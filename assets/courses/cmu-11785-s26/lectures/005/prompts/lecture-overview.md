# Lecture 04 Overview

本文件只根据本讲 9 份 section notes 整理，不额外引入 transcript、课件之外的信息。

## 整讲主线

- 先把训练神经网络重述为“最小化 loss 的函数优化问题”。
- 再从导数的局部线性定义出发，逐步建立偏导、gradient、level set、Hessian 等优化语言。
- 随后说明一元与多变量函数中，为什么“导数或 gradient 为零”只是候选条件，还需要二阶信息区分最小值、最大值与 saddle/inflection 情形。
- 在此基础上，把“沿负梯度更新”的直觉组织成 gradient descent 的基本迭代法，并讨论其在 convex 与 non-convex 函数上的差别。
- 然后把一般优化方法接回神经网络训练：定义网络函数 $f$、参数、层、神经元与激活函数。
- 最后补齐训练样本表示与输出层设计：回归用 identity，二分类用 sigmoid，多分类用 one-hot 目标与 softmax 概率输出，并引出“divergence 也必须可微”的要求。

## 分段索引

- 001｜00:00:37-00:10:37：把 loss 最小化重述成函数优化，并从导数的乘子定义讲起。
- 002｜00:10:34-00:20:32：把多变量 derivative 提升为 gradient 的几何意义，解释最快上升/下降方向与 Hessian 的基本角色。
- 003｜00:20:30-00:30:28：回顾一元函数极值判别，并推广到“gradient 为零 + Hessian 验证”的多变量框架。
- 004｜00:30:26-00:40:00：从 Hessian 和 saddle point 过渡到迭代最小化，推导最基本的 gradient descent 更新直觉。
- 005｜00:40:35-00:50:33：正式给出 gradient ascent/descent、收敛条件，并开始定义网络函数 $f$ 与神经元结构。
- 006｜00:50:31-01:00:30：补完常见激活函数、vector activation 与回归/二分类输出表示。
- 007｜01:00:28-01:10:27：讲 one-hot、softmax、多分类输出与 divergence 的可微性要求。
- 008｜01:10:24-01:20:24：仅有课件材料，集中整理导数、gradient、level set 和 Hessian 的概念结论。
- 009｜01:20:22-01:23:37：仅有课件材料，总结极值判别与多变量无约束最小化例题。

## 本讲必须连起来理解的关系

- loss 是参数的函数，所以训练是优化问题。
- derivative 先作为“局部线性乘子”被定义，随后才出现偏导、gradient 与 Hessian。
- gradient 给出最快上升方向，因此负梯度给出最直接的下降方向。
- “gradient 为零”只能给出候选点；是否为最小值，还要看二阶结构。
- 网络训练不仅需要网络本身可微，还需要输出表示与 divergence 设计成可微形式。

## 待核对重点

- section 008 与 009 没有 transcript，相关时间戳只能使用片段总范围。
- 多处 slide 公式抽取存在乱码，尤其是 Hessian 与例题公式；使用时应以保留下来的可辨认文字和关系为准。
- section 007 末尾关于 divergence 可微性的最后几个词被截断，但主旨明确：loss 的差异函数也必须可微。