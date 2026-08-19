# Lecture 01 Overview

整理模式：仅依据 8 个 section notes 汇总；不引入 section notes 之外的新材料。

## 学习目标

本讲目标有两层。第一层是给 CS336 定位：这是一门通过亲手构建语言模型来理解现代 LLM 的课程，重点不是追最新产品热点，而是建立可迁移的 mechanics 与 mindset。第二层是进入第一单元 tokenization，说明为什么在今天的模型体系里，tokenizer 仍然是原始文本与模型计算之间不可绕开的接口。

## 需要的先修知识

老师默认学生至少听说过 Transformer，也默认部分同学上过类似 224n 的课程，因此本讲没有从头重讲标准 Transformer，而是把注意力放在现代 refinement、系统问题、scaling、数据与对齐这些真正决定大模型成败的部分。进入 tokenization 时，所需先修仅是理解文本可以表示为 Unicode 字符串、模型处理的是 token 序列这一基本事实。

## 老师的教学主线

整讲的主线非常清晰：先解释为什么要学“from scratch”，再承认前沿模型工业化导致课堂无法直接复现全部真实场景，然后回答“在这种限制下还能学到什么”。老师把可迁移内容收束为 mechanics 与 mindset，并进一步把全课五个模块都统一翻译成“固定资源下最大化效率”的问题。最后再把这个总框架落到 tokenization，说明 tokenizer 的设计本质上也是在表达能力、序列长度、词表大小和计算效率之间做权衡。

## 核心概念与依赖关系

最上层概念是效率。老师反复把语言模型训练表述成“给定数据与算力预算，能造出的最好模型是什么”。在这个视角下，systems 负责算力效率，tokenization 通过缩短序列和支持自适应计算提升效率，architecture 与 training 共同平衡表达能力、稳定性与速度，scaling laws 让昂贵调参转移到小规模实验，data 决定模型最终想学成什么，alignment 则利用弱监督把已有模型往偏好的行为方向再推一步。进入 tokenization 时，又形成另一条局部依赖链：原始文本是 Unicode 字符串，模型处理的是 token 索引序列，因此需要 encode/decode 接口；character、byte、word 三种朴素方案各自失败，BPE 作为折中而出现。

## 关键推导、例子与结论边界

本讲没有大量正式推导，但有几个关键定量或半定量结论。其一是 accuracy 可以从课堂上被理解成 efficiency 与 resources 的乘积，用来强调大规模训练中效率的重要性。其二是 scaling laws 的经验法则 D ≈ 20N，即训练 token 数大致是参数量的 20 倍，但老师明确提醒这会受数据、架构与推理成本影响。其三是 tokenization 的 compression ratio，用 UTF-8 字节数除以 token 数来衡量序列压缩效果，并借此说明为什么 byte tokenizer 太长、词级 tokenizer 太稀、而 BPE 能在两者之间找到更好平衡。结论边界同样被多次强调：小模型并不天然代表前沿模型；scaling laws 不是自然规律，而是要靠 carefully constructed scaling recipe 才能“成立”；未来若出现 tokenizer-free 方案，也仍需满足按可变 chunk 进行建模的要求。

## 易错点与待核对项

最容易误解的地方有四个。第一，不要把 bitter lesson 误读成“算法不重要”，老师的意思是“能随规模扩展的算法才重要”。第二，不要把课程当成“最新 AI 热点速成班”，老师明确说这门课不以多模态或 agents 细节为主。第三，不要把 scaling laws 当成拟合一条线就完事，它依赖 recipe、超参数迁移与可预测性。第四，不要把 tokenizer 当成纯历史包袱，本讲的立场是：即使未来去 tokenizer 化，模型仍需要某种对序列进行抽象和可变切分的机制。需要回听的字幕疑点主要包括若干 ASR 识别错误，如 00:12:54 附近关于 Adam/attention 的串读、00:30:41 附近的混乱措辞，以及少量口语化跳转。

## 掌握标准

学完本讲，至少应能解释：这门课为什么坚持 from scratch；为什么前沿模型工业化并没有使这门课失去意义；五个作业模块各自解决什么问题；为什么老师把所有模块都放进效率视角；scaling recipe 与 hyperparameter transfer 为何是大规模训练的核心；tokenizer 的 encode/decode 与 round-trip 是什么；character、byte、word 方案各自失败在哪；BPE 如何通过高频相邻对合并构造词表；以及未来替代 tokenizer 的方案至少需要满足什么性质。

## 复习顺序

建议按老师原本论证链复习。先复习课程为何存在、为什么不是热点速成，而是研究与工程底层训练。接着看历史脉络与开放生态，理解今天还能从哪里获得可信技术细节。然后复习五个模块如何被统一成效率问题。之后再进入 tokenization：先看 tokenizer 接口和 compression ratio，再比较 character、byte、word 三种基线，最后复习 BPE 的训练、编码与作业实现要求。这样能最大限度保持老师原始论证顺序。
