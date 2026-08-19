# Lecture 15: Mid/post-training (SFT/RLHF)

整理模式：仅依据当前讲次目录下 prompts\sections\001-008.md 提供的 transcript 与课件材料整理；未引入外部资料，未补写未给出的页码。

## 学习目标

本讲的直接目标，是把“已经通过 pre-training 得到强 base model”这件事继续往前推进，回答两个连续问题：第一，怎样把 GPT-3 级别 base model 拉到接近 ChatGPT 的 instruction-following 水平；第二，为什么在这一步之后还要继续用 RLHF，而不是只靠更多 demonstration data。[课件: lecture_15.pdf p.1] [课件: lecture_15.pdf p.2] [课件: lecture_15.pdf p.4] [课件: lecture_15.pdf p.31] 学完后应能说清 SFT 数据如何从 FLAN 走到 tool-using agentic format，为什么 style、knowledge、safety 会主导 post-training 效果，以及 PPO、DPO 各自在 RLHF 里解决什么问题。[课件: lecture_15.pdf p.9] [课件: lecture_15.pdf p.14] [课件: lecture_15.pdf p.19] [课件: lecture_15.pdf p.22] [课件: lecture_15.pdf p.49] [课件: lecture_15.pdf p.55]

## 需要的先修知识

老师默认听众已经跟完前面 pre-training 相关课程内容，知道 GPT-3 式 base model 是怎样通过大规模 next-token prediction 得到的，也知道 instruction following、SFT、reward model、KL regularization 这些对象在语言模型语境里的基本含义。[00:02:31-00:02:55] [01:06:11-01:06:56] 要顺畅理解本讲后半，还需要最基础的 RL 直觉，至少知道 policy、reward、policy gradient、KL 约束分别在优化里扮演什么角色；老师虽然刻意把 PPO 讲成“baby RL”，但并没有从零重建这套背景。[01:05:48-01:09:21] [课件: lecture_15.pdf p.50] [课件: lecture_15.pdf p.53]

## 老师的教学主线

整讲按照非常清楚的三段式推进。第一段先说明为什么 pre-training 不等于可用助手，并用 GPT-3 到 ChatGPT 的落差引出 post-training 的必要性；接着把 SFT 拆成“数据长什么样”和“怎么用这些数据”两个问题，再按 FLAN、Alpaca、OpenAssistant、Nemotron 的演化线索解释开放世界 instruction data 的变化。[课件: lecture_15.pdf p.2] [课件: lecture_15.pdf p.6] [课件: lecture_15.pdf p.8] [课件: lecture_15.pdf p.9] [课件: lecture_15.pdf p.13] 第二段转向 SFT pitfalls：style 不等于 capability、citation 可能诱发 hallucination、安全监督必须在 violation rate 与 false refusal 之间权衡；随后老师再指出，现代训练管线越来越把 instruction tuning 融进 pre-training 尾端，也就是 midtraining / two-phase training。[课件: lecture_15.pdf p.15] [课件: lecture_15.pdf p.17] [课件: lecture_15.pdf p.19] [课件: lecture_15.pdf p.21] [课件: lecture_15.pdf p.23] [课件: lecture_15.pdf p.29] [课件: lecture_15.pdf p.30] 第三段进入 RLHF：先解释为什么生成示范不等于人类真正偏好，再讲 pairwise feedback、annotator 分布、model-based annotation，最后落到 PPO、DPO 及其副作用，收束为“数据难、算法更复杂、过优化奖励要非常小心”三条结论。[课件: lecture_15.pdf p.33] [课件: lecture_15.pdf p.35] [课件: lecture_15.pdf p.43] [课件: lecture_15.pdf p.45] [课件: lecture_15.pdf p.49] [课件: lecture_15.pdf p.55] [课件: lecture_15.pdf p.62] [课件: lecture_15.pdf p.65]

## 核心概念与依赖关系

整讲最核心的依赖链是：pre-training 提供广泛但未被精确控制的潜在能力，SFT 负责用高质量行为数据把这些能力抽取成更可控的回答风格与任务行为，而 RLHF 则在 SFT 之上从“模仿参考分布”转入“直接优化偏好奖励”。[00:02:41-00:03:04] [00:33:43-00:34:18] [00:42:24-00:43:49] [课件: lecture_15.pdf p.32] 在 SFT 阶段，style、detail、tool use 是显性变化，但更深层的控制点其实是 quality-vs-quantity trade-off、knowledge formatting、safety supervision 和 midtraining 数据配比。[00:14:27-00:15:24] [00:22:30-00:25:18] [00:28:59-00:30:01] [00:36:10-00:39:21] [课件: lecture_15.pdf p.14] [课件: lecture_15.pdf p.15] [课件: lecture_15.pdf p.19] [课件: lecture_15.pdf p.29] RLHF 阶段的依赖关系则是：先有人类或模型提供 pairwise feedback，再训练 reward 或直接用偏好对做 DPO；与此同时，annotator 人口分布、长度偏差与奖励过优化都会反过来塑造模型最终行为。[00:46:23-00:47:07] [00:53:03-00:57:55] [01:04:31-01:05:23] [01:16:35-01:18:47] [课件: lecture_15.pdf p.36] [课件: lecture_15.pdf p.43] [课件: lecture_15.pdf p.48] [课件: lecture_15.pdf p.63] [课件: lecture_15.pdf p.64]

## 关键推导、例子与结论边界

本讲有两条最关键的理论分界。第一条是 SFT 与 RLHF 的目标函数分界：pre-training / SFT 都在拟合某个参考条件分布，RLHF 则直接寻找最大化期望奖励的 policy，因此从概念上就允许模式塌缩，不再天然保留“概率模型”式的多样性。[00:42:24-00:43:58] [课件: lecture_15.pdf p.32] 第二条是 DPO 的推导链：在“policy 是非参数化全体”这个强假设下，带 KL 的 RLHF 目标有指数倾斜闭式解，再反推出 implied reward，最终把 RLHF 化约成对 chosen / rejected 样本的对比式监督学习。[01:11:18-01:14:14] [课件: lecture_15.pdf p.56] [课件: lecture_15.pdf p.57] [课件: lecture_15.pdf p.58] 经验边界同样被老师反复强调：更长、更 chatty 的回答常常只是在刷偏好分，而不是提高 benchmark capability；给模型塞它并不真正知道的 tail knowledge 可能诱发 hallucination；500 级别安全样本就能大幅 steering 行为，但更细粒度安全边界仍需要大规模数据；DPO 与 PPO 的优劣高度 contingent，不能从单次实验就抽象成普遍定律。[00:20:21-00:21:59] [00:24:02-00:25:18] [00:32:31-00:34:18] [01:15:47-01:16:34] [课件: lecture_15.pdf p.17] [课件: lecture_15.pdf p.21] [课件: lecture_15.pdf p.26] [课件: lecture_15.pdf p.61]

## 易错点与待核对项

最容易出错的第一点，是把 instruction following 的提升误解成“预训练继续放大就会自然发生”；老师的意思相反，pre-training 很关键，但从 base model 到可控助手仍需要显式 post-training 数据与 steering。[00:02:31-00:03:04] 第二点，是把偏好评测上的 style 优势误认成能力优势；讲中多次提醒列表、长度和细节会显著影响人类或模型 judge，却不一定改变标准 benchmark。[00:20:21-00:21:59] 第三点，是把 citation-heavy 高质量样本当作无条件好数据；老师明确说如果模型本来不掌握那部分知识，SFT 反而可能把“应该输出引用”的模板学坏，造成 hallucination。[00:22:30-00:25:18] 第四点，是以为“base model”仍然意味着纯互联网 next-token pretraining；现代 midtraining 常已混入大量聊天或高质量 QA 数据，这个边界正在消失。[00:36:10-00:39:21] 需要回听的地方包括若干学生提问被字幕吞掉的片段、部分论文口头简称、以及结尾提到 assignment 所用算法名的精确拼写。[需回听 00:20:56] [需回听 00:35:06] [需回听 01:03:02] [需回听 01:19:13]

## 掌握标准

学完本讲，至少应能完整回答以下问题：为什么从 GPT-3 到 ChatGPT 的进步不能简单视为“再多一点 pre-training”；为什么 FLAN 到 agentic SFT 数据会逐步走向更长、更 chatty、更结构化；为什么 style、citation、tail knowledge 和 safety 数据会分别以不同方式影响模型；为什么 midtraining 会让“base model”这个概念变得暧昧；为什么 RLHF 与 SFT 在目标函数上是两种不同优化问题；以及 DPO 怎样在保留 RLHF 核心直觉的同时，把训练过程简化得更像普通监督学习。[课件: lecture_15.pdf p.2] [课件: lecture_15.pdf p.9] [课件: lecture_15.pdf p.14] [课件: lecture_15.pdf p.19] [课件: lecture_15.pdf p.29] [课件: lecture_15.pdf p.32] [课件: lecture_15.pdf p.55] [课件: lecture_15.pdf p.56] 进一步的掌握标准，是能主动指出 RLHF 的两个主要风险：一是 reward overoptimization，二是 mode collapse / calibration 下降，并知道这正是下一讲进入 RLVR 时要继续处理的问题。[课件: lecture_15.pdf p.63] [课件: lecture_15.pdf p.64] [课件: lecture_15.pdf p.65]

## 复习顺序

建议先按老师自己的故事顺序复习。第一遍先抓总线：回看开场对 GPT-3、ChatGPT 与 instruction following 的定位，再把 post-training 拆成 SFT 与 RLHF 两段。[00:00:10-00:06:22] 第二遍集中看 SFT 数据：从 FLAN、Alpaca、OpenAssistant、Nemotron 走一遍，再复习 style、knowledge、safety、midtraining 四个关键变形点。[00:07:32-00:40:01] 第三遍单独看 RLHF 数据与 annotator 话题，特别记住 pairwise feedback、demographics、expert annotation、model-based annotation 和长度偏差。[00:42:01-01:05:23] 最后一遍再看算法与风险：先记 PPO 的目标与直觉，再记 DPO 的推导逻辑，最后记住 overoptimization 与 mode collapse 为什么是后续 reasoning 训练绕不过去的问题。[01:05:48-01:19:46] [课件: lecture_15.pdf p.50] [课件: lecture_15.pdf p.53] [课件: lecture_15.pdf p.56] [课件: lecture_15.pdf p.63] [课件: lecture_15.pdf p.64]
