---
uid: mit-6824-s21-resource-reading-21
type: course
document_type: resource
resource_kind: reading
resource_order: 121
course: mit-6824-s21
title: Lecture 21 阅读指南：AnalogicFS 与 Project Presentations
description: Lecture 21 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 21 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-21/"
toc: true
official_lecture_number: 21
math: true
---

## 1. 来源、范围与特殊证据边界

- 指定阅读是完整的 **Experiences with a Distributed, Scalable, Methodological File System: AnalogicFS**：Abstract、§1-§6、References。官方 schedule 没有缩小 section 范围。
- 这篇文本不是可信的 systems experience paper。FAQ 明确说明它由 6.824 TAs 多年前使用 [SCIgen](https://pdos.csail.mit.edu/archive/scigen/) “written”，作为课程传统；严肃寓意是 **be careful with what you read and believe**。
- 因此本指南会准确总结“文本声称了什么”，但不会把 AnalogicFS 的 model、mechanism、invariant、failure/consistency/security guarantee、evaluation number 或 references 当作真实 source-supported system fact。它们是被审查对象，不是技术依据。
- Lecture 21 当天的课堂内容是八组 **Project Presentations**，不是教师讲授 AnalogicFS protocol。Lecture 21 目录没有官方 lecture note、聚合 `NOTES.md` 或生成的 section notes；本文只使用实际存在的 10 段 summary input 和完整 transcript 建立 project connection。
- Project presentations 是学生报告/演示证据。本文只归纳 presenters 明确说出的 threat model、implemented subset、test/evaluation conditions 和 open limitations；不把 demo 成功推广成 production guarantee。
- Paper Question 是刻意保持荒诞精神的开放题。本文逐字保留四个选项，并给分析脚手架；不会伪造 quantitative result、补全 Figure 1、选择一个“标准答案”或生成可直接提交答案。

资源：

- [Lecture 21 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-21.md)
- [AnalogicFS 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/katabi-analogicfs.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/analogicfs-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/21-q-analogic.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-21-project-presentations)
- [Lecture 21 summary input](/assets/courses/mit-6824-s21/lectures/022/summary-input.jsonl)
- [Lecture 21 transcript](/assets/courses/mit-6824-s21/lectures/022/transcript.txt)
- [Lecture 21 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=22)

## 2. 如何读：先做 credibility audit，不默认 paper 是真的

普通 reading guide 会从 abstract 提取 problem、mechanism 与 result；本讲必须先增加一步：**检查文本是否形成可证伪、内部一致、可复现实验支持的论证链。**

建议顺序：

1. 只读 title/abstract，列出 nouns、claimed problem、claimed solution 和 measurable outcome。
2. 读 Introduction，检查 motivation 是否指向同一 problem，contributions 是否可验证。
3. 读 Design，寻找 state、components、interfaces、algorithms、assumptions 和 invariants。
4. 读 Implementation，寻找能把 design 落地的 data structures、control path、code/module boundary。
5. 读 Evaluation，要求 hypotheses -> setup -> independent variables -> metrics/units -> baselines -> results -> uncertainty 的完整链。
6. 交叉检查 figures、captions、axes、正文 references 与 conclusion 是否互相支持。
7. 检查 citations 是否真实且相关；作者/venue/terminology 看起来熟悉不等于 citation 有效。
8. 最后才决定哪些 claim 可进入自己的知识模型。

AnalogicFS 在这套检查下不是“有些地方写得模糊”，而是 problem、mechanism、units 和 evidence 大规模语义断裂。FAQ 给出的 SCIgen provenance 进一步解释了原因。

## 3. 文本结构与它声称的系统

为了准确审查，先记录原文表面结构，但每项都标作 **文本声称**：

| 部分 | 文本声称 | 直接问题 |
| --- | --- | --- |
| Abstract | Suffix-tree analysis 是难题；AnalogicFS 研究 8-bit architectures，并解决 hardware/architecture grand challenges | Problem、user、failure/consistency target 不清楚 |
| §1 Introduction | 系统替代 DNS、研究 SCSI disks，基于 stochastic algorithms/I/O automata | 同一段在 DNS、SCSI、ML、lambda calculus、e-commerce 间跳跃，无依赖链 |
| §2 Design | Figure 1 是 A* search analysis；假设某 kernel algorithm 为 $O(n^2)$；DHCP、VoIP、semaphores 等共同构成 framework | 没有可执行 state transition、data model 或 proof obligation |
| §3 Implementation | Centralized logging facility 有 `9941` PHP instructions；block size cap 为 `676 nm`；scripts 有 `935` Fortran lines | Storage block size 使用长度单位 nm；语言/模块数字与设计无因果关系 |
| §4 Evaluation | 三个 hypotheses 涉及 LISP machines seek time、model checking、reinforcement learning/NVRAM | Hypotheses 与 §1 的 claimed file-system problem 不对应 |
| §4.1 Setup | Decommissioned Nintendo Gameboys、10-node overlay、EthOS、JIT x86 assembly | 设备/OS/toolchain 组合未给可复现配置且与 SCSI claim 冲突 |
| §4.2 Results | 四项 experiments，figures 使用 hit ratio、energy、power、latency、clock speed、bandwidth 等 | Axes 单位/变量互不相容，结果多称来自他人且没有 raw data/statistics |
| §5 Related Work | 大量知名领域和作者名被拼接为相关工作 | Citation relevance 不成立，references 本身具有生成式荒诞特征 |
| §6 Conclusion | 声称 disproved telephony property，并确认 unrelated complexity/epistemologies | 没有由前文 experiment 支撑的结论链 |

这个表不是 AnalogicFS model。它只忠实记录文本表面 assertions，并指出为什么无法把它们合成为一个真实 system specification。

## 4. Model 与 mechanism 审查：缺失了什么

一个分布式文件系统的可信 model 至少应回答：

- Clients、metadata servers、storage nodes 各是谁；
- Files/directories/blocks 如何命名和放置；
- Read/write/create/delete/recovery 的 request path；
- Concurrent operations 怎样排序，cache 如何保持一致；
- Replication、logging、checkpoint、reconfiguration 怎样交互；
- Network、crash、disk、Byzantine failure 假设；
- Safety/liveness invariants 及其适用前提。

AnalogicFS 没有给出这些要素。§2 的 flowchart labels（如 `M != V`、`D != F`、`I > P`）没有变量定义、状态语义、transition action、termination condition 或与 file operation 的 mapping。因而 Figure 1 不能被解释为 A* search、filesystem protocol 或可验证 state machine。

### “术语很多”不等于 mechanism

文本同时提到 erasure coding、semaphores、DHCP、VoIP、partition table、A*、lambda calculus 和 I/O automata，但没有给出：

```text
input state
    -> algorithm step / message
    -> state mutation
    -> observable output
```

没有这条 path，就无法回答 protocol 在 normal operation 下如何工作，更无法推导 failure behavior。阅读时应把无法连接到 control/data path 的术语视作待证名词，而不是自动补全为“高级机制”。

## 5. Invariant、failure、consistency 与 security 审查

### 5.1 没有可陈述 invariant

真实 invariant 应是对所有 reachable states 成立、可被 transition preservation 检查的命题，例如：

```text
every committed write appears in the same order at all replicas
at most one owner controls a name at a given log position
every acknowledged block is durable on a quorum
```

AnalogicFS 没有定义 state、commit、replica、quorum 或 operation order，因此不能从“stable”“atomic”“authenticated”“robust”等形容词构造 invariant。重复写“absolutely/yes”也不是 proof。

### 5.2 没有 failure model

论文未说明它容忍：

- process crash；
- disk loss/corruption；
- dropped/duplicated/reordered message；
- partition；
- Byzantine client/server；
- recovery/rejoin。

没有 failure model，就无法解释“distributed/scalable”在什么环境下成立，也无法评价 availability/safety tradeoff。

### 5.3 没有 consistency contract

文本偶尔使用 “atomic” 或 “stable”，但没有定义 linearizability、serializability、causal/eventual consistency、read-after-write 或 conflict resolution。不能因为标题含 filesystem 就假定它继承 NFS、Frangipani 或 Raft semantics。

### 5.4 没有 security guarantee

使用 “authenticated”“symmetric encryption” 等词不等于有 security protocol。缺少 principals、keys、adversary capability、authorization policy、message coverage 和 theorem。AnalogicFS 不能被引用为 confidentiality、integrity、authentication 或 privacy 的证据。

### 5.5 最重要的不变量是阅读过程自己的

```text
claim enters study notes
    only if source defines it
    and mechanism/evidence supports it
    and boundary/assumptions remain attached
```

本讲训练的是这个 evidence invariant，而不是 AnalogicFS protocol invariant。

## 6. Evaluation audit：为什么 figures 不能支持 conclusion

### 6.1 Hypothesis-to-metric mismatch

§4 声称验证 LISP machine expected seek time、model checking 对 system design 的影响、reinforcement learning 对 NVRAM space 的影响；figures 却展示：

- `hit ratio (connections/sec)` 对 `energy (percentile)`；
- `power (cylinders)` 对 `latency (dB)`；
- `hit ratio (Joules)` 对 `clock speed (bytes)`；
- `popularity of multicast algorithms (pages)` 对 `bandwidth (dB)`。

这些 dimension/units 彼此不构成标准 physical or systems measurements，也没有 operational definition。图形存在不等于变量被测量。

### 6.2 Setup-to-claim mismatch

Introduction 说研究 SCSI disks，§4.1 却强调 decommissioned Gameboys；系统声称需要 EthOS 又称 implementation 是 PHP/Fortran/JIT x86 assembly。没有说明硬件如何运行这些组件、sample size、network topology、storage medium、software revision 或 reproducible commands。

### 6.3 Statistics red flags

文本说 error bars 省略，因为多数 data points 落在 observed means 的 `60 standard deviations` 外。这不是省略 error bars 的合理理由，反而表明 data/model/statement 至少一项失效。`10th-percentile and not 10th-percentile` 是自相矛盾句。

### 6.4 Missing baselines and provenance

多个 figures 声称 results 来自其他 named authors，再“reproduce for clarity”，但 references 与正文无法建立可信 provenance。没有 raw data、trial protocol、control、confidence interval 或 meaningful baseline，不能支持 efficiency/scalability/security 结论。

### 6.5 可迁移检查

对任何 real experience paper，都应问：

1. Metric 的 unit 是否与变量匹配？
2. Experiment 是否能改变 claimed cause 并观察 claimed effect？
3. Setup 是否代表 target deployment？
4. Baseline 是否公平、configuration 是否披露？
5. 结果是否可重复，variance/error 是否报告？
6. Conclusion 是否只覆盖 measured workload，而非无限外推？

## 7. Tradeoffs：不能从不存在的 design 推导

通常 systems reading 会列“replication 换 durability”“coordination 换 consistency”“caching 换 freshness”等 tradeoff。AnalogicFS 的问题不是选择可争议，而是没有 coherent design choices，因而不存在 source-supported benefit/cost pairing。

以下写法都不成立：

- “676 nm blocks 通过更小 block 提高 cache locality”：原文没定义 nm 与 bytes 的关系，也没给 measurement。
- “Gameboys 提高 energy efficiency”：原文没有可解释 energy metric 或 baseline。
- “Centralized logging 保证 atomicity”：没有 log record、commit/recovery protocol。
- “Erasure coding 提供 fault tolerance”：没有 coding parameters、failure threshold 或 repair path。
- “I/O automata 证明 correctness”：没有 automaton、transition relation 或 theorem。

可信 tradeoff 必须同时有 mechanism 和负面成本：

```text
design choice
    -> causal mechanism
    -> measured/proved benefit under assumptions
    -> explicit cost/failure boundary
```

缺任何一环，都只能写成 hypothesis 或 claim，不能写成结论。

## 8. Project Presentations：八组真实系统证据

Lecture 21 的八组展示恰好提供了 AnalogicFS 缺失的要素。以下只记录 transcript 中 presenters 明确陈述的内容：

| Project | 明确模型/机制 | 明确边界或课堂追问 |
| --- | --- | --- |
| Distributed private electronic voting | Shamir secret sharing；$n$ counters、threshold $k$；周期 retry；持久化 voter shares | 只处理 fail-stop，不处理 Byzantine；没有 performance numbers；最多容忍 $n-k$ counters crash 的陈述依赖 protocol assumptions |
| Sys private analytics | Secret shares、proxies、encryption、zero-knowledge proof、server replication/partitioning proposal | Demo 未实现 replication/parallel version；server failure 会阻止 reconstruction；benchmark 同 data center，外推已标估算 |
| BukaDocs | LSEQ CRDT、globally unique element keys、grow-only deletion set、client/server propagation | 假设 clients trustworthy；离线 edits 待重连；localhost burst experiment 不能代表 real hardware，load 增加让 convergence 变慢 |
| eggscrambler | Commutative encryption 的 anonymous broadcast；Raft replicated state machine/order；configuration changes | Honest-participant assumption；$n-1$ collusion 可识别最后 sender；partition/round progress 与 membership removal 引出 availability/security 问题 |
| 9P fault tolerance | Uniform 9P interface 拦截 operations；chain replication；configuration service；replicate unmodified memfs/local storage demos | Chain replication 是简单起点；dynamic replica addition 未完成；9P overhead 只做有限 benchmark |
| Modular verification | Concurrent separation logic；证明 sharded KV client abstraction/linearizable specification；强调 compositionality | Specification 错或 model 漏 execution 会让 theorem 无用；implementation 未优化、没有 performance numbers |
| Simple distributed file system | Frangipani-like design，server-side filesystem，Raft 替代 Petal；4096-byte blocks | 2 MB file/nominal disk capacity 等受 RAM/implementation 限制；展示需结合实际 failure/recovery semantics，不因“uses Raft”自动完整正确 |
| Pinguino game framework | Rooms/regions 分片到 workers；fault-tolerant worker/coordinator idea；在 latency 与 replication 间权衡 | Partition 时 backup acting as coordinator 可能形成同 room 双份 divergent state，课堂直接追问 merge/split-brain；说明 design review 应攻击核心 invariant |

这张表的价值不是给项目排名，而是展示可信陈述的格式：每组至少尝试说明 threat/failure assumptions、implemented subset、demo conditions 或 unresolved issue。承认“没实现”“没测”“只在 localhost”“不处理 Byzantine”比 AnalogicFS 的无边界肯定更有技术价值。

## 9. 从 Project Presentations 学到的验证框架

### 9.1 Threat model 必须先于 mechanism

Private voting 明说 fail-stop/not Byzantine；Sys 区分 malicious clients、honest proxy/server assumptions；eggscrambler 在追问中暴露 collusion boundary。没有 threat model 时，“private/secure/fault-tolerant”没有可判断含义。

### 9.2 Implementation status 必须分层

Sys 把 final design 与 demo subset 分开；9P project 说明 replica addition 是 work in progress；modular verification 承认未做性能优化。阅读时应分别记录：

```text
designed
implemented
demonstrated
tested
measured
proved
deployed
```

这些状态不能互相替代。

### 9.3 Tests 要针对 adversarial cases

课堂对 zero-knowledge proof 问“怎样知道实现有效”，回答包括生成 bad proofs 并确认 rejection。可靠性测试同理应注入 crash、drop、duplicate、partition、restart 和 stale state，而不只是 happy-path demo。

### 9.4 Evaluation 要保留环境

BukaDocs 报告 localhost 上 3,000/19,000 concurrent edits 的 convergence times，并主动说明 single-machine fast RPC 与 resource contention 让 real-hardware direction 不确定。这种限定是 source-supported reporting 的必要部分。

### 9.5 课堂问题是 live peer review

Pinguino 的 coordinator partition question 指向 split brain：两侧都创建 same-room active replica 后，重连不能只说“locally resolve”，必须定义 conflict/state ownership invariant。好的 question 会抓最可能破坏 safety 的排程，而不是被 architecture nouns 吸引。

## 10. FAQ、传统与严肃寓意

FAQ 的完整技术信息很短：

- 读它因为有趣、intriguing，是 6.824 多年传统；
- 文本由 TAs 借 SCIgen 生成；
- 教师喜欢阅读学生对开放 Question 的回答；
- 严肃寓意是谨慎判断读到和相信的内容。

### 为什么把它放在 Project Presentations 日

课程当天不是 AnalogicFS 讲解，而是学生展示一个学期末的 systems work。二者形成反差：真实项目即使小、未完成，也应说清 model、assumptions、implemented subset、demo、failure 与 open questions；华丽术语和图表不能替代这些内容。

### 不应从传统推导的事

- 不是说 systems papers 都不可信；而是 peer review 需要主动验证。
- 不是说荒诞 Question 有隐藏唯一 numerical answer；它邀请在 paper spirit 下作创造性回应。
- 不是鼓励捏造实验；尤其 b/d 要求 quantitative explanation 时，应把不可计算性、缺失 variables 和单位问题视为分析对象，而不是伪造 numbers。
- 不是让你忽略 citations；相反，要点开 sources、检查 author/title/venue/relevance。

## 11. 一页审稿清单：model 到 evaluation

| 维度 | 应找到的证据 | AnalogicFS 状态 | Project presentation 对照 |
| --- | --- | --- | --- |
| Problem | User/workload、现有缺口、success criterion | 主题随机漂移 | 各组从 voting/privacy/editing/game latency 等具体需求出发 |
| Model | Components、state、interfaces、assumptions | 缺失 | Voting 明确 voters/counters/$n,k$；BukaDocs 明确 clients/servers/CRDT state |
| Mechanism | Message/data path、algorithm、state transitions | 术语拼接 | Sys/eggscrambler/9P 展示具体 crypto/Raft/replication paths |
| Invariant | Reachable states 上必须成立的性质 | 缺失 | Verification project 直接写 client specification；课堂问题挑战 split brain |
| Failure | Crash/partition/Byzantine/recovery boundary | 缺失 | 多组明确只处理哪些 failure 与未实现部分 |
| Consistency | Reads/writes/order/conflict semantics | 只用空泛 adjectives | BukaDocs 声称 eventual convergence；KV verification 目标 linearizability |
| Security | Adversary、keys、leakage、proof | 缺失 | Voting/Sys/eggscrambler 分别说明 privacy/collusion assumptions |
| Implementation | Code/module/data structure/protocol mapping | 数字与语言无 mapping | Projects 演示运行 subset，并区分 proposed vs built |
| Evaluation | Setup、metric/unit、baseline、variance、result | Units/claims 不相容 | 有限但可审查；presenters 标注 localhost/EC2/no numbers |
| Tradeoff | Mechanism-supported benefit + cost | 无 coherent choice | Pinguino 明示 latency vs fault tolerance，BukaDocs 明示 load vs convergence |

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Experiences with a Distributed, Scalable, Methodological File System: AnalogicFS. In many ways, this experiences paper raises more questions than it answers. Please answer one of the following questions, taking into consideration the rich history of AnalogicFS and the spirit in which the paper was written:
>
> a) The analysis of A* search shown in Figure 1 claims to be an introspective visualization of the AnalogicFS methodology; however, not all decisions are depicted in the figure. In particular, if I <= P, what should be the next node explored such that all assumptions in Section 2 still hold? Show your work.
>
> b) Despite the authors' claims in the introduction that AnalogicFS was developed to study SCSI disks (and their interaction with lambda calculus), the experimental setup detailed in Section 4.1 involves decommissioned Gameboys instead, which use cartridge-based, Flash-like memory. If the authors had used actual SCSI disks during the experiments, how exactly might have their results changed quantitatively?
>
> c) AnalogicFS shows rather unstable multicast algorithm popularity (Figure 5), especially compared with some of the previous systems we've read about in 6.824. Give an example of another system that would have a more steady measurement of popularity pages, especially in the range of 0.1-0.4 decibels of bandwidth.
>
> d) For his 6.824 project, Ben Bitdiddle chose to build a variant of Lab 4 that faithfully emulates the constant expected seek time across LISP machines, as AnalogicFS does. Upon implementation, however, he immediately ran into the need to cap the value size to 400 nm, rather than 676 nm. Explain what assumptions made for the AnalogicFS implementation do not hold true for Lab 4, and why that changes the maximum value size.

下面只给推理脚手架，不选择选项、不补造 paper facts，也不给可提交答案：

1. 先读 FAQ 与 SCIgen provenance，确定题目的 “spirit” 包含幽默和 critical reading，而非从伪公式求唯一数值。
2. 若选 a：逐个列 Figure 1 已定义/未定义的 nodes、edges、variables 和 conditions；说明 `I <= P` 分支为什么不能由现有 semantics 唯一推出。你可以创造规则，但要标明新假设并保持内部一致。
3. 若选 b：列 SCSI 与 cartridge/flash-like storage 需要哪些真实 parameters（seek、rotation、throughput、latency、capacity、workload）；指出 paper 没提供哪些 baseline/raw data，所以什么 quantitative counterfactual 不可识别。不要捏造精确百分比。
4. 若选 c：先做 dimensional analysis，解释 pages 与 dB 为什么不是自然配对；若引用本课程另一系统，只使用其论文真实 metric，并明确你是在延续题目幽默还是做严肃比较。
5. 若选 d：检查 nm 是否能作为 value size，Lab 4 的 value 实际由什么 API/bytes/memory/RPC constraints 决定；区分 AnalogicFS invented assumption 与 Lab 4 official model。不要把 `400/676` 当真实 engineering constants。
6. 无论选哪题，都让 “show/explain” 可审查：写 assumptions、推理 steps、哪些信息不可得、结论适用范围。
7. 保持原创和课程语境；脚手架的目标是识别证据缺口，不是把一段现成笑话扩成 submission。

## 13. 理解检查：10 组问答

1. **问：为什么不能把 AnalogicFS 的 assertions 当作真实系统事实？**  
   **答：** FAQ 明确它由 SCIgen 生成；正文 problem、mechanism、units、citations 和 conclusions 又缺乏语义/证据链。（来源：论文、FAQ）

2. **问：AnalogicFS 是否定义了 distributed filesystem model？**  
   **答：** 没有。它没有 coherent components、file/block state、operations、message path、replication/recovery semantics；Figure 1 variables 也未定义。（来源：论文 §1-§3）

3. **问：为什么 `676 nm` block/value size 是 red flag？**  
   **答：** Nanometer 是长度单位，paper 没给与 bytes/storage allocation 的 mapping；一个精确数字配错误 dimension 不是 implementation evidence。（来源：论文 §3）

4. **问：Figure 2-5 为什么不能支持 performance conclusions？**  
   **答：** Axes units/variables 不相容，setup 与 claims 不对应，缺 raw data/baselines/uncertainty，正文还出现自相矛盾 percentile/statistics 描述。（来源：论文 §4）

5. **问：项目展示中“承认未实现”为什么比模糊 claim 更有价值？**  
   **答：** 它划清 designed 与 demonstrated guarantee，读者可判断现有 evidence 覆盖范围；未实现的 replication/parallelism 不能从 demo 推出。（来源：Lecture 21 transcript）

6. **问：BukaDocs 的 localhost result 应怎样报告？**  
   **答：** 保留 clients/servers、edit count、convergence time 和 single-machine context，并说明 fast RPC 与 shared resource contention 使 real hardware 外推方向不确定。（来源：Lecture 21 transcript 约 00:30）

7. **问：Modular verification project 提醒 proof 有哪两个边界？**  
   **答：** Specification 若不表达真实目标，proved theorem 无用；model 若漏掉现实 execution，theorem 不适用于该 execution。（来源：Lecture 21 transcript 约 00:58-01:00）

8. **问：Pinguino 的 partition 追问在检查什么？**  
   **答：** 两侧 coordinators 是否会各自创建同 room active replicas并让 state divergence；“重连后本地解决”不足以替代明确 ownership/merge invariant。（来源：Lecture 21 transcript 约 01:30）

9. **问：AnalogicFS homework 为什么不应伪造 quantitative answer？**  
   **答：** Paper 缺可识别 counterfactual 所需参数与有效 units；题目精神允许创造性，但严肃寓意要求明确 assumptions/不可计算性，而不是冒充测量。（来源：FAQ、Question）

10. **问：本讲可迁移到以后阅读的核心规则是什么？**  
    **答：** 只有定义清楚、机制或证据支持、且保留 assumptions/boundaries 的 claim 才进入笔记；术语密度、作者名、图表和精确数字都不能替代验证。（来源：AnalogicFS audit 与 Project Presentations 对照）
