---
uid: mit-6824-s21-resource-reading-14
type: course
document_type: resource
resource_kind: reading
resource_order: 114
course: mit-6824-s21
title: Lecture 14 阅读指南：Spanner
description: Lecture 14 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 14 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-14/"
toc: true
official_lecture_number: 14
math: true
---

## 1. 来源、范围与证据边界

- 指定阅读是完整的 **Spanner: Google's Globally-Distributed Database (OSDI 2012)**；课程材料没有另行缩小 paper section 范围。
- 本指南以归档论文为机制与评测事实的主来源；FAQ 用于解释时钟、external consistency 与 commit wait；课堂 NOTES 用于连接老师的讲授顺序。三者的内容不互相冒充。
- 论文描述的是 2012 年系统与当时评测配置。副本数、延迟、TrueTime uncertainty、F1 使用方式等数字必须连同表格或实验设置阅读，不能当作所有部署的固定常数。
- 课堂在主讲中聚焦 read-write/read-only transaction、safe time 与 TrueTime；schema change 只在结尾作为 paper-only extension 提到，不应写成课堂主线。

资源：

- [Lecture 14 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-14.md)
- [Spanner 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/spanner.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/spanner-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/14-q-spanner.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-spanner.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-14-spanner)
- [Lecture 14 NOTES](/courses/mit-6824-s21/lectures/014/)
- [Lecture 14 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=14)

## 2. 带着什么问题读论文

1. Spanner 如何同时使用 **sharding** 与 **replication**，二者分别解决什么问题？
2. 为什么一个 tablet/Paxos group、一个 directory 和一个 application table row 不是同一层抽象？
3. Read-write transaction 如何组合 2PL、2PC 与 Paxos；哪些状态只在 leader，哪些状态必须复制？
4. Read-only transaction 为什么必须预先声明只读，才能走 lock-free snapshot path？
5. `TT.now()` 为什么返回 interval 而不是一个看似精确的时间点？
6. Leader-lease disjointness、Paxos timestamp monotonicity 与 external-consistency invariant 如何逐层依赖？
7. 一个 replica 在什么条件下可证明自己足够新，从而服务 timestamped read？
8. Prepared-but-uncommitted transaction 为什么会压低 safe time？
9. Commit wait 证明了什么，又没有证明什么？
10. 论文评测分别测 replication、2PC scale、availability、TrueTime 与 F1；每组结果的适用边界是什么？

## 3. 系统模型：先分清数据与管理层次

### 3.1 Universe、zone 与 spanserver

- 一个 Spanner deployment 称为 **universe**。
- Universe 由多个 **zones** 组成；zone 是部署、管理和物理隔离单位，也是 replicas 可放置的位置集合。
- 每个 zone 有一个 zonemaster 和许多 spanservers；location proxy 帮 client 找到数据所在 spanserver，placement driver 在分钟量级搬移数据以满足 placement constraints 或平衡负载。

### 3.2 Tablet、Paxos group 与 directory

每个 spanserver 管理许多 tablet。Tablet 保存的底层映射是：

$$
(key, timestamp) \rightarrow value.
$$

- 每个 tablet 上建立一个 Paxos state machine；同一 state machine 的 replicas 组成一个 **Paxos group**。
- Paxos leader 接受 writes；足够 up-to-date 的 replica 可以直接从 tablet 服务某些 reads。
- Leader 维护 lock table 和 transaction manager。Lock table 支持 2PL；跨多个 Paxos groups 的 transaction 才需要 transaction managers 协作 2PC。
- **Directory** 是具有共同 key prefix 的数据集合，是 placement 与 movement 的逻辑单位；一个 Paxos group 可包含多个 directories。论文也说明过大的 directory 实际会拆成 fragments，因此不要把 directory 简化成永不拆分的单块数据。

### 3.3 数据模型与 locality

Spanner 在 versioned key-value substrate 上提供 schematized semi-relational tables、query language 与 general-purpose transactions。Primary key 不只标识 row，也让 application 通过 table hierarchy 与 interleaving 表达 locality。这样做的 tradeoff 是：应用 schema/key 设计参与数据布局；收益是相关 rows 可被 colocate，并以 directory 粒度配置复制位置。

## 4. Read-write transaction：2PL + 2PC over Paxos

### 4.1 单组与跨组路径

- 若 transaction 只涉及一个 Paxos group，lock table 与 Paxos 已能提供事务性，可绕过 distributed transaction manager。
- 若涉及多个 groups，participant leaders 运行 2PC；其中一个 participant group 同时承担 coordinator group，coordinator state 因而也由 Paxos 复制。

### 4.2 协议主线

```text
client executes reads at participant leaders
  -> leaders acquire read locks
  -> client buffers writes
  -> non-coordinator participants acquire write locks
  -> each logs PREPARE through its Paxos group
  -> coordinator chooses one commit timestamp
  -> coordinator logs COMMIT through Paxos
  -> commit wait
  -> notify client and participants
  -> participants log outcome, apply at same timestamp, release locks
```

重要边界：

- 普通 leader-local lock-table state 不必为每次 read 都复制；论文依赖 long-lived Paxos leaders提高 lock-table 管理效率。
- Participant 一旦进入 prepared state，恢复所需的信息不能只留在易失 leader memory；prepare record 通过 Paxos 复制。
- Replicated coordinator 缓解单 coordinator crash 导致的 2PC blocking，但并没有消除 wide-area latency、locking、2PC 或 network partition 的代价。
- Read-write transactions 使用 wound-wait 避免 deadlock；client 在 transaction open 时发送 keepalive。

## 5. TrueTime：把不确定性写进 API

TrueTime API 的核心不是宣称机器知道精确时间，而是返回一个保证包含绝对时间的区间：

$$
TT.now()=[earliest, latest],
$$

$$
earliest \le t_{abs}(e_{now}) \le latest.
$$

论文以 $\epsilon$ 表示 interval 半宽。实现同时使用 GPS 与 atomic clocks，因为二者有不同 failure modes；datacenter 内 time masters 与每台机器的 timeslave 交叉检查来源，并在两次同步之间按最坏 clock drift 扩大 uncertainty。这里的安全性依赖 **bound 正确**，性能则取决于 interval 是否足够窄。

不要混淆：

- Atomic clock 是稳定 oscillator，不会自动在启动时知道 UTC；FAQ 明确指出仍需同步。
- `TT.now()` 的 interval 宽，不等于返回错误信息；只要真时间仍在 interval 内，bound 仍正确。
- GPS、atomic clocks、Marzullo-like filtering 和 machine eviction 是 TrueTime implementation 的 failure containment，不是 transaction protocol 本身。

## 6. 三个不变量与 external-consistency 推导

### 6.1 Leader lease disjointness

对同一 Paxos group，不同 leaders 的 lease intervals 必须互不重叠。Leader 只能在自己的 lease interval 内分配 timestamps；abdicate 前要等待 `TT.after(smax)`，其中 `smax` 是它用过的最大 timestamp。

### 6.2 Paxos timestamp monotonicity

同一 Paxos group 的 Paxos writes 即使跨 leader，也按 monotonically increasing timestamps 分配和应用。它依赖 lease disjointness，随后又成为 safe-time 判断的基础。

### 6.3 External consistency

若 $T_1$ 的 commit 在绝对时间上早于 $T_2$ start，则要求：

$$
t_{abs}(e^{commit}_1)<t_{abs}(e^{start}_2) \Rightarrow s_1<s_2.
$$

Read-write timestamp assignment 遵循两条规则：

1. **Start rule**：coordinator 在收到 commit request 后选择 $s_i \ge TT.now().latest$。
2. **Commit wait**：在 `TT.after(si)` 为真之前，不让 client 看见 transaction 已完成。

论文给出的证明链是：

$$
s_1<t_{abs}(e^{commit}_1)
<t_{abs}(e^{start}_2)
\le t_{abs}(e^{server}_2)
\le s_2.
$$

因此 $s_1<s_2$。Commit wait 的职责是把 chosen timestamp 推入 transaction completion 的真实过去；它不负责复制 data，也不负责证明某个 follower 已应用完整历史。

## 7. Timestamped reads、safe time 与 read-only path

### 7.1 Operation 类型

- **Read-write transaction**：pessimistic 2PL，transactional reads 到 leader。
- **Read-only transaction**：必须预先声明无 writes；系统选择一个 timestamp，所有 reads 作为 snapshot reads 执行，不加 locks。
- **Snapshot read**：client 给 timestamp 或 staleness bound；在足够新的任意 replica 上读取历史 snapshot。

一旦 read-only/snapshot transaction 已选 timestamp，只要该版本未被 garbage collected，commit 就是 inevitable；server failure 后可以在另一 server 以同一 timestamp 和 read position 继续。

### 7.2 Safe-time invariant

Replica 只有在 $t \le t_{safe}$ 时才能服务 read at $t$：

$$
t_{safe}=\min(t^{Paxos}_{safe},t^{TM}_{safe}).
$$

- $t^{Paxos}_{safe}$ 是已应用的最高 Paxos-write timestamp。因为 timestamps 单调且 writes 按序应用，系统知道该 frontier 之前不会再插入 Paxos write。
- 无 prepared transactions 时，$t^{TM}_{safe}=\infty$；否则取所有 prepared transactions 的 prepare-timestamp lower bound 中最小者再减一。原因是这些 transaction 的最终 commit/abort 尚不确定。

论文随后用 fine-grained key-range safe time 减少无关 prepared transaction 造成的 false conflict，并用 `MinNextTS` 让没有新 writes 的 idle Paxos group 也能推进 $t^{Paxos}_{safe}$。

### 7.3 Read-only timestamp

Read-only transaction 先选择 $s_{read}$，再让所有 reads 在该 timestamp 读取。单 Paxos group scope 可利用 `LastTS()`；多 group scope 的实现选择 `TT.now().latest`，避免一轮跨 groups negotiation，但可能等待 replicas 的 safe time 追上。

这条路径的核心交换是：

```text
no read locks + no 2PC + any sufficiently fresh replica
  <-> multi-version storage + timestamp selection + safe-time waiting
```

## 8. Failure、availability 与恢复边界

- Paxos groups 提供同步复制和 majority progress；replica placement 可跨 failure domains 或 datacenters。
- Long-lived leader leases 降低稳定状态开销，但 hard leader failure 后要等待旧 lease 到期才能安全选新 leader。论文 availability experiment 使用 10 秒 leases，hard-kill leader zone 后 groups 随 lease 到期逐步恢复；这不是所有部署的固定 failover time。
- TrueTime 同时使用 GPS 和 atomic clocks，交叉检查并隔离异常 clock source；论文仍把正确 uncertainty bound 作为系统假设。
- 2PC participant 的 prepared state 会阻塞相关 safe time 与 locks，直到 outcome 可确定；Paxos replication 提高获取 decision 的可能性，并不把不可达网络分区变成可用状态。
- Multi-version data 受 garbage-collection policy 约束；过旧 snapshot 的版本若已被收集，就不能继续承诺可读。

## 9. Evaluation：数字要连同实验条件读

### 9.1 Microbenchmarks 与 2PC scale

- Table 3 的 machines 位于 network distance 小于 `1 ms` 的 datacenters；4 KB operations 主要从 memory 服务。由 single-replica experiments，论文估计 commit wait 约 `5 ms`、Paxos latency 约 `9 ms`。
- 增加 replicas 时，snapshot-read throughput 可因任意 up-to-date replica 而近线性增加；write 的每次复制工作却随 replicas 增加。
- Table 4 中 2PC 到 `50` participants 的 mean/99th-percentile 仍被论文称为 reasonable；`100` participants 起 latency 明显上升，`200` participants 更高。结论不是“2PC participant 数量免费扩展”。

### 9.2 Availability 与 TrueTime

- Figure 5 中 non-leader zone kill 几乎不影响 read throughput；graceful leader handoff 影响较小；hard leader-zone kill 使 throughput 近零后随 leases 到期恢复。
- Figure 6 显示 base $\epsilon$ 通常较小，但 network congestion 或 time-master maintenance 会产生 tail spikes。论文把这些 spikes 直接视为性能问题，并持续排查原因。

### 9.3 F1 与结论边界

论文以 Google advertising backend F1 为生产 case study，说明 Spanner 被用于替代手工分片的 MySQL backend，并权衡 locality、replica placement、事务能力与 latency。它证明的是系统在该 workload/configuration 下可用，不是所有 application 都应选择全球复制或 cross-shard transaction。

## 10. 主要 tradeoffs

| 选择 | 收益 | 代价/边界 |
| --- | --- | --- |
| 跨 datacenter synchronous Paxos replication | durability、availability、geographic locality | WAN latency、复制工作、leader/lease 管理 |
| 2PL + 2PC | general cross-shard atomic transactions | locks、deadlock handling、prepared blocking、协调消息 |
| TrueTime interval | 可证明的 global-time ordering | time infrastructure；$\epsilon$ 进入等待路径 |
| Commit wait | real-time order 与 timestamp order 对齐 | read-write completion latency |
| Multi-version storage | lock-free historical/snapshot reads | version storage、GC 与 safe-time bookkeeping |
| Read-only predeclaration | 无 locks、无 2PC、可选近端 replica | 不能在途中变成 writer；可能等待 safe time |
| Directory/application placement control | locality 与 failure-domain policy | schema/key/placement 配置复杂度 |

## 11. FAQ 与课堂连接

- FAQ 用 password-change 例子说明 external consistency：一个 datacenter 中已完成的变更，必须被随后在另一 datacenter 开始的 transaction 看见。
- FAQ 将 external consistency 解释为 transaction-level linearizability/strict serializability；课堂 NOTES 用 `finish(T1)<start(T2)` 的条件反复限定，重叠 transactions 不受同样 real-time precedence 约束。
- 课堂先用“逐次读取 latest committed value”的反例说明 individual freshness 不等于 transaction snapshot，再引入 timestamped versions；对应论文 Section 4.1 的 read-only/snapshot path。
- 课堂 safe-time 简图与论文公式一致，但论文还区分 $t^{Paxos}_{safe}$、$t^{TM}_{safe}$、fine-grained key ranges 和 idle-group `MinNextTS`；复习时不要用简图替代完整定义。
- FAQ 说在本论文抽象层可用 Raft 替代 Paxos；这是 replicated-state-machine 层的类比，不意味着实现、历史或所有性能细节相同。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Spanner Suppose a Spanner server's TT.now() returns correct information, but the uncertainty is large. For example, suppose the absolute time is 10:15:30, and TT.now() returns the interval [10:15:20,10:15:40]. That interval is correct in that it contains the absolute time, but the error bound is 10 seconds. See Section 3 for an explanation TT.now(). What bad effect will a large error bound have on Spanner's operation? Give a specific example.

下面是推理脚手架，不给可直接提交的结论或完整例子：

1. 把题给 interval 写成 `earliest`、`latest` 与 $\epsilon$，先确认真实时间仍被包含，因此首先要分析的是 performance path，而不是假定 clock bound 已失效。
2. 从论文 Section 4.1.2 抄出 read-write 的 start rule 与 commit-wait predicate；分别代入题给 endpoints，列出“可选择 timestamp 的最早界”和“允许对 client 完成的最早界”。
3. 选择一笔具体 read-write transaction，自己给出 commit request 到达时刻；比较小 $\epsilon$ 与题给 $\epsilon$ 时同一协议步骤的 earliest completion。
4. 再检查 Section 4.1.4：若 read-only transaction 采用 `TT.now().latest`，它要读取的 timestamp 与 replica $t_{safe}$ 之间可能出现什么关系？
5. 明确你的例子影响的是 latency、blocking、throughput 还是 correctness，并指出由哪一个 inequality 得出。
6. 不要只写“会更慢”；提交答案应包含具体 transaction、具体 timestamp/predicate 和具体等待位置。

## 13. 理解检查：10 组问答

1. **问：Spanner 中 sharding 与 replication 分别提供什么？**  
   **答：** Sharding 把 key space 分给不同 groups 以获得容量和并行吞吐；每个 shard 的 Paxos replication 提供故障容忍、同步副本与 geographic locality。（来源：论文 §1-2、课堂 NOTES）

2. **问：为什么 directory 不是 Paxos group 的同义词？**  
   **答：** Directory 是 placement/movement 的应用可控逻辑单位；一个 Paxos group 可装多个 directories，过大的 directory 还可拆成 fragments。（来源：论文 §2.2）

3. **问：跨多个 Paxos groups 的 read-write transaction 怎样实现 atomicity 与 serializability？**  
   **答：** Participant leaders 用 2PL 控制冲突，用 2PC 形成一个 global commit/abort outcome；prepare 与 coordinator decision 通过相关 Paxos groups 复制。（来源：论文 §2.1、§4.2.1）

4. **问：TrueTime 的核心 guarantee 是什么？**  
   **答：** `TT.now()` 返回的 `[earliest, latest]` 保证包含调用期间的绝对时间；它显式暴露 uncertainty，而不是返回未经界定误差的单点时间。（来源：论文 §3）

5. **问：commit wait 为什么使用 `TT.after(s)`？**  
   **答：** 它保证 transaction 对 client 完成时，commit timestamp 已在真实过去，从而让严格后开始的 transaction 取得更大的 timestamp。（来源：论文 §4.1.2、FAQ）

6. **问：safe time 为什么是两个 frontier 的最小值？**  
   **答：** Replica 既要确认 Paxos writes 已按序应用到目标 timestamp，也要确认没有更早 prepared transaction 的 outcome 未决；任一条件不足都不能证明 snapshot 完整。（来源：论文 §4.1.3）

7. **问：read-only transaction 为什么不是“恰好没写的 read-write transaction”？**  
   **答：** 它必须预声明只读，系统才能安全选择一次 snapshot timestamp、跳过 locks，并在任意足够新的 replica 上执行；途中不能再产生 writes。（来源：论文 §4.1）

8. **问：为什么 read at old timestamp 不必违反 external consistency？**  
   **答：** 只要 timestamp assignment 尊重所有已完成 transactions 的 real-time precedence，读取对应历史 version 就是该 transaction 的合法 serial snapshot；不能把“旧版本”自动等同于错误。（来源：论文 §4.1.4、课堂 NOTES）

9. **问：hard leader failure 的恢复为什么受 lease length 影响？**  
   **答：** 新 leader 必须避免与旧 leader lease overlap；旧 lease 安全到期后才能重新取得 leadership。缩短 lease 可减小 failure pause，但增加 renewal traffic。（来源：论文 §4.1.1、§5.2）

10. **问：论文评测能否证明 replica 越多总是越快？**  
    **答：** 不能。Snapshot reads 可利用更多 replicas 提升吞吐，但 writes 要做更多复制工作；实验中的 leader 分布与 spanserver 数也会影响 observed throughput。（来源：论文 §5.1）
