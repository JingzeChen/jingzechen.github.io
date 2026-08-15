# Lecture Overview

- title: Lecture 08: Training Part VI Optimizers and Regularizers Choosing a Divergence (Loss) Function Batch Normalization Dropout
- mode: section-notes-synthesized-overview

## 学习目标
- 理解散度函数不仅定义误差，还直接决定梯度下降的几何与收敛速度。
- 区分回归常用的 L2 与分类常用的 KL，并能解释为什么 softmax 分类更偏向 KL。
- 理解 batch normalization 要解决的批间分布漂移问题、前向两步变换，以及它为何让批内样本在求导时耦合。
- 能说明 batch norm 在训练与推理中的不同统计量来源，以及批内样本过于相似时的失败边界。
- 理解 regularization、weight decay、dropout、early stopping、gradient clipping 等方法分别在解决什么训练问题。

## 需要的先修知识
- 损失函数、梯度下降、反向传播、mini-batch 训练。
- softmax、sigmoid、回归与分类任务的输出形式。
- 均值、方差、标准化、Bernoulli 随机变量等基础概率统计概念。

## 老师的教学主线
- 先回顾训练网络的统一框架，再问“怎样选一个利于优化的 divergence”。
- 从 L2 与 KL 的对比出发，把讨论从输出层几何推进到 softmax 输入和最终层权重的优化几何。
- 转入 mini-batch 训练的分布假设，提出 covariate shift，并用 batch normalization 做批间对齐。
- 在 batch norm 的定义之后，专门展开它的反向传播依赖结构与失败边界。
- 再从数据欠定导致的过拟合切入，解释正则化、weight decay 和深层网络的隐式正则化。
- 最后用 bagging 视角解释 dropout，并收束到一组常见训练 heuristics。

## 核心概念与依赖关系
- 散度选择依赖任务类型：回归偏 L2，分类偏 KL；但更深层理由来自对 $z$ 和最终权重的优化形状，而不只是输出概率层面。
- batch normalization 依赖 mini-batch 统计量：先标准化到零均值单位方差，再用 $\gamma,\beta$ 学习新的位置与尺度。
- batch norm 会让批内样本通过均值与方差互相耦合，因此梯度不能再按样本独立拆解。
- regularization 通过限制权重大小抑制感知机过陡，从而防止网络拼出过尖锐的决策边界。
- weight decay 是 L2 正则写进损失后，在梯度下降更新式中的直接实现形态。
- dropout 依赖“子网络集成”的解释，本质上是用随机失活逼近对大量子网络做 bagging。

## 关键推导、例子与结论边界
- 好散度的关键不是“有最小值”这么简单，而是远离最优点时梯度要足够大、接近最优点时又不能过陡。
- 对 softmax 分类，L2 虽然对输出概率看起来更碗形，但对 $z$ 和最终层权重的优化面不如 KL 友好。
- batch norm 前向推导分两步：$u=\frac{z-\mu_B}{\sqrt{\sigma_B^2+\epsilon}}$，$\hat z=\gamma u+\beta$。
- batch norm 反向传播的关键化简点是中心化后 $\sum (z-\mu_B)=0$。
- 若一个 mini-batch 内样本几乎完全相同，batch norm 可能让传回 $z$ 的梯度变成 0，这是它的重要失败边界。
- 正则化例子说明：更深的网络在固定总参数预算下往往更平滑，体现隐式正则化。
- dropout 推理阶段不能真实枚举 $2^n$ 个子网络，只能使用神经元期望的近似实现。

## 易错点与待核对项
- 不要只凭输出概率层面的曲线“好不好看”就判断哪种散度更适合分类。
- 不要把 batch norm 当成静态数据预处理；它是插在网络内部、依赖批统计量的可学习变换。
- 不要忘记 batch norm 在训练与推理时统计量来源不同。
- 不要把 weight decay 看成和 L2 正则无关的独立黑箱技巧。
- 不要把 dropout 与 batch norm 机械叠加，老师明确提醒两者常会相互干扰。
- 若要精修公式细节，需优先回听 00:44 左右的 BN 求导口述、01:05 左右的 $\beta$ 记号说明，以及 01:19 之后若干 ASR 失真句。

## 掌握标准
- 能用自己的话解释为什么 KL 更适合 softmax 分类，而不是只背“分类用交叉熵”。
- 能写出 batch norm 的前向两步公式，并说明 $\gamma,\beta,\epsilon$ 各自的作用。
- 能说明 batch norm 为什么让批内样本不再独立，以及这对求导意味着什么。
- 能解释正则化如何通过限制权重大小抑制过拟合，并把它与 weight decay 联系起来。
- 能说明 dropout 的 bagging 解释、训练伪代码和推理缩放近似。

## 复习顺序
1. 先复习散度函数形状与 L2/KL 的选择逻辑。
2. 再复习 batch norm 的问题背景、前向公式与训练/推理差异。
3. 然后看 batch norm 的反向传播依赖关系与失败边界。
4. 再看 regularization、weight decay 与深层网络的隐式正则化。
5. 最后复习 dropout 与其他训练 heuristics，把整讲串成完整训练工作流。