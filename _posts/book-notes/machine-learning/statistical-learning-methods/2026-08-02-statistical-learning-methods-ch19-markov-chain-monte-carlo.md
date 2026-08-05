---
title: "《统计学习方法（第 2 版）》第 19 章：马尔可夫链蒙特卡罗法"
date: 2026-08-01 02:19:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch19-markov-chain-monte-carlo
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
series_order: 20
related: [statistical-learning-methods-ch18-probabilistic-latent-semantic-analysis, statistical-learning-methods-ch20-latent-dirichlet-allocation]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「马尔可夫链蒙特卡罗法」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

> 凡标注 **【补充】** 或 **【辨析】** 的内容为原书之外的推导、严格条件、数值实验或纠错说明。本文采用原书的**列随机矩阵**约定：$p_{ij}=P(X_t=i\mid X_{t-1}=j)$，所以状态分布按 $\pi^{(t)}=P\pi^{(t-1)}$ 演化。

---

## 0. 本章解决什么问题

### 0.1 从“会算密度”到“能从密度抽样”

统计学习经常遇到这样的反差：一个分布的未归一化密度很容易写出，直接抽样和积分却极难。例如贝叶斯后验

$$
p(\theta\mid y)
=\frac{p(y\mid\theta)p(\theta)}
{\int p(y\mid\theta')p(\theta')\,d\theta'}
$$

的分母可能是高维积分，边缘概率和后验期望又要求继续积分。若能得到后验样本 $\theta^{(1)},\ldots,\theta^{(n)}$，则可用样本均值近似：

$$
E[f(\theta)\mid y]
\approx\frac1n\sum_{t=1}^{n}f(\theta^{(t)}).
$$

问题被转化为：**如何从复杂目标分布 $\pi(x)$ 产生样本？**

### 0.2 普通蒙特卡罗为什么不够

直接抽样、接受-拒绝法和重要性抽样通常产生独立样本，但在高维、变量强相关或归一化常数未知时会遇到困难：

- 找不到易抽样且覆盖目标密度的建议分布；
- 接受-拒绝法的包络常数随维数急剧增大；
- 重要性权重集中在极少数样本上，有效样本量很低。

MCMC 放弃样本独立性，改为构造一个以目标分布为平稳分布的马尔可夫链：

$$
X_0\to X_1\to\cdots\to X_t\to\cdots
$$

链走得足够久后，$X_t$ 的边缘分布接近目标分布；遍历定理又保证相关样本的时间平均收敛到目标期望。

### 0.3 作者的完整思路

```text
普通蒙特卡罗：抽样 → 样本均值 → 期望/积分
       ↓ 复杂分布无法直接高效抽样
马尔可夫链：局部转移容易，但样本相关
       ↓ 平稳分布 + 遍历定理
MCMC：设计平稳分布等于目标分布的链
       ↓ 如何保证目标分布不变？
细致平衡（充分条件）
       ↓
Metropolis-Hastings：建议 + 接受/拒绝修正
       ↓ 满条件分布恰好使接受率为 1
Gibbs 抽样：逐分量从满条件分布更新
```

### 0.4 本章结构

```text
19.1 蒙特卡罗法
 ├─ 随机抽样与接受-拒绝法
 ├─ 数学期望估计
 └─ 蒙特卡罗积分
19.2 马尔可夫链
 ├─ 马尔可夫性与时间齐次性
 ├─ 离散/连续转移核与平稳分布
 └─ 不可约、非周期、正常返、遍历、可逆
19.3 MCMC 通法
 ├─ 构造以目标分布为平稳分布的链
 ├─ 燃烧期与遍历均值
 └─ 贝叶斯学习中的积分
19.4 Metropolis-Hastings
 ├─ 建议核、接受率与细致平衡
 ├─ 对称/独立建议
 └─ 单分量 MH
19.5 Gibbs 抽样
 ├─ 满条件分布与接受率 1
 ├─ 系统扫描算法
 └─ 图模型局部计算
```

---

## 19.1 蒙特卡罗法

蒙特卡罗法不是某一个固定算法，而是一类“**用随机样本把难算的总体量变成易算的样本量**”的数值方法。其核心依据是大数定律。

### 19.1.1 随机抽样

#### 1. 目标

已知目标密度 $p(x)$，希望得到样本

$$
x_1,x_2,\ldots,x_n\overset{\mathrm{iid}}\sim p.
$$

标准分布可用逆变换、变换法等直接抽样；复杂密度则常需间接方法。

#### 2. 接受-拒绝法的构造

选择一个容易抽样的建议密度 $q(x)$ 和常数 $c>0$，要求

$$
p(x)\le c q(x),\qquad \forall x\in\mathcal X.
$$

这要求 $q$ 的支持覆盖 $p$ 的支持。算法 19.1：

1. 抽取候选 $X^*\sim q$；
2. 独立抽取 $U\sim\operatorname{Uniform}(0,1)$；
3. 若
   $$
   U\le\frac{p(X^*)}{cq(X^*)},
   $$
   则接受 $X^*$，否则拒绝并重来；
4. 直到得到 $n$ 个样本。

#### 3. 为什么接受后的样本服从 $p$【补充推导】

记接受事件为 $A$。对任意可测集合 $B$：

$$
\begin{aligned}
P(X^*\in B,A)
&=\int_B q(x)
P\left(U\le\frac{p(x)}{cq(x)}\mid X^*=x\right)dx\\
&=\int_Bq(x)\frac{p(x)}{cq(x)}dx\\
&=\frac1c\int_Bp(x)dx.
\end{aligned}
$$

总体接受概率为

$$
P(A)=\frac1c\int_{\mathcal X}p(x)dx=\frac1c.
$$

因此

$$
P(X^*\in B\mid A)
=\frac{P(X^*\in B,A)}{P(A)}
=\int_Bp(x)dx.
$$

所以接受样本的条件密度正是 $p$。

#### 4. 效率与边界

平均每得到一个样本需要 $c$ 次建议，接受率恰为 $1/c$。$cq$ 越贴近 $p$ 越高效。

高维下即使每个维度都只损失一点覆盖体积，总体接受率也可能指数下降。例如独立维度每维包络损失因子为 $r>1$，$d$ 维常数约为 $r^d$，接受率约 $r^{-d}$。

**成立条件**：

- 必须知道有限包络常数 $c$；
- $q(x)=0$ 的地方必须有 $p(x)=0$；
- 接受率计算需要目标密度的尺度。若只知道 $p(x)$ 到未知常数，只有该常数能被并入已知包络时才能直接使用。

这正是 MH 的优势之一：其密度比中归一化常数会抵消。

### 19.1.2 数学期望估计

设 $X\sim p$，$f$ 可积，目标为

$$
\mu=E_p[f(X)]=\int f(x)p(x)dx.
$$

对独立同分布样本 $X_1,\ldots,X_n\sim p$，定义

$$
\widehat\mu_n=\frac1n\sum_{i=1}^{n}f(X_i).
\qquad\mathrm{(19.1)}
$$

若 $E_p[|f(X)|]<\infty$，强大数定律给出

$$
\widehat\mu_n\xrightarrow{\mathrm{a.s.}}E_p[f(X)],
\qquad n\to\infty.
\qquad\mathrm{(19.2)}
$$

所以

$$
E_p[f(X)]\approx\frac1n\sum_{i=1}^{n}f(X_i).
\qquad\mathrm{(19.3)}
$$

#### 无偏性与误差率【补充】

若期望存在：

$$
E[\widehat\mu_n]=\mu.
$$

若方差 $\sigma_f^2=\operatorname{Var}_p[f(X)]<\infty$：

$$
\operatorname{Var}(\widehat\mu_n)=\frac{\sigma_f^2}{n},
$$

中心极限定理给出

$$
\sqrt n(\widehat\mu_n-\mu)
\xrightarrow{d}N(0,\sigma_f^2).
$$

因此随机误差典型量级为 $O(n^{-1/2})$。精度提高 10 倍，样本量通常要提高 100 倍；这一速率不随积分维数直接改变，但高维会让抽样和方差控制更难。

### 19.1.3 积分计算

对积分

$$
I=\int_{\mathcal X}h(x)dx,
$$

任选支持覆盖积分区域的密度 $p(x)>0$，令

$$
f(x)=\frac{h(x)}{p(x)}.
$$

则

$$
I=\int\frac{h(x)}{p(x)}p(x)dx
=E_p[f(X)].
\qquad\mathrm{(19.4)}
$$

抽取 $X_i\sim p$ 后：

$$
I\approx\frac1n\sum_{i=1}^{n}\frac{h(X_i)}{p(X_i)}.
\qquad\mathrm{(19.5)}
$$

这也是重要性抽样的基本恒等式。$p$ 的选择不改变期望，但显著影响方差；理想上应让 $p(x)$ 与 $|h(x)|$ 形状接近。

#### 例 19.1

计算

$$
I=\int_0^1e^{-x^2/2}dx.
$$

取 $p(x)=1$（$0<x<1$ 的均匀密度），$f(x)=e^{-x^2/2}$，故

$$
I=E_{U(0,1)}[e^{-X^2/2}]
\approx\frac1n\sum_{i=1}^{n}e^{-X_i^2/2}.
$$

原书用 10 个样本得到约 $0.832$；精确值为

$$
\sqrt{\frac\pi2}\operatorname{erf}\left(\frac1{\sqrt2}\right)
\approx0.855624.
$$

10 个样本波动很大，不应把单次结果当成算法精度保证。

#### 例 19.2

计算

$$
\frac1{\sqrt{2\pi}}
\int_{-\infty}^{\infty}x e^{-x^2/2}dx.
$$

取 $p(x)$ 为标准正态密度、$f(x)=x$，积分就是 $E[X]=0$。也可由被积函数是奇函数、积分区间关于 0 对称直接得 0。蒙特卡罗估计随 $n$ 增大趋近 0。

#### 易混淆：数值积分与随机抽样

- 蒙特卡罗积分的样本不是“积分区间上的随便随机点”，其分布 $p$ 决定权重；
- 若 $p$ 不是均匀分布，必须除以 $p(X_i)$；
- 样本均值收敛不代表有限样本无误差；
- 被积函数重尾到方差无穷时，大数定律可能仍成立，但常规标准误和 CLT 失效。

---

## 19.2 马尔可夫链

### 19.2.1 基本定义

#### 1. 马尔可夫性

随机变量序列

$$
\mathcal X=\{X_0,X_1,\ldots,X_t,\ldots\}
$$

具有共同状态空间 $S$。若对 $t\ge1$：

$$
P(X_t\mid X_0,X_1,\ldots,X_{t-1})
=P(X_t\mid X_{t-1}),
\qquad\mathrm{(19.6)}
$$

则称其为一阶马尔可夫链。

直觉是“给定现在，未来与更早过去条件独立”。它不是说历史毫无信息，而是说历史对下一步的影响已经被当前状态完整概括。因此状态设计很重要：若当前状态没有包含足够历史，马尔可夫假设可能不成立。

#### 2. 时间齐次

若转移规律不随绝对时刻变化：

$$
P(X_{t+s}\mid X_{t-1+s})
=P(X_t\mid X_{t-1}),
\qquad\mathrm{(19.7)}
$$

则称时间齐次。本章均讨论时间齐次链。

#### 3. 高阶链转成一阶链

$n$ 阶马尔可夫性为

$$
P(X_t\mid X_0,\ldots,X_{t-1})
=P(X_t\mid X_{t-n},\ldots,X_{t-1}).
\qquad\mathrm{(19.8)}
$$

定义增广状态

$$
Y_t=(X_{t-n+1},\ldots,X_t),
$$

则 $Y_{t+1}$ 只依赖 $Y_t$，所以 $\{Y_t\}$ 是一阶链。代价是状态空间从 $S$ 扩展到 $S^n$。

### 19.2.2 离散状态马尔可夫链

#### 1. 转移概率矩阵

原书定义

$$
p_{ij}=P(X_t=i\mid X_{t-1}=j).
\qquad\mathrm{(19.9)}
$$

矩阵

$$
P=(p_{ij})
\qquad\mathrm{(19.10)}
$$

满足

$$
p_{ij}\ge0,
\qquad
\sum_i p_{ij}=1.
$$

即每一**列**和为 1。许多教材采用行随机约定 $P_{ij}=P(j\mid i)$；两种都正确，但公式互为转置，不能混用。

时刻 $t$ 的列向量状态分布为

$$
\pi^{(t)}
=(\pi_1^{(t)},\pi_2^{(t)},\ldots)^\top,
\quad
\pi_i^{(t)}=P(X_t=i).
\qquad\mathrm{(19.11)}
$$

初始分布是 $\pi^{(0)}$（式 19.12）。由全概率公式：

$$
\begin{aligned}
\pi_i^{(t)}
&=\sum_jP(X_t=i\mid X_{t-1}=j)P(X_{t-1}=j)\\
&=\sum_jp_{ij}\pi_j^{(t-1)},
\end{aligned}
$$

故

$$
\pi^{(t)}=P\pi^{(t-1)}.
\qquad\mathrm{(19.13)}
$$

递推得到

$$
\pi^{(t)}=P^t\pi^{(0)}.
\qquad\mathrm{(19.14)}
$$

$P^t$ 的元素 $(P^t)_{ij}=P(X_t=i\mid X_0=j)$ 是 $t$ 步转移概率。

#### 天气例子

取状态顺序（晴、雨）：

$$
P=\begin{bmatrix}0.9&0.5\\0.1&0.5\end{bmatrix},
\qquad
\pi^{(0)}=\begin{bmatrix}1\\0\end{bmatrix}.
$$

则

$$
\pi^{(1)}=P\pi^{(0)}
=\begin{bmatrix}0.9\\0.1\end{bmatrix},
$$

$$
\pi^{(2)}=P^2\pi^{(0)}
=\begin{bmatrix}0.86\\0.14\end{bmatrix}.
$$

语言模型也是马尔可夫链应用：链式法则本来是

$$
P(w_{1:s})=P(w_1)\prod_{t=2}^{s}P(w_t\mid w_{1:t-1}),
$$

一阶假设将其近似为

$$
P(w_{1:s})\approx P(w_1)\prod_{t=2}^{s}P(w_t\mid w_{t-1}).
$$

这是用偏差换取可估计性；现代 Transformer 不再使用这种有限阶假设，但马尔可夫状态思想仍是序列建模基础。

#### 2. 平稳分布

若概率向量 $\pi$ 满足

$$
\pi=P\pi,
\qquad\mathrm{(19.15)}
$$

则称为平稳分布。若 $X_0\sim\pi$，则

$$
\pi^{(t)}=P^t\pi=\pi,
$$

所有时刻边缘分布不变。

**平稳不等于不移动**：链仍可在状态间频繁跳转，只是总体概率流入与流出平衡。

#### 引理 19.1：平稳分布方程

$\pi$ 是平稳分布，当且仅当

$$
\pi_i=\sum_jp_{ij}\pi_j,
\qquad\mathrm{(19.16)}
$$

$$
\pi_i\ge0,
\qquad\mathrm{(19.17)}
$$

$$
\sum_i\pi_i=1.
\qquad\mathrm{(19.18)}
$$

**论证**：必要性直接来自定义和概率公理；反之，式 (19.17)–(19.18) 保证 $\pi$ 是概率分布，式 (19.16) 即 $P\pi=\pi$，所以一步转移后分布不变，归纳可知任意步都不变。

#### 例 19.3

$$
P=\begin{bmatrix}
1/2&1/2&1/4\\
1/4&0&1/4\\
1/4&1/2&1/2
\end{bmatrix}.
$$

解 $(P-I)\pi=0$ 与 $\mathbf1^\top\pi=1$，得到

$$
\pi=(2/5,1/5,2/5)^\top.
$$

例 19.4 表明平稳分布可能不唯一；无限状态链还可能没有平稳概率分布。

### 19.2.3 连续状态马尔可夫链

连续状态不能用有限矩阵表示。转移核

$$
P(x,A)=\int_Ap(x,y)dy
\qquad\mathrm{(19.19)}
$$

表示当前为 $x$ 时，下一状态落入可测集合 $A$ 的概率：

$$
P(X_t\in A\mid X_{t-1}=x)=P(x,A).
\qquad\mathrm{(19.20)}
$$

对每个固定 $x$，要求 $p(x,y)\ge0$ 且

$$
\int_Sp(x,y)dy=1.
$$

密度 $\pi(y)$ 平稳，当且仅当

$$
\pi(y)=\int_Sp(x,y)\pi(x)dx,
\qquad \forall y\in S.
\qquad\mathrm{(19.21)}
$$

集合形式为

$$
\pi(A)=\int_SP(x,A)\pi(x)dx,
\qquad \forall A\subseteq S.
\qquad\mathrm{(19.22)}
$$

简记为

$$
\pi P=\pi.
\qquad\mathrm{(19.23)}
$$

这里的符号方向与列矩阵写法看似不同，实质都是“旧分布经转移核推前后仍为自身”。

### 19.2.4 马尔可夫链的性质

#### 1. 不可约

对任意 $i,j\in S$，若存在 $t>0$ 使

$$
P(X_t=i\mid X_0=j)>0,
\qquad\mathrm{(19.24)}
$$

则链不可约。直觉是所有状态互相可达，状态空间只有一个沟通类。

不可约排除了链被困在互不连通区域的情形。MCMC 若可约，起点会决定能探索哪个区域，即使目标密度在其他区域也为正。

#### 2. 非周期

状态 $i$ 的周期定义为

$$
d(i)=\gcd\{t\ge1:P(X_t=i\mid X_0=i)>0\}.
$$

$d(i)=1$ 称状态非周期。不可约链中所有状态周期相同，因此只需检查一个状态。

- 有自环 $P(i\mid i)>0$ 的状态周期为 1；
- 确定性三状态循环只有 $3,6,9,\ldots$ 步能返回，周期为 3；
- 周期链可以有唯一平稳分布，但 $P^t\pi^{(0)}$ 会振荡而不收敛。

**定理 19.2 的准确边界【辨析】**：原书说“不可约且非周期的有限状态链有唯一平稳分布”，该命题正确，但条件强于唯一性所需。有限不可约已足以保证唯一平稳分布；非周期额外保证从任意初始分布收敛到它。

**存在唯一性论证【补充】**：有限列随机矩阵 $P$ 的谱半径为 1，且 $1$ 是特征值，因为

$$
\mathbf1^\top P=\mathbf1^\top.
$$

对不可约非负矩阵应用 Perron–Frobenius 定理，谱半径 1 对应一个各分量严格为正的右特征向量 $v$，且该正特征向量在倍数意义下唯一。归一化

$$
\pi=\frac{v}{\mathbf1^\top v}
$$

便得到唯一概率向量 $P\pi=\pi$。若再加非周期性，则 $P$ 是本原矩阵，其余特征值模严格小于 1，因而

$$
P^t\longrightarrow\pi\mathbf1^\top.
$$

所以对任意初始分布 $\mu$：

$$
P^t\mu\to\pi\mathbf1^\top\mu=\pi.
$$

#### 3. 正常返（正再生）

令首次回返时间

$$
T_i^+=\inf\{t\ge1:X_t=i\},
\quad X_0=i.
$$

标准定义中，状态 $i$ **常返**要求 $P_i(T_i^+<\infty)=1$；**正常返/正再生**（positive recurrent）要求

$$
E_i[T_i^+]<\infty.
$$

不可约链中一个状态正常返等价于所有状态正常返。

**【辨析：原书定义问题】** 原书定义 19.5 写成“首次到达概率 $p_{ij}^{(t)}$ 在 $t\to\infty$ 时极限大于 0”。按标准概率论这不可能作为一般定义：首次到达时刻事件互斥，$\sum_t p_{ij}^{(t)}\le1$，故其单项通常必须趋于 0。本文采用标准的有限期望回返时间定义；原书例 19.7 与定理 19.3 的意图也与标准定义一致。

对图 19.8 的半无限出生-死亡链，向左概率 $p$、向右概率 $q$，$p+q=1$。当 $p>q$ 时有平稳分布

$$
\pi_i=\left(\frac qp\right)^i\frac{p-q}{p},
\qquad i=1,2,\ldots,
$$

几何级数可归一化，链正常返；$p\le q$ 时不能归一化为平稳概率分布，链不是正常返。

**定理 19.3**：不可约、非周期且正常返的可数状态链有唯一平稳分布。更精确地说，不可约正常返已保证唯一平稳分布，非周期用于转移分布收敛。

**存在性论证【补充】**：固定参考状态 $o$，以两次返回 $o$ 之间的轨迹作为再生周期，定义一周期访问状态 $j$ 的期望次数

$$
\nu_j
=E_o\left[\sum_{t=0}^{T_o^+-1}\mathbf1\{X_t=j\}\right].
$$

把每次访问后的下一步按转移概率分配，并利用周期首尾都在 $o$，可得概率流守恒

$$
P\nu=\nu.
$$

正常返保证

$$
\sum_j\nu_j=E_o[T_o^+]<\infty,
$$

故可以归一化：

$$
\pi_j=\frac{\nu_j}{E_o[T_o^+]}.
$$

这给出平稳概率分布，特别有

$$
\pi_o=\frac1{E_o[T_o^+]}.
$$

不可约性使所有状态属于同一再生结构；任一平稳概率分布都必须具有上述长期访问比例，因此唯一。非周期性再结合更新定理，排除返回时刻的格点振荡，得到 $P^t(i,j)\to\pi_i$。

#### 4. 遍历定理（定理 19.4）

若链不可约、非周期且正常返，则存在唯一平稳分布 $\pi$，且

$$
\lim_{t\to\infty}P(X_t=i\mid X_0=j)=\pi_i.
\qquad\mathrm{(19.25)}
$$

若 $E_\pi[|f(X)|]<\infty$，则

$$
\widehat f_t=\frac1t\sum_{s=1}^{t}f(X_s)
\xrightarrow{\mathrm{a.s.}}E_\pi[f(X)].
\qquad\mathrm{(19.26)}
$$

即

$$
\widehat f_t\to E_\pi[f(X)].
\qquad\mathrm{(19.27)}
$$

**为什么成立【补充论证】**：选一个再生状态 $i$，把轨迹按连续两次回到 $i$ 切成周期。强马尔可夫性使各完整周期（首周期除外）独立同分布；正常返保证周期平均长度有限。对每周期累计的 $f$ 值和周期长度分别用大数定律，其比值趋于

$$
\frac{E_i[\text{一周期内的 }f\text{ 总和}]}
{E_i[T_i^+]}
=E_\pi[f].
$$

不可约确保全空间被访问，非周期确保边缘分布不振荡。一般状态空间的严格证明使用 Harris 再生理论，不能只靠有限矩阵论。

实践中丢弃前 $m$ 步作为燃烧期，计算

$$
\widehat f_{m,n}
=\frac1{n-m}\sum_{i=m+1}^{n}f(X_i).
\qquad\mathrm{(19.28)}
$$

但有限 $m$ 不能“保证已经平稳”，只是在混合良好时减小初值偏差。

#### 5. 可逆性与细致平衡

若存在分布 $\pi$，对所有 $i,j$：

$$
P(X_t=i\mid X_{t-1}=j)\pi_j
=P(X_t=j\mid X_{t-1}=i)\pi_i,
\qquad\mathrm{(19.29)}
$$

即

$$
p_{ij}\pi_j=p_{ji}\pi_i,
\qquad\mathrm{(19.30)}
$$

则链关于 $\pi$ 可逆。等式表示平稳状态下每对状态间的概率流逐对平衡。

**定理 19.5（细致平衡）**：满足细致平衡的 $\pi$ 是平稳分布。证明为

$$
(P\pi)_i
=\sum_jp_{ij}\pi_j
=\sum_jp_{ji}\pi_i
=\pi_i\sum_jp_{ji}
=\pi_i,
\qquad\mathrm{(19.31)}
$$

其中最后使用从状态 $i$ 出发的转移概率之和为 1（原书列随机约定下是第 $i$ 列和）。

**【重要边界】**：细致平衡是平稳性的充分条件，不是必要条件；可逆也不自动推出不可约、非周期或平稳分布唯一。

- 恒等转移矩阵关于任意 $\pi$ 都满足细致平衡，却完全可约；
- 两状态确定性交换链关于 $(1/2,1/2)$ 可逆，却周期为 2；
- 因此还必须单独检查遍历条件。

原书在定理 19.5 后称“可逆链一定有唯一平稳分布并满足遍历定理”，以及习题 19.5 要求证明“可逆链一定不可约”，按标准定义均缺少条件。后文会给出反例与可成立的补充条件。

---

## 19.3 马尔可夫链蒙特卡罗法

### 19.3.1 基本想法

设目标密度为 $p(x)$，希望抽样并估计

$$
E_p[f(X)]=\int f(x)p(x)dx.
$$

MCMC 分两层解决问题：

1. **设计层**：构造转移核 $K(x,dy)$，使 $p$ 是其平稳分布；
2. **运行层**：从任意 $x_0$ 出发迭代 $X_t\sim K(X_{t-1},\cdot)$，用燃烧期后的遍历均值估计目标期望。

若链满足适当遍历条件：

$$
\mathcal L(X_t)\to p,
$$

且

$$
\frac1{n-m}\sum_{t=m+1}^{n}f(X_t)
\xrightarrow{\mathrm{a.s.}}E_p[f(X)].
\qquad\mathrm{(19.32)}
$$

这里样本相关但仍可用，因为遍历定理替代了 iid 大数定律。

#### 燃烧期、相关性和有效样本量【补充】

燃烧期 $m$ 用于减小初始分布偏差，但不能修复一条混合极慢或可约的链。平稳链样本均值的方差近似为

$$
\operatorname{Var}(\bar f_n)
\approx\frac{\sigma_f^2}{n}\tau_{\mathrm{int}},
$$

其中

$$
	au_{\mathrm{int}}
=1+2\sum_{k=1}^{\infty}\rho_k
$$

是积分自相关时间，$\rho_k$ 是 $f(X_t)$ 的滞后 $k$ 自相关。定义

$$
\operatorname{ESS}=\frac{n}{\tau_{\mathrm{int}}}.
$$

ESS 表示这批相关样本约等价于多少个独立样本。

**【辨析】抽稀不等于独立**：每隔若干步取一个样本只能降低相关性，通常不能使样本严格独立，而且会丢掉信息。若存储不是瓶颈，保留全部样本并报告 ESS 通常更好。

### 19.3.2 基本步骤

原书概括为：

1. 在状态空间 $S$ 上构造满足遍历条件、平稳分布为 $p(x)$ 的马尔可夫链；
2. 从任意 $x_0$ 出发随机游走，产生 $x_0,x_1,\ldots,x_n$；
3. 选燃烧期 $m<n$，保留 $\{x_{m+1},\ldots,x_n\}$；
4. 计算
       $$
       \widehat f_{m,n}
       =\frac1{n-m}\sum_{i=m+1}^{n}f(x_i).
       \qquad\mathrm{(19.33)}
       $$

三个实际难题是：

- 如何构造以 $p$ 为平稳分布且不可约、非周期的链；
- 如何判断燃烧期足够长；
- 如何决定总迭代数，使蒙特卡罗标准误达到要求。

#### 收敛诊断【补充】

不能仅凭一条轨迹“看起来稳定”就证明收敛。常结合：

- 多条过度分散初值的链；
- 轨迹图和自相关图；
- 分链秩归一化 $\widehat R$；
- bulk/tail ESS；
- 蒙特卡罗标准误与目标精度比较。

诊断只能发现部分问题，不能从有限样本严格证明收敛。最根本的仍是验证链的支持、不可约性和核的正确性。

### 19.3.3 MCMC 与统计学习

贝叶斯后验为

$$
p(x\mid y)
=\frac{p(x)p(y\mid x)}
{\int_{\mathcal X}p(x')p(y\mid x')dx'}.
\qquad\mathrm{(19.34)}
$$

统计学习中常见三类难积分：

1. **归一化**
       $$
       p(y)=\int p(y\mid x')p(x')dx';
       \qquad\mathrm{(19.35)}
       $$
2. **边缘化隐变量**
       $$
       p(x\mid y)=\int_{\mathcal Z}p(x,z\mid y)dz;
       \qquad\mathrm{(19.36)}
       $$
3. **后验期望**
       $$
       E[f(X)\mid y]
       =\int_{\mathcal X}f(x)p(x\mid y)dx.
       \qquad\mathrm{(19.37)}
       $$

MH 只使用密度比，因此式 (19.34) 的未知分母会抵消。若

$$
\widetilde p(x)=p(x)p(y\mid x)=Zp(x\mid y),
$$

则

$$
\frac{p(x'\mid y)}{p(x\mid y)}
=\frac{\widetilde p(x')}{\widetilde p(x)}.
$$

这正是 MCMC 对贝叶斯学习特别重要的原因：**不必先算出归一化常数，就能从归一化后的后验抽样。**

---

## 19.4 Metropolis-Hastings 算法

### 19.4.1 基本原理

#### 1. 从建议核到目标平稳核

目标密度记为 $p(x)$。选择易抽样的建议核

$$
x'\sim q(x,\cdot).
$$

建议核一般不以 $p$ 为平稳分布，因此需要接受概率纠偏：

$$
\alpha(x,x')
=\min\left\{1,
\frac{p(x')q(x',x)}{p(x)q(x,x')}
\right\}.
\qquad\mathrm{(19.39)}
$$

对 $x'\ne x$，实际移动密度为

$$
K(x,x')=q(x,x')\alpha(x,x').
\qquad\mathrm{(19.38)}
$$

若拒绝候选则停留在 $x$。完整转移核是

$$
K(x,dx')
=q(x,x')\alpha(x,x')dx'+r(x)\delta_x(dx'),
$$

其中

$$
r(x)=1-\int q(x,y)\alpha(x,y)dy
$$

是拒绝概率，$\delta_x$ 是在当前点的点质量。

**【辨析】** 原书式 (19.38) 只写 $q\alpha$，它描述非对角移动部分；若把它当完整核，积分通常小于 1。对角拒绝质量不可省略。

#### 2. 接受概率从哪里来

希望逐对满足细致平衡：

$$
p(x)q(x,x')\alpha(x,x')
=p(x')q(x',x)\alpha(x',x).
$$

定义 Hastings 比率

$$
R(x,x')
=\frac{p(x')q(x',x)}{p(x)q(x,x')}.
$$

若 $R\ge1$，正向建议相对“应有流量”不足，全部接受：$\alpha(x,x')=1$；反向接受率取 $1/R$。若 $R<1$，正向只接受比例 $R$，反向全接受。这两种情况统一为 $\min(1,R)$。

故

$$
\begin{aligned}
p(x)q(x,x')\alpha(x,x')
&=p(x)q(x,x')
\min\left\{1,R(x,x')\right\}\\
&=\min\{p(x)q(x,x'),p(x')q(x',x)\},
\end{aligned}
$$

该表达式交换 $x,x'$ 后不变。

#### 3. 定理 19.6：MH 核可逆

对 $x\ne x'$：

$$
p(x)K(x,x')
=\min\{p(x)q(x,x'),p(x')q(x',x)\}
=p(x')K(x',x).
\qquad\mathrm{(19.41)}
$$

$x=x'$ 时显然成立，所以完整核关于 $p$ 满足细致平衡。由定理 19.5：

$$
\int p(x)K(x,dx')=p(x')dx',
$$

目标分布 $p$ 是平稳分布。

**成立条件**：这只证明平稳性。要从任意起点收敛并应用遍历定理，还需建议核使 MH 链在目标支持上不可约，并排除周期性；连续随机游走 MH 因拒绝产生自环，通常容易非周期，但不可想当然。

#### 4. 为什么归一化常数抵消

若只知道 $p(x)=\widetilde p(x)/Z$，则

$$
\frac{p(x')q(x',x)}{p(x)q(x,x')}
=\frac{\widetilde p(x')q(x',x)}
{\widetilde p(x)q(x,x')},
$$

$Z$ 消失。这是 MH 相比接受-拒绝法的核心优势。

#### 5. 建议分布

**Metropolis 对称建议**：若

$$
q(x,x')=q(x',x),
\qquad\mathrm{(19.42)}
$$

则

$$
\alpha(x,x')
=\min\left\{1,\frac{p(x')}{p(x)}\right\}.
\qquad\mathrm{(19.43)}
$$

随机游走建议 $x'=x+\varepsilon$、$\varepsilon$ 服从对称分布就是典型例子。

- 步长过小：接受率高，但移动慢、强自相关；
- 步长过大：候选常落在低密度区，拒绝率高；
- 高接受率不等于高效率，应看 ESS/计算时间。

**独立建议**：若 $q(x,x')=q(x')$，定义重要性权重

$$
w(x)=\frac{p(x)}{q(x)},
$$

则

$$
\alpha(x,x')
=\min\left\{1,\frac{w(x')}{w(x)}\right\}.
\qquad\mathrm{(19.44)}
$$

$q$ 必须覆盖 $p$ 的支持，并且越接近 $p$ 混合越好。

#### 6. 满条件分布

对 $x=(x_1,\ldots,x_k)$，记

$$
x_{-I}=\{x_j:j\notin I\}.
$$

满条件分布是给定其余所有分量后的条件分布：

$$
p(x_I\mid x_{-I})
=\frac{p(x)}{\int p(x)dx_I}
\propto p(x).
\qquad\mathrm{(19.45)}
$$

若 $x,x'$ 只在分量集合 $I$ 上不同，则 $x_{-I}=x'_{-I}$，有

$$
\frac{p(x'_I\mid x_{-I})}{p(x_I\mid x_{-I})}
=\frac{p(x')}{p(x)}.
\qquad\mathrm{(19.46)}
$$

因此单分量 MH 可用满条件密度比代替高维联合密度比。

#### 例 19.9

若

$$
p(x_1,x_2)
\propto\exp\left[-\frac12(x_1-1)^2(x_2-1)^2\right],
$$

固定 $x_2$ 后，关于 $x_1$ 的核为

$$
\exp\left[-\frac{(x_1-1)^2}{2/(x_2-1)^2}\right],
$$

所以

$$
x_1\mid x_2\sim N\left(1,(x_2-1)^{-2}\right).
$$

同理

$$
x_2\mid x_1\sim N\left(1,(x_1-1)^{-2}\right).
$$

当条件变量等于 1 时方差形式发散，且原“联合密度”本身在无界区域上不可积；因此这个例子适合演示按变量识别条件核，但不构成良好归一化联合概率分布【补充边界】。

### 19.4.2 Metropolis-Hastings 算法

算法 19.2：

**输入**：目标密度核 $p(x)$、函数 $f$、建议核 $q$。

**参数**：燃烧期 $m$、总迭代数 $n$。

1. 选择初值 $x_0$；
2. 对 $t=1,\ldots,n$：
       1. 抽候选 $x'\sim q(x_{t-1},\cdot)$；
       2. 计算
              $$
              \alpha=\min\left\{1,
              \frac{p(x')q(x',x_{t-1})}
              {p(x_{t-1})q(x_{t-1},x')}
              \right\};
              $$
       3. 抽 $u\sim U(0,1)$；
       4. 若 $u\le\alpha$，令 $x_t=x'$；否则令 $x_t=x_{t-1}$；
3. 返回 $x_{m+1:n}$ 及
       $$
       \widehat f_{m,n}
       =\frac1{n-m}\sum_{t=m+1}^{n}f(x_t).
       $$

#### 数值稳定性【补充】

高维密度连乘容易下溢，应计算对数接受率：

$$
\begin{aligned}
\log R={}&\log\widetilde p(x')-\log\widetilde p(x)\\
&+\log q(x',x)-\log q(x,x').
\end{aligned}
$$

接受条件可写为

$$
\log U\le\min(0,\log R).
$$

### 19.4.3 单分量 Metropolis-Hastings 算法

对 $k$ 维状态，在第 $t$ 次扫描内依次更新 $j=1,\ldots,k$。更新第 $j$ 个分量前的混合状态为

$$
x_{-j}^{(t)}
=\bigl(x_1^{(t)},\ldots,x_{j-1}^{(t)},
x_{j+1}^{(t-1)},\ldots,x_k^{(t-1)}\bigr).
$$

从条件建议

$$
x_j'\sim q_j(x_j^{(t-1)},\cdot\mid x_{-j}^{(t)})
$$

抽候选，接受率为

$$
\alpha_j
=\min\left\{1,
\frac{p(x_j'\mid x_{-j}^{(t)})
q_j(x_j',x_j^{(t-1)}\mid x_{-j}^{(t)})}
{p(x_j^{(t-1)}\mid x_{-j}^{(t)})
q_j(x_j^{(t-1)},x_j'\mid x_{-j}^{(t)})}
\right\}.
\qquad\mathrm{(19.47)}
$$

若接受则 $x_j^{(t)}=x_j'$，否则保持旧值。非对角转移部分为

$$
K_j=q_j\alpha_j.
\qquad\mathrm{(19.48)}
$$

一轮完整扫描的核是各分量核的复合。每个分量核都保持 $p$ 不变，故复合核也保持 $p$ 不变；系统扫描复合核未必整体可逆，但平稳性仍成立。

---

## 19.5 吉布斯抽样

### 19.5.1 基本原理

吉布斯抽样用于多元联合分布

$$
p(x)=p(x_1,\ldots,x_k).
$$

它依次从满条件分布抽样：

$$
x_j^{(t)}\sim
p\left(x_j\mid
x_1^{(t)},\ldots,x_{j-1}^{(t)},
x_{j+1}^{(t-1)},\ldots,x_k^{(t-1)}
\right).
$$

#### 为什么接受率恒为 1

把单分量 MH 的建议取为满条件：

$$
q_j(x_j,x_j'\mid x_{-j})
=p(x_j'\mid x_{-j}).
\qquad\mathrm{(19.49)}
$$

因为新旧状态只有第 $j$ 维不同：

$$
p(x)=p(x_{-j})p(x_j\mid x_{-j}),
$$

$$
p(x')=p(x_{-j})p(x_j'\mid x_{-j}).
$$

代入 MH 比率：

$$
\begin{aligned}
R
&=\frac{p(x')p(x_j\mid x_{-j})}
{p(x)p(x_j'\mid x_{-j})}\\
&=\frac{p(x_{-j})p(x_j'\mid x_{-j})p(x_j\mid x_{-j})}
{p(x_{-j})p(x_j\mid x_{-j})p(x_j'\mid x_{-j})}\\
&=1.
\end{aligned}
\qquad\mathrm{(19.50)}
$$

所以 $\alpha=1$，每个候选都接受，分量转移核就是满条件分布：

$$
K_j(x,x')=p(x_j'\mid x_{-j}).
\qquad\mathrm{(19.51)}
$$

**为什么保持联合分布不变**：若更新前 $X\sim p$，保留 $X_{-j}$ 并重新从正确的 $p(x_j\mid X_{-j})$ 抽 $X_j'$，则

$$
p(x_{-j})p(x_j'\mid x_{-j})=p(x'),
$$

故单次分量更新保持 $p$；一轮多个更新的复合也保持 $p$。

**条件**：满条件必须能抽样，且这些分量更新共同诱导的链应在目标支持上不可约。若目标支持被条件更新切成互不连通部分，Gibbs 仍可能不可约。

### 19.5.2 吉布斯抽样算法

算法 19.3：

1. 选初值 $x^{(0)}=(x_1^{(0)},\ldots,x_k^{(0)})$；
2. 对扫描 $t=1,\ldots,n$，依次执行
       $$
       x_1^{(t)}\sim p(x_1\mid x_2^{(t-1)},\ldots,x_k^{(t-1)}),
       $$
       $$
       x_2^{(t)}\sim p(x_2\mid x_1^{(t)},x_3^{(t-1)},\ldots,x_k^{(t-1)}),
       $$
       $$
       \cdots
       $$
       $$
       x_k^{(t)}\sim p(x_k\mid x_1^{(t)},\ldots,x_{k-1}^{(t)});
       $$
3. 丢弃前 $m$ 次扫描，保留 $x^{(m+1)},\ldots,x^{(n)}$；
4. 用遍历均值估计 $E_p[f(X)]$。

#### 例 19.10：二元正态

设

$$
\begin{bmatrix}X_1\\X_2\end{bmatrix}
\sim N\left(
\begin{bmatrix}0\\0\end{bmatrix},
\begin{bmatrix}1&\rho\\\rho&1\end{bmatrix}
\right).
$$

二元正态条件分布公式给出

$$
X_1\mid X_2=x_2
\sim N(\rho x_2,1-\rho^2),
$$

$$
X_2\mid X_1=x_1
\sim N(\rho x_1,1-\rho^2).
$$

推导第一式：联合密度指数为

$$
-\frac{x_1^2-2\rho x_1x_2+x_2^2}{2(1-\rho^2)}.
$$

固定 $x_2$，对 $x_1$ 配方：

$$
x_1^2-2\rho x_1x_2
=(x_1-\rho x_2)^2-\rho^2x_2^2.
$$

与 $x_1$ 无关的项并入归一化常数，即得到均值 $\rho x_2$、方差 $1-\rho^2$。第二式对称。

当 $|\rho|$ 接近 1 时，每次条件方差很小，链沿狭长椭圆缓慢移动，自相关很强。Gibbs “每步都接受”不代表混合一定快。

#### Gibbs 与单分量 MH

| 项目 | 单分量 MH | Gibbs |
| --- | --- | --- |
| 候选 | 任意易抽样条件建议 | 精确满条件分布 |
| 接受/拒绝 | 需要 | 接受率恒为 1 |
| 适用情况 | 满条件难直接抽样 | 满条件是标准分布或易抽样 |
| 调参 | 建议尺度等 | 通常较少 |
| 混合 | 依建议质量 | 强相关时仍可很慢 |

### 19.5.3 抽样计算

贝叶斯模型中令

$$
x=(\alpha,\theta,z),
$$

其中 $\alpha$ 是超参数、$\theta$ 是模型参数、$z$ 是隐变量、$y$ 是观测数据。后验核为

$$
p(\alpha,\theta,z\mid y)
\propto p(z,y\mid\theta)p(\theta\mid\alpha)p(\alpha).
\qquad\mathrm{(19.52)}
$$

更新单个分量时，只保留与该变量有关的因子：

$$
p(\alpha_i\mid\alpha_{-i},\theta,z,y)
\propto p(\theta\mid\alpha)p(\alpha),
\qquad\mathrm{(19.53)}
$$

$$
p(\theta_j\mid\theta_{-j},\alpha,z,y)
\propto p(z,y\mid\theta)p(\theta\mid\alpha),
\qquad\mathrm{(19.54)}
$$

$$
p(z_k\mid z_{-k},\alpha,\theta,y)
\propto p(z,y\mid\theta).
\qquad\mathrm{(19.55)}
$$

依据是条件分布

$$
p(x_j\mid x_{-j},y)
\propto p(x_j,x_{-j},y),
$$

凡与 $x_j$ 无关的因子都可作为常数丢掉。图模型中只需查看该节点的 Markov blanket（父节点、子节点及子节点的其他父节点），因此 Gibbs 更新常能局部计算，而不必每次重算完整联合密度。

#### 常见误解

1. **MCMC 样本独立。** 它们通常相关，精度由 ESS 而非原始样本数决定。
2. **丢弃固定比例燃烧期就一定收敛。** 收敛取决于链和目标几何，不存在通用比例。
3. **接受率越高越好。** 极小步长可使接受率接近 1，却几乎不探索空间。
4. **拒绝是浪费，应删除重复状态。** 重复状态是转移核的一部分，删除会改变平稳分布。
5. **细致平衡是平稳的必要条件。** 它只是方便构造的充分条件。
6. **有正确平稳分布就足够。** 可约或周期链可能无法从给定起点收敛。
7. **Gibbs 无拒绝所以总比 MH 快。** 强相关和不佳参数化会让 Gibbs 极慢。
8. **抽稀后样本就是 iid。** 抽稀只能减相关，不能保证独立。
9. **轨迹稳定即可证明收敛。** 有限诊断不能证明，只能发现明显问题。
10. **MCMC 能直接给出归一化常数。** 标准 MH 给后验样本和期望，但不直接给边际似然 $p(y)$。

---

## 19.6 【补充】可运行代码：MC、MH 与 Gibbs

代码仅使用 Python 标准库，固定随机种子。公式对应关系：

| 代码 | 原书公式/算法 |
| --- | --- |
| `monte_carlo_examples` | 式 (19.4)–(19.5) |
| `accept_reject_triangular` | 算法 19.1 |
| `weather_chain` | 式 (19.13)–(19.15) |
| `metropolis_beta` | 算法 19.2、习题 19.7 |
| `gibbs_bivariate_normal` | 算法 19.3、例 19.10 |
| `sample_theta_given_eta` 等 | 习题 19.8 的两个满条件分布 |

```python
"""《统计学习方法》第 19 章：蒙特卡罗、MH 与 Gibbs，纯 Python。"""
import math
import random


def mean(values):
       return sum(values) / len(values)


def variance(values):
       center = mean(values)
       return sum((value - center) ** 2 for value in values) / len(values)


def covariance(left, right):
       left_mean, right_mean = mean(left), mean(right)
       return sum(
              (x - left_mean) * (y - right_mean) for x, y in zip(left, right)
       ) / len(left)


def lag1_correlation(values):
       center = mean(values)
       denominator = sum((value - center) ** 2 for value in values)
       numerator = sum(
              (values[index] - center) * (values[index - 1] - center)
              for index in range(1, len(values))
       )
       return numerator / denominator


def monte_carlo_examples(sample_count=100_000, seed=19):
       """式 (19.4)~(19.5)：把积分写成期望。"""
       rng = random.Random(seed)
       # 例 19.1：X~U(0,1)，估计 E[exp(-X^2/2)]。
       example_19_1 = mean([
              math.exp(-rng.random() ** 2 / 2) for _ in range(sample_count)
       ])
       # 习题 19.1：X~N(0,1)，被积函数除以标准正态密度后为 sqrt(2*pi)X^2。
       exercise_19_1 = math.sqrt(2 * math.pi) * mean([
              rng.gauss(0.0, 1.0) ** 2 for _ in range(sample_count)
       ])
       return example_19_1, exercise_19_1


def accept_reject_triangular(sample_count=20_000, seed=20):
       """算法 19.1：用 q=U(0,1)、c=2 抽取 p(x)=2x。"""
       rng = random.Random(seed)
       samples = []
       proposals = 0
       while len(samples) < sample_count:
              candidate = rng.random()
              proposals += 1
              # p/(cq)=(2x)/(2*1)=x。
              if rng.random() <= candidate:
                     samples.append(candidate)
       return samples, sample_count / proposals


def weather_chain(steps=100_000, seed=21):
       """式 (19.13)：晴=0、雨=1，按原书天气转移概率模拟。"""
       rng = random.Random(seed)
       state = 0
       sunny_count = 0
       for _ in range(steps):
              if state == 0:
                     state = 0 if rng.random() < 0.9 else 1
              else:
                     state = 0 if rng.random() < 0.5 else 1
              sunny_count += state == 0
       return sunny_count / steps


def metropolis_beta(iterations=120_000, burn_in=20_000, step=0.3, seed=22):
       """算法 19.2：习题 19.7 的对称随机游走 Metropolis。"""
       rng = random.Random(seed)

       def log_target(theta):
              # Beta(1+4, 1+10-4)=Beta(5,7) 的未归一化对数密度。
              if not 0.0 < theta < 1.0:
                     return -math.inf
              return 4 * math.log(theta) + 6 * math.log1p(-theta)

       current = 0.5
       current_log_density = log_target(current)
       samples = []
       accepted = 0
       for iteration in range(iterations):
              # 在整条实线上作对称均匀随机游走；越界候选的目标密度为 0。
              candidate = current + rng.uniform(-step, step)
              candidate_log_density = log_target(candidate)
              log_ratio = candidate_log_density - current_log_density
              if math.log(rng.random()) <= min(0.0, log_ratio):
                     current = candidate
                     current_log_density = candidate_log_density
                     accepted += 1
              if iteration >= burn_in:
                     samples.append(current)
       return samples, accepted / iterations


def gibbs_bivariate_normal(
       correlation=0.8, iterations=110_000, burn_in=10_000, seed=23
):
       """算法 19.3 与例 19.10：依次抽两个一元满条件正态分布。"""
       rng = random.Random(seed)
       conditional_sd = math.sqrt(1 - correlation ** 2)
       x1 = x2 = 0.0
       first, second = [], []
       for iteration in range(iterations):
              x1 = rng.gauss(correlation * x2, conditional_sd)
              x2 = rng.gauss(correlation * x1, conditional_sd)
              if iteration >= burn_in:
                     first.append(x1)
                     second.append(x2)
       return first, second


def conditional_mode(upper, derivative):
       """对数凹满条件密度的导数单调递减，用二分法找唯一众数。"""
       left, right = 1e-12, upper - 1e-12
       for _ in range(80):
              middle = (left + right) / 2
              if derivative(middle) > 0:
                     left = middle
              else:
                     right = middle
       return (left + right) / 2


def sample_theta_given_eta(eta, rng):
       """习题 19.8：p(theta|eta,y) 的均匀包络接受-拒绝抽样。"""
       upper = 1.0 - eta

       def log_density(theta):
              return (
                     math.log(theta)
                     + 14 * math.log(2 * theta + 1)
                     + 5 * math.log(upper - theta)
              )

       mode = conditional_mode(
              upper,
              lambda theta: 1 / theta + 28 / (2 * theta + 1) - 5 / (upper - theta),
       )
       maximum = log_density(mode)
       while True:
              candidate = rng.uniform(1e-12, upper - 1e-12)
              if math.log(rng.random()) <= log_density(candidate) - maximum:
                     return candidate


def sample_eta_given_theta(theta, rng):
       """习题 19.8：p(eta|theta,y) 的均匀包络接受-拒绝抽样。"""
       upper = 1.0 - theta

       def log_density(eta):
              return (
                     math.log(eta)
                     + math.log(2 * eta + 3)
                     + 5 * math.log(upper - eta)
              )

       mode = conditional_mode(
              upper,
              lambda eta: 1 / eta + 2 / (2 * eta + 3) - 5 / (upper - eta),
       )
       maximum = log_density(mode)
       while True:
              candidate = rng.uniform(1e-12, upper - 1e-12)
              if math.log(rng.random()) <= log_density(candidate) - maximum:
                     return candidate


def gibbs_exercise_19_8(iterations=90_000, burn_in=10_000, seed=24):
       """习题 19.8：用两个非标准满条件分布进行 Gibbs 抽样。"""
       rng = random.Random(seed)
       theta, eta = 0.3, 0.2
       theta_samples, eta_samples = [], []
       for iteration in range(iterations):
              theta = sample_theta_given_eta(eta, rng)
              eta = sample_eta_given_theta(theta, rng)
              if iteration >= burn_in:
                     theta_samples.append(theta)
                     eta_samples.append(eta)
       return theta_samples, eta_samples


def exact_moments_exercise_19_8():
       """展开多项式，并用二维 Dirichlet 积分计算精确后验矩。"""
       def simplex_integral(theta_power, eta_power):
              # 积分 theta^r eta^s (1-theta-eta)^5，区域为二维单位单纯形。
              return (
                     math.gamma(theta_power + 1)
                     * math.gamma(eta_power + 1)
                     * math.gamma(6)
                     / math.gamma(theta_power + eta_power + 8)
              )

       def unnormalized_moment(extra_theta, extra_eta):
              # 后验核：theta(2theta+1)^14 eta(2eta+3)(1-theta-eta)^5。
              return sum(
                     math.comb(14, power) * 2 ** power
                     * (
                            3 * simplex_integral(power + 1 + extra_theta, 1 + extra_eta)
                            + 2 * simplex_integral(power + 1 + extra_theta, 2 + extra_eta)
                     )
                     for power in range(15)
              )

       normalizer = unnormalized_moment(0, 0)
       theta_mean = unnormalized_moment(1, 0) / normalizer
       eta_mean = unnormalized_moment(0, 1) / normalizer
       theta_variance = unnormalized_moment(2, 0) / normalizer - theta_mean ** 2
       eta_variance = unnormalized_moment(0, 2) / normalizer - eta_mean ** 2
       return theta_mean, theta_variance, eta_mean, eta_variance


mc_value, exercise_value = monte_carlo_examples()
print("【普通蒙特卡罗】")
print(f"example 19.1 estimate = {mc_value:.6f} (exact 0.855624)")
print(f"exercise 19.1 estimate = {exercise_value:.6f} (exact {math.sqrt(2 * math.pi):.6f})")
triangular_samples, acceptance = accept_reject_triangular()
print(f"accept-reject rate = {acceptance:.6f} (theory 0.500000)")
print(f"triangular mean = {mean(triangular_samples):.6f} (theory 0.666667)")
print(f"weather sunny frequency = {weather_chain():.6f} (stationary 0.833333)")

beta_samples, beta_acceptance = metropolis_beta()
print("\n【习题 19.7：Beta 后验的 Metropolis 抽样】")
print(f"acceptance rate = {beta_acceptance:.6f}")
print(f"mean = {mean(beta_samples):.6f} (exact {5 / 12:.6f})")
print(f"variance = {variance(beta_samples):.6f} (exact {35 / 1872:.6f})")
print(f"lag-1 correlation = {lag1_correlation(beta_samples):.6f}")

normal_x1, normal_x2 = gibbs_bivariate_normal()
normal_covariance = covariance(normal_x1, normal_x2)
normal_correlation = normal_covariance / math.sqrt(
       variance(normal_x1) * variance(normal_x2)
)
print("\n【例 19.10：二元正态 Gibbs 抽样】")
print(f"means = ({mean(normal_x1):.6f}, {mean(normal_x2):.6f})")
print(f"variances = ({variance(normal_x1):.6f}, {variance(normal_x2):.6f})")
print(f"correlation = {normal_correlation:.6f} (target 0.800000)")
print(f"x1 lag-1 correlation = {lag1_correlation(normal_x1):.6f}")

theta_samples, eta_samples = gibbs_exercise_19_8()
exact_theta_mean, exact_theta_variance, exact_eta_mean, exact_eta_variance = (
       exact_moments_exercise_19_8()
)
print("\n【习题 19.8：非标准满条件 Gibbs 抽样】")
print(f"theta mean = {mean(theta_samples):.6f} (exact {exact_theta_mean:.6f})")
print(f"theta variance = {variance(theta_samples):.6f} (exact {exact_theta_variance:.6f})")
print(f"eta mean = {mean(eta_samples):.6f} (exact {exact_eta_mean:.6f})")
print(f"eta variance = {variance(eta_samples):.6f} (exact {exact_eta_variance:.6f})")
print(f"maximum theta+eta = {max(x + y for x, y in zip(theta_samples, eta_samples)):.6f}")
```

运行输出：

```text
【普通蒙特卡罗】
example 19.1 estimate = 0.855733 (exact 0.855624)
exercise 19.1 estimate = 2.495070 (exact 2.506628)
accept-reject rate = 0.501354 (theory 0.500000)
triangular mean = 0.668379 (theory 0.666667)
weather sunny frequency = 0.831630 (stationary 0.833333)

【习题 19.7：Beta 后验的 Metropolis 抽样】
acceptance rate = 0.614733
mean = 0.415783 (exact 0.416667)
variance = 0.018546 (exact 0.018697)
lag-1 correlation = 0.643492

【例 19.10：二元正态 Gibbs 抽样】
means = (0.002436, 0.000076)
variances = (1.003153, 1.003201)
correlation = 0.799936 (target 0.800000)
x1 lag-1 correlation = 0.639879

【习题 19.8：非标准满条件 Gibbs 抽样】
theta mean = 0.519803 (exact 0.519955)
theta variance = 0.017825 (exact 0.017763)
eta mean = 0.123368 (exact 0.123170)
eta variance = 0.006615 (exact 0.006552)
maximum theta+eta = 0.964565
```

输出说明：

- 普通 MC 有 $O(n^{-1/2})$ 随机误差，估计不必逐位等于真值；
- Beta 链接受率约 $0.615$，但滞后 1 相关仍约 $0.643$，再次说明接受率不等于独立性；
- 二元正态 Gibbs 的 $X_1$ 滞后 1 相关约为 $\rho^2=0.64$，与理论相符；
- 习题 19.8 所有样本满足 $\theta+\eta<1$，MCMC 矩与独立解析积分吻合。

---

## 19.7 习题解答

### 习题 19.1

> 用蒙特卡罗积分法求
> $$
> \int_{-\infty}^{\infty}x^2e^{-x^2/2}dx.
> $$

取标准正态密度

$$
p(x)=\frac1{\sqrt{2\pi}}e^{-x^2/2}.
$$

令

$$
f(x)=\frac{x^2e^{-x^2/2}}{p(x)}
=\sqrt{2\pi}x^2.
$$

若 $X_i\overset{\mathrm{iid}}\sim N(0,1)$，则

$$
I=E[f(X)]
\approx\frac{\sqrt{2\pi}}n\sum_{i=1}^{n}X_i^2.
$$

由 $E[X^2]=1$，精确值为

$$
\boxed{I=\sqrt{2\pi}\approx2.506628}.
$$

代码用 $10^5$ 个样本得到 $2.495070$。

### 习题 19.2

> 证明不可约链若有一个状态非周期，则所有状态都非周期。

记状态 $i$ 的返回时刻集合为

$$
T_i=\{t\ge1:P^t(i,i)>0\},
\quad d(i)=\gcd T_i.
$$

不可约意味着任意 $i,j$ 间存在 $m,n$，使

$$
P^m(i,j)>0,
\qquad
P^n(j,i)>0.
$$

对任意 $t\in T_i$，路径

$$
j\xrightarrow{n}i\xrightarrow{t}i\xrightarrow{m}j
$$

说明 $n+t+m\in T_j$；不走中间的 $i$ 返回环，路径

$$
j\xrightarrow{n}i\xrightarrow{m}j
$$

又说明 $n+m\in T_j$。所以 $d(j)$ 同时整除 $n+t+m$ 与 $n+m$，从而整除其差 $t$。这对所有 $t\in T_i$ 成立，因此

$$
d(j)\mid d(i).
$$

交换 $i,j$ 同理得到 $d(i)\mid d(j)$，故 $d(i)=d(j)$。若某个 $d(i)=1$，则所有状态周期均为 1。

### 习题 19.3

转移矩阵（列随机约定）为

$$
P=\begin{bmatrix}
1/2&1/2&0&0\\
1/2&0&1/2&0\\
0&1/2&0&0\\
0&0&1/2&1
\end{bmatrix}.
$$

**可约性**：从状态 4 出发，以概率 1 永远留在 4，无法到达 1、2、3，故不是任意状态互达，链可约。

**非周期性**：

- 状态 1 有自环 $p_{11}=1/2>0$，周期为 1；
- 状态 1、2、3 互相沟通，所以由习题 19.2，它们周期都为 1；
- 状态 4 有自环 $p_{44}=1$，周期也为 1。

故每个状态都非周期，但整条链可约。

### 习题 19.4

转移矩阵为

$$
P=\begin{bmatrix}
0&1/2&0&0\\
1&0&1/2&0\\
0&1/2&0&1\\
0&0&1/2&0
\end{bmatrix}.
$$

状态图是连通线 $1\leftrightarrow2\leftrightarrow3\leftrightarrow4$，每条允许边可双向到达，故链不可约。

把状态分成

$$
A=\{1,3\},
\qquad B=\{2,4\}.
$$

每一步必从 $A$ 到 $B$ 或从 $B$ 到 $A$，所以返回原状态只能用偶数步；又每个状态都存在 2 步返回路径，因此所有返回时刻的最大公约数为 2：

$$
d(i)=2,
\qquad i=1,2,3,4.
$$

链不可约但周期为 2。

### 习题 19.5

> 原题：证明可逆马尔可夫链一定不可约。

**按标准定义，命题不成立，不能证明。**

反例取两状态恒等转移矩阵

$$
P=\begin{bmatrix}1&0\\0&1\end{bmatrix}.
$$

任取 $\pi=(a,1-a)^\top$，均有

$$
p_{ij}\pi_j=p_{ji}\pi_i,
$$

所以链关于 $\pi$ 可逆。但从状态 1 永远不能到状态 2，链可约。

可成立的修正版是：若链关于处处正的 $\pi$ 满足细致平衡，且无向正流图

$$
\{\{i,j\}:p_{ij}\pi_j>0\}
$$

连通，则链不可约。连通性是额外条件，不是可逆性本身的推论。

### 习题 19.6

> 从一般 MH 推导单分量 MH。

设当前状态为

$$
x=(x_j,x_{-j}),
$$

候选只改第 $j$ 维：

$$
x'=(x_j',x_{-j}).
$$

一般 MH 接受率为

$$
\alpha(x,x')
=\min\left\{1,
\frac{p(x')q(x',x)}{p(x)q(x,x')}
\right\}.
$$

条件建议只作用于第 $j$ 维：

$$
q(x,x')=q_j(x_j,x_j'\mid x_{-j}).
$$

又因

$$
p(x)=p(x_{-j})p(x_j\mid x_{-j}),
$$

$$
p(x')=p(x_{-j})p(x_j'\mid x_{-j}),
$$

共同边缘 $p(x_{-j})$ 抵消，得到

$$
\boxed{
\alpha_j
=\min\left\{1,
\frac{p(x_j'\mid x_{-j})q_j(x_j',x_j\mid x_{-j})}
{p(x_j\mid x_{-j})q_j(x_j,x_j'\mid x_{-j})}
\right\}
}.
$$

依次对 $j=1,\ldots,k$ 应用该更新，即单分量 MH。一轮中前面分量使用新值、后面分量使用上一轮值，正是式 (19.47)。

### 习题 19.7

先验为

$$
	heta\sim\operatorname{Beta}(1,1),
$$

观测 $n=10$ 次伯努利试验中成功 $k=4$ 次。似然核为

$$
p(y\mid\theta)\propto\theta^4(1-\theta)^6.
$$

所以后验核

$$
p(\theta\mid y)
\propto\theta^{1+4-1}(1-\theta)^{1+6-1},
$$

即

$$
	heta\mid y\sim\operatorname{Beta}(5,7).
$$

解析均值和方差：

$$
E[\theta\mid y]
=\frac5{5+7}
=\frac5{12}
\approx0.416667,
$$

$$
\operatorname{Var}(\theta\mid y)
=\frac{5\times7}{(5+7)^2(5+7+1)}
=\frac{35}{1872}
\approx0.018697.
$$

采用对称随机游走

$$
	heta'=\theta+\varepsilon,
\qquad \varepsilon\sim U(-0.3,0.3),
$$

越界候选的目标密度设为 0。对称性使接受率为

$$
\alpha
=\min\left\{1,
\frac{(\theta')^4(1-\theta')^6}
{\theta^4(1-\theta)^6}
\right\}.
$$

代码保留 $10^5$ 个燃烧期后样本，得到均值 $0.415783$、方差 $0.018546$，与解析值相符。

### 习题 19.8

五种结果概率为

$$
\left(
\frac\theta4+\frac18,
\frac\theta4,
\frac\eta4,
\frac\eta4+\frac38,
\frac12(1-\theta-\eta)
\right),
$$

观测计数为

$$
y=(14,1,1,1,5).
$$

#### 1. 参数域与先验假设

概率非负要求

$$
	heta>0,
\qquad\eta>0,
\qquad\theta+\eta<1.
$$

原题未指定先验。为使“用 Gibbs 估计均值和方差”有确定含义，这里采用有效三角域上的均匀先验；若采用其他先验，后验矩会改变。

#### 2. 后验核

多项分布似然忽略与参数无关常数后为

$$
\begin{aligned}
p(\theta,\eta\mid y)
\propto{}&
\left(\frac\theta4+\frac18\right)^{14}
\left(\frac\theta4\right)
\left(\frac\eta4\right)
\left(\frac\eta4+\frac38\right)\\
&\cdot\left[\frac12(1-\theta-\eta)\right]^5.
\end{aligned}
$$

吸收常数：

$$
\boxed{
p(\theta,\eta\mid y)
\propto
	heta(2\theta+1)^{14}
\eta(2\eta+3)
(1-\theta-\eta)^5
}.
$$

#### 3. 满条件分布

固定 $\eta$，丢掉与 $\theta$ 无关的因子：

$$
p(\theta\mid\eta,y)
\propto
	heta(2\theta+1)^{14}(1-\theta-\eta)^5,
\quad0<\theta<1-\eta.
$$

固定 $\theta$：

$$
p(\eta\mid\theta,y)
\propto
\eta(2\eta+3)(1-\theta-\eta)^5,
\quad0<\eta<1-\theta.
$$

二者不是标准分布。代码在各自区间用均匀建议做接受-拒绝抽样。其对数密度二阶导均为负，严格对数凹，因此一阶导只有一个零点，可用二分法找到全局众数并构造有效包络。

#### 4. Gibbs 步骤

$$
	heta^{(t)}\sim p(\theta\mid\eta^{(t-1)},y),
$$

$$
\eta^{(t)}\sim p(\eta\mid\theta^{(t)},y).
$$

保留 80000 个燃烧期后样本，得到：

| 参数 | MCMC 均值 | 精确均值 | MCMC 方差 | 精确方差 |
| --- | ---: | ---: | ---: | ---: |
| $\theta$ | 0.519803 | 0.519955 | 0.017825 | 0.017763 |
| $\eta$ | 0.123368 | 0.123170 | 0.006615 | 0.006552 |

精确值来自展开 $(2\theta+1)^{14}(2\eta+3)$ 后逐项使用二维 Dirichlet 积分：

$$
\int_{\theta>0,\eta>0,\theta+\eta<1}
	heta^r\eta^s(1-\theta-\eta)^5d\theta d\eta
=\frac{\Gamma(r+1)\Gamma(s+1)\Gamma(6)}
{\Gamma(r+s+8)}.
$$

这为 Gibbs 结果提供了独立校验。

---

## 19.8 【补充】方法选择与实践边界

| 方法 | 样本关系 | 是否需归一化常数 | 主要要求 | 常见失败方式 |
| --- | --- | --- | --- | --- |
| 直接抽样 | iid | 通常需要完整分布 | 有现成采样器 | 分布非标准 |
| 接受-拒绝 | iid | 需要可控包络 | 有全局 $cq\ge p$ | 高维接受率极低 |
| 重要性抽样 | iid 加权 | 常数可抵消 | $q$ 覆盖 $p$ | 权重退化 |
| 随机游走 MH | 相关 | 不需要 | 可算密度比 | 步长不佳、模式间难跳 |
| 单分量 MH | 相关 | 不需要 | 条件建议易构造 | 强相关导致慢混合 |
| Gibbs | 相关 | 不需要 | 满条件易抽样 | 条件强相关、支持不连通 |

现代替代方案【补充】：

- Hamiltonian Monte Carlo / NUTS 利用梯度进行长距离高接受移动，适合连续可微高维后验；
- slice sampling 自动构造局部采样区间，减少建议尺度调节；
- blocked Gibbs 联合更新强相关变量，通常比逐分量 Gibbs 混合更快；
- 重参数化（如非中心化）可显著改善后验几何；
- 变分推断牺牲渐近精确性换取更快的确定性近似。

---

## 19.9 本章知识清单

### 必须掌握的逻辑

1. 样本均值为何能近似期望：大数定律；
2. 相关 MCMC 样本为何仍可用：马尔可夫链遍历定理；
3. 目标分布为何是 MH 平稳分布：接受率令双向概率流满足细致平衡；
4. 未知归一化常数为何不影响 MH：密度比中抵消；
5. Gibbs 为何接受率为 1：建议分布正好是满条件分布；
6. 正确平稳分布为何还不够：必须检查不可约、非周期和正常返。

### 必须会写的公式

$$
\pi=P\pi,
$$

$$
\widehat f_{m,n}=\frac1{n-m}\sum_{t=m+1}^{n}f(X_t),
$$

$$
\alpha(x,x')
=\min\left\{1,
\frac{p(x')q(x',x)}{p(x)q(x,x')}
\right\},
$$

$$
x_j^{(t)}\sim p(x_j\mid x_{-j}^{(t)}).
$$

### 必须记住的边界

- 平稳不等于已收敛，可逆不等于遍历；
- 有限不可约保证唯一平稳，非周期保证转移分布不振荡；
- 燃烧期只能减小初值影响，不能修复错误或混合差的链；
- 重复状态必须保留，抽稀通常不是提高统计效率的办法；
- 原始样本数不代表信息量，应报告 ESS 和蒙特卡罗标准误；
- 多模式、高相关和受限几何是随机游走 MH/Gibbs 的主要难点。

## 第 19 章一句话回顾

**MCMC 用一个以目标分布为平稳分布且满足遍历条件的马尔可夫链，把难以直接抽样和积分的问题转化为相关样本的时间平均；MH 通过接受率建立细致平衡，Gibbs 则以满条件分布使接受率恒为 1，但正确性之外仍必须认真处理混合、诊断和有效样本量。**
