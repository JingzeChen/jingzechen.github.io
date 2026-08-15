---
uid: mit-6824-s21-resource-reading-2
type: course
document_type: resource
resource_kind: reading
resource_order: 102
course: mit-6824-s21
title: Lecture 2 阅读与作业指南：Go Tutorial、Concurrency 与 RPC 准备
description: Lecture 2 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 2 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-02/"
toc: true
official_lecture_number: 2
---

## 1. 来源、指定范围与证据边界

- 指定 preparation：**Online Go tutorial**。
- 指定范围：官方 Question 指向 tutorial 中的 **Crawler exercise**，并要求看一看 Go 的 **RPC package**。
- **External-only boundary**：tutorial 只有外部 URL，没有本地归档正文。本指南不复述、猜测或补造 tutorial 的页面、starter code、API 顺序或标准答案。
- 可归档核验的阅读内容只有本讲 `Go FAQ` 与官方 Question；核心事实以它们为准。
- 课堂 `NOTES.md` 只用于“课堂连接”，不反向冒充 tutorial 内容。

资源：

- [Online Go tutorial（外部）](https://tour.golang.org/)
- [归档 Go FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/tour-faq.txt)
- [官方 Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/02-q-gointro.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/)
- [Lecture 2 NOTES](/courses/mit-6824-s21/lectures/002/)

## 2. 阅读目的

本讲 preparation 不是 paper reading，而是为 Lab 1 和后续 distributed programming 建立语言工具。阅读目标应分为三层：

1. **Execution model**：goroutine 如何并发/并行运行，main/function lifecycle 为什么需要显式 coordination。
2. **Synchronization choices**：channels、`sync.Mutex`、`sync.Cond`、`sync.WaitGroup` 各适合表达什么关系，错误 protocol 如何 deadlock 或 leak。
3. **Process boundary**：channel 只在同一 program 内工作；跨 process/computer communication 要使用 RPC 等网络机制。

因为 tutorial 正文未归档，完成 Crawler exercise 时必须以外部页面当时显示的要求为准；本指南只提供审题与验证框架，不提供 exercise submission。

## 3. 问题、模型与假设

### 3.1 为什么课程选 Go

归档 FAQ 给出的理由是：Go 是 type-safe、garbage-collected，支持 goroutines，并有适合课程 labs 的 RPC package。Garbage collection 减少了多 threads 共享 object 时判断最后引用与释放时机的负担。

### 3.2 Goroutine model

- FAQ 把 goroutines 类比为其他语言中的 threads。
- Go runtime 可在所有 available cores 上并行运行 goroutines；若 runnable goroutines 多于 cores，则进行 pre-emptive time-sharing。
- Goroutine 不是进程间 communication primitive；Go channel 只能连接同一 program 内的 goroutines。
- Program 的 main execution 结束时，其他 goroutines 不会保证继续完成；FAQ 明确引用 language spec 的 `Program execution` 边界。

### 3.3 Shared-state 与 communication 假设

- Concurrent access 的 `map` 必须受 lock 保护；FAQ 建议用 race detector 捕获此类错误。
- Channel 自身 synchronized，不等于使用它的 protocol 自动正确；没有 receiver 的 synchronous send 可能 block。
- 带 `Mutex` 的 struct 不应使用会复制 mutex 的 value receiver。

## 4. Preparation resource 中可核验的 Architecture 与机制

由于 tutorial external-only，以下只整理归档 FAQ 明说的 high-level mechanisms。

### 4.1 Channel

FAQ 的 high-level model 是：channel 内部有 buffer 与 lock。Send/receive 都要取得 lock，并可能等待另一端；等待期间 goroutine 可以让出 CPU。它还指出，可以用 `sync.Mutex` 和 `sync.Cond` 自行实现类似协调。

这不是 Go runtime source 的完整实现规范，只是 FAQ 的概念模型。

### 4.2 `sync.Cond`

若一个 goroutine 只是想“提醒另一个 goroutine 某个 condition 可能变化”，而对方未必正在 receive，FAQ 建议考虑 condition variable。原因是 synchronous channel 在没有 receiver 时会让 sender block，而 condition variable 更适合可能有、也可能没有 waiter 的通知场景。

### 4.3 `select` 与 per-channel goroutine

等待多个 channels 时，FAQ 给出两种方向：

- 为每个 channel 建立一个独立 goroutine，让它各自 block；
- 使用 Go `select`。

是否适用取决于 program structure，FAQ 没有声称第一种方案总能使用。

### 4.4 `sync.WaitGroup`

`WaitGroup` 是专用于等待一组 activities 完成的 primitive。Channel 更 general-purpose，可传 values，也可用来等待多个 goroutines，但通常需要更多 code。

### 4.5 RPC package

FAQ 只确认：channel 不能跨 program/computer，Go 的 RPC package 用于和其他 Go programs 经网络通信。关于 package 的具体 API、retry 或 wire semantics，必须查外部 package documentation；归档 preparation 没有足够正文支持在此补写。

### 4.6 Synchronous 与 asynchronous RPC 的组织

FAQ 的建议是：多数 code 要等 reply 才能继续，适合 synchronous RPC；若要并发发起多个 RPC，或等待期间做其他工作，可以另起 goroutine 调用 synchronous `Call()`。FAQ 作者说明自己未使用 Go 的 async RPC API，而偏好这一组织方式。

## 5. Correctness、failure 与 synchronization 推理

### 5.1 Crawler exercise 的 reasoning invariants

不依赖 starter code，也可以先写出检查项：

- **Coverage**：从起始输入可达的 work 是否都会被发现和处理？
- **No unintended duplication**：同一 logical item 是否会因并发 check/update 分离而重复处理？
- **Termination**：main/coordinator 怎样知道没有 in-flight work，也不会再产生新 work？
- **No blocked leftovers**：停止接收后，producer goroutines 是否可能永远卡在 send？
- **Race freedom**：所有 shared mutable state 是否有明确 owner 或同一 lock convention？

这些是通用推理框架，不是 tutorial exercise 的隐藏实现答案。

### 5.2 常见 correctness failures

归档 FAQ 明列了初学 Go 时的典型问题：

- concurrent `map` access 未加 lock；
- channel deadlock；
- 创建 goroutine 时没有正确 capture variable；
- goroutine leak；
- main 结束导致 goroutine 未完成；
- 复制含 mutex 的 receiver。

### 5.3 RPC failure 边界

归档 FAQ 只讨论同步/异步等待方式，没有给出 network failure semantics。因此本指南不会从 preparation source 声称 at-most-once、at-least-once 或 exactly-once。课堂如何补上这一层，见第 10 节。

## 6. Performance 与 evaluation 边界

本讲没有归档 benchmark。FAQ 只有一个 capacity-planning 直觉例子：

- 若目标是 CPU parallelism、machine 有 `16` cores，可先考虑约 `16` 个 executable goroutines；
- 若一次 fetch 约 `0.1 s`，network capacity 约 `100 pages/s`，大约需要 `10` 个 concurrent fetches 才能占满 network；
- 实际上应逐步增加 goroutines，观察 throughput 何时不再增长。

这些是说明“并发度依 workload bottleneck 而定”的示例，不是 Crawler exercise 的规定参数，也不是可泛化的性能结论。

## 7. 设计权衡与限制

| 选择 | 适合的意图 | 风险/限制 |
| --- | --- | --- |
| Goroutine per activity | 重叠 I/O、利用多 cores | stack/调度仍有成本；必须管理 termination |
| Channel | 传 values、同步 sender/receiver | synchronous send/receive 可 deadlock；只在一个 program 内 |
| `sync.Cond` | state change notification | 必须围绕 shared predicate 与 lock 正确组织 |
| `WaitGroup` | 等待一组 work 完成 | 不负责传 value，也不定义 work discovery protocol |
| Shared `map` + `Mutex` | 直接维护共享 state | 每条访问路径都要遵守同一 lock convention |
| Goroutine + synchronous RPC | 并发发起 calls，保留简单 call model | goroutine lifecycle 与结果汇总仍由 application 管理 |

## 8. 官方 Question / Homework

**Assigned Question（原文）**：

> The assigned reading for today is not a paper, but the Online Go tutorial . The assigned "question" is the Crawler exercise in the tutorial. Also, take a look at Go's RPC package , which you will use in lab 1.

### 推理脚手架（不是提交答案）

1. 先从外部 tutorial 抄下 exercise 当时显示的输入、输出与 completion conditions；本地 archive 没有这些正文，不能凭记忆补齐。
2. 对每个 shared state 写 owner：单 goroutine 独占，还是多个 goroutines 通过同一 lock 访问。
3. 把“发现新 work”“启动 work”“work 完成”“全局结束”画成状态转移，检查计数是否可能过早归零。
4. 写两个 adversarial schedules：两个 goroutines 同时发现同一 item；main 停止接收时仍有 producer 准备 send。
5. 用 race detector、重复输入、cycle、slow operation 和 early-return 场景验证 invariants。
6. 阅读 RPC package 时只记录公开 interface 和 error surface；不要把 local function call 的直觉自动等同于 network call。

这份 scaffold 有意不提供 Crawler implementation、代码片段或 exercise 的最终输出。

## 9. FAQ 要点

- Go 适合 6.824 的主要原因是 goroutines、RPC、type safety 与 garbage collection；不是唯一可行语言。
- Goroutines 可并行，也会在 runnable 数超过 cores 时 time-share。
- Channel 是同步 primitive；“thread-safe channel”不保证使用 protocol 不会 block。
- 不确定 receiver 是否等待时，可考虑 `sync.Cond`，而不是用 dummy channel send 强行唤醒。
- 等待多个 channels 可考虑多个 blocking goroutines 或 `select`。
- `WaitGroup` 针对 completion；channel 更 general-purpose。
- Channel 不能跨 process/computer；跨边界需 RPC。
- 并发度应由 CPU、I/O latency、network capacity 和实测 throughput 决定。
- Slice 共享 underlying array；array size 是 type 的一部分，FAQ 作者通常使用 slices 而非 arrays。
- 修改 receiver state 或避免复制大 struct 时使用 pointer receiver；含 mutex 的 struct 不能因 value receiver 而复制 mutex。

## 10. 课堂讨论如何连接并改变重心

[Lecture 2 NOTES](/courses/mit-6824-s21/lectures/002/) 把 tutorial preparation 扩展成两条系统主线：

- **Crawler 不只是 syntax exercise**：课堂用 serial、Mutex + `WaitGroup`、coordinator + channel 三种结构对比 atomic check-and-mark、state ownership、slow I/O 外移和 termination accounting。
- **Synchronization 要围绕 invariant**：`Mutex` 不会自动绑定 data；`sync.Cond.Wait()` 要和 predicate loop 及 associated lock 一起理解；channel protocol 仍可能 deadlock/leak。
- **RPC 只隐藏 marshalling，不隐藏 failure**：课堂进一步区分 `Call()` error 与 service reply，并讨论 timeout 后 request 是否执行的 ambiguity，以及 at-least-once、at-most-once、exactly-once 的成本。
- **Lab connection**：single coordinator 可串行管理 metadata，而 workers 并行执行昂贵 I/O；这一结构直接连接 Lab 1。

这些是课堂对 preparation 的深化，不是 external tutorial 的归档内容。

## 11. 理解题（10 题）

1. **Goroutine 与 OS process 在本讲 source 中最重要的边界是什么？**  答案点：goroutines 在同一 program 内；channel 不能跨 program/computer。
2. **Runnable goroutines 多于 cores 时会怎样？**  答案点：runtime pre-emptively time-shares cores。
3. **为什么 dummy channel wake-up 可能 block sender？**  答案点：synchronous channel 当时可能没有 receiver。
4. **`sync.Cond` 比 dummy send 更适合表达什么？**  答案点：某个 state condition 变化、waiter 可能存在也可能不存在的通知。
5. **`WaitGroup` 与 channel 的职责差别是什么？**  答案点：前者专门等一组 activities 完成；后者可传值且用途更广。
6. **等待多个 channels 有哪两种 FAQ 建议？**  答案点：per-channel blocking goroutine；`select`。
7. **为什么并发访问 Go `map` 要特别检查？**  答案点：需要 lock；race detector 可帮助发现遗漏。
8. **为什么含 mutex 的 struct 不应使用 value receiver？**  答案点：receiver copy 会复制 mutex，破坏共同保护目的。
9. **FAQ 怎样建议组织“异步效果”的 RPC？**  答案点：另起 goroutine 执行 synchronous `Call()`。
10. **怎样判断 goroutine 数量已经足够？**  答案点：按 bottleneck 估算并逐步增加，直到 throughput 不再提升。

## 12. 复习清单

- [ ] 已实际打开 external tutorial，并确认 Crawler exercise 当前要求。
- [ ] 能解释 goroutine 的 parallelism、time-sharing 与 main-exit boundary。
- [ ] 能区分 channel、`Mutex`、`Cond`、`WaitGroup` 的意图。
- [ ] 能为 shared mutable state 指出 owner 或 lock。
- [ ] 能构造 channel deadlock 与 goroutine leak 场景。
- [ ] 能解释 loop/closure capture 为什么要检查。
- [ ] 能解释 channel 为什么不能代替 network RPC。
- [ ] 已查看 Go RPC package 的公开 interface，而未臆测 archive 中不存在的内容。
- [ ] 能为 Crawler 写出 coverage、deduplication、termination、race-free invariants。
- [ ] 能说明课堂如何从语言工具推进到 RPC failure ambiguity。
