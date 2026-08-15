---
uid: mit-6824-s21-resource-reading-7
type: course
document_type: resource
resource_kind: reading
resource_order: 107
course: mit-6824-s21
title: Lecture 7 阅读与作业指南：Raft（2）
description: Lecture 7 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 7 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-07/"
toc: true
official_lecture_number: 7
math: true
---

## 1. 来源、精确范围与证据边界

- 指定论文：**In Search of an Understandable Consensus Algorithm (Extended Version)**（Diego Ongaro and John Ousterhout, 2014）。
- **精确指定范围：跳过 Section 6 `Cluster membership changes`；从 Section 7 `Log compaction` 开始，一直读到论文结尾。**
- 技术主线是 Sections 7-11：log compaction/snapshot、client interaction、implementation and evaluation、related work、conclusion。Section 12 acknowledgments 与 references 属于论文 end matter，可浏览来源，但不承担核心机制。
- **不要阅读或总结 Section 6 作为本讲内容。** `raft2-faq.txt` 混合了 Section 6 questions；本指南明确排除那些 membership-change 问答。
- Sections 7-8 依赖 Section 5 的 safety properties。需要回看 Figure 2/3 或 Lecture 5 时，只把它们当先修，不把 Section 6 插入中间。
- `reading-inputs` 是 archived evidence bundle；`MATERIALS.md` 是课程索引；Lecture 7 `NOTES.md` 用于连接课堂实际讨论，不覆盖 paper claims。

资源：

- [Raft extended paper 归档](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)
- [Lecture 7 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-07.md)
- [Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)
- [官方 Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-7-fault-tolerance---raft-2)
- [Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/)
- [Lecture 7 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=7)

## 2. 阅读路线

### 2.1 先建立边界

打开 paper 后直接定位 **Section 7**。不要从 Section 6 开始顺读，也不要用 FAQ 的 `C_old`、`C_new`、joint consensus 问答补充本讲。

### 2.2 建议顺序

1. **Section 7 + Figures 12-13：** 把 snapshot 看成“已 apply prefix 的 state representation”，追踪 `lastIncludedIndex/Term`、local compaction 与 `InstallSnapshot`。
2. **Section 8：** 沿 client leader discovery、retry、serial number、read-only optimization 追踪 linearizable semantics。
3. **Section 9：** 分开审查 understandability、correctness 与 performance evidence，不把三类证据混为一个“Raft 更好”的结论。
4. **Section 10：** 比较 strong leadership 与 Paxos、Viewstamped Replication（VR）、ZooKeeper、EPaxos 的机制/性能取舍。
5. **Section 11：** 回看 understandability 作为 design goal 如何影响 decomposition 与 state-space reduction。
6. 最后做官方 Question：只依据 snapshot metadata、message ordering、applied/committed frontier 和 Figure 13 receiver steps推理。

## 3. 问题、模型与假设

### 3.1 Section 7 要解决的问题

Raft log 随 client commands 无限增长会耗尽 storage，并使 reboot replay 越来越慢。目标是在不丢失已 committed state、不破坏后续 `AppendEntries` consistency check 的前提下，删除 obsolete log prefix。

### 3.2 Section 8 要解决的问题

Consensus log consistency 还不是完整 client semantics。Clients 需要：

- 找到当前 leader；
- 在 request/reply loss 或 leader crash 后 retry；
- 避免 retry 让 command 执行多次；
- 对 read-only operation 获得 linearizable、非 stale 的结果。

### 3.3 继承的 system assumptions

- Servers 正确执行 protocol 或 crash/recover，不处理 Byzantine behavior。
- Network 可 delay、drop、duplicate、reorder RPC，亦可 partition。
- Stable storage 保存 Raft persistent state 与 snapshots；写入/安装必须具有可恢复的 atomic effect。
- State machine 是 deterministic；commands 按 committed log order apply。
- Majority 可通信是 progress 条件；timing 不应进入 core safety proof，除非明确选择 lease optimization。
- Section 7 默认 consensus 已在 snapshot 覆盖的 entries 上完成；snapshot 不是另一个 consensus decision。

### 3.4 关键 frontiers 不可混用

- `lastIncludedIndex`：snapshot 覆盖的最后 logical log index；
- `commitIndex`：server 已知 committed 的最高 index；
- `lastApplied`：server 已交给 state machine 的最高 index；
- log 起点：compaction 后本地仍保留的最早 logical index；
- `nextIndex[f]` / `matchIndex[f]`：leader 对 follower replication progress 的发送猜测/成功证据。

Snapshot safety 的多数错误都来自把其中两个量当成同一个版本号。

## 4. Section 7：Log compaction 与 snapshot

### 4.1 State-history duality

令 state machine 从初态 $S_0$ 按序执行 `log[1..i]` 后得到 $S_i$：

$$
S_i = apply(S_0, log[1..i]).
$$

若 durable snapshot 保存 $S_i$，恢复资料可从完整 log 变为：

$$
snapshot_i + log[i+1..n].
$$

因此 snapshot 完成后可删除 through $i$ 的 obsolete log prefix。删除的是 history representation，不是删除 operations 的 effect；effect 已在 snapshot state 中。

### 4.2 Snapshot metadata

每个 snapshot 至少保留：

- `lastIncludedIndex`：被 snapshot 替代的最后 log index，也是 state machine 已 apply 的 frontier；
- `lastIncludedTerm`：该 index entry 的 term。

后续第一条 log entry 的 `AppendEntries` 仍需要 previous index/term，因此 compaction 不能丢掉这对 logical boundary metadata。Logical index 继续递增；底层 array/slice 截短不意味着 index 从 0 重启。

Paper 还说 snapshot 保存截至该 index 的最新 cluster configuration；这只是 snapshot format 的一项内容。**其配置变化算法在 Section 6，本讲不展开。**

### 4.3 谁创建 snapshot

各 server 通常独立 snapshot 自己已 apply 的 committed prefix。Follower 无需 leader 同意即可重新组织本地已达成 consensus 的数据：

- 这在形式上弱化了 strict strong-leader principle；
- 但 snapshot 不作新的 consensus decision，只重写已决定 history 的表示；
- data replication 方向仍是 leader 到 follower，follower 只是本地 compact。

Paper 比较了 only-leader snapshot 方案：leader 给每个 follower 传完整 state 会浪费 bandwidth，并使 leader 同时承担 snapshot transfer 与新 log replication，增加复杂性和阻塞风险。

### 4.4 Snapshot 频率与 copy-on-write

- 太频繁：浪费 disk bandwidth/energy；
- 太少：log 可能占满 storage，reboot replay 时间变长；
- 简单策略：log byte size 达到固定 threshold 后 snapshot，threshold 应显著大于 expected snapshot size，以摊薄写放大。

写大型 snapshot 可长时间占用 I/O。Paper 建议 copy-on-write：functional data structures 天然保留旧版本，或利用 Linux `fork` 让 child 看见 fork 时刻 state、parent 继续更新；被写页面才复制。COW 减少 stop-the-world pause，不消除 snapshot write 和 dirty-page copy 成本。

### 4.5 InstallSnapshot RPC

当 follower 需要的 next entry 已被 leader compact，`AppendEntries` 没有足够 prefix 可发送，leader 改用 `InstallSnapshot`。Figure 13 的重要 fields：

- `term`、`leaderId`；
- `lastIncludedIndex`、`lastIncludedTerm`；
- `offset`、`data[]`、`done`，支持按 chunk 传输完整 snapshot。

Chunking 避免单个巨大 RPC，并让 follower 每收到 chunk 都能观察 leader progress。完整安装必须 atomic：partial snapshot 不能在 crash 后冒充可用 state；重复发送完整 snapshot 应 harmless。

### 4.6 收到 snapshot 后的两类 log 关系

1. **Snapshot 包含 recipient 没有的新 history：** 现有 log 可能含冲突的 uncommitted entries；paper receiver steps 允许由 snapshot 取代相关 history。
2. **Snapshot 描述 recipient log 的 prefix：** 若 snapshot boundary 与现有 entry 的 index/term 匹配，删除被 snapshot 覆盖的 prefix，但保留其后的有效 suffix。

核心区分是 snapshot 覆盖什么与 local log 还包含什么，不是“收到 snapshot 就总清空 log”。

## 5. Snapshot safety、failure 与 liveness

### 5.1 Safety invariants

- Snapshot 只应代表已 committed、已 apply 的 prefix。
- State machine 不能撤销已执行、可能已回复 client 的 operation。
- Compaction 后 logical index/term identity 必须保留。
- Snapshot boundary 后仍有效的 suffix 不应因 prefix replacement 无条件丢失。
- Snapshot 与 Raft metadata 的 durable update 必须在 crash/restart 后保持一致。

### 5.2 Message reordering

Network/RPC runtime 可让较早发送的 snapshot 比较晚发送的 snapshot 更晚到达。到达顺序不是版本顺序；receiver 必须用 snapshot metadata、自己的 committed/applied/snapshot frontier 判断 relation。官方 Question 正是要求你检查 Figure 13 step 8 在这种状态下是否可能带来 rollback。

### 5.3 Failure scenarios

- **Leader compact 太早、follower 长期离线：** leader 无旧 entries 可发，转为 snapshot state transfer；正确但 bandwidth 可能很高。
- **Snapshot transfer 中 crash：** partial file 必须与 last complete snapshot 区分，重试不能产生半安装 state。
- **Follower 有 extra uncommitted suffix：** snapshot 可替代冲突 prefix/history，后续由 leader log 继续收敛；未 committed tail 可删除。
- **Follower 已有更先进 state：** 必须先比较 version/frontier，再决定 RPC 是否改变 state；不能仅因 sender 是 leader 就跳过 local monotonicity check。
- **Snapshot writer 太慢：** 若阻塞 normal operation，可能引发 missed heartbeat/election 或 client pause；COW/background write 改善 liveness/performance，不改变 snapshot 内容的 safety contract。

### 5.4 Liveness 边界

Snapshot 让严重落后的 follower 不需重放完整 history，改善 reintegration；但 full-state transfer 仍可能昂贵。Leader 通常应保留足够 log tail 处理常见短暂落后，把 InstallSnapshot 留给极慢或新 follower。没有 majority 时，snapshot 也不能让 cluster 独立处理新 commands；它是 recovery/compaction mechanism，不替代 consensus quorum。

## 6. Section 8：Client interaction

### 6.1 Leader discovery 与 retry

- Client 初次随机连接一个 server；non-leader 拒绝 request，并可提供最近听到的 leader 信息。
- Leader crash 时 client request timeout；client 再尝试随机 server。
- Timeout 不能判断 operation 未执行，因此每次 retry 都要保持 logical request identity。

### 6.2 Exactly-once illusion 与 duplicate detection

若 leader 已 commit command，却在回复 client 前 crash，client 会向 new leader retry；同一 logical command 可能再次进入 log。Paper 的方案：

- client 给每个 command 唯一 serial number；
- state machine 为每个 client 记录最新 processed serial number 与 associated response；
- duplicate 到达时不重新执行，直接返回缓存 response。

这是 replicated service 的 state，不只是 client-side convenience。Request ID 若不随 snapshot 持久保存，reboot/compaction 后可能忘记已执行 request。

### 6.3 Linearizable semantics

Paper 的目标是每个 operation 看起来在 invocation 与 response 之间某一瞬间、恰好一次地执行。Lecture 7 课堂把它展开为：存在 total order；该顺序尊重 non-overlapping operations 的 real-time order；read 返回该顺序中最近 write 的值。

### 6.4 Read-only optimization

Read 不修改 state，理论上可不写 log，但 old leader 可能不知道自己已被替换并返回 stale data。Paper 要求两项保护：

1. New leader 在 term 开始时 commit 一条 blank no-op，确认自己掌握此前哪些 entries 已 committed；
2. 回复 read-only request 前，与 majority 交换 heartbeat，确认自己尚未被 deposed。

Alternative 是 heartbeat-based lease，可少通信，但把 bounded clock skew/timing 引入 safety assumption。Core Raft 避免 timing-dependent safety；选择 lease 是显式的 assumption/performance tradeoff。

## 7. Section 9：Implementation 与 evaluation

### 7.1 Implementation evidence

- 作者在 RAMCloud coordinator failover/configuration service 中实现 Raft；
- 代码约 `2000` 行 C++，不含 tests/comments/blank lines；
- 论文当时提到约 `25` 个独立 third-party open-source implementations，并有公司部署。

这些数字说明 implementability/interest，不单独证明 correctness、understandability 或生产性能。

### 7.2 Understandability study

Study 对象是 Stanford 与 U.C. Berkeley 的 advanced students，共 `43` 名。每人观看 Raft/Paxos videos 并完成配套 quizzes；约一半先学 Paxos，一半先学 Raft，以减轻顺序影响。

主要结果：

- `33/43` participants 的 Raft quiz 分数高于 Paxos；
- 满分 60，平均 Raft `25.7`，Paxos `20.8`，observed mean difference `4.9`；
- paired t-test 在 95% confidence 下给出 true mean difference 至少 `2.5` points；
- regression model 预测 quiz choice favor Raft `12.5` points，但也出现作者无法解释的 order effect；
- self-report 中 `33/41` 分别认为 Raft 更易 implement、也有 `33/41` 认为更易 explain。

Bias/limitations：15 人已有 Paxos experience；Paxos video 长 `14%`；self-report 可能受作者 hypothesis 影响；quizzes/material matching 与 grading rubric 虽被控制，仍不是对所有 engineers/tasks 的普遍证明。

### 7.3 Correctness evidence

- Figure 2 被写成约 `400` 行 TLA+ specification；
- 使用 TLA proof system mechanically proved **Log Completeness Property**；
- mechanical proof 依赖尚未全部 mechanically checked 的 invariants，例如 specification type safety；
- 另有约 `3500` words 的 complete informal State Machine Safety proof。

因此不能简写成“Raft 已被完全形式化证明”。应准确说明 proof target、mechanization 范围与 unchecked assumptions。

### 7.4 Performance evidence

Established leader 复制新 entry 的 common case 使用最少消息结构：leader 到 half cluster 的单 round trip。Paper 还说 batching/pipelining 可进一步提高 throughput/latency，但未在本文完整实现评估这些优化。

Figure 16 的 5-server election experiment（broadcast time 约 `15 ms`）：

- 无 randomness 时，split votes 使 election consistently 超过 `10 s`；
- 只加 `5 ms` randomness，median downtime `287 ms`；
- `50 ms` randomness 时，1000 trials 中 worst case `513 ms`；
- election timeout `12-24 ms` 时，average `35 ms`，longest `152 ms`，但继续降低会违反 timing requirement并增加 unnecessary elections；
- 作者推荐 conservative `150-300 ms`。

这些结果是特定 implementation、cluster 与 broadcast time 下的 election evaluation，不是所有部署的固定 timeout。Lecture 7 Lab 课堂示例使用不同 test constraints，不能直接照搬论文数值。

## 8. Section 10-11：Related work 与 design conclusion

### 8.1 Strong leadership 的差异

- Paxos 的 basic consensus 不要求 leader，leader election 更像 performance optimization；
- Raft 把 election 直接纳入 consensus structure，并尽量把 functionality 集中到 leader；
- VR 与 ZooKeeper 也 leader-based，但论文描述中 log 可在 election 时向 leader 流动；Raft log entries 只从 leader 向 followers 流动，减少 non-leader mechanism。

论文统计 basic consensus + membership changes（排除 compaction/client interaction）时，VR/ZooKeeper 各约 10 message types，Raft 为 4（两种 request 及 responses）。该比较说明 message taxonomy 较少，不等于每条 message 更小或实现自然无 bug。

### 8.2 Strong leader 的性能代价

EPaxos 在 concurrent commands commute 时可由任意 server 一轮提交，能在 WAN 中平衡 load、降低 latency；不 commute 时需额外 communication round。它获得性能与 leaderless flexibility，但显著增加 complexity。Raft 选择 central leader/clear order，优先 understandability。

### 8.3 Conclusion 的方法论

作者认为 correctness、efficiency、conciseness 之外，understandability 也是基础目标，因为 real implementation 必然扩展和偏离 paper form。Raft 反复使用：

- **problem decomposition**：election、replication、safety、compaction、client interaction 分开说明；
- **state-space reduction**：strong leader、单向 flow、限制 inconsistency forms；
- **conservative rule**：放弃某些更复杂但潜在更快的选择，换取可解释 reasoning。

Section 11 的结论是 design philosophy 与 study/evidence 的综合主张，不应被理解为“简洁自动保证 correctness”。

## 9. Safety、liveness、failure 与机制总表

| 场景 | Safety mechanism | Liveness/performance consequence |
| --- | --- | --- |
| Log 无限增长 | Snapshot 只覆盖 committed/applied prefix，并保留 boundary metadata | Snapshot I/O 与频率需权衡；replay 变短 |
| Follower 落后超过 retained log | `InstallSnapshot` 建新 state baseline，再续传 log tail | Full snapshot 占 bandwidth，但避免完整 history replay |
| Snapshot 与 local log prefix matching | 删除 covered prefix，保留 boundary 后 suffix | 减少重传，receiver logic 更复杂 |
| Snapshot RPC reordered/retried | 以 metadata/frontier 判断版本；installation atomic/idempotent | Stale work 可能被丢弃，不应阻塞 newer progress |
| Leader commit 后 reply 前 crash | Stable client serial + cached response 防 duplicate execution | Client 必须 timeout/retry，service 保存额外 metadata |
| Old leader 处理 read | Majority heartbeat/no-op knowledge 防 stale read | 每次 read 增通信；lease 可更快但依赖 clocks |
| Election timeout randomization | Election Safety 仍由 votes/quorum；randomness 只打破 symmetry | 范围太小 split vote，太大 failover pause |
| Strong leader | 单一 log direction 与 ordered decisions | Leader bottleneck、WAN latency，限制 leaderless optimizations |

## 10. 设计权衡与限制

### 10.1 Snapshot vs incremental compaction

Full snapshot mechanism 简单，但 large database 写入/传输昂贵。Log cleaning、LSM tree 或增量 state transfer 可分摊工作、只传变化，却需要更多 metadata、versioning 与 recovery logic。

### 10.2 Independent snapshots vs leader-generated snapshots

Independent follower snapshot 节省 network，降低 leader complexity，但 service/Raft boundary 必须在每台 server 正确协调。Leader-generated snapshot 统一来源，却浪费把本地已可重建的 state 反复传输给 followers。

### 10.3 No-op/heartbeat reads vs log every read

Read 不入 log 可节省 log space、serialization 与 apply latency；代价是必须单独证明 leader freshness。Majority heartbeat 维持 non-timing safety，lease 更快但需 bounded clock assumptions。

### 10.4 Understandability vs optimization

FAQ 与 Section 10 共同提醒：Raft 的 full snapshot、顺序 execution、有限 pipelining、strong leader 都可能弱于高度优化系统。它们是 clarity-first design choices，不是性能上限。

### 10.5 Scope limitations

- 不处理 Byzantine/malicious replicas；
- Replicated application 要 deterministic/self-contained，external side effects 需额外 duplicate/idempotence protocol；
- Full-state snapshot 对大 state 不理想；
- Study subjects、quiz design 与 lab experience 不能直接泛化到所有工程团队；
- Section 6 reconfiguration 完全不在本讲指定范围。

## 11. 官方 Paper Question / Homework

**Assigned Question（原文）**：

> Could a received InstallSnapshot RPC cause the state machine to go backwards in time? That is, could step 8 in Figure 13 cause the state machine to be reset so that it reflects fewer executed operations? If yes, explain how this could happen. If no, explain why it can't happen.

### 推理脚手架（不是可直接提交的答案）

不要从 “snapshot 应该是新的” 开始假设。构造一张 event/version 表：

| 时刻 | Sender/receiver event | RPC snapshot `(lastIncludedIndex,lastIncludedTerm)` | Receiver `commitIndex` | Receiver `lastApplied` | Receiver current snapshot | Existing log relation |
| --- | --- | --- | --- | --- | --- | --- |
| $t_0$ | 初始状态 | - | ? | ? | ? | ? |
| $t_1$ | 第一次 send/delay | (?, ?) | ? | ? | ? | ? |
| $t_2$ | receiver 继续进展 | - | ? | ? | ? | ? |
| $t_3$ | delayed RPC 到达 | (?, ?) | ? | ? | ? | prefix/conflict/ahead? |

按以下步骤组织答案：

1. 明确 “go backwards” 的观察量：是 log slice 变短、uncommitted tail 被删，还是 **state machine 反映的 executed operations 变少**？三者不能混用。
2. 从 Figure 13 找出 step 8 的前置 checks；逐项说明它们比较了 term、offset、snapshot index/term 或 existing log 的什么关系。
3. 允许 RPC delay、retry、reorder，构造 receiver 在旧 RPC 到达前继续 commit/apply 或安装另一个 snapshot 的 chronology。
4. 比较 incoming `lastIncludedIndex` 与 receiver 的 `lastApplied`、`commitIndex`、existing snapshot frontier。哪一种关系才可能改变 state machine？
5. 若 snapshot boundary 与 local log 同 index/term 匹配，说明为什么 suffix 被保留；若不匹配，说明丢弃 log 与 reset state 各自影响 committed 还是 uncommitted information。
6. 把 external client evidence 加入：receiver 已 apply 的 operations 是否可能已产生 reply？若撤销，会违反什么 service guarantee？
7. 检查 paper Figure 13 本身、FAQ 对 reordered stale snapshot 的说明，以及 course service/Raft API 是否承担额外 guard；不要把 lab-specific API 当作 paper 明写的 receiver step。
8. 最后才写 yes/no，并限定 assumptions：paper RPC ordering、课程 RPC model、receiver 已有哪些 frontier。没有 chronology 与 step-by-step check 的单句答案不够。

本指南故意不填写表格、不选择 yes/no，也不提供一段可直接提交的论证。

## 12. FAQ 要点（仅 Sections 7-to-end）

`raft2-faq.txt` 同时含大量 Section 6 membership questions；**那些内容全部跳过。** 与本讲指定范围相关的要点如下：

- **Read 是否每次 commit no-op？** 不是。No-op 只在 leader term 开始时用于确认 committed frontier；read-only request 可用 majority heartbeat 或 lease 检查 leadership。
- **为什么新 leader 需要 current-term no-op？** Figure 8 状态下，它一开始可能不知道 previous-term tail 是否 committed；commit 本 term entry 后才知道此前 prefix 的地位。
- **Lease 为什么改变 safety assumptions？** 它要求 servers 对时间区间有足够一致的认识，例如 bounded clock skew；否则 old leader 可能误以为 lease 尚有效。
- **Snapshot 保存谁的数据？** Replicated service 的 state，例如 key/value table；Raft 额外保存 boundary metadata。
- **删除 snapshot 覆盖的 log prefix 会丢 operation 吗？** Snapshot 已包含 prefix operations 的 effects；应检查 suffix 是否仍需保留。
- **Snapshot 与 log 一样大还有价值吗？** 空间收益可能小，但 organized table 仍可让 restart/query 比 replay/sort log 更快；典型 workload 的 log 往往大于 current state。
- **InstallSnapshot bandwidth 是否昂贵？** 是。可保留更多 recent log，或采用 differential/incremental state transfer；paper 的 simple full snapshot 是 clarity tradeoff。
- **Snapshot 写入时间超过 election timeout 怎么办？** Large state 可 background/COW 写，并降低 snapshot frequency；阻塞 heartbeat 是 liveness 风险。
- **何时收到“自己 log 的 prefix”snapshot？** RPC 可 reordered，或旧 snapshot 延迟；到达时间不表示版本最新。
- **Stale snapshot 如何处理？** FAQ 针对 course RPC model 指出 receiver 需要 reject/ignore 已落后于 local frontier 的 snapshot，并承认 Figure 13 未明确列出该 test；这正是 Question 要你分析的 evidence tension。
- **什么时候 leader 发 snapshot？** Follower progress 早于 leader retained log start，无法用 AppendEntries 回退时。
- **InstallSnapshot 是否必须 atomic/idempotent？** Installation 必须 atomic；重发同一 snapshot 应 harmless。
- **`offset` 为什么存在？** 完整 snapshot 可分多个 chunks，offset 指定该 chunk 在文件中的位置。
- **COW 帮助什么？** Child 保留 fork 时刻 memory view，parent 继续处理 updates；仅被写 pages 才复制。
- **Raft understandability study 是否能由课程经验复现？** FAQ 说课程没有 side-by-side experiment，且 Raft labs 比旧 Paxos labs 更 ambitious，不能用主观教学感受复验 Section 9.1。
- **Raft 的 research impact？** FAQ 强调 paper 对 modern replicated state machine techniques 的解释质量，激发了许多 implementations；这与“协议机制全新”是不同评价。

## 13. 课堂连接

[Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/) 的课堂顺序比指定阅读更宽：先续讲 Section 5 的 divergent log、current-term commit、fast backtracking 与 persistence，再进入 Section 7 snapshot、Section 8 client semantics 和 linearizability。应这样使用：

1. **把 Section 5 内容当先修桥梁。** `nextIndex/matchIndex`、Figure 8 与 durable-before-ack 解释为何 snapshot 只能建立在 safe applied prefix 上；它们不是把 Section 6 补回本讲。
2. **用 service/Raft boundary 理解 snapshot。** Service 知道 state 覆盖到哪个 index，Raft 知道哪些 log entries 可 compact；snapshot 通过 apply path 安装，不能由 Raft 随意改 application state。
3. **用 homework breakout 区分 log rollback 与 state rollback。** Uncommitted conflicting tail 可删；已 committed/applied state 不能撤销。Question 问后者。
4. **用 linearizability histories连接 client semantics。** Total order、real-time order 与 read-from value 共同约束 output，不仅是 logs 最终一致。
5. **用课堂不确定项保持证据诚实。** Figure 13 stale check、Lab API、板书 off-by-one 与某些 timer 数字需回到 paper/handout 核对，不能据即时口述生成唯一 implementation。

课堂也明确提醒 `Start()` return 只回到 service，不等于 operation committed 或可回复 client；这与 Section 8 的端到端路径直接相连。

## 14. 理解题（10 题）

1. **Snapshot 为什么允许删除 log prefix？**  
   **答：** Durable snapshot 已保存按序 apply through `lastIncludedIndex` 后的 state；prefix effects 未丢，只是 history representation 被 state representation 取代。
2. **`lastIncludedIndex/Term` 为什么必须保留？**  
   **答：** 它们定位 snapshot 在 logical log 中的位置，并让 snapshot 后第一条 entry 仍可执行 `prevLogIndex/prevLogTerm` consistency check。
3. **什么时候 leader 必须使用 InstallSnapshot 而不是 AppendEntries？**  
   **答：** Follower 需要的 next index 早于 leader retained log start，leader 已没有对应 entries 可回退发送时。
4. **收到 snapshot 后为什么有时保留 log suffix？**  
   **答：** 若 snapshot boundary 与现有 log 同 index/term 匹配，snapshot 只替代已覆盖 prefix，boundary 后 entries 仍可能有效。
5. **Snapshot frequency 的两个方向风险是什么？**  
   **答：** 太频繁浪费 I/O；太少增加 storage usage 与 reboot replay time。Byte-size threshold 是简单折中。
6. **Client serial number 解决哪种 failure window？**  
   **答：** Leader 已 commit/execute 但 reply 丢失或 crash，client retry 使同一 logical command 再到达；service 以 serial 和 cached response 去重。
7. **Read-only operation 不入 log时为何仍需 majority contact？**  
   **答：** Old leader 可能已被替换却不知情；majority heartbeat 检查当前 authority，避免返回 stale state。
8. **Section 9.1 的主要 empirical result 与限制是什么？**  
   **答：** 43 人中 33 人 Raft quiz 更高，mean difference 4.9/60；prior Paxos exposure、video length、order effect 与 self-report bias 限制泛化。
9. **Section 9.2 为什么不能概括成“全部 correctness 已机械证明”？**  
   **答：** Mechanical proof 针对 Log Completeness，依赖未全机械检查的 invariants；State Machine Safety 还有独立 informal proof。
10. **Strong leader 相对 EPaxos 的核心 tradeoff 是什么？**  
    **答：** Raft 用集中 order 与单向 log flow换取较小 state space；EPaxos 可利用 commutativity/WAN locality 获得性能，但协议更复杂。

## 15. 复习清单

- [ ] 能精确说出“跳过 Section 6，从 Section 7 读到论文结尾”。
- [ ] 能解释 snapshot state 与 applied log prefix 的等价关系。
- [ ] 能列出 snapshot boundary metadata 与 logical-index offset 的目的。
- [ ] 能区分 local snapshot、leader InstallSnapshot 与 log tail replay。
- [ ] 能对 snapshot frequency、full vs incremental、independent vs leader-generated 作权衡。
- [ ] 能解释 duplicate execution window、serial number 与 cached response。
- [ ] 能解释 read-only no-op、majority heartbeat 与 lease 的不同 assumptions。
- [ ] 能准确复述 Section 9 三类 evaluation evidence及其限制。
- [ ] 能比较 Raft strong leadership 与 Paxos/VR/ZooKeeper/EPaxos。
- [ ] 能为官方 Question 建 version/event table，但不把 log truncation误称为 state-machine rollback。
- [ ] 能从 FAQ 中排除所有 Section 6 membership-change 内容。
- [ ] 能说明 Lecture 7 课堂回顾 Section 5 是先修连接，不改变 paper 的 assigned range。
