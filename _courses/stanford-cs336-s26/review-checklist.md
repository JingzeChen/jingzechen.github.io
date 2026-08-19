---
uid: stanford-cs336-s26-review-checklist
type: course
document_type: resource
resource_kind: review
resource_order: 3
course: stanford-cs336-s26
title: Stanford CS336 Spring 2026 复核清单
description: 按风险回查自动 transcript、课件与视频中的未决证据。
excerpt: 按风险回查自动 transcript、课件与视频中的未决证据。
content_lang: zh-CN
permalink: "/courses/stanford-cs336-s26/review-checklist/"
toc: true
---

> 本清单从 152 份分段课堂笔记中的 `[需回听 HH:MM:SS]` 自动去重汇总。
> 标记表示需要回到人工字幕、录像、Python executable lecture 或 PDF 核验，不等于已确认错误。

## 汇总

- 唯一待回听项：`91`。
- 涉及媒体讲次：`7/18`。
- 分类：`{'上下文或语义不清': 75, '代码/课件与口述差异': 6, '公式、符号或数值': 4, '论文、术语或名称': 6}`。
- 优先级：公式/符号/数值 > 代码或课件差异 > 论文/术语/名称 > 一般语义。
- Lecture 18 没有官方录像或材料，不属于待回听队列，而是独立来源缺口。

## 按讲次复核

### Lecture 01: Overview, tokenization

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/001/)。
- `00:05:59` · **公式、符号或数值** · 老师口头提到的 FLOPs 比例变化出自较早材料，字幕中的年份与原图出处需二次核对。 ([001.md](/courses/stanford-cs336-s26/lectures/001/#section-01))
- `00:09:40` · **上下文或语义不清** · “accuracy = efficiency x resources” 是课堂解释框架，不是正式定律，若后续讲义另有更精确定义需对齐。 ([001.md](/courses/stanford-cs336-s26/lectures/001/#section-01))
- `00:12:54` · **代码/课件与口述差异** · 字幕中的 “The atom optimizer attention mechanism” 很可能是口误或识别错误；按上下文应是先提 Adam optimizer 再提 attention mechanism，可与 [代码: lecture_01.py p.5] 对照复核。 ([002.md](/courses/stanford-cs336-s26/lectures/001/#section-02))
- `00:13:43` · **代码/课件与口述差异** · “Google had a paper foreshadowing prompt in, response out” 的具体论文名在本段口述里未明确，不应自行补写。 ([002.md](/courses/stanford-cs336-s26/lectures/001/#section-02))
- `00:20:39` · **上下文或语义不清** · 关于“第一作业工作量等于 224n 五个作业”的引述是否逐字准确，可后续与课程网站原评价对照。 ([003.md](/courses/stanford-cs336-s26/lectures/001/#section-03))
- `00:29:05` · **上下文或语义不清** · 字幕中 “bites” 应为 “bytes”，这里只按语义整理，不额外扩写。 ([003.md](/courses/stanford-cs336-s26/lectures/001/#section-03))
- `00:30:41` · **论文、术语或名称** · 字幕中的 “Blow up has evolved” 显然不顺，按上下文这里只保留为“归一化等细节持续演化”，不自行补具体术语。 ([004.md](/courses/stanford-cs336-s26/lectures/001/#section-04))
- `00:36:44` · **公式、符号或数值** · “training SMDB on model” 为字幕识别错误；可确定老师是在举用公式估算训练某规模模型所需 FLOPs 的例子，但本段不擅自补完整原句。 ([004.md](/courses/stanford-cs336-s26/lectures/001/#section-04))
- `00:44:14` · **上下文或语义不清** · Assignment 2 细节“CAAs have grand plans” 中 CAs 的复数表达字幕略乱，但不影响意思：系统作业可能改版。 ([005.md](/courses/stanford-cs336-s26/lectures/001/#section-05))
- `00:46:23` · **公式、符号或数值** · 老师举例时提到的目标与小规模预算上限是口头示意，具体数值设置以后续作业说明为准。 ([005.md](/courses/stanford-cs336-s26/lectures/001/#section-05))
- `00:51:35` · **代码/课件与口述差异** · Marin 项目训练完成时间是老师现场口述的时点性信息，这里仅保留为“当周即将完成”，不写死课后事实。 ([006.md](/courses/stanford-cs336-s26/lectures/001/#section-06))
- `00:59:17` · **上下文或语义不清** · “mid training” 的口头定义偏经验性，本段按老师原意记为“预训练后期加入的高质量数据”。 ([006.md](/courses/stanford-cs336-s26/lectures/001/#section-06))
- `01:05:55` · **上下文或语义不清** · 老师现场说无法打开交互网站，因此本段关于示例仅以口头描述为准，不额外补网站内容。 ([007.md](/courses/stanford-cs336-s26/lectures/001/#section-07))
- `01:08:57` · **上下文或语义不清** · “Life is good” 等口语化过渡未单独保留，只保留其论证作用。 ([007.md](/courses/stanford-cs336-s26/lectures/001/#section-07))
- `01:13:58` · **上下文或语义不清** · 老师说最高频 pair 有并列时“就取第一个”，这是 toy code 的口头说明；真实实现中的 tie-breaking 规则未在本段展开，不应补写。 ([008.md](/courses/stanford-cs336-s26/lectures/001/#section-08))
- `01:17:04` · **代码/课件与口述差异** · 老师口述 pre-tokenization 的 chunking 细节较快，这里只按“先把文本拆块再在块内应用 tokenizer”记录，不外推具体规则。 ([008.md](/courses/stanford-cs336-s26/lectures/001/#section-08))

### Lecture 02: PyTorch (einops), resource accounting (FLOPs, memory, arithmetic intensity)

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/002/)。
- 当前分段笔记没有待回听标记。

### Lecture 03: Architectures, hyperparameters

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/003/)。
- 当前分段笔记没有待回听标记。

### Lecture 04: Attention alternatives and mixture of experts

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/004/)。
- 当前分段笔记没有待回听标记。

### Lecture 05: GPUs, TPUs

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/005/)。
- 当前分段笔记没有待回听标记。

### Lecture 06: Kernels, Triton

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/006/)。
- 当前分段笔记没有待回听标记。

### Lecture 07: Parallelism

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/007/)。
- `00:04:31` · **上下文或语义不清** · 老师说明 trace 模式时提到的“special single process mode”字幕较快，笔记只保留“课堂 trace 不做真正 multiprocessing”的确定信息。 ([001.md](/courses/stanford-cs336-s26/lectures/007/#section-01))
- `00:06:44` · **上下文或语义不清** · 本段末尾进入 collective operations 示例前，字幕有少量停顿与重复，后续具体定义以下一段内容为准。 ([001.md](/courses/stanford-cs336-s26/lectures/007/#section-01))
- `00:10:14` · **上下文或语义不清** · 字幕写成 “the inverse of scatter is scatter”，结合上下文应为 “the inverse of scatter is gather”，这里按老师后续完整解释记为 gather。 ([002.md](/courses/stanford-cs336-s26/lectures/007/#section-02))
- `00:17:12` · **代码/课件与口述差异** · all-to-all 示例里老师口头指向具体元素时有若干代词与停顿，笔记采用代码页上给出的张量布局固定含义。[代码: lecture_07.py p.3] ([002.md](/courses/stanford-cs336-s26/lectures/007/#section-02))
- `00:19:27` · **上下文或语义不清** · 老师引用此前 MoE 课程时人声压缩明显，笔记仅保留“要做负载均衡”这一确定结论。 ([002.md](/courses/stanford-cs336-s26/lectures/007/#section-02))
- `00:28:59` · **论文、术语或名称** · 老师提到 Meta 的论文与具体模型名时字幕含糊，只保留“Meta 探索过 RoCE”这一不影响主线的结论。 ([003.md](/courses/stanford-cs336-s26/lectures/007/#section-03))
- `00:31:45` · **上下文或语义不清** · 老师解释 NVL72 的 tray 物理结构时有一个词字幕识别不稳，笔记只保留“两颗 CPU、每颗 CPU 接四张 GPU、每个 tray 共八张 GPU”的确定信息。 ([004.md](/courses/stanford-cs336-s26/lectures/007/#section-04))
- `00:33:33` · **上下文或语义不清** · “NCCL 是否对 multi-node 优化”的学生问题里个别连接词不清，老师的结论性回答是“应当针对这类大模型工作负载做过大量优化”。 ([004.md](/courses/stanford-cs336-s26/lectures/007/#section-04))
- `00:35:43` · **上下文或语义不清** · 关于 TPUs 的追问中学生提问内容与老师的快速回应并不完整，笔记不扩写 TPU 架构细节。 ([003.md](/courses/stanford-cs336-s26/lectures/007/#section-03))
- `00:43:01` · **公式、符号或数值** · 老师说 reduce-scatter 前输出张量“碰巧是 0，但也可以是别的值”，原字幕在数值描述上稍快，笔记按其逻辑意义整理。 ([005.md](/courses/stanford-cs336-s26/lectures/007/#section-05))
- `00:44:56` · **上下文或语义不清** · 关于异步 collective 结束后“call a wait or a barrier”的表述较快，笔记保留“需显式等待结果完成”这一确定结论。 ([005.md](/courses/stanford-cs336-s26/lectures/007/#section-05))
- `00:54:25` · **上下文或语义不清** · “先 barrier 再 synchronize 行不行”的讨论中老师明确表示自己不完全确定，笔记保留了他给出的工程直觉而未把它写成严格规则。 ([006.md](/courses/stanford-cs336-s26/lectures/007/#section-06))
- `00:55:21` · **上下文或语义不清** · “multilayer MLPs” 后老师自我纠正“MLP 已经包含 multilayer”这一句节奏较快，笔记只保留其教学含义。 ([006.md](/courses/stanford-cs336-s26/lectures/007/#section-06))
- `01:00:47` · **上下文或语义不清** · “batch size has to be at least world size”是老师的课堂口语表述，笔记按“这套简单切法需要如此”理解，未扩写到更宽泛的工程变体。 ([007.md](/courses/stanford-cs336-s26/lectures/007/#section-07))
- `01:08:00` · **上下文或语义不清** · 关于 backprop 时老师原句中个别字幕残缺，结合上下文与后续解释整理为“backward 用 reduce-scatter 对偶处理梯度”。 ([007.md](/courses/stanford-cs336-s26/lectures/007/#section-07))
- `01:10:48` · **上下文或语义不清** · 老师提到“Wednesday 由 Tatsu 继续讲 micro-batches”时专有名字幕识别不稳，笔记仅保留“下一次会继续深挖”这一课堂安排。 ([008.md](/courses/stanford-cs336-s26/lectures/007/#section-08))
- `01:18:26` · **上下文或语义不清** · 关于 JAX/TPU 编译器路线的个别连接词字幕缺失，笔记未补写课上未明确说明的编译器内部机制。 ([008.md](/courses/stanford-cs336-s26/lectures/007/#section-08))

### Lecture 08: Parallelism

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/008/)。
- 当前分段笔记没有待回听标记。

### Lecture 09: Scaling laws

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/009/)。
- 当前分段笔记没有待回听标记。

### Lecture 10: Inference

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/010/)。
- `00:01:49` · **上下文或语义不清** · 字幕中“actual use app of vantage point”显然是识别错误，这里按上下文理解为从实际使用视角看 inference 是重复成本。 ([001.md](/courses/stanford-cs336-s26/lectures/010/#section-01))
- `00:04:28` · **上下文或语义不清** · SGLang 被描述为“特别适合 agentic workloads，但还没那么流行”，原句细节可再核对。 ([001.md](/courses/stanford-cs336-s26/lectures/010/#section-01))
- `00:17:04` · **上下文或语义不清** · 老师把这里说成是方阵 N/3 结果的“analog”，细节表述可以再和前面系统课原推导对齐。 ([002.md](/courses/stanford-cs336-s26/lectures/010/#section-02))
- `00:20:44` · **上下文或语义不清** · 字幕中 “here is a prompt never going to give you” 口语跳转较乱，这里按老师常用的 Rick Astley 前缀示例理解。 ([003.md](/courses/stanford-cs336-s26/lectures/010/#section-03))
- `00:25:49` · **上下文或语义不清** · 字幕把 matmul 误识为 “MAmmoTH”，这里按语义统一整理为 matmul。 ([003.md](/courses/stanford-cs336-s26/lectures/010/#section-03))
- `00:31:07` · **上下文或语义不清** · 字幕把 generation 说成 “generated nation intensity”，这里按语义整理为 generation intensity。 ([004.md](/courses/stanford-cs336-s26/lectures/010/#section-04))
- `00:36:17` · **上下文或语义不清** · 字幕中的 “Llama 2.13B” 应为 “Llama 2 13B”。 ([004.md](/courses/stanford-cs336-s26/lectures/010/#section-04))
- `00:46:20` · **上下文或语义不清** · 老师说“beat it into your head that memory is the bottleneck”是口语化表达，这里只保留实质含义。 ([005.md](/courses/stanford-cs336-s26/lectures/010/#section-05))
- `00:49:32` · **上下文或语义不清** · 字幕中的 “a kind of a sparsity of 1 one five” 应是指 K:N = 1:5 的 GQA 比例。 ([005.md](/courses/stanford-cs336-s26/lectures/010/#section-05))
- `00:50:58` · **上下文或语义不清** · 老师对 GQA 评测结果的保留态度是口语化表达，这里只保留“不能脱离具体模型泛化”的实质结论。 ([006.md](/courses/stanford-cs336-s26/lectures/010/#section-06))
- `01:06:55` · **上下文或语义不清** · 字幕中的 “in three” 应为 int3。 ([007.md](/courses/stanford-cs336-s26/lectures/010/#section-07))
- `01:14:35` · **代码/课件与口述差异** · 老师口语里的接受规则描述略跳跃，这里以代码材料中的 rejection-sampling 版本解释为准。[代码: lecture_10.py p.14] ([008.md](/courses/stanford-cs336-s26/lectures/010/#section-08))
- `01:17:35` · **上下文或语义不清** · Orca 被老师称为“very early on”的系统，课堂里没有进一步展开时间背景，这里不额外补历史信息。 ([008.md](/courses/stanford-cs336-s26/lectures/010/#section-08))
- `01:19:44` · **上下文或语义不清** · 开头“but this is the core idea at that time”承接上一页口头转场，具体所指对象在本段字幕里不完整，这里不扩写。 ([009.md](/courses/stanford-cs336-s26/lectures/010/#section-09))
- `01:24:34` · **上下文或语义不清** · 老师把 paging 与 speculative execution 并列为系统思路，后者在本讲中主要借 speculative sampling 侧面体现，未单独做传统系统定义。 ([009.md](/courses/stanford-cs336-s26/lectures/010/#section-09))

### Lecture 11: Scaling laws

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/011/)。
- `00:04:47` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/stanford-cs336-s26/lectures/011/#section-01))
- `00:12:59` · **上下文或语义不清** · 字幕或语义需回听确认。 ([002.md](/courses/stanford-cs336-s26/lectures/011/#section-02))
- `00:34:26` · **上下文或语义不清** · 字幕或语义需回听确认。 ([004.md](/courses/stanford-cs336-s26/lectures/011/#section-04))
- `00:36:33` · **上下文或语义不清** · 字幕或语义需回听确认。 ([004.md](/courses/stanford-cs336-s26/lectures/011/#section-04))
- `00:41:17` · **上下文或语义不清** · 字幕或语义需回听确认。 ([005.md](/courses/stanford-cs336-s26/lectures/011/#section-05))
- `00:53:25` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/stanford-cs336-s26/lectures/011/#section-06))
- `00:54:58` · **上下文或语义不清** · [需回听 00:55:35] ([006.md](/courses/stanford-cs336-s26/lectures/011/#section-06))
- `01:00:03` · **上下文或语义不清** · 字幕或语义需回听确认。 ([007.md](/courses/stanford-cs336-s26/lectures/011/#section-07))
- `01:13:43` · **上下文或语义不清** · 字幕或语义需回听确认。 ([008.md](/courses/stanford-cs336-s26/lectures/011/#section-08))

### Lecture 12: Evaluation

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/012/)。
- 当前分段笔记没有待回听标记。

### Lecture 13: Data (sources, datasets)

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/013/)。
- 当前分段笔记没有待回听标记。

### Lecture 14: Data (filtering, deduplication, mixing, synthetic data)

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/014/)。
- `00:56:16` · **上下文或语义不清** · `。[00:56:16-00:56:37] ([006.md](/courses/stanford-cs336-s26/lectures/014/#section-06))
- `01:12:15` · **上下文或语义不清** · ` 再核对。 ([008.md](/courses/stanford-cs336-s26/lectures/014/#section-08))
- `01:19:42` · **上下文或语义不清** · `，只能确定是在继续谈“如何在所有 repos 上拿到数据集”。 ([009.md](/courses/stanford-cs336-s26/lectures/014/#section-09))

### Lecture 15: Mid/post-training (SFT/RLHF)

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/015/)。
- `00:03:47` · **论文、术语或名称** · 老师口头列举的早期资料名称以 transcript 识别为 Stiennon 2020 与 Anthropic HH 2022，正式引用时应以论文原名核对。 ([001.md](/courses/stanford-cs336-s26/lectures/015/#section-01))
- `00:05:17` · **上下文或语义不清** · ScaleAI 泄露材料中的竞品对象与原话细节较口语化，若要逐字记录应回听。 ([001.md](/courses/stanford-cs336-s26/lectures/015/#section-01))
- `00:11:00` · **论文、术语或名称** · 老师提到“没有 response 也能学 instruction following”的论文归属较口语化，若需正式引用应回听并核论文名。 ([002.md](/courses/stanford-cs336-s26/lectures/015/#section-02))
- `00:16:29` · **上下文或语义不清** · OpenAssistant 的确切样本量老师口头说成“大约一万或更多”，这里只按不确定数字记录，不做精确断言。 ([002.md](/courses/stanford-cs336-s26/lectures/015/#section-02))
- `00:20:56` · **上下文或语义不清** · 中间学生关于 “complex matter in the dataset” 的提问被字幕部分吞掉，现仅保留老师承诺“后面会讲”的语义。 ([003.md](/courses/stanford-cs336-s26/lectures/015/#section-03))
- `00:26:20` · **上下文或语义不清** · 学生追问 RL 为什么能缓解 hallucination 的开头有一小段模糊，若需逐字整理应回听。 ([003.md](/courses/stanford-cs336-s26/lectures/015/#section-03))
- `00:30:20` · **上下文或语义不清** · 老师说 Llama 2 safety tuning 的样本量是“few thousand”量级，但并未逐字报出精确数字。 ([004.md](/courses/stanford-cs336-s26/lectures/015/#section-04))
- `00:35:06` · **上下文或语义不清** · 学生关于 “destroying features” 的提问中间有一小段字幕不清，当前仅保留老师后续回答的主要逻辑。 ([004.md](/courses/stanford-cs336-s26/lectures/015/#section-04))
- `00:41:39` · **上下文或语义不清** · 老师提到 Meta 诉讼文件里具体是哪类 researcher memo，被字幕略化为口语描述，正式引用前应回听。 ([005.md](/courses/stanford-cs336-s26/lectures/015/#section-05))
- `00:48:01` · **上下文或语义不清** · “internationality” 一词更可能是别的表达质量标准，字幕转写不稳定，当前只保留其指向“表达/呈现质量”的语义。 ([005.md](/courses/stanford-cs336-s26/lectures/015/#section-05))
- `00:52:37` · **上下文或语义不清** · 老师提到 ScaleAI 近况时带有口语化保留，当前只保留“早期大量依赖低成本外包并引发争议”的主旨。 ([006.md](/courses/stanford-cs336-s26/lectures/015/#section-06))
- `00:53:58` · **论文、术语或名称** · base model 与不同宗教群体接近度的口头描述较快，如需严格复现研究结果应回查原论文或老师提到的附录。 ([006.md](/courses/stanford-cs336-s26/lectures/015/#section-06))
- `01:03:02` · **上下文或语义不清** · 学生关于 Zephyr 模型规模的提问有部分缺字，当前仅保留“当时 7B 仍是相当体面的开放模型”这一主旨。 ([007.md](/courses/stanford-cs336-s26/lectures/015/#section-07))
- `01:05:17` · **论文、术语或名称** · 老师提到“只按长度做 RLHF 也能取得不错结果”的论文名称没有在口头里完整报出，如需正式引用应回查原文。 ([007.md](/courses/stanford-cs336-s26/lectures/015/#section-07))
- `01:17:24` · **上下文或语义不清** · 老师在讲 KL regularizer 时语速较快，当前按语义整理为“防止过拟合 reward model”，如需精确句式应回听。 ([008.md](/courses/stanford-cs336-s26/lectures/015/#section-08))
- `01:19:13` · **上下文或语义不清** · 结尾处老师口头提到 assignment 用的是更简单变体，字幕写成“GRPO”，正式课程材料若要一致，建议结合下一讲或作业说明核对。 ([008.md](/courses/stanford-cs336-s26/lectures/015/#section-08))

### Lecture 16: Post-training - RLVR

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/016/)。
- 当前分段笔记没有待回听标记。

### Lecture 17: Alignment - multimodality

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/017/)。
- 当前分段笔记没有待回听标记。

### Lecture 18: Guest lecture: Daniel Selsam

- **来源缺口**：当前官方 schedule 有本讲记录，但 playlist、课程页和 lecture repository 均未提供可核验录像或材料。

### Lecture 19: Guest lecture: Dan Fu

- 讲次笔记：[NOTES.md](/courses/stanford-cs336-s26/lectures/018/)。
- `00:07:15` · **上下文或语义不清** · 。 ([001.md](/courses/stanford-cs336-s26/lectures/018/#section-01))
- `00:21:07` · **上下文或语义不清** · 、Cerebras、SambaNova 等例子说明硬件格局正在围绕 decode/prefill 分化。 ([003.md](/courses/stanford-cs336-s26/lectures/018/#section-03))
- `00:21:07` · **上下文或语义不清** · 。 ([003.md](/courses/stanford-cs336-s26/lectures/018/#section-03))
- `00:30:05` · **上下文或语义不清** · 。 ([004.md](/courses/stanford-cs336-s26/lectures/018/#section-04))
- `00:31:47` · **上下文或语义不清** · 。 ([004.md](/courses/stanford-cs336-s26/lectures/018/#section-04))
- `00:40:41` · **上下文或语义不清** · 。 ([005.md](/courses/stanford-cs336-s26/lectures/018/#section-05))
- `00:40:41` · **上下文或语义不清** · ，定位类似 Triton，但更底层，提供更细粒度控制。 ([005.md](/courses/stanford-cs336-s26/lectures/018/#section-05))
- `00:45:05` · **上下文或语义不清** · 。 ([005.md](/courses/stanford-cs336-s26/lectures/018/#section-05))
- `00:53:39` · **上下文或语义不清** · 。 ([006.md](/courses/stanford-cs336-s26/lectures/018/#section-06))
- `01:01:14` · **上下文或语义不清** · 。 ([007.md](/courses/stanford-cs336-s26/lectures/018/#section-07))
- `01:01:14` · **上下文或语义不清** · 模型里直接 loop 两三层，在某些数学榜单上出现质量提升；他觉得这件事“很怪”，但团队也在继续研究。 ([007.md](/courses/stanford-cs336-s26/lectures/018/#section-07))
- `01:05:51` · **上下文或语义不清** · 。 ([007.md](/courses/stanford-cs336-s26/lectures/018/#section-07))
- `01:08:57` · **上下文或语义不清** · ，不要自行补成某个确定格式。 ([007.md](/courses/stanford-cs336-s26/lectures/018/#section-07))
- `01:10:57` · **上下文或语义不清** · 。 ([008.md](/courses/stanford-cs336-s26/lectures/018/#section-08))
- `01:10:57` · **上下文或语义不清** · 的 mixture-of-experts inference layer 为例，说对局部计算块做小型 Megakernel，并把部分通信一起融合，是已经开始出现的方向。 ([008.md](/courses/stanford-cs336-s26/lectures/018/#section-08))

## 复核方法

1. 先读对应分段笔记，确认疑点在推导或工程主线中的作用。
2. 回听时间点前后至少 15 秒；人工字幕也可能有术语和断句错误。
3. Executable lecture 同时核对 `[代码: lecture_XX.py p.N]` 对应函数/行范围。
4. PDF lecture 同时核对 `[课件: lecture_XX.pdf p.N]`。
5. 修订 section 后同步更新根 `NOTES.md` 的嵌入正文。
