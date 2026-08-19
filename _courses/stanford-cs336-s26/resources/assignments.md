---
uid: stanford-cs336-s26-resource-assignments-2
type: course
document_type: resource
resource_kind: assignments
resource_order: 2
course: stanford-cs336-s26
title: Stanford CS336 Spring 2026 作业路线图
description: 按五个官方作业串联课程模块、handout、实现环境、学习边界与完成清单。
excerpt: 按五个官方作业串联课程模块、handout、实现环境、学习边界与完成清单。
content_lang: zh-CN
permalink: "/courses/stanford-cs336-s26/assignments/"
toc: true
---

> 站点保留 428 项完整资源索引；讲义、作业 handout 与 transcript 提供站内归档，大体积论文和仓库快照通过官方来源访问。

本文档只做路线规划、资料索引与执行提醒，不提供任何作业解法、隐藏测试推断、实现答案、写作答案或第三方代码复用建议。

## 使用边界

- Stanford CS336 的 `AGENTS.md` 明确要求 AI 只充当助教式引导，不直接生成作业代码、伪代码、写作答案或完整实现。
- 本地的 repository ZIP 都是官方仓库的归档源码快照，不是带评语的参考答案，也不是应被直接拷贝进你自己仓库的实现。
- 每个作业目录中的 `AGENTS.md` 才是该作业的教学式 AI 使用规则；遇到冲突时，以该文件的约束为准。
- 课程荣誉规范在这里按最保守方式执行：不要索取或传播解法，不要推断 hidden tests，不要把 assignment requirement 直接翻译成可提交实现，不要粘贴第三方实现或“参考仓库”代码。
- 推荐的合规求助方式只有四类：概念解释、报错解读、你自己代码的审阅式反馈、以及基于可见测试和不变量的调试建议。

## 状态说明

- `本地归档`：当前课程目录里已有可点击相对链接。
- `外部官方`：链接指向 Stanford 课程官方 GitHub / Raw / Codeload 资源，当前仓库不保证离线可用。
- `讲次桥接`：优先链接到本课程已整理的模块文档或 lecture `NOTES.md`，帮助你在读 handout 前先把课堂背景补齐。

## Assignment 1: Basics

- 发布：Lecture 01 `Mon March 30`
- 截止：Lecture 06 `Wed April 15`
- 目标：建立从零实现语言模型基础组件的工作流，包括 tokenizer、基础训练/测试接口、以及后续作业共用的实现心智模型。
- 先修：Python 基础、PyTorch 张量直觉、UTF-8/字节级文本处理、Transformer 基本结构、Lecture 01-04 的课程框架。

### 官方材料与状态

| 资源 | 本地归档 | 外部官方 | 状态说明 |
| --- | --- | --- | --- |
| Handout PDF | [cs336_assignment1_basics.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/cs336_assignment1_basics.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment1-basics/main/cs336_assignment1_basics.pdf) | 本地归档 + 外部官方 |
| README | [README.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/README.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment1-basics/main/README.md) | 本地归档 + 外部官方 |
| AGENTS | [AGENTS.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/AGENTS.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment1-basics/main/AGENTS.md) | 本地归档 + 外部官方；约束 AI 使用 |
| Repository snapshot | [repository-main.zip](https://codeload.github.com/stanford-cs336/assignment1-basics/zip/refs/heads/main) | [codeload zip](https://codeload.github.com/stanford-cs336/assignment1-basics/zip/refs/heads/main) | 归档源码快照 |
| Official repository | 无本地镜像入口 | [GitHub tree](https://github.com/stanford-cs336/assignment1-basics/tree/main) | 外部官方仓库 |

### 讲次桥接

- 总桥接模块：[模块 01：基础、分词与架构](/courses/stanford-cs336-s26/modules/01/)
- 关键讲义：
  - [Lecture 01 NOTES](/courses/stanford-cs336-s26/lectures/001/)
  - [Lecture 02 NOTES](/courses/stanford-cs336-s26/lectures/002/)
  - [Lecture 03 NOTES](/courses/stanford-cs336-s26/lectures/003/)
  - [Lecture 04 NOTES](/courses/stanford-cs336-s26/lectures/004/)
- 阅读顺序建议：先看模块总线，再回到 Lecture 01 的 tokenization 与 Lecture 02 的 tensor/FLOPs/memory，最后用 Lecture 03-04 补架构语境。

### Compute / Debug Workflow

README 给出的最小工作流是：

```sh
uv run <python_file_path>
uv run pytest
```

- 先完成 `README` 指向的环境准备，再只把你自己的实现接到 `tests/adapters.py` 所要求的接口上。
- 数据下载按 README 中的 TinyStories 与 OpenWebText sample 路径执行；不要私自替换成来路不明的数据或现成 tokenizer 实现。
- 调试优先级：toy string round-trip -> shape/assertion 检查 -> 小样本可见测试 -> 性能瓶颈定位。
- 若向 AI 求助，只能让 AI 帮你解释报错、讨论边界条件、或建议如何构造更小的调试样例，不能让 AI 写 tokenizer/模型代码。

### 完成清单

- [ ] 读完 handout、README、AGENTS 三份材料。
- [ ] 建好 `uv` 环境并能运行 `uv run pytest`。
- [ ] 按 README 下载所需数据。
- [ ] 自己实现并接通 `tests/adapters.py` 需要的接口。
- [ ] 用可见测试、断言和小样例验证正确性。
- [ ] 在不违反 AI/荣誉规范的前提下整理提交物。

## Assignment 2: Systems

- 发布：Lecture 06 `Wed April 15`
- 截止：Lecture 10 `Wed April 29`
- 目标：把 A1 的基础实现推进到系统优化阶段，覆盖高效 Transformer、kernel/Triton、分布式训练与系统级性能思维。
- 先修：A1 的实现经验、GPU memory/FLOPs 基础、Lecture 05-08 的硬件与并行背景、对 `cs336_basics` 代码结构的阅读能力。

### 官方材料与状态

| 资源 | 本地归档 | 外部官方 | 状态说明 |
| --- | --- | --- | --- |
| Handout PDF | [cs336_assignment2_systems.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/cs336_assignment2_systems.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment2-systems/main/cs336_assignment2_systems.pdf) | 本地归档 + 外部官方 |
| README | [README.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/README.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment2-systems/main/README.md) | 本地归档 + 外部官方 |
| AGENTS | [AGENTS.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/AGENTS.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment2-systems/main/AGENTS.md) | 本地归档 + 外部官方；约束 AI 使用 |
| Repository snapshot | [repository-main.zip](https://codeload.github.com/stanford-cs336/assignment2-systems/zip/refs/heads/main) | [codeload zip](https://codeload.github.com/stanford-cs336/assignment2-systems/zip/refs/heads/main) | 归档源码快照 |
| Official repository | 无本地镜像入口 | [GitHub tree](https://github.com/stanford-cs336/assignment2-systems/tree/main) | 外部官方仓库 |

### 讲次桥接

- 总桥接模块：[模块 02：硬件、Kernel、并行与推理](/courses/stanford-cs336-s26/modules/02/)
- 关键讲义：
  - [Lecture 05 NOTES](/courses/stanford-cs336-s26/lectures/005/)
  - [Lecture 06 NOTES](/courses/stanford-cs336-s26/lectures/006/)
  - [Lecture 07 NOTES](/courses/stanford-cs336-s26/lectures/007/)
  - [Lecture 08 NOTES](/courses/stanford-cs336-s26/lectures/008/)
  - [Lecture 10 NOTES](/courses/stanford-cs336-s26/lectures/010/)
- 阅读顺序建议：先用模块文档理解单卡到多卡的主线，再按 Lecture 05 -> 06 -> 07 -> 08 走，最后用 Lecture 10 补 memory-bound inference 直觉。

### Compute / Debug Workflow

README 给出的关键起点是：

```sh
uv run python
./test_and_make_submission.sh
```

- 先验证 `cs336_basics` 可导入，再决定是沿用 staff A1 实现还是替换为你自己的 A1 实现。
- 系统题不要靠“看上去更快”判断；优先用 benchmark/profile、toy shapes、通信前后张量校验和 rank-local assertions。
- Triton、CUDA、分布式错误允许求助 AI 做报错解读，但不允许索要 kernel、DDP、并行切分或优化器的直接实现。
- 只围绕公开测试、接口契约和 lecture 中明确讲过的 profiling/debugging 方法推进；不要推断隐藏测试形式。

### 完成清单

- [ ] 读完 handout、README、AGENTS 三份材料。
- [ ] 确认 `uv` 环境可导入 `cs336_basics`。
- [ ] 明确是否复用 A1 自己的实现，并保证接口兼容。
- [ ] 按 lecture 建立 benchmark/profile -> 修改 -> 复测的循环。
- [ ] 仅用可见测试和不变量排查 correctness/performance 问题。
- [ ] 使用提交脚本前检查没有引入第三方实现代码。

## Assignment 3: Scaling

- 发布：Lecture 10 `Wed April 29`
- 截止：Lecture 12 `Wed May 6`
- 目标：把 scaling laws 变成可执行实验流程，学会用受控训练实验、API/面板和可复现实验记录来做规模外推。
- 先修：loss/perplexity 概念、固定 compute 视角、A1/A2 的训练直觉、Lecture 09/11 的 scaling 方法论，以及最基本的实验记录习惯。

### 官方材料与状态

| 资源 | 本地归档 | 外部官方 | 状态说明 |
| --- | --- | --- | --- |
| Handout PDF | [cs336_assignment3_scaling.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/cs336_assignment3_scaling.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment3-scaling/main/cs336_assignment3_scaling.pdf) | 本地归档 + 外部官方 |
| README | [README.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/README.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment3-scaling/main/README.md) | 本地归档 + 外部官方 |
| AGENTS | [AGENTS.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/AGENTS.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment3-scaling/main/AGENTS.md) | 本地归档 + 外部官方；约束 AI 使用 |
| Repository snapshot | [repository-main.zip](https://codeload.github.com/stanford-cs336/assignment3-scaling/zip/refs/heads/main) | [codeload zip](https://codeload.github.com/stanford-cs336/assignment3-scaling/zip/refs/heads/main) | 归档源码快照 |
| Official repository | 无本地镜像入口 | [GitHub tree](https://github.com/stanford-cs336/assignment3-scaling/tree/main) | 外部官方仓库 |

### 讲次桥接

- 总桥接模块：[模块 03：Scaling Laws](/courses/stanford-cs336-s26/modules/03/)
- 关键讲义：
  - [Lecture 09 NOTES](/courses/stanford-cs336-s26/lectures/009/)
  - [Lecture 10 NOTES](/courses/stanford-cs336-s26/lectures/010/)
  - [Lecture 11 NOTES](/courses/stanford-cs336-s26/lectures/011/)
- 阅读顺序建议：先吃透模块 03 的 IsoFLOP、critical batch 与 transfer 逻辑，再回看 Lecture 10 的系统成本视角，避免把 scaling 实验做成“只看一条曲线”的盲试。

### Compute / Debug Workflow

README 给出的最小路径是：

```sh
uv sync
```

学生路径依赖：

```sh
export A3_API_KEY=06123456
```

- 用 README 指定的 hosted training API、docs、dashboard 和 `examples/client_example.ipynb` 理解实验提交流程。
- 先把实验表格、变量命名、随机种子和预算约束整理清楚，再跑 sweep；不要把调参痕迹混成不可复现的结果。
- 调试重点不是“答案是什么”，而是“实验设定是否受控、损失曲线是否合理、拟合假设是否被数据支持”。
- AI 可以帮你解释曲线、整理实验设计风险、指出统计/拟合陷阱，但不能替你产出 scaling recipe、writeup 结论或 API 作业答案。

### 完成清单

- [ ] 读完 handout、README、AGENTS 三份材料。
- [ ] 完成 `uv sync` 和访问 API / dashboard 的最小连通性检查。
- [ ] 先用小规模试验验证记录链路，再扩大 sweep。
- [ ] 按模块 03 的方法区分 intercept、slope、compute budget 与 transfer 假设。
- [ ] 明确哪些结论来自可见数据，哪些仍是不确定项。
- [ ] 写作或汇报时不让 AI 代写结论、不让 AI 反推“正确 scaling 配方”。

## Assignment 4: Data

- 发布：Lecture 12 `Wed May 6`
- 截止：Lecture 16 `Wed May 20`
- 目标：实现并评估数据处理管线，把 filtering、deduplication、mixing 和离线/在线训练数据准备真正落到工程流程上。
- 先修：Lecture 12-14 的评估与数据主线、A1 的训练接口理解、对离线数据处理和文件组织的基本熟悉度。

### 官方材料与状态

| 资源 | 本地归档 | 外部官方 | 状态说明 |
| --- | --- | --- | --- |
| Handout PDF | [cs336_assignment4_data.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/cs336_assignment4_data.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment4-data/main/cs336_assignment4_data.pdf) | 本地归档 + 外部官方 |
| README | [README.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/README.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment4-data/main/README.md) | 本地归档 + 外部官方 |
| AGENTS | [AGENTS.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/AGENTS.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment4-data/main/AGENTS.md) | 本地归档 + 外部官方；约束 AI 使用 |
| Repository snapshot | [repository-main.zip](https://codeload.github.com/stanford-cs336/assignment4-data/zip/refs/heads/main) | [codeload zip](https://codeload.github.com/stanford-cs336/assignment4-data/zip/refs/heads/main) | 归档源码快照 |
| Official repository | 无本地镜像入口 | [GitHub tree](https://github.com/stanford-cs336/assignment4-data/tree/main) | 外部官方仓库 |

### 讲次桥接

- 总桥接模块：[模块 04：评估与数据](/courses/stanford-cs336-s26/modules/04/)
- 关键讲义：
  - [Lecture 12 NOTES](/courses/stanford-cs336-s26/lectures/012/)
  - [Lecture 13 NOTES](/courses/stanford-cs336-s26/lectures/013/)
  - [Lecture 14 NOTES](/courses/stanford-cs336-s26/lectures/014/)
- 阅读顺序建议：先用 Lecture 12 明确你想保住的能力目标，再读 Lecture 13 的来源/许可边界，最后读 Lecture 14 的 transformation/filtering/dedup/mixing 管线。

### Compute / Debug Workflow

README 给出的关键路径包括：

```sh
uv run scripts/download_data.py --offline-only
uv run modal run scripts/train.py --train-bin /root/data/your_data.bin
./test_and_make_submission.sh
```

- 先区分 `offline-only` 与全量下载，再决定是否进入 Modal 路径。
- README 明确要求在全量非离线路径前先实现 `is_english`；这是数据入口质量门，不应跳过。
- `cs336_basics` 的训练逻辑是 staff 实现，README 明说 leaderboard 提交应原样使用；你的重点是数据管线，不是改训练器。
- 调试顺序建议：小样本管线正确性 -> 样本统计/过滤阈值 -> dedup/mixing 行为 -> 训练输入产物检查。
- AI 只能帮你梳理数据质量风险、许可/来源边界和调试检查点，不能给你过滤器实现、去重算法答案、阈值答案或 writeup 结论。

### 完成清单

- [ ] 读完 handout、README、AGENTS 三份材料。
- [ ] 明确 offline-only、Modal、non-Modal 三条路径的差异。
- [ ] 在下载全量数据前先完成 README 指定的前置实现与路径检查。
- [ ] 不修改 staff `cs336_basics` 训练逻辑。
- [ ] 用小样本和统计摘要验证 filtering/dedup/mixing 是否按预期工作。
- [ ] 提交前再次检查没有引入第三方数据处理实现。

## Assignment 5: Alignment and Reasoning RL

- 发布：Lecture 16 `Wed May 20`
- 截止：Lecture 19 `Wed June 3`
- 目标：把 post-training、RLHF、RLVR 和 reasoning reward 的核心对象连起来，重点理解并实现课程 handout 要求的对齐与 reasoning RL 训练接口。
- 先修：Lecture 15-16 的 post-training 主线、SFT/RLHF/DPO/GRPO 基本概念、PyTorch 单测工作流、对“奖励可验证但仍可能被 hack”的风险意识。

### 官方材料与状态

| 资源 | 本地归档 | 外部官方 | 状态说明 |
| --- | --- | --- | --- |
| Main handout PDF | [cs336_spring2026_assignment5_alignment.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/cs336_spring2026_assignment5_alignment.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment5-alignment/main/cs336_spring2026_assignment5_alignment.pdf) | 本地归档 + 外部官方 |
| Optional supplement PDF | [cs336_spring2026_assignment5_supplement_safety_rlhf.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/cs336_spring2026_assignment5_supplement_safety_rlhf.pdf) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment5-alignment/main/cs336_spring2026_assignment5_supplement_safety_rlhf.pdf) | 本地归档 + 外部官方；README 标为完全可选 |
| README | [README.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/README.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment5-alignment/main/README.md) | 本地归档 + 外部官方 |
| AGENTS | [AGENTS.md](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/AGENTS.md) | [raw](https://raw.githubusercontent.com/stanford-cs336/assignment5-alignment/main/AGENTS.md) | 本地归档 + 外部官方；约束 AI 使用 |
| Repository snapshot | [repository-main.zip](https://codeload.github.com/stanford-cs336/assignment5-alignment/zip/refs/heads/main) | [codeload zip](https://codeload.github.com/stanford-cs336/assignment5-alignment/zip/refs/heads/main) | 归档源码快照 |
| Official repository | 无本地镜像入口 | [GitHub tree](https://github.com/stanford-cs336/assignment5-alignment/tree/main) | 外部官方仓库 |

### 讲次桥接

- 对齐背景：
  - [Lecture 15 NOTES](/courses/stanford-cs336-s26/lectures/015/)
  - [Lecture 16 NOTES](/courses/stanford-cs336-s26/lectures/016/)
- 邻近延伸：
  - [Lecture 17 NOTES](/courses/stanford-cs336-s26/lectures/017/)
- 阅读顺序建议：先用 Lecture 15 理清 SFT/RLHF 的目标差异，再用 Lecture 16 吃透 GRPO/RLVR 的动机、偏差与案例。Lecture 17 不是本作业核心，但能提醒你“alignment”不是只剩奖励公式，系统接口也会继续扩张。

### Compute / Debug Workflow

README 给出的最小环境路径是：

```sh
uv sync --no-install-package flash-attn
uv sync
uv run pytest tests/test_grpo.py
```

- 先按 README 的顺序安装，避免 `flash-attn` 依赖把环境初始化卡住。
- 先跑 `tests/test_grpo.py`，再只围绕 handout 要求和 `tests/adapters.py` 的接口接线。
- 调试时优先验证 reward、归一化、KL、batch/shape 和数值稳定性；不要让 AI 替你写 GRPO、RLHF、reward 或 adapter 代码。
- 可验证奖励不等于可以猜 hidden tests；你应只根据公开接口、公开测试和课程讲义中的 invariants 调试。
- Optional supplement 只应按 README 视为补充阅读，不要把它当成必须完成的隐藏主线。

### 完成清单

- [ ] 读完主 handout、README、AGENTS；确认 optional supplement 是否需要单独安排阅读。
- [ ] 按 README 顺序完成依赖安装。
- [ ] 先跑 `uv run pytest tests/test_grpo.py` 建立最小反馈回路。
- [ ] 只实现 handout 明确要求的接口，不做 hidden-test 猜测式开发。
- [ ] 用 lecture 15-16 的概念框架检查 reward、KL、长度和归一化行为。
- [ ] 提交前再次确认没有使用第三方 RL/对齐作业实现代码。

## 五个作业的一页式推进顺序

1. A1 先打基础：tokenization、PyTorch、基础 LM 组件。
2. A2 再做系统：kernel、并行、性能调试、分布式训练。
3. A3 转向实验方法：用 scaling laws 组织受控试验和外推。
4. A4 把目标和数据打通：评估先行，再做 filtering/dedup/mixing 管线。
5. A5 进入 post-training：把 SFT、RLHF、RLVR 与 reasoning reward 放到同一框架里理解和实现。

## 最后的合规提醒

- 允许做的事：读 handout、读 README、读 AGENTS、读 lecture notes、自己写代码、自己做实验、自己写结论。
- 不允许做的事：让 AI 或外部仓库替你写实现、替你完成 TODO、替你写 writeup、替你推 hidden tests、替你给出“正确超参数/阈值/算法答案”。
- 最安全的提问模板是：“这是我自己的代码/曲线/错误；请帮我解释问题、指出检查方向、推荐 lecture 位置或建议 toy test。”
