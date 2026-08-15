---
uid: mit-6824-s21-resource-reading-1
type: course
document_type: resource
resource_kind: reading
resource_order: 101
course: mit-6824-s21
title: Lecture 1 阅读与作业指南：MapReduce
description: Lecture 1 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 1 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-01/"
toc: true
official_lecture_number: 1
math: true
---

## 1. 来源、指定范围与证据边界

- 指定阅读：**MapReduce: Simplified Data Processing on Large Clusters**（Dean and Ghemawat, OSDI 2004）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- 本讲官方 schedule **没有 Paper Question / Homework**；不要把下面的自学题误当作官方提交题。
- 本讲没有单独归档 FAQ；“FAQ 要点”一节只整理论文自身最容易误读的边界。
- 技术事实以归档论文为准；课堂 `NOTES.md` 只用于最后的“课堂连接”。

资源：

- [MapReduce 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/mapreduce.pdf)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/)
- [Lecture 1 NOTES](/courses/mit-6824-s21/lectures/001/)

## 2. 阅读目的

阅读时不要只记住 `Map` 和 `Reduce` 两个函数。论文真正要回答的是：**怎样用一个受限 programming model，把 parallelization、partitioning、scheduling、failure recovery、communication 和 load balancing 从 application programmer 手中移到 runtime system 中？**

建议形成三条主线：

1. **Abstraction**：用户只提供 `Map`、`Reduce` 以及少量配置，framework 获得自动并行化所需的结构。
2. **Correctness under re-execution**：worker failure、timeout 和 straggler 会制造重复执行；determinism 与 atomic publication 使重复尝试不破坏最终结果。
3. **Performance from placement and redundancy**：data locality、task granularity、Combiner 和 backup tasks 分别处理 network、load balance 和 tail completion time。

## 3. 问题、模型与假设

### 3.1 问题

Google 的许多数据处理任务本身很直接，例如 inverted index、word count、distributed grep 和 sort；困难来自数据量必须由数百或数千台机器共同处理。若每个 application 都自行实现分片、通信、调度和 failure handling，业务逻辑会被大量 distributed-systems code 淹没。

### 3.2 Programming model

用户提供：

```text
Map(k1, v1) -> list(k2, v2)
Reduce(k2, list(v2)) -> list(v2)
```

Runtime 把所有相同 intermediate key 的 values 分组后交给同一个 `Reduce` invocation。Intermediate values 以 iterator 提供，因此不要求整个 value list 同时放入 memory。

### 3.3 实现环境假设

论文实现面向由 commodity PCs、local IDE disks 和 switched Ethernet 组成的大 cluster：

- machine failure 是常见事件；
- network bisection bandwidth 相对稀缺；
- input/output 由 distributed file system 管理；
- input 可分成许多独立 splits；
- 大多数用户 `Map`/`Reduce` 是 input 的 deterministic functions。

这些假设不是 MapReduce API 的普遍定律。论文明确说，不同 hardware/environment 可以有不同实现。

## 4. Architecture 与执行机制

### 4.1 Roles 和 dataflow

```text
user program
  -> one master + many workers
  -> M map tasks read input splits
  -> each map worker partitions intermediate data into R local regions
  -> reduce workers remotely fetch their region from every map worker
  -> sort/group by intermediate key
  -> R reduce tasks publish R final output files
```

- **Master**：维护每个 task 的 `idle / in-progress / completed` 状态、worker identity，以及每个 completed map task 的 `R` 个 intermediate regions 的 location/size。
- **Map worker**：读取一个 input split，运行 user `Map`，按 partition function 将 buffered pairs 写入 local disk。
- **Reduce worker**：从 map workers 远程读取对应 partition，执行 sort/group，再调用 user `Reduce`。
- **Barrier**：论文的基本执行流程先完成 map tasks，再完成 reduce tasks；shuffle 的数据传输可在 map outputs 出现后展开。

### 4.2 Partitioning、ordering 与 Combiner

- 默认 partition function 类似 `hash(key) mod R`；用户可按 hostname 等 application structure 自定义。
- 每个 partition 内按 intermediate key 的递增顺序处理，便于生成分区内有序结果。
- 当 `Reduce` operation 适合局部合并时，可在 map machine 上运行 optional `Combiner`，减少经 network 发送的重复 intermediate records。
- `Combiner` 的适用性不是自动成立的；论文以 word count 这类 partial sum 为典型场景。

### 4.3 Locality 与 task granularity

- Master 尽量把 map task 放到持有 input replica 的 machine；否则放到同一 network switch 附近。
- `M`、`R` 通常远大于 worker 数，以改善 dynamic load balancing 和 failure recovery。
- 代价是 master 要做 $O(M+R)$ scheduling decisions，并保存 $O(MR)$ 的 map/reduce pair state；`R` 还决定 final output file 数。

### 4.4 Refinements

论文还提供 input/output types、atomic/idempotent side-effect guidance、bad-record skipping、local sequential execution、status pages 和 counters。这些不是核心 `Map`/`Reduce` interface 的装饰，而是让系统可调试、可观察、可运营的工程机制。

## 5. Correctness、failure 与 semantics 推理

### 5.1 Worker failure 为什么触发 re-execution

- Master periodic ping 无响应后，把 in-progress task 重新设为 `idle`。
- Failed worker 上已经完成的 **map task** 也要重跑，因为 intermediate output 在该 worker 的 local disk 上。
- 已完成的 **reduce task** 不必因 worker failure 重跑，因为 output 已在 global file system 中。

Timeout 只驱动 recovery，不证明旧 attempt 已停止，因此同一 task 可能执行多次。

### 5.2 Deterministic functions 的语义

若 user `Map` 和 `Reduce` 都是 deterministic functions of inputs，distributed execution 的 output 与一个 non-faulting sequential execution 相同。推理链是：

1. 同一 task 的 attempts 对同一 input 产生同一内容；
2. map completion 由 master 只接受一个 location set；
3. reduce attempt 先写 private temporary file；
4. final output 通过 underlying file system 的 atomic rename 发布；
5. 即使多个 reduce attempts rename 到同一 final name，最终只出现某一个完整、且逻辑相同的结果。

### 5.3 Non-deterministic operators 的较弱语义

若 operator non-deterministic，每个 reduce partition 的 committed output 仍可对应某次 sequential execution；但不同 partitions 可能读取同一 map task 的不同 executions，因此不保证所有 partitions 共同对应同一个 sequential execution。

### 5.4 Side effects 和 master failure 边界

- Auxiliary side effects 由 application writer 保证 atomic、idempotent，常用 temporary file + atomic rename。
- Framework 不提供一个 task 多个 output files 之间的 atomic two-phase commit。
- 论文实现的 single master failure 会 abort 当前 MapReduce job；checkpoint/restart 被描述为可做，但当时实现选择由 client retry whole job。

## 6. Performance 与 evaluation

以下数字只描述论文归档中的 2004 实验环境，不应外推到现代 hardware：

- 实验 cluster 约 `1800` machines。
- Grep 扫描约 `1 TB` 数据，峰值 input scan rate 超过 `30 GB/s`，全程约 `150 s`，其中约一分钟是 startup overhead。
- Sort 约 `1 TB` 数据，normal execution 为 `891 s`。
- 禁用 backup tasks 后 sort 为 `1283 s`，elapsed time 增加 `44%`；长尾由少数 stragglers 造成。
- 故意杀死 `1746` 个 workers 中的 `200` 个后，sort 为 `933 s`，相对 normal execution 增加约 `5%`。
- Backup tasks 通常只增加几个百分点的 resource use，却显著压缩 job 尾部时间。

读 evaluation 时应区分：

- **locality** 提高 input rate，因为大部分 input 不过 network；
- **shuffle** 仍需 network；
- **replicated final output** 使 output path 比单副本更昂贵；
- **backup tasks** 优化 completion time，不是 correctness proof。

## 7. 设计权衡与限制

| 选择 | 收益 | 代价/边界 |
| --- | --- | --- |
| 受限 functional model | 自动 parallelization 与 re-execution | 不适合任意 communication pattern 或 mutable shared state |
| Single master | scheduling 与 metadata 简单 | master failure aborts job；master state 随 $M,R$ 增长 |
| Map intermediate data 放 local disk | 避免写 global file system | worker failure 后 completed map 仍需重跑 |
| Large number of fine-grained tasks | load balance、快速分摊 recovery | scheduling 和 metadata overhead |
| Data locality | 节省 scarce network bandwidth | shuffle/output 仍可能跨网 |
| Backup tasks | 降低 straggler tail | 重复消耗 compute resources |
| Skipping bad records | 在确定性 crash record 上继续进展 | 明确丢弃 input，改变完整处理语义 |

## 8. Paper Question / Homework

**官方状态（原意照录）**：官方 schedule 未为 Lecture 1 列出 Paper Question。

因此本讲没有可“精确抄录”的官方题目，也没有应提交的官方答案。可用以下 prompts 自测，不要把它们标成 MIT official Question：

1. 从一次 worker timeout 开始，画出 duplicate map/reduce attempts，并标明 determinism 与 atomic rename 各解决哪一部分问题。
2. 对 word count 与 distributed sort，分别画出 input、local intermediate data、shuffle 和 final output；指出 network-heavy boundary。
3. 解释为何 completed map task 在 worker failure 后要重跑，而 completed reduce task 通常不用。
4. 构造一个不满足 deterministic assumption 的 `Map` 或 `Reduce`，说明为什么不同 reduce partitions 可能不再对应同一 sequential execution。
5. 说明 backup tasks 为什么属于 performance mechanism，而不是 failure semantics。

推理脚手架：先写明 system assumption，再画 normal path；随后只改变一个 failure/event；列出 runtime 可观察的状态；最后分别检查 safety（结果是否可解释）与 liveness/performance（能否完成、多久完成）。

## 9. FAQ 要点

本讲没有独立归档 FAQ。以下是论文自身最常见的误读边界：

- `Map`/`Reduce` 的独立性不等于整个 job 无通信；shuffle 是显式的 all-mappers-to-reducers data movement。
- Re-execution 不等于 exactly-once execution；论文依赖 deterministic output 和 atomic commit 获得稳定 final result。
- Atomic rename 只保证发布一个完整 file，不会把 non-deterministic attempts 自动变成相同结果。
- Intermediate data 不都在 GFS：map outputs 位于 worker local disks，reduce outputs 位于 global file system。
- Single master 不是论文实现中自动 failover 的 replicated service。
- `Combiner` 不是无条件可插入的优化；必须保持 application computation 的含义。

## 10. 课堂讨论如何改变阅读重心

[Lecture 1 NOTES](/courses/mit-6824-s21/lectures/001/) 没把 MapReduce 当作孤立 batch API，而是把它放进全课 recurring themes：

- `network-only interaction` 造成 partial failure 与 failure ambiguity；timeout 后的 duplicate attempt 是这一抽象问题的第一个具体实例。
- 课堂先区分 availability、recoverability、consistency、throughput、latency 与 tail latency，再用 MapReduce 对应这些目标。
- `Lab 1` 把学生从 application programmer 移到 library implementer：被 abstraction 隐藏的 scheduling、retry、data movement 与 worker lifecycle 都重新成为自己的责任。
- 课堂特别强调 replication 与 sharding 的目标不同，也强调 backup task 复制的是 computation attempt，主要处理 straggler。
- 论文中的 implementation 细节应回扣“用受限 model 换取 distribution hiding”这一主 tradeoff。

## 11. 论文理解题（10 题）

1. **`Map` 与 `Reduce` 之间由 framework 补上的关键步骤是什么？**  答案点：partition、shuffle、sort/group，相同 intermediate key 的 values 汇合。
2. **为什么 intermediate values 使用 iterator？**  答案点：允许 value list 大于 memory。
3. **Master 为每个 task 保存什么最小状态？**  答案点：`idle/in-progress/completed`；非 idle task 的 worker；completed map 的 region locations/sizes。
4. **为什么 map output 放 local disk 仍然合理？**  答案点：它是 temporary data；减少 global storage/network cost；failure 可由 re-execution 恢复。
5. **`R` 同时影响哪些外部结果和内部成本？**  答案点：reduce tasks/final files 数、partitioning、master 的 $O(MR)$ state。
6. **Determinism 与 atomic rename 分别保证什么？**  答案点：attempt 内容等价；final name 只暴露一个完整 attempt。
7. **Non-deterministic operators 的保证为什么按 reduce partition 变弱？**  答案点：不同 reducers 可能读取同一 map task 的不同 attempts。
8. **Data locality 优化了哪段路径？**  答案点：GFS input 到 map worker；不消除 shuffle 和 final output traffic。
9. **Backup task 为什么通常在 job 接近结束时启动？**  答案点：集中处理少数 stragglers；限制额外 resource use。
10. **论文为何把 restricted model 视为优势而非纯限制？**  答案点：runtime 可据此自动 partition、schedule、retry 并提供清晰 semantics。

## 12. 复习清单

- [ ] 能从 types 写出 `Map`/`Reduce` interface，并手算 word count。
- [ ] 能画出 master、map workers、reduce workers、GFS 与 local disks。
- [ ] 能标出 input、intermediate、shuffle 与 output 的 storage/network path。
- [ ] 能从 timeout 推导 duplicate execution，而不是假设 exactly once。
- [ ] 能解释 deterministic 与 non-deterministic semantics 的差别。
- [ ] 能说明 atomic rename 能保证什么、不能保证什么。
- [ ] 能比较 locality、Combiner、task granularity 与 backup tasks 的优化目标。
- [ ] 能复述论文 evaluation 的主要数字并注明历史环境边界。
- [ ] 能说明 master failure 与 multi-file side effects 的明确限制。
- [ ] 能把 MapReduce 的核心 tradeoff 说成“限制 programming model，换取 distribution hiding”。
