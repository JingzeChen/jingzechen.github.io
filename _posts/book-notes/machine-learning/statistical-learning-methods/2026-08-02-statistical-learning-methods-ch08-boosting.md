---
title: "《统计学习方法（第 2 版）》第 8 章：提升方法"
date: 2026-08-01 02:08:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch08-boosting
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch07-support-vector-machines, statistical-learning-methods-ch09-em-algorithm]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「提升方法」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

### 0. 本章解决什么问题

前面七章都在研究**如何训练一个好模型**。本章换一个思路：

> 如果只能得到一堆**很平庸**的模型（比随机猜测略好），能不能把它们组合成一个**很强**的模型？

这就是**提升**（boosting）方法。它的哲学是"三个臭皮匠顶个诸葛亮"——但关键在于，怎样组合才能真正变强？

本章的完整逻辑链条：

```text
理论问题：弱可学习 ⟺ 强可学习？（Schapire 证明等价）
    ↓ 等价性是构造性的，意味着存在"提升"算法
两个核心问题：
  ① 每轮如何改变训练数据的权值？
  ② 如何把弱分类器组合成强分类器？
    ↓ AdaBoost 的答案
  ① 提高被错分样本的权值，降低被正确分类样本的权值
  ② 加权多数表决，误差率小的分类器权值大
    ↓ 为什么有效？
训练误差以指数速率下降（定理 8.1、8.2）
    ↓ 更深的解释是什么？
AdaBoost = 加法模型 + 指数损失 + 前向分步算法（定理 8.3）
    ↓ 换成别的损失函数呢？
提升树（平方损失→拟合残差）
    ↓ 一般损失函数怎么办？
梯度提升：用负梯度近似残差
```

**本章的两条主线**：

| 主线 | 内容 | 关键结论 |
| --- | --- | --- |
| **算法层面** | AdaBoost 怎么做 | 改权值 + 加权表决 |
| **理论层面** | AdaBoost 为什么这么做 | 它是指数损失下的前向分步算法 |

理解第二条主线尤为重要——它把 AdaBoost 从"一个巧妙的启发式"变成了"一个有明确优化目标的算法"，并直接催生了后来的 GBDT、XGBoost、LightGBM。

#### 与前几章的定位

前七章都是**单模型**方法，本章是第一个**集成学习**（ensemble learning）方法：

| 方法 | 基学习器 | 组合方式 |
| --- | --- | --- |
| 前 7 章 | 单个模型 | — |
| **本章 AdaBoost** | 弱分类器（常用决策树桩） | **串行**，加权求和 |
| Bagging / 随机森林 | 决策树 | 并行，投票平均 |

> **串行 vs 并行**是集成学习的两大流派。第 5 章提到"决策树方差大、不稳定，这正是集成方法的契机"——本章兑现了这个伏笔。Bagging 通过平均**降低方差**，Boosting 通过串行纠错**降低偏差**。

---

### 8.1 提升方法 AdaBoost 算法

#### 8.1.1 理论基础：强可学习与弱可学习

在 **PAC 学习**（Probably Approximately Correct）框架下：

| 概念 | 定义 |
| --- | --- |
| **强可学习** | 存在多项式时间算法能学习它，且**正确率很高** |
| **弱可学习** | 存在多项式时间算法能学习它，正确率**仅比随机猜测略好** |

**Kearns 与 Valiant** 提出了这两个概念并猜测二者关系；**Schapire** 后来证明：

$$
\boxed{\;\text{强可学习}\;\Longleftrightarrow\;\text{弱可学习}\;}
$$

**这个定理的意义**：

- **理论上**：两个看似差距悬殊的概念居然等价；
- **实践上**：证明是**构造性**的——它不只说"存在"，还给出了把弱学习器提升为强学习器的**方法**。

于是问题转化为：

> 已知一个"弱学习算法"，如何具体地把它 **boost** 成"强学习算法"？

**为什么这个转化有价值？** 因为**求粗糙的分类规则比求精确的分类规则容易得多**。设计一个 51% 准确率的分类器很简单（比如单层决策树桩），设计一个 99% 准确率的分类器却很难。提升方法让我们能用前者构造后者。

#### 8.1.2 两个核心问题

大多数提升方法都是**改变训练数据的权值分布**，针对不同分布反复调用弱学习算法。这带来两个问题：

**问题一：每一轮如何改变训练数据的权值分布？**

AdaBoost 的答案：

$$
\text{提高被前一轮错误分类样本的权值，降低被正确分类样本的权值}
$$

这样，没被正确分类的数据在下一轮会受到**更大关注**。分类问题被一系列弱分类器"**分而治之**"。

**问题二：如何把弱分类器组合成强分类器？**

AdaBoost 的答案：**加权多数表决**。

$$
\text{加大分类误差率小的弱分类器的权值，减小误差率大的弱分类器的权值}
$$

> AdaBoost 的巧妙之处，在于把这两个直觉**自然而有效地实现在同一个算法里**——而且后来发现，这两个看似独立的设计其实都源自同一个优化目标（8.3 节）。

#### 8.1.3 AdaBoost 算法

**算法 8.1（AdaBoost）**

**输入**：训练集 $T=\{(x_1,y_1),\ldots,(x_N,y_N)\}$，$x_i\in\mathbb R^n$，$y_i\in\{-1,+1\}$；弱学习算法
**输出**：最终分类器 $G(x)$

**（1）初始化训练数据的权值分布**

$$
D_1=(w_{11},\ldots,w_{1N}),
\qquad
w_{1i}=\frac1N,\quad i=1,\ldots,N。
$$

**（2）对 $m=1,2,\ldots,M$：**

**(a)** 使用具有权值分布 $D_m$ 的训练数据学习，得到基本分类器

$$
G_m(x):\mathcal X\to\{-1,+1\}。
$$

**(b)** 计算 $G_m(x)$ 在训练数据集上的**分类误差率**

$$
e_m=\sum_{i=1}^{N}P(G_m(x_i)\ne y_i)
=\sum_{i=1}^{N}w_{mi}\,\mathbf 1(G_m(x_i)\ne y_i)。
$$

**(c)** 计算 $G_m(x)$ 的**系数**

$$
\boxed{\;\alpha_m=\frac12\log\frac{1-e_m}{e_m}\;}
$$

（这里是自然对数。）

**(d)** 更新训练数据集的**权值分布**

$$
w_{m+1,i}=\frac{w_{mi}}{Z_m}\exp\bigl(-\alpha_my_iG_m(x_i)\bigr)，
$$

其中规范化因子

$$
Z_m=\sum_{i=1}^{N}w_{mi}\exp\bigl(-\alpha_my_iG_m(x_i)\bigr)
$$

使 $D_{m+1}$ 成为一个概率分布。

**（3）构建基本分类器的线性组合**

$$
f(x)=\sum_{m=1}^{M}\alpha_mG_m(x)，
$$

得到最终分类器

$$
G(x)=\operatorname{sign}\bigl(f(x)\bigr)
=\operatorname{sign}\left(\sum_{m=1}^{M}\alpha_mG_m(x)\right)。
$$

#### 8.1.4 算法各步的深入解读

**关于误差率 $e_m$**

由于 $\sum_i w_{mi}=1$，有

$$
e_m=\sum_{G_m(x_i)\ne y_i}w_{mi}。
$$

即：**误差率就是被误分类样本的权值之和**。这清楚地显示了权值分布 $D_m$ 与误差率的关系——同一个分类器在不同权值分布下有不同的"误差率"。

**关于系数 $\alpha_m$：三个关键性质**

$$
\alpha_m=\frac12\log\frac{1-e_m}{e_m}
$$

**性质一：$e_m\le\frac12$ 时 $\alpha_m\ge0$。**

$$
e_m\le\frac12
\;\Longrightarrow\;
\frac{1-e_m}{e_m}\ge1
\;\Longrightarrow\;
\alpha_m\ge0。
$$

> 弱分类器只要比随机猜测好（$e_m<0.5$），其权值就是正的。这正是"弱可学习"假设的作用。

**性质二：$\alpha_m$ 随 $e_m$ 减小而增大。**

$$
\frac{d\alpha_m}{de_m}
=\frac12\cdot\frac{-1}{e_m(1-e_m)}<0。
$$

所以**分类误差率越小的基本分类器，在最终分类器中作用越大**。

**性质三：极端情形**

| $e_m$ | $\alpha_m$ | 含义 |
| ---: | ---: | --- |
| $\to0$ | $\to+\infty$ | 完美分类器，权值无穷大 |
| $0.1$ | $1.099$ | 很好 |
| $0.3$ | $0.424$ | 一般 |
| $0.5$ | $0$ | 等于随机猜测，**毫无贡献** |
| $\to1$ | $\to-\infty$ | 完全反着分，取反号即可 |

**关于权值更新：误分类样本的权值被放大多少倍？**

把更新式按分类正确与否展开：

$$
w_{m+1,i}=
\begin{cases}
\dfrac{w_{mi}}{Z_m}e^{-\alpha_m},&G_m(x_i)=y_i\quad(\text{正确}),\\[2mm]
\dfrac{w_{mi}}{Z_m}e^{\alpha_m},&G_m(x_i)\ne y_i\quad(\text{错误})。
\end{cases}
$$

（因为 $y_iG_m(x_i)=+1$ 或 $-1$。）

两者之比：

$$
\frac{e^{\alpha_m}}{e^{-\alpha_m}}=e^{2\alpha_m}
=\exp\left(\log\frac{1-e_m}{e_m}\right)
=\boxed{\frac{1-e_m}{e_m}}
$$

**即：误分类样本的权值相对于正确分类样本被放大 $\dfrac{1-e_m}{e_m}$ 倍。**

例如 $e_m=0.3$ 时放大 $\frac{0.7}{0.3}\approx2.33$ 倍。$e_m$ 越小（分类器越好），被它分错的样本就越"珍贵"，放大倍数越大——这很合理，因为连好分类器都分错的样本确实更难。

> **AdaBoost 的一个特点**：不改变所给的训练数据，而是**不断改变训练数据权值的分布**，使数据在不同轮次的学习中起不同作用。

**关于最终的线性组合**

$$
f(x)=\sum_m\alpha_mG_m(x)
$$

注意：**所有 $\alpha_m$ 之和并不为 1**（不是凸组合）。

- $f(x)$ 的**符号**决定分类；
- $f(x)$ 的**绝对值**表示分类的确信度。

#### 8.1.5 例 8.1：完整计算

**训练数据**（10 个样本）：

| $i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| $x_i$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| $y_i$ | 1 | 1 | 1 | $-1$ | $-1$ | $-1$ | 1 | 1 | 1 | $-1$ |

弱分类器形如 $x<v$ 或 $x>v$（**决策树桩**），阈值使加权误差率最低。

**初始化**：$w_{1i}=0.1$，$i=1,\ldots,10$。

---

**第 1 轮**

**(a)** 阈值 $v=2.5$ 时误差率最低：

$$
G_1(x)=\begin{cases}1,&x<2.5\\-1,&x>2.5\end{cases}
$$

**(b)** 误分类的是 $x=6,7,8$（真实标签为 $1$，被判为 $-1$）：

$$
e_1=3\times0.1=0.3。
$$

**(c)**

$$
\alpha_1=\frac12\log\frac{1-0.3}{0.3}=\frac12\log\frac73=0.4236。
$$

**(d)** 更新权值。规范化因子

$$
Z_1=7\times0.1\times e^{-0.4236}+3\times0.1\times e^{0.4236}=0.9165，
$$

$$
D_2=(\underbrace{0.0714,\ldots,0.0714}_{i=1\sim6},
\underbrace{0.1667,0.1667,0.1667}_{i=7,8,9},0.0714)。
$$

误分类的三个样本（$i=7,8,9$）权值从 $0.1$ 升到 $0.1667$，其余降到 $0.0714$。

$$
f_1(x)=0.4236\,G_1(x),
\qquad
\operatorname{sign}[f_1(x)]\text{ 有 3 个误分类点}。
$$

---

**第 2 轮**

**(a)** 在权值分布 $D_2$ 下，阈值 $v=8.5$ 误差率最低：

$$
G_2(x)=\begin{cases}1,&x<8.5\\-1,&x>8.5\end{cases}
$$

**(b)** 误分类的是 $x=3,4,5$（$i=4,5,6$）：

$$
e_2=3\times0.0714=0.2143。
$$

**(c)** $\alpha_2=0.6496$

**(d)**

$$
D_3=(0.0455,0.0455,0.0455,0.1667,0.1667,0.1667,
0.1060,0.1060,0.1060,0.0455)。
$$

$$
f_2(x)=0.4236\,G_1(x)+0.6496\,G_2(x),
\qquad\text{仍有 3 个误分类点}。
$$

---

**第 3 轮**

**(a)** 阈值 $v=5.5$：

$$
G_3(x)=\begin{cases}1,&x>5.5\\-1,&x<5.5\end{cases}
$$

（注意这一轮**方向反了**。）

**(b)** 误分类的是 $x=0,1,2$（权值各 $0.0455$）和 $x=9$（权值 $0.0455$）：

$$
e_3=4\times0.0455=0.1818。
$$

**(c)** $\alpha_3=0.7520$

**(d)**

$$
D_4=(0.125,0.125,0.125,0.102,0.102,0.102,
0.065,0.065,0.065,0.125)。
$$

$$
f_3(x)=0.4236\,G_1(x)+0.6496\,G_2(x)+0.7520\,G_3(x)，
$$

$$
\operatorname{sign}[f_3(x)]\text{ 的误分类点个数为 }\boxed{0}
$$

**最终分类器**：

$$
G(x)=\operatorname{sign}\bigl[0.4236\,G_1(x)+0.6496\,G_2(x)+0.7520\,G_3(x)\bigr]。
$$

> **数值说明**：书中给出 $e_3=0.1820$、$\alpha_3=0.7514$，是因为使用了四舍五入后的 $D_3$；按完整精度计算为 $e_3=0.1818$、$\alpha_3=0.7520$。不影响结论。

**这个例子最值得注意的地方**：

**三个弱分类器单独看都很差**——每一个都至少错 3 个样本（准确率 $\le70\%$）。但它们的**加权组合**却达到 100% 准确率。

原因在于它们的**错误是互补的**：

| 分类器 | 错在哪些点 |
| --- | --- |
| $G_1$（$x<2.5$） | $x=6,7,8$ |
| $G_2$（$x<8.5$） | $x=3,4,5$ |
| $G_3$（$x>5.5$） | $x=0,1,2,9$ |

**没有任何一个点被全部三个分类器同时分错**，所以加权表决时总有多数正确。这正是权值更新机制的功劳：它**强迫后续分类器去关注前面分错的样本**。

---

### 8.2 AdaBoost 的训练误差分析

AdaBoost 最基本的性质是：**它能在学习过程中不断减少训练误差**。本节从理论上证明这一点。

#### 8.2.1 定理 8.1：训练误差界

**定理 8.1（AdaBoost 的训练误差界）**

$$
\boxed{\;
\frac1N\sum_{i=1}^{N}\mathbf 1\bigl(G(x_i)\ne y_i\bigr)
\le\frac1N\sum_{i=1}^{N}\exp\bigl(-y_if(x_i)\bigr)
=\prod_{m=1}^{M}Z_m
\;}
$$

**证明分两部分。**

**（一）前半部分：0-1 损失 $\le$ 指数损失**

当 $G(x_i)\ne y_i$ 时，$y_if(x_i)<0$（因为 $G=\operatorname{sign}(f)$），故

$$
\exp\bigl(-y_if(x_i)\bigr)>e^0=1=\mathbf 1(G(x_i)\ne y_i)。
$$

当 $G(x_i)=y_i$ 时，$\mathbf 1(\cdot)=0$，而 $\exp(-y_if(x_i))>0$。

两种情况都有

$$
\mathbf 1\bigl(G(x_i)\ne y_i\bigr)\le\exp\bigl(-y_if(x_i)\bigr)，
$$

求和即得前半部分。

> 这就是**指数损失是 0-1 损失的上界**——与第 7 章合页损失的作用完全相同，都是"代理损失"。

**（二）后半部分：指数损失均值 $=\prod_mZ_m$**

关键是把权值更新式变形：

$$
w_{m+1,i}=\frac{w_{mi}}{Z_m}\exp(-\alpha_my_iG_m(x_i))
\;\Longrightarrow\;
w_{mi}\exp(-\alpha_my_iG_m(x_i))=Z_mw_{m+1,i}。
$$

然后逐层"剥离"：

$$
\begin{aligned}
\frac1N\sum_i\exp\bigl(-y_if(x_i)\bigr)
&=\frac1N\sum_i\exp\left(-\sum_{m=1}^{M}\alpha_my_iG_m(x_i)\right)\\
&=\sum_iw_{1i}\prod_{m=1}^{M}\exp\bigl(-\alpha_my_iG_m(x_i)\bigr)
\qquad(w_{1i}=\tfrac1N)\\
&=Z_1\sum_iw_{2i}\prod_{m=2}^{M}\exp\bigl(-\alpha_my_iG_m(x_i)\bigr)\\
&=Z_1Z_2\sum_iw_{3i}\prod_{m=3}^{M}\exp\bigl(-\alpha_my_iG_m(x_i)\bigr)\\
&=\cdots\\
&=Z_1Z_2\cdots Z_{M-1}\sum_iw_{Mi}\exp\bigl(-\alpha_My_iG_M(x_i)\bigr)\\
&=\prod_{m=1}^{M}Z_m。
\end{aligned}
$$

$\blacksquare$

> **这个恒等式非常漂亮**：规范化因子 $Z_m$ 原本只是为了让权值和为 1 引入的"技术性"量，结果它们的连乘积**恰好等于**训练集上的平均指数损失。
>
> **推论**：每一轮应选取使 $Z_m$ **最小**的 $G_m$，从而使训练误差界下降最快。这为算法设计提供了直接指导。

**代码验证**（例 8.1 数据）：

| $m$ | $e_m$ | $Z_m$ |
| ---: | ---: | ---: |
| 1 | 0.3000 | 0.916515 |
| 2 | 0.2143 | 0.820652 |
| 3 | 0.1818 | 0.771389 |

$$
\prod_mZ_m=0.580193
=\frac1N\sum_ie^{-y_if(x_i)}\ \checkmark
$$

实际训练误差 $=0\le0.580193$ ✓

#### 8.2.2 $\alpha_m$ 公式的来历

定理 8.1 告诉我们要**最小化 $Z_m$**。这正好可以推出 $\alpha_m$ 的公式——这比书中通过前向分步算法的推导更直接。

把 $Z_m$ 按分类正确与否拆开：

$$
\begin{aligned}
Z_m&=\sum_{i=1}^{N}w_{mi}\exp\bigl(-\alpha y_iG_m(x_i)\bigr)\\
&=\sum_{y_i=G_m(x_i)}w_{mi}e^{-\alpha}
+\sum_{y_i\ne G_m(x_i)}w_{mi}e^{\alpha}\\
&=(1-e_m)e^{-\alpha}+e_me^{\alpha}。
\end{aligned}
$$

对 $\alpha$ 求导并令为零：

$$
\frac{dZ_m}{d\alpha}=-(1-e_m)e^{-\alpha}+e_me^{\alpha}=0，
$$

$$
e^{2\alpha}=\frac{1-e_m}{e_m}
\quad\Longrightarrow\quad
\boxed{\alpha_m=\frac12\log\frac{1-e_m}{e_m}}
$$

**二阶导数** $\frac{d^2Z_m}{d\alpha^2}=(1-e_m)e^{-\alpha}+e_me^{\alpha}>0$，故确为极小值。

> **所以 $\alpha_m$ 不是拍脑袋定的**，而是"使训练误差界下降最快"的最优解。AdaBoost 的每一个设计细节都有明确的优化依据。

#### 8.2.3 定理 8.2：二分类的具体界

**定理 8.2**

$$
\prod_{m=1}^{M}Z_m
=\prod_{m=1}^{M}\left[2\sqrt{e_m(1-e_m)}\right]
=\prod_{m=1}^{M}\sqrt{1-4\gamma_m^2}
\le\exp\left(-2\sum_{m=1}^{M}\gamma_m^2\right)，
$$

其中 $\gamma_m=\frac12-e_m$。

**证明。**

**（一）$Z_m$ 的闭式**。把最优 $\alpha_m$ 代回：

$$
e^{-\alpha_m}=\sqrt{\frac{e_m}{1-e_m}},
\qquad
e^{\alpha_m}=\sqrt{\frac{1-e_m}{e_m}}，
$$

$$
\begin{aligned}
Z_m&=(1-e_m)\sqrt{\frac{e_m}{1-e_m}}+e_m\sqrt{\frac{1-e_m}{e_m}}\\
&=\sqrt{e_m(1-e_m)}+\sqrt{e_m(1-e_m)}\\
&=2\sqrt{e_m(1-e_m)}。
\end{aligned}
$$

**（二）用 $\gamma_m$ 改写**。令 $e_m=\frac12-\gamma_m$：

$$
\begin{aligned}
4e_m(1-e_m)
&=4\left(\frac12-\gamma_m\right)\left(\frac12+\gamma_m\right)\\
&=4\left(\frac14-\gamma_m^2\right)=1-4\gamma_m^2，
\end{aligned}
$$

故 $Z_m=\sqrt{1-4\gamma_m^2}$。

**（三）不等式**。由 $e^x$ 与 $\sqrt{1-x}$ 在 $x=0$ 处的泰勒展开：

$$
\sqrt{1-4\gamma_m^2}\le\exp\left(-2\gamma_m^2\right)。
$$

> **验证方法**：令 $u=4\gamma_m^2\in[0,1]$，需证 $\sqrt{1-u}\le e^{-u/2}$，即 $\ln(1-u)\le-u$，这正是熟知的 $\ln(1+t)\le t$（取 $t=-u$）。

连乘即得定理。$\blacksquare$

**代码验证**：三个恒等式在例 8.1 上完全吻合：

| $m$ | $Z_m$ | $2\sqrt{e_m(1-e_m)}$ | $\sqrt{1-4\gamma_m^2}$ |
| ---: | ---: | ---: | ---: |
| 1 | 0.916515 | 0.916515 | 0.916515 |
| 2 | 0.820652 | 0.820652 | 0.820652 |
| 3 | 0.771389 | 0.771389 | 0.771389 |

#### 8.2.4 推论 8.1：指数速率下降

**推论 8.1** 若存在 $\gamma>0$，对所有 $m$ 有 $\gamma_m\ge\gamma$，则

$$
\boxed{\;
\frac1N\sum_{i=1}^{N}\mathbf 1\bigl(G(x_i)\ne y_i\bigr)
\le\exp\bigl(-2M\gamma^2\bigr)
\;}
$$

**这表明 AdaBoost 的训练误差以指数速率下降。**

**理解这个结论**：

| $\gamma$ | 弱分类器准确率 | 使误差 $<0.01$ 所需轮数 $M$ |
| ---: | ---: | ---: |
| $0.05$ | $55\%$ | $\approx922$ |
| $0.1$ | $60\%$ | $\approx231$ |
| $0.2$ | $70\%$ | $\approx58$ |

即使弱分类器只有 55% 的准确率（比抛硬币好一点点），也只需约 900 轮就能把训练误差压到 1% 以下。

**关键前提**：$\gamma_m\ge\gamma>0$ 必须对**所有** $m$ 成立，即弱学习器**始终**比随机猜测好一个固定的量。若某轮 $e_m\to0.5$（即 $\gamma_m\to0$），界就失效了——8.8 节习题 8.1 会看到这种情况的实例。

**AdaBoost 名称的由来**：

> 算法**不需要预先知道** $\gamma$ 的下界，它能**自适应**（Adaptive）于各个弱分类器的实际误差率。这正是 **Ada**Boost 中 "Ada" 的含义。

这与早期提升方法（需要预设 $\gamma$）形成对比，是 Freund 与 Schapire 的重要贡献。

---

### 8.3 AdaBoost 的解释：前向分步算法

上一节证明了 AdaBoost **有效**，但还没回答一个更根本的问题：

> AdaBoost 那些看似巧妙的设计（指数形式的权值更新、对数形式的系数），到底**从哪里来**？

答案是：

$$
\boxed{\;
\text{AdaBoost}=\underbrace{\text{加法模型}}_{\text{模型}}
+\underbrace{\text{指数损失}}_{\text{策略}}
+\underbrace{\text{前向分步算法}}_{\text{算法}}
\;}
$$

#### 8.3.1 加法模型与前向分步算法

**加法模型**（additive model）：

$$
f(x)=\sum_{m=1}^{M}\beta_mb(x;\gamma_m)，
$$

其中 $b(x;\gamma_m)$ 是**基函数**，$\gamma_m$ 是基函数参数，$\beta_m$ 是系数。

AdaBoost 的 $f(x)=\sum_m\alpha_mG_m(x)$ 正是加法模型。

**学习问题**：给定损失函数 $L$，极小化经验风险

$$
\min_{\{\beta_m,\gamma_m\}}\;
\sum_{i=1}^{N}L\left(y_i,\;\sum_{m=1}^{M}\beta_mb(x_i;\gamma_m)\right)。
$$

**这是一个非常复杂的优化问题**——要同时确定 $2M$ 组参数，且它们相互耦合。

**前向分步算法的想法**：

> 既然学的是加法模型，那就**从前向后，每一步只学一个基函数及其系数**，逐步逼近目标。

每步只需优化

$$
\min_{\beta,\gamma}\;\sum_{i=1}^{N}L\bigl(y_i,\;f_{m-1}(x_i)+\beta b(x_i;\gamma)\bigr)。
$$

**算法 8.2（前向分步算法）**

**输入**：训练集 $T$，损失函数 $L(y,f(x))$，基函数集 $\{b(x;\gamma)\}$
**输出**：加法模型 $f(x)$

1. 初始化 $f_0(x)=0$；
2. 对 $m=1,2,\ldots,M$：
   - **(a)** 极小化损失函数

$$
(\beta_m,\gamma_m)=\arg\min_{\beta,\gamma}
\sum_{i=1}^{N}L\bigl(y_i,f_{m-1}(x_i)+\beta b(x_i;\gamma)\bigr)；
$$

   - **(b)** 更新

$$
f_m(x)=f_{m-1}(x)+\beta_mb(x;\gamma_m)；
$$

3. 得到

$$
f(x)=f_M(x)=\sum_{m=1}^{M}\beta_mb(x;\gamma_m)。
$$

**核心思想**：把"同时求解 $M$ 组参数"的问题，简化为"**逐次**求解各组参数"。

> 这是一种**贪心**策略：每一步只考虑当前最优，不回头调整之前的 $\beta_k,\gamma_k$（$k<m$）。与第 5 章决策树的贪心生长是同一思路。

#### 8.3.2 定理 8.3：AdaBoost 是前向分步算法的特例

**定理 8.3** AdaBoost 算法是前向分步加法算法的特例。此时模型是由基本分类器组成的加法模型，**损失函数是指数函数**：

$$
L(y,f(x))=\exp\bigl[-yf(x)\bigr]。
$$

**证明。** 设经过 $m-1$ 轮已得到 $f_{m-1}(x)$，第 $m$ 轮要求

$$
(\alpha_m,G_m)=\arg\min_{\alpha,G}
\sum_{i=1}^{N}\exp\Bigl[-y_i\bigl(f_{m-1}(x_i)+\alpha G(x_i)\bigr)\Bigr]。
$$

**关键一步**：把指数拆开

$$
\exp\bigl[-y_i(f_{m-1}(x_i)+\alpha G(x_i))\bigr]
=\underbrace{\exp\bigl[-y_if_{m-1}(x_i)\bigr]}_{\triangleq\;\bar w_{mi}}
\cdot\exp\bigl[-y_i\alpha G(x_i)\bigr]。
$$

于是目标变为

$$
(\alpha_m,G_m)=\arg\min_{\alpha,G}
\sum_{i=1}^{N}\bar w_{mi}\exp\bigl[-y_i\alpha G(x_i)\bigr]。
$$

**注意**：$\bar w_{mi}=\exp[-y_if_{m-1}(x_i)]$ 既不依赖 $\alpha$ 也不依赖 $G$，与本轮最小化无关；但它依赖 $f_{m-1}$，**随每轮迭代而改变**——这就是"样本权值"的来源！

**第一步：求 $G_m(x)$**

对任意 $\alpha>0$，注意到

$$
\exp\bigl[-y_i\alpha G(x_i)\bigr]=
\begin{cases}
e^{-\alpha},&y_i=G(x_i)\\
e^{\alpha},&y_i\ne G(x_i)
\end{cases}
$$

因为 $e^{\alpha}>e^{-\alpha}$，要使总和最小，应让**被误分类的样本权值和最小**：

$$
G_m(x)=\arg\min_G\sum_{i=1}^{N}\bar w_{mi}\,\mathbf 1\bigl(y_i\ne G(x_i)\bigr)。
$$

$$
\boxed{\;\text{这正是 AdaBoost 中"使加权误差率最小的基本分类器"}\;}
$$

**第二步：求 $\alpha_m$**

把目标函数改写（与 8.2.2 节同样的技巧）：

$$
\begin{aligned}
\sum_i\bar w_{mi}e^{-y_i\alpha G(x_i)}
&=\sum_{y_i=G(x_i)}\bar w_{mi}e^{-\alpha}
+\sum_{y_i\ne G(x_i)}\bar w_{mi}e^{\alpha}\\
&=\left(e^{\alpha}-e^{-\alpha}\right)
\sum_i\bar w_{mi}\mathbf 1\bigl(y_i\ne G(x_i)\bigr)
+e^{-\alpha}\sum_i\bar w_{mi}。
\end{aligned}
$$

把已求得的 $G_m$ 代入，对 $\alpha$ 求导并令为零，得

$$
\alpha_m=\frac12\log\frac{1-e_m}{e_m}，
$$

其中

$$
e_m=\frac{\sum_i\bar w_{mi}\mathbf 1(y_i\ne G_m(x_i))}{\sum_i\bar w_{mi}}
$$

是**归一化后**的加权分类误差率。

$$
\boxed{\;\text{这与 AdaBoost 第 2(c) 步的 }\alpha_m\text{ 完全一致}\;}
$$

**第三步：权值更新**

由 $f_m(x)=f_{m-1}(x)+\alpha_mG_m(x)$ 及 $\bar w_{mi}=\exp[-y_if_{m-1}(x_i)]$：

$$
\begin{aligned}
\bar w_{m+1,i}
&=\exp\bigl[-y_if_m(x_i)\bigr]\\
&=\exp\bigl[-y_i\bigl(f_{m-1}(x_i)+\alpha_mG_m(x_i)\bigr)\bigr]\\
&=\bar w_{mi}\exp\bigl[-y_i\alpha_mG_m(x_i)\bigr]。
\end{aligned}
$$

$$
\boxed{\;\text{这与 AdaBoost 第 2(d) 步只相差规范化因子 }Z_m\;}
$$

而规范化不影响 $\arg\min$（因为它对所有样本是同一个正常数），故两者**等价**。$\blacksquare$

#### 8.3.3 这个定理的意义

**（1）AdaBoost 不再神秘。** 它的每一步都是明确优化目标的必然结果：

| AdaBoost 的"巧妙设计" | 其实是 |
| --- | --- |
| 样本权值 $w_{mi}$ | $\exp[-y_if_{m-1}(x_i)]$，即当前模型在该样本上的指数损失 |
| 提高误分类样本权值 | 指数损失对错分样本本来就大 |
| $\alpha_m=\frac12\log\frac{1-e_m}{e_m}$ | 一维搜索的解析解 |
| 加权表决 | 加法模型的必然形式 |

**（2）权值的真正含义**：

$$
w_{mi}\propto\exp\bigl[-y_if_{m-1}(x_i)\bigr]
$$

即"**当前集成模型在样本 $i$ 上的损失**"。损失大（分得差）的样本权值大——所以下一个分类器会重点关注它们。这比"提高错分样本权值"的直觉描述更精确。

**（3）打开了推广的大门**：

$$
\text{换损失函数}\;\Longrightarrow\;\text{新的提升算法}
$$

| 损失函数 | 得到的算法 |
| --- | --- |
| 指数损失 $e^{-yf}$ | **AdaBoost** |
| 平方损失 $(y-f)^2$ | **回归提升树**（8.4 节） |
| 对数损失 $\log(1+e^{-yf})$ | LogitBoost |
| 任意可微损失 | **梯度提升**（8.4.3 节） |

#### 8.3.4 指数损失的性质：AdaBoost 在估计什么？

一个自然的问题：指数损失的**理论最优解**是什么？

固定 $x$，最小化条件期望：

$$
\mathbb E\bigl[e^{-yf(x)}\mid x\bigr]
=P(y=1\mid x)e^{-f(x)}+P(y=-1\mid x)e^{f(x)}。
$$

对 $f$ 求导并令为零：

$$
-P(y=1\mid x)e^{-f}+P(y=-1\mid x)e^{f}=0，
$$

$$
e^{2f}=\frac{P(y=1\mid x)}{P(y=-1\mid x)}，
$$

$$
\boxed{\;
f^*(x)=\frac12\log\frac{P(y=1\mid x)}{P(y=-1\mid x)}
\;}
$$

**两个重要结论**：

**（1）AdaBoost 拟合的是对数几率的一半。**

回顾第 6 章：逻辑斯谛回归建模的正是 $\log\dfrac{P(y=1\mid x)}{P(y=-1\mid x)}=w\cdot x$。所以

$$
\text{AdaBoost 与逻辑斯谛回归在估计同一个量（相差一个因子 2）}
$$

这解释了为什么可以用

$$
\hat P(y=1\mid x)=\frac{1}{1+e^{-2f(x)}}
$$

把 AdaBoost 的输出转成概率。

**（2）$\operatorname{sign}(f^*)$ 是贝叶斯最优分类器。**

$$
f^*(x)>0
\;\Longleftrightarrow\;
P(y=1\mid x)>P(y=-1\mid x)
$$

正是第 4 章的后验最大化准则。所以**指数损失是"分类校准"的**（classification-calibrated）——最小化它能收敛到贝叶斯最优分类器。

**（3）指数损失的缺点：对噪声敏感。**

代码计算的损失对比（$z=yf(x)$）：

| $z$ | 0-1 | 合页 | 逻辑斯谛 | **指数** |
| ---: | ---: | ---: | ---: | ---: |
| $-3$ | 1.00 | 4.00 | 3.05 | **20.09** |
| $-2$ | 1.00 | 3.00 | 2.13 | **7.39** |
| $-1$ | 1.00 | 2.00 | 1.31 | **2.72** |
| $0$ | 1.00 | 1.00 | 0.69 | 1.00 |
| $+1$ | 0.00 | 0.00 | 0.31 | 0.37 |
| $+2$ | 0.00 | 0.00 | 0.13 | 0.14 |

指数损失随错误程度**指数增长**，远快于合页损失（线性）和逻辑斯谛损失（渐近线性）。

**后果**：若数据中有**标签噪声**（本该是 $+1$ 却标成 $-1$），AdaBoost 会不断给它加权，最终可能被一个错误标签"带偏"。这是 AdaBoost 的主要弱点。

> **改进方向**：LogitBoost 用对数损失、GentleBoost 用平方损失，都是为了降低对噪声的敏感度。

---

### 8.4 提升树

#### 8.4.1 提升树模型

以**决策树**为基函数的提升方法称为**提升树**（boosting tree）：

$$
f_M(x)=\sum_{m=1}^{M}T(x;\Theta_m)，
$$

其中 $T(x;\Theta_m)$ 表示决策树，$\Theta_m$ 为树的参数。

- 分类问题：二叉**分类**树；
- 回归问题：二叉**回归**树。

> 例 8.1 中的基本分类器 $x<v$ 或 $x>v$，就是只有一个根结点直接连两个叶结点的最简单决策树，称为**决策树桩**（decision stump）。

**注意**：这里系数固定为 1（吸收进树的输出值中），不像 AdaBoost 那样显式写 $\alpha_m$。

**分类问题的提升树**：只需把 AdaBoost 中的基本分类器限制为二类分类树即可，是 AdaBoost 的特例。

下面重点讨论**回归**提升树。

#### 8.4.2 回归提升树：为什么是拟合残差

回归树可表示为

$$
T(x;\Theta)=\sum_{j=1}^{J}c_j\,\mathbf 1(x\in R_j)，
$$

其中 $\Theta=\{(R_1,c_1),\ldots,(R_J,c_J)\}$ 表示区域划分与各区域的常数，$J$ 是叶结点个数。

前向分步算法第 $m$ 步要求解

$$
\hat\Theta_m=\arg\min_{\Theta_m}
\sum_{i=1}^{N}L\bigl(y_i,f_{m-1}(x_i)+T(x_i;\Theta_m)\bigr)。
$$

**采用平方误差损失时**：

$$
L(y,f(x))=\bigl(y-f(x)\bigr)^2，
$$

代入得

$$
\begin{aligned}
L\bigl(y,f_{m-1}(x)+T(x;\Theta_m)\bigr)
&=\bigl[y-f_{m-1}(x)-T(x;\Theta_m)\bigr]^2\\
&=\bigl[\underbrace{r}_{\text{残差}}-T(x;\Theta_m)\bigr]^2，
\end{aligned}
$$

其中

$$
\boxed{\;r=y-f_{m-1}(x)\;}
$$

是**当前模型拟合数据的残差**（residual）。

$$
\boxed{\;
\text{结论：平方损失下，每一步只需拟合当前模型的残差}
\;}
$$

**这个结论极其简洁优美**。它把"最小化复杂的组合损失"变成了"用普通回归树拟合一列新的目标值"——而拟合回归树的方法第 5 章已经讲过了。

**算法 8.3（回归问题的提升树算法）**

1. 初始化 $f_0(x)=0$；
2. 对 $m=1,2,\ldots,M$：
   - **(a)** 计算残差

$$
r_{mi}=y_i-f_{m-1}(x_i),\quad i=1,\ldots,N；
$$

   - **(b)** 拟合残差 $r_{mi}$ 学习一个回归树，得到 $T(x;\Theta_m)$；
   - **(c)** 更新 $f_m(x)=f_{m-1}(x)+T(x;\Theta_m)$；
3. 得到

$$
f_M(x)=\sum_{m=1}^{M}T(x;\Theta_m)。
$$

**直觉**：

```text
第 1 棵树：粗略拟合 y          → 剩下残差 r₁
第 2 棵树：拟合 r₁            → 剩下残差 r₂
第 3 棵树：拟合 r₂            → 剩下残差 r₃
...
每棵树都在"纠正"前面所有树的累积错误
```

#### 8.4.3 例 8.2：回归提升树完整计算

**训练数据**：

| $x_i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| $y_i$ | 5.56 | 5.70 | 5.91 | 6.40 | 6.80 | 7.05 | 8.90 | 8.70 | 9.00 | 9.05 |

只用**树桩**作为基函数。

**第 1 步：求 $T_1(x)$**

对每个切分点 $s$，计算

$$
m(s)=\min_{c_1}\sum_{x_i\in R_1}(y_i-c_1)^2
+\min_{c_2}\sum_{x_i\in R_2}(y_i-c_2)^2，
$$

其中 $R_1=\{x\le s\}$，$R_2=\{x>s\}$，最优 $c_1,c_2$ 为各区域均值（第 5 章已证）。

| $s$ | 1.5 | 2.5 | 3.5 | 4.5 | 5.5 | **6.5** | 7.5 | 8.5 | 9.5 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| $m(s)$ | 15.72 | 12.07 | 8.36 | 5.78 | 3.91 | **1.93** | 8.01 | 11.73 | 15.74 |

$s=6.5$ 时 $m(s)$ 最小。此时 $R_1=\{1,\ldots,6\}$，$R_2=\{7,8,9,10\}$：

$$
c_1=\frac{5.56+5.70+5.91+6.40+6.80+7.05}{6}=6.24，
$$

$$
c_2=\frac{8.90+8.70+9.00+9.05}{4}=8.91。
$$

$$
T_1(x)=\begin{cases}6.24,&x<6.5\\8.91,&x\ge6.5\end{cases}
\qquad
f_1(x)=T_1(x)。
$$

**残差**（$r_{2i}=y_i-f_1(x_i)$）：

| $i$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| $r_{2i}$ | $-0.68$ | $-0.54$ | $-0.33$ | $0.16$ | $0.56$ | $0.81$ | $-0.01$ | $-0.21$ | $0.09$ | $0.14$ |

$$
L(y,f_1)=\sum_i\bigl(y_i-f_1(x_i)\bigr)^2=1.93。
$$

**后续各步**（方法相同，只是拟合对象换成残差）：

| $m$ | $T_m(x)$ | $L(y,f_m)$ |
| ---: | --- | ---: |
| 1 | $6.24\;(x<6.5),\;8.91\;(x\ge6.5)$ | $1.93$ |
| 2 | $-0.52\;(x<3.5),\;0.22\;(x\ge3.5)$ | $0.79$ |
| 3 | $0.15\;(x<6.5),\;-0.22\;(x\ge6.5)$ | $0.47$ |
| 4 | $-0.16\;(x<4.5),\;0.11\;(x\ge4.5)$ | $0.30$ |
| 5 | $0.07\;(x<6.5),\;-0.11\;(x\ge6.5)$ | $0.23$ |
| 6 | $-0.15\;(x<2.5),\;0.04\;(x\ge2.5)$ | $0.17$ |

**最终模型**：

$$
f_6(x)=T_1(x)+\cdots+T_6(x)=
\begin{cases}
5.63,&x<2.5\\
5.82,&2.5\le x<3.5\\
6.56,&3.5\le x<4.5\\
6.83,&4.5\le x<6.5\\
8.95,&x\ge6.5
\end{cases}
$$

**观察损失下降过程**：

$$
1.93\to0.79\to0.47\to0.30\to0.23\to0.17
$$

每一棵新树都在减小残差，但**下降幅度递减**——这是典型的提升行为：前几棵树抓住主要结构，后面的树做精细修正。

> **数值说明**：书中在每一步都把残差**四舍五入到两位小数**再继续，因此后续数值与完整精度计算略有出入（例如 $T_2$ 的系数精确值为 $-0.51$ 而非 $-0.52$，$L(y,f_2)$ 精确值为 $0.80$ 而非 $0.79$）。代码验证部分给出的是完整精度结果。这不影响对算法的理解。

#### 8.4.4 梯度提升

**问题**：平方损失和指数损失下每步优化很简单，但**一般损失函数**怎么办？

例如绝对损失 $|y-f|$、Huber 损失等，每步的

$$
\min_{\Theta}\sum_iL\bigl(y_i,f_{m-1}(x_i)+T(x_i;\Theta)\bigr)
$$

没有简单解法。

**Friedman 的答案：梯度提升**（gradient boosting）。

**核心洞察**。回顾平方损失（这里用 $\frac12(y-f)^2$ 便于求导）：

$$
-\frac{\partial L(y,f)}{\partial f}
=-\frac{\partial}{\partial f}\cdot\frac12(y-f)^2
=y-f=r。
$$

$$
\boxed{\;\text{负梯度}=\text{残差}\;}
$$

所以"拟合残差"其实是"**拟合负梯度**"的特例！

**推广**：对一般损失函数，用**负梯度在当前模型的值**作为残差的近似：

$$
r_{mi}=-\left[\frac{\partial L(y_i,f(x_i))}{\partial f(x_i)}\right]_{f(x)=f_{m-1}(x)}。
$$

**为什么这样合理？** 这是**最速下降法**在函数空间中的应用：

- 参数空间的梯度下降：$\theta\leftarrow\theta-\eta\nabla_\theta L$；
- **函数空间**的梯度下降：$f\leftarrow f-\eta\nabla_fL$。

但 $f$ 是一个函数，不能直接"减去梯度"。解决办法是**用一棵回归树去拟合负梯度**，再把这棵树加到模型上。

$$
\text{梯度提升}=\text{函数空间中的梯度下降}
$$

**算法 8.4（梯度提升算法）**

**输入**：训练集 $T$，损失函数 $L(y,f(x))$
**输出**：回归树 $\hat f(x)$

**（1）初始化**

$$
f_0(x)=\arg\min_c\sum_{i=1}^{N}L(y_i,c)。
$$

> 这是只有一个根结点的树，即最优常数预测。平方损失下是均值，绝对损失下是中位数。

**（2）对 $m=1,2,\ldots,M$：**

**(a)** 计算负梯度（伪残差）

$$
r_{mi}=-\left[\frac{\partial L(y_i,f(x_i))}{\partial f(x_i)}\right]_{f=f_{m-1}},
\quad i=1,\ldots,N；
$$

**(b)** 对 $r_{mi}$ 拟合一个回归树，得到第 $m$ 棵树的叶结点区域 $R_{mj}$，$j=1,\ldots,J$；

**(c)** 对 $j=1,\ldots,J$，**线性搜索**确定叶结点的最优输出值

$$
c_{mj}=\arg\min_c\sum_{x_i\in R_{mj}}
L\bigl(y_i,f_{m-1}(x_i)+c\bigr)；
$$

**(d)** 更新

$$
f_m(x)=f_{m-1}(x)+\sum_{j=1}^{J}c_{mj}\mathbf 1(x\in R_{mj})。
$$

**（3）** 得到

$$
\hat f(x)=f_M(x)=\sum_{m=1}^{M}\sum_{j=1}^{J}c_{mj}\mathbf 1(x\in R_{mj})。
$$

**为什么要分成 (b) 和 (c) 两步？**

这是梯度提升的一个精妙设计：

- **(b) 用负梯度确定树的结构**（怎么划分区域）——负梯度指明了"往哪个方向改进"；
- **(c) 用原始损失确定叶子的取值**——负梯度只是一阶近似，直接用它做输出值不够准确，所以再做一次精确的一维优化。

平方损失下两步会给出相同结果（因为负梯度就是残差）；一般损失下 (c) 步能显著提升效果。

**常见损失的负梯度**：

| 损失函数 | $L(y,f)$ | 负梯度 $-\partial L/\partial f$ |
| --- | --- | --- |
| 平方损失 | $\frac12(y-f)^2$ | $y-f$（**残差**） |
| 绝对损失 | $\lvert y-f\rvert$ | $\operatorname{sign}(y-f)$ |
| Huber 损失 | 分段 | 残差的截断 |
| 指数损失 | $e^{-yf}$ | $ye^{-yf}$ |
| 对数损失 | $\log(1+e^{-yf})$ | $\dfrac{y}{1+e^{yf}}$ |

> **绝对损失的负梯度只有符号**（$\pm1$），完全不含幅度信息——这正是它对离群点稳健的原因：一个偏离很远的点和一个稍微偏离的点，贡献的梯度**一样大**，不会主导训练。

**梯度提升的历史地位**：

$$
\text{梯度提升}\;\to\;\text{GBDT}\;\to\;\text{XGBoost / LightGBM / CatBoost}
$$

这一系列方法至今仍是**结构化/表格数据**上最强的方法之一，在 Kaggle 等竞赛中长期占据主导地位。XGBoost 的主要改进是用**二阶泰勒展开**（同时用一阶和二阶导数）代替只用一阶梯度，并加入正则项。

---

### 8.5 代码实现与验证

```python
"""提升方法（《统计学习方法》第 8 章）：AdaBoost / 提升树 / 梯度提升"""
import math


def stump_predict(j, v, direction, x):
    """决策树桩：direction='lt' 表示 x[j]<v 判为 +1，'gt' 反之"""
    if direction == 'lt':
        return 1 if x[j] < v else -1
    return -1 if x[j] < v else 1


def candidate_stumps(X, include_constant=False):
    """生成所有候选树桩。include_constant 决定是否允许"恒定输出"的退化树桩"""
    n_feat = len(X[0])
    out = []
    for j in range(n_feat):
        vals = sorted(set(x[j] for x in X))
        cands = [(vals[k] + vals[k + 1]) / 2 for k in range(len(vals) - 1)]
        if include_constant:                    # 两端加候选 → 产生常值分类器
            cands = [vals[0] - 0.5] + cands + [vals[-1] + 0.5]
        for v in cands:
            out.append((j, v, 'lt'))
            out.append((j, v, 'gt'))
    return out


class AdaBoost:
    def __init__(self, X, Y, include_constant=False):
        self.X, self.Y = X, Y
        self.N = len(Y)
        self.stumps = candidate_stumps(X, include_constant)
        self.alphas, self.chosen, self.Zs = [], [], []

    def _best_stump(self, w):
        """在当前权值分布下选加权误差率最小的树桩"""
        best = None
        for (j, v, d) in self.stumps:
            e = sum(w[i] for i in range(self.N)
                    if stump_predict(j, v, d, self.X[i]) != self.Y[i])
            if best is None or e < best[0] - 1e-15:
                best = (e, j, v, d)
        return best

    def f(self, x):
        """f(x) = Σ α_m G_m(x)"""
        return sum(a * stump_predict(*s, x)
                   for a, s in zip(self.alphas, self.chosen))

    def train_error(self):
        return sum(1 for i in range(self.N)
                   if (1 if self.f(self.X[i]) >= 0 else -1) != self.Y[i])

    def fit(self, M, verbose=True):
        w = [1.0 / self.N] * self.N              # 步骤(1) 初始化权值
        for m in range(1, M + 1):
            e, j, v, d = self._best_stump(w)     # 步骤(2a) 学习基本分类器
            if e < 1e-12:
                e = 1e-12
            alpha = 0.5 * math.log((1 - e) / e)  # 步骤(2c) 计算系数
            # 步骤(2d) 更新权值分布
            Z = sum(w[i] * math.exp(-alpha * self.Y[i]
                                    * stump_predict(j, v, d, self.X[i]))
                    for i in range(self.N))
            w = [w[i] * math.exp(-alpha * self.Y[i]
                                 * stump_predict(j, v, d, self.X[i])) / Z
                 for i in range(self.N)]
            self.alphas.append(alpha)
            self.chosen.append((j, v, d))
            self.Zs.append(Z)
            if verbose:
                op = '<' if d == 'lt' else '>='
                print(f"  m={m}: [x{j} {op} {v}]  e={e:.4f}  α={alpha:.4f}  "
                      f"Z={Z:.6f}  训练误分类={self.train_error()}")
            if self.train_error() == 0:
                if verbose:
                    print(f"  => 训练误差降为 0（M={m}）")
                break
        return self

    def exp_loss(self):
        """平均指数损失 (1/N)Σ exp(-y_i f(x_i))"""
        return sum(math.exp(-self.Y[i] * self.f(self.X[i]))
                   for i in range(self.N)) / self.N


def best_regression_stump(xs, targets):
    """拟合一维回归树桩，返回 (最小平方误差, 切分点, 左值, 右值)"""
    n = len(xs)
    vals = sorted(set(xs))
    best = None
    for k in range(len(vals) - 1):
        s = (vals[k] + vals[k + 1]) / 2
        L = [targets[i] for i in range(n) if xs[i] < s]
        R = [targets[i] for i in range(n) if xs[i] >= s]
        c1, c2 = sum(L) / len(L), sum(R) / len(R)
        m = sum((t - c1) ** 2 for t in L) + sum((t - c2) ** 2 for t in R)
        if best is None or m < best[0] - 1e-12:
            best = (m, s, c1, c2)
    return best


def boosting_tree(xs, ys, M, verbose=True):
    """算法 8.3：回归问题的提升树（平方损失 → 拟合残差）"""
    n = len(xs)
    f = [0.0] * n
    trees = []
    for m in range(1, M + 1):
        r = [ys[i] - f[i] for i in range(n)]          # (a) 计算残差
        _, s, c1, c2 = best_regression_stump(xs, r)   # (b) 拟合残差
        f = [f[i] + (c1 if xs[i] < s else c2) for i in range(n)]  # (c) 更新
        loss = sum((ys[i] - f[i]) ** 2 for i in range(n))
        trees.append((s, c1, c2))
        if verbose:
            print(f"  T{m}(x): {c1:+.2f} (x<{s}), {c2:+.2f} (x>={s})"
                  f"    L(y,f{m}) = {loss:.4f}")
    return f, trees


def gradient_boosting(xs, ys, M, loss='squared', verbose=True):
    """算法 8.4：梯度提升。loss ∈ {'squared', 'absolute'}"""
    n = len(xs)
    if loss == 'squared':
        f0 = sum(ys) / n                                  # 初始化：均值
        neg_grad = lambda y, fv: y - fv                   # 负梯度 = 残差
        best_c = lambda vals: sum(vals) / len(vals)       # 叶子最优值：均值
        loss_fn = lambda y, fv: (y - fv) ** 2 / 2
    else:                                                 # 绝对损失
        srt = sorted(ys)
        f0 = srt[n // 2]                                  # 初始化：中位数
        neg_grad = lambda y, fv: (1.0 if y > fv else (-1.0 if y < fv else 0.0))
        best_c = lambda vals: sorted(vals)[len(vals) // 2]  # 叶子最优值：中位数
        loss_fn = lambda y, fv: abs(y - fv)

    f = [f0] * n
    for m in range(1, M + 1):
        r = [neg_grad(ys[i], f[i]) for i in range(n)]     # (a) 负梯度
        _, s, _, _ = best_regression_stump(xs, r)         # (b) 拟合负梯度定结构
        left = [i for i in range(n) if xs[i] < s]         # (c) 线性搜索定叶子值
        right = [i for i in range(n) if xs[i] >= s]
        c1 = best_c([ys[i] - f[i] for i in left])
        c2 = best_c([ys[i] - f[i] for i in right])
        f = [f[i] + (c1 if xs[i] < s else c2) for i in range(n)]   # (d) 更新
        if verbose:
            total = sum(loss_fn(ys[i], f[i]) for i in range(n))
            print(f"  m={m}: 切分 x<{s}  c=({c1:+.3f}, {c2:+.3f})  "
                  f"损失={total:.4f}")
    return f


def show(title):
    print("\n" + "=" * 60)
    print(title)
    print("=" * 60)


show("【例 8.1】AdaBoost")
X1 = [(i,) for i in range(10)]
Y1 = [1, 1, 1, -1, -1, -1, 1, 1, 1, -1]
ada = AdaBoost(X1, Y1).fit(M=10)
print("  最终 f(x) = " +
      " + ".join(f"{a:.4f}·G{k+1}(x)" for k, a in enumerate(ada.alphas)))

show("【定理 8.1 / 8.2】训练误差界")
prod_Z = 1.0
print("   m      e_m        Z_m      2√(e(1-e))   √(1-4γ²)")
w = [0.1] * 10
tmp = AdaBoost(X1, Y1)
for m, (a, s, Z) in enumerate(zip(ada.alphas, ada.chosen, ada.Zs), 1):
    e = 1 / (1 + math.exp(2 * a))          # 由 α 反解 e
    gamma = 0.5 - e
    print(f"   {m}   {e:.6f}   {Z:.6f}   {2*math.sqrt(e*(1-e)):.6f}   "
          f"{math.sqrt(1-4*gamma**2):.6f}")
    prod_Z *= Z
print(f"\n  实际训练误差     = {ada.train_error()/len(Y1):.6f}")
print(f"  平均指数损失     = {ada.exp_loss():.6f}")
print(f"  ∏ Z_m           = {prod_Z:.6f}")
print(f"  验证 训练误差 ≤ 指数损失 = ∏Z_m : "
      f"{ada.train_error()/len(Y1) <= ada.exp_loss() + 1e-12}, "
      f"{abs(ada.exp_loss() - prod_Z) < 1e-9}")

show("【例 8.2】回归提升树")
xs = list(range(1, 11))
ys = [5.56, 5.70, 5.91, 6.40, 6.80, 7.05, 8.90, 8.70, 9.00, 9.05]

print("  第 1 步各切分点的 m(s)：")
line_s, line_m = [], []
for k in range(1, 10):
    s = k + 0.5
    L = [ys[i] for i in range(10) if xs[i] < s]
    R = [ys[i] for i in range(10) if xs[i] >= s]
    c1, c2 = sum(L) / len(L), sum(R) / len(R)
    line_s.append(f"{s:6.1f}")
    line_m.append(f"{sum((t-c1)**2 for t in L) + sum((t-c2)**2 for t in R):6.2f}")
print("    s    : " + " ".join(line_s))
print("    m(s) : " + " ".join(line_m))

print("\n  逐轮拟合残差：")
f_final, _ = boosting_tree(xs, ys, M=6)
print("\n  f6(x) 各点取值：")
prev = None
for i in range(10):
    if prev is None or abs(f_final[i] - prev) > 1e-9:
        print(f"    x ≥ {xs[i]:2d} : {f_final[i]:.2f}")
        prev = f_final[i]

show("【算法 8.4】梯度提升：平方损失 vs 绝对损失（含离群点）")
ys_out = ys[:]
ys_out[4] = 20.0                       # 人为制造一个离群点
print(f"  数据：把 y[5] 从 {ys[4]} 改成 {ys_out[4]}（离群点）\n")
print("  平方损失（负梯度=残差，会追逐离群点）：")
f_sq = gradient_boosting(xs, ys_out, M=6, loss='squared')
print(f"    预测 = [{', '.join(f'{v:.2f}' for v in f_sq)}]")
print("\n  绝对损失（负梯度只有符号，稳健）：")
f_ab = gradient_boosting(xs, ys_out, M=6, loss='absolute')
print(f"    预测 = [{', '.join(f'{v:.2f}' for v in f_ab)}]")

dev_sq = sum(abs(f_sq[i] - ys[i]) for i in range(10) if i != 4)
dev_ab = sum(abs(f_ab[i] - ys[i]) for i in range(10) if i != 4)
print(f"\n  离群点处预测：平方={f_sq[4]:.2f}（追向 20）  绝对={f_ab[4]:.2f}（基本忽略）")
print(f"  9 个干净点上与真实 y 的总偏差：平方={dev_sq:.2f}   绝对={dev_ab:.2f}")

show("【损失函数对比】z = y·f(x)")
print("     z     0-1 损失   合页   逻辑斯谛    指数")
for z in [-3, -2, -1, 0, 1, 2]:
    l01 = 1.0 if z <= 0 else 0.0
    lh = max(0.0, 1 - z)
    ll = math.log(1 + math.exp(-z))
    le = math.exp(-z)
    print(f"   {z:+d}       {l01:.2f}      {lh:.2f}     {ll:.2f}     {le:8.2f}")
print("\n  指数损失增长最快 => AdaBoost 对标签噪声最敏感")

show("【习题 8.1】应聘人员数据")
X8 = [(0, 1, 3), (0, 3, 1), (1, 2, 2), (1, 1, 3), (1, 2, 3),
      (0, 1, 2), (1, 1, 2), (1, 1, 1), (1, 3, 1), (0, 2, 1)]
Y8 = [-1, -1, -1, -1, -1, -1, 1, 1, -1, -1]

print("  (A) 仅用内部切分点的树桩：")
a1 = AdaBoost(X8, Y8, include_constant=False).fit(M=15, verbose=False)
print(f"      15 轮后训练误分类数 = {a1.train_error()}")
e_last = 1 / (1 + math.exp(2 * a1.alphas[-1]))
print(f"      最后一轮 e_m = {e_last:.4f} → 趋近 0.5，弱学习假设失效")

print("\n  (B) 允许常值树桩：")
a2 = AdaBoost(X8, Y8, include_constant=True).fit(M=10)
print("\n      逐样本验证：")
for i in range(10):
    fv = a2.f(X8[i])
    p = 1 if fv >= 0 else -1
    ok = "OK" if p == Y8[i] else "ERR"
    print(f"        样本{i+1:2d} {X8[i]}  y={Y8[i]:+d}  "
          f"f(x)={fv:+.4f}  预测={p:+d}  {ok}")
```

**运行结果：**

```text
============================================================
【例 8.1】AdaBoost
============================================================
  m=1: [x0 < 2.5]  e=0.3000  α=0.4236  Z=0.916515  训练误分类=3
  m=2: [x0 < 8.5]  e=0.2143  α=0.6496  Z=0.820652  训练误分类=3
  m=3: [x0 >= 5.5]  e=0.1818  α=0.7520  Z=0.771389  训练误分类=0
  => 训练误差降为 0（M=3）
  最终 f(x) = 0.4236·G1(x) + 0.6496·G2(x) + 0.7520·G3(x)

============================================================
【定理 8.1 / 8.2】训练误差界
============================================================
   m      e_m        Z_m      2√(e(1-e))   √(1-4γ²)
   1   0.300000   0.916515   0.916515   0.916515
   2   0.214286   0.820652   0.820652   0.820652
   3   0.181818   0.771389   0.771389   0.771389

  实际训练误差     = 0.000000
  平均指数损失     = 0.580193
  ∏ Z_m           = 0.580193
  验证 训练误差 ≤ 指数损失 = ∏Z_m : True, True

============================================================
【例 8.2】回归提升树
============================================================
  第 1 步各切分点的 m(s)：
    s    :    1.5    2.5    3.5    4.5    5.5    6.5    7.5    8.5    9.5
    m(s) :  15.72  12.08   8.37   5.78   3.91   1.93   8.01  11.74  15.74

  逐轮拟合残差：
  T1(x): +6.24 (x<6.5), +8.91 (x>=6.5)    L(y,f1) = 1.9300
  T2(x): -0.51 (x<3.5), +0.22 (x>=3.5)    L(y,f2) = 0.8007
  T3(x): +0.15 (x<6.5), -0.22 (x>=6.5)    L(y,f3) = 0.4780
  T4(x): -0.16 (x<4.5), +0.11 (x>=4.5)    L(y,f4) = 0.3056
  T5(x): +0.07 (x<6.5), -0.11 (x>=6.5)    L(y,f5) = 0.2289
  T6(x): -0.15 (x<2.5), +0.04 (x>=2.5)    L(y,f6) = 0.1722

  f6(x) 各点取值：
    x ≥  1 : 5.63
    x ≥  3 : 5.82
    x ≥  4 : 6.55
    x ≥  5 : 6.82
    x ≥  7 : 8.95

============================================================
【算法 8.4】梯度提升：平方损失 vs 绝对损失（含离群点）
============================================================
  数据：把 y[5] 从 6.8 改成 20.0（离群点）

  平方损失（负梯度=残差，会追逐离群点）：
  m=1: 切分 x<4.5  c=(-2.734, +1.823)  损失=56.3477
  m=2: 切分 x<5.5  c=(+1.910, -1.910)  损失=38.1072
  m=3: 切分 x<4.5  c=(-1.910, +1.273)  损失=25.9469
  m=4: 切分 x<5.5  c=(+1.273, -1.273)  损失=17.8400
  m=5: 切分 x<4.5  c=(-1.273, +0.849)  损失=12.4354
  m=6: 切分 x<5.5  c=(+0.849, -0.849)  损失=8.8324
    预测 = [6.74, 6.74, 6.74, 6.74, 16.60, 8.54, 8.54, 8.54, 8.54, 8.54]

  绝对损失（负梯度只有符号，稳健）：
  m=1: 切分 x<4.5  c=(-2.790, +0.300)  损失=14.4500
  m=2: 切分 x<2.5  c=(-0.210, +0.000)  损失=14.0300
  m=3: 切分 x<9.5  c=(+0.000, +0.050)  损失=13.9800
  m=4: 切分 x<5.5  c=(+0.000, -0.100)  损失=13.8800
  m=5: 切分 x<8.5  c=(+0.000, +0.100)  损失=13.6800
  m=6: 切分 x<1.5  c=(-0.140, +0.000)  损失=13.5400
    预测 = [5.56, 5.70, 5.91, 5.91, 9.00, 8.90, 8.90, 8.90, 9.00, 9.05]

  离群点处预测：平方=16.60（追向 20）  绝对=9.00（基本忽略）
  9 个干净点上与真实 y 的总偏差：平方=6.38   绝对=2.54

============================================================
【损失函数对比】z = y·f(x)
============================================================
     z     0-1 损失   合页   逻辑斯谛    指数
   -3       1.00      4.00     3.05        20.09
   -2       1.00      3.00     2.13         7.39
   -1       1.00      2.00     1.31         2.72
   +0       1.00      1.00     0.69         1.00
   +1       0.00      0.00     0.31         0.37
   +2       0.00      0.00     0.13         0.14

  指数损失增长最快 => AdaBoost 对标签噪声最敏感

============================================================
【习题 8.1】应聘人员数据
============================================================
  (A) 仅用内部切分点的树桩：
      15 轮后训练误分类数 = 2
      最后一轮 e_m = 0.4530 → 趋近 0.5，弱学习假设失效

  (B) 允许常值树桩：
  m=1: [x0 < -0.5]  e=0.2000  α=0.6931  Z=0.800000  训练误分类=2
  m=2: [x1 < 1.5]  e=0.1875  α=0.7332  Z=0.780625  训练误分类=3
  m=3: [x2 < 1.5]  e=0.2692  α=0.4993  Z=0.887120  训练误分类=1
  m=4: [x0 >= 0.5]  e=0.2381  α=0.5816  Z=0.851835  训练误分类=1
  m=5: [x0 < -0.5]  e=0.2566  α=0.5319  Z=0.873490  训练误分类=1
  m=6: [x2 < 2.5]  e=0.2514  α=0.5455  Z=0.867680  训练误分类=0
  => 训练误差降为 0（M=6）

      逐样本验证：
        样本 1 (0, 1, 3)  y=-1  f(x)=-2.1182  预测=-1  OK
        样本 2 (0, 3, 1)  y=-1  f(x)=-1.4951  预测=-1  OK
        样本 3 (1, 2, 2)  y=-1  f(x)=-1.3304  预测=-1  OK
        样本 4 (1, 1, 3)  y=-1  f(x)=-0.9551  预测=-1  OK
        样本 5 (1, 2, 3)  y=-1  f(x)=-2.4214  预测=-1  OK
        样本 6 (0, 1, 2)  y=-1  f(x)=-1.0273  预测=-1  OK
        样本 7 (1, 1, 2)  y=+1  f(x)=+0.1359  预测=+1  OK
        样本 8 (1, 1, 1)  y=+1  f(x)=+1.1344  预测=+1  OK
        样本 9 (1, 3, 1)  y=-1  f(x)=-0.3319  预测=-1  OK
        样本10 (0, 2, 1)  y=-1  f(x)=-1.4951  预测=-1  OK
```

> **Windows 运行提示**：若报 `UnicodeEncodeError`，执行前设置 `$env:PYTHONIOENCODING = "utf-8"`。

**代码验证的五个结论：**

| 结论 | 证据 |
| --- | --- |
| AdaBoost 三轮达到零训练误差 | 精确复现例 8.1 的 $e_m,\alpha_m,D_m$ |
| **定理 8.1、8.2 精确成立** | $\prod Z_m=$ 指数损失均值 $=0.580193$；$Z_m=2\sqrt{e(1-e)}=\sqrt{1-4\gamma^2}$ |
| 提升树逐轮减小残差 | 损失 $1.93\to0.80\to0.48\to0.31\to0.23\to0.17$ |
| **绝对损失比平方损失稳健** | 加入离群点 $y_5=20$ 后，平方损失在该点预测被拉到 $16.60$（追向 20），绝对损失仅 $9.00$；9 个干净点上总偏差 **6.38 vs 2.54** |
| 指数损失增长最快 | $z=-3$ 时指数损失 $20.09$，远超合页 $4.00$ |

---

### 8.6 深入理解

#### 8.6.1 Boosting 与 Bagging 的对比

| | **Boosting**（本章） | **Bagging / 随机森林** |
| --- | --- | --- |
| 基学习器训练 | **串行**（后一个依赖前一个） | **并行**（相互独立） |
| 样本使用 | 改变**权值分布** | **有放回抽样**（bootstrap） |
| 基学习器 | **弱**学习器（如树桩） | **强**学习器（如深树） |
| 组合方式 | 加权求和（权值不等） | 简单投票/平均（权值相等） |
| 主要降低 | **偏差** | **方差** |
| 过拟合风险 | 较高（尤其有噪声时） | 较低 |
| 并行化 | 困难 | 容易 |

**为什么 Boosting 降低偏差？** 因为每一步都在**纠正当前模型的错误**（拟合残差/负梯度），模型复杂度逐步提升，拟合能力越来越强。

**为什么 Bagging 降低方差？** 因为对 $B$ 个近似独立的模型取平均，方差降为约 $\frac1B$。

> 这也解释了基学习器的选择：Boosting 用**弱**学习器（避免一开始就过拟合），Bagging 用**强**学习器（本身偏差已小，只需降方差）。

#### 8.6.2 AdaBoost 为什么不容易过拟合？

一个著名的实验现象：AdaBoost 在训练误差降为 0 之后，**继续迭代反而能进一步降低测试误差**。这与"训练误差为 0 就该停止"的直觉相悖。

**间隔理论的解释**（Schapire et al.）：定义样本的**归一化间隔**

$$
\text{margin}(x_i,y_i)=\frac{y_if(x_i)}{\sum_m\alpha_m}
=\frac{y_i\sum_m\alpha_mG_m(x_i)}{\sum_m\alpha_m}\in[-1,1]。
$$

即使训练误差已为 0（所有间隔为正），继续迭代仍会**增大间隔**，从而提升泛化能力。

> 这与第 7 章 SVM 的间隔思想相通：**分对不够，还要分得有信心**。AdaBoost 被称为在做"隐式的间隔最大化"。

**但这不是绝对的**。在**标签噪声**较大时，AdaBoost 会严重过拟合——因为指数损失会给被错误标注的样本越来越大的权值（8.3.4 节）。实践中仍需通过验证集选择迭代轮数 $M$。

**常用的正则化手段**：

| 手段 | 做法 |
| --- | --- |
| **收缩**（shrinkage） | $f_m=f_{m-1}+\nu\cdot T_m$，学习率 $\nu\in(0,1]$（如 0.1） |
| **子采样** | 每轮只用部分样本（Stochastic Gradient Boosting） |
| 限制树深 | 树桩或深度 2–8 的浅树 |
| 早停 | 用验证集监控，误差不降则停 |

> 收缩是 GBDT 最重要的技巧："**小步慢走**"比"大步快跑"泛化更好。经验法则是 $\nu$ 越小、$M$ 越大，效果越好但训练越慢。

#### 8.6.3 与前几章的统一视角

回到第 7 章的统一框架：所有二分类方法都可写成

$$
\min\;\sum_{i=1}^{N}L\bigl(y_if(x_i)\bigr)+\text{正则项}，
$$

区别在损失函数与模型族：

| 方法 | 损失 $L(z)$ | 模型 $f$ | 最优 $f^*$ 估计的量 |
| --- | --- | --- | --- |
| 感知机（第 2 章） | $\max(0,-z)$ | 线性 | — |
| SVM（第 7 章） | $\max(0,1-z)$ | 线性/核 | — |
| 逻辑斯谛（第 6 章） | $\log(1+e^{-z})$ | 线性 | $\log\frac{p}{1-p}$ |
| **AdaBoost（本章）** | $e^{-z}$ | **加法模型** | $\frac12\log\frac{p}{1-p}$ |

**最有意思的一点**：逻辑斯谛回归与 AdaBoost 估计的是**同一个量**（相差因子 2），但

- 逻辑斯谛回归用**线性模型** + 梯度下降；
- AdaBoost 用**加法模型** + 前向分步。

它们是同一目标的两种不同实现路径。

#### 8.6.4 实践要点

| 问题 | 建议 |
| --- | --- |
| 基学习器选什么 | 决策树桩或深度 2–8 的浅树；太强会过拟合 |
| $M$ 怎么定 | 验证集早停；配合小学习率用较大 $M$ |
| 有标签噪声 | 避免 AdaBoost，改用 LogitBoost/GBDT + 稳健损失 |
| 类别不平衡 | 调整初始权值或使用代价敏感版本 |
| 需要概率输出 | $\hat p=\frac{1}{1+e^{-2f(x)}}$，必要时再做校准 |
| 大规模数据 | 用 XGBoost/LightGBM（直方图算法、并行分裂） |

---

### 8.7 本章方法论总结

#### 8.7.1 用三要素分析

**模型**：加法模型

$$
f(x)=\sum_{m=1}^{M}\alpha_mG_m(x)
\quad\text{或}\quad
f_M(x)=\sum_{m=1}^{M}T(x;\Theta_m)。
$$

**策略**：经验风险最小化，损失函数决定具体算法：

| 损失 | 算法 |
| --- | --- |
| 指数损失 | AdaBoost |
| 平方损失 | 回归提升树 |
| 一般可微损失 | 梯度提升 |

**算法**：**前向分步算法**——每步只学一个基函数及其系数，不回头调整。

#### 8.7.2 必须掌握的结论

1. Schapire 证明**强可学习 $\Leftrightarrow$ 弱可学习**，且证明是构造性的，这是提升方法的理论基础。
2. 提升方法的两个核心问题：如何改权值、如何组合；AdaBoost 的答案是"提高错分样本权值"和"加权多数表决"。
3. 误差率 $e_m$ 是**被误分类样本的权值之和**，依赖于当前权值分布。
4. $\alpha_m=\frac12\log\frac{1-e_m}{e_m}$：$e_m\le\frac12$ 时非负，且随 $e_m$ 减小而增大。
5. 误分类样本的权值相对被放大 $\dfrac{1-e_m}{e_m}$ 倍。
6. AdaBoost 不改变数据，只改变**数据的权值分布**。
7. **定理 8.1**：训练误差 $\le$ 平均指数损失 $=\prod_mZ_m$；证明关键是权值更新式的逐层剥离。
8. $\alpha_m$ 的公式可由**最小化 $Z_m$** 直接导出，是最优的。
9. **定理 8.2**：$Z_m=2\sqrt{e_m(1-e_m)}=\sqrt{1-4\gamma_m^2}\le e^{-2\gamma_m^2}$。
10. **推论 8.1**：若 $\gamma_m\ge\gamma>0$，训练误差 $\le e^{-2M\gamma^2}$，**指数速率下降**。
11. AdaBoost **不需要预知** $\gamma$，能自适应各弱分类器的误差率——这是 "Ada" 的由来。
12. **定理 8.3**：AdaBoost = 加法模型 + **指数损失** + 前向分步算法。
13. 样本权值的本质是 $w_{mi}\propto\exp[-y_if_{m-1}(x_i)]$，即当前模型在该样本上的损失。
14. 指数损失的最优解是 $f^*(x)=\frac12\log\frac{P(y=1\mid x)}{P(y=-1\mid x)}$，即**对数几率的一半**。
15. 指数损失增长最快，故 AdaBoost **对标签噪声最敏感**。
16. 平方损失下，提升树每步只需**拟合残差**。
17. **负梯度是残差的推广**：平方损失下负梯度恰为残差。
18. 梯度提升是**函数空间中的梯度下降**；用负梯度定树结构，用原始损失定叶子值。
19. Boosting 串行降**偏差**，Bagging 并行降**方差**；前者用弱学习器，后者用强学习器。
20. AdaBoost 训练误差为 0 后继续迭代仍能提升泛化，可用**间隔理论**解释。
21. 收缩（学习率 $\nu$）是最重要的正则化手段：小步慢走优于大步快跑。

---

### 8.8 习题思路与推导

#### 习题 8.1：应聘人员数据的 AdaBoost

**数据**（10 人，3 个特征）：

| 序号 | 身体 | 业务能力 | 发展潜力 | 分类 |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 0 | 1 | 3 | $-1$ |
| 2 | 0 | 3 | 1 | $-1$ |
| 3 | 1 | 2 | 2 | $-1$ |
| 4 | 1 | 1 | 3 | $-1$ |
| 5 | 1 | 2 | 3 | $-1$ |
| 6 | 0 | 1 | 2 | $-1$ |
| 7 | 1 | 1 | 2 | $+1$ |
| 8 | 1 | 1 | 1 | $+1$ |
| 9 | 1 | 3 | 1 | $-1$ |
| 10 | 0 | 2 | 1 | $-1$ |

**先分析数据**：只有 2 个正类（样本 7、8），8 个负类——**严重不平衡**。这个观察很重要，它决定了后面的结果。

**（一）一个值得注意的现象**

若只使用**内部切分点**的树桩（标准做法），代码运行 15 轮后训练误分类数仍为 **2**，且最后一轮 $e_m=0.4530$ 已接近 $0.5$。

**为什么会这样？** 由推论 8.1，指数下降的前提是

$$
\gamma_m=\frac12-e_m\ge\gamma>0\quad\text{对所有 }m。
$$

而这里 $e_m\to0.5$，即 $\gamma_m\to0$，**弱学习假设失效**——误差界 $e^{-2M\gamma^2}\to1$ 变得毫无意义。

根本原因是候选树桩空间太小：3 个特征、取值很少，内部切分点只能产生 10 个不同树桩，AdaBoost 在几轮后就开始**循环选择同样的几个树桩**，且 $\alpha_m\to0$（贡献越来越小）。

> **这是一个很好的教训**：AdaBoost 不是万能的，它依赖于弱学习器**持续**能找到比随机猜测好的假设。若假设空间太贫乏，提升会停滞。

**（二）允许常值树桩后的完整解**

注意到"恒输出 $-1$"本身也是一个合法的决策树桩（切分点落在取值范围之外）。由于数据 8 负 2 正，这个常值分类器的误差率只有 $0.2$，**比任何内部切分树桩都好**。

把它加入候选集后，AdaBoost 在 **$M=6$** 轮达到零训练误差：

| $m$ | 基本分类器 $G_m(x)$ | $e_m$ | $\alpha_m$ | 累计误分类 |
| ---: | --- | ---: | ---: | ---: |
| 1 | 恒输出 $-1$ | 0.2000 | 0.6931 | 2 |
| 2 | $+1$ 若 业务能力 $<1.5$ | 0.1875 | 0.7332 | 3 |
| 3 | $+1$ 若 发展潜力 $<1.5$ | 0.2692 | 0.4993 | 1 |
| 4 | $+1$ 若 身体 $\ge0.5$ | 0.2381 | 0.5816 | 1 |
| 5 | 恒输出 $-1$ | 0.2566 | 0.5319 | 1 |
| 6 | $+1$ 若 发展潜力 $<2.5$ | 0.2514 | 0.5455 | **0** |

**最终分类器**：

$$
\begin{aligned}
G(x)=\operatorname{sign}\bigl[
&0.6931\,G_1(x)+0.7332\,G_2(x)+0.4993\,G_3(x)\\
&+0.5816\,G_4(x)+0.5319\,G_5(x)+0.5455\,G_6(x)\bigr]
\end{aligned}
$$

**逐样本验证**（全部正确）：

| 样本 | 特征 | $y$ | $f(x)$ | 预测 |
| ---: | --- | ---: | ---: | ---: |
| 1 | $(0,1,3)$ | $-1$ | $-2.1182$ | $-1$ ✓ |
| 2 | $(0,3,1)$ | $-1$ | $-1.4951$ | $-1$ ✓ |
| 3 | $(1,2,2)$ | $-1$ | $-1.3304$ | $-1$ ✓ |
| 4 | $(1,1,3)$ | $-1$ | $-0.9551$ | $-1$ ✓ |
| 5 | $(1,2,3)$ | $-1$ | $-2.4214$ | $-1$ ✓ |
| 6 | $(0,1,2)$ | $-1$ | $-1.0273$ | $-1$ ✓ |
| **7** | $(1,1,2)$ | $+1$ | $+0.1359$ | $+1$ ✓ |
| **8** | $(1,1,1)$ | $+1$ | $+1.1344$ | $+1$ ✓ |
| 9 | $(1,3,1)$ | $-1$ | $-0.3319$ | $-1$ ✓ |
| 10 | $(0,2,1)$ | $-1$ | $-1.4951$ | $-1$ ✓ |

**观察**：两个正类样本的 $f(x)$ 分别只有 $+0.1359$ 和 $+1.1344$，**离决策边界很近**——这反映出正类样本太少、模型对它们的把握不大。样本 9 $(1,3,1)$ 的 $f=-0.3319$ 也很接近边界，因为它与样本 8 $(1,1,1)$ 只差业务能力一项却标签相反。

**这道题的启发**：

1. AdaBoost 在**类别不平衡**时，第一个弱分类器往往就是"全部预测多数类"；
2. 弱学习器的**假设空间**必须足够丰富，否则会停滞在 $e_m\to0.5$；
3. 训练误差为 0 不代表模型好——这里只有 10 个样本、2 个正类，泛化能力存疑。

#### 习题 8.2：比较 SVM、AdaBoost、逻辑斯谛回归

**（一）统一框架**

三者都可写成"**损失函数 + 正则项**"的最小化，且都可以用 $z=yf(x)$ 表示损失：

| 模型 | 损失函数 $L(z)$ | 名称 |
| --- | --- | --- |
| SVM | $\max(0,1-z)$ | 合页损失 |
| AdaBoost | $e^{-z}$ | 指数损失 |
| 逻辑斯谛回归 | $\log(1+e^{-z})$ | 对数损失 |

三者都是 **0-1 损失的凸上界**（代理损失），都是**分类校准**的（最小化它们能收敛到贝叶斯最优分类器）。

**（二）学习策略对比**

| 维度 | **SVM** | **AdaBoost** | **逻辑斯谛回归** |
| --- | --- | --- | --- |
| 模型 | $\operatorname{sign}(w\cdot x+b)$ 或核形式 | 加法模型 $\sum\alpha_mG_m$ | $\sigma(w\cdot x)$ |
| 损失 | 合页损失 | 指数损失 | 对数损失 |
| 正则 | $L_2$（间隔最大化） | 无显式（靠早停/收缩） | $L_2$ 或 $L_1$ |
| 目标解释 | **间隔最大化** | 前向分步拟合 | **极大似然** |
| $f^*$ 估计 | — | $\frac12\log\frac{p}{1-p}$ | $\log\frac{p}{1-p}$ |
| 概率输出 | 否（需校准） | 否（需转换） | **是，且校准良好** |

**（三）学习算法对比**

| 维度 | **SVM** | **AdaBoost** | **逻辑斯谛回归** |
| --- | --- | --- | --- |
| 优化问题 | **凸二次规划** | 前向分步（贪心） | **无约束凸优化** |
| 算法 | SMO / 内点法 | 逐轮加基学习器 | 梯度下降 / 牛顿 / L-BFGS |
| 全局最优 | **是** | 否（贪心） | **是** |
| 解的稀疏性 | **支持向量稀疏** | 基学习器数量有限 | 不稀疏 |
| 非线性 | **核技巧** | 基学习器本身非线性 | 需手工特征 |
| 复杂度 | $O(N^2)\sim O(N^3)$ | $O(M\cdot\text{基学习器代价})$ | $O(\text{迭代}\times Nn)$ |

**（四）关键差异分析**

**1. 对异常点的敏感度**（由损失增长速度决定）：

$$
\underbrace{e^{-z}}_{\text{指数增长}}
\;>\;
\underbrace{\max(0,1-z)}_{\text{线性增长}}
\;\approx\;
\underbrace{\log(1+e^{-z})}_{\text{渐近线性}}
$$

$$
\text{AdaBoost 最敏感}
\;>\;
\text{SVM}\approx\text{逻辑斯谛回归}
$$

代码验证：$z=-3$ 时，指数损失 $20.09$，合页损失 $4.00$，对数损失 $3.05$。

**2. 对"分对了的样本"的态度**：

| 模型 | $z>1$ 时 |
| --- | --- |
| SVM | 损失**恰为 0**，样本完全不影响解 → **稀疏** |
| AdaBoost / 逻辑斯谛 | 损失 $>0$，所有样本都有贡献 → 不稀疏 |

这解释了 SVM 解的稀疏性（只有支持向量起作用）。

**3. 非线性能力的来源**：

| 模型 | 途径 |
| --- | --- |
| SVM | **核技巧**（隐式高维映射） |
| AdaBoost | **基学习器**（如决策树）本身非线性 |
| 逻辑斯谛回归 | 需**手工**构造特征 |

**（五）实践选型建议**

| 场景 | 推荐 |
| --- | --- |
| 需要可信**概率** | 逻辑斯谛回归 |
| 高维小样本（如文本） | 线性 SVM / 逻辑斯谛回归 |
| **表格/结构化数据** | **提升树**（GBDT/XGBoost） |
| 标签有**噪声** | 逻辑斯谛回归 > SVM > AdaBoost |
| 需要**可解释性** | 逻辑斯谛回归（系数即对数几率） |
| 需要模型**紧凑** | SVM（稀疏支持向量） |

**（六）三者的深层联系**

$$
\text{逻辑斯谛回归与 AdaBoost 估计同一个量（相差因子 2）}
$$

只是前者用线性模型 + 梯度下降，后者用加法模型 + 前向分步。而 SVM 与前两者的区别在于：它的合页损失有**平坦段**，因而追求的是"间隔"而非"概率"。

> **一个统一的理解**：三者都在最小化 0-1 损失的凸代理，区别只在于**用什么函数代理**、**用什么模型族**、**用什么算法优化**——这正是第 1 章"模型 + 策略 + 算法"三要素框架的完美体现。

---

### 第 8 章一句话回顾

提升方法源于"弱可学习与强可学习等价"这一构造性定理，AdaBoost 用"提高错分样本权值"与"加权多数表决"两个直觉把弱分类器串成强分类器，其训练误差满足 $\prod_mZ_m=\prod_m\sqrt{1-4\gamma_m^2}\le e^{-2M\gamma^2}$ 的**指数下降界**；而定理 8.3 揭示了这些"巧妙设计"的真正来源——AdaBoost 不过是**加法模型 + 指数损失 + 前向分步算法**的产物，样本权值本质上就是当前模型的指数损失；沿着这条线索把损失换成平方损失就得到"**拟合残差**"的提升树，再把残差推广为**负梯度**便得到适用于任意可微损失的梯度提升，这正是今天 GBDT/XGBoost 家族的源头。
