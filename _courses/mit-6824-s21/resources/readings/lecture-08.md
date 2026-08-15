---
uid: mit-6824-s21-resource-reading-8
type: course
document_type: resource
resource_kind: reading
resource_order: 108
course: mit-6824-s21
title: Lecture 8 课前反思指南：Lab 2A/2B Q&A
description: Lecture 8 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 8 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-08/"
toc: true
official_lecture_number: 8
---

## 1. 来源与任务边界

- 本讲是 **Lab 2A/2B Q&A**，不是 paper lecture。
- **没有新指定论文，也没有本讲 paper FAQ。** Lab 2 handout 要求参考 extended Raft paper，尤其 Figure 2，但这不等于 Lecture 8 另行布置了一篇 paper。
- 唯一正式 homework 是归档 Question：提交一个关于刚完成 Lab 的问题。
- 本指南只依据 archived Question、官方 Lab 2 handout、课程 `MATERIALS.md` 与 Lecture 8 `NOTES.md`；不从外部 Student's Guide、论坛答案或成品实现补机制。
- 课堂展示的是一份可讨论的实现结构和 debugging workflow，不是唯一 reference solution。本指南只整理 invariants、evidence 与 tradeoffs，不提供 RPC handler、goroutine loop、timer 或 locking 的可提交代码。

资源：

- [Lecture 8 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-08.md)
- [官方 Lab Q&A Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/08-q-QAlab.html)
- [Lab 2: Raft 归档说明](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)
- [Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-8-lab-2a_2b-qa)
- [Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/)
- [Lecture 8 transcript](/assets/courses/mit-6824-s21/lectures/008/transcript.txt)
- [Lecture 8 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=8)

## 2. 官方 Lab Question

**Assigned Question（原文）**：

> The lecture today is an Q&A session about the last submitted lab (e.g., lab 1 or lab2A+B). Submit a question about the lab: for example, something you wondered about while doing the lab, something you didn't understand, or just anything.

这里要求的是一个你自己的 **question**。不要把提交写成 Raft 总结、贴出完整实现，或询问“怎样才能通过全部 tests”。一个可讨论问题应包含具体 scenario、可观察 evidence、你认为相关的 invariant，以及仍无法区分的解释。

## 3. 从失败现象到可回答问题

课堂给出的主方法是：

```text
test scenario
  -> falsifiable hypothesis
  -> stable RPC/state trace
  -> supporting and counter-evidence
  -> narrower question or justified fix
  -> rerun the same test
```

写问题前先完成四步：

1. **重建 test scenario：** 哪些 peers connected、谁被认为是 leader、何时 partition/reconnect、tester 在等待 election 还是 agreement？
2. **找 first divergence：** 不要从最终 timeout 倒推 root cause；找 trace 中第一个违反 expectation 的 term、role、vote、log、commit 或 apply event。
3. **写 competing hypotheses：** 例如 stale reply 被使用、timer 被错误 reset、progress evidence 回退、apply path 阻塞。每个 hypothesis 都要说明什么 trace 能推翻它。
4. **压缩成 question：** 问清楚应维持什么 invariant、何时需要重新验证 assumption，或两个设计的 safety/liveness tradeoff；不要索要成品代码。

可用句式：

> During ___ test, after ___ network event, peer ___ changed from ___ to ___. My trace shows ___. I expected ___ because of invariant ___. I cannot distinguish ___ from ___. Which state or RPC evidence should decide between them?

## 4. 先确认 Lab 2A/2B contract

### 4.1 Raft module boundary

官方 handout 把 Raft 实现为 larger service 使用的 Go object。Tester/service 调用：

- `Make(...)` 创建 peer；
- `GetState()` 查询 peer 当前 term 与主观 leadership；
- `Start(command)` 请求开始 agreement，并立即返回调用方，不等待 replication 完成；
- `applyCh` 接收 newly committed entries 的 `ApplyMsg`。

`Start()` 返回 `isleader=true` 只表示该时刻 peer 主观接受请求；不表示 command 已 committed、applied 或可向最终 client 回复。

### 4.2 Part 2A 的行为面

2A 聚焦 leader election 与 heartbeat。反思时至少区分：

- server role：follower、candidate、leader；
- `currentTerm` 与每 term 的 `votedFor`；
- election timeout 与 heartbeat interval；
- RequestVote request/reply；
- higher-term information 引发的 state transition；
- majority 以全部 configured peers 为分母。

2A 的目标不是让某个 peer 经常自称 leader，而是在 network/failure scenario 下满足 one leader per term，并在 majority 可通信时及时恢复 leadership。

### 4.3 Part 2B 的行为面

2B 增加 log replication、agreement 与 apply：

- leader 接受 command 并形成 `(index,term,command)` entry；
- AppendEntries 以 `prevLogIndex/prevLogTerm` 检查共同 prefix；
- follower 可拒绝 mismatch，leader 调整 per-peer replication progress；
- leader 以 majority replication evidence 推进 commit；
- peers 按 index order 把 committed entries 送入 `applyCh`。

“Logs 暂时不同”“某 entry 最终丢失”和“两个 state machines 在同一 index apply 不同 command”是三个不同结论。前两者在 uncommitted tail 上可能合法；第三个违反 State Machine Safety。

### 4.4 Progress boundary

官方 handout说明：majority 存活且可互通时 Raft 继续；无 majority 时不 progress，但通信恢复后应从 persistent/已有 state 继续。Lab 2A/2B Q&A 主要讨论 election 与 volatile log replication behavior；后续 2C/2D 的 persistence/snapshot 不应被偷换成 2A/2B 的现成答案。

## 5. 需要从 trace 维护的 invariants

### 5.1 Term 与 role

- `currentTerm` 对单 peer 单调不减。
- 收到 request/reply 中更高 term 时，peer 不能继续在旧 term 以 candidate/leader authority 行动。
- 同 term 的 vote denial 与 higher-term message 不同：前者影响 vote count，后者改变 election context。
- Role 是主观 local state；真正能 commit 的 active leader 还需 majority responses。

诊断日志应把 event term 与 peer 当前 term 分开记录，否则无法识别 stale RPC/reply。

### 5.2 Election Safety

- 一台 peer 每 term 最多支持一个 candidate；duplicate RequestVote 可重复确认同一 candidate，但不能改投另一 candidate。
- Candidate 只有在同一 election context 中取得 majority 才能成为 leader。
- 多个 vote reply goroutines 的 lock serialization 不会自动过滤 stale reply；reply 还要与当前 term/role/context 比较。

### 5.3 Timer semantics

必须区分：

- heartbeat interval：leader 周期发送 authority/replication traffic；
- randomized election timeout：follower/candidate 多久无有效 leader/election progress 后发起新 election；
- timer polling/tick interval：实现多久检查一次 deadline。

调大 timeout 让失败减少，只证明 bug 对 timing 敏感，不证明原 timeout 错。Timer reset 应由明确 protocol event 触发；stale/lower-term message 是否能延后 election 是值得从 trace 单独检查的问题。

### 5.4 Log Matching 与 per-peer progress

- `nextIndex[f]` 是 leader 下一次准备发送位置的估计；
- `matchIndex[f]` 是成功 AppendEntries 已确认的最高匹配 index；
- rejection 可降低发送猜测，不能凭空提高匹配证据；
- success reply 也可能迟到，处理前要确认它仍属于当前 leader/term 与相关 request context；
- 同 index+term 的匹配意味着该处之前 prefix 匹配，这是 `prevLogIndex/prevLogTerm` 有效的基础。

课堂对某些板书数值存在 off-by-one 口述歧义；问题应引用变量语义与你自己的 trace，而不是复述某个 12/13 数字。

### 5.5 Commit 与 apply

- Leader 不能因本地 append 或单个 follower ACK 就对一般 cluster 宣称 commit；需要 majority replication evidence。
- Figure 8 的 current-term rule 说明 majority copies 与可直接推进 commit 仍需 term 条件；这属于 protocol safety，不是 tester trick。
- `commitIndex` 是已知 committed frontier，`lastApplied` 是已交付 frontier，二者不可混用。
- Apply 必须按 log index order；多个 RPC completion order 不能决定 state-machine order。
- 向 `applyCh` 发送可能 block，不能把“单一 applier 保序”误当成“持 lock 发送永不阻塞”。

## 6. Concurrency 与 ownership 反思

Lecture 8 展示了 coarse-grained Raft mutex、ticker、incoming handlers、outgoing RPC goroutines、`Start` caller 与专用 applier 的一种组织方式。应提取的是 boundary，不是结构模板。

### 6.1 Critical section

- 同一 critical section 内可原子检查并更新相关 Raft state。
- Unlock 后到下一次 lock 之间，term、role、log 和 progress 都可能改变；跨区间 assumption 必须重新验证。
- 将 handler 拆成许多小 critical sections 会增加 interleavings；一个大 critical section 又不能包含未知时长的外部等待。

### 6.2 Blocking boundary

- Sender 不应持 Raft lock 等待 network RPC round trip；receiver handler 在另一 peer 上可获取它自己的 lock。
- Channel send 可能阻塞，包括 unbuffered channel 或已满的 buffered channel。
- RPC arguments 若引用可变 Go slice backing array，unlock 后 log mutation 可能改变正在发送的数据；诊断时应确认 message payload 是稳定 snapshot 还是 alias。

### 6.3 Reply freshness

`RPC sent under assumption A` 不意味着 reply 到达时 A 仍成立。Trace 应记录：send term/role、request identity、reply term/success、处理时 current term/role，以及 `nextIndex/matchIndex` 前后变化。Mutex 只让处理互斥，不判断结果是否过期。

### 6.4 Applier ownership

课堂用单一 applier 自然保证 apply order，并以 condition variable 表达“可能有新 committed work”。其他架构也可能正确；必须回答的是：谁拥有 `lastApplied` progression，谁保证不重复/跳 index，谁在 channel block 时释放 Raft state lock。

## 7. Debugging evidence 的最小格式

建议每条 trace 统一包含：

| Field | 诊断用途 |
| --- | --- |
| elapsed time | 对齐 timeout、RPC delay、partition action |
| peer ID | 区分 local histories |
| topic | timer/election/vote/log/commit/apply/test action |
| local term/role | 判断 event 发生时的 authority |
| RPC direction/type | 重建 sender/receiver chain |
| request term/index metadata | 判断 freshness 与 prefix check |
| reply term/result | 判断 step-down、success、conflict |
| state delta | 记录 first divergence，而非只有函数入口 |

把 tester 的 disconnect、reconnect、leader check 与 `Start` action 也写入同一时间轴。原始 trace 尽量全量保存，再按 topic/peer 过滤；过早关闭“噪声”可能删掉 root-cause evidence。

对 logging 改变 timing 的 Heisenbug，保持 instrumentation 不变并重复运行，保存每个 run；不要失败后反复改 prints，导致无法比较 execution。

## 8. 课堂中的设计取舍

### 8.1 Coarse vs fine locking

Coarse lock 减少 interleavings、便于维护多字段 invariant；代价是 critical section 过长会降低并发。无论粒度如何，network/channel block 必须切到 lock 外，回来后重验 context。

### 8.2 Event-driven vs polling

Condition variable 可在 commit progress 后立即唤醒 applier；periodic polling 较简单但增加 delay 与 timing paths。课堂偏好职责分离，但没有把 condition variable 规定为 protocol requirement。

### 8.3 `Start` immediate replication vs heartbeat-only

Heartbeat 与带 entries 的 AppendEntries 可共用发送路径。只等 heartbeat 也可能最终 replicate，却受 heartbeat rate 限制、增加 command latency，并可能无法满足后续 progress expectations；偶发 agreement failure 仍需另找 safety/liveness evidence，不能只归因于发送 trigger。

### 8.4 Timer range

短 timeout 更快发现 leader failure，却更容易因 delay/drop 触发 contested elections；长 timeout 给 RPC 更多机会，却延长 failover。课堂出现的具体毫秒范围属于个人实现/测试语境，不是可照抄常量。

### 8.5 Optimistic progress

Leader 将 `nextIndex` 初始化到 local last index 之后，是 optimistic guess；followers up-to-date 时节省探测，落后时需 backoff。Optimism 不能污染 `matchIndex`，后者必须由 success evidence 支撑。

## 9. 常见失败不等于 root cause

- **“Expected one leader, got none”** 可能来自 timer、vote eligibility、stale term、RPC lifecycle 或 goroutine leak；错误文本本身不能定位。
- **Agreement timeout** 可能来自 election churn、AppendEntries mismatch、progress update、commit rule、applier blocking 或 nil channel。
- **调大 timeout 后通过** 可能只是改变 bad interleaving 的概率。
- **Race detector 无报告** 只说明本次执行未检测到 data race，不证明 protocol safety/liveness。
- **Race detector 下长期崩溃** 可能来自 timer goroutine lifecycle leak，而非 RPC library。
- **Nil channel** 属于 initialization/lifecycle failure，表面上却像 receiver 永远不响应。
- **Logs 最终相同** 不证明 apply order/commit safety；**logs 暂时不同** 也不自动说明错误。
- **Peer 自称 leader** 不证明它能取得 majority、commit 或向 service完成 operation。

## 10. Lab 反思记录模板

| 项目 | 你的记录 |
| --- | --- |
| Test 与 run ID | 哪个 test、是否 `-race`、第几次 run？ |
| Network scenario | 哪些 peers connected/disconnected/reconnected？ |
| First divergence | 最早错误 term/role/vote/log/commit/apply event？ |
| Expected invariant | 你认为哪条 Figure 2/3 rule 应成立？ |
| Relevant local state | Event 前后的 term、role、log/progress/frontier？ |
| Relevant RPC | Send/receive/reply 的 term、index、result？ |
| Concurrency context | 哪些 goroutines、lock/unlock/block boundary？ |
| Hypothesis A | 什么 evidence 支持，什么 evidence 可推翻？ |
| Hypothesis B | 什么 evidence 支持，什么 evidence 可推翻？ |
| Narrow question | 课堂应澄清哪个 invariant 或 tradeoff？ |

不要把整张表作为 homework。先用它消除模糊描述，再提交最后一行的具体 question。

## 11. 诊断 prompts（10 项）

以下 prompts 不要求写修复或实现，只要求建立可证伪的解释。

1. **Election chronology：** 选一次 re-election failure，按时间列出 heartbeat loss、timeout、term increment、self-vote、RequestVote sends/replies 与 leader transition。哪一个 event 第一次偏离 Figure 2 expectation？
2. **Stale vote reply：** 构造 candidate 发出 RequestVote 后、reply 返回前收到 higher-term RPC 的 scenario。你的 trace 如何证明旧 reply 没有被计入新 election？
3. **Timer reset：** 列出所有会重置 election timer 的代码路径及其 event term。某个 stale/lower-term message 是否会延长 deadline？哪条 log 能推翻你的判断？
4. **Role/term atomicity：** 找一次 role 与 term 同时变化。其他 goroutine 能否观察到只更新其中一项的组合？如果能，那一组合会如何影响下一条 RPC decision？
5. **AppendEntries payload：** 选一条发送 RPC，记录构造时 log range 与发送后 local log mutation。Payload 是否是稳定 copy？若是共享 slice，什么 interleaving 会改变 receiver 实际看到的 entries？
6. **Per-peer progress：** 对一个 follower 画 `nextIndex`、`matchIndex` 随 success/failure/reordered replies 的时间线。哪次更新有成功证据，哪次只是猜测？是否出现 progress 被 stale reply 回退？
7. **Commit reasoning：** 选一个 leader 推进 `commitIndex` 的时刻，列出构成 majority 的 peers、各自已确认 `matchIndex` 与目标 entry term。哪些 evidence 来自当前 term/context？
8. **Apply ordering：** 从两条相邻 committed entries 追踪到 `ApplyMsg`。谁拥有 `lastApplied`，channel block 时是否持 Raft lock，是否存在 duplicate、skip 或 completion-order apply 的可能？
9. **Timing mask vs root cause：** 对一个“增大 timeout 后较少失败”的 case，写出至少两个解释。设计一个保持代码不变、只增加固定 trace/重复 runs 的检查来区分它们。
10. **End-to-end question：** 从一个具体 test failure 提炼 `scenario -> invariant -> first divergence -> competing hypotheses -> requested clarification`，确保最后问题不要求任何 RPC handler 或 goroutine implementation。

## 12. 可提交问题的自检

- [ ] 我的问题明确针对 Lab 2A、2B 或两者的交界。
- [ ] 我引用了具体 test scenario/trace，而不只是最终 timeout。
- [ ] 我区分 event term 与处理时 local current term。
- [ ] 我区分 local role 与能取得 majority 的 active leadership。
- [ ] 我区分 `nextIndex` guess 与 `matchIndex` evidence。
- [ ] 我区分 append、commit、apply 与 `Start()` return。
- [ ] 我说明了相关 lock/RPC/channel boundary，但没有索要实现代码。
- [ ] 我没有把更大 timeout、偶尔 pass 或无 race report 当作 correctness proof。
- [ ] 我把课堂展示视为一种 design，而不是 official solution。
- [ ] 我的提交确实是 question，不是 Raft 复习文章。

## 13. 课堂连接摘要

[Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/) 把课堂组织成“先 debugging evidence，再 concurrency boundary，最后沿 election -> replication -> commit -> apply 复盘”。几个最值得带入自己的问题的连接是：

1. Structured logging 必须同时包含 protocol event 与 tester network action，才能解释 partition chronology。
2. Coarse-grained lock 只序列化 local state mutation；term/context validation 才过滤 stale network result。
3. Heartbeat 与 AppendEntries 是同一路径的不同 payload 情形，触发源不直接决定是否携带 entries。
4. Majority replication、current-term condition、`commitIndex` 与 ordered applier共同构成完成路径，任一层都不能由“某 follower ACK 了”替代。
5. Timer leak、nil channel、timeout masking 和 immutable `peers` 的 race 讨论说明：资源 lifecycle、initialization、timing 与 protocol logic 是不同 failure classes。

课堂对 `rf.killed` race、某些 fallback branch、channel fairness 与具体 timer constants保留不确定性。若你的 question 涉及这些点，应把不确定 assumptions 写出来，而不是从 transcript 推导一个标准答案。
