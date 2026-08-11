---
title: "Agent 技术综述：从 Logical Agent 到 OpenClaw Moment"
date: 2026-05-02 00:00:00 +0800
updated: 2026-08-11
uid: episode-139-agent-history
type: podcast
content_lang: zh-CN
status: growing
topics: [ai-engineering, machine-learning, software-architecture]
categories: [播客笔记, AI 研究]
tags: [ai-agents, language-agents, openclaw, podcast-notes]
description: "沿 Logical、Neural、Semantic Parsing 到 Language Agent 的技术脉络，讨论通用数字代理、持续学习与 Agent 的现实边界。"
podcast_show: zhang-xiaojun
episode_number: 139
episode_date: 2026-05-02
episode_duration: "02:17:48"
episode_duration_seconds: 8269
guests: [苏煜]
source_platform: 小宇宙
source_url: https://www.xiaoyuzhoufm.com/episode/69f3857a5c60a99573fea0c2
podcast_cover: /assets/img/podcasts/episode-139.jpg
transcript_jsonl: /assets/js/data/podcasts/episode-139.jsonl
transcript_txt: /assets/js/data/podcasts/episode-139.txt
study_cards: /assets/js/data/podcasts/episode-139-study-cards.md
transcript_status: auto-generated
image:
  path: /assets/img/podcasts/episode-139.jpg
  alt: "张小珺 Jùn｜商业访谈录第 139 期封面"
toc: true
---

## 300 字摘要

这期节目把 Agent 放回人工智能的长历史中：从依赖规则和专家知识的 Logical Agent，到通过神经网络在受限环境中学习行为的 Neural Agent，再到把自然语言映射为形式表示的 Semantic Parsing，以及由大语言模型驱动的 Language Agent。苏煜把 Agent 定义为“有边界、处于环境中、围绕目标行动的实体”，并用 Memory 与 Autonomy 两条能力轴解释其演进。

LLM 的意义不只是聊天，而是让语言成为感知、推理、规划、工具调用和行动的通用脚手架。CoT、ReAct、Mind2Web、WebArena、OSWorld 和 Coding Agent 展示了 Agent 从受限接口走向 Universal Digital Agent 的路径。OpenClaw Moment 类似 ChatGPT Moment：底层技术并非突然出现，真正触发社会认知的是交互、权限、独立环境和持续在线的结合。

苏煜认为下一阶段重点是 Continual Learning、World Model 与 Specialization：让通用 Agent 从真实部署中学习具体公司、职业和工作流，成长为可靠、快速、低成本的 Expert Agent。现实风险不是短期突然产生生存意志，而是知识工作替代、收益集中和能力访问不平等。需要注意，四阶段历史、世界模型定义和持续学习统一框架是嘉宾的理论综合，并非学界唯一分类。

## 一页回顾

### 这期在回答什么

1. Agent 到底是什么，为什么不是 2022 年才出现？
2. Logical、Neural、Semantic Parsing 和 Language Agent 如何衔接？
3. CoT、ReAct 和 Computer Use 怎样扩大 Agent 的行动空间？
4. OpenClaw Moment 为什么像 ChatGPT Moment？
5. GUI、CLI、API、Coding 会收敛成 Universal Digital Agent 吗？
6. Continual Learning、World Model 和 Expert Agent 是什么关系？
7. Agent 最现实的瓶颈和社会风险是什么？

### 五个核心结论

1. **Agent 的本质是实体、环境和目标导向行动。** Web、Desktop、Mobile 和 Coding 只是环境与接口分类。
2. **Memory 是 Autonomy 的基础。** 感知、推理、决策和行动都依赖知识、经验与可更新的世界表征。
3. **语言是通用脚手架。** 它连接理解、推理、规划、工具、代码和记忆，并允许复杂任务使用更多 Token 和计算。
4. **产品时刻来自技术、交互、权限和分发的乘积。** OpenClaw 的影响不必依赖全新的底层算法。
5. **未来差异化来自专业化。** 通用能力变便宜后，具体公司、职业和工作流中的 Expert Agent 更可能创造价值。

### 核心关系

```text
Memory
  ├─ 知识表达、获取、更新和遗忘
  ├─ Semantic / Episodic / Procedural Memory
  └─ World Model
            ↓
Autonomy
  ├─ Perception
  ├─ Reasoning
  ├─ Decision Making
  └─ Action
            ↓
真实环境反馈 -> Continual Learning -> Specialization -> Expert Agent
```

苏煜进一步把几个热门概念统一为：

- Continual/Self Learning：学习过程；
- World Model：学习内容；
- Specialization/Expert Agent：学习结果；
- Reliability、Speed、Cost：专业化带来的效益。

这是嘉宾提出的研究框架，不是已确立的技术等式。

## 分章笔记

### 00:02:00–00:29:28 Agent 的定义与技术史

- 苏煜自述在美国完成博士训练，进入俄亥俄州立大学并建立 NLP 研究组，研究 Semantic Parsing、Language Agent 和 Computer Use，后来创办 NeoCognition。
- 他把 Agent 定义为有边界的实体，处于外部环境中，并执行目标导向活动。按这个宽定义，人和动物也属于 Agent。
- Memory 不只是保存文本，还包括知识表达、获取、更新、遗忘，以及语义、情景和程序性记忆。
- Autonomy 包含感知、推理、决策与行动；Memory 为这些能力提供基础。
- Logical Agent 依赖逻辑语言、知识库和推理引擎。专家系统的瓶颈是知识获取：工程师必须访谈专家，再把隐性知识手工编码成规则。
- Neural Agent 用数据和神经网络学习从感知到动作的映射。Atari、AlphaGo 等显示局部环境中的强能力，但输入、动作和环境边界仍窄，样本效率也有限。
- Semantic Parsing 把自然语言转换成数据库、知识图谱或网站可执行的形式表示，扩大了 Agent 的输入输出和行动空间。
- Language Agent 以 LLM 提供广泛语言先验，并用语言承担理解、推理、计划、工具调用、代码与行动。
- 苏煜把语言视为人类文明和 AI Agent 的“加速器”。但文明演进还受制度、工具、能源、农业和人口网络影响，不能归因于语言单一变量。
- 1950–90 年代、2000 年后和 2022 年后的阶段划分，是嘉宾用于理解历史的概念框架，不是唯一学术分期。

**回顾问题：** Agent 的边界由模型、运行时、权限、身体，还是任务定义？

### 00:29:28–00:48:56 Language Agent 的三年压缩史

- Chain-of-Thought 被描述为语言推理的重要节点：复杂任务可生成更多中间 Token，相当于获得更弹性的计算量。
- ReAct 将 Reasoning 与 Action 连接成环境循环：观察、推理、选择动作、改变环境，再观察新状态。
- LLM-Planner 和 SayCan 等工作把语言模型用于机器人规划；Toolformer 等工作探索模型自主使用工具。
- Mind2Web 将 LLM 带入开放 Web 环境；WebArena 用网站副本构造可复现测试环境，降低真实网站变化和合规问题。
- GPT-4o 等多模态模型推动 Agent 从 HTML/Text Representation 转向“像人一样看屏幕”。
- OSWorld 把 Web Agent 扩展到桌面操作；UGround 等工作强调 Visual Perception 与 Pixel-Level Action。
- Coding Agent 借助 CLI、代码和 API 直接作用于数字世界。Coding 被视为数字环境中可组合、可验证、可扩展的行动语言。
- Web、Desktop、Mobile、GUI、CLI、API 和 Coding 的分类是阶段性工具分类；最终需求是 Universal Digital Agent。
- Mind2Web、MMMU、AgentBench 等“第一个”“最标准”表述需要用原始论文和同期综述核验。

**回顾问题：** Coding Agent 的成功来自模型更强，还是代码环境更容易验证、回滚和提供反馈？

### 00:48:56–01:02:05 OpenClaw Moment 与社会辐射

- 节目将 OpenClaw Moment 与 ChatGPT Moment 类比：两者都建立在多年技术积累上，产品交互才让大众突然看见能力。
- OpenClaw 被描述为开源、持续在线、拥有独立运行环境，并可通过即时通讯入口交互。用户开放更大权限后，Agent 才能展示更完整的行动能力。
- 一个“Moment”可理解为：`技术成熟度 × 交互形态 × 权限范围 × 分发渠道`。
- 中国与美国的技术辐射路径不同。苏煜观察到，美国影响更集中在开发者和技术圈，中国则更易全民化、产业化和政策化，应用动作也更快。
- 这种中美差异是嘉宾观察，没有节目内统计证据；也不能简单推导为哪一方技术更领先。
- 广权限和 Always-On 同时提高能力与风险：权限管理、Prompt Injection、数据泄露和错误操作必须单独评估。

**回顾问题：** 产品开放的权限越大，怎样证明新增能力大于新增安全风险？

### 01:02:05–01:20:30 NeoCognition、创业与专业化智能

- 苏煜介绍 NeoCognition 为 Agent Research Lab，关注 Specialized Intelligence、Continual Learning 和 Expert Agent。
- 他认为模型公司适合构建覆盖整个数字世界的通用入口，但具体职业、企业、软件和行业需要长期专业化。
- Expert Agent 必须学习“小世界”中的工作流、隐性规则、组织关系和失败模式，而不只是调用通用模型。
- 软件产业可能从出售工具转向交付结果：工具由 Agent 使用，平台逐步变成 AI Labor Market。
- 苏煜称 NeoCognition 完成约 4000 万美元 Seed Round。该融资额、轮次、完成日期和投资方需要查公司公告或监管文件。
- 他认为美国融资正在两极分化：巨额资本集中在头部模型公司，普通创业公司融资变难。精确比例是个人估计。
- 学术研究允许开放探索，创业则要求客户、部署和现实反馈。嘉宾的公司论述同时是研究主张和创业叙事。

**回顾问题：** 专业化能力应存放在模型参数、外部记忆、Skill、工作流，还是组织数据中？

### 01:20:30–01:44:34 Continual Learning、World Model 与交互边界

- 经典 Continual Learning 关注学习新任务时避免遗忘旧任务；当下用法还混入个性化、RL Post-Training、Self-Improvement 和外部 Skill。
- 苏煜追问“持续学习究竟在学什么”，答案是广义 World Model：物理环境、语言、数学、组织结构、业务规则、社会关系和制度约束。
- 他借用 Jeff Hawkins 的《A Thousand Brains》和皮层柱理论，把 Neocortex 类比为通用世界模型学习器。这是有影响力的理论，不是已证实的统一神经科学结论。
- 人类实习生通过真实工作逐渐成为专家；Agent 也需要从部署中的成功、失败和反馈形成持久能力。
- 学校擅长 Benchmark 和实验环境，却较难获得大规模长期真实 Deployment。创业为持续学习提供现实信号，也引入商业偏差和安全风险。
- GUI 不会简单被 CLI/API 淘汰。人类依赖视觉界面做理解、验证、审计与建立信任，大量长尾软件也只提供 GUI。
- Agent 通常更适合 CLI/API，但 Computer Use 可以利用现有 GUI 中积累的业务逻辑和约束，不必等待所有软件重写接口。
- 最可能的形态是 GUI、CLI、API 和 Coding 共存，由更通用的数字 Agent 选择合适接口。
- Continual Learning 不一定要求实时修改模型参数。External Memory、Retrieval、Skill、轨迹和程序合成也能提供部分学习效果。

**回顾问题：** 一个部署后不断学习的 Agent，如何防止遗忘、投毒、隐私泄露和能力回退？

### 01:44:34–01:52:47 当前瓶颈与 2026 预期

- 苏煜把 Memory、Self-Learning、Continual Learning、World Model 和 Specialization 视为同一主线的不同侧面。
- 当前 Agent 的问题包括长程任务成功率不稳定、环境理解浅、Token 成本高、速度慢，以及无法将重复经验内化成专业能力。
- 可靠性不仅是模型正确率，还受规划、工具选择、状态跟踪、外部系统不确定性、权限和错误恢复影响。
- 嘉宾预测 Continual/Self-Learning 会成为 2026 的主要前沿主题，World-Model-Based Learning 是重要下注之一，而非唯一方法。
- 他区分 Safety 与 Security：部分 Safety 问题来自能力不足，Security 更关注对抗性最坏情形。但更强能力不能自动解决恶意输入、越权和目标错配。
- “Continual Learning 会被解决”缺少明确指标和时间尺度，应理解为研究预测。

**回顾问题：** 怎样定义“持续学习已经解决”：Benchmark 提升、个性化、长期不遗忘，还是生产环境中的可靠专家化？

### 01:52:47–02:16:28 大厂下注、社会影响与快问快答

- 苏煜认为大厂 Agent 策略正在趋同，Anthropic 通过 Claude Code 和 Computer Use 形成阶段性方向感；OpenAI、Google、xAI 和中国公司各自下注生产力与 Computer Use。
- 节目提到 UI-TARS、AutoGLM、AgentBench 等中国项目，以及 xAI/Macrohard、Project Prometheus 等当前叙述。产品、组织、融资和角色需要按录制日期核验。
- 专业化 Agent 可能进入每个企业和职业，把通用模型变成懂具体环境的“老员工”。
- 苏煜更担心知识工作替代和收益集中，而不是近期 Agent 自发产生生存意志并消灭人类。
- 他的理由是当前目标主要由人赋予，Agent 缺少生物意义上的原生意图。反方认为，即使没有人类式欲望，外部目标、工具权限和优化压力也可能产生危险行为。
- 他主张民主化 Frontier Agent Capabilities，让普通人把行业洞察变成 Expert Agent，而不是让能力只集中在少数模型公司。
- 民主化还需要计算资源、平台依赖、责任、数据权利和安全治理，否则开放能力并不自动带来公平收益。
- 有效技术访谈约在 `02:16:28` 结束；其后包含编辑旁白和片尾，不纳入结论。

**回顾问题：** Agent 能力民主化如何同时避免平台垄断、滥用、数据剥夺和责任真空？

## 事实、框架与预测

| 层级 | 示例 | 推荐写法 |
| --- | --- | --- |
| 第一人称经历 | 学术路径、研究组、创业动机 | “苏煜自述/表示” |
| 标准技术历史 | CoT、ReAct、WebArena、OSWorld 等 | 查原始论文和发布日期 |
| 嘉宾分类框架 | 四阶段 Agent 历史、Memory/Autonomy | “苏煜提出/将其概括为” |
| 优先权主张 | 第一个、最早、最标准、增长最快 | 必须由同期文献或数据支持 |
| 公司与市场陈述 | OpenClaw、各大厂策略、融资 | 标明录制日期并查公告 |
| 预测 | 持续学习、就业、社会结构 | 保留时间和假设，未来复盘 |

## 十五项高风险主张

以下内容不能脱离归因直接写成事实：

1. 苏煜的完整学术职级、任职时间和研究组创建情况。
2. Mind2Web、CACT、LLM-Planner、MMMU 与其团队的具体贡献和作者关系。
3. 专家系统失败“直接导致最大 AI Winter”的单因果叙述。
4. CoT、ReAct 的精确首发时间和优先权。
5. LLM-Planner 是最早的 LLM 机器人规划系统之一。
6. Mind2Web 是第一个 LLM Web/Computer-Use Agent。
7. SayCan 是公认的第一个代表性 LLM Robot Planning 工作。
8. Toolformer 是第一个 LLM Tool-Use 工作，以及 Microsoft 内部传播故事。
9. AutoGPT 是 GitHub 历史增长最快项目之一并达到约 18 万 Stars。
10. MMMU 是第一个或最标准的多模态 LLM Benchmark。
11. OpenClaw 的出现时间、增长速度、权限模型和对大厂路线的影响。
12. NeoCognition 已完成约 4000 万美元 Seed Round。
13. OpenAI 和 Anthropic 占 AI 融资总额约 30%–50%。
14. Neocortex 占大脑约 70%、约 15 万个 Cortical Columns 等数字。
15. Continual Learning 将被解决，并在可见时间内重构多数行业。

应分别查询作者主页、论文、arXiv/会议记录、GitHub 历史、公司公告、监管文件、神经科学综述和同期市场数据。

## 争议与反方问题

1. Language Agent 是新的智能范式，还是 LLM 工具系统的新命名？
2. Language 是智能核心，还是对多模态世界模型的高效接口？
3. Continual Learning 是否必须围绕 World Model？
4. 参数更新、外部 Memory 和 Skill 哪种更适合安全部署？
5. GUI 中的隐性业务知识，能否由更标准的 API 逐步替代？
6. Agent 失败主要是能力问题，还是权限、目标和安全工程问题？
7. 专业化 Agent 会扩散机会，还是加强模型平台控制？
8. 没有原生欲望是否足以排除严重自主系统风险？

## 未来复盘清单

1. OpenClaw Moment 是否形成持续使用，而非短期传播事件？
2. Universal Digital Agent 是否真正跨 Web、Desktop、Mobile 和 Coding？
3. 部署中的 Agent 是否能长期学习且不发生灾难性遗忘？
4. World Model 能否被定义为可测量、可比较的工程对象？
5. 专业化 Agent 是否在可靠性、速度和成本上持续优于通用模型？
6. GUI、CLI 和 API 的使用比例如何演化？
7. NeoCognition 的技术路线是否产生公开可复现结果？
8. Agent 就业替代和收益集中是否出现可量化证据？

## 阅读建议

- 技术史：重点读 `00:02:00–00:48:56`。
- OpenClaw 与中美扩散：重点读 `00:48:56–01:02:05`。
- 持续学习与交互：重点读 `01:20:30–01:52:47`。
- 社会影响：重点读 `01:52:47–02:16:28`。
- 正式引用论文或“第一个”主张：使用页面顶部的 Transcript 定位回听，并查询原始文献。