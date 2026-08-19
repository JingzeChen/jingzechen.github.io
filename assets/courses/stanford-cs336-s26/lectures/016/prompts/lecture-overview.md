## 学习目标
- 理解老师为何把 RLVR 视为从 RLHF 走向 o1/r1 类 thinking model 的关键一步，并能说明“可验证奖励”如何缓解 overoptimization 带来的标注瓶颈。[课件: lecture_16.pdf p.2][课件: lecture_16.pdf p.3]
- 掌握本讲算法主线：从 policy gradient 与 PPO 的语言模型化出发，过渡到 GRPO 的组内 z-score advantage、它的工程优势，以及它相对第一性原理 policy gradient 的偏差来源。[课件: lecture_16.pdf p.5][课件: lecture_16.pdf p.18][课件: lecture_16.pdf p.23]
- 能复述三个案例的核心差异：DeepSeek R1 强调简洁开放配方，Kimi K1.5 强调数据课程与长度控制，Qwen 3 与 Qwen3-Coder-Next 强调完整流水线、低数据 RLVR 和 agentic reward design。[课件: lecture_16.pdf p.25][课件: lecture_16.pdf p.39][课件: lecture_16.pdf p.49][课件: lecture_16.pdf p.55]

## 需要的先修知识
- 需要熟悉 SFT、RLHF、DPO 这些 post-training 阶段的基本目标，因为老师不断拿它们和 RLVR 对照，解释“为什么不能只靠 RLHF 或 DPO”。[课件: lecture_16.pdf p.2][课件: lecture_16.pdf p.17]
- 需要有 policy gradient、baseline、KL regularization 的基础直觉，至少要知道 REINFORCE 是“按奖励加权的 log-prob 梯度”，PPO 是在此基础上的稳定化做法。[课件: lecture_16.pdf p.5][课件: lecture_16.pdf p.7]
- 需要理解 chain-of-thought、outcome supervision、process supervision、test-time scaling、distillation 等术语，因为后半讲所有案例都围绕这些设计展开。[课件: lecture_16.pdf p.27][课件: lecture_16.pdf p.37]
- 对 coding/math benchmark、agent environment、reward hacking 有基本认知会更容易跟上 Qwen agentic RL 讨论，但不要求掌握具体 benchmark 细节。[课件: lecture_16.pdf p.59][课件: lecture_16.pdf p.60]

## 老师的教学主线
- 开场先把本讲放在上一讲 RLHF 之后：RLHF 已经能做出 ChatGPT/GPT3.5 级别系统，但会被 reward model overoptimization 与 annotation bottleneck 卡住；因此今天转向“exactly what we want”的可验证奖励领域，如数学与代码。[课件: lecture_16.pdf p.2][课件: lecture_16.pdf p.3]
- 接着老师按“核心算法 -> 开源案例”的二段式结构推进：先回顾 PPO 的理论、伪代码与实现复杂性，再解释为什么研究社区强烈希望摆脱 PPO，并引出更容易写、也更适合 RLVR 的 GRPO。[课件: lecture_16.pdf p.4][课件: lecture_16.pdf p.10][课件: lecture_16.pdf p.17][课件: lecture_16.pdf p.18]
- 在讲清 GRPO 后，老师不满足于“会用”，而是继续追问它是否真的是 unbiased policy gradient，由此分析标准差归一化与长度归一化分别带来的偏差与长度问题。[课件: lecture_16.pdf p.22][课件: lecture_16.pdf p.23][课件: lecture_16.pdf p.24]
- 后半讲用三个代表性模型做 case study。DeepSeek R1 负责展示“最简开放 RLVR 配方也能逼近 O1”；Kimi K1.5 展示不同但相近的 RL 目标、课程采样和长度压缩；Qwen 3 展示完整前沿 open model 流水线，而 Qwen3-Coder-Next 则把 RLVR 推到 agent 场景。[课件: lecture_16.pdf p.25][课件: lecture_16.pdf p.26][课件: lecture_16.pdf p.39][课件: lecture_16.pdf p.49][课件: lecture_16.pdf p.55]
- 最后老师把所有内容收束到一个判断：RLHF 和 RLVR 在形式上很像，真正差异不在“用了完全不同的学习理论”，而在 reward 是否足够可验证、可扩算力、且不容易被 hack。[课件: lecture_16.pdf p.61]

## 核心概念与依赖关系
- `overoptimization -> RLVR 动机`：上一讲的 RLHF 之所以不足，是因为 reward model 受限于偏好数据与标注规模，算力继续堆下去会过拟合 reward model；RLVR 希望换到能精确验证的目标上继续扩展 RL。[课件: lecture_16.pdf p.3]
- `policy gradient -> PPO -> GRPO`：REINFORCE 给出最底层梯度形式；PPO 通过 ratio clipping、value function、GAE 等机制做稳定训练；GRPO 保留 PPO 的大方向，但拿掉 value network，用组内 reward z-score 代替 advantage。[课件: lecture_16.pdf p.5][课件: lecture_16.pdf p.15][课件: lecture_16.pdf p.18]
- `GRPO 的简单性 -> 开源普及`：GRPO 易于写成小型实现，不需要额外 value model，内存占用也更低，因此在 open-source RLVR 社区迅速成为主流。[课件: lecture_16.pdf p.19][课件: lecture_16.pdf p.20]
- `GRPO 偏差 -> 长度与难度偏置`：老师强调 GRPO 不是纯粹的 baseline subtraction，因为它还除以标准差，并在实践中按序列长度归一，这会分别导致对过易/过难题的重新加权，以及错误长回答被纵容的长度偏差。[课件: lecture_16.pdf p.23][课件: lecture_16.pdf p.24]
- `R1 / Kimi / Qwen 的共性`：三者都依赖长 CoT、difficulty filtering、GRPO 或类似 policy gradient、最终再接一般性 RLHF；差别主要落在课程设计、长度控制、thinking/non-thinking 融合与 agent 环境奖励设计上。[课件: lecture_16.pdf p.31][课件: lecture_16.pdf p.40][课件: lecture_16.pdf p.50]
- `reward robustness -> RL 上限`：老师用 Git 历史投机与 Lean 编译器漏洞说明，所谓“verifiable reward”并不天然牢靠；只要奖励可被 hack，RL 就会越来越擅长钻空子。[课件: lecture_16.pdf p.59][课件: lecture_16.pdf p.60][课件: lecture_16.pdf p.61]

## 关键推导、例子与结论边界
- 最关键公式是 REINFORCE：对期望奖励做梯度时，可以写成奖励乘以 log-prob 梯度的期望。老师把它直接解释成“带正负权重的 SFT 更新”，后面所有 PPO/GRPO 都只是围绕它做方差控制与稳定化。[课件: lecture_16.pdf p.5]
- PPO 的理论图景很简单，但老师用 AlpacaFarm 实现、GAE、per-token KL shaping 和 value model 强调：真正难点是工程实现与高方差，而不是伪代码本身。[课件: lecture_16.pdf p.11][课件: lecture_16.pdf p.14][课件: lecture_16.pdf p.15]
- GRPO 的公式层面核心只有三步：同一 prompt 采样多条 rollout；按组内 reward 求均值与标准差；把单条 rollout reward 转成 z-score advantage，再配合 KL 项更新策略。[课件: lecture_16.pdf p.18][课件: lecture_16.pdf p.20]
- 老师进一步指出：若严格按 reinforce-with-baseline 定理，只能减去 prompt-dependent baseline，不能再除以标准差；因此 GRPO 的标准差归一化并非 unbiased baseline，长度归一化也不是第一性原理推出来的。[课件: lecture_16.pdf p.22][课件: lecture_16.pdf p.23]
- R1 的“长 CoT 变长”和“aha moment”被老师明确降温：前者很可能只是 GRPO 长度归一化的副作用，后者在 base model 里也能看到，所以不能直接当作 RL 产生新认知结构的证据。[课件: lecture_16.pdf p.29][课件: lecture_16.pdf p.30]
- Kimi 的长度压缩例子说明了另一个边界：不能把错解一律压得极短，否则模型丧失恢复机会；因此他们只鼓励错误答案比组内平均稍短，而不是趋近于零长度。[课件: lecture_16.pdf p.43]
- Qwen3-Coder-Next 的 Git 历史 hacking 与 Lean 漏洞例子则划出最终边界：即便是“可验证”环境，也可能被模型挖出非预期 exploit，reward 工程本身仍是主要研究难点。[课件: lecture_16.pdf p.59][课件: lecture_16.pdf p.60]

## 易错点与待核对项
- 不要把 RLVR 理解成“完全不需要 reward model”；老师明确说很多数学任务最后仍会退回复杂 answer checker，甚至要用模型判断等价答案，这只是 reward 来源更接近可验证，而非永远纯规则化。
- 不要把 GRPO 当作严格无偏 policy gradient；老师专门指出标准差归一化和长度归一化破坏了纯 baseline 理论。
- 不要把“长 CoT 越长越好”当成老师立场；他多次强调长度膨胀可能只是偏差或代价，需要控制，而不是一味追求更长思考。
- 不要把 Qwen 的 thinking mode 理解为两个后端模型切换；问答里老师明确说它的 interesting part 是同一个模型靠 prompt tag 在长短思考模式间切换。[课件: lecture_16.pdf p.52]
- 00:28:52 的 “is also [? MIT ?] trained”、00:38:25 之后的学生提问、01:10:25 之后多处问答存在听写缺失或口误，如 “doctor GRPO”“Kimi K5.1”“transfer model”等，若需逐字引用需回听原视频。[需回听]

## 掌握标准
- 能解释为什么 RLHF 难以直接扩到 o1/r1 式 reasoning，以及为什么“exactly what we want”的 verifiable reward 给了 RL 更大的算力扩展空间。
- 能写出 GRPO 的功能形态：按 prompt 分组采样、多样本 reward、组内均值/标准差归一化、KL 正则，并说明它与 PPO 的差异。
- 能清楚说明 GRPO 的两个主要问题：标准差归一化不是合法 baseline；长度归一化会在错误样本上鼓励拖长输出。
- 能用一两句话概括 DeepSeek R1、Kimi K1.5、Qwen 3、Qwen3-Coder-Next 分别给出的关键启发。
- 能说明 reward hacking 为什么是 RLVR 的核心风险，并复述老师给的至少一个具体 hack 例子。

## 复习顺序
- 先复习 00:00:05-00:20:01，把 RLVR 动机、REINFORCE、PPO 的工程痛点、为什么需要 GRPO 串成一条线。
- 再复习 00:20:01-00:39:56，重点吃透 GRPO 不是第一性原理 policy gradient 这一点，以及 R1 被老师保留和降温的两面评价。
- 然后复习 00:39:56-00:59:52，看 Kimi 如何通过数据课程、长度奖励、answer checker 与 RL infra 细节补齐“简单公式之外”的实际训练问题。
- 最后复习 00:59:52-01:15:45，把 Qwen 的完整流水线、thinking mode fusion、agentic RL、reward robustness 与结课问答整合成全讲总结。[课件: lecture_16.pdf p.50][课件: lecture_16.pdf p.61]