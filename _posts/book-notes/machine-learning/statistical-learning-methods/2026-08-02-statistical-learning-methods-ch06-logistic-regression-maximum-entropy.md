---
title: "《统计学习方法（第 2 版）》第 6 章：逻辑斯谛回归与最大熵模型"
date: 2026-08-01 02:06:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch06-logistic-regression-maximum-entropy
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
series_order: 7
related: [statistical-learning-methods-ch05-decision-tree, statistical-learning-methods-ch07-support-vector-machines]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「逻辑斯谛回归与最大熵模型」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

### 0. 本章解决什么问题

本章表面上讲两个模型，实际上讲的是**同一件事的两种说法**。

**逻辑斯谛回归**从"如何把线性打分变成概率"出发；
**最大熵模型**从"在满足约束的所有分布中该选哪一个"出发。

两条路走到最后，得到的是同一个模型族——**对数线性模型**：

$$
P(y\mid x)=\frac{1}{Z(x)}\exp\left(\sum_i w_i f_i(x,y)\right)。
$$

本章的完整逻辑链条：

```text
【路线一：逻辑斯谛回归】
线性打分 w·x 值域是全体实数，但概率必须在 [0,1]
    ↓ 需要一个压缩函数
逻辑斯谛分布的分布函数（sigmoid）
    ↓ 等价说法
对数几率 log[p/(1-p)] 是输入的线性函数
    ↓ 参数怎么定？
极大似然估计 → 凸优化问题

【路线二：最大熵模型】
用特征函数的期望约束刻画"已知的事实"
    ↓ 满足约束的分布仍有无穷多个
最大熵原理：选熵最大的那个（不做多余假设）
    ↓ 带约束的凸优化
拉格朗日对偶
    ↓ 惊人的结果
对偶函数极大化 ≡ 极大似然估计
    ↓
得到与逻辑斯谛回归相同形式的模型

【汇合】
两者都是对数线性模型，用同一套优化算法求解
    ↓
IIS / 梯度下降 / 拟牛顿法
```

**为什么这章重要？**

1. 它是第一个**直接建模条件概率 $P(Y\mid X)$ 的判别模型**（第 4 章朴素贝叶斯是生成模型）；
2. 它引入了**最大熵原理**这一普适的建模哲学；
3. 它展示了**拉格朗日对偶**这一强大工具（第 7 章 SVM 会再次大量使用）；
4. 它是深度学习中 softmax 分类层的直接来源；
5. 它的目标函数是**光滑凸函数**，是理解优化方法的最佳载体。

#### 与前几章的定位

| 方法 | 类型 | 建模对象 | 决策边界 | 训练 |
| --- | --- | --- | --- | --- |
| 感知机（第 2 章） | 判别 | $f(x)$ | 超平面 | 迭代纠错 |
| $k$-NN（第 3 章） | 判别 | 无 | 任意 | 无 |
| 朴素贝叶斯（第 4 章） | **生成** | $P(X,Y)$ | 超平面 | 闭式计数 |
| 决策树（第 5 章） | 判别 | 划分 | 轴对齐矩形 | 贪心递归 |
| **本章** | **判别** | **$P(Y\mid X)$** | **超平面** | **凸优化** |

与朴素贝叶斯构成第 4 章提到的**生成-判别对**：模型形式相同（都是对数线性），但一个学联合分布、一个直接学条件分布。

---

### 6.1 逻辑斯谛回归模型

#### 6.1.1 逻辑斯谛分布

**定义 6.1（逻辑斯谛分布）** 连续随机变量 $X$ 服从逻辑斯谛分布，是指它有如下分布函数和密度函数：

$$
F(x)=P(X\le x)=\frac{1}{1+e^{-(x-\mu)/\gamma}}，
$$

$$
f(x)=F'(x)=\frac{e^{-(x-\mu)/\gamma}}{\gamma\left(1+e^{-(x-\mu)/\gamma}\right)^2}，
$$

其中 $\mu$ 是**位置参数**，$\gamma>0$ 是**形状参数**。

**分布函数的形状**是一条 **S 形曲线**（sigmoid curve）：

- 关于点 $\left(\mu,\tfrac12\right)$ **中心对称**：

$$
F(-x+\mu)-\frac12=-\left(F(x+\mu)-\frac12\right)；
$$

- 在中心附近增长快，两端增长慢（趋于饱和）；
- $\gamma$ 越小，中心附近越陡峭（$\gamma\to0$ 时退化为阶跃函数）。

**为什么用这个分布？** 因为我们需要一个把 $(-\infty,+\infty)$ 单调映射到 $(0,1)$ 的函数。任何连续分布的**分布函数**都能做到这一点（这就是为什么正态分布的 CDF 也能用，那叫 **probit 回归**）。选逻辑斯谛分布的理由是：

1. 有**闭式表达式**（正态 CDF 没有）；
2. 导数形式极其简洁（见下节）；
3. 对数几率恰好是线性的（6.1.4 节），有清晰的统计解释。

#### 6.1.2 sigmoid 函数及其关键性质

取 $\mu=0,\gamma=1$，得到标准 **sigmoid 函数**：

$$
\sigma(z)=\frac{1}{1+e^{-z}}=\frac{e^z}{1+e^z}。
$$

**性质一：值域与单调性**

$$
\sigma:\mathbb R\to(0,1),\qquad\text{严格单调递增}，
$$

$$
\sigma(-\infty)=0,\quad\sigma(0)=\tfrac12,\quad\sigma(+\infty)=1。
$$

注意是**开区间** $(0,1)$——sigmoid 永远取不到 0 和 1。这个细节在 6.1.9 节会变得很关键。

**性质二：对称性**

$$
\sigma(-z)=1-\sigma(z)。
$$

**证明**：

$$
\sigma(-z)=\frac{1}{1+e^{z}}
=\frac{e^{-z}}{e^{-z}+1}
=1-\frac{1}{1+e^{-z}}=1-\sigma(z)。
$$

这个性质说明二分类中 $P(Y=0\mid x)$ 和 $P(Y=1\mid x)$ 天然互补。

**性质三：导数（最重要）**

$$
\boxed{\;\sigma'(z)=\sigma(z)\bigl(1-\sigma(z)\bigr)\;}
$$

**证明**：

$$
\begin{aligned}
\sigma'(z)
&=\frac{d}{dz}(1+e^{-z})^{-1}\\
&=-(1+e^{-z})^{-2}\cdot(-e^{-z})\\
&=\frac{e^{-z}}{(1+e^{-z})^2}\\
&=\frac{1}{1+e^{-z}}\cdot\frac{e^{-z}}{1+e^{-z}}\\
&=\sigma(z)\bigl(1-\sigma(z)\bigr)。
\end{aligned}
$$

（最后一步用了 $\dfrac{e^{-z}}{1+e^{-z}}=1-\sigma(z)$。）

**这个恒等式为什么重要？** 它让梯度计算变得极其简洁——导数可以用函数值本身表示，不需要重新计算指数。后面推导梯度时会看到，正是它导致了 $\nabla L=\sum(y_i-\pi_i)x_i$ 这个漂亮的形式。

**性质四：逆函数是 logit**

$$
\sigma^{-1}(p)=\log\frac{p}{1-p}=\operatorname{logit}(p)。
$$

**推导**：令 $p=\dfrac{1}{1+e^{-z}}$，则

$$
1+e^{-z}=\frac1p
\;\Rightarrow\;
e^{-z}=\frac{1-p}{p}
\;\Rightarrow\;
z=\log\frac{p}{1-p}。
$$

#### 6.1.3 二项逻辑斯谛回归模型

**定义 6.2** 二项逻辑斯谛回归模型是如下条件概率分布：

$$
P(Y=1\mid x)=\frac{\exp(w\cdot x+b)}{1+\exp(w\cdot x+b)}，
$$

$$
P(Y=0\mid x)=\frac{1}{1+\exp(w\cdot x+b)}，
$$

其中 $x\in\mathbb R^n$，$Y\in\{0,1\}$，$w$ 是权值向量，$b$ 是偏置。

**简化记法**：把偏置并入权重（与第 2 章相同的技巧）

$$
w\leftarrow(w^{(1)},\ldots,w^{(n)},b)^\top,
\qquad
x\leftarrow(x^{(1)},\ldots,x^{(n)},1)^\top，
$$

则

$$
P(Y=1\mid x)=\frac{\exp(w\cdot x)}{1+\exp(w\cdot x)}=\sigma(w\cdot x)，
$$

$$
P(Y=0\mid x)=\frac{1}{1+\exp(w\cdot x)}=1-\sigma(w\cdot x)。
$$

**分类规则**：比较两个概率，取大的那一类。等价于

$$
\hat y=\begin{cases}
1,&w\cdot x>0\ (\text{即 }\sigma(w\cdot x)>0.5),\\
0,&w\cdot x<0。
\end{cases}
$$

> **所以逻辑斯谛回归的决策边界是超平面 $w\cdot x=0$**，和感知机一样是线性分类器。区别在于：感知机只给出类别，逻辑斯谛回归还给出**该判断有多可靠**的概率。

#### 6.1.4 对数几率：模型的本质

**几率**（odds）：事件发生概率与不发生概率之比

$$
\text{odds}=\frac{p}{1-p}。
$$

**对数几率**（log odds / logit）：

$$
\operatorname{logit}(p)=\log\frac{p}{1-p}。
$$

**核心恒等式**。对逻辑斯谛回归：

$$
\begin{aligned}
\log\frac{P(Y=1\mid x)}{1-P(Y=1\mid x)}
&=\log\frac{\dfrac{\exp(w\cdot x)}{1+\exp(w\cdot x)}}
{\dfrac{1}{1+\exp(w\cdot x)}}\\
&=\log\exp(w\cdot x)\\
&=w\cdot x。
\end{aligned}
$$

$$
\boxed{\;\log\frac{P(Y=1\mid x)}{P(Y=0\mid x)}=w\cdot x\;}
$$

**这是逻辑斯谛回归的真正定义**：

> 输出 $Y=1$ 的**对数几率**是输入 $x$ 的**线性函数**。

**这个视角解决了什么问题？**

概率 $p$ 被限制在 $[0,1]$，无法直接用线性函数建模（线性函数值域是 $\mathbb R$）。但经过两步变换：

$$
p\in[0,1]
\xrightarrow{\ \text{几率}\ }
\frac{p}{1-p}\in[0,+\infty)
\xrightarrow{\ \log\ }
\log\frac{p}{1-p}\in(-\infty,+\infty)
$$

值域就被"拉开"到整个实数轴，可以用线性模型了。这正是广义线性模型（GLM）中**连接函数**（link function）的思想，logit 是 Bernoulli 分布的**典范连接函数**（canonical link，见习题 6.1）。

**参数的解释性**。由上式，$w^{(j)}$ 表示：

> 在其他特征不变的情况下，$x^{(j)}$ 每增加 1 个单位，对数几率增加 $w^{(j)}$，即**几率乘以 $e^{w^{(j)}}$**。

例如 $w^{(j)}=0.7$，则 $e^{0.7}\approx2$，意味着该特征每增加一个单位，事件发生的几率翻倍。这种可解释性是逻辑斯谛回归在医学、金融领域长盛不衰的重要原因。

#### 6.1.5 参数估计：极大似然

给定训练集 $T=\{(x_1,y_1),\ldots,(x_N,y_N)\}$，$y_i\in\{0,1\}$。记

$$
\pi(x)=P(Y=1\mid x)=\sigma(w\cdot x)。
$$

**似然函数**。每个样本服从 Bernoulli 分布，用一个统一的式子表示两种情况：

$$
P(y_i\mid x_i)=\pi(x_i)^{y_i}\left[1-\pi(x_i)\right]^{1-y_i}。
$$

> 这个写法很巧妙：$y_i=1$ 时第二项指数为 0 退化掉，只剩 $\pi(x_i)$；$y_i=0$ 时第一项退化，只剩 $1-\pi(x_i)$。**用指数把 if-else 变成了连乘**，从而可以统一求导。

样本独立，似然为：

$$
L=\prod_{i=1}^{N}\pi(x_i)^{y_i}\left[1-\pi(x_i)\right]^{1-y_i}。
$$

**对数似然**：

$$
L(w)=\sum_{i=1}^{N}\Bigl[y_i\log\pi(x_i)+(1-y_i)\log\bigl(1-\pi(x_i)\bigr)\Bigr]。
$$

**化简为最终形式**（这一步书中跳得较快，这里补全）：

$$
\begin{aligned}
L(w)
&=\sum_i\left[y_i\log\frac{\pi(x_i)}{1-\pi(x_i)}+\log\bigl(1-\pi(x_i)\bigr)\right]\\
&=\sum_i\Bigl[y_i(w\cdot x_i)+\log\bigl(1-\sigma(w\cdot x_i)\bigr)\Bigr]\\
&=\sum_i\left[y_i(w\cdot x_i)+\log\frac{1}{1+\exp(w\cdot x_i)}\right]\\
&=\sum_{i=1}^{N}\Bigl[y_i(w\cdot x_i)-\log\bigl(1+\exp(w\cdot x_i)\bigr)\Bigr]。
\end{aligned}
$$

第二步用了 6.1.4 节的对数几率恒等式。

$$
\boxed{\;
L(w)=\sum_{i=1}^{N}\Bigl[y_i(w\cdot x_i)-\log\bigl(1+e^{w\cdot x_i}\bigr)\Bigr]
\;}
$$

**与交叉熵的关系**。取负号并除以 $N$：

$$
-\frac1N L(w)
=-\frac1N\sum_i\Bigl[y_i\log\pi_i+(1-y_i)\log(1-\pi_i)\Bigr]，
$$

这正是**二元交叉熵损失**（binary cross-entropy）。所以

> 最大化对数似然 ≡ 最小化交叉熵损失。

这也是第 1 章"对数损失下的 ERM ≡ MLE"在本模型上的具体体现。

#### 6.1.6 梯度推导

对 $w$ 求导。先处理第二项：

$$
\frac{\partial}{\partial w}\log\bigl(1+e^{w\cdot x_i}\bigr)
=\frac{e^{w\cdot x_i}}{1+e^{w\cdot x_i}}x_i
=\sigma(w\cdot x_i)\,x_i
=\pi(x_i)\,x_i。
$$

于是：

$$
\boxed{\;
\nabla L(w)=\sum_{i=1}^{N}\bigl[y_i-\pi(x_i)\bigr]x_i
\;}
$$

**这个形式极其漂亮**：

$$
\text{梯度}=\sum_i(\underbrace{y_i-\pi_i}_{\text{预测残差}})\cdot\underbrace{x_i}_{\text{特征}}
$$

写成矩阵形式：$\nabla L=X^\top(y-\pi)$。

**含义**：某个样本预测得越离谱（残差越大），它对参数更新的贡献就越大；预测准确的样本（$\pi_i\approx y_i$）几乎不产生梯度。这是一种**自动的难例加权**。

> 对比第 2 章感知机的更新 $w\leftarrow w+\eta y_ix_i$：感知机只在犯错时更新，且更新量固定；逻辑斯谛回归对**所有**样本都更新，更新量正比于残差。这是"硬判决"与"软概率"的区别。

**梯度上升更新公式**：

$$
w\leftarrow w+\eta\sum_{i=1}^{N}\bigl[y_i-\pi(x_i)\bigr]x_i。
$$

#### 6.1.7 为什么不用平方损失？

一个自然的疑问：为什么不直接最小化

$$
J(w)=\sum_i\bigl(y_i-\sigma(w\cdot x_i)\bigr)^2？
$$

**理由一：非凸。** 平方损失套上 sigmoid 后，$J(w)$ 关于 $w$ **不是凸函数**，存在多个局部极小值，优化可能陷入次优解。而交叉熵是凸的（下节证明）。

**理由二：梯度消失。** 对平方损失求导：

$$
\frac{\partial J}{\partial w}
=-2\sum_i\bigl(y_i-\sigma_i\bigr)\underbrace{\sigma_i(1-\sigma_i)}_{\text{致命因子}}x_i。
$$

当模型**严重错误**时，比如真实 $y_i=1$ 但 $\sigma_i\approx0$：

- 残差 $(y_i-\sigma_i)\approx1$，很大；
- 但 $\sigma_i(1-\sigma_i)\approx0$，把梯度**乘没了**。

结果是：**错得越离谱，梯度越小，学习越慢**——完全违背直觉。

而交叉熵的梯度是 $(y_i-\sigma_i)x_i$，**没有 $\sigma(1-\sigma)$ 这个因子**：

$$
y_i=1,\ \sigma_i\approx0
\;\Longrightarrow\;
\text{梯度}\approx x_i\ (\text{强信号})。
$$

**为什么因子会消失？** 因为对数似然中的 $\log$ 与 sigmoid 中的 $\exp$ 恰好"抵消"了。这不是巧合——这是 Bernoulli 分布与其典范连接函数配对的必然结果（习题 6.1）。

> **结论**：损失函数不能随便选。交叉熵之于 sigmoid，是数学上"天造地设"的搭配。

#### 6.1.8 凸性证明：为什么能找到全局最优

计算 Hessian 矩阵：

$$
\begin{aligned}
H=\nabla^2L(w)
&=\frac{\partial}{\partial w^\top}\sum_i\bigl[y_i-\sigma(w\cdot x_i)\bigr]x_i\\
&=-\sum_i\sigma'(w\cdot x_i)\,x_ix_i^\top\\
&=-\sum_{i=1}^{N}\pi_i(1-\pi_i)\,x_ix_i^\top。
\end{aligned}
$$

**证明 $H$ 半负定**。对任意向量 $v\in\mathbb R^{n+1}$：

$$
\begin{aligned}
v^\top Hv
&=-\sum_i\pi_i(1-\pi_i)\,v^\top x_ix_i^\top v\\
&=-\sum_i\underbrace{\pi_i(1-\pi_i)}_{>0}\underbrace{(x_i^\top v)^2}_{\ge0}\\
&\le0。
\end{aligned}
$$

因为 $\pi_i\in(0,1)$ 所以 $\pi_i(1-\pi_i)>0$，而平方项非负。

**结论：**

$$
L(w)\ \text{是凹函数}
\quad\Longleftrightarrow\quad
-L(w)\ \text{是凸函数}。
$$

**这意味着什么？**

1. **任何局部最优就是全局最优**——不用担心初始化；
2. 梯度为零的点就是最优点；
3. 可以放心使用梯度下降、牛顿法等各种凸优化方法；
4. 若 $H$ 严格负定（数据张成满秩且非可分），最优解**唯一**。

> 这是逻辑斯谛回归相对神经网络的巨大优势：**没有局部极小值陷阱**。第 5 章决策树要面对 NP 完全问题，本章则有完美的凸性保证。

**牛顿法（IRLS）**。既然有 Hessian，可以用牛顿法：

$$
w\leftarrow w-H^{-1}\nabla L
=w+\left(\sum_i\pi_i(1-\pi_i)x_ix_i^\top\right)^{-1}\sum_i(y_i-\pi_i)x_i。
$$

这在统计学中称为 **迭代重加权最小二乘**（Iteratively Reweighted Least Squares, IRLS），因为每一步等价于解一个加权最小二乘问题，权重为 $\pi_i(1-\pi_i)$。收敛极快（通常 4–6 步），代码验证见 6.5 节。

#### 6.1.9 一个重要陷阱：完全可分时 MLE 不存在

**问题**：如果训练数据**线性可分**，逻辑斯谛回归会怎样？

假设存在 $w_0$ 使得所有样本都被正确分类，即

$$
y_i=1\Rightarrow w_0\cdot x_i>0,
\qquad
y_i=0\Rightarrow w_0\cdot x_i<0。
$$

考虑 $w=c\,w_0$，令 $c\to+\infty$：

- 对 $y_i=1$ 的样本，$\pi_i=\sigma(c\,w_0\cdot x_i)\to1$；
- 对 $y_i=0$ 的样本，$\pi_i\to0$。

于是对数似然 $L(w)\to0$（其上确界），**但永远取不到**，因为 sigmoid 的值域是开区间 $(0,1)$。

**结论**：

$$
\boxed{\;
\text{数据完全可分}\;\Longrightarrow\;\text{MLE 不存在，}\lVert w\rVert\to\infty
\;}
$$

**代码验证**（6.5 节）显示，可分数据上梯度上升 20 万次后 $\lVert w\rVert$ 仍在持续增长（$\approx26$ 且未收敛），对数似然趋近 0 但取不到。

**为什么这是问题？**

- 参数发散，数值不稳定；
- 模型输出的概率全是 0 或 1，**过度自信**；
- 泛化能力差（把训练集的偶然可分当作了真实规律）。

**解决办法：正则化。** 加上 $L_2$ 惩罚：

$$
\min_w\;-L(w)+\frac{\lambda}{2}\lVert w\rVert_2^2。
$$

惩罚项在 $\lVert w\rVert\to\infty$ 时趋于无穷，**保证最优解有限且唯一**。

> 由第 1 章的讨论，这等价于给 $w$ 加高斯先验后做 MAP 估计。$L_1$ 正则则对应拉普拉斯先验，能产生稀疏解。
>
> 这也解释了为什么 scikit-learn 的 `LogisticRegression` **默认开启 $L_2$ 正则**——不是可选优化，而是保证问题良定的必需品。

#### 6.1.10 多项逻辑斯谛回归

推广到 $K$ 类分类，$Y\in\{1,2,\ldots,K\}$：

$$
P(Y=k\mid x)=\frac{\exp(w_k\cdot x)}
{1+\sum_{k=1}^{K-1}\exp(w_k\cdot x)},
\qquad k=1,\ldots,K-1，
$$

$$
P(Y=K\mid x)=\frac{1}{1+\sum_{k=1}^{K-1}\exp(w_k\cdot x)}。
$$

**为什么只有 $K-1$ 组参数？**

因为概率之和为 1，最后一类的概率由前 $K-1$ 类确定，是**冗余**的。这里把第 $K$ 类作为**参照类**（reference class），令 $w_K=0$。

任意两类的对数几率比仍是线性的：

$$
\log\frac{P(Y=k\mid x)}{P(Y=K\mid x)}=w_k\cdot x。
$$

**对称形式（softmax）**。若不固定参照类，写成：

$$
P(Y=k\mid x)=\frac{\exp(w_k\cdot x)}{\sum_{j=1}^{K}\exp(w_j\cdot x)}，
$$

这就是深度学习中无处不在的 **softmax 函数**。

> 这个形式有**参数冗余**：所有 $w_k$ 同时加上任意向量 $c$，概率不变（分子分母同乘 $e^{c\cdot x}$ 约掉）。所以 softmax 的参数不唯一，除非加正则或固定某一类。这也解释了为什么书中要固定 $w_K=0$。

**神经网络分类层就是多项逻辑斯谛回归**：最后一层线性变换 + softmax + 交叉熵损失，与本节完全相同，只是 $x$ 换成了网络学到的特征表示。

---

### 6.2 最大熵模型

#### 6.2.1 最大熵原理

**最大熵原理**：学习概率模型时，在所有满足约束条件的概率模型中，**熵最大的模型是最好的模型**。

**哲学基础**：

> 已知的，要严格满足（约束条件）；
> 未知的，不做任何多余假设（熵最大 = 最不确定 = 最"无知"）。

这是一种"**不撒谎**"的建模态度：任何超出数据支持的假设都是主观臆断，会引入偏差。

**为什么用熵度量"无知"？** 由第 5 章：

$$
0\le H(P)\le\log|\mathcal X|，
$$

等号右边成立当且仅当 $P$ 是**均匀分布**。所以"熵最大"就是"尽可能接近均匀"，即"尽可能等可能"。

> "等可能"是一个直觉概念，难以在有约束时操作；而熵是一个**可优化的数值指标**。最大熵原理的贡献就是把哲学直觉变成了数学问题。

#### 6.2.2 例 6.1：直观理解

**问题**：随机变量 $X$ 有 5 个取值 $\{A,B,C,D,E\}$，估计各自概率。

**情形一：只知道概率和为 1**

$$
P(A)+P(B)+P(C)+P(D)+P(E)=1。
$$

满足这个约束的分布有无穷多个。在没有其他信息时，最合理的选择是均匀分布：

$$
P(A)=P(B)=P(C)=P(D)=P(E)=\frac15。
$$

**情形二：额外已知 $P(A)+P(B)=\dfrac{3}{10}$**

仍有无穷多解。最大熵原理给出：在**每个约束组内部**保持等概率

$$
P(A)=P(B)=\frac{3}{20},
$$

$$
P(C)=P(D)=P(E)=\frac{7}{30}。
$$

**验证**：$\frac{3}{20}\times2=\frac{3}{10}$ ✓，$\frac{7}{30}\times3=\frac{7}{10}$ ✓，总和为 1 ✓。

**几何解释**（图 6.2）。概率模型的全体构成一个**单纯形**（simplex）：

- 单纯形上的每个点 = 一个概率模型；
- 每个线性约束 = 单纯形上的一个超平面（图中的直线）；
- 多个约束的交集 = 可行模型集合 $\mathcal C$；
- 最大熵原理 = 在 $\mathcal C$ 中挑熵最大的那一点。

```text
   概率模型空间(单纯形)        加上约束后
        ╱▔▔╲                    ╱▔▔╲
       ╱     ╲                 ╱──┼──╲  ← 约束1
      ╱       ╲               ╱   │   ╲
     ╱_________╲             ╱────┼────╲ ← 约束2
                                  ↑
                            可行集(仍有无穷多点)
                            最大熵原理选出唯一一点
```

由于熵是**严格凹函数**，而可行集是**凸集**（线性约束的交），所以最优解**存在且唯一**——这是最大熵模型良定的数学保证。

#### 6.2.3 特征函数与约束条件

现在把最大熵原理应用到分类。目标是学习条件概率分布 $P(Y\mid X)$。

**经验分布**。由训练集可以统计出：

$$
\tilde P(X=x,Y=y)=\frac{\nu(X=x,Y=y)}{N},
\qquad
\tilde P(X=x)=\frac{\nu(X=x)}{N}，
$$

其中 $\nu(\cdot)$ 表示频数。

**特征函数**。用**特征函数** $f(x,y)$ 描述 $x$ 与 $y$ 之间的某个事实：

$$
f(x,y)=
\begin{cases}
1,&x\text{ 与 }y\text{ 满足某一事实},\\
0,&\text{否则}。
\end{cases}
$$

> 例如在词性标注中，可以定义"当前词是 'the' 且标注为限定词"这样的特征。特征函数是**人为设计**的，它编码了我们认为重要的模式。一般地，特征函数可以取任意实值，不必是二值。

**两个期望**。

特征 $f$ 关于**经验分布** $\tilde P(X,Y)$ 的期望：

$$
E_{\tilde P}(f)=\sum_{x,y}\tilde P(x,y)f(x,y)。
$$

特征 $f$ 关于**模型** $P(Y\mid X)$ 与经验分布 $\tilde P(X)$ 的期望：

$$
E_{P}(f)=\sum_{x,y}\tilde P(x)P(y\mid x)f(x,y)。
$$

> 注意第二个式子用的是 $\tilde P(x)$ 而非 $P(x)$——因为我们只建模条件分布 $P(Y\mid X)$，输入的边缘分布直接用经验分布代替。这是判别模型的典型做法：**不对 $P(X)$ 建模**。

**约束条件**。如果模型能捕捉训练数据中的信息，这两个期望应该相等：

$$
\boxed{\;E_P(f_i)=E_{\tilde P}(f_i),\qquad i=1,2,\ldots,n\;}
$$

**这个约束的含义**：模型预测出的特征平均出现频率，必须与训练数据中实际观察到的频率一致。这称为**矩匹配**（moment matching）。

$n$ 个特征函数就给出 $n$ 个约束。

#### 6.2.4 最大熵模型的定义

**定义 6.3（最大熵模型）** 满足所有约束的模型集合为

$$
\mathcal C=\left\{P\in\mathcal P\;\middle|\;E_P(f_i)=E_{\tilde P}(f_i),\ i=1,\ldots,n\right\}。
$$

定义在条件概率分布上的**条件熵**为

$$
H(P)=-\sum_{x,y}\tilde P(x)P(y\mid x)\log P(y\mid x)。
$$

则 $\mathcal C$ 中条件熵 $H(P)$ **最大**的模型称为最大熵模型。

**形式化为约束最优化问题**（按习惯改为求极小）：

$$
\min_{P\in\mathcal C}\;-H(P)=\sum_{x,y}\tilde P(x)P(y\mid x)\log P(y\mid x)
$$

$$
\text{s.t.}\quad E_P(f_i)-E_{\tilde P}(f_i)=0,\quad i=1,\ldots,n，
$$

$$
\sum_y P(y\mid x)=1\quad(\forall x)。
$$

注意第二组约束（归一化）不能忘——它保证解是合法的概率分布。

#### 6.2.5 用拉格朗日对偶求解（完整推导）

这是本章最重要的推导，也是第 7 章 SVM 的预演。

**第一步：构造拉格朗日函数**

引入乘子 $w_0,w_1,\ldots,w_n$：

$$
\begin{aligned}
L(P,w)=&-H(P)
+w_0\left(1-\sum_y P(y\mid x)\right)\\
&+\sum_{i=1}^{n}w_i\Bigl(E_{\tilde P}(f_i)-E_P(f_i)\Bigr)\\
=&\sum_{x,y}\tilde P(x)P(y\mid x)\log P(y\mid x)
+w_0\left(1-\sum_y P(y\mid x)\right)\\
&+\sum_{i=1}^{n}w_i\left(\sum_{x,y}\tilde P(x,y)f_i(x,y)
-\sum_{x,y}\tilde P(x)P(y\mid x)f_i(x,y)\right)。
\end{aligned}
$$

**第二步：原始问题与对偶问题**

原始问题：

$$
\min_{P\in\mathcal C}\max_{w}L(P,w)。
$$

对偶问题：

$$
\max_{w}\min_{P\in\mathcal C}L(P,w)。
$$

**为什么可以用对偶？** 因为：

- 目标函数 $-H(P)$ 关于 $P$ 是**凸函数**；
- 约束是**线性**的；
- 满足 Slater 条件。

由凸优化理论，**强对偶性成立**，原始问题与对偶问题的解等价。于是可以通过求解对偶问题来求解原始问题。

> **为什么要转对偶？** 原始问题是带约束的、对无穷多个 $P(y\mid x)$ 求极值，很难直接处理。转成对偶后，内层极小有**闭式解**，外层变成关于有限个参数 $w$ 的**无约束**优化——难度大幅下降。这是拉格朗日对偶的典型威力。

**第三步：求解内层极小 $\min_P L(P,w)$**

对 $P(y\mid x)$ 求偏导。逐项计算：

第一项：

$$
\frac{\partial}{\partial P(y\mid x)}\sum_{x,y}\tilde P(x)P(y\mid x)\log P(y\mid x)
=\tilde P(x)\bigl(\log P(y\mid x)+1\bigr)。
$$

（用了 $\frac{d}{dp}(p\log p)=\log p+1$。）

第二项：$-w_0$。

第三项：$-\tilde P(x)\sum_i w_i f_i(x,y)$。

合并：

$$
\frac{\partial L}{\partial P(y\mid x)}
=\tilde P(x)\left(\log P(y\mid x)+1-w_0-\sum_{i=1}^{n}w_if_i(x,y)\right)。
$$

令偏导为 0。在 $\tilde P(x)>0$ 的情况下：

$$
\log P(y\mid x)=\sum_{i=1}^{n}w_if_i(x,y)+w_0-1，
$$

$$
P(y\mid x)=\frac{\exp\left(\sum_i w_if_i(x,y)\right)}{\exp(1-w_0)}。
$$

**第四步：用归一化条件消去 $w_0$**

由 $\sum_y P(y\mid x)=1$：

$$
\sum_y\frac{\exp\left(\sum_i w_if_i(x,y)\right)}{\exp(1-w_0)}=1
\;\Longrightarrow\;
\exp(1-w_0)=\sum_y\exp\left(\sum_i w_if_i(x,y)\right)。
$$

**最大熵模型的形式**：

$$
\boxed{\;
P_w(y\mid x)=\frac{1}{Z_w(x)}\exp\left(\sum_{i=1}^{n}w_if_i(x,y)\right)
\;}
$$

$$
Z_w(x)=\sum_y\exp\left(\sum_{i=1}^{n}w_if_i(x,y)\right)。
$$

$Z_w(x)$ 称为**规范化因子**（配分函数），$w_i$ 是特征 $f_i$ 的权值。

> **注意 $w_0$ 的角色**：它是归一化约束的乘子，最终被吸收进了 $Z_w(x)$。这是拉格朗日方法中常见的现象——归一化乘子总是变成配分函数。

**第五步：求解外层极大**

记对偶函数

$$
\Psi(w)=\min_{P\in\mathcal C}L(P,w)=L(P_w,w)，
$$

则最优参数为

$$
w^*=\arg\max_w\Psi(w)。
$$

至此，最大熵模型的学习归结为**对偶函数的极大化**——一个无约束优化问题。

#### 6.2.6 例 6.2：完整求解

**问题**：求例 6.1 中的最大熵模型。

记 $y_1,\ldots,y_5$ 表示 $A,\ldots,E$。优化问题：

$$
\min\;-H(P)=\sum_{i=1}^{5}P(y_i)\log P(y_i)
$$

$$
\text{s.t.}\quad P(y_1)+P(y_2)=\frac{3}{10},
\qquad
\sum_{i=1}^{5}P(y_i)=1。
$$

**拉格朗日函数**：

$$
L(P,w)=\sum_{i=1}^{5}P(y_i)\log P(y_i)
+w_1\left(P(y_1)+P(y_2)-\frac{3}{10}\right)
+w_0\left(\sum_{i=1}^{5}P(y_i)-1\right)。
$$

**对 $P$ 求偏导**：

$$
\frac{\partial L}{\partial P(y_1)}=1+\log P(y_1)+w_1+w_0,
$$

$$
\frac{\partial L}{\partial P(y_2)}=1+\log P(y_2)+w_1+w_0,
$$

$$
\frac{\partial L}{\partial P(y_j)}=1+\log P(y_j)+w_0,\quad j=3,4,5。
$$

**令偏导为 0**：

$$
P(y_1)=P(y_2)=e^{-w_1-w_0-1},
$$

$$
P(y_3)=P(y_4)=P(y_5)=e^{-w_0-1}。
$$

> **关键观察**：受同一约束影响的变量，得到**相同的概率**。这从数学上解释了为什么"组内等概率"——不是我们主观假设的，而是最大熵原理**推导出来的**。

**代回得对偶函数**：

$$
\Psi(w)=L(P_w,w)=-2e^{-w_1-w_0-1}-3e^{-w_0-1}-\frac{3}{10}w_1-w_0。
$$

**对 $w$ 求极大**，令偏导为 0，解得：

$$
P(y_1)=P(y_2)=\frac{3}{20}=0.15,
$$

$$
P(y_3)=P(y_4)=P(y_5)=\frac{7}{30}\approx0.2333。
$$

**数值验证**（6.5 节代码）：解析解的熵为 $H=1.587837$；在约束内随机搜索 20 万次得到的最大熵为 $1.587835$，对应解 $\approx[0.1502,0.1498,0.2327,0.2334,0.2339]$，与解析解吻合。

#### 6.2.7 核心定理：对偶函数极大化 ≡ 极大似然估计

这是本章最深刻的结论。

**定理**：最大熵模型的对偶函数 $\Psi(w)$ 等于训练数据的对数似然函数 $L_{\tilde P}(P_w)$。

**证明**。

**（一）计算对数似然。** 条件概率分布的对数似然为：

$$
L_{\tilde P}(P_w)=\log\prod_{x,y}P(y\mid x)^{\tilde P(x,y)}
=\sum_{x,y}\tilde P(x,y)\log P(y\mid x)。
$$

代入最大熵模型形式 $P_w(y\mid x)=\frac{1}{Z_w(x)}\exp(\sum_i w_if_i)$：

$$
\begin{aligned}
L_{\tilde P}(P_w)
&=\sum_{x,y}\tilde P(x,y)\left[\sum_i w_if_i(x,y)-\log Z_w(x)\right]\\
&=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)
-\sum_{x,y}\tilde P(x,y)\log Z_w(x)\\
&=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)
-\sum_{x}\tilde P(x)\log Z_w(x)。
\end{aligned}
$$

最后一步用了 $\sum_y\tilde P(x,y)=\tilde P(x)$，且 $Z_w(x)$ 与 $y$ 无关。

**（二）计算对偶函数。** 把 $P_w$ 代入 $L(P,w)$：

$$
\begin{aligned}
\Psi(w)
&=\sum_{x,y}\tilde P(x)P_w(y\mid x)\log P_w(y\mid x)\\
&\quad+\sum_i w_i\left(\sum_{x,y}\tilde P(x,y)f_i-\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i\right)\\
&=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)\\
&\quad+\sum_{x,y}\tilde P(x)P_w(y\mid x)\left(\log P_w(y\mid x)-\sum_i w_if_i(x,y)\right)。
\end{aligned}
$$

注意括号内：

$$
\log P_w(y\mid x)-\sum_i w_if_i(x,y)=-\log Z_w(x)。
$$

所以：

$$
\begin{aligned}
\Psi(w)
&=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)
-\sum_{x,y}\tilde P(x)P_w(y\mid x)\log Z_w(x)\\
&=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)
-\sum_{x}\tilde P(x)\log Z_w(x)。
\end{aligned}
$$

最后一步用了 $\sum_y P_w(y\mid x)=1$。

**（三）比较**。两式完全相同：

$$
\boxed{\;\Psi(w)=L_{\tilde P}(P_w)\;}
$$

$\blacksquare$

**这个定理说明了什么？**

$$
\underbrace{\text{最大熵}}_{\text{在约束下最"无知"}}
\quad\Longleftrightarrow\quad
\underbrace{\text{极大似然}}_{\text{最好地拟合数据}}
$$

两个看似完全不同的建模哲学，得到**完全相同的解**！

- 最大熵：从"不做多余假设"出发，是一种**信息论**视角；
- 极大似然：从"最好地解释数据"出发，是一种**统计推断**视角。

**更深一层的理解**。回顾最大熵的约束：

$$
E_P(f_i)=E_{\tilde P}(f_i)。
$$

而对数似然的梯度为（见 6.4 节）：

$$
\frac{\partial L}{\partial w_i}=E_{\tilde P}(f_i)-E_P(f_i)。
$$

**令梯度为零，恰好就是最大熵的约束条件！**

$$
\nabla L=0
\quad\Longleftrightarrow\quad
E_P(f_i)=E_{\tilde P}(f_i)
$$

所以：**最大熵的"约束"就是极大似然的"最优性条件"**。这两件事本质上是同一个方程的两种读法。

> 代码验证（6.5 节）：用 IIS 求得最优解后，检查 $|E_P(f_i)-E_{\tilde P}(f_i)|$，结果为 $5.6\times10^{-17}$、$0$、$0$——约束在机器精度内精确成立。

---

### 6.3 两个模型的关系

#### 6.3.1 逻辑斯谛回归是最大熵模型的特例

这是本章的画龙点睛之笔，可惜书中只是一笔带过。这里完整说明。

**取特定的特征函数**。对二分类 $y\in\{0,1\}$，定义 $n$ 个特征：

$$
f_i(x,y)=
\begin{cases}
x^{(i)},&y=1,\\
0,&y=0,
\end{cases}
\qquad i=1,\ldots,n。
$$

即 $f_i(x,y)=x^{(i)}\cdot\mathbf 1(y=1)$。

**代入最大熵模型**：

$$
\sum_i w_if_i(x,1)=\sum_i w_ix^{(i)}=w\cdot x,
\qquad
\sum_i w_if_i(x,0)=0。
$$

规范化因子：

$$
Z_w(x)=\exp(w\cdot x)+\exp(0)=1+\exp(w\cdot x)。
$$

于是：

$$
P_w(y=1\mid x)=\frac{\exp(w\cdot x)}{1+\exp(w\cdot x)},
\qquad
P_w(y=0\mid x)=\frac{1}{1+\exp(w\cdot x)}。
$$

$$
\boxed{\;\text{这正是逻辑斯谛回归！}\;}
$$

**数值验证**。6.5 节代码在同一份数据上分别运行：

- **IIS**（最大熵路线）：$w=[-1.608880,\ 1.775544,\ 0.721108]$
- **梯度上升**（逻辑斯谛回归路线）：$w=[-1.608880,\ 1.775544,\ 0.721108]$
- 最大差异：$4.9\times10^{-15}$（机器精度）

两条完全不同的推导路线，收敛到**同一组参数**。

**这个结论的意义**：

1. 逻辑斯谛回归不是拍脑袋设计的——它是"在矩匹配约束下最大熵"的**必然结果**；
2. sigmoid 的指数形式来自拉格朗日对偶的推导，不是随意选的压缩函数；
3. 多分类的 softmax 同理，对应 $f_{i,k}(x,y)=x^{(i)}\mathbf 1(y=k)$。

#### 6.3.2 对数线性模型

两个模型都可以写成统一形式：

$$
P(y\mid x)=\frac{1}{Z_w(x)}\exp\left(\sum_i w_if_i(x,y)\right)，
$$

取对数：

$$
\log P(y\mid x)=\sum_i w_if_i(x,y)-\log Z_w(x)。
$$

**对数概率是特征的线性函数**，故称**对数线性模型**（log-linear model）。

这一模型族极其广泛：

| 模型 | 特征设计 |
| --- | --- |
| 逻辑斯谛回归 | $f_i(x,y)=x^{(i)}\mathbf 1(y=1)$ |
| Softmax 回归 | $f_{i,k}(x,y)=x^{(i)}\mathbf 1(y=k)$ |
| 最大熵模型 | 任意人工设计特征 |
| **条件随机场**（第 11 章） | 序列上的特征 |
| 神经网络分类层 | $x$ 换成学到的表示 |

> 第 11 章的条件随机场就是**把最大熵模型推广到序列结构**，本章的推导会在那里再次出现。所以本章的推导务必吃透。

#### 6.3.3 与朴素贝叶斯的对比（生成-判别对）

| | 朴素贝叶斯（第 4 章） | 逻辑斯谛回归（本章） |
| --- | --- | --- |
| 类型 | 生成 | 判别 |
| 建模 | $P(X,Y)=P(Y)P(X\mid Y)$ | $P(Y\mid X)$ |
| 独立假设 | **需要**（条件独立） | **不需要** |
| 参数求解 | 闭式计数 | 迭代优化 |
| 后验形式 | 对数线性 | 对数线性 |
| 小样本 | 较优 | 易过拟合 |
| 大样本 | 受假设偏差限制 | 较优 |
| 概率校准 | 差（过度自信） | **好** |

**关键区别**：两者的**模型形式相同**（都是对数线性），但**参数估计目标不同**：

- 朴素贝叶斯最大化**联合似然** $\prod P(x_i,y_i)$；
- 逻辑斯谛回归最大化**条件似然** $\prod P(y_i\mid x_i)$。

正因为不需要对 $P(X)$ 建模，逻辑斯谛回归**不必假设特征独立**，可以处理相关特征。这也是它概率校准更好的原因（第 4 章讲过朴素贝叶斯因重复计数而过度自信）。

---

### 6.4 模型学习的最优化算法

#### 6.4.1 目标函数的良好性质

两个模型的学习都归结为：

$$
\max_w\;L(w)=\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)
-\sum_x\tilde P(x)\log Z_w(x)。
$$

**梯度**（重要，后面反复用到）：

$$
\frac{\partial L(w)}{\partial w_i}
=E_{\tilde P}(f_i)-E_P(f_i)
=\underbrace{\sum_{x,y}\tilde P(x,y)f_i(x,y)}_{\text{经验期望}}
-\underbrace{\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i(x,y)}_{\text{模型期望}}。
$$

**推导 $\log Z_w$ 的导数**（这一步值得单独看）：

$$
\begin{aligned}
\frac{\partial}{\partial w_i}\log Z_w(x)
&=\frac{1}{Z_w(x)}\frac{\partial Z_w(x)}{\partial w_i}\\
&=\frac{1}{Z_w(x)}\sum_y\exp\left(\sum_j w_jf_j(x,y)\right)f_i(x,y)\\
&=\sum_y P_w(y\mid x)f_i(x,y)。
\end{aligned}
$$

> 配分函数的对数导数等于充分统计量的期望——这是指数族分布的普遍性质。

**目标函数的性质**：

1. **光滑**：无穷次可微；
2. **凹**（负的是凸）：Hessian 半负定；
3. **全局最优**：任何局部最优即全局最优。

因此梯度下降、牛顿法、拟牛顿法都适用，且都能收敛到全局最优。

#### 6.4.2 改进的迭代尺度法（IIS）

**IIS 的基本思想**：找一个参数更新方式 $w\to w+\delta$，使对数似然**单调增加**，反复应用直到收敛。

难点在于：直接优化 $L(w+\delta)-L(w)$ 关于**向量** $\delta$ 很困难（各分量耦合）。IIS 的策略是**两次放缩下界**，最终让各个 $\delta_i$ **解耦**，可以逐个求解。

**第一次放缩：用 $\log\alpha\le\alpha-1$**

参数改变量：

$$
\begin{aligned}
L(w+\delta)-L(w)
=&\sum_{x,y}\tilde P(x,y)\sum_i\delta_if_i(x,y)\\
&-\sum_x\tilde P(x)\log\frac{Z_{w+\delta}(x)}{Z_w(x)}。
\end{aligned}
$$

先化简配分函数之比：

$$
\begin{aligned}
\frac{Z_{w+\delta}(x)}{Z_w(x)}
&=\frac{1}{Z_w(x)}\sum_y\exp\left(\sum_i(w_i+\delta_i)f_i(x,y)\right)\\
&=\sum_y\frac{\exp\left(\sum_i w_if_i\right)}{Z_w(x)}\exp\left(\sum_i\delta_if_i\right)\\
&=\sum_y P_w(y\mid x)\exp\left(\sum_i\delta_if_i(x,y)\right)。
\end{aligned}
$$

利用不等式

$$
-\log\alpha\ge1-\alpha,\qquad\alpha>0
$$

（即 $\log\alpha\le\alpha-1$，由 $\log$ 的凹性和在 $\alpha=1$ 处的切线得到），有：

$$
\begin{aligned}
L(w+\delta)-L(w)
\ge&\sum_{x,y}\tilde P(x,y)\sum_i\delta_if_i(x,y)+1\\
&-\sum_x\tilde P(x)\sum_yP_w(y\mid x)\exp\left(\sum_i\delta_if_i(x,y)\right)\\
\triangleq&\;A(\delta\mid w)。
\end{aligned}
$$

**第二次放缩：用 Jensen 不等式**

引入

$$
f^{\#}(x,y)=\sum_{i=1}^{n}f_i(x,y)。
$$

当 $f_i$ 是二值函数时，$f^{\#}(x,y)$ 表示**所有特征在 $(x,y)$ 上出现的次数**。

关键改写：

$$
\sum_i\delta_if_i(x,y)
=\sum_i\frac{f_i(x,y)}{f^{\#}(x,y)}\Bigl(\delta_if^{\#}(x,y)\Bigr)。
$$

注意系数满足

$$
\frac{f_i(x,y)}{f^{\#}(x,y)}\ge0,
\qquad
\sum_i\frac{f_i(x,y)}{f^{\#}(x,y)}=1，
$$

构成一个**概率分布**。由 $\exp$ 的凸性和 Jensen 不等式：

$$
\exp\left(\sum_i\frac{f_i}{f^{\#}}\cdot\delta_if^{\#}\right)
\le\sum_i\frac{f_i}{f^{\#}}\exp\left(\delta_if^{\#}\right)。
$$

代入 $A(\delta\mid w)$（注意该项前面是负号，不等号方向反转）：

$$
\begin{aligned}
A(\delta\mid w)\ge
&\sum_{x,y}\tilde P(x,y)\sum_i\delta_if_i(x,y)+1\\
&-\sum_x\tilde P(x)\sum_yP_w(y\mid x)
\sum_i\frac{f_i(x,y)}{f^{\#}(x,y)}\exp\left(\delta_if^{\#}(x,y)\right)\\
\triangleq&\;B(\delta\mid w)。
\end{aligned}
$$

于是得到链式关系：

$$
L(w+\delta)-L(w)\ge A(\delta\mid w)\ge B(\delta\mid w)。
$$

**第三步：求解 $\delta_i$**

$B(\delta\mid w)$ 的**决定性优点**：$\delta_i$ 只出现在 $\exp(\delta_i f^{\#})$ 中，各分量**完全解耦**！

求偏导：

$$
\frac{\partial B(\delta\mid w)}{\partial\delta_i}
=\sum_{x,y}\tilde P(x,y)f_i(x,y)
-\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i(x,y)\exp\bigl(\delta_if^{\#}(x,y)\bigr)。
$$

令其为 0：

$$
\boxed{\;
\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i(x,y)\exp\bigl(\delta_if^{\#}(x,y)\bigr)
=E_{\tilde P}(f_i)
\;}
$$

**这个方程只含 $\delta_i$ 一个未知数**，可以逐个求解。这就是两次放缩的全部目的。

**算法 6.1（IIS）**

**输入**：特征函数 $f_1,\ldots,f_n$；经验分布 $\tilde P(X,Y)$
**输出**：最优参数 $w^*$，最优模型 $P_{w^*}$

1. 对所有 $i$，取初值 $w_i=0$；
2. 对每一个 $i\in\{1,\ldots,n\}$：
   - (a) 求解上述方程得到 $\delta_i$；
   - (b) 更新 $w_i\leftarrow w_i+\delta_i$；
3. 若未收敛，重复步骤 2。

**特殊情形：$f^{\#}$ 为常数**

若对所有 $(x,y)$ 有 $f^{\#}(x,y)=M$（常数），方程简化为：

$$
\exp(\delta_iM)\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i(x,y)=E_{\tilde P}(f_i)，
$$

$$
\exp(\delta_iM)\,E_P(f_i)=E_{\tilde P}(f_i)，
$$

得到**闭式解**：

$$
\boxed{\;\delta_i=\frac{1}{M}\log\frac{E_{\tilde P}(f_i)}{E_P(f_i)}\;}
$$

**直观解读**：

- 若模型期望**小于**经验期望（$E_P<E_{\tilde P}$），说明该特征"用得不够"，$\delta_i>0$，**增大**权重；
- 若模型期望**大于**经验期望，$\delta_i<0$，**减小**权重；
- 两者相等时 $\delta_i=0$，达到最优（正是最大熵的约束条件）。

**一般情形：用牛顿法解 $\delta_i$**

若 $f^{\#}$ 不是常数，记方程为 $g(\delta_i)=0$，用牛顿法迭代：

$$
\delta_i^{(k+1)}=\delta_i^{(k)}-\frac{g\bigl(\delta_i^{(k)}\bigr)}{g'\bigl(\delta_i^{(k)}\bigr)}。
$$

由于 $g$ 单调（$g'>0$），方程有单根，牛顿法恒收敛且很快。

#### 6.4.3 拟牛顿法（BFGS）

**为什么需要拟牛顿法？** 牛顿法收敛快，但需要计算并求逆 Hessian 矩阵：

- 计算 $H$ 需 $O(n^2)$ 存储、$O(Nn^2)$ 时间；
- 求逆需 $O(n^3)$ 时间。

当 $n$ 很大（如 NLP 中特征数百万）时不可行。

**拟牛顿法的思想**：不精确计算 Hessian，而是用迭代过程中的**梯度差**去**近似**它，同时保持超线性收敛速度。

**目标函数**（取负号变成极小化）：

$$
\min_w\;f(w)=\sum_x\tilde P(x)\log\sum_y\exp\left(\sum_i w_if_i(x,y)\right)
-\sum_{x,y}\tilde P(x,y)\sum_i w_if_i(x,y)。
$$

**梯度**：

$$
\frac{\partial f(w)}{\partial w_i}
=\sum_{x,y}\tilde P(x)P_w(y\mid x)f_i(x,y)-E_{\tilde P}(f_i)
=E_P(f_i)-E_{\tilde P}(f_i)。
$$

**算法 6.2（最大熵模型学习的 BFGS 算法）**

**输入**：特征函数、经验分布、目标函数 $f(w)$、梯度 $g(w)$、精度 $\varepsilon$
**输出**：最优参数 $w^*$

1. 选定初始点 $w^{(0)}$，取 $B_0$ 为正定对称矩阵（通常取单位阵），置 $k=0$；
2. 计算 $g_k=g(w^{(k)})$。若 $\lVert g_k\rVert<\varepsilon$，停止，得 $w^*=w^{(k)}$；
3. 由 $B_kp_k=-g_k$ 解出搜索方向 $p_k$；
4. 一维搜索：求 $\lambda_k$ 使

$$
f(w^{(k)}+\lambda_kp_k)=\min_{\lambda\ge0}f(w^{(k)}+\lambda p_k)；
$$

5. 置 $w^{(k+1)}=w^{(k)}+\lambda_kp_k$；
6. 计算 $g_{k+1}$。若 $\lVert g_{k+1}\rVert<\varepsilon$ 则停止；否则按下式更新：

$$
B_{k+1}=B_k+\frac{y_ky_k^\top}{y_k^\top\delta_k}
-\frac{B_k\delta_k\delta_k^\top B_k}{\delta_k^\top B_k\delta_k}，
$$

其中

$$
y_k=g_{k+1}-g_k,\qquad\delta_k=w^{(k+1)}-w^{(k)}；
$$

7. 置 $k=k+1$，转步骤 3。

**BFGS 更新公式的来源**。要求近似 Hessian 满足**割线方程**：

$$
B_{k+1}\delta_k=y_k，
$$

这是对 $\nabla^2f\cdot\Delta w\approx\Delta g$ 的离散化。满足该方程的矩阵有无穷多，BFGS 在其中选择"与 $B_k$ 差异最小且保持正定对称"的那一个。

> 保持**正定**很关键：它保证 $p_k=-B_k^{-1}g_k$ 是**下降方向**（因为 $g_k^\top p_k=-g_k^\top B_k^{-1}g_k<0$）。

**实践中**：大规模问题常用 **L-BFGS**（有限内存 BFGS），只存储最近 $m$（通常 5–20）步的 $\{\delta,y\}$ 对，内存降到 $O(mn)$。L-BFGS 是训练最大熵模型和条件随机场的**事实标准**。

#### 6.4.4 算法对比

| 算法 | 收敛速度 | 每步代价 | 内存 | 适用 |
| --- | --- | --- | --- | --- |
| 梯度下降 | 线性（慢） | $O(Nn)$ | $O(n)$ | 简单，易实现 |
| **IIS** | 线性 | $O(Nn)$ | $O(n)$ | 最大熵专用 |
| 牛顿法 | **二次（最快）** | $O(Nn^2+n^3)$ | $O(n^2)$ | $n$ 小 |
| **BFGS** | 超线性 | $O(Nn+n^2)$ | $O(n^2)$ | 中等规模 |
| **L-BFGS** | 超线性 | $O(Nn+mn)$ | $O(mn)$ | **大规模首选** |
| SGD | 次线性 | $O(n)$ | $O(n)$ | 超大数据 |

**代码验证**（6.5 节）在同一问题上：

- 牛顿法：**4 步**收敛到 $10^{-14}$ 精度；
- 梯度上升：需 **1000+ 步**达到同样精度。

> 这与理论一致：牛顿法利用了二阶信息（曲率），能自适应调整步长和方向；梯度下降只有一阶信息，在病态问题上会来回震荡。

---

### 6.5 代码实现与验证

```python
"""逻辑斯谛回归与最大熵模型（《统计学习方法》第 6 章）"""
import math
from collections import defaultdict


def sigmoid(z):
    """数值稳定的 sigmoid"""
    if z >= 0:
        return 1.0 / (1.0 + math.exp(-z))
    ez = math.exp(z)                 # z 很负时避免 exp(-z) 溢出
    return ez / (1.0 + ez)


def check_sigmoid_properties():
    print("=== sigmoid 性质验证 ===")
    for z in [-2.0, -0.5, 0.0, 1.3]:
        h = 1e-6
        numeric = (sigmoid(z + h) - sigmoid(z - h)) / (2 * h)
        analytic = sigmoid(z) * (1 - sigmoid(z))
        print(f"  z={z:+.1f}  sigma'数值={numeric:.9f}  "
              f"sigma(1-sigma)={analytic:.9f}  差={abs(numeric-analytic):.1e}")
    print(f"  对称性 sigma(-1.5)+sigma(1.5) = "
          f"{sigmoid(-1.5)+sigmoid(1.5):.10f}  (应为 1)")


class LogisticRegression:
    """二项逻辑斯谛回归，支持梯度上升与牛顿法(IRLS)"""

    def __init__(self, X, Y):
        self.X, self.Y = X, Y
        self.n = len(X[0])

    def log_likelihood(self, w):
        """L(w) = sum[ y*(w.x) - log(1+exp(w.x)) ]"""
        total = 0.0
        for x, y in zip(self.X, self.Y):
            z = sum(wi * xi for wi, xi in zip(w, x))
            total += y * z - math.log(1 + math.exp(z)) if z < 500 else y * z - z
        return total

    def gradient(self, w):
        """grad = sum (y_i - pi_i) x_i"""
        g = [0.0] * self.n
        for x, y in zip(self.X, self.Y):
            p = sigmoid(sum(wi * xi for wi, xi in zip(w, x)))
            for j in range(self.n):
                g[j] += x[j] * (y - p)
        return g

    def hessian(self, w):
        """H = -sum pi(1-pi) x x^T"""
        H = [[0.0] * self.n for _ in range(self.n)]
        for x, _ in zip(self.X, self.Y):
            p = sigmoid(sum(wi * xi for wi, xi in zip(w, x)))
            for a in range(self.n):
                for b in range(self.n):
                    H[a][b] -= p * (1 - p) * x[a] * x[b]
        return H

    def fit_gradient_ascent(self, lr=0.1, iters=20000):
        w = [0.0] * self.n
        for _ in range(iters):
            g = self.gradient(w)
            for j in range(self.n):
                w[j] += lr * g[j]
        return w

    def fit_newton(self, iters=10):
        """牛顿法（二维情形显式求逆，便于展示原理）"""
        w = [0.0] * self.n
        history = []
        for _ in range(iters):
            g, H = self.gradient(w), self.hessian(w)
            det = H[0][0] * H[1][1] - H[0][1] * H[1][0]
            inv = [[H[1][1] / det, -H[0][1] / det],
                   [-H[1][0] / det, H[0][0] / det]]
            for j in range(self.n):
                w[j] -= sum(inv[j][k] * g[k] for k in range(self.n))
            history.append((self.log_likelihood(w), w[:]))
        return w, history


class MaxEnt:
    """最大熵模型，用 IIS 训练（内层以牛顿法解 delta）"""

    def __init__(self, data, features, labels):
        self.data, self.feats, self.Ys = data, features, labels
        self.nf = len(features)
        self.Xs = sorted(set(x for x, _ in data))
        N = len(data)
        self.pxy, self.px = defaultdict(float), defaultdict(float)
        for x, y in data:
            self.pxy[(x, y)] += 1.0 / N
            self.px[x] += 1.0 / N
        # 经验期望 E_P~(f_i)
        self.Ep_emp = [sum(self.pxy[(x, y)] * f(x, y)
                           for x in self.Xs for y in self.Ys)
                       for f in features]

    def prob(self, w, x):
        """P_w(y|x) = exp(sum w_i f_i) / Z_w(x)，用减最大值保证稳定"""
        scores = [sum(w[i] * self.feats[i](x, y) for i in range(self.nf))
                  for y in self.Ys]
        m = max(scores)
        exps = [math.exp(s - m) for s in scores]
        Z = sum(exps)
        return {y: exps[k] / Z for k, y in enumerate(self.Ys)}

    def model_expectation(self, w, i):
        """E_P(f_i) = sum P~(x) P_w(y|x) f_i(x,y)"""
        return sum(self.px[x] * self.prob(w, x)[y] * self.feats[i](x, y)
                   for x in self.Xs for y in self.Ys)

    def log_likelihood(self, w):
        return sum(self.pxy[(x, y)] * math.log(self.prob(w, x)[y])
                   for x in self.Xs for y in self.Ys if self.pxy[(x, y)] > 0)

    def f_sharp(self, x, y):
        """f#(x,y) = sum_i f_i(x,y)"""
        return sum(f(x, y) for f in self.feats)

    def _solve_delta(self, w, i, tol=1e-14, max_iter=80):
        """牛顿法解 sum P~(x)P_w(y|x) f_i exp(delta*f#) = E_P~(f_i)"""
        d = 0.0
        for _ in range(max_iter):
            g = sum(self.px[x] * self.prob(w, x)[y] * self.feats[i](x, y)
                    * math.exp(d * self.f_sharp(x, y))
                    for x in self.Xs for y in self.Ys) - self.Ep_emp[i]
            gp = sum(self.px[x] * self.prob(w, x)[y] * self.feats[i](x, y)
                     * self.f_sharp(x, y) * math.exp(d * self.f_sharp(x, y))
                     for x in self.Xs for y in self.Ys)
            if abs(gp) < 1e-15:
                break
            step = g / gp
            d -= step
            if abs(step) < tol:
                break
        return d

    def fit_iis(self, iters=20000, verbose_at=()):
        w = [0.0] * self.nf
        for it in range(1, iters + 1):
            for i in range(self.nf):
                w[i] += self._solve_delta(w, i)
            if it in verbose_at:
                print(f"  iter={it:<6d} L={self.log_likelihood(w):.10f}  "
                      f"w=[{', '.join(f'{v:.6f}' for v in w)}]")
        return w


check_sigmoid_properties()

print("\n=== 例 6.2 验证 ===")
p12, p345 = 3 / 20, 7 / 30
H = -2 * p12 * math.log(p12) - 3 * p345 * math.log(p345)
print(f"  P(y1)=P(y2)={p12:.6f}   P(y3..5)={p345:.6f}")
print(f"  约束 P(y1)+P(y2)={2*p12:.6f} (应=0.3)   总和={2*p12+3*p345:.6f}")
print(f"  最大熵 H={H:.6f}")

print("\n=== 逻辑斯谛回归：梯度上升 vs 牛顿法 ===")
X = [[1, 0.5], [1, 1.5], [1, 2.0], [1, 2.5],
     [1, 3.5], [1, 4.0], [1, 4.5], [1, 5.5]]
Y = [0, 0, 1, 0, 1, 0, 1, 1]
lr_model = LogisticRegression(X, Y)

w_gd = lr_model.fit_gradient_ascent(lr=0.1, iters=20000)
w_nt, hist = lr_model.fit_newton(iters=6)
print("  牛顿法收敛过程：")
for k, (L, w) in enumerate(hist[:5], 1):
    print(f"    iter={k}  L={L:.8f}  w=[{w[0]:.5f}, {w[1]:.5f}]")
print(f"  梯度上升(20000步) w=[{w_gd[0]:.5f}, {w_gd[1]:.5f}]")
print(f"  牛顿法    (6步)   w=[{w_nt[0]:.5f}, {w_nt[1]:.5f}]")
print(f"  两者最大差异 = {max(abs(a-b) for a, b in zip(w_gd, w_nt)):.2e}")

H_mat = lr_model.hessian(w_nt)
det = H_mat[0][0] * H_mat[1][1] - H_mat[0][1] * H_mat[1][0]
print(f"  -H 主子式: {-H_mat[0][0]:.6f}, {det:.6f}  => 正定，L 为凹函数")

print("\n=== 完全可分数据：MLE 不存在 ===")
X2, Y2 = [[1, 1.0], [1, 2.0], [1, 4.0], [1, 5.0]], [0, 0, 1, 1]
sep = LogisticRegression(X2, Y2)
w = [0.0, 0.0]
for it in range(1, 200001):
    g = sep.gradient(w)
    for j in range(2):
        w[j] += 0.1 * g[j]
    if it in (100, 1000, 20000, 200000):
        print(f"  iter={it:<7d} |w|={math.hypot(*w):8.4f}  "
              f"L={sep.log_likelihood(w):.8f}")
print("  => |w| 持续增长，L 趋近 0 但取不到 => 必须加正则化")

print("\n=== 最大熵(IIS) 与 逻辑斯谛回归 的等价性 ===")
data = ([((1, 1), 1)] * 3 + [((1, 1), 0)] * 1
        + [((1, 0), 1)] * 2 + [((1, 0), 0)] * 2
        + [((0, 1), 1)] * 1 + [((0, 1), 0)] * 3
        + [((0, 0), 1)] * 1 + [((0, 0), 0)] * 4)

features = [lambda x, y: 1.0 if y == 1 else 0.0,
            lambda x, y: 1.0 if (x[0] == 1 and y == 1) else 0.0,
            lambda x, y: 1.0 if (x[1] == 1 and y == 1) else 0.0]

me = MaxEnt(data, features, [0, 1])
print(f"  经验期望 = {[round(v, 6) for v in me.Ep_emp]}")
w_iis = me.fit_iis(iters=20000, verbose_at=(1, 10, 100, 20000))

X3 = [[1.0, float(x[0]), float(x[1])] for x, _ in data]
Y3 = [y for _, y in data]
lr3 = LogisticRegression(X3, Y3)
w_lr = lr3.fit_gradient_ascent(lr=0.5 / len(data), iters=300000)

print(f"\n  IIS (最大熵)   w = [{', '.join(f'{v:.6f}' for v in w_iis)}]")
print(f"  梯度上升(LR)   w = [{', '.join(f'{v:.6f}' for v in w_lr)}]")
print(f"  最大差异 = {max(abs(a-b) for a, b in zip(w_iis, w_lr)):.2e}")

print("\n  约束 E_P(f_i) = E_P~(f_i) 检验：")
for i in range(3):
    em, ee = me.model_expectation(w_iis, i), me.Ep_emp[i]
    print(f"    f{i}: 模型={em:.10f}  经验={ee:.10f}  差={abs(em-ee):.1e}")

print("\n  预测概率对比：")
for x in me.Xs:
    pm = me.prob(w_iis, x)[1]
    plr = sigmoid(w_lr[0] + w_lr[1] * x[0] + w_lr[2] * x[1])
    emp = (sum(1 for xx, yy in data if xx == x and yy == 1)
           / sum(1 for xx, _ in data if xx == x))
    print(f"    x={x}  最大熵={pm:.6f}  LR={plr:.6f}  经验频率={emp:.6f}")
```

**运行结果：**

```text
=== sigmoid 性质验证 ===
  z=-2.0  sigma'数值=0.104993585  sigma(1-sigma)=0.104993585  差=1.3e-12
  z=-0.5  sigma'数值=0.235003712  sigma(1-sigma)=0.235003712  差=3.8e-11
  z=+0.0  sigma'数值=0.250000000  sigma(1-sigma)=0.250000000  差=7.2e-12
  z=+1.3  sigma'数值=0.168298363  sigma(1-sigma)=0.168298362  差=5.5e-11
  对称性 sigma(-1.5)+sigma(1.5) = 1.0000000000  (应为 1)

=== 例 6.2 验证 ===
  P(y1)=P(y2)=0.150000   P(y3..5)=0.233333
  约束 P(y1)+P(y2)=0.300000 (应=0.3)   总和=1.000000
  最大熵 H=1.587837

=== 逻辑斯谛回归：梯度上升 vs 牛顿法 ===
  牛顿法收敛过程：
    iter=1  L=-4.18350434  w=[-2.15385, 0.71795]
    iter=2  L=-4.13011517  w=[-2.70609, 0.90203]
    iter=3  L=-4.12941139  w=[-2.77933, 0.92644]
    iter=4  L=-4.12941121  w=[-2.78051, 0.92684]
    iter=5  L=-4.12941121  w=[-2.78051, 0.92684]
  梯度上升(20000步) w=[-2.78051, 0.92684]
  牛顿法    (6步)   w=[-2.78051, 0.92684]
  两者最大差异 = 1.15e-14
  -H 主子式: 1.362978, 3.085756  => 正定，L 为凹函数

=== 完全可分数据：MLE 不存在 ===
  iter=100     |w|=  3.9803  L=-0.60685574
  iter=1000    |w|=  9.7901  L=-0.08800771
  iter=20000   |w|= 18.8457  L=-0.00493707
  iter=200000  |w|= 26.0896  L=-0.00049913
  => |w| 持续增长，L 趋近 0 但取不到 => 必须加正则化

=== 最大熵(IIS) 与 逻辑斯谛回归 的等价性 ===
  经验期望 = [0.411765, 0.294118, 0.235294]
  iter=1      L=-0.6783985697  w=[-0.101409, 0.109455, 0.009381]
  iter=10     L=-0.6126942007  w=[-0.675029, 0.817504, 0.182471]
  iter=100    L=-0.5788782661  w=[-1.583479, 1.753779, 0.702717]
  iter=20000  L=-0.5788581256  w=[-1.608880, 1.775544, 0.721108]

  IIS (最大熵)   w = [-1.608880, 1.775544, 0.721108]
  梯度上升(LR)   w = [-1.608880, 1.775544, 0.721108]
  最大差异 = 4.88e-15

  约束 E_P(f_i) = E_P~(f_i) 检验：
    f0: 模型=0.4117647059  经验=0.4117647059  差=5.6e-17
    f1: 模型=0.2941176471  经验=0.2941176471  差=0.0e+00
    f2: 模型=0.2352941176  经验=0.2352941176  差=0.0e+00

  预测概率对比：
    x=(0, 0)  最大熵=0.166744  LR=0.166744  经验频率=0.200000
    x=(0, 1)  最大熵=0.291570  LR=0.291570  经验频率=0.250000
    x=(1, 0)  最大熵=0.541570  LR=0.541570  经验频率=0.500000
    x=(1, 1)  最大熵=0.708430  LR=0.708430  经验频率=0.750000
```

> **Windows 运行提示**：若报 `UnicodeEncodeError: 'charmap' codec`，执行前设置 `$env:PYTHONIOENCODING = "utf-8"`。

**四个结论被代码严格验证：**

| 结论 | 证据 |
| --- | --- |
| $\sigma'=\sigma(1-\sigma)$ | 数值导数与解析式差 $10^{-11}$ |
| 牛顿法远快于梯度下降 | 4 步 vs 20000 步，结果差 $10^{-14}$ |
| 可分数据 MLE 发散 | 20 万步后 $\lVert w\rVert=26.09$ 仍在增长 |
| **最大熵 ≡ 逻辑斯谛回归** | **两条路线参数差 $4.9\times10^{-15}$** |

特别注意最后的**约束满足性**：IIS 求得最优解后，$E_P(f_i)$ 与 $E_{\tilde P}(f_i)$ 在机器精度内**完全相等**。这从数值上印证了 6.2.7 节的洞察——**最大熵的约束条件，就是极大似然的一阶最优性条件**。

---

### 6.6 深入理解

#### 6.6.1 逻辑斯谛回归 vs 感知机 vs SVM

三者都是线性分类器，决策边界都是 $w\cdot x=0$，区别在**损失函数**：

令 $z=y(w\cdot x)$（这里 $y\in\{-1,+1\}$）：

| 模型 | 损失函数 | 特点 |
| --- | --- | --- |
| 感知机 | $\max(0,-z)$ | 只惩罚错误 |
| SVM | $\max(0,1-z)$ | 惩罚"间隔不足" |
| 逻辑斯谛回归 | $\log(1+e^{-z})$ | **所有样本都有梯度** |
| 0-1 损失 | $\mathbf 1(z\le0)$ | 理想但不可优化 |

**逻辑斯谛损失的特点**：

- **处处可微**（感知机和 SVM 的合页损失在折点不可微）；
- 即使分类正确（$z>0$）仍有微小损失，促使模型继续增大间隔；
- $z\to-\infty$ 时损失线性增长（比指数损失更**抗噪声**）；
- 是 0-1 损失的**凸上界**（可优化的替代损失）。

> 第 8 章 AdaBoost 用的是指数损失 $e^{-z}$，对离群点更敏感。逻辑斯谛损失因为增长较慢，鲁棒性更好。

#### 6.6.2 最大熵原理的普适性

最大熵原理不止用于分类，它是一个**普适的建模准则**：

| 已知约束 | 最大熵分布 |
| --- | --- |
| 取值范围有限 | **均匀分布** |
| 均值固定（非负支撑） | **指数分布** |
| 均值和方差固定 | **正态分布** |
| 期望特征匹配 | **对数线性模型**（本章） |

> **正态分布的一个深刻解释**：在所有均值 $\mu$、方差 $\sigma^2$ 给定的分布中，正态分布熵最大。这就是为什么"不知道具体分布时假设正态"是合理的——它是最"不做多余假设"的选择。

这些结论都可以用本章的拉格朗日方法推导：写出熵、加约束、求对偶。**方法完全相同，只是约束不同**。

#### 6.6.3 为什么是指数族

从 6.2.5 节的推导可以看到，最大熵模型的指数形式

$$
P(y\mid x)\propto\exp\left(\sum_i w_if_i(x,y)\right)
$$

**不是假设，而是推导结果**——它来自"对 $p\log p$ 求导得 $\log p+1$，令其等于线性项"这一步。

一般地，**指数族分布**形如：

$$
P(y;\eta)=h(y)\exp\bigl(\eta^\top T(y)-A(\eta)\bigr)。
$$

最大熵模型正是指数族在条件分布上的体现，其中：

- $\eta=w$ 是自然参数；
- $T(y)=f(x,y)$ 是充分统计量；
- $A(\eta)=\log Z_w(x)$ 是对数配分函数。

指数族的普遍性质在本章都能看到：

$$
\nabla A(\eta)=\mathbb E[T(y)]
\quad\text{（配分函数梯度 = 期望，见 6.4.1 节）}，
$$

$$
\nabla^2A(\eta)=\operatorname{Cov}[T(y)]\succeq0
\quad\text{（故 }A\text{ 凸，目标函数凹）}。
$$

**凸性的根源就在这里**——不是巧合，是指数族的必然性质。

#### 6.6.4 实践要点

| 问题 | 处理 |
| --- | --- |
| 数据可分 | **必须加正则**（$L_2$ 或 $L_1$） |
| 特征尺度差异大 | 标准化（影响收敛速度和正则效果） |
| 类别不平衡 | 调整类别权重或决策阈值 |
| 特征数极大 | L-BFGS 或 SGD；$L_1$ 正则做特征选择 |
| 需要概率输出 | 逻辑斯谛回归**天然校准良好** |
| 需要非线性边界 | 特征工程 / 核方法 / 换模型 |
| 数值溢出 | $\log(1+e^z)$ 用 `logaddexp`；softmax 减最大值 |

**数值稳定技巧**（代码中已体现）：

$$
\log(1+e^z)=
\begin{cases}
z+\log(1+e^{-z}),&z>0,\\
\log(1+e^{z}),&z\le0，
\end{cases}
$$

softmax 计算时统一减去最大值：$\dfrac{e^{s_k-M}}{\sum_je^{s_j-M}}$，$M=\max_js_j$。

---

### 6.7 本章方法论总结

#### 6.7.1 用三要素分析

**模型**

对数线性模型：

$$
\mathcal F=\left\{P_w(y\mid x)=\frac{1}{Z_w(x)}
\exp\left(\sum_iw_if_i(x,y)\right)\right\}。
$$

属于**判别**、**概率**、**参数化**、**线性**模型。

**策略**

极大似然估计（或正则化极大似然）：

$$
\max_w\;L(w)
\qquad\text{或}\qquad
\max_w\;L(w)-\frac{\lambda}{2}\lVert w\rVert^2。
$$

等价说法：最小化交叉熵损失 / 最大熵原理下的对偶极大化。

**算法**

目标函数光滑凹，可用：IIS、梯度下降、牛顿法、BFGS/L-BFGS、SGD。均收敛到全局最优。

#### 6.7.2 必须掌握的结论

1. 逻辑斯谛分布的分布函数是 sigmoid，把 $\mathbb R$ 单调映射到开区间 $(0,1)$。
2. $\sigma'(z)=\sigma(z)(1-\sigma(z))$，这是梯度形式简洁的根源。
3. 逻辑斯谛回归的本质定义：**对数几率是输入的线性函数** $\log\frac{p}{1-p}=w\cdot x$。
4. 参数 $w^{(j)}$ 的含义：该特征增加一个单位，几率乘以 $e^{w^{(j)}}$。
5. 对数似然 $L(w)=\sum_i[y_i(w\cdot x_i)-\log(1+e^{w\cdot x_i})]$，等价于负交叉熵。
6. 梯度 $\nabla L=\sum_i(y_i-\pi_i)x_i$，形式为"残差 × 特征"。
7. 不用平方损失的原因：非凸，且梯度含 $\sigma(1-\sigma)$ 因子导致**错得越离谱学得越慢**。
8. Hessian $=-\sum\pi_i(1-\pi_i)x_ix_i^\top$ 半负定，故目标函数凹，**局部最优即全局最优**。
9. **数据完全可分时 MLE 不存在**，$\lVert w\rVert\to\infty$，必须加正则化。
10. 多项逻辑斯谛回归即 softmax，是神经网络分类层的直接来源；参数有冗余，需固定参照类。
11. 最大熵原理：满足约束的前提下选熵最大的模型，即"不做多余假设"。
12. 特征函数的约束是**矩匹配** $E_P(f_i)=E_{\tilde P}(f_i)$。
13. 最大熵模型由拉格朗日对偶推出，指数形式是**推导结果而非假设**。
14. **核心定理**：对偶函数 $\Psi(w)$ 恒等于对数似然 $L_{\tilde P}(P_w)$，故最大熵 ≡ 极大似然。
15. 更深一层：最大熵的**约束条件**正是极大似然的**梯度为零条件**。
16. **逻辑斯谛回归是最大熵模型的特例**，取 $f_i(x,y)=x^{(i)}\mathbf 1(y=1)$ 即可。
17. IIS 通过两次放缩（$\log\alpha\le\alpha-1$ 和 Jensen 不等式）使各 $\delta_i$ **解耦**，从而可逐个求解。
18. $f^\#$ 为常数时 $\delta_i$ 有闭式解 $\frac1M\log\frac{E_{\tilde P}(f_i)}{E_P(f_i)}$，否则用牛顿法。
19. BFGS 用梯度差近似 Hessian，满足割线方程并保持正定；大规模用 L-BFGS。
20. 最大熵原理是普适建模准则：均值约束→指数分布，均值方差约束→**正态分布**。

---

### 6.8 习题思路与推导

#### 习题 6.1：确认逻辑斯谛分布属于指数分布族

**先澄清题意。** 这道题需要分两个层面回答，否则容易出错。

**（一）严格地说，连续的逻辑斯谛分布本身不是指数族**

指数族的标准形式为：

$$
p(x;\theta)=h(x)\exp\bigl(\eta(\theta)^\top T(x)-A(\theta)\bigr)。
$$

逻辑斯谛分布（固定 $\gamma=1$）的对数密度为：

$$
\log f(x;\mu)=-(x-\mu)-2\log\bigl(1+e^{-(x-\mu)}\bigr)。
$$

第二项 $\log(1+e^{-(x-\mu)})$ **无法拆成 $\eta(\mu)T(x)-A(\mu)$ 的形式**（$x$ 与 $\mu$ 不可分离）。所以它是一个**位置-尺度族**，不是指数族。

**（二）题目真正要考的：逻辑斯谛回归的 Bernoulli 模型属于指数族**

逻辑斯谛回归建模的是 $Y\mid X$ 的 Bernoulli 分布。设 $P(Y=1)=p$，$y\in\{0,1\}$：

$$
\begin{aligned}
P(y;p)
&=p^y(1-p)^{1-y}\\
&=\exp\Bigl[y\log p+(1-y)\log(1-p)\Bigr]\\
&=\exp\left[y\log\frac{p}{1-p}+\log(1-p)\right]。
\end{aligned}
$$

令**自然参数**

$$
\eta=\log\frac{p}{1-p}=\operatorname{logit}(p)，
$$

反解得

$$
p=\frac{e^\eta}{1+e^\eta}=\sigma(\eta)，
$$

$$
\log(1-p)=\log\frac{1}{1+e^\eta}=-\log(1+e^\eta)。
$$

于是：

$$
\boxed{\;
P(y;\eta)=\exp\Bigl[\eta y-\log(1+e^\eta)\Bigr]
\;}
$$

对照标准形式，各部分为：

| 记号 | 值 |
| --- | --- |
| $h(y)$ | $1$ |
| $T(y)$（充分统计量） | $y$ |
| $\eta$（自然参数） | $\operatorname{logit}(p)$ |
| $A(\eta)$（对数配分函数） | $\log(1+e^\eta)$ |

**验证指数族的两个基本性质：**

$$
A'(\eta)=\frac{e^\eta}{1+e^\eta}=\sigma(\eta)=p=\mathbb E[Y]\ \checkmark
$$

$$
A''(\eta)=\sigma(\eta)\bigl(1-\sigma(\eta)\bigr)=p(1-p)=\operatorname{Var}[Y]\ \checkmark
$$

**这与逻辑斯谛回归的联系（GLM 视角）：**

广义线性模型的构造法则是：**令自然参数等于线性预测子**

$$
\eta=w\cdot x。
$$

代入 $p=\sigma(\eta)$ 立即得到

$$
P(Y=1\mid x)=\sigma(w\cdot x)，
$$

**这正是逻辑斯谛回归。**

$\operatorname{logit}$ 因此被称为 Bernoulli 分布的**典范连接函数**（canonical link）。这解释了本章的两个"巧合"：

- 6.1.4 节"对数几率是线性的"——因为对数几率就是自然参数；
- 6.1.7 节"交叉熵梯度中 $\sigma(1-\sigma)$ 恰好消掉"——因为用典范连接时，GLM 的梯度恒为 $\sum(y_i-\mu_i)x_i$，与分布无关。

> **同一套框架的其他成员**：正态分布 + 恒等连接 = 线性回归；泊松分布 + 对数连接 = 泊松回归。逻辑斯谛回归只是 GLM 家族的一员。

#### 习题 6.2：逻辑斯谛回归的梯度下降算法

**目标函数**。最小化负对数似然（等价于最大化 $L(w)$）：

$$
J(w)=-L(w)=\sum_{i=1}^{N}\Bigl[\log\bigl(1+e^{w\cdot x_i}\bigr)-y_i(w\cdot x_i)\Bigr]。
$$

**梯度**。由 6.1.6 节：

$$
\nabla J(w)=-\sum_{i=1}^{N}\bigl[y_i-\pi(x_i)\bigr]x_i
=\sum_{i=1}^{N}\bigl[\pi(x_i)-y_i\bigr]x_i，
$$

其中 $\pi(x_i)=\sigma(w\cdot x_i)$。矩阵形式：$\nabla J=X^\top(\pi-y)$。

**算法（批量梯度下降）**

**输入**：训练集 $T$，学习率 $\eta>0$，精度 $\varepsilon$
**输出**：$w^*$ 及模型 $P(Y=1\mid x)=\sigma(w^*\cdot x)$

1. 取初值 $w^{(0)}=0$，置 $k=0$；
2. 计算所有 $\pi_i=\sigma(w^{(k)}\cdot x_i)$；
3. 计算梯度

$$
g_k=\sum_{i=1}^{N}(\pi_i-y_i)x_i；
$$

4. 若 $\lVert g_k\rVert<\varepsilon$，停止，输出 $w^*=w^{(k)}$；
5. 更新

$$
w^{(k+1)}=w^{(k)}-\eta\,g_k；
$$

6. 置 $k=k+1$，转步骤 2。

**几个实践要点：**

**（1）加正则化。** 若数据可分，必须加 $L_2$ 项：

$$
J_\lambda(w)=J(w)+\frac{\lambda}{2}\lVert w\rVert^2,
\qquad
\nabla J_\lambda=X^\top(\pi-y)+\lambda w，
$$

更新式变为

$$
w\leftarrow(1-\eta\lambda)w-\eta X^\top(\pi-y)，
$$

即每步先做一次**权重衰减**（weight decay）。

**（2）随机梯度下降（SGD）。** 大数据时每次只用一个样本：

$$
w\leftarrow w-\eta\bigl(\sigma(w\cdot x_i)-y_i\bigr)x_i。
$$

> 对比第 2 章感知机的更新 $w\leftarrow w+\eta y_ix_i$：形式几乎一样，但感知机只在犯错时更新且步长固定；逻辑斯谛回归的步长正比于**概率残差**，是"软化"版的感知机。

**（3）学习率。** 固定 $\eta$ 太大会震荡、太小则慢。可用回溯线搜索或 Adam 等自适应方法。

**（4）收敛速度。** 代码验证显示梯度下降需约 $2\times10^4$ 步，而牛顿法只需 **4 步**——若维数不高，优先用牛顿法/IRLS。

#### 习题 6.3：最大熵模型学习的 DFP 算法

**DFP 与 BFGS 的区别**。两者都是拟牛顿法，区别在于近似的对象：

| | 近似对象 | 更新公式 |
| --- | --- | --- |
| **BFGS**（算法 6.2） | Hessian $B\approx\nabla^2f$ | 需解 $B_kp_k=-g_k$ |
| **DFP** | Hessian 的**逆** $G\approx(\nabla^2f)^{-1}$ | 直接 $p_k=-G_kg_k$ |

DFP 直接维护逆矩阵，**省去每步解线性方程组**。

**目标函数与梯度**（同 6.4.3 节）：

$$
f(w)=\sum_x\tilde P(x)\log Z_w(x)
-\sum_{x,y}\tilde P(x,y)\sum_iw_if_i(x,y)，
$$

$$
g_i(w)=\frac{\partial f}{\partial w_i}=E_P(f_i)-E_{\tilde P}(f_i)。
$$

**算法（最大熵模型学习的 DFP 算法）**

**输入**：特征函数 $f_1,\ldots,f_n$，经验分布 $\tilde P(x,y)$，精度 $\varepsilon$
**输出**：$w^*$ 及模型 $P_{w^*}(y\mid x)$

1. 选定初始点 $w^{(0)}$，取 $G_0$ 为正定对称矩阵（通常取单位阵 $I$），置 $k=0$；
2. 计算 $g_k=g(w^{(k)})$。若 $\lVert g_k\rVert<\varepsilon$，停止，得 $w^*=w^{(k)}$；
3. 计算搜索方向（**无需解方程**）：

$$
p_k=-G_kg_k；
$$

4. 一维搜索：求 $\lambda_k$ 使

$$
f\bigl(w^{(k)}+\lambda_kp_k\bigr)=\min_{\lambda\ge0}f\bigl(w^{(k)}+\lambda p_k\bigr)；
$$

5. 置

$$
w^{(k+1)}=w^{(k)}+\lambda_kp_k；
$$

6. 计算 $g_{k+1}$。若 $\lVert g_{k+1}\rVert<\varepsilon$，停止；否则令

$$
\delta_k=w^{(k+1)}-w^{(k)},
\qquad
y_k=g_{k+1}-g_k，
$$

按 **DFP 公式**更新：

$$
\boxed{\;
G_{k+1}=G_k
+\frac{\delta_k\delta_k^\top}{\delta_k^\top y_k}
-\frac{G_ky_ky_k^\top G_k}{y_k^\top G_ky_k}
\;}
$$

7. 置 $k=k+1$，转步骤 3。

**DFP 公式的三点说明：**

**（1）满足割线方程。** 验证 $G_{k+1}y_k=\delta_k$：

$$
\begin{aligned}
G_{k+1}y_k
&=G_ky_k+\frac{\delta_k(\delta_k^\top y_k)}{\delta_k^\top y_k}
-\frac{G_ky_k(y_k^\top G_ky_k)}{y_k^\top G_ky_k}\\
&=G_ky_k+\delta_k-G_ky_k\\
&=\delta_k\ \checkmark
\end{aligned}
$$

这正是 $\nabla^2f^{-1}\Delta g\approx\Delta w$ 的离散版本。

**（2）保持正定的条件**：需要**曲率条件**

$$
\delta_k^\top y_k>0。
$$

若一维搜索满足 Wolfe 条件，该条件自动成立。因为 $f$ 是凸函数，通常能满足；实现时若发现 $\delta_k^\top y_k\le0$，应跳过本次更新。

**（3）与 BFGS 的对偶关系**。把 DFP 公式中的 $G\leftrightarrow B$、$\delta\leftrightarrow y$ 互换，就得到 BFGS 公式：

$$
B_{k+1}=B_k+\frac{y_ky_k^\top}{y_k^\top\delta_k}
-\frac{B_k\delta_k\delta_k^\top B_k}{\delta_k^\top B_k\delta_k}。
$$

两者互为**对偶**，同属 Broyden 族。

> **实践中 BFGS 通常优于 DFP**：DFP 对不精确线搜索更敏感，累积舍入误差后容易使 $G_k$ 趋于奇异。因此工业实现（如 L-BFGS）几乎都基于 BFGS 而非 DFP。

---

### 第 6 章一句话回顾

逻辑斯谛回归从"把线性打分 $w\cdot x$ 通过 sigmoid 压成概率"出发，其等价本质是**对数几率线性**；最大熵模型则从"在矩匹配约束下不做多余假设"出发，经拉格朗日对偶推出同样的指数形式——两条路线由"**对偶函数恒等于对数似然**"这一定理汇合，而最大熵的约束条件恰恰就是极大似然的梯度为零条件；由于目标函数光滑且凹，IIS、牛顿法与 L-BFGS 都能稳稳收敛到全局最优。
