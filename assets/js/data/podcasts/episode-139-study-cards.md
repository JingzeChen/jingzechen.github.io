# 术语表与复习卡

## 自动转写术语提示

| 规范词 | 自动转写常见变体 | 说明 | 置信度 |
| --- | --- | --- | --- |
| 苏煜 | 苏老师 | 嘉宾 | 高 |
| NeoCognition | Neocognition、Neo Cognition | 嘉宾创办的 Agent Research Lab | 高 |
| Stuart Russell | Stuart Russo | AI 教科书作者 | 高 |
| Peter Norvig | Peter Norvig | AI 教科书作者 | 高 |
| Luke Zettlemoyer | Luke Zettelmayer、Zettelmaier | Semantic Parsing/Tool Use 研究者 | 高 |
| Graham Neubig | Graham Newbig | CMU 研究者 | 高 |
| Dario Amodei | Darrel | Anthropic CEO | 中高 |
| Anthropic | Anthropy、Anthropik | AI 公司 | 高 |
| OpenClaw | OpenCloud、Open Cloud | 本期核心 Agent 产品/项目 | 高 |
| Claude Code | Cloud Code、Cloud Co-work | Coding Agent | 高 |
| Logical Agent | 基于逻辑的 Agent | 符号逻辑智能体 | 高 |
| Neural Agent | Neural Agent | 神经网络智能体 | 高 |
| Semantic Parsing | Semantic Parsing、语义解析 | 自然语言到形式表示 | 高 |
| Language Agent | Language Agent | 语言作为脚手架的 Agent | 高 |
| Inference Engine | Influence Engine | 推理引擎 | 高 |
| Chain-of-Thought | CoT | 思维链 | 高 |
| ReAct | React | Reasoning + Acting | 高 |
| LLM-Planner | LLM Planner | LLM 机器人规划工作 | 高 |
| Mind2Web | MindWeb、Mintweb | Web Agent 数据/研究 | 高 |
| SayCan | Sacan | 机器人规划工作 | 中高 |
| Toolformer | 2former、2use | LLM Tool Use 工作 | 中 |
| WebArena | Web Arena | 可复现 Web Agent 环境 | 高 |
| OSWorld | OS World | 桌面 Computer Use 环境 | 高 |
| SWE-bench | Sweetbench | Coding Agent Benchmark | 高 |
| GPT-4o | GP4O | 多模态模型 | 高 |
| GUI | 故意 | 图形用户界面 | 高 |
| CLI | CLI | 命令行界面 | 高 |
| Continual Learning | Continued Learning | 持续学习 | 高 |
| World Model | World Model | 对环境结构与规律的模型 | 高 |
| Expert Agent | Specialized Agent | 专业化智能体 | 高 |
| A Thousand Brains | Thousand Brains | Jeff Hawkins 理论 | 高 |
| AgentBench | Agent Bench | Agent Benchmark | 高 |
| UI-TARS | UI Tars | Computer Use Agent | 中高 |
| AutoGLM | Auto GLM | 智谱 Agent 产品/技术 | 中高 |

## 仍需回听确认

- `Toolformer / 2former` 的具体论文和作者归属。
- `CACT`、`UGround` 的正式全称和发布时间。
- `LLMs in the Imaginary`、`Learning Tools through Simulated Trial and Error` 的正式书目。
- Project Prometheus、Macrohard 等当前项目的角色、融资和技术范围。
- 部分人物姓名和合作关系因转写无 Speaker 标签，不能仅靠文本确定。

## 15 张复习卡

### 1. Agent 的三个基本要素是什么？

**时间：** `00:03:57`

**问：** 苏煜怎样定义 Agent？

**答：** Agent 是有边界的实体，处在外部环境中，并围绕目标进行活动，而不是随机游荡。

### 2. Memory 与 Autonomy 是什么关系？

**时间：** `00:08:19`

**问：** 为什么 Memory 是 Agent 的基础？

**答：** Memory 保存知识和经验，Autonomy 则用这些内容进行感知、推理、决策和行动；没有可用记忆，自主行动难以可靠。

### 3. Logical Agent 的瓶颈是什么？

**时间：** `00:06:26`

**问：** 专家系统为什么难以扩展？

**答：** 工程师必须访谈专家并手工编码规则，知识获取慢、成本高，也难表达现实世界中的模糊和隐性知识。

### 4. Neural Agent 的进步和限制是什么？

**时间：** `00:13:59`

**问：** 游戏 Agent 为什么还不算人类式通用？

**答：** 它能从数据学习并覆盖相关环境，但通常依赖固定输入、动作和大量交互，面对新环境时学习效率仍低。

### 5. Semantic Parsing 如何扩大行动空间？

**时间：** `00:18:50`

**问：** 自然语言怎样连接外部环境？

**答：** Semantic Parsing 把语言转换为数据库、知识图谱、网站或工具可执行的形式表示。

### 6. 为什么叫 Language Agent？

**时间：** `00:21:38`

**问：** 语言在 Agent 中承担哪些角色？

**答：** 语言同时用于理解、推理、计划、交互、工具调用、代码行动和记忆表达，是通用计算脚手架。

### 7. CoT 与 ReAct 有什么区别？

**时间：** `00:30:02`

**问：** ReAct 比纯 CoT 多了什么？

**答：** CoT 主要生成推理过程；ReAct 把推理放进环境循环，在每一步观察、思考、行动并接收新反馈。

### 8. Mind2Web 与 WebArena 有何区别？

**时间：** `00:36:30`

**问：** 两种 Web Agent 路线分别强调什么？

**答：** Mind2Web 更面向广泛真实网站；WebArena 用网站副本建立可重复、可控的评测环境。

### 9. 什么是 Universal Digital Agent？

**时间：** `00:40:56`

**问：** 为什么 Web、Desktop、Mobile、Coding 不是最终分类？

**答：** 它们只是环境和接口。最终需求是能跨 GUI、CLI、API 和代码完成数字世界任务的通用 Agent。

### 10. OpenClaw Moment 为什么像 ChatGPT Moment？

**时间：** `00:48:56`

**问：** 触发社会认知跃迁的是什么？

**答：** 不是单一新算法，而是成熟技术与新交互、分发、独立环境、持续在线和更大权限的结合。

### 11. 什么是 Specialized Intelligence？

**时间：** `01:02:05`

**问：** 专业化 Agent 与通用模型有什么区别？

**答：** 通用模型提供基础能力，专业化 Agent 则持续学习具体职业、公司、软件和工作流，形成环境特有的可靠能力。

### 12. Continual Learning、World Model 和 Expert Agent 怎样关联？

**时间：** `01:20:30`

**问：** 苏煜提出的统一框架是什么？

**答：** Continual Learning 是过程，World Model 是学习内容，Specialization/Expert Agent 是结果。这个统一是嘉宾的研究框架。

### 13. 为什么 GUI 不会被 CLI 完全取代？

**时间：** `01:37:40`

**问：** GUI 对人和 Agent 仍有什么价值？

**答：** 人需要视觉理解、验证和审计；大量长尾软件只提供 GUI，其中还编码了业务逻辑和约束。

### 14. 当前 Agent 最大瓶颈是什么？

**时间：** `01:44:34`

**问：** 为什么不只是模型能力不足？

**答：** 还包括长程可靠性、持续学习、环境理解、工具选择、错误恢复、成本、速度和权限安全。

### 15. 苏煜最担心的社会风险是什么？

**时间：** `02:05:00`

**问：** 为什么不是近期奇点？

**答：** 他更担心知识工作快速替代、收益集中和再分配不足；对 Agent 短期自发产生生存目标持怀疑态度。

## 引用注意事项

- 自动转写不是嘉宾确认的逐字稿。
- 四阶段技术史、Memory/Autonomy 和持续学习统一框架应归因于苏煜。
- 论文名、作者、日期及“第一个”主张必须查原始文献。
- NeoCognition 融资和各大厂产品策略需查公司公告与同期资料。
- 神经科学类比来自特定理论，不代表学界共识。