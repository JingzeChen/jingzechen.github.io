# 术语表与复习卡

## 自动转写术语提示

| 规范词 | 自动转写常见变体 | 说明 | 置信度 |
| --- | --- | --- | --- |
| 杨植麟 | 杨志玲 | 嘉宾 | 高 |
| 月之暗面 / Moonshot AI | 登月公司 | Kimi 公司 | 高 |
| Kimi K1.5 / K2 / K3 | KL、K20、gk2 | 模型版本 | 高 |
| MoE | MoE | Mixture of Experts | 高 |
| Muon | 没有优化器、Mule | 矩阵优化器 | 高 |
| MuonClip | Muon Clip | Muon 稳定化方法 | 高 |
| Adam | ADM | 优化器 | 高 |
| Token Efficiency | Token Efficiency | 单位训练 Token 学习效率 | 高 |
| Rephrase | Rephrase | 数据改写 | 高 |
| MaxLogit | MaxLogic、MathLogic | 训练稳定性指标 | 中高 |
| RL / RLHF | IL、IO、RHF | 强化学习/人类反馈强化学习 | 高 |
| SFT | SFT | 监督微调 | 高 |
| Test-Time Scaling | Test-Time Scaling | 推理阶段扩展计算 | 高 |
| Brain in a Vat | 肛中之脑 | 缸中之脑 | 高 |
| Reasoner | Resonant | 推理模型 | 高 |
| Agent | Agent | 多轮工具使用系统 | 高 |
| L1–L5 | Chatbot、Reasoner、Agent、Innovator、Organization | 能力里程碑 | 高 |
| Universal Constructor | Universal Constructor | 通用构造器 | 高 |
| Pass@k / Pass@1 | Path-XK、Path-1 | 多次/单次通过率 | 中高 |
| Claude / Claude Code | Cloud、Clock Code | Anthropic 模型/产品 | 高 |
| ChatGPT Agent | TrashGPT Agent | OpenAI Agent 产品 | 高 |
| Manus | Minus | Agent 产品 | 高 |
| SWE-bench | Sweep/Sweet Bench | 软件工程评测 | 高 |
| Long Context | Long Contract | 长上下文 | 高 |
| Linear Attention | Linear Tension | 线性注意力 | 高 |
| Context Engineering | Context Engineering | 上下文工程 | 高 |
| First-Party Agent | 一方产品 | 模型厂商自建 Agent | 高 |
| PMF | PMF | Product-Market Fit | 高 |
| ARR | ARR | 年度经常性收入 | 高 |
| AI Factory | AI Factory | 算力生产智能的比喻 | 高 |
| The Beginning of Infinity | 无穷的开始 | David Deutsch 著作 | 高 |
| Reward Hacking | Reward Hacking | 奖励投机 | 高 |

## 仍需回听或查官方资料

- K2 训练中的 MaxLogit 指标、Clipping 方案和 MuonClip 消融。
- K2 实际数据改写比例、数据来源和版权治理。
- 未公开团队分工、K2 参与 K3 研发的任务比例。
- 用户数、ARR、盈利和市场份额等财务信息。
- 快问快答中若干模型名和产品名的低置信度 ASR。

## 15 张复习卡

### 1. “无限雪山”表达什么？

**时间：** `00:01:49`

**问：** 为什么 AGI 不是山顶？

**答：** 每解决一个问题都会出现新问题，进步是持续扩展知识和能力边界，而非抵达封闭终点。

### 2. Reasoning 怎样进行 Test-Time Scaling？

**时间：** `00:10:25`

**问：** 内部思考如何提升能力？

**答：** 增加串行思考 Token，让模型反复提出猜想、自我验证并修正。

### 3. Agent 与“缸中之脑”有何区别？

**时间：** `00:12:59`

**问：** 环境反馈改变了什么？

**答：** Agent 使用工具改变外部状态，并根据新反馈决定下一步，而非只在内部 Token 空间思考。

### 4. Test-Time Scaling 的两条轴是什么？

**时间：** `00:14:14`

**问：** Reasoning 与 Agent 如何统一？

**答：** 一条轴增加思考 Token，另一条增加工具调用和环境交互轮次。

### 5. L1–L5 是严格阶梯吗？

**时间：** `00:18:17`

**问：** 为什么可以并行发展？

**答：** Chatbot、Reasoner、Agent、Innovator、Organization 是相互依赖的里程碑，不是等距串行等级。

### 6. Innovator 的标志是什么？

**时间：** `00:20:24`

**问：** 模型怎样参与下一代模型研发？

**答：** 提出想法、实现实验、分析结果，并把反馈用于后续模型、数据和系统改进。

### 7. K2 的两项核心目标是什么？

**时间：** `00:24:58`

**问：** Base 与 Agentic 如何并列？

**答：** 做强基础模型，并获得跨任务、工具和环境的 Agent 泛化能力。

### 8. Token Efficiency 是什么？

**时间：** `00:26:44`

**问：** 它与训练吞吐有什么不同？

**答：** 表示同量训练数据获得更多能力，而不是只把相同训练更快跑完。

### 9. Muon 的价值主张是什么？

**时间：** `00:28:16`

**问：** 为什么需要独立复现？

**答：** 团队称其在特定小实验中约有两倍 Token Efficiency，但规模、数据和基线条件不完整。

### 10. K2 Agent 的最大挑战是什么？

**时间：** `00:32:47`

**问：** 为什么不是 Benchmark 分数？

**答：** 真正难点是新工具、新环境和 OOD 任务的泛化，单项分数可能来自过拟合。

### 11. Agent 的最小定义是什么？

**时间：** `00:41:03`

**问：** 哪两个特征不可缺？

**答：** 多轮行动与工具使用，使模型能从环境反馈中持续更新决策。

### 12. 为什么长上下文仍是瓶颈？

**时间：** `00:52:40`

**问：** 扩大窗口有什么代价？

**答：** 必须在容量、短上下文智力、推理效率、记忆选择和成本之间平衡。

### 13. 为什么从闭源转向开放？

**时间：** `00:54:08`

**问：** 技术信念和市场策略怎样同时存在？

**答：** 开放扩大部署和生态，也能在未绝对领先时争取开发者；两种动机不冲突。

### 14. 第一方 Agent 的优势是什么？

**时间：** `01:05:00`

**问：** 为什么模型公司可能有更高上限？

**答：** 可以先设计工具和环境，再在其中端到端训练模型，使模型与产品共同优化。

### 15. RL 式管理的风险是什么？

**时间：** `01:25:05`

**问：** 为什么不能只设指标？

**答：** 奖励设计不完整会导致 Reward Hacking；但过多 SFT 式直接指令又会压制主动性。

## 引用注意事项

- 自动转写不是嘉宾确认的逐字稿。
- K2 架构和公开指标应以模型卡与技术报告为准。
- Muon 效率、数据改写、稳定性和内部流程属于团队口径。
- 收入、盈利、用户和公司边界判断需要财务与产品数据。
- 本节目不构成投资建议。