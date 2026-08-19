---
uid: stanford-cs336-s26-module-03
type: course
document_type: module
course: stanford-cs336-s26
module_number: 3
title: 模块 03：Scaling Laws
description: '本模块把两讲关于 scaling laws 的内容整理成一条可执行的学习与复习路线：先掌握 Lecture 09 的基础对象与拟合方法，再进入 Lecture 11 的现代实践 recipe、超参数迁移、muP 以及“scaling in the wild”的失败边界。Lecture 09 的重点是“为什么 scaling laws 值得做、怎么看数据/模型/compute 的幂律关系、为什么要尊重拟合过程”；Lecture 11 的重点是“现实团队如何把这件事做成 recipe，并如何控制 learning rate、batch size、optimizer 与 parametrization 的规模漂移”。[课件: lecture_09.pdf p.1-p.7] [课件: lecture_09.pdf p.45-p.52] [00:00:05-00:02:16][课件: lecture_11.pdf p.2-p.4]'
excerpt: '本模块把两讲关于 scaling laws 的内容整理成一条可执行的学习与复习路线：先掌握 Lecture 09 的基础对象与拟合方法，再进入 Lecture 11 的现代实践 recipe、超参数迁移、muP 以及“scaling in the wild”的失败边界。Lecture 09 的重点是“为什么 scaling laws 值得做、怎么看数据/模型/compute 的幂律关系、为什么要尊重拟合过程”；Lecture 11 的重点是“现实团队如何把这件事做成 recipe，并如何控制 learning rate、batch size、optimizer 与 parametrization 的规模漂移”。[课件: lecture_09.pdf p.1-p.7] [课件: lecture_09.pdf p.45-p.52] [00:00:05-00:02:16][课件: lecture_11.pdf p.2-p.4]'
content_lang: zh-CN
permalink: "/courses/stanford-cs336-s26/modules/03/"
toc: true
math: true
mermaid: true
---

> 本模块只使用以下两份讲义笔记，不引入任何外部事实、论文补充或额外定义：
>
> - [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/)
> - [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/)
>
> 证据记录规则：保留原笔记中的时间戳、页码引用与不确定性标记；凡笔记明确标为“[需回听]”或只给趋势不给精确式，本模块也按不确定项处理。

## 模块目的

本模块把两讲关于 scaling laws 的内容整理成一条可执行的学习与复习路线：先掌握 Lecture 09 的基础对象与拟合方法，再进入 Lecture 11 的现代实践 recipe、超参数迁移、muP 以及“scaling in the wild”的失败边界。Lecture 09 的重点是“为什么 scaling laws 值得做、怎么看数据/模型/compute 的幂律关系、为什么要尊重拟合过程”；Lecture 11 的重点是“现实团队如何把这件事做成 recipe，并如何控制 learning rate、batch size、optimizer 与 parametrization 的规模漂移”。[课件: lecture_09.pdf p.1-p.7] [课件: lecture_09.pdf p.45-p.52] [00:00:05-00:02:16][课件: lecture_11.pdf p.2-p.4]

如果只记一句话，这两讲共同的实践结论是：scaling laws 的作用不是训练后画好看的图，而是在大训练之前，用小规模实验建立可外推的、但必须做鲁棒性检查的决策依据。[课件: lecture_09.pdf p.4-p.6] [00:21:25-00:22:03][课件: lecture_11.pdf p.24] [01:15:52-01:16:58][课件: lecture_11.pdf p.58]

## 先修要求

- 需要熟悉 test loss、perplexity、参数量、token 数、FLOPs、optimizer、learning rate、batch size、warmup 与数据并行这些预训练基本对象，因为两讲都把它们当作 trade-off 变量直接操作。[课件: lecture_09.pdf p.1-p.7] [00:10:24-00:12:04][00:31:51-00:00:39:58]
- 需要有 log-log 图像与幂律的基本直觉，因为 Lecture 09 的基础推理从“log-log 直线意味着 polynomial decay”展开，Lecture 11 的外推则默认你已经接受这种图像语言。[课件: lecture_09.pdf p.7] [00:01:20-00:01:37]
- 需要接受“很多规律是经验性的、条件性的，而不是自然常数”这个前提，因为 Lecture 11 会明确指出 learning rate / batch scaling、optimizer 比较、muP 的适用性都依赖 recipe、数据与参数化。[00:31:51-00:33:15] [00:37:44-00:38:04] [01:13:55-01:15:11]

## 精确学习路径与链接

### 路径总览

1. 先读 [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/) 的开场、数据缩放、数据工程、模型工程、critical batch、联合缩放与 discrepancy 七个层次。
2. 再读 [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/) 的两条现代路线：MiniCPM/muP 稳定化路线与 DeepSeek/StepFun 拟合路线。
3. 最后回到本模块，对照“公式只写到哪里”“哪些趋势可迁移”“哪些地方必须保留不确定性”。

### 精确推进顺序

| 阶段 | 先看内容 | 对应链接 | 你要抓住什么 |
| --- | --- | --- | --- |
| 1 | Lecture 09 开场与数据缩放基础 | [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/) | scaling laws 是训练前决策工具；log-log 直线与幂律；均值估计与非参数估计的两层直觉。[课件: lecture_09.pdf p.1-p.7] |
| 2 | Lecture 09 数据工程与模型工程 | [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/) | intercept/slope 分工；mixture、repetition、architecture、optimizer、aspect ratio 的缩放式思考。 |
| 3 | Lecture 09 critical batch 与 upstream/downstream caution | [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/) | 批大小为什么既是系统问题也是 scaling 问题；为什么先在低方差上游 loss 建模，再谨慎谈 downstream。 |
| 4 | Lecture 09 联合缩放与 Chinchilla/Kaplan discrepancy | [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/) | lower envelope、IsoFLOP、joint fits 三种方法；为什么老师偏爱 IsoFLOP；为什么要 respect the process。 |
| 5 | Lecture 11 MiniCPM 与 WSD | [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/) | muP 稳定学习率；WSD 降低 Chinchilla sweep 成本；小模型 ladder 外推大模型。 [00:03:36-00:15:58][课件: lecture_11.pdf p.6-p.18] |
| 6 | Lecture 11 DeepSeek、StepFun、optimizer 轴 | [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/) | 直接拟合 batch/LR scaling；compute 轴与 Chinchilla ratio 轴；transfer 与条件性。 [00:20:03-00:49:56][课件: lecture_11.pdf p.19-p.41] |
| 7 | Lecture 11 muon 与 muP 细节 | [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/) | 矩阵更新、A1/A2 不变量、层学习率缩放、muP 失效条件。 [00:49:56-01:16:58][课件: lecture_11.pdf p.42-p.58] |

## 依赖关系图

```mermaid
graph TD
    A[Lecture 09: scaling laws 用于训练前决策] --> B[数据缩放 laws]
    B --> C[log-log 直线 = 幂律]
    C --> D[均值估计 1/n 与非参数 n^{-1/d} 直觉]
    B --> E[数据工程: mixture / repetition]
    E --> F[intercept 与 slope 区分]
    F --> G[模型工程: 架构 / optimizer / aspect ratio]
    G --> H[critical batch 与 learning rate]
    H --> I[固定 FLOPs 下的联合缩放]
    I --> J[lower envelope / IsoFLOP / joint fits]
    J --> K[Kaplan vs Chinchilla discrepancy]
    K --> L[respect the process]
    L --> M[Lecture 11: 现代 recipe]
    M --> N[MiniCPM: muP + WSD]
    M --> O[DeepSeek / StepFun: 拟合 batch 与 LR]
    O --> P[超参数 transfer 与条件性]
    N --> Q[muP: A1/A2 invariance]
    O --> R[optimizer scaling: compute 轴 + Chinchilla ratio 轴]
    Q --> S[失效条件: RMSNorm gain / exotic optimizer / weight decay]
    R --> T[不确定性与更大尺度失效风险]
```

## 两讲合起来到底在讲什么

Lecture 09 给出的是“对象、图像语言和方法论底线”。它先定义 scaling laws 的用途，再从最简单的数据缩放入手，把 log-log 直线、幂律、参数型与非参数型误差直觉建立起来；随后把问题推进到数据混配、重复训练、架构比较、optimizer、aspect ratio、critical batch，以及固定 FLOPs 下的数据-模型联合最优配比，最后用 Kaplan/Chinchilla 的分歧强调缩放律对计数口径、warmup 和拟合过程极度敏感。[课件: lecture_09.pdf p.1-p.7] [课件: lecture_09.pdf p.45-p.52]

Lecture 11 则假设你已经接受这套框架，开始问更实际的问题：公开大模型团队到底怎样做这些 scaling studies，怎样省掉昂贵 sweep，怎样把最优 batch、learning rate、optimizer 与参数化规则从小模型迁移到大模型，以及为什么这些规律仍然会在真实训练里失效。[00:00:05-00:02:16][课件: lecture_11.pdf p.2-p.4] [01:15:52-01:16:58][课件: lecture_11.pdf p.58]

## Lecture 09 基础缩放主线

### 1. 数据缩放是所有后续缩放的起点

Lecture 09 先强调，若模型相对数据足够大，并且系统仍处于 power-law regime，那么把数据量放到横轴、把误差或 loss 放到纵轴，在 log-log 图上常出现近似直线；这就是课堂里反复使用的最基本缩放对象。[课件: lecture_09.pdf p.7]

两条支持这一图像的公式直觉是：

- 均值估计例子：

$$
\mathbb E[(\hat\mu-\mu)^2] = \sigma^2 / n
$$

按 Lecture 09 notes 的记法，取对数后写成：

$$
\log(\text{Error}) = -\log n + 2\log\sigma
$$

这一步的作用不是证明语言模型就是均值估计，而是说明“幂律并不神秘”。[Lecture 09 NOTES: 002]

- 非参数估计直觉：误差可近似按 $n^{-1/d}$ 衰减，因此 log-log 斜率可慢到 $-1/d$，这被用来解释为什么神经网络经验指数经常远慢于 $-1$。[Lecture 09 NOTES: 002]

### 2. Lecture 09 的数据 scaling recipe

Lecture 09 的数据 recipe 不是“直接堆更多 token”，而是先判断你是否还在 power-law regime，再做 mixture、repetition 和 compute 分配判断。老师明确说，如果模型相对数据太小，就会接近 irreducible error regime，此时简单加数据不会继续给出同样的幂律收益。[Lecture 09 NOTES: 003]

这时最重要的分析框架是 intercept 与 slope：很多数据干预会改变截距，但不明显改变斜率；如果这一点成立，小规模上最好的 mixture 往往也会在更大规模继续最好，因为变的是整条线的位置，而不是资源收益速度。[Lecture 09 NOTES: 003]

### 3. Lecture 09 的模型 scaling recipe

Lecture 09 把模型工程也纳入同一套框架：架构、optimizer、层数、宽深比、MoE 参数口径都应先在小模型上看缩放曲线，再决定大模型是否值得做。老师给出的课堂判断标准很明确：如果某个干预在 scaling law 里看不出持续优势，就不要轻易相信它能在大规模上带来可靠收益。[Lecture 09 NOTES: 004]

这里最重要的经验不是某个具体架构，而是两个判断：

- 若某个方案 slope 更差，那么规模继续放大后它最终会输掉。
- 若某个方案主要只改善 intercept，那么它更像“常数项收益”，而不是“改变长期扩展速度”。[Lecture 09 NOTES: 004]

### 4. Lecture 09 的 batch / learning rate / downstream 边界

Lecture 09 给出 critical batch size 的机械估法。若目标是尽快达到某个 target loss，就记录达到它所需的步数 $S$ 与样本数 $E$，并使用：

$$
E = S \times B
$$

再以拟合得到的最少步数 $S_{\min}$ 与最少样本数 $E_{\min}$ 平衡代价，取：

$$
B_{\text{crit}} \approx E_{\min} / S_{\min}
$$

Lecture 09 notes 明确给出的是这个结构与直觉，没有把更完整 trade-off 函数写全，因此这里不补写额外公式。[Lecture 09 NOTES: 005][需回听]

对 learning rate，Lecture 09 只给路线级总结，不给唯一闭式处方：一条路线是拟合最优 learning rate 随规模变化，一条路线是通过重新参数化让不同规模的最优 learning rate 尽量不变；这恰好为 Lecture 11 的 DeepSeek 路线与 muP 路线埋下伏笔。[Lecture 09 NOTES: 006]

Lecture 09 还特别强调 upstream/downstream 不完全一致。推荐做法是：先在低方差、规则的预训练 loss 或 perplexity 上建立缩放规律，再谨慎处理向 downstream 的 transfer，因为后者更高方差、更不平滑。[Lecture 09 NOTES: 006]

### 5. Lecture 09 的 compute-optimal recipe

Lecture 09 的联合缩放终点，是在固定 FLOPs 下同时选择模型大小与数据量。老师把三种方法并列：

- lower envelope method：从所有训练曲线中取“同一 FLOP 下最低 loss”的下包络，再拟合最优模型尺度。[Lecture 09 NOTES: 007]
- IsoFLOP method：固定多个 FLOP budget，在每个预算下沿参数量与数据量的 trade-off 扫描，再对每个预算取最优点。老师明确说这是他最偏爱的路线。[Lecture 09 NOTES: 007]
- joint fits：先假设联合函数形式，再在参数量与数据量网格上做曲面拟合。它更 brute-force，也更依赖拟合与口径选择。[Lecture 09 NOTES: 007]

Lecture 09 真正想教的不是“20 tokens per parameter”这句口号，而是：即使都是合理方法，Kaplan 与 Chinchilla 仍能因为参数计数、warmup、optimizer tuning 和坐标定义而得到很不一样的 compute-optimal prescription。因此，结论必须和 recipe 一起读。[Lecture 09 NOTES: 007] [Lecture 09 NOTES: 008] [课件: lecture_09.pdf p.45-p.52]

## Lecture 11 现代实践主线

### 1. 两条路线：稳定化 vs 拟合

Lecture 11 从一开始就把近年公开 scaling recipe 分成两条路线：

- MiniCPM / muP 路线：尽量让最优 learning rate 不随模型规模剧烈漂移，再在这个更稳定的空间里做外推。[00:05:00-00:07:13][课件: lecture_11.pdf p.8-p.9]
- DeepSeek / StepFun 路线：承认最优 batch 和 learning rate 会随规模变动，直接用小规模 grid search 与 IsoFLOPs 分析把规律拟合出来，再外推到大模型。[00:20:03-00:22:30] [00:33:31-00:39:58][课件: lecture_11.pdf p.19-p.24] [课件: lecture_11.pdf p.34-p.37]

这两条路线都继承了 Lecture 09 的前提：真正有价值的是“小模型拟合，大模型验证或部署”，而不是只收集一堆大模型单点结果。[00:21:25-00:22:03][课件: lecture_11.pdf p.24]

### 2. Lecture 11 的 compute / data / model scaling recipe

Lecture 11 没有推翻 Lecture 09 的 compute-optimal 分析，而是把它变成更低成本、可执行的实验流程。

MiniCPM 侧的关键是 WSD。它把学习率分成 warmup、stable、decay 三段，其中 decay 常只占总训练的 10% 到 20%。这样在做 Chinchilla 式数据 sweep 时，可以回退到 stable 末尾，复用前段训练，只重做末段 decay，而不是每次延长数据长度都整段重训。[00:11:09-00:14:32][课件: lecture_11.pdf p.14-p.16]

DeepSeek 侧的关键是用 IsoFLOPs curve 得到更“干净”的 fixed-compute trade-off，并用小规模灰点拟合去预测真实大模型星点结果。Lecture 11 明确把这件事作为 scaling law 的终局图像：拟合不是目的，预测大模型才是目的。[00:20:39-00:22:03][课件: lecture_11.pdf p.23-p.24]

StepFun 则把这条拟合路线系统化：

- 最优 batch size 主要依赖数据量 $D$，与模型大小关系较小。[00:35:20-00:36:02][课件: lecture_11.pdf p.36]
- 老师把它的直觉版重写为“batch size 大体像数据量的平方根”。这是一条 notes 明确记下的经验趋势，但没有给出更严格系数式，因此这里只保留趋势，不补写参数化公式。[00:38:08-00:39:03]
- 最优 learning rate 随模型变大而变小，随数据量变大而变大；但老师同时说，对数据量的依赖可能更脆弱、与设定强相关。[00:36:08-00:36:40] [00:37:44-00:38:04]

### 3. Lecture 11 的超参数迁移 recipe

Lecture 11 对 hyperparameter transfer 的核心要求是：不要把小模型最优点机械移植到大模型，而要先说明你是通过哪条路线迁移的。

- 若走拟合路线，就像 DeepSeek / StepFun 那样，先做高分辨率 grid search，在不同模型大小、数据量下提取最优 batch 与 learning rate，再拟合出随 compute、$D$ 或规模变化的规律。[00:31:51-00:39:58][课件: lecture_11.pdf p.33-p.37]
- 若走稳定化路线，就像 MiniCPM / muP 那样，先改变参数化与层学习率规则，让最优 learning rate 对宽度变化更不敏感，再把小模型上找出的最优值迁移到更宽模型。[00:05:00-00:07:13] [01:13:19-01:15:47]

Lecture 11 给出的迁移边界也很明确：如果数据分布变了、weight decay 变了、架构变了，或者你已经跑到别人 grid search 没覆盖的 compute regime，仍然值得重做自己的分析；老师把这类判断直说成仍然包含很多 “vibes”。[00:39:58-00:41:38]

### 4. Lecture 11 的 optimizer 与参数化 recipe

Lecture 11 在 optimizer 上要求至少控制两个轴：

- compute 轴：固定模型-数据比例，观察算法增益是否随规模持续存在。[00:44:54-00:46:00][课件: lecture_11.pdf p.40]
- Chinchilla ratio 轴：观察 token-to-parameter ratio 变化时，相对优劣是否改变。[00:46:00-00:47:21][课件: lecture_11.pdf p.40]

如果只沿 compute 看、不沿 ratio 看，就可能把配比效应误读成 optimizer 优劣；如果 learning rate 或 weight decay 没单独调公平，就会把超参数失配误读成算法结论。[00:43:59-00:47:21][课件: lecture_11.pdf p.39-p.40]

muon 在这讲里的角色不是“最终胜出的优化器”，而是一个提醒：小 benchmark 上很强的东西，大尺度上未必稳定；但 Kimi K2 又说明它至少可以在大规模预训练中工作。Lecture 11 因此只给出“可行性已证明，普遍优势未证明”的结论。[00:52:52-00:54:11][课件: lecture_11.pdf p.43]

## 本模块中真正被支持的公式与关系

下表只收录两份 notes 明确支持的公式、比例或趋势，不额外补齐未给出的论文原式。

| 对象 | 被 notes 支持的内容 | 来源 |
| --- | --- | --- |
| 数据缩放 toy example | $\mathbb E[(\hat\mu-\mu)^2] = \sigma^2 / n$ | Lecture 09 NOTES: 002 |
| log-log 线性化 | $\log(\text{Error}) = -\log n + 2\log\sigma$ | Lecture 09 NOTES: 002 |
| 非参数估计直觉 | 误差可近似按 $n^{-1/d}$ 缩放 | Lecture 09 NOTES: 002 |
| critical batch 关系 | $E = S \times B$ | Lecture 09 NOTES: 005 |
| critical batch 近似 | $B_{\text{crit}} \approx E_{\min}/S_{\min}$ | Lecture 09 NOTES: 005 |
| WSD 结构 | warmup + stable + decay，decay 常约占 10%-20% | [00:11:09-00:12:04][课件: lecture_11.pdf p.14-p.15] |
| StepFun batch 趋势 | 最优 batch 主要依赖数据量 $D$，老师重写成大体像 $\sqrt D$ | [00:35:20-00:36:02] [00:38:08-00:39:03] |
| StepFun learning rate 趋势 | 最优 LR 随模型变大而变小，随数据变多而变大 | [00:36:08-00:36:40] |
| muon 更新 | 对矩阵更新 $B_t = USV^\top$，把奇异值归一后用 $UV^\top$ 更新 | [00:50:57-00:52:41][课件: lecture_11.pdf p.42] |
| muP A1 | 初始化激活保持 $\Theta(1)$ | [01:00:40-01:02:03][课件: lecture_11.pdf p.46] |
| muP A2 | 一次梯度更新后的激活变化保持 $\Theta(1)$ | [01:00:40-01:02:03][课件: lecture_11.pdf p.46] |
| 层范数尺度 | 若单激活是 $\Theta(1)$，整层范数为 $\Theta(\sqrt{n_l})$ | [01:02:03-01:02:29][课件: lecture_11.pdf p.46] |
| 线性层 rank-1 更新 | $\Delta W_l = -\eta_l \nabla_{h_l}\ell\, h_{l-1}^\top$ | [01:05:19-01:08:29][课件: lecture_11.pdf p.48] |
| muP 层学习率 | $\eta_l$ 按 fan-out / fan-in 缩放 | [01:09:54-01:10:24][课件: lecture_11.pdf p.49-p.50] |
| muP 对 Adam 的近似 | 层特定 learning rate 近似按 $1/n_{l-1}$ 缩放 | [01:09:54-01:10:24][课件: lecture_11.pdf p.49-p.50] |

## IsoFLOP、fitting、外推与不确定性

### IsoFLOP 在两讲中的位置

Lecture 09 把 IsoFLOP method 讲成固定 FLOPs 下最实用、最稳健、也最容易解释的联合缩放方法：对每个预算扫描参数与数据的 trade-off，再取最优点，最后拟合这些最优点如何随 compute 变化。[Lecture 09 NOTES: 007]

Lecture 11 则把这一方法直接用到近年公开 recipe 上。老师认为 DeepSeek 的曲线之所以比 MiniCPM 更“干净”，主要就是因为它使用了 IsoFLOPs sweep；StepFun 也延续了这种思路，只是把对象拓展到 batch 与 learning rate 等更细粒度超参数。[00:20:39-00:21:18][课件: lecture_11.pdf p.23-p.24] [00:33:31-00:39:58][课件: lecture_11.pdf p.34-p.37]

### 三种 fit 的关系

- lower envelope 更直观，但 Lecture 09 明确提示其定义细节并不简单。[Lecture 09 NOTES: 007]
- IsoFLOP 更符合课堂推荐做法，因为你能看到固定预算下的整条 trade-off 曲线与最小点，而不是只看包络线结果。[Lecture 09 NOTES: 007]
- joint fits 最统一，但也最依赖你提出的函数形式、参数口径和曲面拟合方式；Lecture 09 正是用 Kaplan/Chinchilla 的分歧来提醒你，这一步的敏感性不能被忽略。[Lecture 09 NOTES: 007] [Lecture 09 NOTES: 008]

### 外推什么时候有资格做

两讲共同支持的最低标准是：

1. 你先在小规模上看到了稳定趋势，而不是局部放大后偶然像一条直线的错觉。[Lecture 09 NOTES: 004]
2. 你知道自己在外推什么对象。Lecture 09 偏向先外推 upstream loss，Lecture 11 则把外推扩展到 batch、learning rate、optimizer 或参数化规则。[Lecture 09 NOTES: 006] [00:30:27-00:31:04]
3. 你保留了 recipe 条件。Lecture 09 用 Kaplan/Chinchilla discrepancy 讲这一点，Lecture 11 则用 StepFun 条件性、optimizer confounder 和 muP 失效条件再次讲这一点。[Lecture 09 NOTES: 008] [00:37:44-00:38:04] [00:43:59-00:47:21] [01:13:55-01:15:11]

### 本模块保留的不确定性

- Lecture 09 notes 明确标出：第 002 段和第 008 段有“prompt 页码少于 transcript 覆盖范围”或“页码跨度过大”的情况，因此某些推理主要来自 transcript，不宜擅自补充更多页码。[Lecture 09 NOTES: 易错点与待核对项]
- Lecture 09 的 critical batch trade-off 函数没有完整写出，因此这里只保留 $E = S \times B$ 与 $B_{\text{crit}} \approx E_{\min}/S_{\min}$。[Lecture 09 NOTES: 005][需回听]
- Lecture 11 对 StepFun 和若干后续论文只给趋势与口头解释，没有给唯一精确指数与常数，因此这里不把它们写成通用定律。[00:31:51-00:33:15] [00:36:08-00:38:58]
- Lecture 11 明确把 muP 推导称为 “physicists math”，依赖高维近似、无主阶抵消与 loss update 为 $O(1)$ 等强假设；因此相关公式要理解为构造原则与量级结果，不是课堂里已经证明完备的定理。[01:07:21-01:12:35][课件: lecture_11.pdf p.48-p.50]

## 两讲的差异

### 1. 问题层级不同

Lecture 09 主要在回答“scaling laws 是什么、为什么会出现、能用来比较什么、以及为什么联合缩放结论会受 recipe 影响”；Lecture 11 主要在回答“近年团队怎样把它做成能落地的训练 recipe，以及怎样处理 batch、learning rate、optimizer 和参数化漂移”。[课件: lecture_09.pdf p.1-p.7] [课件: lecture_09.pdf p.45-p.52] [00:00:05-00:02:16][课件: lecture_11.pdf p.2-p.4]

### 2. 方法焦点不同

Lecture 09 更强调对象与方法论：数据 scaling、intercept/slope、critical batch、lower envelope / IsoFLOP / joint fits、Kaplan/Chinchilla discrepancy。Lecture 11 更强调可执行配方：WSD、small-scale ladder、grid search contour、compute 轴与 ratio 轴、muP 的 invariance 推导与 stress test。[Lecture 09 NOTES: 003-008] [Lecture 11 NOTES: 2-8]

### 3. 对“稳定性”的处理方式不同

Lecture 09 提供两条高层路线但不站死边：可以显式拟合最优 learning rate 的变化，也可以通过重新参数化让它尽量不变。[Lecture 09 NOTES: 006]

Lecture 11 把这两条路线具体化成两派：

- DeepSeek / StepFun：直接拟合变化规律。[00:22:14-00:22:30] [00:33:31-00:39:58]
- MiniCPM / muP：主动消减变化，再迁移最优值。[00:05:00-00:07:13] [01:09:54-01:15:47]

### 4. 风险呈现方式不同

Lecture 09 最强的风险案例是 Kaplan 与 Chinchilla：同为合理方法，结果却能被参数口径、warmup 和优化器调优强烈左右。[Lecture 09 NOTES: 008]

Lecture 11 最强的风险案例有三个：

- StepFun 规律对数据条件敏感。[00:37:44-00:38:04]
- optimizer 结论会被超参数失配与 Chinchilla ratio 污染。[00:43:59-00:47:21]
- muP 与某些优化器在更大尺度可能前面很好看、后面突然失效或爆炸。[00:47:23-00:48:58] [01:13:55-01:15:11]

## 常见失败模式

### Lecture 09 暴露出的失败模式

- 把 scaling laws 当成训练后图表，而不是训练前决策工具。[Lecture 09 NOTES: 易错点]
- 把局部近似线性误当成全局幂律。[Lecture 09 NOTES: 004]
- 默认所有干预都会改 slope，而忽略很多干预其实主要改 intercept。[Lecture 09 NOTES: 003]
- 把上游 perplexity 最优直接等同于下游最优。[Lecture 09 NOTES: 006]
- 记住 Chinchilla 口号，却忘了它依赖拟合方法、参数口径与训练 recipe。[Lecture 09 NOTES: 008]

### Lecture 11 暴露出的失败模式

- 把 WSD 只看成“另一条学习率曲线”，忽略它真正重要的是降低数据 sweep 的重训成本。[00:12:04-00:14:32]
- 把任何 batch/LR scaling law 当通用真理，而不看自变量、数据分布和 recipe 是否一致。[00:31:51-00:33:15] [00:37:44-00:38:04]
- 比较 optimizer 时没单独调 learning rate 与 weight decay。[00:43:59-00:44:50]
- 只看 compute 轴，不看 Chinchilla ratio 轴。[00:46:00-00:47:21]
- 以为小尺度看起来线性很多个数量级，就足以证明更大尺度也成立；cautious AdamC 的例子明确反驳了这点。[00:47:23-00:48:58][课件: lecture_11.pdf p.41]
- 在 muP 上忽略 learned RMSNorm gain、Lion 一类 sign-based / exotic optimizer、以及较强 decoupled weight decay 的破坏作用。[01:13:55-01:15:11][课件: lecture_11.pdf p.53-p.56]

## 复习标记

### 先复习 Lecture 09 的标记

- 如果你还不能解释为什么 log-log 直线会自然出现，回到数据缩放与 toy example 部分。[Lecture 09 NOTES: 002]
- 如果你说不清 intercept 与 slope 分别对应什么，回到 data mixture 与 optimizer/architecture 例子。[Lecture 09 NOTES: 003-004]
- 如果你记得“20 tokens per parameter”，却说不出 lower envelope、IsoFLOP 与 joint fits 的差别，回到联合缩放部分。[Lecture 09 NOTES: 007]
- 如果你把 Chinchilla 当成单一固定答案，而说不出参数计数、warmup、optimizer tuning 的作用，回到 discrepancy 部分。[Lecture 09 NOTES: 008]

### 再复习 Lecture 11 的标记

- 如果你说不清 MiniCPM 与 DeepSeek 的根本差异，回到两条路线对比。[00:22:14-00:22:30]
- 如果你会背 WSD 三段，但说不出为什么它省成本，回到 stable checkpoint 回滚逻辑。[00:12:04-00:12:38]
- 如果你只记住 StepFun 的趋势，却忘了它对数据条件敏感，回到老师关于 “vibes” 和条件性的提醒。[00:37:44-00:38:04] [00:41:14-00:41:38]
- 如果你会背 muP 的结论，却说不出 A1/A2、rank-1 更新和 layer-specific learning rate 是如何连起来的，回到 00:59:56-01:12:35。[课件: lecture_11.pdf p.46-p.50]

## 掌握标准

- 能用自己的话完整复述 Lecture 09 的主线：数据缩放为何自然、数据与模型工程怎样共享 intercept/slope 框架、为什么 fixed-FLOPs trade-off 要优先用稳健拟合方法、以及为什么 Kaplan/Chinchilla 分歧说明必须尊重 process。[Lecture 09 NOTES: 001-008]
- 能比较 Lecture 11 的两条 modern recipe：MiniCPM/muP 的稳定化路线与 DeepSeek/StepFun 的拟合路线，并说出它们在 learning rate / batch handling 上的根本分歧。[Lecture 11 NOTES: 1-4]
- 能准确写出本模块允许使用的关键关系：$\sigma^2/n$、$n^{-1/d}$、$E=S\times B$、$B_{\text{crit}}\approx E_{\min}/S_{\min}$、$\Delta W_l=-\eta_l\nabla_{h_l}\ell h_{l-1}^\top$、A1/A2、$\eta_l$ 的 fan-out / fan-in 缩放。[Lecture 09 NOTES: 002,005] [Lecture 11 NOTES: 7-8]
- 能指出至少三类风险来源：数据条件变化、超参数失配或实验轴不完整、以及参数化/optimizer 在更大尺度上的失效。[00:37:44-00:38:04] [00:43:59-00:48:58] [01:13:55-01:15:11]

## 10 个递进练习（含答案）

### 练习 1

问：Lecture 09 把 scaling laws 的首要用途定义成什么？

答：在高成本大训练之前，先在小规模实验上建立可外推规律，用来指导架构、数据、batch、learning rate 和 compute 分配决策，而不是事后画图总结。[Lecture 09 NOTES: 001]

### 练习 2

问：为什么 Lecture 09 反复强调 log-log 直线？

答：因为它意味着误差或 loss 与资源之间近似满足幂律关系；这让小规模趋势可以被压缩成少量斜率与截距信息，再外推到更大尺度。[Lecture 09 NOTES: 002]

### 练习 3

问：Lecture 09 用哪两个数学直觉说明幂律“并不神秘”？

答：一是均值估计的 $\sigma^2/n$ 与其 log-log 线性化；二是非参数估计里误差近似按 $n^{-1/d}$ 衰减，因此神经网络出现较慢经验指数并不奇怪。[Lecture 09 NOTES: 002]

### 练习 4

问：为什么老师说很多数据干预与优化器干预主要改 intercept，而不是 slope？

答：因为在多种经验例子里，干预会把整条曲线平移到更低 loss，但不明显改变资源增加时的收益速度；这也是为什么小规模最优配方常能迁移到更大规模。[Lecture 09 NOTES: 003-004]

### 练习 5

问：Lecture 09 为什么更偏爱 IsoFLOP method？

答：因为它在固定 FLOPs 预算下直接扫描参数与数据 trade-off，能清楚看到每个预算下的最优点，做法相对稳健、可解释，也更适合工程决策。[Lecture 09 NOTES: 007]

### 练习 6

问：Lecture 11 中 MiniCPM 与 DeepSeek 的根本差异是什么？

答：MiniCPM 更像稳定化路线，试图通过 muP 和相关 recipe 让敏感超参数对规模不那么敏感；DeepSeek 更像拟合路线，承认最优 batch 与 learning rate 会变，并直接拟合这种变化。[00:22:14-00:22:30]

### 练习 7

问：WSD 为什么能降低 Chinchilla 式 sweep 的成本？

答：因为在 warmup-stable-decay 结构下，可以把 checkpoint 回退到 stable 末尾，复用前段训练，只重做最后一小段 decay，而不必为每个数据长度从头重训完整 run。[00:11:09-00:14:32][课件: lecture_11.pdf p.14-p.16]

### 练习 8

问：StepFun 给出的最关键 batch / learning rate 趋势是什么？

答：最优 batch size 主要由数据量 $D$ 驱动，老师把趋势总结成大体像 $\sqrt D$；最优 learning rate 随模型变大而变小，随数据量变大而变大，但这些规律对数据与设定敏感。[00:35:20-00:39:03]

### 练习 9

问：研究 optimizer scaling 时，为什么至少要同时看 compute 轴和 Chinchilla ratio 轴？

答：因为算法可能在某个 compute 区间表现好，但在更大尺度收益消失；也可能不是算法本身更好，而是只在某个 token-to-parameter ratio 区间占优。如果不同时控制这两个轴，就会把 confounder 误读成算法优势。[00:44:54-00:47:21]

### 练习 10

问：muP 在 Lecture 11 里最值得记住的结论与边界各是什么？

答：最值得记住的结论是，它通过 A1/A2 不变量与层级学习率缩放，能显著减弱最优 learning rate 随宽度漂移；最值得记住的边界是，它依赖量级近似与强假设，且会被 learned RMSNorm gain、某些 sign-based / exotic optimizer 与较强 decoupled weight decay 破坏。[01:00:40-01:15:11][课件: lecture_11.pdf p.46-p.57]

## 推荐复习顺序

1. 先复习 Lecture 09 的 001-003 段，把“为什么要做 scaling laws”“log-log 幂律直觉”“intercept/slope”三件事重新连起来。[Lecture 09 NOTES: 001-003]
2. 再复习 Lecture 09 的 004-008 段，把“模型工程缩放”“critical batch”“upstream/downstream caution”“IsoFLOP 与 discrepancy”串成完整工程方法论。[Lecture 09 NOTES: 004-008]
3. 然后复习 Lecture 11 的 1-4 段，先把 MiniCPM、WSD、DeepSeek、StepFun 这条现代 recipe 主线抓住。[Lecture 11 NOTES: 1-4]
4. 最后复习 Lecture 11 的 5-8 段，重点看 optimizer confounder、muon、muP A1/A2 与失效条件，把“为什么 scaling in the wild 仍然 messy”理解透。[Lecture 11 NOTES: 5-8]

## 最后提醒

如果你要把这两讲浓缩成一套工作顺序，最接近老师原意的版本是：先在小规模上找稳定趋势，再决定用拟合路线还是稳定化路线；优先在 upstream loss 上建立低方差规律；固定 FLOPs 时优先考虑 IsoFLOP；比较 optimizer 或 architecture 时同时审查超参数公平性与实验轴完整性；最后把所有结论都连同参数口径、warmup、schedule 与不确定性一起交付，而不是只交一个幂律指数。[Lecture 09 NOTES: 006-008] [Lecture 11 NOTES: 2-8]
