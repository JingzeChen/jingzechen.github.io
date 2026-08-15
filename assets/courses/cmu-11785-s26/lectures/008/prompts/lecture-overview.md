# Lecture 07 Overview

模式：transcript + slides

## 总览

- 00:01:31-00:11:30：回顾训练神经网络的总主线，指出 full batch 更新虽然直接优化总 loss，但每次更新都要扫完整个训练集，计算代价高。
- 00:11:27-00:21:24：引入 incremental update 与 SGD，说明样本顺序必须随机化；在数据高度相似时，SGD 能以同等算力做更多次有效修正。
- 00:21:21-00:31:19：用过原点线性回归说明“总追最新样本会不收敛”，因此学习率必须随迭代递减。
- 00:31:19-00:41:19：给出 SGD 收敛的两个正式条件，说明 $\eta_k \propto 1/k$ 的地位，并用 K-means 图说明 SGD 更快但更抖、更容易落到较差解。
- 00:41:17-00:51:17：回到 expected divergence 与 empirical risk，证明经验风险与单样本损失都无偏，但样本越少方差越大，从而解释 SGD 的高方差。
- 00:51:13-01:01:13：引入 mini-batch，说明它在无偏性上继承 batch/SGD，在方差上按 $1/B$ 缩减，因此成为实践主流。
- 01:01:10-01:11:10：回顾 momentum 与 Nesterov，解释它们为何特别适合平滑 SGD / mini-batch 带来的高方差梯度。
- 01:11:07-01:21:06：从“学习率项还没被修正”出发，引入 RMSProp，再与 momentum 结合得到 Adam，并解释早期偏置修正项的作用。
- 01:21:04-01:24:17：通过最后一题与可视化图收束全讲，给出对 vanilla SGD、momentum、RMSProp、Adam 的角色分工和整讲结论。

## 核心主线

- 从 full batch 的高代价出发，转向更频繁但更噪声的 incremental updates。
- 从“为什么 incremental 有时更快”推进到“它何时收敛、为何方差大”。
- 用 mini-batch 在效率与方差之间折中。
- 再用 momentum、Nesterov、RMSProp、Adam 处理 SGD / mini-batch 带来的梯度抖动与方向尺度不均问题。

## 关键公式与结论索引

- SGD 收敛条件：$\sum_k \eta_k = \infty$，$\sum_k \eta_k^2 < \infty$。
- 典型递减学习率：$\eta_k \propto 1/k$。
- empirical risk 与 mini-batch loss 都是 expected divergence 的无偏估计。
- 经验风险方差与样本数成反比：$\mathrm{var} \propto 1/n$。
- mini-batch loss 方差与 batch size 成反比：$\mathrm{var} \propto 1/B$。
- momentum 平滑一阶趋势，RMSProp 缩放二阶矩，Adam 结合二者。

## 需要重点回听的 ASR 疑点

- 00:04:47：“trend algorithms”原词。
- 00:18:13：“data clotting/clumping”原词。
- 01:05:33：Nesterov 人名拼写与口播。
- 01:21:32：AdamW 相关那句口播。
- 01:22:28：可视化示例来源作者姓名。