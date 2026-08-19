## 学习目标

- 理解为什么大模型训练的基本计算单位已经从单张 GPU 变成整个数据中心，以及并行化首先要同时解决算力和显存两类瓶颈。[课件: lecture_08.pdf p.4][课件: lecture_08.pdf p.6][课件: lecture_08.pdf p.13]
- 能按老师的顺序解释数据并行路径：naive DDP -> ZeRO stage 1/2/3(FSDP)，并说清它们各自的通信账本、内存收益和适用边界。[课件: lecture_08.pdf p.15][课件: lecture_08.pdf p.21][课件: lecture_08.pdf p.27][课件: lecture_08.pdf p.28]
- 能区分三类模型并行与激活并行：pipeline parallel、tensor parallel、sequence/context parallel，以及它们为什么分别适合不同链路与不同瓶颈。[课件: lecture_08.pdf p.31][课件: lecture_08.pdf p.35][课件: lecture_08.pdf p.43][课件: lecture_08.pdf p.48][课件: lecture_08.pdf p.54]
- 理解 expert parallel 在 MoE 时代的角色，以及为什么 attention 与 MLP 往往需要解耦后的并行配置。[课件: lecture_08.pdf p.50][课件: lecture_08.pdf p.53]
- 能把整讲收束成可操作规则：先让模型 fit，再用 DP 吃剩余 GPU；机内优先 TP/EP，跨节点优先 PP，长序列补 CP，小模型可优先 FSDP。[课件: lecture_08.pdf p.57][课件: lecture_08.pdf p.58][课件: lecture_08.pdf p.72][课件: lecture_08.pdf p.73]

## 需要的先修知识

- 上一讲已经讲过的并行化基本概念，以及 collective communication 的基本术语，如 all-reduce、all-gather、reduce-scatter。[课件: lecture_08.pdf p.7][课件: lecture_08.pdf p.8]
- 训练态参数更新的基本心智模型，至少知道 batch、梯度累积、SGD/Adam 状态分别是什么。
- transformer 的主要结构块，包括 attention、MLP、LayerNorm、残差连接以及在 MoE 中的 expert/router。
- GPU/TPU 集群存在机内快互连与机间慢互连差异，通信模式会影响并行策略选择。[课件: lecture_08.pdf p.9][课件: lecture_08.pdf p.10]

## 老师的教学主线

- 先从“为什么必须多机多卡”和“collective 通信原语”讲起，把问题框成算力瓶颈、显存瓶颈与网络拓扑三者共同决定的系统问题。[课件: lecture_08.pdf p.4][课件: lecture_08.pdf p.7][课件: lecture_08.pdf p.13]
- 再走完数据并行路线：用 naive DDP 建立基线，解释 optimizer state 为什么让显存变得糟糕，再通过 ZeRO stage 1/2/3 逐步展示怎样分片状态、梯度和参数，并靠等价分解与 overlap 把成本压低。[课件: lecture_08.pdf p.15][课件: lecture_08.pdf p.17][课件: lecture_08.pdf p.23][课件: lecture_08.pdf p.26][课件: lecture_08.pdf p.27]
- 然后转入模型并行：先讲 pipeline parallel 的 bubble 与 microbatch，再讲 tensor parallel 的宽度切分和前后向对偶，顺手把 activation memory 公式推到需要 sequence parallel 的程度。[课件: lecture_08.pdf p.34][课件: lecture_08.pdf p.38][课件: lecture_08.pdf p.40][课件: lecture_08.pdf p.46][课件: lecture_08.pdf p.48]
- 接着用 expert parallel 把 MoE 带来的高带宽 token routing 复杂性说清，并解释为什么 attention 与 MLP 在 MoE 模型里会偏好不同的并行规模，需要解耦策略。[课件: lecture_08.pdf p.50][课件: lecture_08.pdf p.53]
- 最后用总表、定量扩展曲线和真实训练案例，把所有 parallelism primitives 收束成一套业界规则与经验模式。[课件: lecture_08.pdf p.55][课件: lecture_08.pdf p.57][课件: lecture_08.pdf p.59][课件: lecture_08.pdf p.72][课件: lecture_08.pdf p.73]

## 核心概念与依赖关系

- Collective 原语等价关系是理解 ZeRO/FSDP 的前提：all-reduce 与 reduce-scatter + all-gather 的等价使若干内存收益在带宽账本上近似“免费”。[课件: lecture_08.pdf p.8]
- 数据并行依赖 batch 这个资源；当 batch 不能再有效增大时，必须借助模型并行继续扩展。[课件: lecture_08.pdf p.15][课件: lecture_08.pdf p.29]
- 模型并行分成深度切分与宽度切分：pipeline parallel 沿层深度切，tensor parallel 沿矩阵宽度切；sequence/context parallel 则是对激活与长序列再做补充切分。[课件: lecture_08.pdf p.31][课件: lecture_08.pdf p.39][课件: lecture_08.pdf p.48][课件: lecture_08.pdf p.54]
- 激活内存账本是 TP/SP 之后仍要处理的问题，经验式 $34sbh + 5as^2/h$ 连接了显存估算、重计算与长上下文策略。[课件: lecture_08.pdf p.46][课件: lecture_08.pdf p.49]
- EP 与 TP/DP/PP 的组合并非自由交换，尤其在 MoE 中 attention 与 MLP 的并行需求不一致，这直接催生了解耦后的多维并行系统。[课件: lecture_08.pdf p.52][课件: lecture_08.pdf p.53]
- 最终的配置规则建立在链路层次之上：快链路优先 TP/EP，慢链路优先 PP，装得下后再回到 DP 扩展。[课件: lecture_08.pdf p.35][课件: lecture_08.pdf p.42][课件: lecture_08.pdf p.57][课件: lecture_08.pdf p.58]

## 关键推导、例子与结论边界

- Naive DDP 的核心更新式是 $\theta_{t+1}=\theta_t-\eta\sum_{i=1}^{B}\nabla f(x_i)$；它计算缩放理想，但通信要传 $2\times \#params$，内存几乎不缩放。[课件: lecture_08.pdf p.15]
- 训练态显存经验账本里，参数之外还要保存梯度、master weights 和 Adam 一二阶矩，因此 optimizer state 往往是显存大头。[课件: lecture_08.pdf p.17]
- ZeRO stage 1/2 与 naive DDP 在带宽账本上近似等价，而 stage 3/FSDP 额外多一次 all-gather，但可通过分层释放与 communication/computation overlap 将代价压到可接受。[课件: lecture_08.pdf p.21][课件: lecture_08.pdf p.23][课件: lecture_08.pdf p.26][课件: lecture_08.pdf p.27]
- Pipeline 的 bubble 比例大致随 $(n_{stages}-1)/n_{micro}$ 下降，所以必须有足够大的 batch 才能把 PP 用好。[课件: lecture_08.pdf p.34][课件: lecture_08.pdf p.36]
- Tensor parallel 没有 pipeline bubble，但通信更频繁、更依赖高速互连；激活内存里的 $10sbh$ 残差则推动了 sequence parallel 的引入。[课件: lecture_08.pdf p.43][课件: lecture_08.pdf p.47][课件: lecture_08.pdf p.48]
- 真实案例给出的结论边界很清楚：TP 通常不超过 8；小 dense 模型可偏向 FSDP；大 dense 模型使用 TP+PP+DP；MoE 倾向把 EP 做大并让 TP 保持较小；长上下文阶段会显著提高 CP。[课件: lecture_08.pdf p.61][课件: lecture_08.pdf p.63][课件: lecture_08.pdf p.66][课件: lecture_08.pdf p.72]

## 易错点与待核对项

- 不要把 ZeRO/FSDP 和 pipeline parallel 混为一谈：前者每卡仍走完整模型，只是按需拿参数；后者是真的把层放到不同卡上。[课件: lecture_08.pdf p.25][课件: lecture_08.pdf p.32]
- 不要把“通信成本差不多”误解为“实现完全免费”；老师的“free/almost free”是带宽账本口径，不是说没有工程调度、延迟或实现复杂度。[课件: lecture_08.pdf p.21][课件: lecture_08.pdf p.27]
- 不要把 sequence parallel 与 context parallel 当成严格同义词；老师明确说 sequence parallel 常是 TP 的附加件，而 context parallel 更像长上下文独立策略。[课件: lecture_08.pdf p.48][课件: lecture_08.pdf p.54]
- 不要以为 TP 越大越好；课上反复强调超过 8 往往收益变差，且 attention 与 MLP 在 MoE 中对 TP 的需求本就不同。[课件: lecture_08.pdf p.53][课件: lecture_08.pdf p.61]
- 若要按实现级精度复原 DeepSeek 的 DPP/Hybrid EP、TPU8i/TPU8t 或 loop transformer 问答，仍需回听若干口语化片段。[需回听]

## 掌握标准

- 能从“算力瓶颈 + 显存瓶颈 + 网络拓扑”三项出发，解释为什么今天的 LLM 训练必须是多机多卡系统问题。
- 能不看材料复述 ZeRO stage 1/2/3 各切什么、通信怎么组织、为什么 stage 1/2 被老师称为近似免费。[课件: lecture_08.pdf p.19][课件: lecture_08.pdf p.23][课件: lecture_08.pdf p.27]
- 能比较 PP、TP、SP/CP、EP 的主要通信对象、适合链路和核心代价，而不是只记名字。[课件: lecture_08.pdf p.35][课件: lecture_08.pdf p.43][课件: lecture_08.pdf p.48][课件: lecture_08.pdf p.50][课件: lecture_08.pdf p.54]
- 能用老师的启发式规则为一个给定训练配置说明“先怎么切模型、再怎么用 DP 扩剩余卡”。[课件: lecture_08.pdf p.57][课件: lecture_08.pdf p.58]
- 能从 OLMo、DeepSeek、Llama 3、Gemma 2、Mixtral、Qwen 3 这些案例里抽出稳定模式，而不是把它们当孤立配置表。[课件: lecture_08.pdf p.63][课件: lecture_08.pdf p.64][课件: lecture_08.pdf p.66][课件: lecture_08.pdf p.68][课件: lecture_08.pdf p.72]

## 复习顺序

1. 先复习开场的 two bottlenecks、collectives 等价关系，以及 TPU/GPU 拓扑差异，建立全讲的问题框架。[课件: lecture_08.pdf p.4][课件: lecture_08.pdf p.8][课件: lecture_08.pdf p.10]
2. 再按 naive DDP -> ZeRO-1/2/3 的顺序复习数据并行，把“通信账本”和“内存账本”一一对上。[课件: lecture_08.pdf p.15][课件: lecture_08.pdf p.21][课件: lecture_08.pdf p.27]
3. 然后看 pipeline parallel 与 tensor parallel 的对照：一个靠 microbatch 抗 bubble，一个靠快互连抗高频 collectives。[课件: lecture_08.pdf p.34][课件: lecture_08.pdf p.43]
4. 接着复习 activation memory 公式、sequence parallel 和 context parallel，明确 dense 模型里显存问题是怎样一步步被拆开的。[课件: lecture_08.pdf p.46][课件: lecture_08.pdf p.48][课件: lecture_08.pdf p.54]
5. 最后回看 expert parallel、总表、Narayanan 曲线与真实训练案例，把它们统一成“先 fit、后 DP、TP 常不超 8、MoE 放大 EP、长上下文放大 CP”的总规则。[课件: lecture_08.pdf p.53][课件: lecture_08.pdf p.57][课件: lecture_08.pdf p.59][课件: lecture_08.pdf p.72][课件: lecture_08.pdf p.73]
