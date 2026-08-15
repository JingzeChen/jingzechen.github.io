# Lecture Overview

- 课程：CMU 11-785 Introduction to Deep Learning (Spring 2026)
- 讲次：Lecture 06: Training Part IV Convergence issues Loss Surfaces Momentum
- 整理模式：以 9 份 section notes 为基础，按老师课堂顺序汇总；只使用本讲 prompts 中给出的 transcript 与 slide 页码。

## 全讲主线
本讲先回顾“反向传播负责算导数，梯度下降负责更新参数”的训练框架，然后追问两个更难的问题：第一，哪怕 loss 最小化做成了，是否就真的得到了想要的分类器；第二，就算目标设定无误，梯度下降本身是否会收敛、为什么有时很慢、又该如何改进。老师沿着这条线依次引入 proxy loss 与 classification error 的错位、loss surface 上的 saddle point / local minima、凸优化视角下的步长分析、decaying learning rate、Rprop、momentum 和 Nesterov 加速。

## 分段脉络
### 001 00:00:06-00:10:05
回顾整体训练算法：总 loss、梯度下降、forward / backward、参数导数的来源，以及 Poll 0 对权重导数公式的检查。

### 002 00:10:02-00:20:02
提出“backprop 是否总做对事”的第一问，说明 divergence 只是 classification error 的 proxy，并用 spoiler 例子说明最小化 proxy 不保证最小化分类错误。

### 003 00:19:59-00:29:57
从 bias-variance 角度为 backprop 的“偏但稳”辩护，再转向 loss surface：大网络里 saddle point 可能比坏 local minima 更常见，由此进入凸优化分析。

### 004 00:29:54-00:39:52
在一维二次函数上推导最优固定步长：通过 Taylor 展开和一阶最优条件，得到最优步长是二阶导的逆。

### 005 00:39:50-00:49:47
给出一维步长过小、适中、过大的收敛/振荡/发散分界，并推广到二维椭圆等高线，说明不同方向的最优步长一般不同。

### 006 00:49:45-00:59:45
把方向间步长冲突推广到一般高维函数，说明为什么统一学习率会导致慢收敛；进一步提出 decaying learning rate，强调“先大后小”有助于逃离坏盆地。

### 007 00:59:44-01:09:42
引入 Rprop：只用导数符号来调节各维步长，同号放大、改号回退并缩小，展示一种不显式算 Hessian 的 per-dimension heuristic。

### 008 01:09:39-01:19:20
从导数符号序列的稳定/振荡模式出发，建立 running average，得到 momentum；再通过交换“历史步”和“当前梯度步”的顺序，引出更快的 Nesterov 方法。

### 009 01:19:43-01:21:57
用 constant slope 反例说明 momentum 并非处处占优，然后做全讲总结，并预告后续两讲将继续讨论 incremental updates、trend algorithms 与 generalization。

## 关键推导索引
- section 004：\(E(w)=\frac{1}{2}aw^2+bw+c\) 的 Taylor 展开与 \(\eta_{\mathrm{opt}}=[E''(w_k)]^{-1}\)。
- section 005：一维下 \(2\eta_{\mathrm{opt}}\) 是振荡与发散边界；多维下不同方向最优步长不同。
- section 008：运行平均递推 \(\bar x_{k+1}=\frac{k}{k+1}\bar x_k+\frac{1}{k+1}x_{k+1}\)，并将其迁移为 momentum 的历史步平均思想。

## 全讲结论压缩
- 可微 loss 只是任务目标的代理，找到 loss 的最小值并不等于找到分类误差最小的解。
- 深网 loss surface 不仅可能有 local minima，更常见的问题可能是 saddle points。
- 统一学习率在多维情形下天然受最敏感方向制约，这会造成慢收敛、振荡或发散。
- 实践上的改进思路主要有三类：学习率衰减、自适应 per-dimension 步长、历史趋势法。
- Rprop 用导数符号调步长；momentum 用历史步平均抑制振荡；Nesterov 在此基础上进一步加速。

## 待核对集中项
- 一些公式口述在 ASR 中把 prime / double prime 混淆，尤其 section 004。
- 若后续需要严格统一人名与算法拼写，应把 Quickprop 的发明者、Nesterov 的拼写再与原音核对一次。