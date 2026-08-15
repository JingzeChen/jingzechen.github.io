# Lecture Overview Generation Input

仅可依据下面九份分段笔记信息生成整讲概览，不得补充任何外部事实、额外公式、课外历史背景或未在分段笔记中出现的结论。

课程：CMU 11-785 Introduction to Deep Learning (Spring 2026)

讲次：Lecture 03: Training Part I The Problem of Learning Empirical Risk Minimization

可用分段笔记摘要：

1. 00:00:04-00:10:03
- 交代本讲进入“训练神经网络”主题，列出 learning problem、perceptron rule、ERM、梯度下降等路线。
- 回顾神经网络是 universal function approximators，并把语音转写、图像描述、下棋、LLM 回复统一看成函数。
- 提出两类问题：输入输出如何数值表示，以及如何构造执行目标函数的网络；本讲先处理后者。
- 定义 perceptron、z、activation、weights、bias，以及把 bias 改写成恒为 1 的额外输入。
- 说明前馈网络、架构已知且容量足够的假设，并把整网写成参数化函数 f(x; W)。
- 结尾转入手工构造 diamond boundary 的示例。

2. 00:10:01-00:19:59
- 用四个边界感知机加顶部 AND 感知机构造 diamond boundary，说明手工搭网只适用于最简单问题。
- 引入自动估计参数：给定目标函数 g(x)，找参数 W 让网络函数尽量接近它。
- 用 shaded area 表示整体误差，并定义 divergence function 量化逐点 gap。
- divergence 要求：匹配时为 0，不匹配时为正。
- 指出完整积分要求处处知道 g(x)，现实中做不到；实际只有 input-output samples。
- 定义 training samples、empirical error，并强调它只是整体误差的 proxy，压低经验误差只是希望能推广到未见点。

3. 00:19:57-00:29:56
- 总结“学习函数”在实践中只是拟合训练点，并通过 Poll 1 强调容量、参数化和“任意架构都行”这一误解的错误。
- 把问题收缩到 binary classification，定义最自然的经验分类误差是错分数或错分比例。
- 引入原始 Rosenblatt threshold perceptron，先只分析单个感知机。
- 说明单个 perceptron 实现的是跨超平面的 step function，边界由加权和加偏置为 0 决定。
- 再次把 bias 吸收进额外输入，说明 learning the perceptron 就是 learning the hyperplane。
- 先假设 linearly separable，结尾把求和式改写成 W^T X 并留到下一段做几何解释。

4. 00:29:54-00:39:53
- 解释 W^T X=0 的几何意义：W 与在超平面上的 X 垂直，且 W^T X = ||W|| ||X|| cos(theta)。
- 说明正类应满足 W^T X>0，负类应满足 W^T X<0。
- 给出 perceptron problem：找向量 W 使超平面完美分离两类。
- 引入 online perceptron algorithm：初始化 W，只在错分样本处更新。
- 给出 ideal weight 直觉：正样本对应 +x，负样本对应 -x。
- 推出更新式：错分正样本时 W = W + x，错分负样本时 W = W - x，并用一个二维例子演示边界如何逐步修正到零错误。

5. 00:39:52-00:49:51
- 说明线性可分时 perceptron algorithm 保证有限步收敛；当前讨论不涉及 overfitting。
- 说明非线性可分时算法不会收敛。
- 转入 double pentagon 多层网络例子，指出网络架构本身可以表达该边界。
- 即使假设除一个黄色神经元外其余都已正确，该单个中间边界也不能直接从原始标签学习，因为对它来说标签不线性可分。
- 因而必须为中间神经元重新标注一部分样本。
- 对单个边界而言，n 个样本就有 2^n 种 relabeling 可能，复杂度已经不可接受。

6. 00:49:49-00:59:48
- 把 relabeling 难题推广到整个 MLP：不仅要学权重，还要为每个神经元、每个训练实例确定正确中间输出。
- 得出结论：threshold perceptron MLP 的训练是组合优化问题，至少指数级，perceptron rule 不能直接训练 MLP。
- 提到 ADALINE/MADALINE 是 slides 中的贪心替代方案，但课上不展开。
- 回顾至此的结论后，转向根因：threshold activation 几乎处处导数为 0、边界处不可导。
- 用一维阈值平移和高维直线旋转说明，只看错分数时，参数微调往往给不出“该往哪边调”的方向信息。
- 由此提出解决方向：必须同时更换 activation function 和 mismatch measure。

7. 00:59:45-01:09:43
- 对比 threshold activation 与平滑 activation：分类错误数可能同样不变，但平滑输出到目标值的距离会变化。
- 用 dotted lines 的总长度说明连续输出提供了局部方向信息。
- 经 Poll 3 后提炼出两个 learnability requirements：activation 可微、divergence 也可微。
- 引入连续激活函数 ReLU、softplus、sigmoid，并说明 ReLU 拐点可用 subderivatives 处理。
- 给出 sigmoid 公式 1 / (1 + e^{-z})，并解释为 P(Y=1|X)。
- 用链式直觉说明：若 sigma 对 z 可微，z 对 W 可微，就能知道 W 的小变化如何影响输出 y。

8. 01:09:41-01:19:38
- 把单个可微感知机推广到全网：利用 chain rule，可计算任意参数小扰动对最终输出的影响。
- 重新陈述 divergence 的要求，并新增“对网络输出可微”。
- 组合得到：参数变化 -> 输出变化 -> divergence 变化，因此可以据此调整参数。
- 回到理想目标：最小化整块 shaded area，也就是对输入空间上 divergence 的积分。
- 再用 P(X) 加权修正目标，强调更常见的输入应拥有更大权重，不该浪费精力拟合根本不会出现的输入区间。
- 说明现实里既不知道完整 g(X) 也不知道 P(X)，所以只能在 training samples 上计算 average divergence，把它作为期望风险的经验近似。

9. 01:19:35-01:23:05
- 说明如果反复从数据分布抽样，训练样本上的 average divergence 在期望上对应真实加权风险。
- 正式定义 empirical risk minimization：给定训练样本，计算网络输出和目标输出之间的平均 divergence，并学习 W 去最小化它。
- 说明这项训练集平均 divergence 在课程中就叫 loss。
- 强调 loss 不是 weighted shaded area 本身，而是对 expected divergence 的 estimate。
- 指出训练集固定后，loss 只剩 W 这一个变量，因此训练问题就是最小化关于 W 的函数。
- 结尾把整讲收束为 function minimization / optimization 问题，并在 01:23:01 左右结束课程。

整讲概览应至少覆盖：

- 本讲的总目标
- 老师的教学主线
- 从“可表示”到“可学习”的转折
- perceptron rule 在线性可分与多层网络中的适用边界
- 为什么 threshold activation 会让训练失去方向信息
- 两个 learnability requirements
- divergence、expected risk、empirical risk、loss 之间的关系
- 最终如何把训练问题写成关于 W 的优化问题
- 仍需回听核对的重点