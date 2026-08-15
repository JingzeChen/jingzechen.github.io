---
uid: mit-6824-s21-resource-reading-11
type: course
document_type: resource
resource_kind: reading
resource_order: 111
course: mit-6824-s21
title: Lecture 11 阅读与作业指南：Chain Replication
description: Lecture 11 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 11 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-11/"
toc: true
official_lecture_number: 11
math: true
---

## 1. 来源、指定范围与证据边界

- 指定论文：**Chain Replication for Supporting High Throughput and Availability**（Robbert van Renesse and Fred B. Schneider, OSDI 2004）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- 本讲有官方 Paper Question，课程归档没有 Lecture 11 配套 FAQ；本指南不从其他学期的 CRAQ、实现博客或后续系统补写 CR 事实。
- 课堂 [Lecture 11 NOTES](/courses/mit-6824-s21/lectures/011/) 只用于“课堂连接”。Paper 的 formal state、完整 reconfiguration bookkeeping、simulation 参数和 placement results 不反向写入 transcript notes。

资源：

- [Lecture 11 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-11.md)
- [CR (2004) 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/cr-osdi04.pdf)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/11-q-cr.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-11-chain-replication)
- [Lecture 11 NOTES](/courses/mit-6824-s21/lectures/011/)
- [Lecture 11 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=11)

## 2. 阅读目的

Paper 的目标不是只发明一条 `head -> tail` 消息路径，而是给 fail-stop storage servers 一套包含 interface specification、normal operation、failure reconfiguration、chain extension、throughput/availability evaluation 和 replica placement 的完整方案。阅读时应回答：

1. 为什么把 update 的排序放在 head、把 query 与 reply 放在 tail，仍能实现 strong consistency？
2. `Hist`、`Pending` 与 `Sent` 如何把 client-visible specification 映射到各 replica 的 local state？
3. Head、tail、internal server failure 分别改变哪些 logical state，为什么只有 internal failure 需要 suffix transfer？
4. 为什么 high availability 既依赖 replication factor，也依赖 repair speed、parallel recovery 与 replica placement？
5. Paper 的 simulation 证明了哪些 workload 下的趋势，又没有证明哪些 production-system 性质？

## 3. 问题、接口与故障模型

### 3.1 Storage-service scope

Paper 讨论介于 file system 与 database 之间的 storage service：

- 存储 objects；
- `query(objId, opts)` 从单个 object 派生结果，不修改 object；
- `update(objId, newVal, opts)` 原子修改单个 object，可包含依赖旧 state 的预编程、甚至 non-deterministic computation；
- 不提供多个 objects 上的 indivisible transaction。

Query 是 idempotent；update 不一定 idempotent。Client timeout 后会 retry，但 non-idempotent update 的 retry 必须由 client 先判断 update 是否已执行，paper 不提供通用 exactly-once request layer。

### 3.2 Client-visible state machine

Paper 用两个变量定义 object `objID`：

- `Hist_objID`：已经执行的 update request sequence；
- `Pending_objID`：已经到达、尚未处理的 requests set。

三类 transitions 是：request 到达并进入 `Pending`；pending request 被忽略；pending request 被处理，其中 query 只返回基于 `Hist` 的结果，update 还追加到 `Hist`。这套 specification 用于证明 server-side steps 对 client 而言只是 no-op 或合法 transition。

### 3.3 Failure assumptions

- Server failure 是 **fail-stop**：server 停止，而不是继续作错误 state transitions；environment 能检测 halted state。
- Object 在 `t` 个 servers 上复制；paper 的 protocol exposition 假设并发失败不超过 `t-1`，即至少一个 replica 存活。
- Master 在讲解模型中先被假设为不失败；prototype 实际用 Paxos 复制 master replicas，使其整体表现为一个不失败的 process。
- Partition 下 CR 不追求 disconnected operation；短暂 outage 被 client 看成 request/reply loss，由 retry 吸收。

## 4. Normal Protocol 与 Strong Consistency

### 4.1 Chain roles

同一 object 的 replicas 线性排列：第一个是 **head**，最后一个是 **tail**。

```text
update:
client -> head -> replica -> ... -> tail -> reply

query:
client --------------------------> tail -> reply
```

- Head 原子处理 update，作出可能的 non-deterministic choice，再把 resulting state change 经 reliable FIFO links 向后传播。
- Intermediate replicas 只需应用并转发 state change，不必重复 head 的 computation。
- Tail 生成所有 replies；query 在 tail 本地原子执行。

### 4.2 Logical implementation

Chain implementation 把 client-visible state 定义为：

- `Hist_objID = Hist^T_objID`，即 tail 的 history；
- `Pending_objID` 是任何 chain server 已收到但 tail 尚未处理的 requests。

Client 把 update 送 head、query 送 tail时，对 logical state 相当于把 request 加入 `Pending`。只有 tail processing 会从 `Pending` 移除 request，并在 update 情形扩展 logical `Hist`。其他 replicas 的传播步骤对 client-visible specification 是 no-op。

### 4.3 Strong-consistency argument

Tail 是 query 与 completed update 的共同 serialization point：

1. Head 对 updates 排序；FIFO links 保留该 order。
2. Tail 以该 order 处理 updates。
3. Query 也只在 tail 处理，并与 updates 串行交错。
4. 因此 query result 反映 tail 已完成的 update prefix，不会暴露只到达前部 replicas 的 partial update。

这一 argument 针对单 object storage-service interface；paper 的 update 虽可 non-deterministic，但 choice 只在 head 计算一次，随后复制 resulting state change。

## 5. Failure Protocol 与 Invariants

### 5.1 Update Propagation Invariant

按 head 到 tail 依次标号 `H ... T`。若 `i <= j`，则 `i` 是 `j` 的 predecessor。定义 `a ⪯ b` 表示 sequence `a` 是 `b` 的 prefix，paper 给出：

$$
\mathrm{Hist}^{j}_{objID} \preceq \mathrm{Hist}^{i}_{objID}
$$

即越靠近 tail 的 successor history，是越靠近 head 的 predecessor history 的 prefix。该方向很容易读反：updates 从 head 向 tail 流动，所以 predecessor 可能多出尚未传完的 suffix。

### 5.2 Head failure

Master 删除旧 head `H`，让其 successor 成为新 head。只被旧 head 收到、尚未转发的 requests 会从 logical `Pending` 消失，这等价于 specification 允许的“忽略 pending request”。Tail 的 `Hist` 不变，因此 completed updates 不丢。

### 5.3 Tail failure

Master 删除 tail `T`，让 predecessor `T-` 成为新 tail。由于旧 tail history 是 predecessor history 的 prefix，新 logical `Hist` 可能向前增加；这相当于一次或多次合法 processing transitions。Client 未收到 reply 的 update 可能在新 tail 中已完成，所以 client-side retry/deduplication 仍是额外问题。

### 5.4 Internal-server failure

删除 internal server `S` 后，原 predecessor `S-` 与原 successor `S+` 直接连接。为防止 `S+` 缺失 `S-` 已经转给旧 `S` 的 updates，每个 server `i` 维护 `Sent^i`：已转发给某 successor、但可能尚未被 tail 处理的 update sequence。

- Server 转发 request `r` 时，把 `r` 追加到 `Sent`。
- Tail 完成 `r` 后，`ack(r)` 沿 chain 向前传播。
- Server 收到 `ack(r)` 后从自己的 `Sent` 删除 `r`，并把 ACK 继续向 predecessor 转发。

Paper 的 Inprocess Requests Invariant 是：

$$
\mathrm{Hist}^{i}_{objID}
=
\mathrm{Hist}^{j}_{objID} \oplus \mathrm{Sent}^{i}
\quad\text{for } i \le j
$$

其中 `⊕` 按全局 update order 合并 sequences。Reconfiguration 时：

1. Master 先通知 `S+` 新 predecessor。
2. `S+` 返回自己收到的最后一个 update sequence number `sn`。
3. Master 把新 successor 与 `sn` 告知 `S-`。
4. `S-` 只把 `Sent` 中 `sn` 之后的必要 suffix 发给 `S+`，然后才处理新位置上后续 requests。

这套 handshake 是 paper-only detail；课堂只讲了“predecessor 重发 successor 缺失的 updates”。

## 6. Extending a Chain

Paper 认为把新 server `T+` 加到 tail 之后最简单，因为 tail 的 `Sent` 初始化为空。流程是：

1. Current tail `T` 向 `T+` 复制 object state/history；复制可与 `T` 继续处理 queries 和来自 predecessor 的 updates 并发。
2. Copy 期间每个新 update 同时追加到 `Sent^T`。
3. 当以下关系成立时，base copy 与 delta 已形成可追赶状态：

$$
\mathrm{Hist}^{T}_{objID}
=
\mathrm{Hist}^{T+}_{objID} \oplus \mathrm{Sent}^{T}
$$

4. `T` 被通知不再是 tail，并把 `Sent^T` 按序发给 `T+`；收到旧 client query 时可转发给新 tail。
5. Master 与 clients 得知 `T+` 是新 tail；`T+` 追平后开始服务。

持续 writes 不要求重新全量复制；需要的是 ordered delta stream 与 serving barrier。

## 7. Primary/Backup 比较

传统 primary/backup 中，primary 对 requests 排序、并行发送给 backups、等待所有 non-faulty backups ACK，再 reply client。CR 把 sequencing responsibility 分给 head 和 tail：head 排 updates，tail 把 queries 插入 completed update sequence。

| 维度 | Chain Replication | 传统 Primary/Backup |
| --- | --- | --- |
| Query | Tail 单机处理 | Primary 可能需等待 prior updates 的 backup ACK |
| Update dissemination | 串行沿 chain | Primary 并行发给 backups |
| Update latency | 相邻 links latency 之和 | 最慢 non-faulty backup latency |
| Client-facing sequencing load | Head/tail 分担 | Primary 集中承担 |
| Failure state | Head/middle/tail 三种 chain case | Primary/backup 两种，但 primary replacement 需比较 backups progress |

Paper 对“检测完成后的 message-delay recovery”给出具体分析：CR head/tail failure 的相关 outage 各约 2 message-delivery delays，middle failure protocol 涉及 4 delays；传统 P/B primary failure 路径约 5 delays，backup failure 最多增加 1 delay。这些是论文模型中的 comparison，不是课堂测得的 wall-clock SLA；failure detection delay 被 paper 认为通常才是 dominant cost。

## 8. Performance 与 Evaluation

### 8.1 Simulation boundary

Paper 使用 prototype protocols 跑 simulated network，重点是 intrinsic processing/communication delays。Network 被设为 infinite bandwidth、每条 message latency `1 ms`；结果不是 production deployment benchmark。

### 8.2 Single-chain setup

- Replication factor `t = 2, 3, 10`；
- Server query latency `5 ms`；head update computation `50 ms`；后续 replica 应用 object difference `20 ms`；
- `25` clients，每个一次最多一个 outstanding request；
- 比较 `chain`、传统 `p/b`，以及允许 query 到 random server、但放弃 strong consistency 的 `weak-chain`/`weak-p/b`。

三节点示例中，paper 计算 update latency 为 `94 ms`，query latency 为 `7 ms`。在所测 update percentages 与 replication factors 中，chain throughput 不低于 p/b。Weak variants 在 query-heavy workload 可利用所有 servers，但 updates 超过约 `15%` 后反而不如 strong chain；原因之一是 random queries 占用 head，减少 head 处理较慢 updates 的 capacity。

Paper 还观察到：在 concurrent requests 足够、能形成 pipeline 时，chain 与 p/b throughput 不因 replication factor 增加而下降。该结论是 throughput，不代表单 request latency 不随 chain 变长。

### 8.3 Multiple chains

Paper 把 objects hash 到 volumes，每个 volume 对应唯一 chain；dispatcher 根据 master 提供的 configuration 转发请求，reply 由 chain 直接发 client。实验使用 `5000` volumes、三副本、`25` clients，requests 在 chains 上均匀随机分布。

Uniform distribution 是扩展结果的重要前提。Object 太大时 replacement copy 慢；object 太小时 chain 数过多，processor/channel multiplexing cost 增加，单 processor failure 也影响更多 chains。Volume size 因而同时控制 recovery granularity 与 multiplexing overhead。

### 8.4 Failure/recovery simulation

Table 1 的 simulated storage service 使用：

- `24` servers、`5000` volumes、chain length `3`；
- 每台 server 存 `150 GB`；
- 每台 recovery bandwidth 最多 `6.25 MB/s`，全量 copy 约 `6 h 40 min`；
- Failed server reboot time `10 min`；master failure detection 约 `10 s`；
- `10` query-only clients 与 `1` update-only client。

Failure 后 throughput 先归零直到 master 检测并从 chains 删除 failed server；随后较少 servers 与 concurrent recovery 使 query throughput 降低。Failed server 回来并接收 volumes 后，throughput逐步恢复，但 placement 不再均匀：它参与较少 chains、却在这些 chains 中全是 tail，造成负载不平衡。Update throughput 一度高于初始值，是因为部分 chains 临时从长度 3 缩成 2，每次 update 工作量变少；这不是 durability 改善。

### 8.5 Availability 与 placement

Paper 比较三种 volume placement：

- `ring`：consistent-hash ring 上连续 servers，parallel recovery 受 chain length 限制；
- `rndseq`：random placement，但 parallel recovery 同样限制为 `t`；
- `rndpar`：random placement，并尽量利用 disjoint sources/destinations 并行恢复。

Availability metric 是任意 object 的 mean time between unavailability（MTBU）。Simulation 为加速采用每台 server `24 h` MTBF、每台初始 `100` volumes、全 server data copy `4 h`；paper 明确承认 `24 h` MTBF 不现实，只是便于模拟。

结果的关键不是“random 永远更好”：在 parallelism 受限时 random placement 的 MTBU 可能低于 ring；当 servers 足够多、rndpar 能利用更多 parallel recovery 时，它最终优于 rndseq 和 ring。Replica placement 与 repair parallelism 必须一起评价。

## 9. 设计权衡与限制

| 选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| Tail-only query | Single-server read、strong consistency、head 不被 queries 干扰 | Tail hotspot；需要 shard/multi-chain balance |
| Head 计算一次、转发 state change | 支持 non-deterministic update；后续 replicas 不重复计算 | Head 是 update compute bottleneck |
| Serial dissemination | 简单 prefix invariants、局部 repair | Single-update latency 为 links/replica costs 之和 |
| Write-all-current-chain | 所有 replicas 知道 completed update prefix | Member unreachable 时需 reconfigure，不能像 quorum 那样直接绕过 |
| Master 统一配置 | 避免 split brain、统一 head/tail | Master 必须自身容错；failure detection/reconfiguration 进入 availability path |
| Client retry | Outage 可表现为 lost request/reply | Non-idempotent updates 需要额外 duplicate handling |
| Tail extension | Online base copy + delta catch-up | Copy time 与 state size 相关；切换需要 ordered barrier |
| Random placement + parallel repair | 大集群可缩短 vulnerability window | Placement imbalance、network/recovery resource competition |

## 10. 官方 Paper Question / Homework

**Assigned Question（原文）**：

> Give an example scenario where a client could observe incorrect results (i.e., non-linearizable) if the head of the chain would return a response to the client as soon as it received an acknowledgment from the next server in the chain (instead of the tail responding).

### 推理脚手架（不是可直接提交的成稿）

1. 画最短但能区分 next server 与 tail 的 chain，例如 `H -> M -> T`，并给 object 一个旧值。
2. 让 Client A 发 update；明确 update 已到 `H` 和 `M`，因此错误协议让 `H` 收到 next-server ACK 后向 A reply。
3. 在 update 到 `T` 之前安排 Client B（或 A 自己）开始 query；query 按正确 CR route 发送给 `T`。
4. 写出两个 operations 的 real-time relation：update reply 先发生，query invocation 后发生。
5. 写出 tail 返回的值，并说明任何保留 real-time order 的 sequential history 都无法把该 query 排到 completed update 之前。
6. 最后指出由 tail reply 为什么删除了这个 execution window；不要只写“tail 比 head 新”。

课堂在 `00:39:23-00:50:17` 实际走过这一 schedule。提交作业时仍应自己写出 events 与 contradiction，而不是复制课堂笔记。

## 11. FAQ 状态

课程归档没有为 Lecture 11 提供独立 FAQ。遇到论文未明确说明的 client retry/deduplication、master replication 或 stale-client routing 问题，应标成 paper/lecture boundary；不要用其他学期 CRAQ FAQ 或后续 chain-based systems 补成本文事实。

## 12. 课堂讨论如何连接并改变重心

[Lecture 11 NOTES](/courses/mit-6824-s21/lectures/011/) 没有从 paper 的 `Hist/Pending/Sent` specification 开始，而是采用系统设计路线：

```text
两种 RSM architecture
-> configuration service + primary/backup
-> head/tail normal flow
-> commit point 与 linearizability 反例
-> 三类 failure
-> tail extension
-> CR/Raft performance-availability tradeoff
-> rotated chains 扩展 reads
```

课堂特别强调了 paper formalism 之外的三个使用边界：

- Configuration service 是防止 split brain 的 safety boundary，不能让 successor 根据 local timeout 自行晋升。
- CR recovery shape 较简单，但 current chain 的任一 member failure 都会先阻塞 writes；不能把“repair 简单”误写成“failure 下立即可用”。
- Cross-chain global order 与 partitioned old-tail stale reads 没有课堂完整证明；version/proxy 只在问答中以 tentative language 出现。

反过来，paper 的 `Sent`/ACK bookkeeping、message-delay comparison、simulation 数字与 placement/MTBU results 均没有被课堂详细讲授，应留在本阅读指南。

## 13. 论文理解题

1. **Paper 的 storage service 为什么介于 file system 与 database 之间？**  
   答案点：单 object query/update；update 可 atomic read-modify-write/non-deterministic；不支持 multi-object transaction。
2. **`Hist` 与 `Pending` 各表示什么？**  
   答案点：已执行 update sequence；已到达但 tail 尚未处理的 request set。
3. **为什么 tail 能成为 strong-consistency serialization point？**  
   答案点：Tail 按 head order 接收 updates，并在同一 server 串行插入 queries/replies。
4. **Update Propagation Invariant 的 prefix 方向是什么？**  
   答案点：Successor history 是 predecessor history 的 prefix。
5. **为什么 head failure 可以丢 requests，而不违反 specification？**  
   答案点：只在旧 head、未到 successor/tail 的 requests 仍属 pending，可对应 ignored transition。
6. **Internal failure 为什么需要 `Sent`，head/tail failure 通常不需要同样 repair？**  
   答案点：直接连接的新 successor 可能缺失 failed middle 收到的 suffix；`Sent` 跟踪可能未到 tail 的 forwarded updates。
7. **Tail extension 为什么可与 normal requests 并发？**  
   答案点：复制 base state时把 concurrent updates 追加到 ordered `Sent`，随后 catch up。
8. **为什么 weak-chain 在 update 比例升高时可能比 strong chain 更慢？**  
   答案点：Random queries 占用 head，减少较昂贵 update processing capacity。
9. **为什么 failure 后 update throughput 上升不代表系统更健康？**  
   答案点：部分 chains 变短、复制工作减少，同时 redundancy 降低。
10. **Placement result 为什么必须与 recovery parallelism 一起解释？**  
    答案点：Random placement 增加失败组合，也可能提供 disjoint sources/destinations；只有充分 parallel repair 时 rndpar 的优势才出现。

## 14. 复习清单

- [ ] 能写出 query/update interface、single-object scope 与 fail-stop assumption。
- [ ] 能画 head/tail paths，并解释 tail-only serialization proof。
- [ ] 能定义 logical `Hist`/`Pending` 与 per-server `Sent`。
- [ ] 能正确写出 Update Propagation Invariant 的 prefix 方向。
- [ ] 能逐 case 说明 head、tail、internal failure 对 logical state 的影响。
- [ ] 能复述 internal deletion 的 `S+ -> sn -> S- -> suffix` handshake。
- [ ] 能从 base copy、`Sent` delta 与 serving barrier 推导 tail extension correctness。
- [ ] 能比较 serial chain 与 parallel primary/backup 的 latency/load tradeoff。
- [ ] 能复述 single-chain simulation setup，并区分 throughput 与 latency 结论。
- [ ] 能解释 failure/recovery 后的 load imbalance 与“短链 update 更快”现象。
- [ ] 能比较 `ring`、`rndseq`、`rndpar`，并说明 parallel recovery 对 MTBU 的作用。
- [ ] 能独立构造官方 Question 的 real-time contradiction。
