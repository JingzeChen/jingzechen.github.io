# Lecture Overview Generation Input

仅可依据下面九份分段笔记信息生成整讲概览，不得补充任何外部事实、公式、时间线或课件页码。

课程：CMU 11-785 Introduction to Deep Learning (Spring 2026)

讲次：Lecture 02: Neural Nets As Universal Approximators

可用分段笔记摘要：

1. 00:01:54-00:11:51
- 从上一讲回顾切入，明确本讲主题是“神经网络能表示什么”。
- 把神经网络统一成输入到输出的函数视角。
- 回顾 perceptron 的阈值定义，并把它改写成 $z=\sum_i w_i x_i-t$ 加上阈值算子 $\theta(z)$ 的两步结构。
- 区分 linear 与 affine，为后续 activation 讨论做准备。
- 在结尾引入“把 threshold 换成更平滑函数”的思路。

2. 00:11:48-00:21:48
- 解释 sigmoid 在正负无穷两端的行为，并说明它是 threshold 的平滑版。
- 列出 threshold、sigmoid、tanh、rectification/ReLU、softplus 等 activation。
- 用 poll 澄清 linear 与 affine 的集合关系。
- 正式定义 multi-layer perceptron、depth、deep network 与 layer。

3. 00:21:46-00:31:46
- 从“网络到底计算什么函数”切入，给出本讲三条主线：布尔函数、分类器、函数逼近。
- 回顾 perceptron 可实现 AND、OR、NOT。
- 进一步构造 universal AND、universal OR、majority gate。
- 指出单个 perceptron 不能做 XOR，因此需要 MLP。
- 给出 3 单元和 2 单元两种 XOR 网络，收束到“MLP 是 universal Boolean function”。

4. 00:31:43-00:41:41
- 证明任意布尔函数都能写成 truth table 的 DNF，因此可由单隐藏层 MLP 表示。
- 通过 Karnaugh map 说明相邻 1 格可分组，从而压缩 DNF 和隐藏层大小。
- 用 checkerboard 说明最坏情况下无法化简。
- 得到一层隐藏层布尔 MLP 在 $n$ 输入最坏情况下需 $2^{n-1}$ 个 hidden neurons。
- Poll 例子确认 10 输入 checkerboard 需要 512 个隐藏神经元。

5. 00:41:38-00:51:37
- 识别 checkerboard 本质上是 XOR/parity。
- 用多变量 XOR 链式或配对式构造说明深网络可把规模从指数降到线性。
- 给出 $3(n-1)$ 个 perceptrons 与 $2\log_2 n$ 层的结论。
- 说明若层数固定不足，网络宽度会重新指数膨胀，且 XOR 误差会非常糟。
- 收束到“深度可与宽度做交换，但代价有时是指数级”的总结，并过渡到分类器。

6. 00:51:35-01:01:32
- 从单 perceptron 的超平面分类边界讲起，解释它为何能做 OR/NOT 却不能做 XOR。
- 用五边形示范如何通过多个边界单元和一个输出单元合成封闭区域。
- 说明两个不连通多边形可通过更高层 OR 组合。
- 指出若只剩一层隐藏层，简单叠加多边形边界会产生伪激活区域。
- 通过观察边数增加时的求和图形，为“多边形趋于圆”的近似思路铺路。

7. 01:01:29-01:11:27
- 完成“边数趋于无穷得到圆/圆柱体”的构造。
- 说明用很多小圆可把任意复杂 decision boundary 逼近到任意精度。
- 得出“单隐藏层 MLP 是 universal classifier，但可能需要几乎无限神经元”。
- 用 16 条线和 64 条线的交替网格再次比较浅层网络与深层 XOR 网络的规模差异。
- 总结：更深网络通常能用更少神经元表达同一分类函数。

8. 01:11:24-01:21:22
- 从 pulse 构造出发，说明一层隐藏层 MLP 能逼近任意一维实值函数。
- 再借助 cylinder 的求和构造说明高维情形也成立，因此 MLP 是 universal approximator。
- Poll 强调“可以任意精度逼近”不等于“可以精确表示”。
- 回到 checkerboard 说明：若层太窄且 activation 为 threshold，后续层无法恢复被截断的位置细节。
- 说明 sigmoid、ReLU、leaky ReLU 等 graded activations 更能向后传递信息，但若要完整表示复杂函数，仍常需要更大深度。

9. 01:21:19-01:24:27
- 补充说明 graded activation 也不是万能的，低层边界方向若覆盖不足仍会丢信息。
- 用一句总括整合本讲：MLP 是 universal Boolean functions、universal classifiers、universal function approximators。
- 强调真正的限制来自容量、宽度、深度和 activation 的共同作用。
- 给出本讲视角下的 capacity 定义：网络能表示多少个彼此断开的区域。
- 把下一讲主题引到“如何训练 MLP 去学到一个指定函数”。

整讲概览应至少覆盖：

- 本讲的总目标
- 老师的教学主线
- 布尔函数、分类边界、函数逼近三条主线之间的关系
- depth、width、activation、capacity 四者的相互制约
- 关键构造：perceptron 两步分解、DNF/Karnaugh、XOR 深层构造、polygon/circle/cylinder、pulse/cylinder 逼近
- 哪些结论是“精确表示”，哪些只是“任意精度逼近”
- 仍需回听核对的重点