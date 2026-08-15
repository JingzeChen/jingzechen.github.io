---
uid: cmu-11785-s26-review-checklist
type: course
document_type: resource
resource_kind: review
resource_order: 3
course: cmu-11785-s26
title: CMU 11-785 Spring 2026 复核清单
description: 按风险回查自动 transcript、课件与视频中的未决证据。
excerpt: 按风险回查自动 transcript、课件与视频中的未决证据。
content_lang: zh-CN
permalink: "/courses/cmu-11785-s26/review-checklist/"
toc: true
math: true
---

> 本清单从 256 份分段课堂笔记中的 `[需回听 HH:MM:SS]` 标记自动汇总。
> 标记表示证据需要核验，不等于确认笔记有错；修订时应回到官方视频、字幕和同讲课件。

## 汇总

- 唯一待回听项：`270`。
- 涉及讲次：`16/29`。
- 分类：`{'ASR 术语或名称': 100, '上下文或语义不清': 111, '代码、API 或实现': 2, '公式、符号或数值': 23, '课件与口述差异': 34}`。
- 建议优先级：公式/符号/数值 > 代码/API > 课件与口述差异 > 核心术语 > 普通语义。

## 按讲次复核

### Lecture 00: Course Logistics Learning Objectives Grading Deadlines

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/001/)。
- `00:00:27` · **课件与口述差异** · 字幕中两位授课教师姓名转写错误较重；本笔记按课件 p.10 采用 Bhiksha Raj、Rita Singh。 ([001.md](/courses/cmu-11785-s26/lectures/001/#section-01))
- `00:02:14` · **ASR 术语或名称** · “Kegali” 应为 Kigali，但字幕拼写不稳。 ([001.md](/courses/cmu-11785-s26/lectures/001/#section-01))
- `00:03:11` · **ASR 术语或名称** · “perceptrums” 为 ASR 误写，应对应 multilayer perceptrons。 ([001.md](/courses/cmu-11785-s26/lectures/001/#section-01))
- `00:14:23` · **ASR 术语或名称** · 字幕把 Piazza 写成 Piaza/Piazza 不稳定，本笔记统一写作 Piazza。 ([002.md](/courses/cmu-11785-s26/lectures/001/#section-02))
- `00:15:40` · **上下文或语义不清** · “unable to co-op” 语义不通，结合上下文更像 “unable to cope”。 ([002.md](/courses/cmu-11785-s26/lectures/001/#section-02))
- `00:15:57` · **ASR 术语或名称** · “IDL world” 口播似乎带有 ID(ea)L 的双关，字幕无法完整反映。 ([002.md](/courses/cmu-11785-s26/lectures/001/#section-02))
- `00:18:47` · **ASR 术语或名称** · MediaTech 的观看截止语句是“the Monday following the following week”，实际制度表述较绕，已按字幕直译记录。 ([002.md](/courses/cmu-11785-s26/lectures/001/#section-02))
- `00:20:25` · **课件与口述差异** · 字幕把 mytorch 前面的表述写成 “pietorch”，应结合课件 p.40 理解为学生自己的小工具包，名称是 mytorch。 ([003.md](/courses/cmu-11785-s26/lectures/001/#section-03))
- `00:24:54` · **课件与口述差异** · 口头说“all of the students must participate in that video”，但课件 p.43 明写 “The video can be presented by one, some, or all team members”，两者存在轻微张力；本笔记已同时保留口头建议与课件条文。 ([003.md](/courses/cmu-11785-s26/lectures/001/#section-03))
- `00:25:56` · **课件与口述差异** · grading 小结里关于项目分项的具体分值口播不清，课件 p.44 仅明确“attendance 1 mark”，其余分值未在本 prompt 课件中展开。 ([003.md](/courses/cmu-11785-s26/lectures/001/#section-03))
- `00:26:55` · **ASR 术语或名称** · “acrew” 为 ASR 误写，应是 accrue。 ([003.md](/courses/cmu-11785-s26/lectures/001/#section-03))
- `00:30:06` · **上下文或语义不清** · “a great ones” 更可能是 “a great one”，但不影响收尾含义。 ([004.md](/courses/cmu-11785-s26/lectures/001/#section-04))

### Lecture 01: Introduction

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/002/)。
- `00:02:55` · **课件与口述差异** · transcript 将 Piazza 记作 “Piaza”，课件为 Piazza。 ([001.md](/courses/cmu-11785-s26/lectures/002/#section-01))
- `00:03:54` · **上下文或语义不清** · transcript 中负责处理系统访问问题的助教称呼记为 “TTA/RTS” 一类缩写，建议回听确认具体称谓。 ([001.md](/courses/cmu-11785-s26/lectures/002/#section-01))
- `00:15:54` · **上下文或语义不清** · transcript 出现 “kegali students” 一类表述，语义不清，需结合原音确认具体所指学生群体。 ([002.md](/courses/cmu-11785-s26/lectures/002/#section-02))
- `00:16:05` · **上下文或语义不清** · transcript 把 in-person 记成 “inerson”，不影响含义，但建议回听统一措辞。 ([002.md](/courses/cmu-11785-s26/lectures/002/#section-02))
- `00:21:21` · **上下文或语义不清** · transcript 将 CMU 记成 “CNU”，该处讲的是深蓝/Deep Thought 与本校关系，建议回听确认专有名词。 ([002.md](/courses/cmu-11785-s26/lectures/002/#section-02))
- `00:24:07` · **上下文或语义不清** · transcript 中前助教姓名记作 “Current”，应为专有名词，建议回听确认。 ([003.md](/courses/cmu-11785-s26/lectures/002/#section-03))
- `00:28:23` · **课件与口述差异** · transcript 把 Plato 记成 “plateau/Plate”，可结合前文与 slide 理解为 Plato，但建议回听统一。 ([003.md](/courses/cmu-11785-s26/lectures/002/#section-03))
- `00:32:01` · **ASR 术语或名称** · transcript 中人名写作 “Bane”，结合上文语境应为 Bain，建议回听确认。 ([004.md](/courses/cmu-11785-s26/lectures/002/#section-04))
- `00:37:55` · **上下文或语义不清** · transcript 将 von Neumann 记为 “oneman / one I mean”，建议回听统一专有名词。 ([004.md](/courses/cmu-11785-s26/lectures/002/#section-04))
- `00:47:28` · **上下文或语义不清** · transcript 说 “if the inhibitory input is turned on the output of the neuron will always be turned on”，与前后文“抑制会阻止发火”冲突，应回听确认该句应为 turned off/does not fire 一类表述。 ([005.md](/courses/cmu-11785-s26/lectures/002/#section-05))
- `00:58:15` · **ASR 术语或名称** · transcript 将 Rosenblatt 记作 “Rosenblot / Rosenbl”，建议回听统一人名。 ([006.md](/courses/cmu-11785-s26/lectures/002/#section-06))
- `01:01:29` · **公式、符号或数值** · 学习率记号在 transcript 中记为 “a”，若后续课程统一记作其他符号，需以后续材料为准；本段按 transcript 记录。 ([006.md](/courses/cmu-11785-s26/lectures/002/#section-06))
- `01:12:50` · **ASR 术语或名称** · transcript 将 Heaviside 记作 “heavy side”，本笔记仅保留其含义，不额外补标准拼写。 ([008.md](/courses/cmu-11785-s26/lectures/002/#section-08))

### Lecture 02: Neural Nets As Universal Approximators

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/003/)。
- `00:08:21` · **ASR 术语或名称** · 字幕把 affine 多次转成 aphine/alpha/fine，需要按老师板书语义理解为 affine。 ([001.md](/courses/cmu-11785-s26/lectures/003/#section-01))
- `00:09:29` · **ASR 术语或名称** · 字幕把 $\sum_i w_i x_i+b$ 末项记成 v，按上下文应为偏置项 $b$。 ([001.md](/courses/cmu-11785-s26/lectures/003/#section-01))
- `00:10:57` · **公式、符号或数值** · 老师开始讲 sigmoid 时只进入了极限讨论的开头，完整公式与解释在下一段延续。 ([001.md](/courses/cmu-11785-s26/lectures/003/#section-01))
- `00:11:48` · **ASR 术语或名称** · 字幕中 sigmoid 的指数表达被转成 e ra to 等口语残片，数学含义清楚但转写不稳。 ([002.md](/courses/cmu-11785-s26/lectures/003/#section-02))
- `00:13:19` · **ASR 术语或名称** · sigmoine、soft plus、rectification 等词在 ASR 中有轻微变形。 ([002.md](/courses/cmu-11785-s26/lectures/003/#section-02))
- `00:19:06` · **ASR 术语或名称** · 字幕把 “said to be deep” 误成 subset to be deep，按语义应理解为“称为 deep”。 ([002.md](/courses/cmu-11785-s26/lectures/003/#section-02))
- `00:23:57` · **ASR 术语或名称** · 字幕把 networks need to be deep 误成 teeth，需要按上下文理解为 deep。 ([003.md](/courses/cmu-11785-s26/lectures/003/#section-03))
- `00:28:55` · **ASR 术语或名称** · 字幕把 XOR 写成 exor/xr，按语义统一理解为 XOR。 ([003.md](/courses/cmu-11785-s26/lectures/003/#section-03))
- `00:29:42` · **课件与口述差异** · Gerald Friedland 的姓名转写轻微不稳，课件 p.33 给出拼写可用于校正。 ([003.md](/courses/cmu-11785-s26/lectures/003/#section-03))
- `00:35:05` · **ASR 术语或名称** · 字幕把 Karnaugh map 转成 car map/cardinal map，按老师语义应为 Karnaugh map。 ([004.md](/courses/cmu-11785-s26/lectures/003/#section-04))
- `00:40:00` · **ASR 术语或名称** · 字幕把 $2^{n-1}$ 转成 2 ra to n minus1，需要按上下文理解为指数写法。 ([004.md](/courses/cmu-11785-s26/lectures/003/#section-04))
- `00:42:18` · **ASR 术语或名称** · 字幕里的 XR、exord 都应理解为 XOR。 ([005.md](/courses/cmu-11785-s26/lectures/003/#section-05))
- `00:44:44` · **上下文或语义不清** · “two times login layers” 按上下文应为 $2\log_2 n$ layers。 ([005.md](/courses/cmu-11785-s26/lectures/003/#section-05))
- `00:50:09` · **上下文或语义不清** · “depth can be traded off for but depth can be traded off for” 有重复转写，按语义应为“depth can be traded off for width”。 ([005.md](/courses/cmu-11785-s26/lectures/003/#section-05))
- `00:54:37` · **ASR 术语或名称** · 字幕里的 “an XR needs two hidden neurons” 实际是指 XOR 网络需要两条边界对应的隐藏单元。 ([006.md](/courses/cmu-11785-s26/lectures/003/#section-06))
- `00:58:18` · **ASR 术语或名称** · spurious 被字幕写成 speurious，不影响含义但需注意。 ([006.md](/courses/cmu-11785-s26/lectures/003/#section-06))
- `01:00:20` · **课件与口述差异** · 本段尾部转入“边数趋于无穷”的极限图像时，口头承接较快，需要与下一段连读理解。 ([006.md](/courses/cmu-11785-s26/lectures/003/#section-06))
- `01:02:35` · **公式、符号或数值** · 老师提到“one of my TAs once worked out” 的复杂公式，但并未在 transcript 中完整给出，笔记只保留其口头结论。 ([007.md](/courses/cmu-11785-s26/lectures/003/#section-07))
- `01:08:31` · **上下文或语义不清** · Gerald Friedland 的两单元 XOR 再次被提及，但这里未重复具体结构。 ([007.md](/courses/cmu-11785-s26/lectures/003/#section-07))
- `01:10:30` · **ASR 术语或名称** · 字幕中 statistically independent features 前后有重复残句，按语义理解为“最坏情况下规模可对统计独立特征数呈指数增长”。 ([007.md](/courses/cmu-11785-s26/lectures/003/#section-07))
- `01:12:58` · **ASR 术语或名称** · 字幕中的 pulse 构造描述有零碎重复，但整体逻辑清楚。 ([008.md](/courses/cmu-11785-s26/lectures/003/#section-08))
- `01:19:48` · **上下文或语义不清** · reloop、leaky rail 等词应分别理解为 ReLU、leaky ReLU。 ([008.md](/courses/cmu-11785-s26/lectures/003/#section-08))
- `01:21:13` · **上下文或语义不清** · 本段 transcript 在 “compose the …” 处截断到下一段，需与下一段开头连读理解。 ([008.md](/courses/cmu-11785-s26/lectures/003/#section-08))
- `01:21:40` · **课件与口述差异** · 本段关于“四个神经元方向选择”的具体图示只来自课件图形，口头描述较快，需结合 slide 理解。 ([009.md](/courses/cmu-11785-s26/lectures/003/#section-09))
- `01:23:18` · **课件与口述差异** · Gerald Friedland 姓名在字幕中作 Freland，按前文课件统一为 Friedland。 ([009.md](/courses/cmu-11785-s26/lectures/003/#section-09))
- `01:24:23` · **上下文或语义不清** · prompt 片段名到 01:24:27，但 transcript 在 01:24:23 停止，末尾可能是停顿或未转写问答开头。 ([009.md](/courses/cmu-11785-s26/lectures/003/#section-09))

### Lecture 03: Training Part I The Problem of Learning Empirical Risk Minimization

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/004/)。
- `00:05:03` · **课件与口述差异** · 老师口头对 z 的引入和 “affine” 一词的 ASR 转写较乱，但上下文明确是在定义加权和加偏置的中间量。 ([001.md](/courses/cmu-11785-s26/lectures/004/#section-01))
- `00:05:47` · **ASR 术语或名称** · 字幕把 neuron units 转成了不稳定的 “ei”，此处仅按上下文理解为神经元单元编号。 ([001.md](/courses/cmu-11785-s26/lectures/004/#section-01))
- `00:13:07` · **上下文或语义不清** · 学生抢答里提到 integral of what、loss function、g(x) 等短句交叠较多，老师的核心纠正是“先定义 gap，再积分”。 ([002.md](/courses/cmu-11785-s26/lectures/004/#section-02))
- `00:17:29` · **ASR 术语或名称** · 字幕把 “training samples” 误写成了 “training functions”，此处按上下文统一理解为训练样本。 ([002.md](/courses/cmu-11785-s26/lectures/004/#section-02))
- `00:25:20` · **课件与口述差异** · 老师口头说的是 Rosenblatt，字幕个别位置转写不稳。 ([003.md](/courses/cmu-11785-s26/lectures/004/#section-03))
- `00:25:46` · **ASR 术语或名称** · “heaviside” 与 “affine” 的 ASR 均不稳定，但不影响本段核心定义。 ([003.md](/courses/cmu-11785-s26/lectures/004/#section-03))
- `00:37:21` · **ASR 术语或名称** · 字幕把老师对负类理想权重的描述压缩得较乱，核心含义是“ideal direction 是 -x，因此更新等价于从 W 中减去 x”。 ([004.md](/courses/cmu-11785-s26/lectures/004/#section-04))
- `00:45:08` · **上下文或语义不清** · 老师解释“为什么不能学这条线”时有一段停顿，核心原因是“原始标签对该中间边界不线性可分”。 ([005.md](/courses/cmu-11785-s26/lectures/004/#section-05))
- `00:47:24` · **ASR 术语或名称** · 字幕把 relabeling 转写成了 reabel/rele 等多种错误形式，此处统一记为 relabeling。 ([005.md](/courses/cmu-11785-s26/lectures/004/#section-05))
- `00:52:52` · **课件与口述差异** · 老师口头说的是 “NP complexity combinatorial optimization problem”，更准确表述应理解为“NP-hard/组合优化级别困难”，此处保留口头原意，不外推更强结论。 ([006.md](/courses/cmu-11785-s26/lectures/004/#section-06))
- `00:57:53` · **课件与口述差异** · 字幕把边界处的导数说成 “infinite”，口头表述更像在强调“不好用/不光滑”，这里不额外补数学细节。 ([006.md](/courses/cmu-11785-s26/lectures/004/#section-06))
- `01:02:07` · **上下文或语义不清** · 老师在说明曲线应继续往左还是往右移时出现一次 left/right 自我纠正，本笔记只保留“总距离变化能指示优化方向”的稳定结论，不强行还原口误前后的方向细节。 ([007.md](/courses/cmu-11785-s26/lectures/004/#section-07))
- `01:05:44` · **课件与口述差异** · Poll 3 逐题口播比较快，学生若需要逐项真值，最好对照 slides p.102-p.103 回看。 ([007.md](/courses/cmu-11785-s26/lectures/004/#section-07))
- `01:10:28` · **ASR 术语或名称** · 字幕中的 “change Y” 和 “change the outputs of these perceptrons” 有少量口误/跳词，但核心意思是“参数扰动可逐层传播到最终输出”。 ([008.md](/courses/cmu-11785-s26/lectures/004/#section-08))
- `01:16:11` · **公式、符号或数值** · 老师解释积分里的 dx 与 P(X) 时语速较快，若需严格符号化表达，建议对照 slides 再核对一次。 ([008.md](/courses/cmu-11785-s26/lectures/004/#section-08))
- `01:19:35` · **上下文或语义不清** · 这段开头的口播有几处重复和吞音，但稳定结论是“样本平均 divergence 的期望对应真实加权风险”。 ([009.md](/courses/cmu-11785-s26/lectures/004/#section-09))
- `01:21:38` · **课件与口述差异** · 老师口头说的是 “unbiased estimate”，本笔记按原话保留，不额外补充统计学前提。 ([009.md](/courses/cmu-11785-s26/lectures/004/#section-09))

### Lecture 04: Training Part II Gradient Descent Training the Network

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/005/)。
- `00:01:20` · **ASR 术语或名称** · 字幕中的 “average d” 应是 “average divergence”，本笔记按上下文统一为 divergence。 ([001.md](/courses/cmu-11785-s26/lectures/005/#section-01))
- `00:03:09` · **公式、符号或数值** · 字幕把 multiplier 周围的公式信息压缩得较厉害，口头应当同时指向 $\Delta x$ 与 $\Delta y$ 的线性关系。 ([001.md](/courses/cmu-11785-s26/lectures/005/#section-01))
- `00:09:37` · **ASR 术语或名称** · “What is alpha r?” 的 ASR 不稳，结合后文应是在问某个 $\alpha_i$ 分量代表什么。 ([001.md](/courses/cmu-11785-s26/lectures/005/#section-01))
- `00:11:03` · **ASR 术语或名称** · “naba” 应为 “nabla”，字幕转写不稳。 ([002.md](/courses/cmu-11785-s26/lectures/005/#section-02))
- `00:17:21` · **ASR 术语或名称** · “hessen” 应为 “Hessian”，课堂口音与字幕拼写均不稳定。 ([002.md](/courses/cmu-11785-s26/lectures/005/#section-02))
- `00:17:49` · **公式、符号或数值** · 老师把 positive definite 暂时口头化成“all positive values”，严格来说应理解为特征值/二次型条件而不是矩阵元素逐项为正。 ([002.md](/courses/cmu-11785-s26/lectures/005/#section-02))
- `00:25:42` · **ASR 术语或名称** · “inflection ction point” 一带 ASR 明显抖动，但不影响“拐点不是极值”的主旨。 ([003.md](/courses/cmu-11785-s26/lectures/005/#section-03))
- `00:28:43` · **上下文或语义不清** · “find the value x at which the function is zero” 应为“find the value x at which the derivative/gradient is zero”，上下文更一致。 ([003.md](/courses/cmu-11785-s26/lectures/005/#section-03))
- `00:30:22` · **上下文或语义不清** · 本段最后一句被截断，老师显然正要继续说明 saddle point 情形。 ([003.md](/courses/cmu-11785-s26/lectures/005/#section-03))
- `00:31:01` · **ASR 术语或名称** · 字幕把 eigenvalues/eigenvectors 转成 “igon values/igon vectors”，本笔记已按数学术语统一。 ([004.md](/courses/cmu-11785-s26/lectures/005/#section-04))
- `00:37:22` · **公式、符号或数值** · 学生 Bruno 的提问被字幕截断较重，只能确定他卡在“如何把两种方向规则写成一个公式”。 ([004.md](/courses/cmu-11785-s26/lectures/005/#section-04))
- `00:42:52` · **ASR 术语或名称** · “gradient descent conver algorithm” 应为 “gradient descent converges / convergence algorithm”，字幕拼写不稳。 ([005.md](/courses/cmu-11785-s26/lectures/005/#section-05))
- `00:48:57` · **ASR 术语或名称** · 字幕中的 “aine/aphine” 应为 “affine”。 ([005.md](/courses/cmu-11785-s26/lectures/005/#section-05))
- `00:52:19` · **ASR 术语或名称** · 字幕中的 “aphine” 应为 “affine”。 ([006.md](/courses/cmu-11785-s26/lectures/005/#section-06))
- `01:00:23` · **上下文或语义不清** · 本段最后一句被截断，只能确认老师强调 sigmoid 可微，并正要继续说明这对训练的重要性。 ([006.md](/courses/cmu-11785-s26/lectures/005/#section-06))
- `01:00:31` · **ASR 术语或名称** · “multi-multivaried” 为明显 ASR 抖动，语义应为“softmax 是 sigmoid 的多类版本”。 ([007.md](/courses/cmu-11785-s26/lectures/005/#section-07))
- `01:10:19` · **上下文或语义不清** · 本段最后一句“must be differentiable with respect to ...”被截断，能确定老师在强调 divergence 的可微性，但具体结尾词未保留下来。 ([007.md](/courses/cmu-11785-s26/lectures/005/#section-07))

### Lecture 05: Training Part III Backpropagation Calculus of Backpropagation

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/006/)。
- `01:07:44` · **上下文或语义不清** · 字幕或语义需回听确认。 ([007.md](/courses/cmu-11785-s26/lectures/006/#section-07))

### Lecture 06: Training Part IV Convergence issues Loss Surfaces Momentum

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/007/)。
- `00:03:55` · **ASR 术语或名称** · ASR 中多次出现 “aphine / aine term”，应为 affine term。 ([001.md](/courses/cmu-11785-s26/lectures/007/#section-01))
- `00:04:57` · **课件与口述差异** · “ykus one” 应为 \(y^{k-1}\) 的口头读法。 ([001.md](/courses/cmu-11785-s26/lectures/007/#section-01))
- `00:09:10` · **课件与口述差异** · 老师口头说 “answer: A”，但 transcript 未完整保留投票选项文本；所幸课件 p.8-p.9 保留了选项，可据课件确认。 ([001.md](/courses/cmu-11785-s26/lectures/007/#section-01))
- `00:13:56` · **上下文或语义不清** · transcript 中 “this function doesn't actually go to Z1 or zero” 语义不顺，应核对老师原话究竟是 “go to zero” 还是 “go to one”。 ([002.md](/courses/cmu-11785-s26/lectures/007/#section-02))
- `00:18:18` · **ASR 术语或名称** · “spoiler” 一词多次出现，含义清楚，但若后续课程采用别的中文术语，可统一为“扰动点/捣乱点”。 ([002.md](/courses/cmu-11785-s26/lectures/007/#section-02))
- `00:24:36` · **ASR 术语或名称** · “the example, in the statements that I assume made earlier” 这句 ASR 不顺，应核对老师原话是否为 “the statements that I made earlier”。 ([003.md](/courses/cmu-11785-s26/lectures/007/#section-03))
- `00:27:22` · **上下文或语义不清** · street light effect 的笑话细节可再回听，以便若后续统一课程风格时需要更准确的中文复述。 ([003.md](/courses/cmu-11785-s26/lectures/007/#section-03))
- `00:31:17` · **公式、符号或数值** · transcript 混入了二次方程求根公式 “-b ± sqrt(b^2-4ac)/(2a)”；老师当时是在泛泛提醒二次函数有 closed-form 解，还是想说最小值位置，应再听原音避免误读。 ([004.md](/courses/cmu-11785-s26/lectures/007/#section-04))
- `00:33:05` · **公式、符号或数值** · ASR 把 Taylor 公式中的二阶导读成 “fprime of x0 by”，公式文字化不完整，但整体推导链清楚。 ([004.md](/courses/cmu-11785-s26/lectures/007/#section-04))
- `00:36:41` · **ASR 术语或名称** · “E prime inverse” 实际应是 \([E''(w_k)]^{-1}\)；ASR 在 prime / double prime 上有混淆。 ([004.md](/courses/cmu-11785-s26/lectures/007/#section-04))
- `00:42:43` · **课件与口述差异** · transcript 中二元二次函数口头式有缺字，尤其 \(w_2\) 的平方项附近 ASR 断裂；本笔记按老师后文解释补写成对称二次式。 ([005.md](/courses/cmu-11785-s26/lectures/007/#section-05))
- `00:48:48` · **公式、符号或数值** · “optimal step size is 33” 属于老师图上的数值例子，若后续需要和原图完全一致，应回听或直接看对应 slide 图示。 ([005.md](/courses/cmu-11785-s26/lectures/007/#section-05))
- `00:55:23` · **ASR 术语或名称** · transcript 中 “it will stay in large values sonic” 明显 ASR 失真，应回听确认老师原意，推测是在解释为什么大学习率会帮助找到更大的 basin。 ([006.md](/courses/cmu-11785-s26/lectures/007/#section-06))
- `00:58:00` · **课件与口述差异** · Poll 2 的完整题面未在 prompt 中给出，只保留了解析；若后续要重建课堂提问，应补看原投票画面或 slide。 ([006.md](/courses/cmu-11785-s26/lectures/007/#section-06))
- `01:03:49` · **上下文或语义不清** · “this tends to overshoot small values” 的具体语义略糊，推测是在说 Rprop 更容易跨过浅小谷底；若后续需要更精确措辞，应回听原音。 ([007.md](/courses/cmu-11785-s26/lectures/007/#section-07))
- `01:06:18` · **上下文或语义不清** · “Scott Fman” 应为 Scott Fahlman。 ([007.md](/courses/cmu-11785-s26/lectures/007/#section-07))
- `01:10:09` · **公式、符号或数值** · transcript 中老师一开始把 running average 写成 “alpha * xbar_{k-1} + x_k”，随后又给出精确系数 \(k/(k+1)\) 与 \(1/(k+1)\)；前者应理解为口头概括，后者才是严格公式。 ([008.md](/courses/cmu-11785-s26/lectures/007/#section-08))
- `01:16:51` · **ASR 术语或名称** · “Nsteros / Nastro / Nestto” 均为 ASR 失真，应统一为 Nesterov。 ([008.md](/courses/cmu-11785-s26/lectures/007/#section-08))
- `01:21:33` · **ASR 术语或名称** · “demonstrabably superior” 的具体比较对象是“other methods” 还是“plain gradient descent / some methods”，ASR 未保留完整上下文，可回听确认措辞强度。 ([009.md](/courses/cmu-11785-s26/lectures/007/#section-09))

### Lecture 07: Training Part V Optimization Batch Size, SGD, Mini-batch, Second-order Methods

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/008/)。
- `00:04:47` · **ASR 术语或名称** · 自动字幕写成“revisit trend algorithms”，这里更像是在说某类“trend”或“training”相关算法，需回听确认原词。 ([001.md](/courses/cmu-11785-s26/lectures/008/#section-01))
- `00:16:45` · **ASR 术语或名称** · 自动字幕多处把 stochastic 识别为“stoastic”，引用时应以概念为准、拼写需回听核实。 ([002.md](/courses/cmu-11785-s26/lectures/008/#section-02))
- `00:18:13` · **ASR 术语或名称** · 自动字幕写成“data clotting”，结合上下文更像在说数据团聚/clumping，需回听确认老师原词。 ([002.md](/courses/cmu-11785-s26/lectures/008/#section-02))
- `00:24:28` · **ASR 术语或名称** · 学生名字字幕写成“Jenny”，是否准确需回听确认。 ([003.md](/courses/cmu-11785-s26/lectures/008/#section-03))
- `00:35:05` · **ASR 术语或名称** · 自动字幕把 cosine annealing 识别为“cosign uneing scheduleuler”，此处只保留“外包络需下降”的结论，原词需回听确认。 ([004.md](/courses/cmu-11785-s26/lectures/008/#section-04))
- `00:41:42` · **ASR 术语或名称** · “on stat as a statistical expectation”一处字幕不顺，应只保留“统计期望意义上成立”的意思，原话需回听。 ([005.md](/courses/cmu-11785-s26/lectures/008/#section-05))
- `00:44:57` · **ASR 术语或名称** · 自动字幕把老师点名对象写成“answer everyone”，应是对某位学生的回应，名字需回听确认。 ([005.md](/courses/cmu-11785-s26/lectures/008/#section-05))
- `00:54:35` · **ASR 术语或名称** · 学生名字字幕写成“Duna”，应为对某位学生的回应，姓名需回听。 ([006.md](/courses/cmu-11785-s26/lectures/008/#section-06))
- `00:56:00` · **ASR 术语或名称** · 自动字幕写成“abilation experiments”，显然是常见术语误识别，需回听确认是否为“ablation experiments”。 ([006.md](/courses/cmu-11785-s26/lectures/008/#section-06))
- `01:03:40` · **公式、符号或数值** · 一处公式口播中“some times the current correction”字幕较乱，含义已按 running average 理解，需回听核对原措辞。 ([007.md](/courses/cmu-11785-s26/lectures/008/#section-07))
- `01:05:33` · **ASR 术语或名称** · 自动字幕把人名多次写成“Nestros”或“Nestorov”，应统一核对为讲者所说的人名。 ([007.md](/courses/cmu-11785-s26/lectures/008/#section-07))
- `01:12:08` · **ASR 术语或名称** · 字幕里有“highest because this is swinging wildly”前后答问略乱，结论明确是“竖直摆动更大者学习率更低”，但具体点名谁答题需回听。 ([008.md](/courses/cmu-11785-s26/lectures/008/#section-08))
- `01:16:27` · **ASR 术语或名称** · 字幕中的学生名字写成“toana”，需回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/008/#section-08))
- `01:21:32` · **ASR 术语或名称** · “AdamW just has been DK”明显是 ASR 误识别，只能确认老师在说 AdamW 的额外修正留到下一讲。 ([009.md](/courses/cmu-11785-s26/lectures/008/#section-09))
- `01:21:32` · **上下文或语义不清** · 。 ([009.md](/courses/cmu-11785-s26/lectures/008/#section-09))
- `01:22:28` · **课件与口述差异** · 自动字幕把来源人名识别为“chronal radford”，结合课件链接更像在指 Alec Radford，需回听确认。 ([009.md](/courses/cmu-11785-s26/lectures/008/#section-09))
- `01:23:10` · **课件与口述差异** · 关于“AdaDelta 最快”与“Nesterov 最快”的口头比较连在一起，老师是在比较不同图上的表现，原句界限需回听确认。 ([009.md](/courses/cmu-11785-s26/lectures/008/#section-09))

### Lecture 08: Training Part VI Optimizers and Regularizers Choosing a Divergence (Loss) Function Batch Normalization Dropout

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/009/)。
- `00:02:47` · **上下文或语义不清** · “Trend algorithms” 的中文表述是否应译作“趋势算法”或“动量/趋势类优化法”。 ([001.md](/courses/cmu-11785-s26/lectures/009/#section-01))
- `00:02:47` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/009/#section-01))
- `00:07:08` · **ASR 术语或名称** · ASR 把 “L2 divergence” 识别成了 “L2 jar divergence”。 ([001.md](/courses/cmu-11785-s26/lectures/009/#section-01))
- `00:08:25` · **ASR 术语或名称** · “RMSSE” 处老师是在回应学生提问，术语拼写需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/009/#section-01))
- `00:10:53` · **上下文或语义不清** · “a fine value” 应是 “affine value”，但仍建议回听确认。 ([002.md](/courses/cmu-11785-s26/lectures/009/#section-02))
- `00:10:53` · **上下文或语义不清** · 字幕或语义需回听确认。 ([002.md](/courses/cmu-11785-s26/lectures/009/#section-02))
- `00:13:59` · **上下文或语义不清** · 课堂中插入点名与聊天消息，个别句子被打断。 ([002.md](/courses/cmu-11785-s26/lectures/009/#section-02))
- `00:14:05` · **代码、API 或实现** · [00:15:27] PyTorch 相关说明中多处 ASR 把 “affine / PyTorch / softmax” 识别得不稳定。 ([002.md](/courses/cmu-11785-s26/lectures/009/#section-02))
- `00:24:03` · **ASR 术语或名称** · [00:24:29] ASR 多次把 “affine” 识别成 “aphine / aine”。 ([003.md](/courses/cmu-11785-s26/lectures/009/#section-03))
- `00:25:16` · **上下文或语义不清** · [00:28:12] 因网络故障，本段中间有明显内容缺口。 ([003.md](/courses/cmu-11785-s26/lectures/009/#section-03))
- `00:37:13` · **ASR 术语或名称** · [00:37:37] 老师插入对迟到同学的回应，ASR 混有无意义音节。 ([004.md](/courses/cmu-11785-s26/lectures/009/#section-04))
- `00:39:20` · **课件与口述差异** · [00:39:34] Poll 3 的口头答案中 “which statements are one / which two” 句子不够完整。 ([004.md](/courses/cmu-11785-s26/lectures/009/#section-04))
- `00:41:35` · **ASR 术语或名称** · [00:41:39] ASR 连续输出大量 “Z”，但不影响判断此处是在问第二条路径。 ([005.md](/courses/cmu-11785-s26/lectures/009/#section-05))
- `00:44:11` · **公式、符号或数值** · [00:45:15] 幂函数求导处的口述公式被 ASR 截断，最好结合原视频核对幂次与系数。 ([005.md](/courses/cmu-11785-s26/lectures/009/#section-05))
- `00:44:11` · **上下文或语义不清** · 字幕或语义需回听确认。 ([005.md](/courses/cmu-11785-s26/lectures/009/#section-05))
- `00:47:18` · **ASR 术语或名称** · ASR 将 $(z-\mu)$ 识别成 “z / mu”，应回听核实。 ([005.md](/courses/cmu-11785-s26/lectures/009/#section-05))
- `00:49:42` · **公式、符号或数值** · [00:50:02] cross line 公式口述较快，部分分子分母顺序被 ASR 打散。 ([006.md](/courses/cmu-11785-s26/lectures/009/#section-06))
- `00:58:24` · **ASR 术语或名称** · [00:58:44] 老师提到原始论文作者与任务名称时 ASR 不稳定。 ([006.md](/courses/cmu-11785-s26/lectures/009/#section-06))
- `00:58:24` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/cmu-11785-s26/lectures/009/#section-06))
- `01:01:45` · **公式、符号或数值** · [01:01:53] sigmoid 公式被 ASR 识别为 “1 / e to minus wx”，建议回听核对准确写法。 ([007.md](/courses/cmu-11785-s26/lectures/009/#section-07))
- `01:05:01` · **上下文或语义不清** · 字幕或语义需回听确认。 ([007.md](/courses/cmu-11785-s26/lectures/009/#section-07))
- `01:05:01` · **课件与口述差异** · 老师口头把某个组合系数记成 $\beta$，应核实具体是 $\eta\lambda$ 还是其他记号。 ([007.md](/courses/cmu-11785-s26/lectures/009/#section-07))
- `01:07:52` · **ASR 术语或名称** · [01:08:20] 实验示例的人员名字与数据规模细节被 ASR 识别得不稳定。 ([007.md](/courses/cmu-11785-s26/lectures/009/#section-07))
- `01:10:38` · **ASR 术语或名称** · bagging 提出者 ASR 写成 “Leo Bryman”，人名拼写需核实。 ([008.md](/courses/cmu-11785-s26/lectures/009/#section-08))
- `01:13:39` · **上下文或语义不清** · [01:13:44] “Bernoulli variable” 被识别成 “boli variable”。 ([008.md](/courses/cmu-11785-s26/lectures/009/#section-08))
- `01:18:57` · **ASR 术语或名称** · [01:19:06] 误差曲线所对应的数据集名字被 ASR 识别成 “NEST”，需回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/009/#section-08))
- `01:19:33` · **上下文或语义不清** · “stoastic data model method” 应是 “stochastic model method” 一类表述，需核实原句。 ([009.md](/courses/cmu-11785-s26/lectures/009/#section-09))
- `01:20:23` · **ASR 术语或名称** · [01:20:32] “very steep as a various” 这一句 ASR 明显失真，语义应是损失面某些区域非常陡。 ([009.md](/courses/cmu-11785-s26/lectures/009/#section-09))
- `01:21:18` · **上下文或语义不清** · “valet” 应为 “validation”，需核实。 ([009.md](/courses/cmu-11785-s26/lectures/009/#section-09))

### Lecture 09: Convolutional Neural Networks (CNNs) I

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/010/)。
- `00:08:12` · **ASR 术语或名称** · 学生关于 data augmentation 的原始提问语句较短，字幕未完整保留问题表述，但不影响老师的反驳主线。 ([001.md](/courses/cmu-11785-s26/lectures/010/#section-01))
- `00:11:37` · **ASR 术语或名称** · 字幕把 “entire MLP” 误成了 “entire NLP”，语义应是整个多层感知机而非自然语言处理模型。 ([002.md](/courses/cmu-11785-s26/lectures/010/#section-02))
- `00:24:26` · **ASR 术语或名称** · “size of the input bracket” 一句字幕明显不顺，老师应是在说扫描子网个数依赖输入大小。 ([003.md](/courses/cmu-11785-s26/lectures/010/#section-03))
- `00:29:40` · **ASR 术语或名称** · 字幕把 backprop 写成了 “backb/backdrop”，语义应为 backpropagation。 ([003.md](/courses/cmu-11785-s26/lectures/010/#section-03))
- `00:30:46` · **ASR 术语或名称** · 字幕中的人名/称呼 “Jandya” 明显是课堂点名的 ASR 误识别。 ([004.md](/courses/cmu-11785-s26/lectures/010/#section-04))
- `00:31:20` · **ASR 术语或名称** · “WCJ” 一句字幕无法对应稳定术语，应为学生名字或未识别清楚的问题片段。 ([004.md](/courses/cmu-11785-s26/lectures/010/#section-04))
- `00:44:32` · **ASR 术语或名称** · 字幕把 affine 误成了 “aine”，语义应为每层先算 affine term 再过激活。 ([005.md](/courses/cmu-11785-s26/lectures/010/#section-05))
- `00:50:58` · **ASR 术语或名称** · 字幕中的 “sele / steamman” 应是花瓣或花蕊相关词的误识别。 ([006.md](/courses/cmu-11785-s26/lectures/010/#section-06))
- `00:58:29` · **上下文或语义不清** · “aine terms” 应为 affine terms。 ([006.md](/courses/cmu-11785-s26/lectures/010/#section-06))
- `01:01:49` · **ASR 术语或名称** · 字幕中的 “phone names / phonms” 应为 phones 或 phonemes。 ([007.md](/courses/cmu-11785-s26/lectures/010/#section-07))
- `01:19:15` · **ASR 术语或名称** · 字幕中的 “seles” 明显为花朵局部部件相关词误识别。 ([008.md](/courses/cmu-11785-s26/lectures/010/#section-08))
- `01:19:42` · **ASR 术语或名称** · 字幕把 pooling 识别成了 “pulling”，语义应为 pooling。 ([008.md](/courses/cmu-11785-s26/lectures/010/#section-08))
- `01:20:54` · **ASR 术语或名称** · 字幕中的研究者姓名应为专有名词，ASR 识别成了 “Yan Leon”。 ([009.md](/courses/cmu-11785-s26/lectures/010/#section-09))
- `01:21:00` · **上下文或语义不清** · “touring award” 应为某奖项专有名词的误识别。 ([009.md](/courses/cmu-11785-s26/lectures/010/#section-09))
- `01:21:03` · **ASR 术语或名称** · “emnest images” 可能是数据集名称误识别，需结合原音确认。 ([009.md](/courses/cmu-11785-s26/lectures/010/#section-09))

### Lecture 10: CNNs II

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/011/)。
- `00:03:22` · **ASR 术语或名称** · “receptive fields in capstri cortex” 应是论文名或 “cat striate cortex” 的 ASR 误写。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:03:22` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:04:47` · **上下文或语义不清** · “stride cortex / strided” 多处应为 striate cortex。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:05:05` · **上下文或语义不清** · “truth serum” 是课堂调侃还是确有其词，建议以原视频口气复核。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:05:05` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:08:30` · **ASR 术语或名称** · “oriented splits/slits of light” 的 ASR 在本段多次出现，建议统一核对为 slits。 ([001.md](/courses/cmu-11785-s26/lectures/011/#section-01))
- `00:10:43` · **上下文或语义不清** · “waking macak monkeys” 应为 waking macaque monkeys。 ([002.md](/courses/cmu-11785-s26/lectures/011/#section-02))
- `00:12:43` · **ASR 术语或名称** · “So Jesse SLs respond...” 一句 ASR 混乱，但上下文应是在重述“S cells 找模式，C cells 清理”。 ([002.md](/courses/cmu-11785-s26/lectures/011/#section-02))
- `00:19:53` · **公式、符号或数值** · “reloop / alphine” 应为 ReLU / affine 一类术语，但本段仅能按老师口头近似记录，不宜自行正规化到完整公式。 ([002.md](/courses/cmu-11785-s26/lectures/011/#section-02))
- `00:19:53` · **上下文或语义不清** · 字幕或语义需回听确认。 ([002.md](/courses/cmu-11785-s26/lectures/011/#section-02))
- `00:20:23` · **ASR 术语或名称** · “reloop / aphine” 是术语 ASR，语义应接近 ReLU / affine。 ([003.md](/courses/cmu-11785-s26/lectures/011/#section-03))
- `00:20:23` · **上下文或语义不清** · 字幕或语义需回听确认。 ([003.md](/courses/cmu-11785-s26/lectures/011/#section-03))
- `00:25:42` · **上下文或语义不清** · “backdrop” 应为 backprop。 ([003.md](/courses/cmu-11785-s26/lectures/011/#section-03))
- `00:29:13` · **代码、API 或实现** · “aphine” 应为 affine；本文件已按语义理解为“仿射函数”。 ([003.md](/courses/cmu-11785-s26/lectures/011/#section-03))
- `00:30:29` · **上下文或语义不清** · “Yan Neman / lit five / linet” 应为 Yann LeCun / LeNet-5。 ([004.md](/courses/cmu-11785-s26/lectures/011/#section-04))
- `00:31:15` · **上下文或语义不清** · “MNEST” 应为 MNIST。 ([004.md](/courses/cmu-11785-s26/lectures/011/#section-04))
- `00:39:20` · **上下文或语义不清** · 字幕或语义需回听确认。 ([004.md](/courses/cmu-11785-s26/lectures/011/#section-04))
- `00:39:20` · **公式、符号或数值** · 符号口述里 “M / N / K / L” 的索引对象存在 ASR 噪声，本笔记仅保留老师明确说明的角色分工，不擅自重写完整公式。 ([004.md](/courses/cmu-11785-s26/lectures/011/#section-04))
- `00:43:01` · **公式、符号或数值** · transcript 在一般尺寸公式处把输入宽与 filter 宽都听成了 n，语义上应是输入边长 $n$、filter 边长 $m$。 ([005.md](/courses/cmu-11785-s26/lectures/011/#section-05))
- `00:43:01` · **上下文或语义不清** · 字幕或语义需回听确认。 ([005.md](/courses/cmu-11785-s26/lectures/011/#section-05))
- `00:45:17` · **上下文或语义不清** · transcript 在 padding 处把“列”“行”交替写错了几次，但老师想表达的是上下左右各补同样厚度的零。 ([005.md](/courses/cmu-11785-s26/lectures/011/#section-05))
- `00:56:06` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/cmu-11785-s26/lectures/011/#section-06))
- `00:56:06` · **公式、符号或数值** · 带 stride 的卷积尺寸公式在 transcript 中变量和括号不稳定。 ([006.md](/courses/cmu-11785-s26/lectures/011/#section-06))
- `00:57:47` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/cmu-11785-s26/lectures/011/#section-06))
- `00:57:47` · **公式、符号或数值** · 带 stride 的 pooling 尺寸公式同样有 ASR 歧义，建议对照原视频或板书再定稿。 ([006.md](/courses/cmu-11785-s26/lectures/011/#section-06))
- `00:59:30` · **课件与口述差异** · “fractional stride convolution” 前后的口头描述较快，若后续要抽出正式定义，建议再听一遍。 ([006.md](/courses/cmu-11785-s26/lectures/011/#section-06))
- `01:00:52` · **上下文或语义不清** · “insert SUS one rows” 应为插入 $S-1$ 行/列零。 ([007.md](/courses/cmu-11785-s26/lectures/011/#section-07))
- `01:06:20` · **课件与口述差异** · transcript 把 2x2、4x4 这类口头表达写成 “2 + 2, 4 + 4”，含义是二维 filter 大小而非求和。 ([007.md](/courses/cmu-11785-s26/lectures/011/#section-07))
- `01:15:24` · **上下文或语义不清** · transcript 把输入总值数记成 “KN”，按语义应为“channels 数 × 空间元素数”，在方形输入下应是 $k n^2$。 ([008.md](/courses/cmu-11785-s26/lectures/011/#section-08))
- `01:15:24` · **上下文或语义不清** · 字幕或语义需回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/011/#section-08))
- `01:15:42` · **上下文或语义不清** · “size is still going to be m cross n” 处变量混杂；老师本意是“暂时忽略边缘效应，空间尺寸先视为不变”。 ([008.md](/courses/cmu-11785-s26/lectures/011/#section-08))
- `01:18:18` · **ASR 术语或名称** · “KL for the L layer or the L as a post...” 一句 ASR 较乱，但最终不等式 $K_l \ge D^2 K_{l-1}$ 是明确可辨的。 ([008.md](/courses/cmu-11785-s26/lectures/011/#section-08))
- `01:20:22` · **上下文或语义不清** · “they’re the same” 对应的 poll 题干未完整保留在 transcript 中，但从上下文看是在重申两组数量关系相同。 ([009.md](/courses/cmu-11785-s26/lectures/011/#section-09))
- `01:20:25` · **课件与口述差异** · 口头配置是否对应老师心中的 LeNet-1/LeNet-5 具体版本，建议后续如需精确命名再对照视频或原图。 ([009.md](/courses/cmu-11785-s26/lectures/011/#section-09))

### Lecture 11: CNNs III

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/012/)。
- `00:02:07` · **上下文或语义不清** · transcript 中 “The grade out topics” 应为 “The grayed out topics”。 ([001.md](/courses/cmu-11785-s26/lectures/012/#section-01))
- `00:02:59` · **上下文或语义不清** · transcript 出现 “time delay neural neural network” 重复，语义应为 time-delay neural network。 ([001.md](/courses/cmu-11785-s26/lectures/012/#section-01))
- `00:07:21` · **ASR 术语或名称** · 投票故障处有一段字幕中断，原句为 “We have forgotten to set up the ...”。 ([001.md](/courses/cmu-11785-s26/lectures/012/#section-01))
- `00:09:11` · **上下文或语义不清** · transcript 中 “drop sus one rows” 应对应 “drop S-1 rows/columns”。 ([001.md](/courses/cmu-11785-s26/lectures/012/#section-01))
- `00:13:07` · **上下文或语义不清** · transcript 中 “km divergence” 应为 KL divergence。 ([002.md](/courses/cmu-11785-s26/lectures/012/#section-02))
- `00:13:07` · **课件与口述差异** · 所指的 KL divergence 对应。[课件 p.42-p.43] ([002.md](/courses/cmu-11785-s26/lectures/012/#section-02))
- `00:16:58` · **上下文或语义不清** · transcript 中 “flat NLP” 应为 “flat MLP”。 ([002.md](/courses/cmu-11785-s26/lectures/012/#section-02))
- `00:17:12` · **课件与口述差异** · transcript 多次把 affine 识别成 “aphine/aine”，中文笔记已按课件统一为 affine map/仿射图。 ([002.md](/courses/cmu-11785-s26/lectures/012/#section-02))
- `00:21:48` · **上下文或语义不清** · transcript 中 “aphine/aine” 均应是 affine。 ([003.md](/courses/cmu-11785-s26/lectures/012/#section-03))
- `00:24:30` · **课件与口述差异** · transcript 将层索引和 filter 编号口头说得较快，具体英文句式存在 ASR 误写，但不影响依赖关系本身。 ([003.md](/courses/cmu-11785-s26/lectures/012/#section-03))
- `00:29:53` · **ASR 术语或名称** · 结尾处 “comput trying” 为明显 ASR 拼接错误。 ([003.md](/courses/cmu-11785-s26/lectures/012/#section-03))
- `00:32:38` · **上下文或语义不清** · transcript 中 “For Z20 I'm using W2” 省略了一维索引，应是某个两维权重坐标。 ([004.md](/courses/cmu-11785-s26/lectures/012/#section-04))
- `00:37:57` · **ASR 术语或名称** · transcript 中 “aphine element y lmxy” 为 ASR 对 affine element 的误写。 ([004.md](/courses/cmu-11785-s26/lectures/012/#section-04))
- `00:38:08` · **上下文或语义不清** · transcript 出现 “zap” 应为 Z map。 ([004.md](/courses/cmu-11785-s26/lectures/012/#section-04))
- `00:44:31` · **课件与口述差异** · 老师口头尺寸推导中夹杂了几次重复与改口，最终结论明确为补零后尺寸 $m+k-1$。 ([005.md](/courses/cmu-11785-s26/lectures/012/#section-05))
- `00:45:03` · **上下文或语义不清** · transcript 中一处把 $m$ 识别成 $n$，笔记按上下文统一为输入尺寸 $m$。 ([005.md](/courses/cmu-11785-s26/lectures/012/#section-05))
- `00:46:28` · **上下文或语义不清** · transcript “K minus one rows and zeros on every side” 应为 rows and columns of zeros。 ([005.md](/courses/cmu-11785-s26/lectures/012/#section-05))
- `00:50:47` · **课件与口述差异** · 口头说明引用的是后续层 filters，而配套课件材料却仍是最初的 Poll 1，二者明显不匹配；本段笔记以 transcript 为准。 ([006.md](/courses/cmu-11785-s26/lectures/012/#section-06))
- `00:56:02` · **ASR 术语或名称** · transcript 中 “zy / yx + 1 / y + 2” 为 ASR 混乱，笔记按老师给出的规律统一整理为 $y_{x+i,y+j}$。 ([006.md](/courses/cmu-11785-s26/lectures/012/#section-06))
- `00:58:31` · **上下文或语义不清** · transcript 把 “times the derivative” 识别成 “time zy”，语义已按链式法则整理。 ([006.md](/courses/cmu-11785-s26/lectures/012/#section-06))
- `01:02:36` · **上下文或语义不清** · 老师先口误说成 “n plus k minus one”，随即更正为前向输出大小 $m-k+1$；笔记采用更正后的版本。 ([007.md](/courses/cmu-11785-s26/lectures/012/#section-07))
- `01:07:13` · **公式、符号或数值** · transcript 中 “DL / DY + C= W DL / DZ” 为 ASR 误写；老师语义是在描述对 $Y$ 的梯度累积更新。 ([007.md](/courses/cmu-11785-s26/lectures/012/#section-07))
- `01:08:34` · **课件与口述差异** · transcript 中的口头规则省略了部分索引与转置细节，本段仅保留老师明确说出的累积形式。 ([007.md](/courses/cmu-11785-s26/lectures/012/#section-07))
- `01:10:09` · **公式、符号或数值** · transcript 中窗口数值被识别成 “1 63 1 3 6 and 5”，根据上下文应是一个四元素窗口，最大值为 6；具体口头报数可再回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/012/#section-08))
- `01:12:01` · **公式、符号或数值** · transcript 中 “y kl / ig element / pulley” 为 ASR 误写，语义是“若该输入位置是前向复制到输出的位置，则接收该输出位置的梯度”。 ([008.md](/courses/cmu-11785-s26/lectures/012/#section-08))
- `01:19:31` · **上下文或语义不清** · transcript 中 “succent / cooling layers” 应分别是 succinct 与 pooling layers。 ([008.md](/courses/cmu-11785-s26/lectures/012/#section-08))

### Lecture 12: CNNs IV

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/013/)。
- `00:01:35` · **上下文或语义不清** · 。 ([001.md](/courses/cmu-11785-s26/lectures/013/#section-01))
- `00:03:55` · **上下文或语义不清** · 。 ([001.md](/courses/cmu-11785-s26/lectures/013/#section-01))

### Lecture 13: Recurrent Neural Networks (RNNs) I

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/014/)。
- `00:01:08` · **上下文或语义不清** · 。 ([001.md](/courses/cmu-11785-s26/lectures/014/#section-01))
- `00:07:30` · **上下文或语义不清** · 。 ([001.md](/courses/cmu-11785-s26/lectures/014/#section-01))
- `00:09:44` · **上下文或语义不清** · 。 ([001.md](/courses/cmu-11785-s26/lectures/014/#section-01))
- `00:14:04` · **上下文或语义不清** · 。 ([002.md](/courses/cmu-11785-s26/lectures/014/#section-02))
- `00:20:16` · **上下文或语义不清** · 。 ([002.md](/courses/cmu-11785-s26/lectures/014/#section-02))
- `00:21:31` · **上下文或语义不清** · 。 ([003.md](/courses/cmu-11785-s26/lectures/014/#section-03))
- `00:24:13` · **上下文或语义不清** · 。 ([003.md](/courses/cmu-11785-s26/lectures/014/#section-03))
- `00:34:18` · **上下文或语义不清** · 。 ([004.md](/courses/cmu-11785-s26/lectures/014/#section-04))
- `00:34:45` · **上下文或语义不清** · 。 ([004.md](/courses/cmu-11785-s26/lectures/014/#section-04))
- `00:40:21` · **上下文或语义不清** · [需回听 00:40:48]。 ([005.md](/courses/cmu-11785-s26/lectures/014/#section-05))
- `00:40:21` · **上下文或语义不清** · 。 ([005.md](/courses/cmu-11785-s26/lectures/014/#section-05))
- `00:50:14` · **上下文或语义不清** · [需回听 00:55:45]。 ([006.md](/courses/cmu-11785-s26/lectures/014/#section-06))
- `01:07:52` · **上下文或语义不清** · 。 ([007.md](/courses/cmu-11785-s26/lectures/014/#section-07))
- `01:09:22` · **上下文或语义不清** · [需回听 01:09:30]。 ([008.md](/courses/cmu-11785-s26/lectures/014/#section-08))
- `01:09:22` · **上下文或语义不清** · 。 ([007.md](/courses/cmu-11785-s26/lectures/014/#section-07))
- `01:19:42` · **上下文或语义不清** · 。 ([009.md](/courses/cmu-11785-s26/lectures/014/#section-09))
- `01:19:50` · **上下文或语义不清** · 。 ([009.md](/courses/cmu-11785-s26/lectures/014/#section-09))

### Lecture 14: RNNs II

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/015/)。
- `00:00:50` · **ASR 术语或名称** · ` ASR 把 “recurrent neural networks” 识别成了 “recreate neural networks”。 ([001.md](/courses/cmu-11785-s26/lectures/015/#section-01))
- `00:06:23` · **ASR 术语或名称** · ` parity 问题里老师口述训练样本数时字幕写成 “two race to two end”，应核对原话是否想表达“指数级覆盖所有模式”；本段笔记只保留了“需要覆盖所有模式”的结论。 ([001.md](/courses/cmu-11785-s26/lectures/015/#section-01))
- `00:10:53` · **ASR 术语或名称** · ` ASR 把 “BIBO stable” 误成了 “bible stable”。 ([002.md](/courses/cmu-11785-s26/lectures/015/#section-02))
- `00:19:02` · **ASR 术语或名称** · ` 字幕中输入系数/记号存在 ASR 抖动，本段只保留“随 $w^t$ 演化”的核心结论。 ([002.md](/courses/cmu-11785-s26/lectures/015/#section-02))
- `00:27:56` · **上下文或语义不清** · ` “what is remembered as a function of both W and B” 的前文特殊情形提及不够干净，本段只保留老师明确说出的结论。 ([003.md](/courses/cmu-11785-s26/lectures/015/#section-03))
- `00:30:41` · **ASR 术语或名称** · ` ASR 把 “Lyapunov” 误成了 “liabo”，本段按稳定性分析术语理解为李雅普诺夫方法。 ([004.md](/courses/cmu-11785-s26/lectures/015/#section-04))
- `00:42:58` · **课件与口述差异** · ` 字幕写成 “emnest model / ELO activation”，应分别理解为 MNIST 与 ELU，具体数据集命名可再核对课件原图。 ([005.md](/courses/cmu-11785-s26/lectures/015/#section-05))
- `00:53:12` · **ASR 术语或名称** · ` ASR 把 “constant error carousel” 识别成了 “constant error corrosive/corrosion”，正文按 LSTM 标准术语整理。 ([006.md](/courses/cmu-11785-s26/lectures/015/#section-06))
- `01:04:04` · **ASR 术语或名称** · ` ASR 写成了 “recurrent reads”，结合上下文应理解为 recurrent weights / recurrences 对主记忆的不良影响。 ([007.md](/courses/cmu-11785-s26/lectures/015/#section-07))
- `01:16:52` · **ASR 术语或名称** · ` “constant error corrosal/corrosal” 仍是 ASR 对 `carousel` 的误识别。 ([008.md](/courses/cmu-11785-s26/lectures/015/#section-08))

### Lecture 15: Sequence to Sequence Models Connectionist Temporal Classification (CTC)

- 讲次笔记：[NOTES.md](/courses/cmu-11785-s26/lectures/016/)。
- `00:03:11` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/016/#section-01))
- `00:03:22` · **上下文或语义不清** · 字幕或语义需回听确认。 ([001.md](/courses/cmu-11785-s26/lectures/016/#section-01))
- `00:15:40` · **上下文或语义不清** · 字幕或语义需回听确认。 ([002.md](/courses/cmu-11785-s26/lectures/016/#section-02))
- `00:27:07` · **上下文或语义不清** · 字幕或语义需回听确认。 ([003.md](/courses/cmu-11785-s26/lectures/016/#section-03))
- `00:29:57` · **上下文或语义不清** · 字幕或语义需回听确认。 ([003.md](/courses/cmu-11785-s26/lectures/016/#section-03))
- `00:32:19` · **上下文或语义不清** · 字幕或语义需回听确认。 ([004.md](/courses/cmu-11785-s26/lectures/016/#section-04))
- `00:38:51` · **上下文或语义不清** · 字幕或语义需回听确认。 ([004.md](/courses/cmu-11785-s26/lectures/016/#section-04))
- `00:44:20` · **上下文或语义不清** · 字幕或语义需回听确认。 ([005.md](/courses/cmu-11785-s26/lectures/016/#section-05))
- `00:47:53` · **上下文或语义不清** · 字幕或语义需回听确认。 ([005.md](/courses/cmu-11785-s26/lectures/016/#section-05))
- `00:50:35` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/cmu-11785-s26/lectures/016/#section-06))
- `00:57:08` · **上下文或语义不清** · 字幕或语义需回听确认。 ([006.md](/courses/cmu-11785-s26/lectures/016/#section-06))
- `01:06:27` · **上下文或语义不清** · 字幕或语义需回听确认。 ([007.md](/courses/cmu-11785-s26/lectures/016/#section-07))
- `01:17:12` · **上下文或语义不清** · 字幕或语义需回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/016/#section-08))
- `01:19:08` · **上下文或语义不清** · 字幕或语义需回听确认。 ([008.md](/courses/cmu-11785-s26/lectures/016/#section-08))
- `01:21:03` · **上下文或语义不清** · 字幕或语义需回听确认。 ([009.md](/courses/cmu-11785-s26/lectures/016/#section-09))

### Lecture 16: Connectionist Temporal Classification Blanks Beam Search

- 当前分段笔记没有待回听标记。

### Lecture 17: Language Models Translation

- 当前分段笔记没有待回听标记。

### Lecture 18: Attention Models Transformers

- 当前分段笔记没有待回听标记。

### Lecture 19: Transformers and Newer Architectures

- 当前分段笔记没有待回听标记。

### Lecture 20: Large Language Models

- 当前分段笔记没有待回听标记。

### Lecture 21: Representation and Autoencoders

- 当前分段笔记没有待回听标记。

### Lecture 22: Variational Auto Encoders

- 当前分段笔记没有待回听标记。

### Lecture 23: Diffusion

- 当前分段笔记没有待回听标记。

### Lecture 24: Generative Adversarial Networks

- 当前分段笔记没有待回听标记。

### Lecture 25: Graph Neural Networks (GNNs)

- 当前分段笔记没有待回听标记。

### Lecture 26: Reinforcement Learning

- 当前分段笔记没有待回听标记。

### Lecture 27: Hopfield Networks

- 当前分段笔记没有待回听标记。

### Lecture 28: Boltzmann Machines

- 当前分段笔记没有待回听标记。

## 复核方法

1. 先打开对应分段笔记，确认疑点在整段教学链条中的作用。
2. 回到时间戳附近前后至少 15 秒，避免只听单个词。
3. 同时检查本讲课件页；若口述与课件不同，保留双方并注明差异。
4. 修订分段笔记后，同步更新讲次 `NOTES.md` 中嵌入的对应段落。
5. 只有证据足够时才移除 `[需回听]`；不确定时保留。
