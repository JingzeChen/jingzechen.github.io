---
uid: mit-6824-s21-resource-reading-5
type: course
document_type: resource
resource_kind: reading
resource_order: 105
course: mit-6824-s21
title: Lecture 5 阅读与作业指南：Raft（1）
description: Lecture 5 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 5 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-05/"
toc: true
official_lecture_number: 5
math: true
---

## 1. 来源、指定范围与证据边界

- 指定论文：**In Search of an Understandable Consensus Algorithm (Extended Version)**（Diego Ongaro and John Ousterhout, 2014）。
- **精确指定范围：从论文开头读到 Section 5 末尾，包括 Sections 1-5 与 Sections 5.1-5.6；到 Section 6 `Cluster membership changes` 标题前停止。**
- 本讲要掌握 replicated state machine、leader election、log replication、safety、crash handling 与 timing/availability。
- Section 6 membership changes、Section 7 snapshots、Section 8 client interaction、Section 9 evaluation 等均不属于本讲指定阅读。后续章节即使在 FAQ 中出现，也不能冒充本讲 paper evidence。
- `reading-inputs` 是归档证据包；`MATERIALS.md` 是课程索引；课堂 `NOTES.md` 只用于连接老师实际讲法，不覆盖论文原意。

资源：

- [Raft extended paper 归档](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)
- [Lecture 5 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-05.md)
- [Raft FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt)
- [官方 Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/05-q-raft.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-5-fault-tolerance---raft-1)
- [Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)
- [Lecture 5 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=5)

## 2. 阅读路线与核心问题

建议按下列顺序读，不要一开始就把 Figure 2 当成待背诵代码：

1. **Sections 1-2：** Raft 要解决什么 replicated state machine 问题？正确性、可用性和性能目标分别是什么？
2. **Sections 3-4：** 作者为何认为 Paxos 不适合作为教学和完整系统实现的起点？`decomposition` 与 `state-space reduction` 如何影响 Raft 的结构？
3. **Section 5 开头与 Figures 2-3：** 先列出 state、RPC 和五条 safety properties，再带着这些名字阅读各 subsection。
4. **Sections 5.1-5.3：** 沿 `term -> election -> AppendEntries -> commit -> apply` 追踪一条 command。
5. **Section 5.4：** 用 Figure 8 反例理解 election restriction 与 current-term commit rule；这是本讲最关键的 safety 推理。
6. **Sections 5.5-5.6：** 分开看 crash/retry 的 safety 与 timing 对 availability 的影响。
7. 最后回到 Figure 7 和官方 Question，只写机制驱动的逐候选分析，不凭“日志看起来最长”猜答案。

阅读时持续追问：

- 为什么两个副本不能仅靠 timeout 在 crash 与 partition 之间作安全判断？
- majority intersection 传递的究竟是什么信息？
- follower 保存 entry、leader 知道 entry committed、follower apply entry 为什么是三个不同事件？
- 为什么 candidate 的 log freshness 先比 last term，再比 last index？
- 为什么 previous-term entry 已在 majority 上仍可能不能直接 commit？
- 哪些状态必须 stable，哪些状态可在重启后重新构造？
- 为什么 timing 不参与 safety proof，却决定系统能否 progress？

## 3. 系统模型、目标与假设

### 3.1 Replicated state machine 模型

每个 server 保存一份 ordered log，并让 deterministic state machine 按 index 顺序执行 commands。若所有 replicas 从相同初态出发、按相同顺序执行相同 commands，则它们产生相同 state 与 outputs。Consensus module 的职责是让 logs 最终包含相同 commands、相同 order，而不是解释 command 的业务语义。

```text
client command
  -> leader appends log entry
  -> leader replicates entry
  -> entry becomes committed
  -> each server applies it in index order
  -> state machines converge
```

### 3.2 Failure 与 network assumptions

- Servers 属于 **non-Byzantine / fail-stop** 模型：正确执行 protocol，或 crash/停止；它们可从 stable storage 恢复后重新加入。
- Network 可 delay、drop、duplicate、reorder messages，也可 partition。
- RPC request 或 reply 都可能丢失，因此 protocol 会 retry；接收端行为必须能安全处理 duplicate RPC。
- Raft 不防御 malicious server、伪造消息或任意错误执行；认证、防火墙或 Byzantine protocol 属于模型外。
- 固定 cluster configuration 是 Section 5 的假设；membership changes 在 Section 6，明确不属于本讲。

### 3.3 正确性与可用性目标

- **Safety：** 在所有 non-Byzantine network/failure 情况下，不返回 incorrect result；不能因时钟错误或消息极慢而破坏 log consistency。
- **Availability/liveness：** 只要全体 servers 的 majority 存活、彼此及 clients 可通信，系统应能选出稳定 leader 并继续处理 commands。
- **Fault tolerance：** 常见的 5-server cluster 可容忍 2 台不可达；一般 `2f+1` 台可在最多 `f` 台不可达时保留 majority。
- **Common-case performance：** established leader 让 command 在一次到 majority 的 RPC round trip 后即可完成关键复制；minority slow servers 不应卡住整体。

### 3.4 Timing 假设的边界

Safety 不依赖时间。极端 delay 最多使 server 误触发 election、提高 term 或暂时停止服务，不应使两个不同 commands 在同一 applied index 对外生效。Progress 则需要：

$$
broadcastTime \ll electionTimeout \ll MTBF.
$$

- `broadcastTime`：并行向全体发送 RPC 并收到 replies 的平均时间；
- `electionTimeout`：失去 leader traffic 后发起 election 的等待时间；
- `MTBF`：单台 server 的平均故障间隔。

第一个不等式让 leader 来得及发 heartbeat，也降低 split vote；第二个不等式让 election downtime 只占运行时间很小一部分。

## 4. Raft 状态、角色与 RPC

### 4.1 三种角色

- **follower：** 被动响应 leader/candidate；收到有效 leader traffic 时维持 follower。
- **candidate：** election timeout 后提高 term、投自己一票并请求 votes。
- **leader：** 接受 client commands，决定 log placement，向 followers 复制，并传播 `leaderCommit`。

正常情况下每个 term 最多一个 leader。一个 term 也可能因 split vote 没有 leader。

### 4.2 Term 是 logical clock

- `currentTerm` 单调增加，并在每次 RPC 中交换。
- 收到更高 term 的 request/reply 时，server 更新 term 并转为 follower。
- 收到较低 term 的 request 时拒绝。
- Server 可经历多次没有新 log entry 的 election，因此 `currentTerm` 可能大于 `lastLogTerm`；两者不能混用。

### 4.3 Persistent 与 volatile state

**所有 servers 的 persistent state（回复相关 RPC 前先稳定保存）：**

- `currentTerm`：见过的最高 term；
- `votedFor`：本 term 投给的 candidate，或 null；
- `log[]`：每条 entry 的 command 与创建它的 term。

**所有 servers 的 volatile state：**

- `commitIndex`：已知 committed 的最高 index；
- `lastApplied`：已交给 state machine 的最高 index。

**leader 的 volatile state：**

- `nextIndex[]`：下一次准备给各 follower 发送的 index，是可回退的猜测；
- `matchIndex[]`：已由成功 reply 确认 follower 保存的最高 index，是复制证据。

Role 不必持久化；reboot 后先以 follower 身份恢复。`currentTerm`、`votedFor` 与 `log[]` 则不能忘记，否则同 term 重复投票或已确认 entry 消失会破坏 safety。

### 4.4 两种基本 RPC

**RequestVote RPC**：

- 由 candidate 发起；带 `term`、`candidateId`、`lastLogIndex`、`lastLogTerm`。
- Receiver 先拒绝 stale term；在本 term 尚未投给别人（或已投给同一 candidate）且 candidate log 至少同样 up-to-date 时才 grant。

**AppendEntries RPC**：

- 由 leader 发起；既复制 entries，也以 empty `entries[]` 充当 heartbeat。
- 带 `prevLogIndex`、`prevLogTerm` 建立 prefix consistency check；带 `leaderCommit` 传播 commit knowledge。
- Follower 只在前驱 index/term 匹配时接受；同 index 不同 term 的 conflict entry 及其后缀会被删除，再追加 leader 的新 entries。

Figure 2 是 protocol summary，不是完整并发程序。每条明确规则都必须成立，但 reply ordering、stale response、locking 等实现控制流仍需独立推理。

## 5. Leader election 与 liveness

### 5.1 Election 过程

1. Follower 在 election timeout 内未收到有效 AppendEntries，也未给 candidate 投票，转为 candidate。
2. Candidate 提高 `currentTerm`、vote for itself、重置 timer，并行发送 RequestVote。
3. 同一 term 获得全体 servers 的 majority 后，立即成为 leader，无需等待其余可能永不返回的 peers。
4. 收到当前或更高 term leader 的 AppendEntries 时，candidate 转为 follower。
5. 无人获 majority 时，随机 timeout 后进入更高 term 重试。

### 5.2 Election Safety

同一 term 内：

- 每台 server 最多投给一个 candidate；
- 每个 leader 必须获得 majority；
- 任意两个 majorities 必相交。

因此两个 candidates 不可能同时各获一个合法 majority。Split vote 的后果是没有 leader，而不是两个 leaders。

### 5.3 Randomized timeout 解决什么、不解决什么

Randomization 降低多个 followers 同时 timeout、反复瓜分 votes 的概率。它改善 liveness，不是 safety 依据：即使 timeout 一再碰撞，one-vote-per-term 与 majority 仍阻止双 leader；系统只是暂时无进展。

Timeout 太短会频繁误选举；太长会延长 leader failure 后的 pause。论文在 Section 5.6 给出 timing inequality，但本讲指定范围内没有 Section 9 的 election experiment，不能用后文实验数字替代本节模型。

## 6. Log replication、commit 与 repair

### 6.1 一条 command 的路径

```text
client -> leader
  -> leader appends (index, term, command)
  -> parallel AppendEntries
  -> followers persist and ACK local append
  -> leader sees sufficient matchIndex evidence
  -> leader advances commitIndex under the commit rule
  -> leader applies in order and replies
  -> later AppendEntries carries leaderCommit
  -> followers advance commitIndex and apply in order
```

不要把以下三件事混为一谈：

1. follower 已保存 entry；
2. leader 已知道 entry committed；
3. follower 已知道 entry committed 并 apply。

### 6.2 Log Matching Property

Raft 维持两层性质：

- 若两个 logs 有相同 `(index, term)` 的 entry，则该 entry 的 command 相同；
- 若两个 logs 在某 `(index, term)` 匹配，则它们 through 该 index 的 prefix 相同。

`prevLogIndex/prevLogTerm` 是归纳步骤。空 log 满足共同前缀；每次 AppendEntries 只在前驱匹配时延伸，于是成功 reply 证明新 prefix 与 leader 一致。

### 6.3 Divergent logs 与 leader-driven repair

Leader crash 可留下 follower 缺 entry、多 uncommitted entries，或两者兼有。新 leader 不把 follower tail 合并进自己，而是让 followers 最终复制 leader log：

1. 为 follower 设置乐观 `nextIndex`；
2. 前驱检查失败则向前回退并重试；
3. 找到最新共同 prefix 后，follower 删除 conflict suffix；
4. follower 追加 leader suffix，成功后 leader 更新 `matchIndex`。

Leader 自己遵守 **Leader Append-Only**：只 append，不覆盖或删除自身 entries。能否安全地让 follower 丢弃冲突 tail，依赖 election restriction 保证 elected leader 已包含 committed history。

### 6.4 Commit rule 的关键细节

Established leader 对本 term entry 可在它复制到 majority 后直接推进 commit。若目标 index 为 $N$，核心条件是：

$$
N > commitIndex,
$$

$$
\left|\{i \mid matchIndex[i] \ge N\}\right| > \frac{clusterSize}{2},
$$

且

$$
log[N].term = currentTerm.
$$

不能仅凭“previous-term entry 现在有 majority copies”直接 commit。Figure 8 展示该 entry 仍可能在后续合法 election 后被覆盖。Leader 先 commit 一条 current-term entry 后，其 preceding prefix 才因 Log Matching 间接 committed。这是为简化 reasoning 而采用的保守规则。

## 7. Safety：从局部规则到 state machine

Figure 3 的五条性质应按依赖关系理解：

1. **Election Safety：** 每 term 至多一位 leader。
2. **Leader Append-Only：** leader 不覆盖或删除自己的 log entries。
3. **Log Matching：** 相同 index/term 蕴含相同 entry 与相同 prefix。
4. **Leader Completeness：** 某 term committed 的 entry 存在于所有更高 term leaders。
5. **State Machine Safety：** 某 server 在 index $i$ apply 了 command 后，任何 server 都不会在 $i$ apply 不同 command。

### 7.1 Election restriction

Voter 对 candidate log 的 freshness 使用字典序：

$$
(candidate.lastLogTerm,candidate.lastLogIndex)
\ge_{lex}
(voter.lastLogTerm,voter.lastLogIndex).
$$

- Last terms 不同时，更高 last term 更新；
- Last terms 相同时，更长或等长的 log 更新。

这不是“最长 log 赢”，也不是“最高 currentTerm 的 candidate 自动获票”。RPC term 合格与 log freshness 合格是两个独立检查。

### 7.2 Majority intersection 如何支撑 Leader Completeness

若 leader 在 term $T$ 把本 term entry 复制到 majority 并 commit，而未来 term $U$ 的 leader 也必须从 majority 获票，则两个集合至少共享一个 voter。该 voter 保存 committed entry；它只会投给至少同样 up-to-date 的 candidate。配合中间 leaders 不丢 committed prefix 与 Log Matching，可推出未来 leader 必包含该 entry。

Section 5.4.3 给的是 proof sketch，不是完整机械证明。阅读目标是找到 contradiction 中的共同 voter、log freshness 与 prefix matching 各自承担哪一步，不要把“majority 会相交”单独当作完整证明。

### 7.3 State Machine Safety

Server 只按 index 顺序 apply committed entries。Leader Completeness 保证未来 leaders 保留这些 entries，Log Matching 保证相同 index 的 prefix 内容一致，因此后来的 server 在同一 index 不会 apply 另一个 command。

## 8. Failure、recovery 与 availability

### 8.1 Follower/candidate crash

- RPC 会 timeout，sender 持续 retry；
- Server 重启后从 stable `currentTerm`、`votedFor`、`log[]` 恢复；
- 同一 AppendEntries 重发时，已存在的相同 entries 不重复追加，RPC 行为具有 idempotent 效果；
- Minority slow/down servers 不阻止 majority progress。

### 8.2 Leader crash 或 partition

- Minority 中的 old leader 可能暂时仍自认为 leader，但拿不到 majority，不能 commit 新 command；
- 若它接触到见过更高 term 的 server，会从 reply 学到 higher term 并 step down；
- Majority partition 可选 new leader；没有任何 majority 时停止 progress；
- 安全停顿是设计结果，不是 safety failure。

### 8.3 Client retry 的边界

若 request 尚未 committed，leader change 后可丢失；client 未收到 reply 就必须 retry。若 operation 已 apply 但 reply 丢失，retry 又可能让同一 logical command 再进入 log。Raft core 提供 ordered replication，application/service 需要 request identity 与 duplicate response handling；本讲课堂连接到该边界，但完整 client interaction 在 Section 8，不属于指定论文范围。

## 9. Evaluation：本讲范围内能支持什么结论

### 9.1 指定范围内的证据

Sections 1-5 主要给出 design、mechanisms 与 safety argument，并未呈现 Section 9 的完整 empirical evaluation。因此本讲可评价的是：

- **机制成本：** normal case 的新 entry 只需 leader 到 majority 的一轮 RPC；
- **可用性条件：** majority 可通信才 progress，election 期间会暂停；
- **state-space 目标：** strong leader、单向 log flow、固定角色和较少 RPC types 让 reasoning 更集中；
- **correctness evidence：** Figure 8 反例与 Section 5.4.3 proof sketch 支撑规则必要性，但不是完整形式化验证。

Abstract/Introduction 提到 43 人 user study、效率接近 Paxos 与 formal specification，但实验设计、数字与 proof status 位于 Section 9，留到 Lecture 7 的指定范围再评价。不要把 introduction 的 claim 当作本讲已审阅的完整 evidence。

### 9.2 课堂提供的诊断性评价

[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/) 用 test-and-set partition dilemma、`2f+1`、一条 command 的时间线与 Figure 7 把 paper rules 变成可操作检查。课堂还强调 Figure 2 “必须遵守但不是完整程序”，这直接说明 understandability 不等于 implementation triviality。

## 10. 设计权衡与限制

| 选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| Strong leader | log 只从 leader 流向 follower，placement 与 repair 清楚 | leader 是 throughput/latency 汇聚点，election 时暂停 |
| Majority quorum | crash/partition 下保持 single committed history | minority 无法服务；没有 majority 时完全停止 progress |
| Randomized election timeout | 用少量机制打破 split-vote symmetry | liveness 概率化且参数敏感；不提供 safety |
| Up-to-date election restriction | elected leader 自带 committed history，无需 election 时传 log 给 leader | 某些有较长但较旧 tail 的 candidates 会被拒绝 |
| Conservative current-term commit rule | 避免 Figure 8 的 subtle overwrite，proof 更简单 | previous-term entry 可能等待一条 current-term entry 才间接 commit |
| Persistent term/vote/log | crash/reboot 后保住 election 与 committed-history promises | 每次相关更新进入 stable-storage critical path，通常需 batching |
| Sequential state-machine execution | replicas 的 order 与 state 易于推理 | 限制利用 commutativity/multi-core 的空间 |
| Fixed configuration in Section 5 | 核心 consensus 可独立解释 | 生产环境 reconfiguration 需要额外 protocol；本讲不覆盖 Section 6 |

## 11. 官方 Paper Question / Homework

**Assigned Question（原文）**：

> Suppose we have the scenario shown in the Raft paper's Figure 7: a cluster of seven servers, with the log contents shown. The first server crashes (the one at the top of the figure), and cannot be contacted. A leader election ensues. For each of the servers marked (a), (d), and (f), could that server be elected? If yes, which servers would vote for it? If no, what specific Raft mechanism(s) would prevent it from being elected?

### 推理脚手架（不是可直接提交的答案）

为 `a`、`d`、`f` 分别复制一张空表，不要先写 yes/no：

| Candidate | Candidate `(lastTerm,lastIndex)` | Potential voter | Voter `(lastTerm,lastIndex)` | Term check | `votedFor` check | Up-to-date check | Vote? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `?` | 从 Figure 7 读取 | `?` | 从 Figure 7 读取 | 同一 election term？ | 本 term 可投？ | 先 term 后 index | 暂不汇总 |

逐项完成以下步骤：

1. 固定 cluster size 为 7，先写出 majority 门槛；crashed top server 仍在配置分母中，只是不能投票。
2. 对 candidate 读取最后一条 entry 的 `(lastLogTerm,lastLogIndex)`；不要用 `currentTerm` 替代 last entry term。
3. 对每个可联系 voter 做同样记录。先比较 RPC/election term，再比较 log freshness。
4. Freshness 必须先比 last term；只有 last term 相同才比 last index。不要使用“谁的格子更多谁就更新”的规则。
5. `vote denied` 是单个 voter 的结果，不等于 candidate 全局失败；把所有 potential yes votes 加上 candidate self-vote 后再与 majority 比较。
6. 若无法当选，准确指出阻止它的是 stale RPC term、one vote per term、up-to-date election restriction，还是无法取得 majority；不要笼统写“Raft safety”。
7. 若可能当选，列出一组足够的 voters，并逐票说明为什么其 log 不比 candidate 更新；不要只写节点名字。
8. 最后检查 candidate 当选后会保留哪些 committed prefix、可能覆盖哪些 tentative tail，以验证你的 election 结论没有暗示已 committed history 被删除。

课堂 `NOTES.md` 含有老师讨论后的结论片段；正式作业应先独立完成上述表格。这里故意不列最终 yes/no 与 voter sets，避免把指南变成 submission answer。

## 12. FAQ 要点

- **Raft 为 clarity 放弃什么？** FAQ 指出 stable writes、单 follower 同时有效的 AppendEntries 数量、snapshot 全量写入/传输、顺序 state-machine execution 等会限制性能；这些可优化，但会增加机制。
- **为什么课程选 Raft？** 关键贡献是有一篇相对完整、清楚的 paper 描述 practical replicated service；并非 single-decree Paxos 本身比 Raft 更复杂。
- **Minority 能否继续？** 在保持 Raft guarantees 的前提下不能。让 minority 独立修改会引入 split brain；若允许 reconciliation，则 client semantics 转向 eventual consistency。
- **Election pause 是否严重？** FAQ 认为 failures 相对少见，client-visible pause 通常较短；但这是经验判断，不是 Section 5 的严格上界。
- **Network partition 会不会双 leader？** 可能有 stale server 主观自称 leader，但只有 global majority 一侧能 elect/commit；active leader 的定义应以能否得到 majority 为准。
- **Majority 是 live servers 的多数吗？** 不是，永远以全部 configured servers 为分母；否则 partition 两边可各自降低门槛。
- **Timeout 太短会破坏 safety 吗？** 不会，但可让系统不断 election、无法处理 clients，破坏 liveness。
- **Follower 何时 apply？** 只有从 leader 的 `leaderCommit` 得知 committed 后，才按序交给 state machine。
- **Uncommitted request 会不会 lost？** 会；client 没有成功 reply 时必须 retry，service 后续还要处理 duplicate request。
- **Byzantine conditions 是什么？** Malicious/incorrect participants 可发任意错误消息；Raft 不在该模型下保证正确。
- **应用边界是什么？** Replicated application 最适合 self-contained deterministic state；外部 side effects 必须能正确处理 replay/duplicates，否则需要额外 protocol。
- FAQ 文件还讨论 snapshot 等后续主题；本讲只把与 Sections 1-5 直接相关的问答纳入主线。

## 13. 课堂连接

[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/) 对 paper 的重排有四个重要价值：

1. **从 impossibility-shaped dilemma 开始。** 两副本 test-and-set 在 crash/partition 不可区分时无法兼顾 availability 与 single winner，majority 不是凭空出现的常量。
2. **把 quorum intersection 连接两轮事件。** 前一 leader 的 replication majority 与下一 leader 的 election majority 相交，交集 server 携带 history；但仍需 election restriction 才形成完整 safety argument。
3. **区分 knowledge stages。** Follower ACK 只证明本地 append；leader 汇总后知道 commit；followers 再从后续 AppendEntries 学到 commit。这比只看 Figure 2 字段更能解释 crash timing。
4. **用 Figure 7 暴露概念混淆。** `currentTerm` 与 `lastLogTerm` 不同；单个 no vote 与全局 majority 不同；higher-term tentative tail 与 committed prefix 的保留保证不同。

课堂还把 client timeout/retry 与 duplicate detection 放到 service boundary，提醒 Raft safety 不是端到端 exactly-once 的全部答案。

## 14. 理解题（10 题）

1. **为什么 `no response` 不能证明 server crash？**  
   **答：** Crash、packet loss、delay 与 partition 对远端都可能表现为无回复；timeout 只能产生 suspicion，不能给出准确 failure classification。
2. **`2f+1` 为什么能容忍最多 `f` 台不可达并继续？**  
   **答：** 剩余 `f+1` 台仍严格超过总数一半；再少一台就不再构成 global majority，只能停止 progress。
3. **同一 term 为什么至多一个 leader？**  
   **答：** Leader 需 majority，每台 server 每 term 最多投给一个 candidate，两个 majorities 必相交，交集节点不可能投两票。
4. **`currentTerm` 与 log entry 的 `term` 有何不同？**  
   **答：** 前者是 server 当前 election epoch；后者是创建该 entry 的 leader term。没有 append 新 entry 也可多次提高 `currentTerm`。
5. **Heartbeat 为什么仍可发现 log divergence？**  
   **答：** Heartbeat 是 empty AppendEntries，仍携带 `prevLogIndex/prevLogTerm` 并执行同一 prefix consistency check。
6. **Follower ACK entry 后为什么不能立即 apply？**  
   **答：** 它只知道本地保存，不知道 leader 是否取得 majority；必须等 `leaderCommit` 传播 commit knowledge。
7. **为什么 candidate freshness 不能只比较 log length？**  
   **答：** 较短 log 的最后 term 可能更高并包含必须保留的 history；Raft 先比 last term，再在相同 term 下比 last index。
8. **Leader 为什么不能按副本数直接 commit previous-term entry？**  
   **答：** Figure 8 表明该 entry 即使暂时在 majority 上，仍可能由后续合法 leader 覆盖；必须先以 current-term entry 建立安全 commit point。
9. **`nextIndex` 与 `matchIndex` 的差别是什么？**  
   **答：** `nextIndex` 是下一发送位置的可修正猜测；`matchIndex` 是成功 RPC 已确认的最高复制位置，用于 majority evidence。
10. **Safety 与 timing 的关系是什么？**  
    **答：** Safety 不依赖消息或时钟速度；bad timing 只能引发额外 election/停顿。稳定 progress 需要 broadcast、timeout 与 failure interval 满足合适尺度关系。

## 15. 复习清单

- [ ] 能精确说出指定范围是论文开头 through Section 5，并在 Section 6 前停止。
- [ ] 能写出 failure/network assumptions 与 Byzantine scope boundary。
- [ ] 能列出 persistent、all-server volatile 与 leader volatile state。
- [ ] 能区分 RequestVote 和 AppendEntries 的参数、接收检查与用途。
- [ ] 能用 one vote + majority intersection 证明 Election Safety。
- [ ] 能沿一条 command 标出 append、persist、ACK、commit、apply、reply。
- [ ] 能解释 Log Matching 的两层含义与 prefix induction。
- [ ] 能用 Figure 8 解释 current-term commit rule。
- [ ] 能从 Leader Completeness 推到 State Machine Safety。
- [ ] 能对 Figure 7 建 voter table，但不把 `currentTerm`、`lastLogTerm` 与 log length 混用。
- [ ] 能说明 crash/partition 下 minority 为什么停止，以及 client 为什么 retry。
- [ ] 能区分本讲 mechanism/proof evidence 与 Section 9 才提供的 empirical evaluation。
