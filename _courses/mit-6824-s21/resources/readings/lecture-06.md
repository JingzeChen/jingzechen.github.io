---
uid: mit-6824-s21-resource-reading-6
type: course
document_type: resource
resource_kind: reading
resource_order: 106
course: mit-6824-s21
title: Lecture 6 课前反思指南：Lab 1 Q&A
description: Lecture 6 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 6 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-06/"
toc: true
official_lecture_number: 6
---

## 1. 来源与任务边界

- 本讲是 **Lab 1: MapReduce Q&A**，不是 paper lecture。
- **没有指定论文，也没有 paper FAQ。** 不要为了套用论文阅读模板而补一篇未被 schedule 指定的 paper。
- 唯一正式 homework 是归档 Question：提交一个关于刚完成 Lab 的问题。
- 本指南只依据 archived Question、官方 Lab 1 handout、课程 `MATERIALS.md` 与 Lecture 6 `NOTES.md`；课堂中展示的个人方案、未完成 channel 草图或不确定回答都不应变成“官方实现”。
- 目标是帮助你从自己的设计、测试和 failure evidence 中提炼一个具体问题，而不是给出可提交的 coordinator/worker solution。

资源：

- [Lecture 6 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-06.md)
- [官方 Lab Q&A Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/06-q-QAlab.html)
- [Lab 1: MapReduce 归档说明](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-mr.html)
- [Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-6-lab-1-qa)
- [Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/)
- [Lecture 6 transcript](/assets/courses/mit-6824-s21/lectures/006/transcript.txt)
- [Lecture 6 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=6)

## 2. 官方 Lab Question

**Assigned Question（原文）**：

> The lecture today is an Q&A session about the last submitted lab (e.g., lab 1 or lab2A+B). Submit a question about the lab: for example, something you wondered about while doing the lab, something you didn't understand, or just anything.

这里没有唯一正确答案。作业要求你提交自己的 **question**，不是复述 Lab handout，也不是提交一段实现。高质量问题应能指出：你观察到什么、原先如何理解、哪两个解释仍无法区分，以及你希望课堂澄清什么。

## 3. 如何形成一个可讨论的问题

建议把问题写成四部分草稿：

1. **Context：** 指明 Lab 1 的角色或阶段，例如 `coordinator`、`worker`、Map/Reduce barrier、task timeout、file publication、RPC、lock/channel。
2. **Observation：** 写一个可以核对的现象，例如某 test、某段 trace、某类 delay/crash 后的状态；不要只写“有时 hang”。
3. **Competing explanations：** 列出至少两个可能解释，并说明现有 evidence 为什么还不能排除其中一个。
4. **Question：** 问清 mechanism、invariant 或 tradeoff，而不是问“请给我正确代码”。

可采用以下句式，但必须替换为自己的 evidence：

> In the scenario where ___, I observed ___. I expected ___ because ___. I cannot tell whether the relevant issue is ___ or ___. What invariant or evidence should distinguish them?

不要提交：

- 只含 “my code does not work” 的无场景问题；
- 要求完整 reference implementation 的问题；
- 直接贴出整份代码让课堂 debug；
- 把某个通过测试的结构当成唯一架构，询问别人为何“不照做”；
- 没有区分 specification、课堂示例与自己 design choice 的问题。

## 4. 先重建官方 Lab contract

在反思具体 bug 前，先确认你理解的是 handout 要求，而不是课堂某份示例代码。

### 4.1 Roles 与通信

- 系统由一个 `coordinator` process 与一个或多个并行 `worker` processes 构成。
- Lab 环境把它们放在同一 machine，但角色经 RPC 交流；真实系统可在不同 machines。
- Worker 请求 task、读取输入、调用 application Map/Reduce function，并写 output files。
- Coordinator 分配 tasks，并在 worker 未能于合理时间完成时重新分配；归档 handout 对本 Lab 指定 `10 seconds` 的 task timeout。

### 4.2 Dataflow 与 phase ordering

```text
input split
  -> Map task
  -> partitioned intermediate files
  -> all Map tasks complete
  -> Reduce task reads its partitions
  -> final mr-out-* files
```

“全部 Map tasks 已分配”不等于“全部 Map tasks 已完成”。Reduce 依赖所有 Map outputs，因此 phase barrier 是 correctness 条件。Coordinator 管 control-plane metadata；Map、sorting/grouping、Reduce 与文件数据处理主要属于 workers。

### 4.3 Failure 与 duplicate execution

Timeout 只能说明 task 长时间未报告完成，不能证明 worker 一定 crash。Coordinator 可能把同一 task 交给另一个 worker，而原 worker 之后也完成。反思时必须区分：

- logical task identity；
- 某次 execution attempt；
- coordinator 记录的 issued/done state；
- 哪个 file result 对外成为可见 final result。

这组区分用于提出问题，不在本指南给出命名、状态机或冲突解决代码。

### 4.4 Test boundary

归档 handout 说明 tests 检查：

- word-count 与 indexer 的 final output correctness；
- Map/Reduce tasks 是否并行执行；
- worker crash 时是否能恢复并完成。

一次 test pass 不能证明所有 interleavings 正确；一次 hang 也不能仅凭现象说明是 RPC、lock、file 或 phase bug。问题应引用可重复 scenario 或 trace。

## 5. 课堂材料中的反思轴

以下内容来自 Lecture 6 Q&A，可用于审查自己的设计，但都不是要求照抄的 solution。

### 5.1 RPC contract 与状态 ownership

课堂先从“请求 task”和“报告 task 完成”的通信意图出发，再问 coordinator 需要哪些 task metadata。反思重点是：

- 一次 RPC 是否表达了一个清楚意图，还是先探测再领取、产生冗余 round trips？
- 哪个角色拥有 task assignment/completion truth？
- `Done` 表示整个 job 结束，还是暂时没有 task？
- RPC reply 中哪些 metadata 是 worker 执行所必需，哪些只是某一实现的 convenience？

### 5.2 Waiting 与 liveness

当本阶段 tasks 已发出但未完成时，可让 worker polling，也可让 coordinator 暂缓 RPC reply；课堂比较了 fixed sleep 与 condition variable。反思时不要问“哪个 API 是标准答案”，而应问：

- 等待的 predicate 是什么？
- 哪些事件使 predicate 变 true？
- timeout 没有 completion event 时，谁负责重新检查？
- 设计如何区分“暂时无工作”与“全局结束”？
- 不同方案的 wake-up latency 与 RPC traffic 有何差别？

### 5.3 File publication 与 phase barrier

课堂讨论 temporary file 与 atomic rename，是为了审查 partial output、并发 attempts 与 final visibility。可追问：

- Reader 在什么条件下能看到完整文件？
- 两次 execution attempts 是否可能争用同一 temporary/final name？
- Coordinator 收到 completion 时，相关 files 是否已经完整可见？
- Reduce 是否可能在某个 Map 的最终 intermediate outputs 尚未发布时启动？

这些问题用于建立 correctness argument；本指南不规定文件命名或 rename protocol。

### 5.4 Timeout、failure suspicion 与 retry

课堂区分 paper 的 laggard backup task 与 Lab 的统一 timeout/reissue：Lab 将 crash 与 extremely slow worker 都视为“长时间未完成”。反思重点：

- Timeout 触发的是 suspicion 还是 failure fact？
- Reissue 后原 attempt 完成会发生什么？
- 完成通知可能 delayed、duplicate 或来自已过期 attempt 时，coordinator 如何解释？
- Timeout 太短/太长分别改变 correctness、traffic 还是 completion latency？

### 5.5 Local concurrency 与 distributed communication

`Mutex`、condition variable 和 Go channel 只协调单 process 内 goroutines；跨 worker/coordinator boundary 仍是 RPC。课堂反复强调：

- shared mutable state 的读写都需要与同一 synchronization discipline 一致；
- 不要持有 control-state lock 跨越可能阻塞的 RPC/channel operation；
- unlock 与下一次 lock 之间 assumptions 可能失效；
- race detector 无报告不等于 distributed protocol 正确，报告 race 也不直接说明业务 invariant 是什么。

### 5.6 Control plane 与 data plane

Coordinator 若读取所有 data、sorting 或执行 Map/Reduce，会成为 bottleneck。课堂把“能通过 tests”与“职责清楚、可扩展”分开。反思时可问：某项工作是否必须由 central coordinator 知道，还是 worker/local file 已有足够信息？

## 6. Lab 反思记录模板

对一个最值得提问的现象，先完成下表：

| 项目 | 你的记录 |
| --- | --- |
| Test / scenario | 哪个 test、worker 数、发生了什么 crash/delay？ |
| Expected invariant | 你认为必须始终成立的 phase/task/file/state 条件是什么？ |
| First divergence | Trace 中最早偏离 expectation 的事件是什么？ |
| Relevant owner | Coordinator state、worker attempt、RPC 还是 file publication？ |
| Timing evidence | Timeout 前后、completion/rename/RPC 的顺序是什么？ |
| Concurrency evidence | 哪些 goroutines/processes 同时访问相关 state？ |
| Hypothesis A | 可被什么 trace 推翻？ |
| Hypothesis B | 可被什么 trace 推翻？ |
| Remaining uncertainty | 课堂最需要澄清的 mechanism/tradeoff 是什么？ |

这张表不要求放进提交内容。它的作用是把“我不懂”压缩成一个他人能回答、你也能验证的问题。

## 7. 诊断 prompts（10 项）

以下 prompts 只要求描述 evidence 与 invariant，不要求给出实现修复。

1. **Phase boundary：** 给出一次 Map phase 到 Reduce phase 的 transition trace。哪一个 event 证明“所有 Map tasks completed”，而不只是 assigned？如果证据不足，你会记录什么？
2. **Task identity：** 同一 logical task timeout 后出现两个 attempts。你的 trace 如何区分它们？Coordinator 收到迟到 completion 时，哪些 state facts 必须重新核对？
3. **File visibility：** 选择一个 intermediate 或 final output。列出 create、write、close、rename、completion report 和 reader open 的顺序；在哪个点结果才应被视为 published？
4. **Waiting predicate：** 当 worker 请求 task 而 coordinator 暂时无合法 task 可发时，写出 coordinator 正在等待的 predicate，以及 completion/timeout 如何使它改变。你的设计可能发生 lost wakeup 或永不重查 timeout 吗？
5. **RPC surface：** 列出一次完成 task 所需的 RPC round trips。是否有两个 calls 只是先问“有没有”再问“给我”？若保留它们，各自携带了什么不可合并的语义？
6. **Lock boundary：** 找一个会 block 的 RPC、channel send 或 file operation。若它在持 coordinator lock 时等待，另一个需要该 lock 的 goroutine 能否产生解除等待所需的 event？
7. **Race evidence：** 对一个共享字段列出所有 readers/writers。Race detector 的结果能证明什么、不能证明什么？多个字段共同构成 invariant 时，单独无锁读取可能拼出什么不存在的 state？
8. **Timeout interpretation：** 一个 task 超过 10 秒。列出 worker crashed、worker slow、completion reply lost 三种解释；你的现有 logs 能排除哪一种？Reissue 是对哪种共同症状作出的动作？
9. **Coordinator bottleneck：** 选择 coordinator 的一项工作，估算其数据量或调用频率。它是 scheduling metadata 还是 worker data processing？规模增加时哪个 resource 先成为 central bottleneck？
10. **Test-to-question：** 选一个曾经失败或偶发通过的 test，写出最小 scenario、两个 competing hypotheses 与一条 counter-evidence；最后把它压缩成不索取代码的课堂问题。

## 8. 可提交问题的自检

提交前逐项确认：

- [ ] 问题与刚提交的 Lab 1 明确相关。
- [ ] 我写了一个具体 scenario/observation，而不是只有情绪或结果。
- [ ] 我区分了 official handout requirement、课堂示例与自己的 design choice。
- [ ] 我没有要求完整实现、代码片段或 test answer。
- [ ] 我指出了至少一个 invariant、mechanism 或 tradeoff。
- [ ] 若涉及 timing，我没有把 timeout 当成 crash proof。
- [ ] 若涉及 concurrency，我区分了本地 lock/channel 与跨 process RPC。
- [ ] 若涉及 files，我说明了 publication 与 completion 的顺序疑问。
- [ ] 问题足够窄，课堂能在几分钟内解释或指出验证方法。
- [ ] 原文 Question 要求的是提交自己的问题；我的提交确实是 question，而不是 Lab 总结。

## 9. 课堂连接摘要

[Lecture 6 NOTES](/courses/mit-6824-s21/lectures/006/) 的价值不在于提供“老师版本”，而在于展示设计审查顺序：先 RPC contract，再 coordinator state，再 worker/file flow，最后检查 waiting、timeout、locks 与 failure。课堂还保留了重要的不确定性：channel 草图不完整、某些 timer 数字未确认、interface/fairness 问题没有通用答案。你的问题若正好落在这些边界，应明确说出 assumptions，而不要把课堂即时回答提升为 specification。
