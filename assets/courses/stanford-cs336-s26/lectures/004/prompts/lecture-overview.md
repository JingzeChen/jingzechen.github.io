# Lecture 04 课程总览笔记

## 学习目标
- 理解本讲的两条主线：一条是用 attention alternatives 控制长上下文成本，另一条是用 mixture of experts 在近似不增加 FLOPs 的前提下扩大参数容量。
- 能复述线性注意力的核心起点：先去掉 softmax，再利用矩阵乘法结合律把 attention 重排成线性依赖，并进一步写成递推状态形式。
- 能说明 Mamba-2、gated delta net、DSA 这几条 attention alternatives 路线分别在“表达力、推理效率、实现复杂度”上的取舍。
- 能说明主流 MoE 的结构、路由、训练和系统问题：TopK routing、shared/fine-grained experts、load balancing、expert parallel、router stability、fine-tuning 过拟合。
- 能用 DeepSeek v1/v2/v3 作为案例，理解现代大模型如何把架构设计与系统设计联合起来。

## 需要的先修知识
- 基础 transformer 结构：attention block、MLP/FFN block、residual、normalization。
- 自注意力常见记号：`Q`、`K`、`V`、softmax、上下文长度 `n`、隐藏维/键值维。
- 复杂度直觉：为什么 all-to-all attention 随序列长度增长会出现二次成本。
- RNN/LSTM 的基本概念：状态递推、遗忘/写入门、训练并行性差但推理状态固定。
- 系统侧基本概念：FLOPs、通信成本、KV cache、数据并行、模型并行。

## 老师的教学主线
- 先交代本讲范围：attention alternatives 改 attention，MoE 改 MLP。
- 再建立长上下文的成本动机，说明基础工具箱如 local/global hybrid 和 flash attention 虽重要，但可能不足以支撑超长上下文。
- 然后用“去掉 softmax + 结合律重排 + 递推 duality”构造出 linear attention 及其后继家族，再补充 DSA 作为另一条稀疏注意力路线。
- 在 attention alternatives 部分结束时，老师用问答澄清“损失到底来自哪里”，并强调 TopK 这种离散选择模式会在后面的 MoE 里再次出现。
- 进入 MoE 后，先讲工业动机和基础心智模型，再依次展开路由、共享专家、训练启发式、系统并行、稳定性和微调问题。
- 最后用 DeepSeek 系列把这些点串成一条演化线，并以 MLA、MTP 收束到“现代模型是整套系统设计”的结论。

## 核心概念与依赖关系
- `长上下文需求 -> attention 成本主导 -> 需要更激进的 attention alternatives`。
- `去掉 softmax -> linear attention 重排 -> RNN 递推 duality -> Mamba-2 / gated delta net 等门控状态模型`。
- `不走递推线 -> 用轻量 indexer 做 TopK 粗筛 -> DSA 在短子集上做 full attention`。
- `想要更多参数但不想同比增加 FLOPs -> 把单个 FFN 换成多个 experts + router -> 得到 MoE`。
- `离散 TopK 路由不可导且会 rich-get-richer -> 需要 balancing losses / bias tricks -> 才能稳定训练稀疏 MoE`。
- `MoE 不仅是建模技巧 -> 还牵涉 expert parallel、通信、稀疏矩阵乘法、router 数值稳定性、微调策略`。

## 关键推导、例子与结论边界
- 关键推导一：

```text
Attn(Q, K, V) = ρ(QK^T)V
若暂时把 ρ 视为恒等：
QK^TV = Q(K^TV)
```

- 关键推导二：线性注意力可以写成递推状态：

```text
S_t = S_{t-1} + k_t v_t^T
y_t = q_t^T S_t
```

- 关键推导三：门控后仍能维持 duality 的前提，是额外项只依赖输入而不依赖状态；这给出 Mamba-2 和 gated delta net 的课堂解释框架。
- 关键例子：Minimax M1、Nemotron-3、Qwen 3.5 / Qwen Next、DeepSeek v3.2、GLM5、Qwen MoE、DeepSeek MoE、MiniCPM。
- 结论边界：
  1. 纯线性 attention 尚未在大规模上被完全证明；现实里大多是 hybrid。
  2. DSA 并非严格线性时间，只是常数和子序列长度更可控。
  3. shared experts 有不少成功案例，但并非所有受控研究都证明它必然有效。
  4. MoE 训练依赖启发式均衡，不代表离散路由的理论难题已经彻底解决。

## 易错点与待核对项
- 易错点：把“linear attention 的并行形式与递推形式等价”误解成“full softmax attention 与 linear attention 等价”。真正有损的是去掉 softmax 的第一步。
- 易错点：把 experts 想成高层语义模块。老师明确说大多数 router 过于简单，专家分工通常只是输入模式偏好。
- 易错点：只看大 O 而忽略系统常数。flash attention、DSA indexer、expert communication 都说明常数项可能决定成败。
- 易错点：把 balancing loss 当成可有可无的装饰。OlMoE 消融说明删掉后可能直接出现 expert collapse。
- 待核对：字幕里有若干 `[INAUDIBLE]` 与术语误转写，尤其出现在问答、DSA 细节、shared expert 并行化、MoE 随机性与 MLA/KV cache 部分，详细项见各分段笔记中的 `[需回听]`。

## 掌握标准
- 能不用看讲义，口头解释为什么 attention 成本会随上下文变成瓶颈，以及 local/global hybrid、flash attention、linear attention、DSA 分别在解决什么层面的成本问题。
- 能写出线性注意力的重排式与递推式，并说明 duality 为何对训练和推理都有利。
- 能比较 Mamba-2 与 gated delta net 的门控思想，并说明为什么“只依赖输入的门”是关键条件。
- 能描述主流 MoE 的最简结构、TopK 路由流程，以及为什么需要 load balancing、per-device balancing、router stability tricks。
- 能用 DeepSeek v1/v2/v3 的演化复述“现代 MoE 是建模与系统联合设计”的主张。

## 复习顺序
1. 先复习整讲总问题：为什么要同时讨论 attention alternatives 和 MoE。
2. 再复习线性注意力的三个台阶：去 softmax、结合律重排、递推 duality。
3. 然后看混合方案：Minimax M1、Mamba-2、gated delta net、Qwen Next 的性能直觉。
4. 再补 DSA，把它和 linear attention 区分开：一个靠递推，一个靠稀疏索引。
5. 最后复习 MoE：结构心智模型 -> TopK routing -> shared/fine-grained experts -> balancing losses -> 系统与稳定性 -> DeepSeek 家族复盘。