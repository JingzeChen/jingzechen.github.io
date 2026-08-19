# Lecture 02 总览笔记

## 学习目标

- 理解本讲要解决的问题：在给定 compute 与 memory 约束下，怎样快速估算训练成本并判断瓶颈。[代码: lecture_02.py p.2][代码: lecture_02.py p.3]
- 会把训练对象统一看成 tensor，并能按 dtype、元素个数、层数、batch 大小估算内存占用。[代码: lecture_02.py p.4][代码: lecture_02.py p.5][代码: lecture_02.py p.25]
- 会用 einops 的命名维度思路描述 matmul、reduce、rearrange，并把它用于后续梯度和 FLOPs 推导。[代码: lecture_02.py p.7][代码: lecture_02.py p.9][代码: lecture_02.py p.10][代码: lecture_02.py p.11]
- 会用 $6 \times \text{数据点数} \times \text{参数量}$ 近似单个 training step 的 FLOPs，并知道它何时会失真。[代码: lecture_02.py p.21]
- 会用 arithmetic intensity / roofline 语言区分 memory-bound 与 compute-bound，并把结论映射到 Transformer 训练与推理。[代码: lecture_02.py p.13][代码: lecture_02.py p.14][代码: lecture_02.py p.19]
- 知道两种常用省显存策略：gradient accumulation 与 activation checkpointing。[代码: lecture_02.py p.28][代码: lecture_02.py p.29][代码: lecture_02.py p.30]

## 需要的先修知识

- 基本线性代数：向量、矩阵、矩阵乘法、维度匹配。
- 基本 PyTorch 使用：tensor、device、`loss.backward()`、梯度张量。
- 基本反向传播直觉：知道上游梯度、参数梯度、输入梯度分别是什么。
- 对训练流程有粗略概念：forward、backward、optimizer step。
- 对 GPU 有最低限度认识：GPU 有计算峰值，也有内存带宽，二者都会限制速度。

## 老师的教学主线

- 先用两个餐巾纸问题定目标：多久能训完、显存能装多大模型。[代码: lecture_02.py p.3]
- 再从底层对象出发：训练中的一切本质上都是 tensor，先讲 dtype、memory、CPU/GPU 放置。[代码: lecture_02.py p.4][代码: lecture_02.py p.5][代码: lecture_02.py p.6]
- 接着统一 tensor 运算表达：用 einops 把维度语义说清楚，再进入 FLOPs 计数。[代码: lecture_02.py p.7][代码: lecture_02.py p.9][代码: lecture_02.py p.10][代码: lecture_02.py p.11][代码: lecture_02.py p.12]
- 然后从单个 matmul 推到 MFU、arithmetic intensity、roofline，解释为什么很多 workload 跑不到峰值。[代码: lecture_02.py p.12][代码: lecture_02.py p.13][代码: lecture_02.py p.19]
- 最后把这些方法带回训练：梯度 FLOPs、optimizer state 内存，以及两种常见省显存技巧。[代码: lecture_02.py p.21][代码: lecture_02.py p.25][代码: lecture_02.py p.28][代码: lecture_02.py p.29]

## 核心概念与依赖关系

- tensor 是统一载体：data、parameters、gradients、activations、optimizer state 都是 tensor。[代码: lecture_02.py p.4]
- dtype 决定单元素字节数与数值范围：fp32 稳但贵，fp16 省但危险，bf16 是训练常用折中，optimizer state 常保留 fp32。[代码: lecture_02.py p.5][代码: lecture_02.py p.25]
- 内存核算先于性能分析：装不下模型谈不上训练，搬运太慢也吃不满算力。
- einops 让维度语义显式化：一旦维度表达清楚，matmul、梯度、rearrange 的 FLOPs 和内存更容易核算。[代码: lecture_02.py p.9][代码: lecture_02.py p.10][代码: lecture_02.py p.11]
- MFU 依赖两层事实：
  - 逻辑层面先会数 FLOPs；
  - 系统层面再看算术强度是否足以越过硬件的 accelerator intensity。[代码: lecture_02.py p.12][代码: lecture_02.py p.19]
- training step 的 $6ND$ 依赖 backward = 2 × forward 这一层级结论；而 activation checkpointing、gradient accumulation 则是在这个训练框架上做 memory tradeoff。[代码: lecture_02.py p.21][代码: lecture_02.py p.28][代码: lecture_02.py p.29]

## 关键推导、例子与结论边界

- 关键推导 1：tensor memory = 元素数 × 单元素字节数；这是所有参数、梯度、activation、optimizer state 估算的基底。[代码: lecture_02.py p.5][代码: lecture_02.py p.25]
- 关键推导 2：线性层 forward FLOPs 约为 $2BDK$，换成参数量视角就是 $2 \times \text{数据点数} \times \text{参数量}$。[代码: lecture_02.py p.12]
- 关键推导 3：单层 backward 需要输入梯度和参数梯度两次 matmul，因此整层 backward ≈ 2 × forward；整步训练约为 $6ND$。[代码: lecture_02.py p.21]
- 关键推导 4：arithmetic intensity = FLOPs / bytes，accelerator intensity = 硬件 FLOP/s / bytes/s；前者低于后者则 memory-bound，高于后者则 compute-bound。[代码: lecture_02.py p.14][代码: lecture_02.py p.19]
- 关键例子：ReLU、GELU、dot product、matrix-vector、matmul 的强度比较，导出“matmul 常 compute-bound，许多别的操作常 memory-bound”。[代码: lecture_02.py p.14][代码: lecture_02.py p.15][代码: lecture_02.py p.16][代码: lecture_02.py p.17][代码: lecture_02.py p.18]
- 结论边界：$6ND$ 对长上下文 Transformer 会低估，因为注意力中的平方项会变重要；checkpoint “省一半”也是当前 block 划分下的直观说法，不是全局定律。[代码: lecture_02.py p.21][代码: lecture_02.py p.29]

## 易错点与待核对项

- 不要把 FLOPs 和 FLOP/s 混成一回事；一个是总量，一个是速度。
- 不要把“内存只影响能不能放下模型”理解得太窄；memory bandwidth 同时会限制吞吐。
- 不要以为“算子公式更复杂”就必然更慢；若都 memory-bound，复杂算子未必显著更慢。
- 不要把训练低比特与训练后量化低比特混成同一问题。
- 不要把 optimizer state 忽略掉；它常常不是主要算力瓶颈，但很可能是容量瓶颈。[代码: lecture_02.py p.25]
- 待核对项集中在口头自我修正和字幕缺字处：H100 例题口头修正、部分问答中的 [INAUDIBLE]、以及若干现场写错后纠正的 memory 式子。[需回听]

## 掌握标准

- 能独立解释为什么老师要先讲 tensor dtype、再讲 einops、再讲 FLOPs/MFU、最后讲训练与省显存。
- 能给出一个 tensor、一个线性层、一个简化 deep network 的内存与 FLOPs 量级估算。
- 能说明为什么 backward 比 forward 更贵，以及 $6ND$ 从哪里来。
- 能不看原文说出 ReLU、dot product、matmul 在 memory-bound / compute-bound 上的典型位置。
- 能判断什么时候优先考虑 gradient accumulation，什么时候优先考虑 activation checkpointing。

## 复习顺序

- 先复习两道开场问题，确认本讲到底在服务什么决策。
- 再复习 dtype 与内存公式，尤其是参数、梯度、optimizer state、activation 四类对象的字节构成。
- 再复习 einops 的三类操作：einsum、reduce、rearrange。
- 接着复习线性层 FLOPs、MFU、arithmetic intensity、roofline 的推理链条。
- 最后复习训练步的 $6ND$ 公式，以及 gradient accumulation / activation checkpointing 的使用动机与代价。