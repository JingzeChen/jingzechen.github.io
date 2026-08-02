---
title: "《统计学习方法（第 2 版）》第 7 章：支持向量机"
date: 2026-08-01 02:07:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch07-support-vector-machines
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch06-logistic-regression-maximum-entropy, statistical-learning-methods-ch08-boosting]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「支持向量机」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

### 0. 本章解决什么问题

第 2 章的感知机能找到一个分离超平面，但它的解**不唯一**——初始值、样本顺序不同，得到的超平面就不同。支持向量机（SVM）要回答的是：

> 在无穷多个能正确分类的超平面中，**哪一个最好**？

SVM 的答案是：**离两类样本都最远的那个**，即**间隔最大**的超平面。

本章的完整逻辑链条：

```text
线性可分时超平面有无穷多个
    ↓ 需要一个"最优"的标准
间隔最大化（几何间隔最大）
    ↓ 化为优化问题
凸二次规划：min ½||w||² s.t. yᵢ(w·xᵢ+b) ≥ 1
    ↓ 求解不便，且无法引入核
拉格朗日对偶 → 只依赖内积 xᵢ·xⱼ
    ↓ 现实数据往往不可分
引入松弛变量 ξ → 软间隔（对偶只多了上界 α ≤ C）
    ↓ 本质上还是线性分类器
把内积替换为核函数 K(xᵢ,xⱼ) → 非线性 SVM
    ↓ 样本量大时 QP 求解太慢
SMO：每次只优化两个变量，有解析解
```

**三个模型层层递进**：

| 模型 | 适用数据 | 关键技术 |
| --- | --- | --- |
| 线性可分 SVM（硬间隔） | 线性可分 | 硬间隔最大化 |
| 线性 SVM（软间隔） | 近似线性可分 | 松弛变量 + 惩罚参数 $C$ |
| 非线性 SVM | 线性不可分 | 核技巧 + 软间隔 |

后者包含前者，简单模型是复杂模型的特例。

**为什么这章是全书重点？**

1. 它把**拉格朗日对偶**用到了极致（第 6 章最大熵是预演）；
2. **核技巧**是比 SVM 更普适的方法论，能把任何只依赖内积的线性算法非线性化；
3. 它的目标函数是**凸二次规划**，有唯一全局最优解；
4. 它展示了如何为大规模问题设计专门的优化算法（SMO）；
5. 间隔最大化对应着良好的**泛化理论**保证。

#### 与前几章的定位

| 方法 | 目标 | 解 | 决定解的样本 |
| --- | --- | --- | --- |
| 感知机（第 2 章） | 分对就行 | **不唯一** | 曾被误分类的点 |
| 逻辑斯谛回归（第 6 章） | 最大化似然 | 唯一（需正则） | **所有**样本 |
| **SVM（本章）** | **间隔最大** | **唯一** | **少数支持向量** |

SVM 与感知机的关系尤为紧密：模型形式完全相同（都是 $\operatorname{sign}(w\cdot x+b)$），对偶形式也都把 $w$ 表示成样本的线性组合，区别只在于**用什么标准挑选那一个超平面**。

---

### 7.1 线性可分支持向量机与硬间隔最大化

#### 7.1.1 问题的提出

给定特征空间上的训练集

$$
T=\{(x_1,y_1),(x_2,y_2),\ldots,(x_N,y_N)\}，
$$

其中 $x_i\in\mathbb R^n$，$y_i\in\{+1,-1\}$，且训练集**线性可分**。

**定义 7.1（线性可分支持向量机）** 通过间隔最大化学习得到的分离超平面

$$
w^*\cdot x+b^*=0
$$

及分类决策函数

$$
f(x)=\operatorname{sign}(w^*\cdot x+b^*)
$$

称为线性可分支持向量机。

**直观动机**。考虑三个都在正类一侧的点 $A,B,C$：

```text
        分离超平面
            │
   C        │        ← C 离超平面很近，判断"没把握"
       B    │        ← B 中等
  A         │        ← A 离得远，判断"很有把握"
            │
```

点离超平面越远，我们对分类结果越有信心。所以一个好的超平面，应该让**最难分的点**（离超平面最近的点）也尽可能远离超平面。这就是间隔最大化的思想。

#### 7.1.2 函数间隔与几何间隔

**定义 7.2（函数间隔）** 超平面 $(w,b)$ 关于样本点 $(x_i,y_i)$ 的函数间隔：

$$
\hat\gamma_i=y_i(w\cdot x_i+b)。
$$

关于训练集 $T$ 的函数间隔是所有样本点函数间隔的**最小值**：

$$
\hat\gamma=\min_{i=1,\ldots,N}\hat\gamma_i。
$$

> 这个定义在第 2 章已经出现过。$y_i(w\cdot x_i+b)$ 的**符号**表示分类是否正确，**绝对值**表示离超平面的相对远近。

**函数间隔的致命缺陷**。如果把 $(w,b)$ 同时放大 2 倍变成 $(2w,2b)$：

- 超平面 $2w\cdot x+2b=0$ 与 $w\cdot x+b=0$ **完全相同**；
- 但函数间隔变成了原来的 **2 倍**。

所以函数间隔可以被随意"放大"，不能作为优化目标——否则只要不断放大 $w$ 就能让目标无穷大。

**修正办法**：除以 $\lVert w\rVert$，得到几何间隔。

**定义 7.3（几何间隔）**

$$
\gamma_i=y_i\left(\frac{w}{\lVert w\rVert}\cdot x_i+\frac{b}{\lVert w\rVert}\right)
=\frac{y_i(w\cdot x_i+b)}{\lVert w\rVert}，
$$

$$
\gamma=\min_{i=1,\ldots,N}\gamma_i。
$$

**几何间隔的推导**（为什么是这个式子）。设点 $x_i$ 到超平面的投影为 $x_0$，则

$$
x_i-x_0=t\cdot\frac{w}{\lVert w\rVert}
$$

（连线垂直于超平面，方向沿法向量）。由 $w\cdot x_0+b=0$：

$$
w\cdot x_i+b=w\cdot(x_i-x_0)=t\lVert w\rVert，
$$

故

$$
|t|=\frac{|w\cdot x_i+b|}{\lVert w\rVert}，
$$

正是点到超平面的欧氏距离。乘上 $y_i$ 得到**带符号**的距离：分类正确时为正，错误时为负。

**两者的关系**：

$$
\gamma_i=\frac{\hat\gamma_i}{\lVert w\rVert},
\qquad
\gamma=\frac{\hat\gamma}{\lVert w\rVert}。
$$

**关键性质**：

| | 参数按比例缩放 $(w,b)\to(\lambda w,\lambda b)$ |
| --- | --- |
| 超平面 | **不变** |
| 函数间隔 | 变为 $\lambda$ 倍 |
| **几何间隔** | **不变** |

几何间隔是超平面的**内在属性**，与参数化方式无关。这正是我们需要的。

#### 7.1.3 间隔最大化：从直觉到优化问题

**第一步：写出原始想法**

最大化几何间隔，同时保证每个点的几何间隔至少是 $\gamma$：

$$
\max_{w,b}\;\gamma
$$

$$
\text{s.t.}\quad
y_i\left(\frac{w}{\lVert w\rVert}\cdot x_i+\frac{b}{\lVert w\rVert}\right)\ge\gamma,
\quad i=1,\ldots,N。
$$

**第二步：用函数间隔改写**

由 $\gamma=\hat\gamma/\lVert w\rVert$：

$$
\max_{w,b}\;\frac{\hat\gamma}{\lVert w\rVert}
\qquad
\text{s.t.}\quad y_i(w\cdot x_i+b)\ge\hat\gamma。
$$

**第三步（关键）：为什么可以令 $\hat\gamma=1$**

这一步是全章最容易含糊的地方，必须讲清楚。

考虑把 $(w,b)$ 按比例缩放为 $(\lambda w,\lambda b)$，$\lambda>0$：

- 约束变为 $y_i(\lambda w\cdot x_i+\lambda b)\ge\lambda\hat\gamma$，两边同除 $\lambda$ 后**与原约束完全相同**；
- 目标 $\dfrac{\lambda\hat\gamma}{\lVert\lambda w\rVert}=\dfrac{\lambda\hat\gamma}{\lambda\lVert w\rVert}=\dfrac{\hat\gamma}{\lVert w\rVert}$，**也没有变**。

所以缩放产生的是一个**完全等价的优化问题**。既然 $\hat\gamma$ 的具体取值不影响解，我们不妨**固定** $\hat\gamma=1$（这相当于在所有等价的参数表示中，选定一个"标准"的尺度）。

> **换个角度理解**：原问题对 $(w,b)$ 的尺度有冗余（一条超平面对应无穷多组参数）。令 $\hat\gamma=1$ 就是**消除这个冗余**，把解固定下来。

代入后问题变为：

$$
\max_{w,b}\;\frac{1}{\lVert w\rVert}
\qquad
\text{s.t.}\quad y_i(w\cdot x_i+b)\ge1。
$$

**第四步：转成标准形式**

$$
\max\frac{1}{\lVert w\rVert}
\quad\Longleftrightarrow\quad
\min\lVert w\rVert
\quad\Longleftrightarrow\quad
\min\frac12\lVert w\rVert^2。
$$

（平方与系数 $\frac12$ 都是为了求导方便，不改变最优解——因为 $t\mapsto\frac12t^2$ 在 $t\ge0$ 上严格递增。）

**最终的优化问题：**

$$
\boxed{
\begin{aligned}
\min_{w,b}\quad&\frac12\lVert w\rVert^2\\
\text{s.t.}\quad&y_i(w\cdot x_i+b)-1\ge0,\quad i=1,\ldots,N
\end{aligned}}
$$

**这是一个凸二次规划问题**：

- 目标函数 $\frac12\lVert w\rVert^2$ 是**凸二次**函数；
- 约束是**仿射**（线性）的；

因此有**唯一全局最优解**，且有成熟算法可解。

> **凸优化问题**的一般形式：目标 $f(w)$ 与不等式约束 $g_i(w)\le0$ 均为凸函数，等式约束 $h_i(w)=0$ 为仿射函数。当 $f$ 是二次函数、$g_i$ 是仿射函数时，称为**凸二次规划**。

**算法 7.1（最大间隔法）**

1. 构造并求解上述凸二次规划，得 $w^*,b^*$；
2. 得到分离超平面 $w^*\cdot x+b^*=0$ 与决策函数 $f(x)=\operatorname{sign}(w^*\cdot x+b^*)$。

#### 7.1.4 解的存在唯一性

**定理 7.1** 若训练集 $T$ 线性可分，则最大间隔分离超平面**存在且唯一**。

**证明思路**（书中证明的梳理）：

**（一）存在性**

线性可分 $\Rightarrow$ 优化问题存在可行解；目标函数 $\frac12\lVert w\rVert^2\ge0$ 有下界，故最优解存在，记 $(w^*,b^*)$。

又因训练集中既有正类又有负类，$(w,b)=(0,b)$ 不满足约束（此时 $y_i\cdot b\ge1$ 对正负类不能同时成立），故 $w^*\ne0$。

**（二）唯一性**

先证 $w^*$ 唯一。反设有两个最优解 $(w_1^*,b_1^*)$ 和 $(w_2^*,b_2^*)$，则 $\lVert w_1^*\rVert=\lVert w_2^*\rVert=c$。

令 $w=\frac{w_1^*+w_2^*}{2}$，$b=\frac{b_1^*+b_2^*}{2}$，则 $(w,b)$ 也是可行解（约束是线性的，凸组合仍可行）。于是

$$
c\le\lVert w\rVert\le\frac12\lVert w_1^*\rVert+\frac12\lVert w_2^*\rVert=c，
$$

**不等号必须取等号**。这意味着三角不等式取等，故 $w_1^*=\lambda w_2^*$ 且 $|\lambda|=1$。

若 $\lambda=-1$，则 $w=0$，与 $(w,b)$ 是可行解矛盾。故 $\lambda=1$，即

$$
w_1^*=w_2^*。
$$

再证 $b^*$ 唯一。设 $x_1',x_2'$ 分别是使 $(w^*,b_1^*)$ 的约束取等号的正、负类点，则可推出

$$
b_1^*=-\frac12\bigl[w^*\cdot x_1'+w^*\cdot x_2'\bigr]，
$$

同理 $b_2^*$ 也有相同表达式，故 $b_1^*=b_2^*$。$\blacksquare$

> **对比第 2 章**：感知机的解**不唯一**（依赖初始化和样本顺序），SVM 的解**唯一**。这正是"加了间隔最大化这个额外准则"带来的好处——它从无穷多可行超平面中挑出了唯一确定的那个。

#### 7.1.5 支持向量与间隔边界

**支持向量**：使约束取等号的样本点，即

$$
y_i(w\cdot x_i+b)-1=0。
$$

- 对 $y_i=+1$ 的支持向量，位于超平面 $H_1:w\cdot x+b=1$ 上；
- 对 $y_i=-1$ 的支持向量，位于超平面 $H_2:w\cdot x+b=-1$ 上。

$H_1$ 与 $H_2$ 称为**间隔边界**，它们之间的距离称为**间隔**（margin）：

$$
\text{margin}=\frac{2}{\lVert w\rVert}。
$$

**推导**：两平行超平面 $w\cdot x+b=1$ 与 $w\cdot x+b=-1$ 之间的距离为

$$
\frac{|1-(-1)|}{\lVert w\rVert}=\frac{2}{\lVert w\rVert}。
$$

这也解释了为什么 $\min\frac12\lVert w\rVert^2$ 等价于最大化间隔。

```text
        H₂        分离超平面      H₁
         │            │            │
    ×    │            │            │   ○
      ×  ●            │            ●  ○      ● = 支持向量
         │            │            │
    ×    │            │            ●  ○
         │            │            │
      ←──┼── 2/||w|| ─┼────────────┤
```

**核心性质：只有支持向量决定超平面。**

- 移动支持向量 $\Rightarrow$ 解会改变；
- 移动甚至删除间隔边界**以外**的点 $\Rightarrow$ 解**完全不变**。

支持向量的个数通常很少，所以

> SVM 由极少数"重要的"训练样本完全确定。

这既是名字的由来，也是它的一大优点：模型只需存储支持向量，且对非支持向量的噪声不敏感。

#### 7.1.6 例 7.1

**数据**（与例 2.1 相同）：正例 $x_1=(3,3)^\top$，$x_2=(4,3)^\top$；负例 $x_3=(1,1)^\top$。

**优化问题**：

$$
\min_{w,b}\;\frac12(w_1^2+w_2^2)
$$

$$
\text{s.t.}\quad
\begin{cases}
3w_1+3w_2+b\ge1,\\
4w_1+3w_2+b\ge1,\\
-w_1-w_2-b\ge1。
\end{cases}
$$

**解**：$w_1=w_2=\frac12$，$b=-2$。

最大间隔分离超平面：

$$
\frac12x^{(1)}+\frac12x^{(2)}-2=0。
$$

**验证**（代码已核验）：

| 点 | $y_i$ | $w\cdot x_i+b$ | $y_i(w\cdot x_i+b)$ | 是否支持向量 |
| --- | ---: | ---: | ---: | :---: |
| $x_1=(3,3)$ | $+1$ | $1$ | $1$ | **是** |
| $x_2=(4,3)$ | $+1$ | $3/2$ | $3/2$ | 否 |
| $x_3=(1,1)$ | $-1$ | $-1$ | $1$ | **是** |

$\lVert w\rVert=\frac{\sqrt2}{2}$，间隔 $=\frac{2}{\lVert w\rVert}=2\sqrt2\approx2.828$。

注意 $x_2$ 不是支持向量——把它删掉，解完全不变。

---

### 7.2 学习的对偶算法

#### 7.2.1 为什么要转对偶

原始问题已经是凸二次规划，为什么还要转对偶？两个理由：

1. **对偶问题往往更容易求解**——变量个数从 $n+1$（特征维数）变成 $N$（样本数），且约束更简单；
2. **自然引入核函数**——对偶问题只涉及样本间的**内积** $x_i\cdot x_j$，这是核技巧的入口。

第二点才是决定性的。**没有对偶，就没有核 SVM。**

#### 7.2.2 拉格朗日对偶推导

**第一步：构造拉格朗日函数**

对每个不等式约束引入乘子 $\alpha_i\ge0$：

$$
L(w,b,\alpha)=\frac12\lVert w\rVert^2
-\sum_{i=1}^{N}\alpha_iy_i(w\cdot x_i+b)
+\sum_{i=1}^{N}\alpha_i。
$$

> 注意符号：约束写成 $y_i(w\cdot x_i+b)-1\ge0$，标准形式是 $g_i(w)=1-y_i(w\cdot x_i+b)\le0$，所以拉格朗日函数是 $f+\sum\alpha_ig_i$，展开即得上式。

原始问题等价于

$$
\min_{w,b}\max_{\alpha\ge0}L(w,b,\alpha)。
$$

**为什么等价？** 若某个约束被违反（$y_i(w\cdot x_i+b)<1$），则取 $\alpha_i\to+\infty$ 可使内层 $\max$ 为 $+\infty$；只有所有约束都满足时，内层最大值才有限（此时最优取 $\alpha_ig_i=0$）。所以外层 $\min$ 自动排除了不可行点。

**对偶问题**是交换 $\min$ 与 $\max$：

$$
\max_{\alpha\ge0}\min_{w,b}L(w,b,\alpha)。
$$

由于原问题是凸的且满足 Slater 条件，**强对偶性成立**，两者的解相同。

**第二步：求内层极小 $\min_{w,b}L$**

对 $w$ 和 $b$ 求偏导并令其为零：

$$
\nabla_wL=w-\sum_{i=1}^{N}\alpha_iy_ix_i=0
\quad\Longrightarrow\quad
\boxed{w=\sum_{i=1}^{N}\alpha_iy_ix_i}
$$

$$
\nabla_bL=-\sum_{i=1}^{N}\alpha_iy_i=0
\quad\Longrightarrow\quad
\boxed{\sum_{i=1}^{N}\alpha_iy_i=0}
$$

> **第一个式子极其重要**：它说明最优的 $w$ 一定是**训练样本的线性组合**（与第 2 章感知机对偶形式完全一致）。第二个式子是 $b$ 带来的等式约束，后面 SMO 中"必须同时更新两个变量"的原因就在这里。

**第三步：代回消元**

把 $w=\sum_i\alpha_iy_ix_i$ 代入 $L$：

$$
\begin{aligned}
\frac12\lVert w\rVert^2
&=\frac12\left(\sum_i\alpha_iy_ix_i\right)\cdot\left(\sum_j\alpha_jy_jx_j\right)\\
&=\frac12\sum_{i=1}^{N}\sum_{j=1}^{N}\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)，
\end{aligned}
$$

$$
\begin{aligned}
-\sum_i\alpha_iy_i(w\cdot x_i+b)
&=-\sum_i\alpha_iy_iw\cdot x_i-b\underbrace{\sum_i\alpha_iy_i}_{=0}\\
&=-\sum_{i}\sum_{j}\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)。
\end{aligned}
$$

两式相加，二次项系数为 $\frac12-1=-\frac12$：

$$
\min_{w,b}L=-\frac12\sum_{i=1}^{N}\sum_{j=1}^{N}
\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)+\sum_{i=1}^{N}\alpha_i。
$$

**第四步：对偶问题**

$$
\max_\alpha\;-\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)+\sum_i\alpha_i
$$

改写为极小形式（乘 $-1$）：

$$
\boxed{
\begin{aligned}
\min_\alpha\quad&\frac12\sum_{i=1}^{N}\sum_{j=1}^{N}
\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)-\sum_{i=1}^{N}\alpha_i\\
\text{s.t.}\quad&\sum_{i=1}^{N}\alpha_iy_i=0,\\
&\alpha_i\ge0,\quad i=1,\ldots,N
\end{aligned}}
$$

**观察**：目标函数中样本**只以内积 $x_i\cdot x_j$ 的形式出现**。这就是核技巧的入口。

#### 7.2.3 KKT 条件及其含义

原始问题与对偶问题的最优解满足 **KKT 条件**：

$$
\begin{aligned}
&\text{(1) 稳定性：}&&w^*=\sum_i\alpha_i^*y_ix_i,\quad\sum_i\alpha_i^*y_i=0\\
&\text{(2) 原始可行：}&&y_i(w^*\cdot x_i+b^*)-1\ge0\\
&\text{(3) 对偶可行：}&&\alpha_i^*\ge0\\
&\text{(4) 互补松弛：}&&\alpha_i^*\bigl[y_i(w^*\cdot x_i+b^*)-1\bigr]=0
\end{aligned}
$$

**互补松弛条件是理解 SVM 的钥匙**。它说：对每个样本，$\alpha_i^*$ 与 $\bigl[y_i(w^*\cdot x_i+b^*)-1\bigr]$ 中**至少有一个为 0**：

| 情况 | 含义 |
| --- | --- |
| $\alpha_i^*=0$ | 该样本**不影响** $w^*$，在间隔边界之外 |
| $\alpha_i^*>0$ | 必有 $y_i(w^*\cdot x_i+b^*)=1$，即样本**恰在间隔边界上** |

$$
\boxed{\;\alpha_i^*>0\;\Longleftrightarrow\;x_i\text{ 是支持向量}\;}
$$

这从数学上严格解释了"只有支持向量决定超平面"。

#### 7.2.4 由对偶解还原原始解

**定理 7.2** 设 $\alpha^*$ 是对偶问题的解，则存在下标 $j$ 使 $\alpha_j^*>0$，且

$$
w^*=\sum_{i=1}^{N}\alpha_i^*y_ix_i，
$$

$$
b^*=y_j-\sum_{i=1}^{N}\alpha_i^*y_i(x_i\cdot x_j)。
$$

**$w^*$ 的推导**：直接来自 KKT 稳定性条件。

**存在 $\alpha_j^*>0$ 的证明**（反证）：若所有 $\alpha_i^*=0$，则 $w^*=0$。但 $w^*=0$ 时超平面退化，不满足约束 $y_i\cdot b\ge1$（正负类不能同时满足），与最优解矛盾。

**$b^*$ 的推导**：取任一 $\alpha_j^*>0$，由互补松弛：

$$
y_j(w^*\cdot x_j+b^*)-1=0。
$$

两边乘 $y_j$，利用 $y_j^2=1$：

$$
w^*\cdot x_j+b^*=y_j
\quad\Longrightarrow\quad
b^*=y_j-w^*\cdot x_j
=y_j-\sum_i\alpha_i^*y_i(x_i\cdot x_j)。
$$

**分类决策函数的对偶形式**：

$$
\boxed{\;
f(x)=\operatorname{sign}\left(\sum_{i=1}^{N}\alpha_i^*y_i(x\cdot x_i)+b^*\right)
\;}
$$

**关键观察**：决策函数**只依赖于待预测样本与训练样本的内积**。这意味着：

1. 不需要显式计算 $w^*$（在高维/无穷维空间中 $w^*$ 可能无法表示）；
2. 只需对**支持向量**求和（$\alpha_i^*=0$ 的项自动消失）；
3. 把内积换成核函数即可处理非线性问题。

#### 7.2.5 例 7.2：用对偶算法求解

数据同例 7.1。Gram 矩阵：

$$
G=\begin{pmatrix}18&21&6\\21&25&7\\6&7&2\end{pmatrix}
$$

（例如 $x_1\cdot x_1=9+9=18$，$x_1\cdot x_3=3+3=6$。）

对偶问题为

$$
\min_\alpha\;\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_jG_{ij}-\sum_i\alpha_i
$$

$$
\text{s.t.}\quad\alpha_1+\alpha_2-\alpha_3=0,\quad\alpha_i\ge0。
$$

**消元**。由等式约束 $\alpha_3=\alpha_1+\alpha_2$，代入得

$$
s(\alpha_1,\alpha_2)=4\alpha_1^2+\frac{13}{2}\alpha_2^2
+10\alpha_1\alpha_2-2\alpha_1-2\alpha_2。
$$

（代码已用有理数精确核验此展开式。）

**求极值**。令偏导为零：

$$
\begin{cases}
8\alpha_1+10\alpha_2-2=0,\\
10\alpha_1+13\alpha_2-2=0,
\end{cases}
$$

解得 $(\alpha_1,\alpha_2)=\left(\frac32,-1\right)$。

**但 $\alpha_2=-1<0$ 违反约束**，所以最小值在**边界**上取到：

| 边界 | 最优点 | 目标值 |
| --- | --- | ---: |
| $\alpha_1=0$ | $\alpha_2=\frac{2}{13}$ | $-\frac{2}{13}\approx-0.154$ |
| **$\alpha_2=0$** | $\alpha_1=\frac14$ | $\boxed{-\frac14}$ |

最小值在 $\alpha_2=0,\alpha_1=\frac14$ 处，此时 $\alpha_3=\alpha_1+\alpha_2=\frac14$。

$$
\alpha^*=\left(\tfrac14,\;0,\;\tfrac14\right)^\top。
$$

**还原原始解**：

$$
w^*=\tfrac14(1)(3,3)^\top+0+\tfrac14(-1)(1,1)^\top
=\left(\tfrac12,\tfrac12\right)^\top，
$$

$$
b^*=y_1-\sum_i\alpha_i^*y_iG_{i1}
=1-\left(\tfrac14\cdot18-\tfrac14\cdot6\right)=1-3=-2。
$$

与例 7.1 的直接求解结果**完全一致**。

$\alpha_1^*,\alpha_3^*>0$ 说明 $x_1,x_3$ 是支持向量，$\alpha_2^*=0$ 说明 $x_2$ 不是——这与 7.1.6 节的观察吻合。

---

### 7.3 线性支持向量机与软间隔最大化

#### 7.3.1 问题：现实数据往往不可分

硬间隔 SVM 要求**所有**样本满足 $y_i(w\cdot x_i+b)\ge1$。现实中：

- 数据可能因**噪声**或**特异点**（outlier）而线性不可分；
- 即使可分，个别离群点也可能把间隔挤得极小，导致过拟合。

```text
   ×    │  ○           少数几个 × 混在 ○ 区域里，
     ×  │    ○  ×  ○   硬间隔要么无解，
   ×    │  ○     ○     要么被这几个点严重扭曲
```

**解决思路**：允许少数点"违规"，但要付出代价。

#### 7.3.2 松弛变量与原始问题

对每个样本引入**松弛变量** $\xi_i\ge0$，把约束放松为

$$
y_i(w\cdot x_i+b)\ge1-\xi_i。
$$

$\xi_i$ 度量了该样本"违反"间隔要求的程度：

| $\xi_i$ | 含义 |
| --- | --- |
| $\xi_i=0$ | 满足硬间隔要求 |
| $0<\xi_i<1$ | 分类正确，但落在间隔内部 |
| $\xi_i=1$ | 恰好落在分离超平面上 |
| $\xi_i>1$ | **被错误分类** |

同时在目标函数中对每个 $\xi_i$ 支付代价：

$$
\boxed{
\begin{aligned}
\min_{w,b,\xi}\quad&\frac12\lVert w\rVert^2+C\sum_{i=1}^{N}\xi_i\\
\text{s.t.}\quad&y_i(w\cdot x_i+b)\ge1-\xi_i,\quad i=1,\ldots,N\\
&\xi_i\ge0,\quad i=1,\ldots,N
\end{aligned}}
$$

**惩罚参数 $C>0$ 的含义**（这是 SVM 最重要的超参数）：

$$
\underbrace{\frac12\lVert w\rVert^2}_{\text{间隔尽量大}}
+\;C\;
\underbrace{\sum_i\xi_i}_{\text{违规尽量少}}
$$

| $C$ | 效果 |
| --- | --- |
| $C$ 大 | 严厉惩罚违规 $\to$ 间隔窄、训练误差小 $\to$ 接近硬间隔，**易过拟合** |
| $C$ 小 | 容忍违规 $\to$ 间隔宽、训练误差大 $\to$ **易欠拟合** |
| $C\to\infty$ | 退化为硬间隔 SVM |

> 用第 1 章的语言：$\frac12\lVert w\rVert^2$ 是**正则化项**（控制复杂度），$C\sum\xi_i$ 是**经验风险**，$C$ 是权衡系数。这与 5.4 节决策树剪枝的 $C(T)+\alpha|T|$ 是同一个思想。

**定义 7.5（线性支持向量机）** 求解上述凸二次规划得到的分离超平面与决策函数称为线性支持向量机。

> **解的性质**：$w^*$ 唯一，但 $b^*$ **可能不唯一**（存在于一个区间中）。这与硬间隔不同。实践中通常取所有满足 $0<\alpha_i^*<C$ 的样本算出的 $b$ 的平均值。

#### 7.3.3 对偶问题推导

**拉格朗日函数**（两组约束，两组乘子 $\alpha_i\ge0$、$\mu_i\ge0$）：

$$
\begin{aligned}
L(w,b,\xi,\alpha,\mu)
=&\frac12\lVert w\rVert^2+C\sum_i\xi_i\\
&-\sum_i\alpha_i\bigl[y_i(w\cdot x_i+b)-1+\xi_i\bigr]
-\sum_i\mu_i\xi_i。
\end{aligned}
$$

**对 $w,b,\xi$ 求偏导并令为零**：

$$
\nabla_wL=w-\sum_i\alpha_iy_ix_i=0
\;\Longrightarrow\;
w=\sum_i\alpha_iy_ix_i，
$$

$$
\nabla_bL=-\sum_i\alpha_iy_i=0
\;\Longrightarrow\;
\sum_i\alpha_iy_i=0，
$$

$$
\frac{\partial L}{\partial\xi_i}=C-\alpha_i-\mu_i=0
\;\Longrightarrow\;
\boxed{C-\alpha_i-\mu_i=0}
$$

**第三个式子是软间隔的全部新意所在。** 由它可得：

$$
\mu_i=C-\alpha_i。
$$

结合 $\alpha_i\ge0$ 和 $\mu_i\ge0$：

$$
\alpha_i\ge0
\quad\text{且}\quad
C-\alpha_i\ge0
\quad\Longrightarrow\quad
\boxed{0\le\alpha_i\le C}
$$

> **这就是软间隔对偶问题中上界 $C$ 的来历**——不是人为加的，而是从 $\xi_i$ 的最优性条件自动推出的。硬间隔对应 $C=\infty$，上界消失。

**代回消元**。注意含 $\xi$ 的项：

$$
C\sum_i\xi_i-\sum_i\alpha_i\xi_i-\sum_i\mu_i\xi_i
=\sum_i(\underbrace{C-\alpha_i-\mu_i}_{=0})\xi_i=0，
$$

**$\xi$ 完全消失了**。剩下的部分与硬间隔情形完全相同，故对偶问题为：

$$
\boxed{
\begin{aligned}
\min_\alpha\quad&\frac12\sum_{i=1}^{N}\sum_{j=1}^{N}
\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)-\sum_{i=1}^{N}\alpha_i\\
\text{s.t.}\quad&\sum_{i=1}^{N}\alpha_iy_i=0\\
&0\le\alpha_i\le C,\quad i=1,\ldots,N
\end{aligned}}
$$

**与硬间隔对偶的唯一区别**：约束 $\alpha_i\ge0$ 变成 $0\le\alpha_i\le C$。目标函数一模一样。

> 这个结果非常优雅：引入了 $N$ 个松弛变量，对偶问题却**没有增加任何变量**，只是给原有变量加了个上界。

**定理 7.3**：设 $\alpha^*$ 是对偶解，若存在分量 $0<\alpha_j^*<C$，则

$$
w^*=\sum_i\alpha_i^*y_ix_i,
\qquad
b^*=y_j-\sum_i\alpha_i^*y_i(x_i\cdot x_j)。
$$

> 注意计算 $b^*$ 时必须选**严格在 $(0,C)$ 内**的 $\alpha_j^*$。原因见下节：只有这类样本恰好落在间隔边界上，才有 $y_j(w^*\cdot x_j+b^*)=1$。

#### 7.3.4 支持向量的完整分类

软间隔的 KKT 互补条件为：

$$
\alpha_i^*\bigl[y_i(w^*\cdot x_i+b^*)-1+\xi_i^*\bigr]=0,
\qquad
\mu_i^*\xi_i^*=0，
$$

结合 $\mu_i^*=C-\alpha_i^*$，可以完整刻画每个样本的位置：

| $\alpha_i^*$ | $\mu_i^*=C-\alpha_i^*$ | $\xi_i^*$ | 样本位置 |
| :---: | :---: | :---: | --- |
| $\alpha_i^*=0$ | $>0$ | $=0$ | 间隔边界**外**，分类正确（非支持向量） |
| $0<\alpha_i^*<C$ | $>0$ | $=0$ | **恰在间隔边界上** |
| $\alpha_i^*=C$ | $=0$ | $0<\xi_i<1$ | 间隔内部，分类**正确** |
| $\alpha_i^*=C$ | $=0$ | $\xi_i=1$ | 恰在分离超平面上 |
| $\alpha_i^*=C$ | $=0$ | $\xi_i>1$ | 分类**错误** |

**推理链条**：

- 若 $\alpha_i^*<C$，则 $\mu_i^*=C-\alpha_i^*>0$，由 $\mu_i^*\xi_i^*=0$ 得 $\xi_i^*=0$；
- 若 $\alpha_i^*>0$，由第一个互补条件得 $y_i(w^*\cdot x_i+b^*)=1-\xi_i^*$；
- 两者结合：$0<\alpha_i^*<C\Rightarrow\xi_i^*=0\Rightarrow y_i(w^*\cdot x_i+b^*)=1$，即恰在间隔边界上。

```text
         H₂        分离超平面      H₁
          │            │            │
     ×    │            │            │    ○      α=0 (非支持向量)
       ×  ●            │            ●  ○        α∈(0,C) 在边界上
          │      ○     │            │           α=C, 0<ξ<1 (间隔内)
          │            │  ×         │           α=C, ξ>1 (错分)
```

**这个表格是理解软间隔 SVM 的核心**，也是 SMO 算法中判断 KKT 条件的依据。

#### 7.3.5 合页损失：SVM 的另一种解释

**定理 7.4** 线性 SVM 的原始问题等价于最小化

$$
\sum_{i=1}^{N}\bigl[1-y_i(w\cdot x_i+b)\bigr]_++\lambda\lVert w\rVert^2，
$$

其中 $[z]_+=\max(0,z)$。

函数

$$
L(y(w\cdot x+b))=\bigl[1-y(w\cdot x+b)\bigr]_+
$$

称为**合页损失函数**（hinge loss）。

**证明**。令

$$
\xi_i=\bigl[1-y_i(w\cdot x_i+b)\bigr]_+。
$$

**（一）验证 $\xi_i$ 满足原始问题的约束：**

- 显然 $\xi_i\ge0$（取正部）；
- 若 $1-y_i(w\cdot x_i+b)>0$，则 $\xi_i=1-y_i(w\cdot x_i+b)$，故 $y_i(w\cdot x_i+b)=1-\xi_i$；
- 若 $1-y_i(w\cdot x_i+b)\le0$，则 $\xi_i=0$，且 $y_i(w\cdot x_i+b)\ge1=1-\xi_i$。

两种情况都有 $y_i(w\cdot x_i+b)\ge1-\xi_i$ ✓

**（二）** 于是原问题可写成

$$
\min_{w,b}\;\sum_i\xi_i+\lambda\lVert w\rVert^2。
$$

取 $\lambda=\dfrac{1}{2C}$，乘以 $C$：

$$
\min_{w,b}\;C\sum_i\xi_i+\frac12\lVert w\rVert^2，
$$

与原始问题一致。$\blacksquare$

**合页损失的图形与意义**：

```text
损失
 3 │╲
   │ ╲  合页损失 [1-z]₊
 2 │  ╲
   │   ╲
 1 ├────╲────  0-1 损失
   │     ╲│
 0 └──────╲────────────  z = y(w·x+b)
  -2  -1   0   1   2
```

**三种损失的对比**（代码已计算）：

| $z=y(w\cdot x+b)$ | 0-1 损失 | 感知机 $[-z]_+$ | 合页 $[1-z]_+$ | 逻辑斯谛 |
| ---: | ---: | ---: | ---: | ---: |
| $-2.0$ | 1.00 | 2.00 | 3.00 | 3.07 |
| $-1.0$ | 1.00 | 1.00 | 2.00 | 1.89 |
| $0.0$ | 1.00 | 0.00 | 1.00 | 1.00 |
| $+0.5$ | 0.00 | 0.00 | **0.50** | 0.68 |
| $+1.0$ | 0.00 | 0.00 | **0.00** | 0.45 |
| $+2.0$ | 0.00 | 0.00 | 0.00 | 0.18 |

**关键差异**：

- **感知机损失**：只要分类正确（$z>0$）损失就是 0；
- **合页损失**：要求 $z\ge1$，即不仅要分对，还要**间隔足够大**；
- **逻辑斯谛损失**：永远大于 0，即使分得很好仍鼓励继续增大间隔。

$$
\text{合页损失对学习的要求比感知机更高。}
$$

**代理损失的思想**。0-1 损失是分类问题"真正"的损失，但它不连续、不可导，直接优化是 NP 难的。合页损失是 0-1 损失的**凸上界**（从图中可见合页损失曲线始终在 0-1 损失之上），因此：

$$
\text{优化合页损失}\;\Longrightarrow\;\text{间接控制 0-1 损失}
$$

这类损失称为**代理损失函数**（surrogate loss）。

> **本书至此出现的四种代理损失**：感知机损失（第 2 章）、逻辑斯谛损失（第 6 章）、合页损失（本章）、指数损失（第 8 章 AdaBoost）。它们都是 0-1 损失的凸上界，区别在于对错误的惩罚增长速度：合页损失**线性**增长，指数损失**指数**增长（对噪声最敏感），逻辑斯谛损失渐近线性。

---

### 7.4 非线性支持向量机与核函数

#### 7.4.1 非线性问题与空间变换

有些问题用直线（超平面）无法分开，但用曲线（超曲面）可以：

```text
   原空间（不可分）          变换后（可分）
      ×  ×  ×                  │
    × ○ ○ ○ ×                  │  ×
    × ○  ○  ×      →      ○ ○  │  ×
    × ○ ○ ○ ×             ○    │  ×  ×
      ×  ×  ×                  │
```

**思路**：先用非线性变换 $\phi$ 把数据映射到新空间，再在新空间用线性方法。

**书中的例子**。设原空间 $\mathcal X\subseteq\mathbb R^2$，映射

$$
z=\phi(x)=\left((x^{(1)})^2,(x^{(2)})^2\right)^\top。
$$

原空间中的**椭圆**

$$
w_1(x^{(1)})^2+w_2(x^{(2)})^2+b=0
$$

在新空间中变成**直线**

$$
w_1z^{(1)}+w_2z^{(2)}+b=0。
$$

于是原空间的非线性可分问题，变成了新空间的线性可分问题。

**但直接做映射有严重问题**：

- 要达到好的效果，特征空间维数往往**极高**（$n$ 维输入的 $p$ 次多项式特征有 $O(n^p)$ 个）；
- 甚至可能是**无穷维**（高斯核对应的特征空间）；
- 显式计算 $\phi(x)$ 和内积 $\phi(x)\cdot\phi(z)$ 代价太大。

#### 7.4.2 核技巧

**定义 7.6（核函数）** 设 $\mathcal X$ 是输入空间，$\mathcal H$ 是特征空间（希尔伯特空间）。若存在映射

$$
\phi:\mathcal X\to\mathcal H
$$

使得对所有 $x,z\in\mathcal X$：

$$
\boxed{\;K(x,z)=\phi(x)\cdot\phi(z)\;}
$$

则称 $K(x,z)$ 为**核函数**，$\phi$ 为映射函数。

**核技巧的思想**：

> 只定义核函数 $K(x,z)$，**不显式定义映射 $\phi$**。

因为直接计算 $K(x,z)$ 通常很容易，而通过 $\phi(x),\phi(z)$ 计算却很困难。

**例 7.3**。设 $\mathcal X=\mathbb R^2$，$K(x,z)=(x\cdot z)^2$。

展开：

$$
\begin{aligned}
(x\cdot z)^2
&=\left(x^{(1)}z^{(1)}+x^{(2)}z^{(2)}\right)^2\\
&=(x^{(1)}z^{(1)})^2+2x^{(1)}z^{(1)}x^{(2)}z^{(2)}+(x^{(2)}z^{(2)})^2。
\end{aligned}
$$

可以取映射（$\mathcal H=\mathbb R^3$）：

$$
\phi(x)=\left((x^{(1)})^2,\;\sqrt2\,x^{(1)}x^{(2)},\;(x^{(2)})^2\right)^\top，
$$

容易验证 $\phi(x)\cdot\phi(z)=(x\cdot z)^2=K(x,z)$（代码已数值核验，误差 $10^{-16}$）。

**重要**：$\phi$ 和 $\mathcal H$ **不唯一**。同一个核也可以取

$$
\phi(x)=\frac{1}{\sqrt2}\left((x^{(1)})^2-(x^{(2)})^2,\;2x^{(1)}x^{(2)},\;(x^{(1)})^2+(x^{(2)})^2\right)^\top,
$$

或取 $\mathcal H=\mathbb R^4$：

$$
\phi(x)=\left((x^{(1)})^2,x^{(1)}x^{(2)},x^{(1)}x^{(2)},(x^{(2)})^2\right)^\top。
$$

**核技巧应用到 SVM**：把对偶问题与决策函数中的内积**全部替换为核函数**：

$$
\min_\alpha\;\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_jK(x_i,x_j)-\sum_i\alpha_i，
$$

$$
f(x)=\operatorname{sign}\left(\sum_{i=1}^{N}\alpha_i^*y_iK(x,x_i)+b^*\right)。
$$

**这等价于**：先用 $\phi$ 把数据映射到高维特征空间，再在那里学习线性 SVM。但整个过程中**从未显式计算过 $\phi(x)$**。

> **这就是"核技巧"三个字的全部含义**：学习是隐式地在特征空间进行的。计算量只与样本数有关，与特征空间维数**无关**——哪怕是无穷维。

#### 7.4.3 正定核的充要条件

**问题**：给定一个函数 $K(x,z)$，怎么判断它是不是核函数（即是否存在对应的 $\phi$）？

**定理 7.5（正定核的充要条件）** 设 $K:\mathcal X\times\mathcal X\to\mathbb R$ 是**对称函数**，则 $K$ 是正定核的充要条件是：对任意 $x_1,\ldots,x_m\in\mathcal X$，其 **Gram 矩阵**

$$
K=[K(x_i,x_j)]_{m\times m}
$$

是**半正定**矩阵。

**必要性证明**（容易的方向）。若 $K$ 是核函数，存在 $\phi$ 使 $K(x,z)=\phi(x)\cdot\phi(z)$。对任意 $c_1,\ldots,c_m\in\mathbb R$：

$$
\begin{aligned}
\sum_{i,j=1}^{m}c_ic_jK(x_i,x_j)
&=\sum_{i,j}c_ic_j\bigl(\phi(x_i)\cdot\phi(x_j)\bigr)\\
&=\left(\sum_ic_i\phi(x_i)\right)\cdot\left(\sum_jc_j\phi(x_j)\right)\\
&=\left\lVert\sum_ic_i\phi(x_i)\right\rVert^2\ge0。
\end{aligned}
$$

故 Gram 矩阵半正定。$\blacksquare$

**充分性证明思路**（困难的方向）。已知 Gram 矩阵半正定，要**构造出** $\phi$ 和 $\mathcal H$。书中分三步：

**第一步：定义映射，构成向量空间 $S$**

定义

$$
\phi:x\mapsto K(\cdot,x)。
$$

> 这一步很巧妙：**把点 $x$ 映射成一个函数** $K(\cdot,x)$（固定第二个参数得到的一元函数）。

考虑所有有限线性组合构成的集合：

$$
f(\cdot)=\sum_{i=1}^{m}\alpha_iK(\cdot,x_i)。
$$

$S$ 对加法和数乘封闭，构成向量空间。

**第二步：在 $S$ 上定义内积**

对 $f=\sum_i\alpha_iK(\cdot,x_i)$，$g=\sum_j\beta_jK(\cdot,z_j)$，定义

$$
f*g=\sum_{i=1}^{m}\sum_{j=1}^{l}\alpha_i\beta_jK(x_i,z_j)。
$$

需验证四条内积公理，其中最关键的是：

**（a）非负性 $f*f\ge0$**：

$$
f*f=\sum_{i,j}\alpha_i\alpha_jK(x_i,x_j)\ge0，
$$

这**正是 Gram 矩阵半正定**的直接结果——这就是为什么半正定是充分条件。

**（b）$f*f=0\Rightarrow f=0$**：需要用到 Cauchy-Schwarz 不等式

$$
|f*g|^2\le(f*f)(g*g)。
$$

其证明用了一个经典技巧：对任意 $\lambda\in\mathbb R$，

$$
(f+\lambda g)*(f+\lambda g)\ge0，
$$

展开是关于 $\lambda$ 的二次三项式且非负，故**判别式 $\le0$**，即得不等式。

再利用**再生性**（下面第三步）：

$$
K(\cdot,x)*f=f(x)，
$$

于是

$$
|f(x)|^2=|K(\cdot,x)*f|^2\le K(x,x)\cdot(f*f)。
$$

当 $f*f=0$ 时，对任意 $x$ 都有 $f(x)=0$，即 $f=0$ ✓

**第三步：完备化为希尔伯特空间**

由内积导出范数 $\lVert f\rVert=\sqrt{f\cdot f}$，$S$ 成为赋范向量空间。由泛函分析，不完备的赋范空间可以**完备化**，得到完备的内积空间即**希尔伯特空间** $\mathcal H$。

这个空间称为**再生核希尔伯特空间**（Reproducing Kernel Hilbert Space, RKHS），因为核 $K$ 具有**再生性**：

$$
K(\cdot,x)\cdot f=f(x),
\qquad
K(\cdot,x)\cdot K(\cdot,z)=K(x,z)。
$$

第二式正好给出

$$
K(x,z)=\phi(x)\cdot\phi(z)，
$$

充分性得证。$\blacksquare$

**定义 7.7（正定核的等价定义）** 设 $K(x,z)$ 是对称函数，若对任意 $x_1,\ldots,x_m$，Gram 矩阵均半正定，则称 $K$ 为**正定核**。

> **实用性说明**：这个定义在**构造**核函数时很有用，但**验证**一个具体函数是否正定核并不容易（要对任意有限点集验证）。实践中通常直接使用已知的核函数，或用核的**封闭性质**组合出新核：
>
> - $K_1+K_2$ 是核；
> - $cK_1$（$c>0$）是核；
> - $K_1\cdot K_2$ 是核（Schur 积定理）；
> - $f(x)K_1(x,z)f(z)$ 是核。

#### 7.4.4 常用核函数

**1. 多项式核函数**

$$
K(x,z)=(x\cdot z+1)^p。
$$

对应 $p$ 次多项式分类器：

$$
f(x)=\operatorname{sign}\left(\sum_i\alpha_i^*y_i(x_i\cdot x+1)^p+b^*\right)。
$$

**2. 高斯核函数（RBF 核）**

$$
K(x,z)=\exp\left(-\frac{\lVert x-z\rVert^2}{2\sigma^2}\right)。
$$

对应**高斯径向基函数分类器**：

$$
f(x)=\operatorname{sign}\left(\sum_i\alpha_i^*y_i
\exp\left(-\frac{\lVert x-x_i\rVert^2}{2\sigma^2}\right)+b^*\right)。
$$

> **高斯核的特征空间是无穷维的**——这可以由 $e^t$ 的泰勒展开看出。这正是核技巧威力的最好体现：无穷维空间中的线性分类，计算量却和维数无关。
>
> $\sigma$ 的作用：$\sigma$ 小 → 每个支持向量的影响范围小 → 边界复杂，易过拟合；$\sigma$ 大 → 影响范围大 → 边界平滑，趋近线性。

**3. 字符串核函数**

核函数不必定义在欧氏空间上，也可以定义在**离散集合**上。

设 $\Sigma$ 是有限字符表，$\Sigma^n$ 是长度为 $n$ 的字符串集合。定义映射 $\phi_n(s)$，其在 $u\in\Sigma^n$ 维上的取值为

$$
[\phi_n(s)]_u=\sum_{i:s(i)=u}\lambda^{l(i)}，
$$

其中 $0<\lambda\le1$ 是衰减参数，$l(i)$ 是子串在原串中占据的长度（含间隔）。

字符串核为

$$
k_n(s,t)=\sum_{u\in\Sigma^n}[\phi_n(s)]_u[\phi_n(t)]_u。
$$

**书中的例子**（$n=3$，考察维度 `asd`）：

- `"Nasdaq"` 中 `asd` 是**连续**子串，$l=3$，贡献 $\lambda^3$；
- `"lass das"` 中 `asd` 是长度为 5 的**不连续**子串，出现 2 次，贡献 $2\lambda^5$。

$\lambda<1$ 使得**间隔越大的匹配贡献越小**，符合"连续匹配更相似"的直觉。

> 直观上，两个字符串**相同的子串越多，核函数值越大**。字符串核可用动态规划快速计算，在文本分类、生物信息学中有重要应用。

#### 7.4.5 非线性支持向量机

**定义 7.8** 通过核函数与软间隔最大化学习得到的分类决策函数

$$
f(x)=\operatorname{sign}\left(\sum_{i=1}^{N}\alpha_i^*y_iK(x,x_i)+b^*\right)
$$

称为**非线性支持向量机**。

**算法 7.4（非线性支持向量机学习算法）**

1. 选取核函数 $K(x,z)$ 与参数 $C$，求解

$$
\min_\alpha\;\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_jK(x_i,x_j)-\sum_i\alpha_i
$$

$$
\text{s.t.}\;\sum_i\alpha_iy_i=0,\quad0\le\alpha_i\le C；
$$

2. 选择 $0<\alpha_j^*<C$，计算

$$
b^*=y_j-\sum_i\alpha_i^*y_iK(x_i,x_j)；
$$

3. 构造决策函数。

当 $K$ 是正定核时，该问题是**凸二次规划**，解存在。

**代码验证**（7.6 节）在环形数据（内圈正类、外圈负类，线性完全不可分）上：

| 核函数 | 训练准确率 | 支持向量数 |
| --- | ---: | ---: |
| 线性核 | 0.70 | 111 |
| **多项式核 $p=2$** | **1.00** | **6** |
| **高斯核 $\sigma=1$** | **1.00** | 13 |

线性核彻底失败（70%，且几乎所有点都成了支持向量，说明模型在"挣扎"）；多项式核 $p=2$ 完美分类且只需 **6 个**支持向量——因为环形边界 $x_1^2+x_2^2=r^2$ 恰好是 2 次的，$p=2$ 的特征空间正好包含它。

> **这个对比说明了核选择的本质**：核函数编码了我们对数据结构的**先验假设**。选对了核，问题瞬间变简单；选错了核，再多的计算也无济于事。

---

### 7.5 序列最小最优化算法（SMO）

#### 7.5.1 为什么需要 SMO

SVM 的对偶问题是凸二次规划，理论上有很多通用算法可解。但：

- 变量个数 $=N$（样本数）；
- 需要存储 $N\times N$ 的 Gram 矩阵，$N=10^5$ 时约需 **80 GB** 内存；
- 通用 QP 求解器的复杂度约 $O(N^3)$。

样本量大时完全不可行。

**SMO 的思路**（Platt, 1998）：

> 每次只选**两个**变量优化，固定其余变量。这个两变量子问题有**解析解**，不需要调用数值优化器。

**为什么是两个而不是一个？** 因为有等式约束

$$
\sum_{i=1}^{N}\alpha_iy_i=0。
$$

若只改变一个 $\alpha_1$，其余固定，则

$$
\alpha_1y_1=-\sum_{i=2}^{N}\alpha_iy_i=\text{常数}，
$$

$\alpha_1$ 被**完全确定**，根本无法优化。所以至少要同时改两个。

**SMO 的收敛依据**：若所有变量都满足 KKT 条件，则得到最优解（KKT 是该问题的**充要条件**，因为问题是凸的）。否则总能找到违反 KKT 的变量，优化它必使目标函数下降。

#### 7.5.2 两变量子问题

不失一般性，设选择 $\alpha_1,\alpha_2$ 为变量，其余固定。子问题为：

$$
\begin{aligned}
\min_{\alpha_1,\alpha_2}\;W(\alpha_1,\alpha_2)
=&\frac12K_{11}\alpha_1^2+\frac12K_{22}\alpha_2^2+y_1y_2K_{12}\alpha_1\alpha_2\\
&-(\alpha_1+\alpha_2)+y_1\alpha_1\sum_{i=3}^{N}y_i\alpha_iK_{i1}
+y_2\alpha_2\sum_{i=3}^{N}y_i\alpha_iK_{i2}
\end{aligned}
$$

$$
\text{s.t.}\quad\alpha_1y_1+\alpha_2y_2=\varsigma\;(\text{常数}),
\qquad0\le\alpha_i\le C。
$$

**几何图景**：

- 不等式约束把 $(\alpha_1,\alpha_2)$ 限制在**正方形盒子** $[0,C]\times[0,C]$ 内；
- 等式约束把它限制在一条**平行于对角线的直线**上。

```text
   y₁≠y₂: α₁-α₂=k          y₁=y₂: α₁+α₂=k
   α₂                        α₂
   C ┌─────────╱─┐           C ┌─╲───────┐
     │       ╱   │             │   ╲     │
     │     ╱     │             │     ╲   │
   0 └───╱───────┘           0 └───────╲─┘
     0         C  α₁           0         C  α₁
```

所以实质上是**一条线段上的单变量优化问题**。

#### 7.5.3 剪辑边界 $L$ 和 $H$ 的推导

设 $\alpha_2^{\text{new}}$ 的取值范围为 $[L,H]$。

**情形一：$y_1\ne y_2$**，等式约束为 $\alpha_1-\alpha_2=k$，其中 $k=\alpha_1^{\text{old}}-\alpha_2^{\text{old}}$。

由 $\alpha_1=\alpha_2+k$ 及 $0\le\alpha_1\le C$：

$$
0\le\alpha_2+k\le C
\quad\Longrightarrow\quad
-k\le\alpha_2\le C-k。
$$

与 $0\le\alpha_2\le C$ 取交集：

$$
\boxed{L=\max(0,\alpha_2^{\text{old}}-\alpha_1^{\text{old}}),
\qquad
H=\min(C,C+\alpha_2^{\text{old}}-\alpha_1^{\text{old}})}
$$

**情形二：$y_1=y_2$**，等式约束为 $\alpha_1+\alpha_2=k$，$k=\alpha_1^{\text{old}}+\alpha_2^{\text{old}}$。

由 $\alpha_1=k-\alpha_2$ 及 $0\le\alpha_1\le C$：

$$
k-C\le\alpha_2\le k。
$$

与 $0\le\alpha_2\le C$ 取交集：

$$
\boxed{L=\max(0,\alpha_1^{\text{old}}+\alpha_2^{\text{old}}-C),
\qquad
H=\min(C,\alpha_1^{\text{old}}+\alpha_2^{\text{old}})}
$$

#### 7.5.4 解析解的推导

**定理 7.6** 沿约束方向**未经剪辑**的解为

$$
\alpha_2^{\text{new,unc}}=\alpha_2^{\text{old}}+\frac{y_2(E_1-E_2)}{\eta}，
$$

其中

$$
\eta=K_{11}+K_{22}-2K_{12}=\lVert\phi(x_1)-\phi(x_2)\rVert^2，
$$

$$
g(x)=\sum_{i=1}^{N}\alpha_iy_iK(x_i,x)+b,
\qquad
E_i=g(x_i)-y_i。
$$

$E_i$ 是模型对 $x_i$ 的**预测误差**。

**$\eta$ 的几何意义**：

$$
\lVert\phi(x_1)-\phi(x_2)\rVert^2
=\phi(x_1)\cdot\phi(x_1)-2\phi(x_1)\cdot\phi(x_2)+\phi(x_2)\cdot\phi(x_2)
=K_{11}-2K_{12}+K_{22}\ \checkmark
$$

即两个样本在特征空间中的**距离平方**。$\eta>0$ 保证子问题是严格凸的（有唯一极小）；$\eta\le0$ 时需特殊处理（实践中直接跳过）。

**推导过程**。记

$$
v_i=\sum_{j=3}^{N}\alpha_jy_jK_{ij}=g(x_i)-\sum_{j=1}^{2}\alpha_jy_jK_{ij}-b,
\quad i=1,2。
$$

目标函数写成

$$
\begin{aligned}
W(\alpha_1,\alpha_2)=&\frac12K_{11}\alpha_1^2+\frac12K_{22}\alpha_2^2
+y_1y_2K_{12}\alpha_1\alpha_2\\
&-(\alpha_1+\alpha_2)+y_1v_1\alpha_1+y_2v_2\alpha_2。
\end{aligned}
$$

由 $\alpha_1y_1=\varsigma-\alpha_2y_2$ 及 $y_1^2=1$：

$$
\alpha_1=(\varsigma-y_2\alpha_2)y_1。
$$

代入消去 $\alpha_1$，得到只含 $\alpha_2$ 的函数，对 $\alpha_2$ 求导：

$$
\frac{\partial W}{\partial\alpha_2}
=(K_{11}+K_{22}-2K_{12})\alpha_2
-K_{11}\varsigma y_2+K_{12}\varsigma y_2+y_1y_2-1-v_1y_2+v_2y_2。
$$

令导数为零并整理（代入 $\varsigma=\alpha_1^{\text{old}}y_1+\alpha_2^{\text{old}}y_2$，并用 $g(x_i)$ 的定义）：

$$
(K_{11}+K_{22}-2K_{12})\alpha_2^{\text{new,unc}}
=(K_{11}+K_{22}-2K_{12})\alpha_2^{\text{old}}+y_2(E_1-E_2)，
$$

即

$$
\boxed{\alpha_2^{\text{new,unc}}=\alpha_2^{\text{old}}+\frac{y_2(E_1-E_2)}{\eta}}
$$

**剪辑**。因 $\alpha_2$ 必须落在 $[L,H]$ 内：

$$
\alpha_2^{\text{new}}=
\begin{cases}
H,&\alpha_2^{\text{new,unc}}>H,\\
\alpha_2^{\text{new,unc}},&L\le\alpha_2^{\text{new,unc}}\le H,\\
L,&\alpha_2^{\text{new,unc}}<L。
\end{cases}
$$

由等式约束求出 $\alpha_1$：

$$
\alpha_1^{\text{new}}=\alpha_1^{\text{old}}
+y_1y_2\left(\alpha_2^{\text{old}}-\alpha_2^{\text{new}}\right)。
$$

**直观理解更新式**：$E_1-E_2$ 是两个样本预测误差之差。误差差异越大，$\alpha_2$ 调整幅度越大；$\eta$ 越大（两点在特征空间中离得越远），调整越保守。

#### 7.5.5 变量的选择

**第 1 个变量（外层循环）**：选**违反 KKT 条件最严重**的样本。

KKT 条件（由 7.3.4 节的表格得到）：

$$
\begin{aligned}
\alpha_i=0&\;\Longleftrightarrow\;y_ig(x_i)\ge1\\
0<\alpha_i<C&\;\Longleftrightarrow\;y_ig(x_i)=1\\
\alpha_i=C&\;\Longleftrightarrow\;y_ig(x_i)\le1
\end{aligned}
$$

检验策略：**先遍历所有 $0<\alpha_i<C$ 的点**（间隔边界上的支持向量），若都满足 KKT，再遍历整个训练集。

> 这个顺序有讲究：边界上的支持向量最"活跃"，最可能违反 KKT，优先检查它们能加快收敛。

**第 2 个变量（内层循环）**：希望 $\alpha_2$ 有**足够大的变化**。

由更新式，变化量正比于 $|E_1-E_2|$，所以选使 $|E_1-E_2|$ **最大**的 $\alpha_2$：

- 若 $E_1>0$，选最小的 $E_i$；
- 若 $E_1<0$，选最大的 $E_i$。

为节省时间，把所有 $E_i$ 保存在列表中。

若这样选出的 $\alpha_2$ 不能使目标函数充分下降，则依次尝试：遍历间隔边界上的支持向量 → 遍历整个训练集 → 放弃 $\alpha_1$，重新选择。

#### 7.5.6 阈值 $b$ 的更新

每次优化后需重新计算 $b$。

**当 $0<\alpha_1^{\text{new}}<C$ 时**，由 KKT 条件 $y_1g(x_1)=1$：

$$
\sum_{i=1}^{N}\alpha_iy_iK_{i1}+b=y_1，
$$

$$
b_1^{\text{new}}=y_1-\sum_{i=3}^{N}\alpha_iy_iK_{i1}
-\alpha_1^{\text{new}}y_1K_{11}-\alpha_2^{\text{new}}y_2K_{21}。
$$

由 $E_1$ 的定义：

$$
E_1=\sum_{i=3}^{N}\alpha_iy_iK_{i1}+\alpha_1^{\text{old}}y_1K_{11}
+\alpha_2^{\text{old}}y_2K_{21}+b^{\text{old}}-y_1，
$$

移项得

$$
y_1-\sum_{i=3}^{N}\alpha_iy_iK_{i1}
=-E_1+\alpha_1^{\text{old}}y_1K_{11}+\alpha_2^{\text{old}}y_2K_{21}+b^{\text{old}}。
$$

代入：

$$
\boxed{
b_1^{\text{new}}=-E_1-y_1K_{11}\left(\alpha_1^{\text{new}}-\alpha_1^{\text{old}}\right)
-y_2K_{21}\left(\alpha_2^{\text{new}}-\alpha_2^{\text{old}}\right)+b^{\text{old}}}
$$

同理，当 $0<\alpha_2^{\text{new}}<C$ 时：

$$
b_2^{\text{new}}=-E_2-y_1K_{12}\left(\alpha_1^{\text{new}}-\alpha_1^{\text{old}}\right)
-y_2K_{22}\left(\alpha_2^{\text{new}}-\alpha_2^{\text{old}}\right)+b^{\text{old}}。
$$

**取值规则**：

- 若 $\alpha_1^{\text{new}},\alpha_2^{\text{new}}$ 都在 $(0,C)$ 内，则 $b_1^{\text{new}}=b_2^{\text{new}}$，取任一；
- 若都在边界（0 或 $C$），则 $b_1^{\text{new}}$ 与 $b_2^{\text{new}}$ 之间的**任何值**都满足 KKT，取**中点**。

**$E_i$ 的更新**：

$$
E_i^{\text{new}}=\sum_{S}y_j\alpha_jK(x_i,x_j)+b^{\text{new}}-y_i，
$$

其中 $S$ 是所有支持向量的集合。

#### 7.5.7 SMO 完整算法

**算法 7.5（SMO 算法）**

**输入**：训练集 $T$，精度 $\varepsilon$
**输出**：近似解 $\hat\alpha$

1. 取初值 $\alpha^{(0)}=0$，令 $k=0$；
2. 选取优化变量 $\alpha_1^{(k)},\alpha_2^{(k)}$，解析求解两变量子问题，更新为 $\alpha^{(k+1)}$；
3. 若在精度 $\varepsilon$ 内满足停机条件

$$
\sum_i\alpha_iy_i=0,\qquad0\le\alpha_i\le C,
$$

$$
y_i\cdot g(x_i)
\begin{cases}
\ge1,&\{x_i\mid\alpha_i=0\}\\
=1,&\{x_i\mid0<\alpha_i<C\}\\
\le1,&\{x_i\mid\alpha_i=C\}
\end{cases}
$$

则转 4；否则 $k\leftarrow k+1$，转 2；

4. 取 $\hat\alpha=\alpha^{(k+1)}$。

**为什么 SMO 高效？**

| | 通用 QP | SMO |
| --- | --- | --- |
| 每步代价 | $O(N^3)$ | **$O(N)$**（解析解） |
| 内存 | $O(N^2)$ | **$O(N)$**（可不存 Gram 矩阵） |
| 迭代次数 | 少 | 多 |
| 总体 | 大 $N$ 时不可行 | **高效** |

> 虽然子问题次数很多，但每次都是**解析计算**，没有数值迭代，所以总体上非常快。这是"用大量廉价步骤代替少量昂贵步骤"的典型设计。

---

### 7.6 代码实现与验证

```python
"""支持向量机（《统计学习方法》第 7 章）：SMO 算法 + 核技巧"""
import math
import random


def linear_kernel(x, z):
    """线性核 K(x,z) = x·z"""
    return sum(a * b for a, b in zip(x, z))


def polynomial_kernel(p):
    """多项式核 K(x,z) = (x·z + 1)^p"""
    return lambda x, z: (sum(a * b for a, b in zip(x, z)) + 1) ** p


def gaussian_kernel(sigma):
    """高斯核 K(x,z) = exp(-||x-z||^2 / (2σ²))"""
    return lambda x, z: math.exp(
        -sum((a - b) ** 2 for a, b in zip(x, z)) / (2 * sigma ** 2))


class SVM:
    """支持向量机，用 SMO 训练。C 取很大时即硬间隔。"""

    def __init__(self, X, Y, C=1.0, kernel=linear_kernel, tol=1e-6):
        self.X, self.Y, self.C, self.kf, self.tol = X, Y, C, kernel, tol
        self.N = len(X)
        self.a = [0.0] * self.N          # 拉格朗日乘子 α
        self.b = 0.0
        # 预计算 Gram 矩阵（大规模场景应改为按需计算 + 缓存）
        self.K = [[kernel(X[i], X[j]) for j in range(self.N)]
                  for i in range(self.N)]

    def g(self, i):
        """g(x_i) = Σ α_j y_j K(x_j, x_i) + b"""
        return sum(self.a[j] * self.Y[j] * self.K[j][i]
                   for j in range(self.N)) + self.b

    def E(self, i):
        """预测误差 E_i = g(x_i) - y_i"""
        return self.g(i) - self.Y[i]

    def _bounds(self, i1, i2):
        """计算剪辑边界 [L, H]（7.5.3 节）"""
        a1, a2 = self.a[i1], self.a[i2]
        if self.Y[i1] != self.Y[i2]:            # α₁ - α₂ = k
            return max(0.0, a2 - a1), min(self.C, self.C + a2 - a1)
        return max(0.0, a2 + a1 - self.C), min(self.C, a2 + a1)   # α₁ + α₂ = k

    def _take_step(self, i1, i2):
        """优化一对 (α_{i1}, α_{i2})，成功返回 True"""
        if i1 == i2:
            return False
        a1_old, a2_old = self.a[i1], self.a[i2]
        y1, y2 = self.Y[i1], self.Y[i2]
        E1, E2 = self.E(i1), self.E(i2)

        L, H = self._bounds(i1, i2)
        if H - L < 1e-12:
            return False

        # η = K11 + K22 - 2K12 = ||φ(x1) - φ(x2)||²
        eta = self.K[i1][i1] + self.K[i2][i2] - 2 * self.K[i1][i2]
        if eta < 1e-12:                          # 非正定情形，跳过
            return False

        # 未剪辑解 + 剪辑（定理 7.6）
        a2_new = a2_old + y2 * (E1 - E2) / eta
        a2_new = min(H, max(L, a2_new))
        if abs(a2_new - a2_old) < 1e-10:
            return False
        a1_new = a1_old + y1 * y2 * (a2_old - a2_new)

        # 更新阈值 b（7.5.6 节）
        b1 = (-E1 - y1 * self.K[i1][i1] * (a1_new - a1_old)
              - y2 * self.K[i2][i1] * (a2_new - a2_old) + self.b)
        b2 = (-E2 - y1 * self.K[i1][i2] * (a1_new - a1_old)
              - y2 * self.K[i2][i2] * (a2_new - a2_old) + self.b)
        if 0 < a1_new < self.C:
            self.b = b1
        elif 0 < a2_new < self.C:
            self.b = b2
        else:
            self.b = (b1 + b2) / 2               # 都在边界上，取中点

        self.a[i1], self.a[i2] = a1_new, a2_new
        return True

    def _violates_kkt(self, i):
        """检验样本 i 是否违反 KKT 条件（7.5.5 节）"""
        r = self.Y[i] * self.g(i) - 1
        return ((self.a[i] < self.C - self.tol and r < -self.tol) or
                (self.a[i] > self.tol and r > self.tol))

    def fit(self, max_iter=200):
        examine_all = True
        for _ in range(max_iter):
            changed = 0
            # 外层循环：优先检查间隔边界上的支持向量
            idx = (range(self.N) if examine_all else
                   [i for i in range(self.N)
                    if self.tol < self.a[i] < self.C - self.tol])
            for i1 in idx:
                if not self._violates_kkt(i1):
                    continue
                E1 = self.E(i1)
                # 内层循环：选 |E1 - E2| 最大的 α₂
                for i2 in sorted(range(self.N),
                                 key=lambda j: -abs(E1 - self.E(j))):
                    if self._take_step(i1, i2):
                        changed += 1
                        break
            if examine_all:
                examine_all = False
            elif changed == 0:
                examine_all = True
            if changed == 0 and examine_all:
                break
        return self

    def decision(self, x):
        """f(x) = Σ α_i y_i K(x_i, x) + b"""
        return sum(self.a[j] * self.Y[j] * self.kf(self.X[j], x)
                   for j in range(self.N)) + self.b

    def predict(self, x):
        return 1 if self.decision(x) >= 0 else -1

    def support_vectors(self):
        return [i for i in range(self.N) if self.a[i] > 1e-6]

    def weight(self):
        """仅线性核有意义：w = Σ α_i y_i x_i"""
        d = len(self.X[0])
        return [sum(self.a[i] * self.Y[i] * self.X[i][k]
                    for i in range(self.N)) for k in range(d)]


def show(title):
    print("\n" + "=" * 58)
    print(title)
    print("=" * 58)


show("【例 7.1 / 7.2】硬间隔 SVM")
X = [(3, 3), (4, 3), (1, 1)]
Y = [1, 1, -1]
m = SVM(X, Y, C=1e8).fit()          # C 很大 ≈ 硬间隔
w = m.weight()
print(f"  α = {[round(v, 6) for v in m.a]}      (期望 [0.25, 0, 0.25])")
print(f"  w = [{w[0]:.6f}, {w[1]:.6f}]   b = {m.b:.6f}"
      f"   (期望 w=[0.5,0.5], b=-2)")
nw = math.hypot(*w)
print(f"  ||w|| = {nw:.6f}   间隔 2/||w|| = {2/nw:.6f}"
      f"  (= 2√2 = {2*math.sqrt(2):.6f})")
print("  各点函数间隔：")
for i, (xi, yi) in enumerate(zip(X, Y), 1):
    fx = m.decision(xi)
    tag = "  <- 支持向量" if abs(yi * fx - 1) < 1e-5 else ""
    print(f"    x{i}={xi}  y={yi:+d}  f(x)={fx:+.4f}  "
          f"y·f(x)={yi*fx:.4f}{tag}")

show("【习题 7.2】求最大间隔分离超平面")
X2 = [(1, 2), (2, 3), (3, 3), (2, 1), (3, 2)]
Y2 = [1, 1, 1, -1, -1]
m2 = SVM(X2, Y2, C=1e8).fit()
w2 = m2.weight()
print(f"  α = {[round(v, 6) for v in m2.a]}")
print(f"  w = [{w2[0]:.6f}, {w2[1]:.6f}]   b = {m2.b:.6f}")
print(f"  分离超平面：{w2[0]:.0f}·x1 + {w2[1]:.0f}·x2 + {m2.b:.0f} = 0")
nw2 = math.hypot(*w2)
print(f"  ||w|| = {nw2:.6f}   间隔 = {2/nw2:.6f}")
print("  各点函数间隔：")
for i, (xi, yi) in enumerate(zip(X2, Y2), 1):
    fx = m2.decision(xi)
    tag = "  <- 支持向量" if abs(yi * fx - 1) < 1e-5 else ""
    print(f"    x{i}={xi}  y={yi:+d}  y·f(x)={yi*fx:.4f}  "
          f"α={m2.a[i-1]:.4f}{tag}")
print(f"  约束 Σα·y = {sum(m2.a[i]*Y2[i] for i in range(5)):.2e}")

show("【核技巧】环形数据（线性完全不可分）")
random.seed(7)
Xc, Yc = [], []
for _ in range(60):                             # 内圈：正类
    r, t = random.uniform(0, 1.0), random.uniform(0, 2 * math.pi)
    Xc.append((r * math.cos(t), r * math.sin(t)))
    Yc.append(1)
for _ in range(60):                             # 外环：负类
    r, t = random.uniform(1.8, 2.8), random.uniform(0, 2 * math.pi)
    Xc.append((r * math.cos(t), r * math.sin(t)))
    Yc.append(-1)

for name, kf in [("线性核", linear_kernel),
                 ("多项式核 p=2", polynomial_kernel(2)),
                 ("高斯核 σ=1", gaussian_kernel(1.0))]:
    mk = SVM(Xc, Yc, C=10.0, kernel=kf).fit()
    acc = sum(mk.predict(Xc[i]) == Yc[i] for i in range(len(Yc))) / len(Yc)
    print(f"  {name:<14s} 训练准确率 = {acc:.4f}   "
          f"支持向量数 = {len(mk.support_vectors())}")

show("【定理 7.5】核函数的 Gram 矩阵半正定性")

def min_eigenvalue(M):
    """幂法估计对称矩阵最小特征值"""
    n = len(M)
    c = max(sum(abs(v) for v in row) for row in M)
    B = [[(c if i == j else 0) - M[i][j] for j in range(n)] for i in range(n)]
    v = [random.random() for _ in range(n)]
    for _ in range(5000):
        w_ = [sum(B[i][j] * v[j] for j in range(n)) for i in range(n)]
        nv = math.sqrt(sum(t * t for t in w_))
        if nv < 1e-300:
            return 0.0
        v = [t / nv for t in w_]
    lam = sum(v[i] * sum(B[i][j] * v[j] for j in range(n)) for i in range(n))
    return c - lam

random.seed(1)
pts = [[random.uniform(-2, 2) for _ in range(3)] for _ in range(6)]
for name, kf in [("线性核", linear_kernel),
                 ("多项式核 p=3", polynomial_kernel(3)),
                 ("高斯核 σ=1", gaussian_kernel(1.0))]:
    G = [[kf(x, z) for z in pts] for x in pts]
    print(f"  {name:<14s} 最小特征值 = {min_eigenvalue(G):+.3e}  (应 ≥ 0)")

show("【习题 7.4】K(x,z)=(x·z)² 的显式特征映射")
def phi2(x):
    return (x[0] ** 2, math.sqrt(2) * x[0] * x[1], x[1] ** 2)

for _ in range(3):
    x = [random.uniform(-2, 2) for _ in range(2)]
    z = [random.uniform(-2, 2) for _ in range(2)]
    lhs = (x[0] * z[0] + x[1] * z[1]) ** 2
    rhs = sum(a * b for a, b in zip(phi2(x), phi2(z)))
    print(f"  K(x,z) = {lhs:.10f}   φ(x)·φ(z) = {rhs:.10f}   "
          f"差 = {abs(lhs-rhs):.1e}")

show("【损失函数对比】z = y·f(x)")
print("     z      0-1 损失   感知机   合页损失   逻辑斯谛")
for z in [-2, -1, -0.5, 0, 0.5, 1, 1.5, 2]:
    l01 = 1.0 if z <= 0 else 0.0
    lp = max(0.0, -z)
    lh = max(0.0, 1 - z)
    ll = math.log(1 + math.exp(-z)) / math.log(2)
    print(f"   {z:+.1f}      {l01:.2f}      {lp:.2f}      "
          f"{lh:.2f}       {ll:.2f}")
```

**运行结果：**

```text
==========================================================
【例 7.1 / 7.2】硬间隔 SVM
==========================================================
  α = [0.25, 0.0, 0.25]      (期望 [0.25, 0, 0.25])
  w = [0.500000, 0.500000]   b = -2.000000   (期望 w=[0.5,0.5], b=-2)
  ||w|| = 0.707107   间隔 2/||w|| = 2.828427  (= 2√2 = 2.828427)
  各点函数间隔：
    x1=(3, 3)  y=+1  f(x)=+1.0000  y·f(x)=1.0000  <- 支持向量
    x2=(4, 3)  y=+1  f(x)=+1.5000  y·f(x)=1.5000
    x3=(1, 1)  y=-1  f(x)=-1.0000  y·f(x)=1.0000  <- 支持向量

==========================================================
【习题 7.2】求最大间隔分离超平面
==========================================================
  α = [0.5, 0.0, 2.0, 0.0, 2.5]
  w = [-1.000000, 2.000000]   b = -2.000000
  分离超平面：-1·x1 + 2·x2 + -2 = 0
  ||w|| = 2.236068   间隔 = 0.894427
  各点函数间隔：
    x1=(1, 2)  y=+1  y·f(x)=1.0000  α=0.5000  <- 支持向量
    x2=(2, 3)  y=+1  y·f(x)=2.0000  α=0.0000
    x3=(3, 3)  y=+1  y·f(x)=1.0000  α=2.0000  <- 支持向量
    x4=(2, 1)  y=-1  y·f(x)=2.0000  α=0.0000
    x5=(3, 2)  y=-1  y·f(x)=1.0000  α=2.5000  <- 支持向量
  约束 Σα·y = 0.00e+00

==========================================================
【核技巧】环形数据（线性完全不可分）
==========================================================
  线性核            训练准确率 = 0.7000   支持向量数 = 111
  多项式核 p=2       训练准确率 = 1.0000   支持向量数 = 6
  高斯核 σ=1        训练准确率 = 1.0000   支持向量数 = 13

==========================================================
【定理 7.5】核函数的 Gram 矩阵半正定性
==========================================================
  线性核            最小特征值 = -3.553e-15  (应 ≥ 0)
  多项式核 p=3       最小特征值 = +5.678e+00  (应 ≥ 0)
  高斯核 σ=1        最小特征值 = +5.985e-01  (应 ≥ 0)

==========================================================
【习题 7.4】K(x,z)=(x·z)² 的显式特征映射
==========================================================
  K(x,z) = 0.2350852473   φ(x)·φ(z) = 0.2350852473   差 = 8.3e-17
  K(x,z) = 15.6118474242   φ(x)·φ(z) = 15.6118474242   差 = 1.8e-15
  K(x,z) = 1.6471945891   φ(x)·φ(z) = 1.6471945891   差 = 2.2e-16

==========================================================
【损失函数对比】z = y·f(x)
==========================================================
     z      0-1 损失   感知机   合页损失   逻辑斯谛
   -2.0      1.00      2.00      3.00       3.07
   -1.0      1.00      1.00      2.00       1.89
   -0.5      1.00      0.50      1.50       1.41
   +0.0      1.00      0.00      1.00       1.00
   +0.5      0.00      0.00      0.50       0.68
   +1.0      0.00      0.00      0.00       0.45
   +1.5      0.00      0.00      0.00       0.29
   +2.0      0.00      0.00      0.00       0.18
```

> **Windows 运行提示**：若报 `UnicodeEncodeError`，执行前设置 `$env:PYTHONIOENCODING = "utf-8"`。

**代码验证的五个结论：**

| 结论 | 证据 |
| --- | --- |
| SMO 正确实现 | 例 7.1 精确复现 $\alpha=(\frac14,0,\frac14)$、$w=(\frac12,\frac12)$、$b=-2$ |
| 只有支持向量决定超平面 | $x_2$ 的 $\alpha=0$，删掉它解不变 |
| **核技巧的威力** | **线性核 70%，多项式核 $p=2$ 达 100% 且仅 6 个支持向量** |
| 核函数半正定 | 三种核的 Gram 矩阵最小特征值均 $\ge0$ |
| 合页损失要求更高 | $z=0.5$ 时感知机损失为 0，合页损失仍有 0.5 |

---

### 7.7 深入理解

#### 7.7.1 SVM 与前几章方法的统一视角

所有线性分类器都可以写成

$$
\min_{w,b}\;\sum_{i=1}^{N}L\bigl(y_i(w\cdot x_i+b)\bigr)+\lambda\lVert w\rVert^2，
$$

区别只在损失函数 $L(z)$：

| 模型 | 损失 $L(z)$ | 正则 | 解的性质 |
| --- | --- | --- | --- |
| 感知机 | $\max(0,-z)$ | 无 | 不唯一 |
| **SVM** | $\max(0,1-z)$ | $L_2$ | **唯一，稀疏** |
| 逻辑斯谛回归 | $\log(1+e^{-z})$ | $L_2$ | 唯一，不稀疏 |
| AdaBoost（第 8 章） | $e^{-z}$ | 无显式 | — |

**SVM 解的稀疏性从何而来？** 来自合页损失的**平坦段**：当 $z>1$ 时损失恒为 0，导数也为 0，这些样本对解**毫无贡献**（$\alpha_i=0$）。而逻辑斯谛损失永远大于 0、导数永不为 0，所以**所有**样本都参与决定 $w$。

$$
\text{合页损失有平坦段}\;\Longrightarrow\;\text{支持向量稀疏}
$$

#### 7.7.2 为什么间隔最大化能提升泛化

三个层面的理解：

**（1）几何直觉**：间隔大意味着决策边界离两类都远，训练数据的小扰动不会改变分类结果，模型更**稳健**。

**（2）正则化视角**：目标 $\min\frac12\lVert w\rVert^2$ 就是 $L_2$ 正则化。由第 1 章，这限制了模型复杂度。

**（3）统计学习理论**：Vapnik 证明，间隔为 $\gamma$、数据落在半径 $R$ 的球内时，分类器的 VC 维满足

$$
h\le\min\left(\left\lceil\frac{R^2}{\gamma^2}\right\rceil,n\right)+1。
$$

**关键点**：这个上界**与特征空间维数 $n$ 无关**（当 $R^2/\gamma^2<n$ 时）。这解释了为什么核 SVM 能在无穷维特征空间中工作而不必然过拟合——真正控制复杂度的是**间隔**，不是维数。

> 对比第 2 章 Novikoff 定理的误分类次数上界 $k\le(R/\gamma)^2$——**同样的 $R^2/\gamma^2$ 又出现了**。间隔与半径之比是刻画线性分类问题难度的核心量。

#### 7.7.3 核方法的普适性

核技巧不限于 SVM。**任何只依赖样本内积的线性算法都能核化**：

| 线性算法 | 核化版本 |
| --- | --- |
| 感知机（第 2 章对偶形式） | 核感知机 |
| 主成分分析（第 16 章） | 核 PCA |
| $k$ 均值（第 14 章） | 核 $k$ 均值 |
| 线性判别分析 | 核 LDA |
| 岭回归 | 核岭回归 |

**核化的通用步骤**：

1. 把算法写成**对偶形式**，使样本只以内积出现；
2. 把内积 $x_i\cdot x_j$ 替换为 $K(x_i,x_j)$。

> 第 2 章讲感知机对偶形式时提到"这为核化提供了入口"——本章兑现了这个伏笔。

#### 7.7.4 实践要点

**核与参数的选择**：

| 情形 | 建议 |
| --- | --- |
| 特征维数 $n$ 很大（如文本） | **线性核**（数据往往已线性可分） |
| 样本数 $N$ 大、$n$ 小 | 高斯核 |
| $N$ 很大（$>10^5$） | 线性 SVM（LIBLINEAR）或 SGD |
| 不确定 | 先试线性核作基线，再试高斯核 |

**$C$ 与 $\sigma$ 的调参**：通常在对数网格上做交叉验证，如

$$
C\in\{2^{-5},2^{-3},\ldots,2^{15}\},
\qquad
\gamma=\frac{1}{2\sigma^2}\in\{2^{-15},\ldots,2^{3}\}。
$$

**特征缩放是必需的**。核函数依赖内积或距离，量纲不一致会让大尺度特征主导。这与第 3 章 $k$-NN 的情况相同。

**多分类**。SVM 本质是二分类器，多分类需要：

- **一对一**（OvO）：训练 $\frac{K(K-1)}{2}$ 个分类器，投票；LIBSVM 采用此法；
- **一对多**（OvR）：训练 $K$ 个分类器，取得分最高者。

**类别不平衡**：可对不同类别使用不同的 $C_+$ 与 $C_-$。

#### 7.7.5 SVM 的优缺点

**优点**：

- 有**唯一全局最优解**（凸问题），不像神经网络有局部极小；
- 解**稀疏**，只依赖支持向量，模型紧凑；
- 通过核可处理**高维甚至无穷维**特征空间；
- 有**扎实的理论保证**（间隔与泛化界）；
- 小样本、高维场景表现优异。

**缺点**：

- 训练复杂度约 $O(N^2)\sim O(N^3)$，**大规模数据吃力**；
- 需存储核矩阵，内存开销大；
- **不直接输出概率**（需 Platt scaling 校准）；
- 对核与参数的选择**敏感**；
- 多分类需额外策略。

> **历史地位**：SVM 在 1995–2010 年间是最主流的分类方法。深度学习兴起后，在大规模感知任务上被取代，但在**中小样本、高维结构化数据**（如生物信息、文本分类）上仍有竞争力。更重要的是，它的**核方法**与**间隔理论**已成为机器学习的基础工具。

---

### 7.8 本章方法论总结

#### 7.8.1 用三要素分析 SVM

**模型**

$$
f(x)=\operatorname{sign}\left(\sum_{i=1}^{N}\alpha_i^*y_iK(x,x_i)+b^*\right)。
$$

属于**判别**、**非概率**模型。线性核时是参数化模型，高斯核时是非参数化模型（复杂度随样本增长）。

**策略**

间隔最大化，等价于正则化的合页损失最小化：

$$
\min_{w,b}\;\sum_{i=1}^{N}\bigl[1-y_i(w\cdot x_i+b)\bigr]_++\lambda\lVert w\rVert^2。
$$

**算法**

凸二次规划。小规模用通用 QP 求解器，大规模用 **SMO**（每次解析求解两变量子问题）。

#### 7.8.2 必须掌握的结论

1. 函数间隔 $\hat\gamma_i=y_i(w\cdot x_i+b)$ 会随参数缩放而变，几何间隔 $\gamma_i=\hat\gamma_i/\lVert w\rVert$ **不变**。
2. 令 $\hat\gamma=1$ 是**消除参数尺度冗余**，产生等价问题，不是额外假设。
3. 硬间隔原始问题 $\min\frac12\lVert w\rVert^2$ s.t. $y_i(w\cdot x_i+b)\ge1$ 是凸二次规划，解**存在且唯一**。
4. 间隔 $=\dfrac{2}{\lVert w\rVert}$，故最小化 $\lVert w\rVert$ 即最大化间隔。
5. 转对偶的两个理由：更易求解；**自然引入核函数**。第二点是决定性的。
6. 对偶推导给出 $w=\sum_i\alpha_iy_ix_i$ 和 $\sum_i\alpha_iy_i=0$，前者说明 $w$ 是样本的线性组合。
7. **KKT 互补松弛** $\alpha_i^*[y_i(w^*\cdot x_i+b^*)-1]=0$ 是核心，它给出 $\alpha_i^*>0\Leftrightarrow$ 支持向量。
8. 只有支持向量决定超平面；删除其他样本解不变。
9. 软间隔引入 $\xi_i$ 与惩罚 $C$；$C$ 大易过拟合，$C$ 小易欠拟合，$C\to\infty$ 退化为硬间隔。
10. **软间隔对偶中的上界 $0\le\alpha_i\le C$ 来自 $C-\alpha_i-\mu_i=0$ 与 $\mu_i\ge0$**，不是人为规定。
11. 软间隔对偶与硬间隔**目标函数完全相同**，只多了上界约束——引入 $N$ 个 $\xi$ 却没增加对偶变量。
12. 软间隔支持向量按 $\alpha_i$ 与 $\xi_i$ 分为五种情形；计算 $b^*$ 必须选 $0<\alpha_j^*<C$ 的样本。
13. SVM 等价于最小化**合页损失 + $L_2$ 正则**；合页损失是 0-1 损失的凸上界（代理损失）。
14. 合页损失比感知机损失要求更高：不仅要分对，还要间隔 $\ge1$。
15. 核函数 $K(x,z)=\phi(x)\cdot\phi(z)$；核技巧是**只定义 $K$ 而不显式定义 $\phi$**。
16. 同一个核对应的 $\phi$ 和 $\mathcal H$ **不唯一**。
17. **正定核充要条件**：对称 + 任意 Gram 矩阵半正定。充分性通过构造 RKHS 证明。
18. 高斯核对应**无穷维**特征空间，但计算量与维数无关。
19. SMO 每次优化**两个**变量（因等式约束，一个变量无法独立变动），子问题有**解析解**。
20. $\eta=K_{11}+K_{22}-2K_{12}=\lVert\phi(x_1)-\phi(x_2)\rVert^2$，更新量 $\propto(E_1-E_2)/\eta$。
21. 第 1 个变量选违反 KKT 最严重者，第 2 个选使 $|E_1-E_2|$ 最大者。
22. 间隔最大化的泛化保证：VC 维上界 $\propto R^2/\gamma^2$，**与特征空间维数无关**。

---

### 7.9 习题思路与推导

#### 习题 7.1：比较感知机与线性可分 SVM 的对偶形式

**（一）两者的对偶形式**

**感知机对偶形式**（第 2 章）：

$$
w=\sum_{i=1}^{N}\alpha_iy_ix_i,
\qquad
b=\sum_{i=1}^{N}\alpha_iy_i，
$$

$$
f(x)=\operatorname{sign}\left(\sum_{j=1}^{N}\alpha_jy_j(x_j\cdot x)+b\right)。
$$

其中 $\alpha_i=n_i\eta$，$n_i$ 是样本 $i$ 被误分类而触发更新的**次数**。

更新规则：若 $y_i\left(\sum_j\alpha_jy_j(x_j\cdot x_i)+b\right)\le0$，则

$$
\alpha_i\leftarrow\alpha_i+\eta,\qquad b\leftarrow b+\eta y_i。
$$

**SVM 对偶形式**：

$$
w^*=\sum_{i=1}^{N}\alpha_i^*y_ix_i,
\qquad
b^*=y_j-\sum_i\alpha_i^*y_i(x_i\cdot x_j)，
$$

其中 $\alpha^*$ 由凸二次规划确定：

$$
\min_\alpha\;\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)-\sum_i\alpha_i
$$

$$
\text{s.t.}\quad\sum_i\alpha_iy_i=0,\quad\alpha_i\ge0。
$$

**（二）相同点**

1. **形式相同**：$w$ 都是训练样本的线性组合 $\sum\alpha_iy_ix_i$，且 $\alpha_i\ge0$；
2. **只依赖内积**：决策函数都只涉及 $x_i\cdot x_j$，因此**都可以核化**；
3. 都是线性分类器，模型形式均为 $\operatorname{sign}(w\cdot x+b)$；
4. 都可以只用"重要"样本表示（感知机是曾被误分类的点，SVM 是支持向量）。

**（三）不同点**

| 维度 | 感知机对偶 | SVM 对偶 |
| --- | --- | --- |
| $\alpha_i$ 的含义 | **更新次数** $\times\eta$ | **拉格朗日乘子** |
| $\alpha_i$ 的确定 | 由迭代过程决定 | 由**优化问题**唯一确定 |
| 约束 | 仅 $\alpha_i\ge0$ | 还有 $\sum\alpha_iy_i=0$（软间隔另有 $\alpha_i\le C$） |
| $b$ 的形式 | $b=\sum\alpha_iy_i$ | $b=y_j-\sum\alpha_iy_i(x_i\cdot x_j)$ |
| $\alpha_i>0$ 的样本 | 曾被**误分类**的点 | **支持向量**（在间隔边界上） |
| 解 | **不唯一**（依赖初值、顺序） | **唯一** |
| 目标 | 分对即可 | **间隔最大** |
| 学习方式 | 在线、误分类驱动 | 批量、全局优化 |
| 不可分数据 | **不收敛**（震荡） | 软间隔仍可解 |

**（四）本质区别**

两者的模型空间**完全相同**，区别在于**从可行解集合中挑哪一个**：

$$
\text{感知机：任意可行解}
\qquad
\text{SVM：间隔最大的那个}
$$

感知机的 $b=\sum\alpha_iy_i$ 也值得注意——它来自"$b$ 每次与 $w$ 同步更新"，而 SVM 的 $b$ 由 KKT 条件导出。

> **一个有意思的联系**：感知机的 $\alpha_i$ 记录了"这个样本有多难分"（被误分类次数越多值越大），SVM 的 $\alpha_i$ 则度量"这个样本对边界有多重要"。两者在直觉上是相通的——难分的样本往往就是靠近边界的样本。

#### 习题 7.2：求最大间隔分离超平面

**数据**：正例 $x_1=(1,2)^\top$，$x_2=(2,3)^\top$，$x_3=(3,3)^\top$；负例 $x_4=(2,1)^\top$，$x_5=(3,2)^\top$。

**求解**（代码用 SMO 求得，下面给出验证）：

$$
\alpha^*=\left(0.5,\;0,\;2.0,\;0,\;2.5\right)^\top，
$$

$$
w^*=\sum_i\alpha_i^*y_ix_i
=0.5\binom12+2\binom33-2.5\binom32
=\binom{-1}{2}，
$$

$$
b^*=-2。
$$

**分离超平面**：

$$
\boxed{-x^{(1)}+2x^{(2)}-2=0}
$$

**分类决策函数**：

$$
f(x)=\operatorname{sign}\left(-x^{(1)}+2x^{(2)}-2\right)。
$$

**验证所有约束**：

| 点 | $y_i$ | $w\cdot x_i+b$ | $y_i(w\cdot x_i+b)$ | $\alpha_i^*$ | 支持向量 |
| --- | ---: | ---: | ---: | ---: | :---: |
| $x_1=(1,2)$ | $+1$ | $-1+4-2=1$ | $1$ | $0.5$ | **是** |
| $x_2=(2,3)$ | $+1$ | $-2+6-2=2$ | $2$ | $0$ | 否 |
| $x_3=(3,3)$ | $+1$ | $-3+6-2=1$ | $1$ | $2.0$ | **是** |
| $x_4=(2,1)$ | $-1$ | $-2+2-2=-2$ | $2$ | $0$ | 否 |
| $x_5=(3,2)$ | $-1$ | $-3+4-2=-1$ | $1$ | $2.5$ | **是** |

所有 $y_i(w\cdot x_i+b)\ge1$ ✓，等式约束 $\sum\alpha_i^*y_i=0.5+2.0-2.5=0$ ✓

**间隔**：

$$
\lVert w^*\rVert=\sqrt{(-1)^2+2^2}=\sqrt5\approx2.236，
$$

$$
\text{margin}=\frac{2}{\sqrt5}\approx0.894。
$$

**图示**：

```text
 x₂
  4 │
    │        ○x₂(2,3)      间隔边界 H₁: -x₁+2x₂-2=1
  3 │    ╱      ●x₃(3,3)   分离超平面: -x₁+2x₂-2=0
    │  ╱  ╱   ╱            间隔边界 H₂: -x₁+2x₂-2=-1
  2 │●x₁(1,2) ╱  ●x₅(3,2)
    │  ╱   ╱  ╱
  1 │╱   ×x₄(2,1)
    │  ╱
  0 └────┴────┴────┴──── x₁
    0    1    2    3

  ● = 支持向量 (x₁, x₃, x₅)
  ○/× = 非支持向量 (x₂, x₄)
```

三个支持向量 $x_1,x_3,x_5$ 完全决定了超平面；$x_2,x_4$ 即使删除，解也不变。

#### 习题 7.3：$L_2$ 松弛的线性 SVM 对偶形式

**原始问题**：

$$
\min_{w,b,\xi}\;\frac12\lVert w\rVert^2+C\sum_{i=1}^{N}\xi_i^2
$$

$$
\text{s.t.}\quad y_i(w\cdot x_i+b)\ge1-\xi_i,
\qquad\xi_i\ge0。
$$

与标准 SVM 的区别：惩罚项是 $\xi_i^2$ 而非 $\xi_i$（称为 **$L_2$-SVM** 或平方合页损失 SVM）。

**（一）拉格朗日函数**

$$
\begin{aligned}
L=&\frac12\lVert w\rVert^2+C\sum_i\xi_i^2\\
&-\sum_i\alpha_i\bigl[y_i(w\cdot x_i+b)-1+\xi_i\bigr]
-\sum_i\mu_i\xi_i，
\end{aligned}
$$

其中 $\alpha_i\ge0$，$\mu_i\ge0$。

**（二）对 $w,b,\xi$ 求偏导**

$$
\frac{\partial L}{\partial w}=w-\sum_i\alpha_iy_ix_i=0
\;\Longrightarrow\;
w=\sum_i\alpha_iy_ix_i，
$$

$$
\frac{\partial L}{\partial b}=-\sum_i\alpha_iy_i=0
\;\Longrightarrow\;
\sum_i\alpha_iy_i=0，
$$

$$
\frac{\partial L}{\partial\xi_i}=2C\xi_i-\alpha_i-\mu_i=0
\;\Longrightarrow\;
\boxed{\xi_i=\frac{\alpha_i+\mu_i}{2C}}
$$

**关键差异**：标准 SVM 得到的是 $C-\alpha_i-\mu_i=0$（不含 $\xi$，故产生上界 $\alpha_i\le C$）；这里得到的是 $\xi_i$ 的**表达式**，$\xi$ 不会自动消失。

**（三）代回消元**

含 $\xi$ 的项为：

$$
\begin{aligned}
C\sum_i\xi_i^2-\sum_i(\alpha_i+\mu_i)\xi_i
&=C\sum_i\xi_i^2-\sum_i2C\xi_i\cdot\xi_i\\
&=-C\sum_i\xi_i^2\\
&=-C\sum_i\frac{(\alpha_i+\mu_i)^2}{4C^2}
=-\sum_i\frac{(\alpha_i+\mu_i)^2}{4C}。
\end{aligned}
$$

（第二步用了 $\alpha_i+\mu_i=2C\xi_i$。）

其余部分与标准推导相同，得

$$
\max_{\alpha,\mu}\;-\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)
+\sum_i\alpha_i-\sum_i\frac{(\alpha_i+\mu_i)^2}{4C}。
$$

**（四）消去 $\mu_i$**

$\mu_i$ 只出现在 $-\dfrac{(\alpha_i+\mu_i)^2}{4C}$ 中，且要**最大化**目标，故应取 $\mu_i$ 尽可能小。由 $\mu_i\ge0$：

$$
\mu_i=0。
$$

> 注意此时 $\xi_i=\dfrac{\alpha_i}{2C}\ge0$ 自动满足，所以约束 $\xi_i\ge0$ 是**冗余**的——这也是 $L_2$-SVM 常省略该约束的原因。

**（五）最终对偶问题**

$$
\min_\alpha\;\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j(x_i\cdot x_j)
-\sum_i\alpha_i+\sum_i\frac{\alpha_i^2}{4C}
$$

$$
\text{s.t.}\quad\sum_i\alpha_iy_i=0,\qquad\alpha_i\ge0。
$$

**（六）一个漂亮的改写**

注意到

$$
\sum_i\frac{\alpha_i^2}{4C}
=\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j\cdot\frac{\delta_{ij}}{2C}
$$

（因为 $i=j$ 时 $y_iy_j=y_i^2=1$）。于是对偶问题可写成

$$
\boxed{
\begin{aligned}
\min_\alpha\quad&\frac12\sum_i\sum_j\alpha_i\alpha_jy_iy_j
\left[(x_i\cdot x_j)+\frac{\delta_{ij}}{2C}\right]-\sum_i\alpha_i\\
\text{s.t.}\quad&\sum_i\alpha_iy_i=0,\qquad\alpha_i\ge0
\end{aligned}}
$$

**结论**：$L_2$-SVM 的对偶就是**标准 SVM 的对偶**，只需

1. 把核矩阵改为 $K'=K+\dfrac{1}{2C}I$（**对角线加一个正数**）；
2. **去掉上界约束** $\alpha_i\le C$。

**（七）数值验证**

代码在一份线性不可分数据上对比：

- **(A)** 直接对原始问题（平方合页损失）做梯度下降：$w=[-0.658759,\;1.111172]$，$b=-0.591172$
- **(B)** 求解上述对偶（修正核、无上界）：$w=[-0.658759,\;1.111172]$，$b=-0.591172$

两者差异 $1.47\times10^{-14}$，**推导正确**。

**（八）$L_1$ 与 $L_2$ 松弛的对比**

| | $L_1$-SVM（标准） | $L_2$-SVM |
| --- | --- | --- |
| 损失 | 合页 $[1-z]_+$ | 平方合页 $[1-z]_+^2$ |
| 对偶约束 | $0\le\alpha_i\le C$ | $\alpha_i\ge0$（**无上界**） |
| 核矩阵 | $K$ | $K+\frac{1}{2C}I$ |
| 目标函数 | 不可微（折点） | **处处可微** |
| 解的稀疏性 | **更稀疏** | 稀疏性较差 |
| 对离群点 | 较稳健（线性惩罚） | 更敏感（**平方**惩罚） |

> 对角线加常数使核矩阵**严格正定**，改善了数值条件——这与岭回归 $(X^\top X+\lambda I)^{-1}$ 的技巧异曲同工。

#### 习题 7.4：证明 $K(x,z)=(x\cdot z)^p$ 是正定核

**方法一：利用核的封闭性质（推荐）**

**引理 1**：$K_1(x,z)=x\cdot z$ 是正定核。

证明：取 $\phi=\text{id}$（恒等映射），则 $K_1(x,z)=\phi(x)\cdot\phi(z)$。或直接验证 Gram 矩阵：对任意 $c\in\mathbb R^m$，

$$
\sum_{i,j}c_ic_j(x_i\cdot x_j)
=\left\lVert\sum_ic_ix_i\right\rVert^2\ge0。
$$

**引理 2（Schur 积定理）**：若 $K_1,K_2$ 是正定核，则乘积 $K_1K_2$ 也是正定核。

证明：设 $K_1(x,z)=\phi_1(x)\cdot\phi_1(z)$，$K_2(x,z)=\phi_2(x)\cdot\phi_2(z)$，分量为

$$
K_1=\sum_s\phi_1^{(s)}(x)\phi_1^{(s)}(z),
\qquad
K_2=\sum_t\phi_2^{(t)}(x)\phi_2^{(t)}(z)。
$$

则

$$
\begin{aligned}
K_1(x,z)K_2(x,z)
&=\sum_s\sum_t\phi_1^{(s)}(x)\phi_2^{(t)}(x)\cdot\phi_1^{(s)}(z)\phi_2^{(t)}(z)\\
&=\psi(x)\cdot\psi(z)，
\end{aligned}
$$

其中 $\psi$ 的分量为所有乘积 $\phi_1^{(s)}\phi_2^{(t)}$（即张量积）。故 $K_1K_2$ 是正定核。$\blacksquare$

**定理证明（数学归纳法）**：

- $p=1$：由引理 1，$K(x,z)=x\cdot z$ 是正定核；
- 归纳假设：$(x\cdot z)^{p-1}$ 是正定核；
- 归纳步骤：$(x\cdot z)^p=(x\cdot z)^{p-1}\cdot(x\cdot z)$，由引理 2 是两个正定核之积，故也是正定核。

由归纳法，对任意正整数 $p$，$K(x,z)=(x\cdot z)^p$ 是正定核。$\blacksquare$

**方法二：显式构造特征映射**

由多项式定理，

$$
(x\cdot z)^p=\left(\sum_{k=1}^{n}x^{(k)}z^{(k)}\right)^p
=\sum_{\substack{k_1+\cdots+k_n=p\\k_i\ge0}}
\binom{p}{k_1,\ldots,k_n}
\prod_{i=1}^{n}\left(x^{(i)}z^{(i)}\right)^{k_i}，
$$

其中多项式系数

$$
\binom{p}{k_1,\ldots,k_n}=\frac{p!}{k_1!\cdots k_n!}。
$$

定义映射 $\phi$，其在多重指标 $(k_1,\ldots,k_n)$ 上的分量为

$$
\phi_{(k_1,\ldots,k_n)}(x)
=\sqrt{\binom{p}{k_1,\ldots,k_n}}\prod_{i=1}^{n}\left(x^{(i)}\right)^{k_i}。
$$

则

$$
\phi(x)\cdot\phi(z)
=\sum_{k_1+\cdots+k_n=p}
\binom{p}{k_1,\ldots,k_n}
\prod_i\left(x^{(i)}\right)^{k_i}\left(z^{(i)}\right)^{k_i}
=(x\cdot z)^p\ \checkmark
$$

**特征空间维数**为

$$
\binom{n+p-1}{p}，
$$

即 $n$ 元 $p$ 次单项式的个数。例如 $n=2,p=2$ 时维数为 $\binom32=3$，正是例 7.3 中的 $\mathbb R^3$。

**具体例子**（$n=2,p=2$，与例 7.3 一致）：

$$
(x\cdot z)^2=(x^{(1)}z^{(1)})^2
+2(x^{(1)}z^{(1)})(x^{(2)}z^{(2)})
+(x^{(2)}z^{(2)})^2，
$$

$$
\phi(x)=\left((x^{(1)})^2,\;\sqrt2\,x^{(1)}x^{(2)},\;(x^{(2)})^2\right)^\top。
$$

系数 $\sqrt2=\sqrt{\binom{2}{1,1}}$ ✓（代码已数值验证，误差 $\le10^{-15}$）

**数值验证**（代码）：对 $p=1,2,3,4$，各做 30 次随机 Gram 矩阵测试，最小特征值均 $\ge-3.6\times10^{-15}$（浮点误差量级），确认半正定。

**推论**：多项式核 $K(x,z)=(x\cdot z+1)^p$ 也是正定核。因为

$$
(x\cdot z+1)^p=\sum_{k=0}^{p}\binom pk(x\cdot z)^k，
$$

是若干正定核 $(x\cdot z)^k$ 的**非负线性组合**（$k=0$ 时为常数核 $1$，也是正定核），而正定核对非负线性组合封闭。

---

### 第 7 章一句话回顾

支持向量机从"哪个分离超平面最好"出发，用**几何间隔最大化**这一尺度不变的准则把感知机的无穷多解收敛为唯一解，并化为凸二次规划；转入**拉格朗日对偶**后，样本只以内积形式出现——这既让 KKT 互补条件揭示出"只有支持向量决定超平面"的稀疏性，又为**核技巧**打开大门，使得在无穷维特征空间中做线性分类的计算量与维数无关；面对不可分数据则引入松弛变量与惩罚参数 $C$，其对偶仅仅多出一个上界 $\alpha_i\le C$，而整个模型等价于最小化"合页损失 + $L_2$ 正则"；最后 **SMO** 抓住等式约束的特点，每次只优化两个变量并给出解析解，把大规模 QP 化解为海量廉价的闭式更新。
