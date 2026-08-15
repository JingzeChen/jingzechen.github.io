---
uid: mit-6824-s21-module-02
type: course
document_type: module
course: mit-6824-s21
module_number: 2
title: 模块 02：Raft 与容错服务
description: 连接 Lecture 5–8 的概念、证据与掌握路径。
excerpt: 连接 Lecture 5–8 的概念、证据与掌握路径。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/modules/02/"
toc: true
math: true
---

> 学习顺序严格保持为 **Raft (1) -> Lab 1 Q&A -> Raft (2) -> Lab 2A/2B Q&A**。本文只整理课程归档中可核对的机制、推理、实验进阶与调试证据，不提供 Lab 2 可提交代码、handler 结构、锁布局、timer 常量或测试答案。论文范围为 Lecture 5 的开头至 Section 5，以及 Lecture 7 的 Section 7 至结尾；**Section 6 membership changes 不在本模块范围内**。

## 学习目标

完成本模块后，应能：

1. 分开定义 safety 与 liveness，并说明 timing 为什么只影响 Raft 的 progress、不应进入核心 safety 证明。
2. 从 crash/partition 不可区分、majority intersection 与 one-vote-per-term 推出 election safety。
3. 沿 `append -> persist -> replicate -> commit -> apply -> reply` 追踪一条 command，区分复制证据、commit knowledge 与 state-machine execution。
4. 用 Figure 2 的 state、RPC checks 与 server rules解释 election、Log Matching、Leader Completeness 和 State Machine Safety，同时说明 Figure 2 为什么“必须遵守但不是完整并发程序”。
5. 用 Figure 8 解释 previous-term entry 不能仅凭多数副本直接 commit，以及 current-term commit rule 的作用。
6. 说明 `currentTerm`、`votedFor`、`log[]` 的持久化承诺与 durable-before-ack 顺序。
7. 说明 snapshot 如何用 state 表示已 apply 的 log prefix，并分析 logical index、boundary term、suffix retention、atomic persistence 与 stale snapshot。
8. 把测试失败转化为 `scenario -> invariant -> hypothesis -> trace -> first divergence -> validation`，而不是用 timeout 调参或偶发通过替代证据。

## 证据地图与边界

| 阶段 | 课堂/分段笔记 | 阅读与官方材料 | 作业与实验 |
| --- | --- | --- | --- |
| Raft (1) | [Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)；分段 [001](/courses/mit-6824-s21/lectures/005/#section-01)、[002](/courses/mit-6824-s21/lectures/005/#section-02)、[003](/courses/mit-6824-s21/lectures/005/#section-03)、[004](/courses/mit-6824-s21/lectures/005/#section-04)、[005](/courses/mit-6824-s21/lectures/005/#section-05)、[006](/courses/mit-6824-s21/lectures/005/#section-06)、[007](/courses/mit-6824-s21/lectures/005/#section-07)、[008](/courses/mit-6824-s21/lectures/005/#section-08)、[009](/courses/mit-6824-s21/lectures/005/#section-09)、[010](/courses/mit-6824-s21/lectures/005/#section-10) | [Reading 05](/courses/mit-6824-s21/readings/lecture-05/)、[Raft extended paper](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Raft FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt) | [Lecture 5 Figure 7 question](/assets/courses/mit-6824-s21/materials/official-materials/questions/05-q-raft.html#q-raft) |
| Lab 1 Q&A | [Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/) | [Reading 06](/courses/mit-6824-s21/readings/lecture-06/)；本讲无指定论文或 paper FAQ | [Lecture 6 Lab question](/assets/courses/mit-6824-s21/materials/official-materials/questions/06-q-QAlab.html#q-QAlab) |
| Raft (2) | [Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/) | [Reading 07](/courses/mit-6824-s21/readings/lecture-07/)、[Raft extended paper](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt) | [Lecture 7 Figure 13 question](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html#q-raft2) |
| Lab 2A/2B Q&A | [Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/) | [Reading 08](/courses/mit-6824-s21/readings/lecture-08/)；本讲无新指定论文或 paper FAQ | [Lecture 8 Lab question](/assets/courses/mit-6824-s21/materials/official-materials/questions/08-q-QAlab.html#q-QAlab)、[Lab 2: Raft](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)、[Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html) |

课程级交叉证据来自 [LABS 实践路线](/courses/mit-6824-s21/labs/)；论文、FAQ、Question、讲义、视频与归档状态的 provenance 来自 [materials-index metadata](/assets/courses/mit-6824-s21/metadata/materials-index.json)。metadata 确认同一份 extended paper 同时服务 Lecture 5 与 Lecture 7，Lecture 5 的指定范围到 Section 5，Lecture 7 从 Section 7 读到结尾并跳过 Section 6；它也确认 Lecture 6/8 的正式 homework 都是提交自己的 Lab question，而非额外论文。

---

## 第一阶段：Raft (1)

**主证据：** [Lecture 5 NOTES 与十个 part notes](/courses/mit-6824-s21/lectures/005/)、[Reading 05](/courses/mit-6824-s21/readings/lecture-05/)、[paper Sections 1-5](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Raft FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt)。

### 1. 从 split brain 到 majority

Timeout 只能说明“尚未收到回复”，不能区分 peer crash、packet loss、长延迟或 network partition。若两个副本各自在 partition 一侧继续修改状态，会产生 split brain；若必须等两个副本，又无法容忍一台 crash。Raft 使用固定 configuration 的 global majority：对 $N$ 台 server，quorum 为

$$
\left\lfloor\frac{N}{2}\right\rfloor+1.
$$

任意两个 majorities 必相交。对 $N=2f+1$，最多 $f$ 台不可达时仍剩 $f+1$ 台，可以 progress；再少就安全停顿。分母始终是全部 configured servers，不是当前 live servers，否则 partition 两侧可能各自降低门槛并同时作决定。

这里要分开两类目标：

- **Safety：** 在 non-Byzantine crash、delay、drop、duplicate、reorder、partition 下，不让两个 state machines 在同一 log index 执行不同 command，也不向 client 返回不正确结果。
- **Liveness/availability：** 当某个 majority 存活、互通且能与 clients 通信，并且消息最终有机会及时送达时，系统能选出稳定 leader 并继续处理 commands。

Safety 不依赖时钟快慢；极端 timing 最多造成额外 election 或停顿。Liveness 需要合适的时间尺度与最终可通信条件，论文概括为 $broadcastTime \ll electionTimeout \ll MTBF$。Randomization 改善 split-vote 后的 liveness，不是 election safety 的依据。

证据：[Lecture 5 part 001](/courses/mit-6824-s21/lectures/005/#section-01)、[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)、[Reading 05 的系统模型与 timing](/courses/mit-6824-s21/readings/lecture-05/)、[Raft FAQ 的 minority/split-brain 问答](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt)。

### 2. Replicated state machine 的完成路径

Raft 复制的不是任意数据库内存，而是一条 ordered command log。Deterministic state machines 从相同初态按同一顺序执行相同 commands，才得到相同 state 与 output。一条 operation 至少经历以下知识阶段：

```text
client request
  -> leader appends a log entry
  -> persistent state is made durable
  -> leader sends AppendEntries in parallel
  -> follower persists and acknowledges local append
  -> leader obtains majority replication evidence
  -> leader advances commitIndex under the commit rule
  -> entries are applied in index order
  -> service may complete the client operation
  -> later AppendEntries propagates leaderCommit to followers
```

必须区分：

1. Leader 本地 append 了 entry。
2. 某 follower ACK，证明它本地接受了 entry。
3. Leader 已有足够 evidence，知道 entry committed。
4. Follower 从 `leaderCommit` 知道 entry committed。
5. State machine 已按序 apply entry。
6. Service 已有足够端到端证据向 client 回复。

`Start()` 接受 command 或某个 peer 自称 leader都不能跳过这些阶段。Raft core 给出 ordered replication；client retry、duplicate detection 与 response caching 属于上层 replicated service 的端到端职责。

证据：[Lecture 5 part notes 002-004](/courses/mit-6824-s21/lectures/005/)、[Reading 05 的 command path](/courses/mit-6824-s21/readings/lecture-05/)、[Lab 2 interface](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)、[Raft FAQ 的 client/server interface 与 retry 问答](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt)。

### 3. Figure 2：状态表不是代码模板

[Figure 2 所在的 extended paper](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf) 把 Raft 的 state、RPC 与 rules 压缩在一页。课堂的关键判断是：**表中每条规则都必须成立，但表不是完整并发程序**。它没有替实现者决定 goroutine ownership、锁边界、RPC payload copy、迟到 reply 过滤、wake-up 机制或 shutdown lifecycle。

#### 状态分类

| 类别 | 状态 | 推理责任 |
| --- | --- | --- |
| 所有 servers 的 persistent state | `currentTerm`、`votedFor`、`log[]` | Crash/restart 后仍兑现“见过的 term、投过的票、确认保存的 history” |
| 所有 servers 的 volatile state | `commitIndex`、`lastApplied` | 分开表示“已知 committed”与“已交付 state machine” |
| Leader volatile state | `nextIndex[]`、`matchIndex[]` | 前者是下一发送位置的可回退猜测；后者是成功 reply 支撑的复制证据 |

#### 规则的因果链

1. RPC 携带 term；看到更高 term 时更新 `currentTerm` 并转 follower，stale term request 被拒绝。
2. 每 term 最多投一票；RequestVote 还要检查 candidate log 是否至少同样 up-to-date。
3. AppendEntries 用 `prevLogIndex/prevLogTerm` 证明共同 prefix；mismatch 时拒绝。
4. Follower 只删除 conflict entry 及其后缀，再追加 leader entries；相同 `(index,term)` 蕴含相同 command 与相同 prefix。
5. Leader 依据 `matchIndex` 的 majority evidence 推进 commit，但直接推进到 $N$ 还要求 `log[N].term == currentTerm`。
6. 每台 server 只把 `lastApplied+1 .. commitIndex` 按 index 顺序交给 state machine。

便于审查的表达是：

$$
commit(N) \Leftarrow
\left|\{i \mid matchIndex[i] \ge N\}\right| > \frac{N_{servers}}{2}
\land log[N].term=currentTerm.
$$

这不是实现伪代码，而是审查 leader 是否拥有足够 commit evidence 的概念条件。

证据：[Lecture 5 Figure 2 课堂边界](/courses/mit-6824-s21/lectures/005/)、[Reading 05 的 state/RPC/Figure 2 解释](/courses/mit-6824-s21/readings/lecture-05/)、[Lab 2 对 Figure 2 的要求](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)。

### 4. Leader election：唯一性与进展分开证明

Election chronology 是：follower 在一段时间没有有效 leader traffic 后提高 term，转 candidate，投自己一票，并行发送 RequestVote；同一 term 获得 global majority 后成为 leader。Split vote 时可能没有 leader，随机 election timeout 让下一轮更可能错开。

同一 term 最多一个 leader的证明只需要三件事：每台 server 每 term 最多投一票；leader 需要 majority；任意两个 majorities 相交。Random timeout、heartbeat frequency 与五秒测试窗口都不参与这个 safety proof，它们只影响多久能选出 leader。

Election restriction 比较 candidate 与 voter 的最后 entry：

$$
(candidate.lastLogTerm,candidate.lastLogIndex)
\ge_{lex}
(voter.lastLogTerm,voter.lastLogIndex).
$$

先比 last term，仅在 term 相同时比 last index。因此“最长 log 赢”“currentTerm 最高就一定获票”“一个 voter 拒绝就等于 candidate 不可能当选”都不成立。Candidate 还必须在同一 election context 中累积有效 replies；旧 election 的迟到 vote 不能进入新 term 的 majority。

证据：[Lecture 5 election/Figure 7 notes](/courses/mit-6824-s21/lectures/005/)、[Reading 05 的 election restriction](/courses/mit-6824-s21/readings/lecture-05/)、[paper Section 5.2 与 5.4](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)。

### 5. Log replication、repair 与 commit

`AppendEntries` 同时承担 heartbeat 与复制；empty entries 不取消 `prevLogIndex/prevLogTerm` 的 consistency check。Leader 为每个 follower 维护 `nextIndex`，从乐观位置尝试发送；失败说明发送假设不成立，可以回退寻找共同 prefix。成功 reply 才能提高 `matchIndex`。Follower 最终采用 leader 的 suffix，但 leader 自身遵守 append-only。

Log 暂时不同不是 safety failure；uncommitted tail 可以在 leader change 后丢失。真正不能发生的是已 committed/applied history 被后续 leader 覆盖。这个结论依赖：

```text
one vote per term + quorum intersection
  -> Election Safety
up-to-date voting + quorum intersection
  -> Leader Completeness
prev index/term checks + conflict truncation
  -> Log Matching
Leader Completeness + ordered apply
  -> State Machine Safety
```

Figure 8 揭示一个反直觉边界：previous-term entry 即使暂时出现在 majority logs 上，也可能在之后的合法 election 中被覆盖，所以不能仅按副本数直接 commit。Leader 先把一个 **current-term** entry 复制到 majority 并 commit，才通过 prefix relation 间接确认此前 entries。这是 safety rule，不是 tester trick。

证据：[Reading 05 的 Log Matching、repair、Figure 8 与 safety chain](/courses/mit-6824-s21/readings/lecture-05/)、[paper Sections 5.3-5.4](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)。

### 6. 官方 Figure 7 paper question

[Lecture 5 官方问题](/assets/courses/mit-6824-s21/materials/official-materials/questions/05-q-raft.html#q-raft) 要求在 Figure 7 的七节点日志中判断 `(a)`、`(d)`、`(f)` 是否可能当选、谁会投票、由什么具体机制阻止某个 candidate。正确练习方式不是记 yes/no，而是为每个 candidate 建表：

1. 固定配置人数与 majority threshold，crashed server 仍在分母中。
2. 分开记录 election `currentTerm` 与 candidate 的 `(lastLogTerm,lastLogIndex)`。
3. 对每个可联系 voter 依次检查 request term、`votedFor` 与 lexicographic freshness。
4. 把 candidate self-vote 与所有有效 yes votes 汇总后再判断 majority。
5. 最后验证当选结果不会让 committed prefix 消失；tentative tail 则可能保留或被覆盖。

问题页面与 assigned range 的归档关系由 [materials-index metadata](/assets/courses/mit-6824-s21/metadata/materials-index.json) 确认；课堂讨论边界见 [Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)。

---

## 第二阶段：Lab 1 Q&A

**主证据：** [Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/)、[Reading 06](/courses/mit-6824-s21/readings/lecture-06/)、[Lecture 6 official Lab question](/assets/courses/mit-6824-s21/materials/official-materials/questions/06-q-QAlab.html#q-QAlab)。本阶段没有指定论文或 paper FAQ；它提供的是可迁移的设计审查与证据方法，不是 Raft protocol rule。

### 1. 为什么 Raft 两讲之间保留 Lab 1 Q&A

Lecture 6 的主题是已提交的 MapReduce Lab 1。它在课程顺序中的价值，是把抽象机制转成可审查的 ownership、blocking、retry、publication 与 evidence 问题。下表只表示方法迁移，右栏的 Raft 机制仍必须回到 Raft paper、Lecture 5/7 和 Lab 2 handout 证明。

| Lab 1 Q&A 的审查轴 | 可迁移的问题 | Raft 中重新取证的位置 |
| --- | --- | --- |
| Logical task 与 execution attempt | 是否把稳定身份与一次可能超时/重试的尝试混在一起？ | Log entry identity、RPC send context、client request ID；[Lecture 5/7 readings](/courses/mit-6824-s21/readings/lecture-05/) |
| Timeout/reissue | Timeout 是 failure fact 还是 suspicion？迟到结果还属于当前 context 吗？ | Election timer、stale RequestVote/AppendEntries reply；[Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/) |
| Map-before-Reduce barrier | “已发出”“已完成”“已发布”是否被混用？ | Append、replicate、commit、apply、reply frontier；[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/) |
| Temporary file + atomic rename | 哪个事件让结果从 tentative 变成可依赖事实？ | Durable-before-ack、atomic state+snapshot persistence；[Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/) |
| Coordinator ownership | 哪个组件拥有某项 truth，其他组件通过什么 evidence 学到？ | Leader replication evidence、follower commit knowledge、service apply state；[Reading 05](/courses/mit-6824-s21/readings/lecture-05/) |
| Blocking boundary | 持有共享状态锁时，是否等待另一个需要该锁才能发生的事件？ | RPC round trip、apply channel、condition wait；[Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/) |

这一步防止把“API 看起来合理”“race detector 没报告”“test 偶尔过了”误当作 correctness argument。Lecture 6 还明确区分 process 内 lock/channel 与跨 machine RPC，提醒 server-local synchronization 不能直接建立 distributed ordering。

证据：[Lecture 6 NOTES 的 RPC contract、waiting、timeout、lock 与 file publication](/courses/mit-6824-s21/lectures/006/)、[Reading 06 的反思模板](/courses/mit-6824-s21/readings/lecture-06/)。

### 2. Evidence-first Q&A 模板

官方 homework 要求提交一个自己在 Lab 中产生的问题，而不是索取成品实现。一个可讨论的问题应包含：

| 字段 | 要写的证据 |
| --- | --- |
| Scenario | 哪个 test、哪些参与者、什么 failure/network action、预期完成什么？ |
| Observation | 第一个可复现的异常，而不是最后的 timeout 文本 |
| Invariant | 应始终成立的 ownership、phase、publication、term、log 或 frontier 条件 |
| Hypothesis A/B | 两个可竞争解释；每个解释可被哪条 trace 推翻？ |
| Missing evidence | 需要新增哪个 event、state delta 或 tester action 才能区分解释？ |
| Question | 请求澄清 mechanism、invariant 或 tradeoff，不请求代码 |

可复用句式是：“在 ___ 场景中，我观察到 ___；按 ___ invariant，我预期 ___；现有 trace 无法区分 ___ 与 ___；哪一项 state/RPC evidence 应作决定？”

证据：[Reading 06 的官方 question 与四段式问题](/courses/mit-6824-s21/readings/lecture-06/)、[Lecture 6 question archive](/assets/courses/mit-6824-s21/materials/official-materials/questions/06-q-QAlab.html#q-QAlab)。

### 3. 本阶段门禁

- [ ] 能说明 Lecture 6 是 Lab 1 Q&A，而不是 Raft (1.5) 或另一篇 paper。
- [ ] 能把 timeout 写成 suspicion，不把它写成 crash proof。
- [ ] 能分开 logical identity、attempt、completion evidence 与 published result。
- [ ] 能指出至少一个不能持 lock 等待的 blocking boundary。
- [ ] 能把模糊的“有时 hang”改写成含 scenario、invariant、competing hypotheses 与 missing evidence 的问题。

---

## 第三阶段：Raft (2)

**主证据：** [Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/)、[Reading 07](/courses/mit-6824-s21/readings/lecture-07/)、[paper Section 7 to end, excluding Section 6](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)。课堂先回接 Section 5 的 repair、Figure 8 与 persistence，再进入 Section 7 snapshot 和 Section 8 client semantics；这不改变 assigned paper range。

### 1. Divergent log catch-up 与 evidence monotonicity

Leader 对每个 follower 的 `nextIndex` 是发送猜测，失败时可回退；`matchIndex` 是成功 RPC 已确认的匹配 frontier，不能凭猜测提高。快速回退可以利用 follower 返回的 conflict term/index，减少逐 entry 探测，但优化细节不改变以下 safety boundary：

- Request/reply 的 term 与发送 context 必须匹配当前 leader authority。
- `prevLogIndex/prevLogTerm` 成功才证明对应 prefix。
- Stale failure reply 不能把已经有更新成功证据的 progress 倒退。
- Stale success reply 也不能被拿来证明另一个 term/context 中的 replication。
- Follower 可以删除 uncommitted conflicting tail，不可撤销 committed/applied state。

证据：[Lecture 7 NOTES 的 catch-up/fast backtracking](/courses/mit-6824-s21/lectures/007/)、[Reading 07](/courses/mit-6824-s21/readings/lecture-07/)、[Lab 2C handout](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)。

### 2. Persistence：把 protocol promise 延伸过 crash

Figure 2 指定 `currentTerm`、`votedFor` 与 `log[]` 为 persistent state。原因不是“这些字段常用”，而是它们承载不能因 reboot 遗忘的承诺：

| Durable state | 若遗忘会破坏什么 |
| --- | --- |
| `currentTerm` | Server 可能回到旧 epoch 并接受/发出不再有效的 authority |
| `votedFor` | Server 可能在同一 term 给两个 candidates 投票，破坏 Election Safety |
| `log[]` | 已向 leader ACK 的 entry 可能在 reboot 后消失，使 majority evidence 不再可信 |

关键顺序是：

$$
change\ persistent\ state
\rightarrow persist
\rightarrow expose\ dependent\ success.
$$

若先回复成功再 durable，crash window 会让其他 peer 把这份 ACK 计入 majority，而重启后的 server 已不再拥有被确认的 state。Role、`commitIndex`、`lastApplied`、`nextIndex`、`matchIndex` 可按协议重新建立，但 service state 还需要 replay committed log 或加载 snapshot 后 replay tail。

证据：[Lecture 7 persistence chronology](/courses/mit-6824-s21/lectures/007/)、[Lab 2C requirements](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)、[LABS 2C route](/courses/mit-6824-s21/labs/)。

### 3. Snapshot：state/history 对偶

若 state machine 从 $S_0$ 依次执行 `log[1..i]` 得到 $S_i$：

$$
S_i=apply(S_0,log[1..i]),
$$

则 durable snapshot 保存 $S_i$ 后，恢复材料可从完整 history 改为：

$$
snapshot_i+log[i+1..n].
$$

Snapshot 删除的是 history representation，不是 operations 的 effect。要使 compact 后的 Raft 仍能推理，至少保留 `lastIncludedIndex` 与 `lastIncludedTerm`；logical index 不能因底层 slice 截短而重置。Service 知道 state 已 apply through 哪个 index，Raft 知道哪些 log entries 可裁剪，两者的 boundary 必须一致。

#### 三条 snapshot 路径

1. **Local compaction：** service 提供覆盖 through $i$ 的 snapshot；Raft 裁剪对应 prefix，并原子保存 Raft state 与 snapshot。
2. **Lagging follower catch-up：** follower 所需 entry 已早于 leader retained log start，leader 改发 `InstallSnapshot`，随后从 snapshot boundary 后继续 log replication。
3. **Crash recovery：** 先恢复 snapshot 与 boundary metadata，再 replay retained tail；不能重复或跳过 operation。

#### 安装时的判定

- Incoming snapshot 落后于 receiver 已 apply/installed frontier 时，不得让 state machine 倒退。
- 若 snapshot boundary 与 local log 的同 index/term 匹配，删除 covered prefix并保留其后有效 suffix。
- 若 local suffix 与 snapshot history 冲突，可丢弃未 committed information；不可撤销已对外可见的 applied state。
- Partial snapshot 不能在 crash 后冒充完整 snapshot；重复安装同一 snapshot 应有 idempotent effect。
- Full-state snapshot 与 transfer 对大 state 可能昂贵，这是 paper/FAQ 承认的 clarity/performance tradeoff，不改变 safety contract。

Lab 2D 的课程接口与 paper Figure 13 不完全相同：课程以单个 RPC 传完整 snapshot，不要求实现 Figure 13 的 chunk `offset`；`Snapshot`/`CondInstallSnapshot` 是 service-Raft boundary，`InstallSnapshot` 是 peer-to-peer RPC。不要把某个 Lab API 当成唯一理论接口。

证据：[Reading 07 的 Sections 7-8 分析](/courses/mit-6824-s21/readings/lecture-07/)、[Lecture 7 snapshot notes](/courses/mit-6824-s21/lectures/007/)、[Lab 2D handout](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)、[Raft (2) FAQ 的 snapshot 问答](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)。

### 4. 从 Raft 到 fault-tolerant service

Raft 的 log agreement 还不是完整 client semantics。Client 可能把 request 发给 follower，可能遇到 leader crash，也可能在 operation 已 commit/apply 但 reply 丢失后 retry。Service 需要稳定 request identity、duplicate detection 与先前 response，且这些 service metadata 也必须进入 snapshot，才能在 compaction/restart 后继续提供同样语义。

Linearizability 要求完成的 operations 存在一个 single-machine total order；该顺序尊重 non-overlapping calls 的 real-time precedence，read 返回该顺序中最近 write 的值。`Start()` 返回、local append、leader identity 或 logs 最终相同都不足以单独证明 client-visible operation 已线性化。

Read-only optimization 也需要 freshness evidence：paper 的方案让 new leader 在 term 开始 commit no-op，并在直接服务 read 前与 majority 交换 heartbeat；lease 可少通信，但把 bounded clock assumptions 引入 safety。课程 Lab 3 可选择把 read 也放入 log，并不要求实现该优化。

证据：[paper Section 8](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Reading 07 的 client interaction/linearizability](/courses/mit-6824-s21/readings/lecture-07/)、[Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/)、[Raft (2) FAQ 的 no-op/read 问答](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)、[LABS 的 Lab 3 progression](/courses/mit-6824-s21/labs/)。

### 5. 官方 Figure 13 paper question

[Lecture 7 官方问题](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html#q-raft2) 问：收到 `InstallSnapshot` 是否会让 state machine “backwards in time”，即 Figure 13 step 8 是否可能让它反映更少的已执行 operations。练习时应建立 event/version 表，而不是从“leader 发来的肯定更新”开始：

1. 记录 incoming `(lastIncludedIndex,lastIncludedTerm)`。
2. 记录 receiver 的 current snapshot frontier、`commitIndex`、`lastApplied` 与 local log relation。
3. 允许较旧 RPC delay/reorder，并让 receiver 在其到达前继续 commit/apply 或安装更新 snapshot。
4. 分开讨论 log slice 变短、uncommitted tail 被删与 state machine rollback；只有第三项是问题所问的 backwards execution。
5. 检查 boundary 匹配时的 suffix retention，以及课程 service/Raft API 提供的额外 stale check。
6. 最终结论必须限定使用的是 paper receiver steps、课程 RPC model 还是 Lab-specific guard。

问题、FAQ 与 assigned range 的 provenance 见 [materials-index metadata](/assets/courses/mit-6824-s21/metadata/materials-index.json)；FAQ 对 stale/reordered snapshot 的讨论见 [Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)。

---

## 第四阶段：Lab 2A/2B Q&A

**主证据：** [Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/)、[Reading 08](/courses/mit-6824-s21/readings/lecture-08/)、[Lecture 8 official Lab question](/assets/courses/mit-6824-s21/materials/official-materials/questions/08-q-QAlab.html#q-QAlab)、[Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)。本讲展示的是一种可讨论的组织与 debugging workflow，不是唯一 reference implementation。

### 1. 从 observable error 向 first divergence 回溯

官方 guidance 区分 fault、latent error、observable error 与 masked error。Tester timeout 是 observable error，却通常离 protocol fault 很远。可重复的调试闭环是：

```text
read the failing test and reconstruct its scenario
  -> name the first observable error
  -> propose a falsifiable proximate hypothesis
  -> add stable instrumentation or an assertion
  -> rerun the same narrow test
  -> move the observable boundary backward
  -> stop at the first state transition that violates an invariant
```

若 hypothesis 被 trace 推翻，应换解释；若获得更早的 observable error，应围绕它继续收窄。不要在理解前修改多个机制，也不要用“改后过了一次”代替因果验证。

证据：[Lab guidance 的 formal debugging process](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)、[Lecture 8 debugging notes](/courses/mit-6824-s21/lectures/008/)、[Reading 08](/courses/mit-6824-s21/readings/lecture-08/)。

### 2. 最小可用 trace

| 字段 | 能检验什么 |
| --- | --- |
| elapsed time / run ID | timer、RPC delay、test action 与偶发 run 的 chronology |
| peer ID | 区分每台 server 的 local history |
| topic | timer/election/vote/log/commit/apply/snapshot/test action |
| local term + role | event 被处理时的 authority context |
| RPC type + direction | 重建 sender/receiver chain |
| request term/index metadata | 检查 stale context、log prefix 与 snapshot version |
| reply term/result | 检查 higher-term step-down、success/conflict 与迟到 reply |
| state delta | 找到 first divergence，而不是只记录 function entry |
| tester disconnect/reconnect/Start | 把 protocol event 放回真实 network scenario |

原始 trace 应尽量保留，再按 peer/topic 过滤。Logging 改变 timing 时，固定 instrumentation 后重复同一测试并保存每个 run，比失败后不断增删 prints 更有可比性。

证据：[Lecture 8 NOTES 的日志字段与 Heisenbug 方法](/courses/mit-6824-s21/lectures/008/)、[Lab guidance 的 structured trace 建议](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)。

### 3. Concurrency boundary 的概念审查

Raft state 会被 timer loop、incoming RPC handlers、`Start()` caller、outgoing RPC goroutines 与 applier 并发访问。Coarse lock 可减少 local interleavings，但不能证明 network result 新鲜。一个 RPC 在 assumption $A$ 下发出，不表示 reply 到达时 $A$ 仍成立；处理 reply 时必须重新检查 term、role、request context 与相关 frontier。

三类边界要分开：

- **Atomic state transition：** 相关 term/role/vote/log/progress 字段应在一致同步纪律下检查和更新。
- **Blocking boundary：** Network RPC、channel send 或长时 I/O 不应在持有会阻止 progress 的 state lock 时等待。
- **Payload stability：** 解锁后仍在发送的可变 slice/structure 不能被并发修改成另一条 message；trace 要能说明发送的是稳定 snapshot 还是 alias。

单一 applier 有利于 index order，但 channel send 仍可能 block；“只有一个 sender”不等于“可以持 Raft lock 等待 service”。Race detector 能发现某些 data race，不证明无 deadlock、无 stale reply、timer reset 正确或 protocol invariant 成立。

证据：[Lecture 8 goroutine/locking/reply freshness notes](/courses/mit-6824-s21/lectures/008/)、[Reading 08 的 concurrency reflection](/courses/mit-6824-s21/readings/lecture-08/)。

### 4. 表面 failure 与可证伪解释

| 表面现象 | 不能直接推出 | 优先检查的 evidence |
| --- | --- | --- |
| `expected one leader, got none` | “timeout 太短” | timer reset source、term progression、vote eligibility、RPC lifecycle |
| Agreement timeout | “AppendEntries handler 错了” | election churn、prefix rejection、progress update、commit rule、applier block |
| 调大 timeout 后较少失败 | 原 timeout 是 root cause | 相同代码/固定 trace 下，bad interleaving 是否仍出现 |
| Race detector 无报告 | 并发设计或 protocol 正确 | multi-field invariant、deadlock、stale context、memory lifecycle |
| Logs 最终相同 | apply/commit safety 成立 | 每个 index 的 commit/apply chronology |
| Logs 暂时不同 | 已违反 Raft | divergent 部分是否仅为 uncommitted tail |
| Peer 自称 leader | 它能完成 client operation | 当前 term 的 majority contact、commit 与 apply evidence |
| `Start()` 返回成功信息 | command 已 committed | match/commit/apply/service result path |
| Nil/uninitialized channel 下 hang | Network 或 election failure | initialization 与 goroutine lifecycle evidence |
| Heartbeat-only 最终复制 | progress speed 足够 | command arrival 到 first replication trigger 的 latency/RPC trace |

证据：[Lecture 8 NOTES 的 common failures](/courses/mit-6824-s21/lectures/008/)、[Reading 08 的“失败不等于 root cause”](/courses/mit-6824-s21/readings/lecture-08/)、[Lab guidance 的 timeout warning](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)。

### 5. 本阶段门禁

- [ ] 能从 tester action 重建 election 或 agreement scenario，而不是只引用最后一行错误。
- [ ] 能为一个 stale RequestVote/AppendEntries reply 写出 send context 与 receive-time context。
- [ ] 能画出某 follower 的 `nextIndex`/`matchIndex` 时间线，并标出 guess 与 evidence。
- [ ] 能为一次 commit 写出 majority members、各自确认 frontier、entry term 与 apply order。
- [ ] 能说明为什么 mutex serialization 不自动过滤 stale reply。
- [ ] 能说明 timeout 调参、一次 pass 与 race-free run 各自不能证明什么。
- [ ] 能提交一个含 scenario、invariant 与可证伪 evidence 的 Lab question，而不索取 solution code。

---

## Lab 进阶：2A -> 2B -> 2C -> 2D

[Lab 2 handout](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html) 与 [LABS 路线](/courses/mit-6824-s21/labs/) 把同一协议分成累积的四个门禁；后一部分通过不能替代前面部分的 regression。

| 阶段 | 新增行为 | 核心 proof obligation | 主要 observable evidence | 通过后仍需回归 |
| --- | --- | --- | --- | --- |
| 2A election | RequestVote、heartbeat、term/role/timer | 每 term 至多一 leader；majority 可通信时最终重选 | election chronology、vote context、higher-term step-down | 2A under repeated election/network loss |
| 2B log | `Start`、AppendEntries entries、repair、commit/apply、election restriction | Committed prefix 不被未来 leader 丢失；同 index apply 不冲突 | prefix checks、per-peer progress、majority/current-term commit、ordered ApplyMsg | 2A + 2B，含 partitioned leader rejoin 与 RPC cost |
| 2C persistence | persist/readPersist、crash/restart、fast backtracking | ACK 所依赖的 term/vote/log 在 reboot 后仍成立 | durable-before-reply trace、restart state、Figure 8/churn runs | 2A-2C repeated with `-race`；随机 pass 不足 |
| 2D snapshot | service snapshot、log compaction、InstallSnapshot、atomic state+snapshot | State machine/frontier 单调；trim 后 logical log 与 suffix 仍正确 | boundary metadata、stale check、snapshot/apply chronology、memory/RPC size | 全部 Lab 2；Lab 3 会进一步压力测试 snapshot |

官方要求 2A leader heartbeat 不超过每秒十次且 majority 存活时应在测试窗口内重选；2B 关注 agreement、partition/rejoin、快速回退与 RPC/byte cost；2C 要多次运行 persistence/churn tests；2D 完成条件是 2D 与全部 Lab 2 tests 都通过。这里的测试名称和性能约束是 validation surface，不是协议定义本身。

## 核心不变量清单

以下不变量都可从 [paper](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Readings 05/07](/courses/mit-6824-s21/readings/lecture-05/) 与 [Lab 2 handout](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html) 交叉核对：

1. **Term monotonicity：** 单个 peer 的 `currentTerm` 单调不减；higher-term evidence 使旧 authority 失效。
2. **One vote per term：** 同一 peer 每 term 至多支持一个 candidate，且 crash/restart 后仍成立。
3. **Election majority：** Candidate 只有在同一 term/context 获得 global majority 才成为 leader。
4. **Election freshness：** Voter 只支持 log 至少与自己同样 up-to-date 的 candidate。
5. **Leader append-only：** Leader 不覆盖或删除自己的 entries。
6. **Log Matching：** 相同 `(index,term)` 蕴含相同 command 和 through 该 index 的相同 prefix。
7. **Progress evidence：** `nextIndex` 可回退，`matchIndex` 只能由有效成功证据提高。
8. **Current-term commit：** Leader 直接推进 commit 到 $N$ 时，除 majority replication 外还要求 `log[N].term == currentTerm`。
9. **Commit/apply order：** `lastApplied <= commitIndex`，并按 index 单调、无 skip、无 duplicate 地交付。
10. **Durable-before-success：** 任何依赖 persistent state 的成功 reply 只能在相应 state durable 后暴露。
11. **Snapshot monotonicity：** Snapshot 只代表已 committed/applied prefix；旧 snapshot 不让 state machine 倒退。
12. **Snapshot boundary：** Compaction 后保留 `lastIncludedIndex/Term`，logical index 不等同于 local slice offset。
13. **Suffix preservation：** Snapshot boundary 与 local entry 匹配时，保留其后的有效 suffix。
14. **No-majority safety stop：** Minority 可保留 tentative state，但不能形成新 commit 或 client success。
15. **End-to-end completion：** Service reply 依赖 commit、apply、execution 与 duplicate semantics，不依赖 `Start()` return 或 local leadership alone。

## 常见误解速查

| 误解 | 纠正 |
| --- | --- |
| “Timeout 证明 peer 已 crash。” | Timeout 只产生 suspicion；partition、delay、drop 都有同一观察。 |
| “Split vote 会产生两个合法 leaders。” | Split vote 通常产生 no leader；one vote + intersecting majorities 阻止同 term 双 leader。 |
| “当前 live peers 的多数就够了。” | Quorum 分母是固定 configuration 的全部 peers。 |
| “Log 最长的 candidate 最新。” | Freshness 先比 last term，再在 term 相同下比 last index。 |
| “Heartbeat 不检查 log。” | Heartbeat 是 empty AppendEntries，仍执行 prefix consistency check。 |
| “Follower ACK 就是 commit/apply。” | ACK 只证明本地 append；leader 汇总 majority 后才知道 commit，follower 还要接收 commit frontier。 |
| “Previous-term entry 有 majority copies 就能直接 commit。” | Figure 8 反例要求先 commit current-term entry，再间接覆盖此前 prefix。 |
| “`nextIndex` 与 `matchIndex` 都是 follower progress。” | 前者是发送猜测，后者是成功证据；只有后者能支持 commit。 |
| “Persist 在函数返回前做就行。” | 必须在依赖该状态的 success/ACK 暴露前 durable。 |
| “Snapshot 是压缩后的 log 文件。” | Snapshot 是 applied service state 加 boundary metadata；它替代 prefix history 的表示。 |
| “收到 leader snapshot 总应安装。” | 到达顺序不等于版本顺序；stale snapshot 不得回滚 state machine。 |
| “Compaction 后 index 从零开始。” | Logical Raft index 保持连续；local storage 需要 base/offset 语义。 |
| “Race detector clean 证明协议正确。” | 它不证明 deadlock、stale reply、timer semantics、commit rule 或 distributed safety。 |
| “调大 timeout 后通过就是修好了。” | Timing 变化可能只 mask latent error；需同场景 trace 验证 first divergence。 |
| “Section 6 是 Raft (2) 的自然过渡。” | 本课程 Lecture 7 明确跳过 Section 6，从 Section 7 读到结尾。 |

## Mastery Gates

### Gate A：Raft (1) 机制门禁

- [ ] 不看笔记证明 one vote per term + majority intersection 推出 Election Safety。
- [ ] 对任意 candidate/voter 写出 `(lastTerm,lastIndex)` freshness 比较。
- [ ] 画出 command 的 append、ACK、commit knowledge、apply 与 reply 时间线。
- [ ] 用 Figure 8 解释 current-term commit rule，不把 majority copies 与 commit 混用。
- [ ] 说出 Figure 2 三类 state，并举一个 Figure 2 未替实现者解决的 concurrency 问题。

### Gate B：Evidence Q&A 门禁

- [ ] 把 timeout 写成 observation，不把它写成原因。
- [ ] 为一个 failure 写出两条 competing hypotheses 与各自 counter-evidence。
- [ ] 指出 logical identity、attempt/context 与 completion evidence 的差别。
- [ ] 提出一个不索取实现代码、可由 trace 回答的 Lab question。

### Gate C：Raft (2) 恢复门禁

- [ ] 用 crash window 证明 term、vote、log 为什么必须 durable-before-ack。
- [ ] 区分可删 uncommitted tail 与不可回退 committed/applied state。
- [ ] 画出 snapshot through $i$、compacted log tail、InstallSnapshot 与 restart replay。
- [ ] 判断 incoming snapshot 是 stale、prefix-compatible 还是 follower catch-up 所需。
- [ ] 解释 request ID/response cache 为什么属于 replicated service state，并应进入 snapshot。

### Gate D：Implementation evidence 门禁

- [ ] 从 test action 重建 network chronology，并找到 first divergence。
- [ ] 对迟到 RPC reply 重验 send term/role 与 receive-time term/role/context。
- [ ] 用 `nextIndex`/`matchIndex` 时间线区分 guess 与 evidence。
- [ ] 说明 lock、RPC/channel blocking 与 payload stability 三个不同问题。
- [ ] 运行同一窄 test 的固定 instrumentation，能用结果支持或推翻 hypothesis。

## 18 个累积问答

### Q1. 为什么两个副本不能仅靠 timeout 同时获得 safety 与 availability？

**答：** 无回复同时兼容 crash 与 partition。允许任一单副本继续会让 partition 两侧各自成功，要求两副本都回复又无法容忍一台 crash；第三副本与 majority rule 用 quorum intersection 打破对称。[证据：Lecture 5 part 001](/courses/mit-6824-s21/lectures/005/#section-01)

### Q2. Safety 与 liveness 在 Raft 中最重要的边界是什么？

**答：** Safety 在 non-Byzantine message delay/drop/reorder/partition 下都必须成立，不依赖 timing；liveness 需要 majority 最终可通信以及 timeout/heartbeat 有可用时间尺度。坏时钟或长延迟可以让系统停顿，不应让它提交冲突历史。[证据：Reading 05](/courses/mit-6824-s21/readings/lecture-05/)

### Q3. 同一 term 为什么最多一个 leader？

**答：** 每个 leader 需要 majority，每台 server 每 term 最多投一票，任意两个 majorities 必相交；若两个 candidate 都声称获 majority，交集 server 必须投两票，与 persistent one-vote rule 矛盾。[证据：paper Section 5.2](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)

### Q4. Randomized election timeout 证明了什么？

**答：** 它只降低 simultaneous candidacy 和重复 split vote 的概率，改善 liveness；即使 timeout 一直碰撞，Election Safety 仍由 one vote 与 quorum intersection 保证。[证据：Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)

### Q5. 为什么 candidate freshness 不能只比较 log length？

**答：** 较短 log 的最后 term 可能更高。Raft 以 `(lastLogTerm,lastLogIndex)` 字典序比较，先保留更高-term history，只有 last term 相同才用长度决定。[证据：Reading 05](/courses/mit-6824-s21/readings/lecture-05/)

### Q6. Heartbeat 为什么仍然与 Log Matching 有关？

**答：** Heartbeat 是 `entries[]` 为空的 AppendEntries，仍携带并检查 `prevLogIndex/prevLogTerm`；它既维持 leader authority，也能暴露 follower prefix mismatch。[证据：paper Figure 2](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)

### Q7. Follower ACK、leader commit 与 follower apply 为什么是三个事件？

**答：** ACK 只证明 follower 本地保存；leader 汇总 majority evidence 后才知道 committed；follower 要从后续 `leaderCommit` 学到 commit frontier，随后才能按序 apply。[证据：Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/)

### Q8. `nextIndex` 与 `matchIndex` 为什么不能互换？

**答：** `nextIndex` 是 leader 下一次发送位置的猜测，失败可回退；`matchIndex` 是有效成功 reply 确认的最高匹配 index，只有它能作为 majority replication evidence。[证据：Lecture 7 NOTES](/courses/mit-6824-s21/lectures/007/)

### Q9. 为什么 previous-term entry 有 majority copies 仍不能直接 commit？

**答：** Figure 8 展示该 entry 仍可能被后续合法 leader 覆盖。Leader 先 commit 本 term entry 后，election restriction 与 Log Matching 才让其 preceding prefix 间接 committed。[证据：Reading 05 的 Figure 8 推理](/courses/mit-6824-s21/readings/lecture-05/)

### Q10. Figure 2 为什么既是规范核心，又不是完整程序？

**答：** 它完整列出必须维护的 state、RPC checks 与 server rules，但不规定并发实现中的锁、goroutine ownership、stale reply filtering、payload copy、blocking channel 或 shutdown lifecycle。[证据：Lecture 5 Figure 2 课堂解释](/courses/mit-6824-s21/lectures/005/)

### Q11. Lecture 6 Lab 1 Q&A 对 Raft 学习的可迁移价值是什么？

**答：** 它训练从 contract、ownership、attempt identity、timeout suspicion、publication 与 blocking boundary 审查实现，并把模糊 failure 压缩成含 scenario、invariant 与 competing hypotheses 的问题；它本身不新增 Raft rule。[证据：Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/)

### Q12. 为什么 persistent state 必须在 success reply 前保存？

**答：** 若先 ACK 后 crash，leader 可能把这份 reply 计入 majority，但 reboot 后 peer 已忘记 entry、term 或 vote，使原 replication/election evidence 失真。Durability 必须先于依赖它的外部成功。[证据：Lecture 7 persistence notes](/courses/mit-6824-s21/lectures/007/)

### Q13. Snapshot 为什么允许删除 log prefix？

**答：** Snapshot 已保存 state machine 按序 apply through `lastIncludedIndex` 后的 state；删除的是重建该 state 的旧 history representation，operation effects 仍在 snapshot 中。[证据：Reading 07](/courses/mit-6824-s21/readings/lecture-07/)

### Q14. Snapshot 后为什么仍要保存 `lastIncludedIndex/Term`？

**答：** 它们定义 logical log boundary，使 snapshot 后第一条 entry 仍能执行 previous index/term consistency check，也让 local slice offset 不冒充 Raft index。[证据：paper Section 7](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)

### Q15. 收到 `InstallSnapshot` 为什么不能无条件安装？

**答：** RPC 可 delay/reorder，receiver 可能已 apply 到更高 frontier。Incoming snapshot 必须与 current applied/snapshot frontier 和 local log relation 比较；旧 snapshot 不能撤销 client-visible state。[证据：Lecture 7 question](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html#q-raft2)、[Lab 2D](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)

### Q16. Raft log 一致为什么仍不足以提供 exactly-once client effect？

**答：** Operation 可能已 commit/apply，但 reply 在 leader crash 前丢失；client retry 会再次提交同一 logical request。Service 需要稳定 request ID、duplicate detection 与 cached response，并把这些 state 一并 snapshot。[证据：paper Section 8](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)

### Q17. Race detector clean 为什么不能证明 Lab 2 正确？

**答：** 它只报告执行中检测到的 data races，不证明 timer reset、RPC context freshness、commit rule、deadlock freedom、apply order 或 distributed safety。Protocol claims 仍需 invariant 与 trace evidence。[证据：Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/)

### Q18. 怎样把 agreement timeout 变成可证伪的调试问题？

**答：** 先重建 tester 的 partition/reconnect/Start chronology，找第一处缺失 progress，提出如“stale failure reply 回退了已确认 progress”这样的具体 hypothesis，再记录 send/receive term、role、request context 与 state delta；同一窄 test 能支持或推翻它。[证据：Reading 08](/courses/mit-6824-s21/readings/lecture-08/)、[Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)

## 学习计划

| Session | 材料 | 产出 | 通过标准 |
| --- | --- | --- | --- |
| 1：故障模型与 quorum | [Lecture 5 part 001-002](/courses/mit-6824-s21/lectures/005/)、[Reading 05 Sections 1-4](/courses/mit-6824-s21/readings/lecture-05/) | 画 crash/partition indistinguishability 与 `2f+1` quorum 图 | 能分开 safety、liveness、timing，并证明 quorum intersection |
| 2：Figure 2 与 election | [paper Figure 2/Section 5.2](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)、[Lecture 5 NOTES](/courses/mit-6824-s21/lectures/005/) | 自制 persistent/volatile/RPC rule 表 | 能解释 one vote、higher term、freshness 与 randomized timeout 的不同职责 |
| 3：replication 与 safety | [Reading 05 Sections 5.3-5.4](/courses/mit-6824-s21/readings/lecture-05/)、[Figure 7 question](/assets/courses/mit-6824-s21/materials/official-materials/questions/05-q-raft.html#q-raft) | 画 command timeline、Figure 8 分支、Figure 7 voter worksheet | 能区分 append/ACK/commit/apply，并从 safety chain检查结论 |
| 4：Lab evidence bridge | [Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/)、[Reading 06](/courses/mit-6824-s21/readings/lecture-06/) | 把一个旧 Lab failure 写成 evidence-first question | 问题包含 scenario、invariant、A/B hypotheses 与 missing evidence |
| 5：repair 与 persistence | [Lecture 7 NOTES 前半](/courses/mit-6824-s21/lectures/007/)、[Lab 2C](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html) | 画 per-follower progress 与 durable-before-ack crash window | 能区分 `nextIndex`/`matchIndex`，解释三项 persistent state |
| 6：snapshot 与 service | [Reading 07 Sections 7-8](/courses/mit-6824-s21/readings/lecture-07/)、[Raft (2) FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)、[Figure 13 question](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html#q-raft2) | 画 local compact、InstallSnapshot、restart 三条数据流 | 能判定 stale/prefix-compatible snapshot，解释 request dedup state |
| 7：debugging evidence | [Lecture 8 NOTES](/courses/mit-6824-s21/lectures/008/)、[Reading 08](/courses/mit-6824-s21/readings/lecture-08/)、[Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html) | 设计一行 trace schema，并对一个 failure 写 falsifiable hypothesis | 能从 observable error 回溯 first divergence，不用 timeout 调参代替解释 |
| 8：累积审查 | [Lab 2 handout](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)、[LABS](/courses/mit-6824-s21/labs/)、本模块 18 问 | 闭卷回答 18 问并逐项完成 Gate A-D | 任一答案都能指出 source、invariant、failure scenario 与 evidence boundary |

## 最终自检

- [ ] 我保持了 Raft (1) -> Lab 1 Q&A -> Raft (2) -> Lab 2A/2B Q&A 的课程顺序。
- [ ] 我没有把 Lecture 6/8 当作新增 paper，也没有把课堂展示当作唯一 implementation。
- [ ] 我没有把 Section 6 membership changes 混入 Lecture 7 指定范围。
- [ ] 我能分别解释 safety、liveness、election、replication、commit、persistence 与 snapshot。
- [ ] 我能从 Figure 2 rule 推出检查项，也能指出 Figure 2 没有覆盖的并发实现责任。
- [ ] 我能用 2A -> 2B -> 2C -> 2D 的累积门禁安排实现验证与 regression。
- [ ] 我能把误解改写为具体 invariant，并用 structured trace 找 first divergence。
- [ ] 我完成了 18 个累积问答和 Gate A-D，而不是只记住测试名称或结论。
