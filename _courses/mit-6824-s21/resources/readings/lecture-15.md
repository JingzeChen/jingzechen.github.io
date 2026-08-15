---
uid: mit-6824-s21-resource-reading-15
type: course
document_type: resource
resource_kind: reading
resource_order: 115
course: mit-6824-s21
title: Lecture 15 阅读指南：Optimistic Concurrency Control（FaRM）
description: Lecture 15 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 15 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-15/"
toc: true
official_lecture_number: 15
math: true
---

## 1. 来源、范围与双媒体边界

- 指定阅读是完整的 **No compromises: distributed transactions with consistency, availability, and performance (SOSP 2015)**；课程材料没有指定只读某几个 sections。
- 官方 Lecture 15 被拆成两个连续媒体分段，二者共同构成本讲，不能把 Part 16 误标为 Lecture 16：
  - Part 15 建立 FaRM 的 deployment/hardware assumptions、RDMA、OCC、Figure 4 正常提交路径与第一个冲突例子。
  - Part 16 续讲 read validation 的交叉条件写、read-only fast path、commit-point crash 的恢复证据和系统边界。
- 论文给出完整 transaction recovery protocol；课堂 Part 2 只建立关键恢复直觉，并明确没有展开完整 algorithm。本文会把两层证据分别标出。
- 论文数字来自 90-machine research cluster 与特定 TATP/TPC-C 配置。FAQ 也明确把 FaRM 称为 research prototype；不能把峰值吞吐推广成任意 workload、硬件或跨地域部署的保证。

资源：

- [Lecture 15 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-15.md)
- [FaRM 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/farm-2015.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/farm-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/15-q-farm.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-farm.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-15-optimistic-concurrency-control-farm)
- [Lecture 15 Part 1 NOTES](/courses/mit-6824-s21/lectures/015/)
- [Lecture 15 Part 2 NOTES](/courses/mit-6824-s21/lectures/016/)
- [Lecture 15 Part 1 视频](https://www.bilibili.com/video/BV16f4y1z7kn/?p=15)
- [Lecture 15 Part 2 视频](https://www.bilibili.com/video/BV16f4y1z7kn/?p=16)

## 2. 论文的设计命题

FaRM 的目标是在一个 datacenter 内提供 distributed ACID transactions、strict serializability、durability、high availability、high throughput 与 low latency。它的论点不是“协议不再有代价”，而是：若正常路径的 storage、network 与 CPU bottlenecks 都被一起重做，强 transaction semantics 不必像过去那样慢。

读论文时沿三条因果链追踪：

```text
commodity DRAM + battery-backed power + SSD
  -> power failure 时保存 memory image
  -> normal path 把 replicated DRAM 当作 NVRAM
  -> durability 不必同步等待 SSD write
```

```text
kernel bypass + one-sided RDMA
  -> source application 直接驱动 NIC
  -> remote NIC 读写 memory，remote CPU 不在 fast path
  -> transaction protocol 必须减少 messages 与 remote CPU work
```

```text
execute 时 one-sided reads
  -> 无法让 remote CPU 在每次 read 前主动加锁
  -> optimistic execution + local write buffering
  -> commit 时 LOCK write set + VALIDATE read-only set
  -> success 才复制 decision/data 并公开 writes
```

## 3. System model 与硬件假设

### 3.1 Address space、regions 与 roles

- FaRM 向 application 提供跨 cluster 的 global address space。Application thread 开始 transaction 后，同时成为其 unreplicated coordinator。
- Address space 分成 `2 GB` regions；每个 region 有一个 primary 和 $f$ 个 backups，放在预期独立的 failure domains。
- Object 从 primary 读取；本地 primary 用 memory load，远端 primary 用 one-sided RDMA read。每个 object 有 64-bit version/header，用于 concurrency control 与 replication。
- Configuration Manager（CM）维护 region 到 replicas 的映射；ZooKeeper 持久化并协调 configuration changes。它们不参与每次 object transaction 的 fast path。
- Per sender-receiver pair 的 ring buffers 分别充当 transaction logs 或 message queues。Sender 通过 one-sided RDMA write 追加，receiver 后台 poll 并 lazily truncate。

### 3.2 “Non-volatile DRAM”的准确含义

论文用 distributed UPS/Local Energy Storage 在 power failure 时给机器供电，把 DRAM 内容写到 SSD。它不是说普通 DRAM 天生不挥发：

- Power failure path 依靠 battery + SSD 保存 memory image。
- 其他 machine crash 仍可能丢失该机器 memory，所以每个 region 与 transaction log 必须复制。
- 若去掉 non-volatile RAM，COMMIT-BACKUP 等 one-sided log writes 不能仅凭 NIC acknowledgement 承诺 power-failure durability；改为同步 SSD writes 会改变延迟与吞吐。

### 3.3 RDMA 的语义边界

- **One-sided RDMA**：发起端 software 主动，目标 NIC 直接访问 memory，不运行目标 CPU code。
- **RDMA-based message/RPC**：sender 把 request 写入 remote queue，目标 polling thread 仍要处理并写回 reply。
- **Hardware ACK**：证明 remote NIC 已完成 memory write；不证明 remote application thread 已处理 log record，也不证明 object in-place value 已更新。
- Access control 在 connection/setup 时配置；fast path 绕开 kernel 不等于可任意访问目标进程 memory。

## 4. Programming model 与 OCC contract

Transaction execute phase 可以读取、写入、allocate/free objects，并执行 arbitrary application logic。Updates 先缓存在 coordinator，成功 commit 才对其他 transactions 可见。

FaRM 对成功提交的 transactions 提供 **strict serializability**。但 execute 期间的 contract 更弱：

- 单 object read 是 atomic，只返回 committed data。
- 同一 transaction 重复读取同一 object 返回一致数据；读取自己写过的 object 返回本 transaction 的最新 buffered value。
- 不保证不同 objects 的多次 reads 在 execute 期间已经组成 atomic snapshot。
- 若这些 reads 不能组成可串行化结果，commit validation 必须让 transaction abort。Application 必须防御暂时不一致，至少不能在到达 commit/abort 前 crash。

这正是 FAQ 强调的边界：**只有 committed transactions 才获得 strict serializability**。OCC 用省掉长期 read locks 的成本，换取冲突时 wasted work、abort 与 retry；长 transactions 或 hot records 会扩大冲突窗口。

## 5. Figure 4：正常提交协议

### 5.1 Execute

Coordinator 用 one-sided RDMA 读取 objects，记录 addresses 与 versions，并在本地维护 read/write sets 与 buffered new values。Remote read-only participants 不消耗 foreground CPU。

### 5.2 LOCK

对每台保存 write-set primary 的机器，coordinator 追加一个 `LOCK` record，其中包含 transaction ID、涉及的 regions，以及该 primary 上所有待写 objects 的 address、read version 与 new value。

Primary 对每个 object 原子检查并尝试设置 lock：

$$
lock=0 \land v_{current}=v_{read}.
$$

若 object 已锁或 version 已改变，LOCK 失败，coordinator abort；它不等待现有 lock 释放，因为 buffered computation 已基于旧输入。

### 5.3 VALIDATE

Coordinator 重读“read but not written” objects 的 versions/lock bits：

- 默认用 one-sided RDMA reads。
- 同一 primary 上超过阈值 $t_r$（论文当时为 4）时改用 RPC，以平衡多个 RDMA reads 与一次 RPC 的 CPU cost。
- 任一 version change 或 active lock 都使 transaction abort。

Lock bit 不能省略：并发 writer 可能已锁 object、尚未安装 new value 或递增 version；只看 version 会漏掉正在发生的 conflict。

### 5.4 COMMIT-BACKUP

全部 LOCK/VALIDATE 成功后，coordinator 把含完整 update payload 的 `COMMIT-BACKUP` record 写入每个相关 backup 的 non-volatile log，并等待 **所有** hardware ACKs。Backup CPU 不在 critical path。

### 5.5 COMMIT-PRIMARY

所有 backup writes 被确认后，coordinator 向 primaries 写 `COMMIT-PRIMARY` record。收到至少一个此类 hardware ACK（或本地写）后可以向 application 报告 committed。Primary 处理该 record 时：

1. 把 new values 安装到 objects；
2. 递增 versions；
3. 清除 locks，使 writes 可见。

### 5.6 TRUNCATE

Primaries/backups 在安全前保留 records。Coordinator 收到所有 primary ACKs 后 lazily truncate logs；backups 可在 truncation 时把 log updates 应用到 in-place objects。Logs 是 per-coordinator/per-pair 结构，因此 truncation frontier 可按顺序回收。

完整顺序：

```text
EXECUTE
  -> LOCK(write set at primaries)
  -> VALIDATE(read-only set)
  -> COMMIT-BACKUP(all relevant backups ACK)
  -> COMMIT-PRIMARY(at least one primary ACK before client success)
  -> TRUNCATE(lazy cleanup)
```

## 6. 正确性不变量与 serialization point

### 6.1 无故障 strict serializability

- Committed read-write transaction 的 serialization point 是所有 write locks 已取得的时刻。
- Committed read-only transaction 的 serialization point 是它最后一次 read 的时刻。
- LOCK 保证 written objects 在 serialization point 的 versions 与 execute 时相同；VALIDATE 保证 read-only objects 也未在该区间改变或被并发 writer 锁住。
- Serialization point 位于 transaction start 与向 application 报告 completion 之间，因此 serializability 还尊重 non-overlapping transactions 的 real-time order，得到 strict serializability。

### 6.2 为什么 backup ACK 必须先于 primary commit

若 coordinator 未等某个 backup 的 `COMMIT-BACKUP` ACK，就让 primary 公开 writes，随后 primary、coordinator 与其他 replicas failure，而该 backup 从未收到 update，committed data 可能丢失。因此：

$$
ACK(all\ COMMIT\text{-}BACKUP) \prec write(COMMIT\text{-}PRIMARY).
$$

### 6.3 为什么 client success 前必须有 commit evidence

Read set 只保存在 coordinator。若 coordinator failure 且没有 surviving commit record，recovery 无法证明 validation 已成功；只有 LOCK records 不能区分“准备提交”与“最终 abort”。所以向 client 返回 success 前至少要留下一个 `COMMIT-PRIMARY` evidence。

### 6.4 Log reservation 与 liveness

传统 prepare 可让 participant CPU 检查资源；FaRM 的 backup write 不运行 remote CPU，因此 coordinator 在 commit 开始前本地 reservation 所需 primary/backup/truncate log space。否则 protocol 可能在已经作出不可逆进展后因 log 满而无法收尾。

## 7. 课堂 Part 1 与 Part 2 如何接起来

### 7.1 Part 1：从硬件到正常路径

[Part 1 NOTES](/courses/mit-6824-s21/lectures/015/) 依次连接：FaRM/Spanner 目标边界 -> UPS-backed NVRAM -> kernel bypass/RDMA -> OCC -> Figure 4 -> 两个 concurrent increments。最后一个例子说明：两个 transactions 读到同一初值后，先提交者会让后提交者在 commit path 看见 lock/version conflict；课堂把完整题目留给 Paper Question。

### 7.2 Part 2：validation、恢复证据与边界

[Part 2 NOTES](/courses/mit-6824-s21/lectures/016/) 用交叉条件写补足 read validation：

$$
T_1: R(x=0);\ if\ x=0\ then\ W(y=1),
$$

$$
T_2: R(y=0);\ if\ y=0\ then\ W(x=1).
$$

两个 transactions 都读到 0 时，serial execution 不能得到 $(x,y)=(1,1)$。课堂排程让 $T_1$ 先锁 $y$；$T_2$ 随后 validation $y$ 时即使 version 尚未改变，也会看见 lock bit 并 abort。这个例子证明 lock bit 对 read/write conflict detection 的必要性，但课堂明确说它不是完整 protocol proof。

Part 2 随后用 commit point 后 crash 说明两类 evidence：LOCK/COMMIT-BACKUP 说明“写什么”，COMMIT-PRIMARY 说明“决定 commit”。它只建立恢复直觉；以下完整 phases 来自论文。

## 8. Failure model、precise membership 与 recovery

### 8.1 Failure assumptions

论文假设 machines 可 crash，通常能保留 non-volatile DRAM；即使每个 object 最多 $f$ 个 replicas 丢失 NVRAM 内容，committed state 仍应 durable。Availability 还要求存在一个互联 partition，它包含 machine majority、ZooKeeper replica majority，并至少含每个 object 的一个 replica。

### 8.2 为什么 one-sided RDMA 需要 precise membership

传统 lease 方案可让 server CPU 在响应请求前检查自己是否仍有资格；one-sided RDMA 由 NIC 直接响应，NIC 不检查 application lease。FaRM 因此在新 configuration 允许 mutations 前，让所有 surviving members 对 membership 达成一致，并要求 clients：

- 不向非当前 members 发 RDMA；
- 忽略已移除 machines 返回的 read result 或 write ACK。

Configuration change 由 CM probe majority、用 ZooKeeper CAS 更新 configuration、remap regions、向所有 members apply/commit，并等待旧 leases 安全过期。

### 8.3 五类 recovery 工作

论文把 failure recovery 分成：

1. failure detection；
2. reconfiguration；
3. transaction state recovery；
4. bulk data recovery；
5. allocator state recovery。

Transaction-state recovery 的核心步骤是：block recovering regions、drain logs、找出跨 configuration 的 recovering transactions、恢复 locks、补齐 log replicas、由各 regions vote、coordinator 决定 commit/abort。关键 invariant 是 preserve 已决定 outcome：已公开或已报告 committed 的 transaction 必须继续 commit，已 abort 的不能复活。

Lock recovery 完成后 region 即可重新服务 foreground transactions；bulk re-replication 在后台进行并 pacing。这把“恢复可服务性”和“恢复完整 replica count”拆开，降低故障对前台 latency 的影响。

## 9. Evaluation：性能数字与条件

### 9.1 Workloads

- TATP read-dominated：论文配置中 `70%` 是 single-row lock-free lookups，`10%` 是读取 2-4 rows 并 validation，`20%` 是 updates。它天然有利于 read/RDMA fast path。
- TPC-C transactions 更复杂，可访问 hundreds of rows；论文用 locality-aware partitioning，使约 `10%` transactions 访问 remote data。

### 9.2 Normal case

- Figure 7：90-machine cluster 上达到 `140 million` TATP transactions/s，median latency `58 us`，99th percentile `645 us`；最低负载点的 latency 更低，但吞吐也远低于峰值。
- Figure 8：达到 `4.5 million` TPC-C new-order transactions/s，median `808 us`、99th percentile `1.9 ms`。
- Read-only lookup workload 达 `790 million lookups/s`，median `23 us`；论文指出此时 benchmark 已 CPU-bound，所以 NIC 数量翻倍没有带来吞吐翻倍。

这些不是 protocol-only 结果：它们依赖 90 machines、Infiniband/RDMA、NVRAM assumption、数据布局、低冲突比例与 benchmark mix。

### 9.3 Failures

- Typical TATP single-machine failure run 在 `40 ms` 内回到 peak throughput，所有 regions 在 `39 ms` active；完整后台 re-replication 用时更长但被 pacing。
- TPC-C 恢复大部分 throughput 少于 `50 ms`，但 locality placement 降低 data-recovery parallelism，完整 re-replication 可超过 4 分钟。
- 40 次 TATP experiments 的 median recovery 约 `50 ms`；超过 70% 少于 `100 ms`，全部少于 `200 ms`。论文摘要的“less than 50 ms”应与具体 typical run/指标一起读。
- CM failure 恢复约 `110 ms`；同时 failure 18/90 machines 的实验约 `400 ms` 恢复 peak throughput。Failure scope 与 coordinator role 会改变结果。

## 10. Tradeoffs 与适用边界

| 设计选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| 数据全在 aggregate RAM | 极低 read latency | 数据集必须装入 cluster memory；成本与容量边界 |
| UPS-backed NVRAM | normal path 不等 SSD | 特殊供电/SSD 假设；普通 crash 仍需 replication |
| One-sided RDMA | 少 messages、少 remote CPU | 特殊 NIC、polling、setup；membership/recovery 更复杂 |
| OCC | 无长期 read locks，适合低冲突 | 高冲突/长 transaction 造成 abort、retry 与 wasted work |
| Primary-backup + unreplicated coordinator | 比 Paxos-based participants 少副本/messages | recovery 必须从分散 logs 重建 decision；部署目标是 datacenter-local |
| Application 与 FaRM 共进程、threads pinned | 避免软件栈开销 | API/runtime 集成更紧，application 必须防御 temporary inconsistency |
| Lazy truncation/background recovery | 缩短 commit 与恢复关键路径 | logs、reservations、pacing 和 outcome bookkeeping 更复杂 |

## 11. FAQ 连接与常见误解

- FAQ 明确指出“no compromises”不是普适 CAP 结论：无 transaction 的 one-sided access 仍可更快，FaRM 也不解决 geographic transaction 的全部问题。
- “RDMA 快”不是完整解释。FaRM 软件同时减少 messages、使用 one-sided operations、并行 recovery，并把 remote CPU work lazy/batched。
- NIC ACK 不等于 server ACK；课堂 Part 1/2 都用这个区别解释为何 backup 可不运行 foreground CPU，以及为何 recovery 必须 drain logs。
- Execute 中看到跨 objects 的 temporary inconsistency 不直接违反论文保证；只有成功 commit 的 transaction 必须 strict serializable。Application 若因临时状态 crash，就无法让 FaRM 通过 validation 安全 abort。
- OCC 在 hot object 上不等待 lock，而是 abort/restart。若大量 transactions 同时冲突，吞吐与 latency 会明显恶化。
- Vertical Paxos 在本文语境中指外部 CM/ZooKeeper 管 reconfiguration、数据 writes 用 primary-backup；不要把它误写成每次 transaction 都运行完整 Paxos consensus。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> No compromises: distributed transactions with consistency, availability, and performance : Suppose there are two FaRM transactions that both increment the same object. They start at the same time and see the same initial value for the object. One transaction completely finishes committing (see Section 4 and Figure 4). Then the second transaction starts to commit. There are no failures. What is the evidence that FaRM will use to realize that it must abort the second transaction? At what point in the Section 4 / Figure 4 protocol will FaRM realize that it must abort?

下面只给推理脚手架，不给提交答案：

1. 为 object header 画出 `(lock bit, version)`，记录两个 transactions execute 时各自保存的 initial header 与 buffered new value。
2. 完整走一遍第一笔 transaction 的 Figure 4 normal path，逐阶段标出 lock、object visibility 与 version 在何时改变。
3. 第二笔开始 commit 时，按 `LOCK -> VALIDATE -> COMMIT-BACKUP -> COMMIT-PRIMARY` 的顺序列出每阶段会检查或写入的 evidence。
4. 找出协议第一次比较“execute 时保存的 metadata”和“当前 primary object metadata”的位置；说明比较不通过时为何不能等待后继续使用旧计算结果。
5. 区分两种不同 interleaving：第二笔在第一笔仍持锁时开始 commit，以及题目给定的第一笔已完全结束后才开始 commit。只分析题目指定的后一种作为提交主体。
6. 最终答案应同时明确：evidence 的字段、观察该 evidence 的组件、Figure 4 phase，以及 resulting action；不要只写“发生冲突所以 abort”。

## 13. 理解检查：10 组问答

1. **问：FaRM 的 strict serializability guarantee 是否覆盖 execute 期间每一组跨 object reads？**  
   **答：** 不覆盖。Execute 期间可能暂时不一致；只有成功 committed transactions 必须 strict serializable，无法验证的 transaction 会 abort。（来源：论文 §3、FAQ）

2. **问：为什么 one-sided RDMA 推动 FaRM 选择 OCC？**  
   **答：** One-sided read 不运行 remote CPU，无法在每次 read 前执行传统 server-side locking；FaRM 先无锁读取并缓存写，再在 commit 时集中 LOCK/VALIDATE。（来源：论文 §1、§4；Part 1 NOTES）

3. **问：LOCK 与 VALIDATE 分别覆盖哪些 objects？**  
   **答：** LOCK 覆盖 write set，在 primaries 原子检查 version/lock 并设置锁；VALIDATE 覆盖 read-but-not-written set，默认由 coordinator one-sided 重读 metadata。（来源：论文 §4）

4. **问：为什么 VALIDATE 必须看 lock bit，不能只看 version？**  
   **答：** 并发 writer 可能已经取得 lock、但尚未安装 value 和递增 version；lock bit 让 reader 在这个窗口也能发现 conflict。（来源：论文 §4、Part 2 NOTES）

5. **问：COMMIT-BACKUP 与 COMMIT-PRIMARY records 各证明什么？**  
   **答：** 前者保存在 backups 完成 transaction 所需的 update payload；后者证明 commit decision。只有 update 内容而无 decision，recovery 不能断言 transaction 已 commit。（来源：论文 §4-5、Part 2 NOTES）

6. **问：为什么向 client 报告 success 前只需至少一个 COMMIT-PRIMARY ACK，却要所有 COMMIT-BACKUP ACK？**  
   **答：** 所有 backups 先保存各自 updates，避免已公开 data 在允许 failures 后丢失；至少一个 surviving primary commit record 则证明 validation 成功和 global decision。（来源：论文 §4 correctness）

7. **问：precise membership 解决了 one-sided RDMA 的什么问题？**  
   **答：** Remote NIC 不会像 server CPU 那样检查 lease；新 configuration 必须让 members 一致，并由发起者停止向已移除机器操作、忽略其 replies/ACKs。（来源：论文 §5.2）

8. **问：为什么 lock recovery 后可以先恢复 foreground service，再做 bulk data recovery？**  
   **答：** Locks 与 transaction outcomes 恢复后可保护/解释当前状态；补齐 $f+1$ replicas 是恢复未来 fault tolerance 的后台工作，可在前台继续运行时 pacing。（来源：论文 §5.3-5.4）

9. **问：140 million TATP transactions/s 主要在哪些条件下成立？**  
   **答：** 90-machine RDMA/NVRAM cluster、read-dominated TATP mix、数据与布局配置及相对低冲突共同作用；不能视为任意 distributed transaction workload 的常数。（来源：论文 §6、FAQ）

10. **问：为什么必须把两个课堂媒体分段一起复习？**  
    **答：** Part 1 建立硬件、OCC 与 normal commit path；Part 2 才用交叉条件写说明 lock-bit validation，并连接 fault-tolerance evidence 与系统边界。两者属于同一 Lecture 15。（来源：MATERIALS、两份 NOTES）
