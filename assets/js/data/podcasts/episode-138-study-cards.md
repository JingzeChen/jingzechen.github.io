# 术语表与复习卡

## 自动转写术语提示

| 规范词 | 自动转写常见变体 | 说明 | 置信度 |
| --- | --- | --- | --- |
| 罗福莉 | 罗弗利 | 嘉宾 | 高 |
| MiMo-V2 | MIMO VR、Mimo VR | 小米模型系列 | 高 |
| MiMo-V2-Flash | VR Flash | 效率型模型 | 高 |
| MiMo-V2-Pro | VR Pro | 1T 级 Agent 基座 | 高 |
| MiMo-V2-Omni | Omni、Dome | 全模态模型 | 高 |
| MiMo-V2-TTS | TTS | 语音生成模型 | 高 |
| OpenClaw | OpenCloud、Open Cloud | 开源 Agent 框架 | 高 |
| Claude Code | Cloud Code、Call Code | Anthropic Coding Agent | 高 |
| Claude Opus 4.6 | Cloud Opus 4.6 | 顶尖模型参照 | 高 |
| Claude Sonnet | Sunnet、Sunhead | Anthropic 模型 | 中高 |
| Harness | Agent Framework、驾驭工程 | 模型外运行和编排层 | 高 |
| Skills / Skill Folder | Skillful、Skills | 可复用执行规范 | 高 |
| Agents.md | Agents MD | Agent 配置/经验文件 | 高 |
| User Agent | User Agent | 模拟用户多轮交互 | 高 |
| Heartbeat | 心跳任务 | 主动触发机制 | 高 |
| SFT | SFT | 监督微调 | 高 |
| RL | RO、R | 强化学习 | 高 |
| Pre-train | Print Train、Punch | 预训练 | 高 |
| Post-train | Poster Train | 后训练 | 高 |
| RL Infra | R Infra、R 音法 | 强化学习基础设施 | 高 |
| Long Context | Contest、Context | 长上下文 | 高 |
| Hybrid Attention | Hybrid Retention | 混合注意力 | 高 |
| Sliding Window Attention | Setting Window | 滑动窗口注意力 | 高 |
| Full Attention | Full Attention | 全局注意力 | 高 |
| MTP | MTP | Multi-Token Prediction | 高 |
| MLA | MLA | Multi-head Latent Attention | 高 |
| KV Cache | KV Cache | 键值缓存 | 高 |
| Compute Bound | Compute Bound | 计算瓶颈 | 高 |
| Memory Bound | Memory Bound | 访存瓶颈 | 高 |
| TPS | TPS | 每秒生成 Token 数 | 高 |
| MoE / Expert | MOE、Expert | 混合专家模型 | 高 |
| RVQ | RVQ | Residual Vector Quantization | 高 |
| QK-Clip | QK Clip | 训练稳定措施 | 高 |
| AIME | AME | 数学评测 | 高 |
| BrowseComp | BronxComp、BrowseCap | 搜索/Agent Benchmark | 中高 |
| SWE-bench | SwebBench、Sweetbench | 软件工程 Benchmark | 高 |
| Terminal-Bench | Terminal Bench | 终端任务 Benchmark | 高 |
| MiniMax | MeMath | 国内模型公司 | 中高 |
| Anthropic | Ausopia | AI 公司 | 中高 |
| MOPD | MOPD | Multi-Teacher On-Policy Distillation | 高 |

## 仍需回听或查官方资料

- 个别 Agent 框架名称：Kilo Code、OpenCode 与 OpenClaw 在 ASR 中可能混淆。
- MiMo API 价格、TPS 和上下文长度应以对应版本官方文档及硬件条件为准。
- Omni/TTS 的参数量、Audio Tokenizer、训练数据和 RVQ 细节应查模型卡。
- OpenClaw 与 OpenAI、Anthropic 的交易或调用关系属于时效性公司信息。

## 15 张复习卡

### 1. OpenClaw 给罗福莉的认知变化是什么？

**时间：** `00:02:16`

**问：** 她为什么从排斥转为高度重视？

**答：** 实际使用后，她看到框架从有温度的交互扩展到日常工作，再进入 User Agent、数据构造和模型研究。

### 2. 好的 Agent 框架在补什么？

**时间：** `00:12:00`

**问：** Harness 的核心价值是什么？

**答：** 补行动缺陷：提供环境 Context、持久 Memory、主动任务、消息通道、工具和多模型路由。

### 3. 框架与产品有什么区别？

**时间：** `00:14:00`

**问：** 为什么 Agent 框架不是单纯 UI？

**答：** 产品是用户直接感知的层；框架还决定模型通信、Context、Workflow、路由、评估和成本优化。

### 4. 什么是模型与框架共同进化？

**时间：** `00:20:00`

**问：** 自学习为什么不只是训练模型？

**答：** 模型进步会改变 Memory、Skills 和 Agent 架构，框架使用反馈又会产生数据和训练方向，两者双向迭代。

### 5. 群体智能怎样推动框架？

**时间：** `00:24:17`

**问：** 团队为什么在群里共同使用 OpenClaw？

**答：** 一个人的想象力有限；共享任务、改动和失败能刺激更多使用方式，让框架快速迭代。

### 6. 为什么 Code 有强泛化性？

**时间：** `00:41:31`

**问：** Coding 为什么适合训练 Agent？

**答：** 软件工程任务长、上下文依赖密集，结果可运行和验证，还能形成环境反馈与错误恢复闭环。

### 7. Skills 对预训练有什么补充？

**时间：** `00:57:22`

**问：** 企业内部经验怎样进入 Agent？

**答：** 人通过真实任务和纠错，把公开互联网没有的业务规则、流程和隐性知识沉淀为可执行 Skills。

### 8. Multi-Agent 当前最确定的价值是什么？

**时间：** `01:08:00`

**问：** 多 Agent 已经提高能力上限了吗？

**答：** 罗福莉认为当前更确定的是并行、速度和成本收益，尚未看到稳定提高最终能力上限。

### 9. MiMo-V2 三个模型怎样分工？

**时间：** `01:19:39`

**问：** Pro、Omni、TTS 分别承担什么？

**答：** Pro 负责理解与复杂任务，Omni 负责多模态感知，TTS 负责语音表达，由 Agent 框架编排。

### 10. Hybrid Attention 与 MTP 如何配合？

**时间：** `01:26:25`

**问：** 它们共同解决什么问题？

**答：** Sliding Window 减少 KV Cache 和算力，MTP 利用剩余计算并行提出多个 Token，以兼顾长上下文成本和速度。

### 11. 为什么 Agent 范式更吃 Post-train？

**时间：** `01:35:00`

**问：** 它与 Chat Reasoning 有何不同？

**答：** Agent 面对多轮环境、框架和长程任务，需要持续适配；Post-train 周期和算力可能接近 Pre-train。

### 12. `3:1:1` 表示什么？

**时间：** `01:48:07`

**问：** 罗福莉如何建议分配研究、预训练和后训练算力？

**答：** 她给出的经验比例是研究、Pre-train、Post-train 约 `3:1:1`，Chat 时代则约 `3:5:1`；不是行业标准。

### 13. 为什么说 1T 是入场券？

**时间：** `01:45:24`

**问：** 这个判断的适用范围是什么？

**答：** 她指的是接近 Claude Opus 4.6 的顶尖 Agent 水平，并非所有生产任务都需要 1T 模型。

### 14. 从 Chat 到 Agent 的第二幕是什么？

**时间：** `03:03:41`

**问：** 新竞争焦点是什么？

**答：** 在复杂、多样的 Agent 框架中端到端完成高复杂任务，并围绕这些任务做 Post-train 和 RL Scaling。

### 15. 为什么环境比经验更重要？

**时间：** `03:24:42`

**问：** 罗福莉如何看人才成长？

**答：** 好基础、好奇心和热爱在高标准、多样、开放的环境中可以快速转化为能力；过往大模型经验不是唯一标准。

## 引用注意事项

- 自动转写不是嘉宾确认的逐字稿；公众号文章也经过作者编辑。
- 架构参数、TPS、API 价格和算力成本应以 MiMo 官方文档和统一评测为准。
- 竞品评价、中美代差、1T 门槛与 AGI 时间表是罗福莉的判断。
- 团队人数、学历比例、组织结构和用卡比例属于内部口径。