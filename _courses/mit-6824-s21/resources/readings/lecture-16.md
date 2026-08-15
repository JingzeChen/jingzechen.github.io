---
uid: mit-6824-s21-resource-reading-16
type: course
document_type: resource
resource_kind: reading
resource_order: 116
course: mit-6824-s21
title: Lecture 16 阅读指南：Big Data - Spark
description: Lecture 16 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 16 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-16/"
toc: true
official_lecture_number: 16
---

## 1. 来源、范围与证据边界

- 指定阅读是完整的 **Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing (NSDI 2012)**；课程材料没有缩小 paper section 范围。
- 本指南以归档论文为 RDD model、execution、fault tolerance 与 evaluation 的主来源；FAQ 用于澄清 MapReduce、immutability、lineage、Scala 与 hash partitioning；课堂连接以 `l-spark.txt` 和本地 transcript 为证据。
- 本讲已有完整聚合 `NOTES.md`；课堂 chronology 以该讲义、官方 lecture notes 和 transcript 交叉核对，不能用论文结构替代老师实际讲授顺序。
- 论文描述 2012 年 Spark/RDD implementation。FAQ 明确指出现代 Spark 更偏向 DataFrames；本文仍按 assigned paper 学 RDD 的设计思想，不把后来的 API/engine 行为反写进论文。
- 论文的性能数字来自指定 EC2 cluster、datasets 和 applications；“up to” 结果必须保留 workload 与 configuration，不能写成 Spark 对所有 Hadoop jobs 都有固定倍数优势。

资源：

- [Lecture 16 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-16.md)
- [Spark 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/zaharia-spark.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/spark-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/16-q-spark.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-spark.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-16-big-data---spark)
- [Lecture 16 transcript](/assets/courses/mit-6824-s21/lectures/017/transcript.txt)
- [Lecture 16 课堂笔记](/courses/mit-6824-s21/lectures/017/)
- [Lecture 16 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=17)

## 2. 论文要解决的缺口

MapReduce/Dryad 已能分配 cluster work 并在 task failure 后重跑，但跨多次 computations 复用 intermediate data 时，通常要把结果写到 replicated distributed file system，再由下一 job 读取。这引入：

- data replication；
- disk/network I/O；
- serialization/deserialization；
- 每轮 job setup 与 scheduling overhead。

这对两类 workload 尤其昂贵：

1. **Iterative algorithms**：PageRank、k-means、logistic regression 等反复在同一 working set 上迭代。
2. **Interactive data mining**：用户对同一 filtered subset 连续运行 ad-hoc queries。

论文不是只加一个 cache，而是提出可由 program 显式复用、控制 partitioning、并能从 derivation 重建的 distributed-memory abstraction：RDD。

## 3. RDD 模型与核心不变量

### 3.1 定义

RDD 是 **read-only、partitioned collection of records**。它只能由以下来源通过 deterministic operations 创建：

1. stable storage 中的数据；
2. 其他 RDDs。

这些创建新 RDD 的操作称为 **transformations**，例如 `map`、`filter`、`join`。会把 value 返回 application 或写到外部 storage 的操作称为 **actions**，例如 `count`、`collect`、`save`。

### 3.2 Reconstruction invariant

RDD 不必始终 materialized，但必须保存足够 metadata，使每个 partition 可从 stable data 或 parent RDD partitions 重算。论文的关键约束可写成：

```text
program can reference RDD r
  -> r has partitions + dependencies + compute function
  -> every lost partition of r has a reconstruction path
```

这个 invariant 让系统记录 **lineage/recipe**，而不是复制每个 intermediate result 或记录每个 fine-grained update。

### 3.3 Immutability 与 consistency 边界

- Transformation 不会原地修改 parent；它描述一个新 RDD。循环的每一轮也产生新的 `ranks`/`contribs` RDD，所以 lineage 是 DAG，不是 mutation cycle。
- Read-only state 消除了 shared mutable cells 的 concurrent-write consistency protocol：没有“两个 writers 同时覆盖同一 RDD partition”的状态。
- Deterministic transformations 使 failure 后重算得到同一 logical data；若 user function 引入未记录的 nondeterminism，lineage 不能自动保证 bit-for-bit replay。
- 这不是 database ACID、linearizability 或 transaction isolation。RDD 用 coarse-grained functional updates 换取便宜 recovery；它不提供 web storage service 所需的 asynchronous fine-grained mutable state。

### 3.4 用户可控制的两项策略

- **Persistence**：用户用 `persist`/`cache` 指示哪些 RDD partitions 值得跨 actions/iterations 保留；可选 memory、serialized memory、disk 或 replication 等策略。
- **Partitioning**：用户可按 key 控制 partitioner，使后续 `join`/`reduceByKey` 避免不必要 shuffle，并把 computation 放到 data 附近。

## 4. Lazy programming model

Transformations 是 lazy 的：调用它们主要扩展 lineage graph，不立即扫描全量数据。Action 才触发 scheduler 从 target RDD 反向分析 dependencies 并执行缺失 partitions。

以课堂 PageRank 主线为例：

```text
HDFS links
  -> parse/distinct/groupByKey
  -> cache link lists
  -> initialize ranks
  -> repeated join/contribution/reduceByKey
  -> collect final ranks  # action triggers execution
```

`cache` 本身只声明未来 materialization 的 persistence policy；第一次 action 计算到该 RDD 时才产生 partitions。若不 cache，每轮 action 可能按 lineage 回到 input 重算 links。

Actions 和 transformations 的区分带来两项能力：

1. Scheduler 能看见完整 dataflow，再决定 pipelining、stages 和 placement。
2. User 可以用 language-integrated operators 组合多步 computation，而不必手工拆成多个 MapReduce jobs 和中间 files。

## 5. RDD representation 与 dependency types

论文的统一 RDD interface 暴露五类信息：

| Metadata/API | 作用 |
| --- | --- |
| `partitions()` | 返回 dataset 的 atomic partition units |
| `preferredLocations(p)` | 给 scheduler data-local placement hints |
| `dependencies()` | 描述 parent RDD relationships |
| `iterator(p, parentIters)` | 从 parents 计算 partition records |
| `partitioner()` | 描述 hash/range partitioning metadata |

### 5.1 Narrow dependency

每个 parent partition 最多被一个 child partition 使用。`map`、`filter` 与某些 `union` 是典型例子。

机制与收益：

- 可在同一 worker 上把多个 transformations pipeline 成一个 stage；
- records 可流过算子，不必在每一步 materialize 整个 partition；
- failure 通常只需重算 lost partitions，并能分散到其他 workers 并行执行。

### 5.2 Wide dependency

多个 child partitions 可能依赖同一个 parent partition，或一个 child 需要来自多 parent partitions 的 data。未 co-partition 的 `join`、`groupByKey`、`reduceByKey` 会形成 wide/shuffle dependency。

机制与代价：

- Upstream outputs 按 key/partitioner 分桶；
- downstream workers 从多个 upstream workers fetch buckets；
- wide edge 成为 stage boundary 和 barrier，带来 network shuffle 与 materialization；
- failure 可能丢失多个 ancestors 的 shuffle slices，导致比 narrow path 更广的 recomputation。

若两个 join parents 已用同一 partitioner，join 可变成 narrow dependencies；这说明 partitioning metadata 是 execution optimization 的一部分，不只是 storage 描述。

## 6. Execution strategy

### 6.1 Driver、workers 与 stages

- Driver 运行 user program、构建 lineage DAG，并在 action 时生成 stages/tasks。
- Workers 是 long-lived processes，可跨 operations 保存 persisted RDD partitions。
- Scheduler 尽量在同一 stage 内 pipeline narrow transformations；wide dependencies、已 materialized partitions 或 shuffle boundaries 切分 stages。
- 每个 stage 的 tasks 通常按 target partitions 划分；partition 数可多于 worker 数，以改善 load balance 与 failure redistribution。

### 6.2 Data locality 与 code shipping

Scheduler 优先把 task 放到已有 memory partition 的 node，其次使用 HDFS block 等 `preferredLocations`。Scala closures 被序列化并送到 workers；论文为 interactive interpreter 修改 class shipping 与 generated object references，使前几行定义的 variables/classes 也能随 closure 到 workers。

Scala 是实现选择，不是 RDD model 的逻辑必要条件。论文明确说 abstraction 不要求 functional language；FAQ 强调 JVM 对 closure serialization/code shipping 的支持是实际理由之一。

### 6.3 Memory management

Persistent RDDs 可存为 deserialized Java objects、serialized bytes 或 disk data：

- Deserialized objects 最快，但 memory footprint 可能大。
- Serialized form 省 memory，访问时多 conversion cost。
- Disk 适合太大而又昂贵到不应每次重算的数据。

论文实现按 RDD level 使用 LRU-like eviction，并允许 persistence priority。内存不足时 partitions 可 spill 到 disk；Figure 12 的 logistic-regression experiment 显示 performance 随 memory 减少而渐进退化，而不是宣称所有 workload 都同样 graceful。

## 7. Fault model 与 recovery mechanisms

### 7.1 Worker/task failure

若 task failure 而 parent stages 仍可用，scheduler 在另一 node 重跑 task。若 shuffle parent output 已丢失，则重新提交生成 missing partitions 的 tasks。由于 immutable partitions 不会被 backup task 的重复执行互相覆盖，系统也能像 MapReduce 一样用 speculative/backup tasks 缓解 stragglers。

### 7.2 Lineage recovery

RDD recovery 的单位是 partition，不是整台 machine memory snapshot：

```text
lost partition
  -> inspect lineage dependencies
  -> locate surviving/materialized parents or stable input
  -> re-run deterministic transformations
  -> reconstruct only required partition(s)
```

Narrow dependencies 通常只传播到对应 parent partitions；wide dependencies 可能让一次 loss 需要重建多处 shuffle inputs。因此 lineage metadata 虽小，recomputation cost 仍取决于 graph shape。

### 7.3 Checkpoint 与 replication

Lineage 理论上总能重算，但 long lineage 与 wide dependencies 可能让 recovery 太慢。论文因此允许把 selected RDDs checkpoint/replicate 到 stable storage：

- Long, wide lineage（例如 iterative PageRank ranks）更值得 periodic checkpoint。
- Narrow lineage 直接连 stable input（例如 logistic-regression points）往往只需并行重算 lost partitions，checkpoint 整个 RDD 反而昂贵。
- RDD immutable，因此 checkpoint 可在后台写出，不需要冻结 mutable shared state 或运行 distributed snapshot protocol。

Checkpoint 不是 lineage 的替代品，而是截短最坏 recomputation path 的选择。

### 7.4 未覆盖的 failure

2012 论文实现没有容忍 scheduler/driver failure；作者只说复制 RDD lineage graph 应该较直接。不能把 worker recovery 结果推广成完整 control-plane high availability guarantee。

## 8. Expressiveness 与不适用 workload

### 8.1 论文支持的模型

RDD 可表达 MapReduce、DryadLINQ、SQL-like bulk operations、Pregel、iterative MapReduce 和 batched stream processing。论文所谓“efficiently express”不仅是能算出相同 output，还包括保留 in-memory reuse、partitioning/locality 与 partial recovery 等优化。

它之所以能覆盖这些模型，是因为很多 parallel programs 本来就在大量 records 上应用同一 operation；immutable versions 也足以表示 iterative state evolution。

### 8.2 不适用边界

RDD 不适合 asynchronous fine-grained updates to shared state，例如 web application 的在线 mutable storage 或 incremental crawler。此类 workload 更适合 databases、RAMCloud、Percolator、Piccolo 等带 logging/checkpoint 与 mutable consistency machinery 的系统。

Spark/RDD 的主要优势也不适用于“只扫描一次再 aggregate”的简单 job：若 intermediate data 从不复用，execution 被 input I/O 主导，in-memory persistence 没有架构性收益。FAQ 明确说这种场景 MapReduce 仍完全合理。

## 9. Evaluation：机制是否兑现

### 9.1 Iterative machine learning

论文在 EC2 上对 100 GB data、10 iterations 的 logistic regression 与 k-means 比较 Hadoop、in-memory binary Hadoop 和 Spark：

- Logistic regression 后续 iterations 在 100 machines 上比 Hadoop 快 `25.3x`，比 HadoopBinMem 快 `20.7x`。
- Compute-heavy k-means 的 speedup 只有 `1.9x-3.2x`，说明复用/I/O 优化收益取决于 computation-to-data ratio。
- 论文把差异拆成 Hadoop software-stack minimum overhead、HDFS serving copies/checksum、deserialization；Spark 把 RDD elements 直接作为 Java objects 放在 memory，绕开这些重复成本。

### 9.2 PageRank 与 partitioning

54 GB Wikipedia dump、10 iterations：仅 in-memory storage 在 30 nodes 上给 Spark `2.4x` speedup；保持 iterations 间一致 partitioning 后提高到 `7.4x`。这直接支持“partitioner 可把 join/shuffle 变便宜”的机制论点。

### 9.3 Failure recovery

75-node k-means、100 GB working set 中，第 6 iteration 开始时 kill 一台 machine：正常 iterations 约 `58 s`，故障轮因重建 lost partitions 增到 `80 s`，下一轮恢复到 `58 s`。Lineage graph 小于 `10 KB`；对比 full working-set checkpoint/replication，论文展示的是 partial reconstruction 的代价优势。

### 9.4 User applications 与 interactive query

- Conviva report 复用同一 filtered subset，从 Hadoop 的 `20 hours` 缩到两台 Spark machines 的 `30 minutes`，即 `40x`；只缓存匹配 rows/columns，因此 200 GB compressed input 不要求把完整解压数据装入 RAM。
- 100 machines 扫描 1 TB Wikipedia page-view logs 的 interactive queries 为 `5-7 s`，对比论文配置中的 disk query `170 s`。

“Up to 20x/40x” 都来自高度复用 intermediate data 的 workload；它们不能证明 single-pass jobs 同样加速。

## 10. Tradeoffs

| 设计选择 | 收益 | 代价/边界 |
| --- | --- | --- |
| Immutable, coarse-grained transformations | lineage 简单、无 fine-grained update log、易 speculative execution | 不适合 asynchronous shared mutable state |
| Lazy evaluation | 可看见完整 DAG、pipeline 与消除不必要工作 | 错误/成本可能到 action 时才暴露；driver metadata 增长 |
| In-memory persistence | iterative/interactive reuse 快 | 占 RAM；需 eviction、serialization 或 spill policy |
| Lineage recovery | metadata 小、只重算 lost partitions | long/wide lineage 可能扩大 recovery work |
| Checkpoint/replication | 截短最坏 recovery path | network/storage 开销；何时 checkpoint 是 policy 问题 |
| Controlled partitioning | 避免重复 shuffle、提高 locality | application/runtime 要维护 partitioner metadata |
| Wide shuffle | 支持 join/group/reduce 等 general dataflow | network all-to-all、barrier、materialization 与更广 recovery |
| Language-integrated closures | API 简洁、支持 interactive work | code/closure serialization 与 runtime integration 复杂 |

## 11. FAQ 与课堂连接

- 课堂讲义把本讲分成 programming model、execution strategy、fault tolerance；本文第 3-7 节按这条顺序组织。
- 课堂用 PageRank 说明直到 `collect` 前主要是在构造 lineage；loop 每轮产生新 RDD，lineage 不形成 cycle。它还用 `cache links` 说明 MapReduce 缺乏跨 jobs 的显式 in-memory reuse。
- 课堂对 narrow/wide 的定义与论文一致：narrow 可本地 pipeline，wide 需要 shuffle/barrier；failure 时 wide path 也更可能扩大 recomputation。
- FAQ 把 Spark 概括成“MapReduce and more”，但同时保留两个边界：streaming/fine-grained shared state 可能有更合适系统；single scan + aggregation 不从 RDD reuse 获得独特优势。
- FAQ 的 hash-partitioning 例子解释 PageRank 中 links/ranks 同 key 共置后，join 不必为每个 key 跨机器找配对数据。
- FAQ 说 modern Spark 的 RDD API 已不再是主要高层接口；这是课后历史背景，不改变 assigned 2012 paper 的设计问题。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing What applications can Spark support well that MapReduce/Hadoop cannot support?

下面只给推理脚手架，不给可提交答案：

1. 先把 “cannot support” 拆成 **无法表达** 与 **无法高效支持**；论文主要论证哪一种含义？引用 Introduction/§7 的措辞核对。
2. 从一个具体 application family 出发，画出它跨多轮 computations 的 data reuse pattern；标出 MapReduce/Hadoop 每轮之间保存 intermediate result 的位置。
3. 把同一 workload 画成 RDD lineage，标出哪些 RDD 要 persist、哪些 dependencies 是 narrow/wide、哪些 actions 触发执行。
4. 比较两条路径中的 stable-storage I/O、serialization、job boundaries、shuffle 与 recomputation，不能只写“Spark 在内存所以快”。
5. 用论文 §6 的一组对应 evaluation 作为证据，并保留 machines、dataset、iterations 或 query pattern 等实验条件。
6. 加一个反例边界：说明哪类 single-pass 或 fine-grained mutable workload 不从该机制获益，防止把答案写成“Spark 对所有应用都更好”。

## 13. 理解检查：10 组问答

1. **问：RDD 的最小定义是什么？**  
   **答：** Read-only、partitioned records collection，由 stable data 或其他 RDDs 通过 deterministic transformations 创建。（来源：论文 §2.1）

2. **问：Transformation 与 action 的区别是什么？**  
   **答：** Transformation lazy 地描述新 RDD 与 lineage；action 返回结果或写外部 storage，并触发实际 computation。（来源：论文 §2.2、课堂讲义）

3. **问：为什么 RDD immutable 却仍能表示 PageRank 每轮变化的 ranks？**  
   **答：** 每轮 transformation 创建一个新的 ranks RDD；variable 可重新指向新版本，但已有 RDD 不被原地改写。（来源：论文 §2.1、FAQ、课堂讲义）

4. **问：Lineage 为什么能替代 intermediate-data replication 的一部分？**  
   **答：** Deterministic dependency graph 保存如何从 surviving parents/stable input 重建 partition；failure 时可重算 lost data，而不必预先复制全部 intermediate bytes。（来源：论文 §1-2）

5. **问：Narrow 与 wide dependency 对 execution 的差别是什么？**  
   **答：** Narrow transformations 可在 node 内 pipeline；wide dependency 要按 key 等规则 shuffle 多个 parent partitions，形成 network/barrier stage boundary。（来源：论文 §4-5）

6. **问：为什么 co-partitioning 能优化 join？**  
   **答：** 两个 parents 用相同 partitioner 时，同 key records 已在对应 partitions，可把原本 wide 的 join dependencies 变 narrow，避免一次重新 shuffle。（来源：论文 §3.2.2、§4、FAQ）

7. **问：Worker failure 后 Spark 是否总只重算一个 partition？**  
   **答：** 不一定。Narrow lineage 往往局部重算；wide/shuffle ancestors 的丢失可能要求重建多个 upstream partitions，long wide lineage 因而更适合 checkpoint。（来源：论文 §4-5）

8. **问：Checkpoint 与 persist 是同一保证吗？**  
   **答：** Persist 表示复用/storage policy，可只存在易失 memory；checkpoint/replication 到 stable storage 用来截短故障后的 lineage recovery。具体 flags 属于论文当时 API，概念上要区分 durability 与 cache。（来源：论文 §2.2、§5.3-5.4、课堂讲义）

9. **问：论文的 20x speedup 为什么在 logistic regression 上比 k-means 明显？**  
   **答：** Logistic regression 每 byte computation 较少，I/O、framework 与 deserialization 占比高；compute-heavy k-means 优化这些成本后的相对收益较小。（来源：论文 §6.1）

10. **问：哪两类 workload 最能体现 RDD 相对 MapReduce 的优势，哪类不适合？**  
    **答：** Iterative reuse 与 interactive repeated queries 最受益；asynchronous fine-grained mutable state 不适合，single-pass scan/aggregate 也缺少 in-memory reuse 的独特收益。（来源：论文 §1、§2.4、FAQ）
