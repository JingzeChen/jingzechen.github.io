# Lecture Overview

- 课程：CMU 11-785 Introduction to Deep Learning (Spring 2026)
- 本讲：Lecture 10: CNNs II
- 模式：按 section notes 汇总；仅使用已提供 transcript 与各 section prompt 中附带的课件页
- 全讲时间：00:00:07-01:21:58

## 全讲主线
老师先从视觉神经科学史讲起，解释 Hubel-Wiesel 如何发现感受野、方向选择性与 S/C 两级处理；随后指出该模型缺少位置不变性，从而引出 Fukushima 的 neocognitron。之后再说明 LeCun 如何通过加入监督、参数共享、方形感受野、stride 和 max pooling，把 neocognitron 工程化为现代 CNN。后半讲则逐层拆解卷积、池化、下采样、上采样、通道数与参数量之间的关系，最后用一个早期数字识别器例子收束。

## 分段索引
- 001 00:00:07-00:10:06：从上一讲的扫描视角切到生物视觉起源；讲 gestalt、Hubel-Wiesel 实验、感受野、方向选择性、S/C cell 雏形。
- 002 00:10:02-00:20:01：说明 S/C 层级会逐层变复杂；指出原生物模型缺少位置不变性；引出 Fukushima 的 neocognitron、S-plane/C-plane、椭圆感受野与位置不变性。
- 003 00:19:58-00:29:56：讲 neocognitron 的无监督 Hebbian 学习与聚类效果；回答如何加监督；转向 LeCun 的工程化简化与 CNN 前身。
- 004 00:29:53-00:39:51：给出 CNN 总体架构与 LeNet 背景；详细拆卷积层前向，先单通道后多通道，建立 filter/channel/map 的乘加计算直觉。
- 005 00:39:49-00:49:48：用 cuboid 视角统一多通道卷积；推导输出尺寸与 zero padding；总结卷积层，再过渡到 pooling 的需求。
- 006 00:49:45-00:59:44：解释 max/mean pooling、索引保存与 backprop；讲 downsampling、stride 合并实现、upsampling 与 fractional stride 的直觉。
- 007 00:59:40-01:09:39：收束前面所有算子；放回 RGB 图像输入；解释第一层卷积核的 3 通道结构、常见 filter 尺寸、1x1 convolution 与主要超参数。
- 008 01:09:37-01:19:36：把单层堆成整网；澄清 kernel/filter/channel 术语；从信息量角度解释为何 channels 常增加而空间常减小，并给出 $K_l \ge D^2 K_{l-1}$ 的补偿规则。
- 009 01:19:34-01:21:58：列全架构超参数；给出 LeCun 早期 digit recognizer 结构；说明 CNN 训练与普通 MLP 共享 backprop 思路，并做全讲总结。

## 统一待核对点
- 多处 ASR 把 striate 听成 stride，把 slits 听成 splits，需要回听统一修正。
- 多处把 affine / ReLU / backprop 等术语写坏，笔记里都已显式打上 [需回听 HH:MM:SS]。
- 卷积与池化带 stride 的尺寸公式在 transcript 中有括号与变量混乱，现只保留老师明确表达的结构关系，不擅自补写超出原材料的精确公式。