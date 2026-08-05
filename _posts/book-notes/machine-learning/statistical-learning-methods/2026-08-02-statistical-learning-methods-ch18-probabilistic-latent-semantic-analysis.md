---
title: "《统计学习方法（第 2 版）》第 18 章：概率潜在语义分析"
date: 2026-08-01 02:18:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch18-probabilistic-latent-semantic-analysis
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: statistical-learning-methods
series_order: 19
related: [statistical-learning-methods-ch17-latent-semantic-analysis, statistical-learning-methods-ch19-markov-chain-monte-carlo]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "把 LSA 的低秩话题表示改写为文档、话题、单词的 PLSA 生成模型，推导后验责任与 EM 软计数更新，并辨析参数增长和词袋假设。"
toc: true
math: true
---

> 凡标注 **【补充】** 的内容为原书之外的推导、例子、边界说明或工程实践。本文按原书小节顺序展开，并修复扫描版 OCR 中缺失的求和号、条件竖线和下标。

---

## 0. 本章解决什么问题

### 0.1 从代数低秩近似走向概率生成模型

第 17 章用

$$
X\approx U_k\Sigma_kV_k^\top
\quad\text{或}\quad
X\approx WH
$$

把单词-文本矩阵压缩到低维话题空间。它能发现共现结构，但仍留下几个问题：

1. “话题权重”究竟是不是概率？SVD 中甚至存在负数；
2. 一个文档为什么会出现这些词？矩阵分解只描述近似，不直接描述生成过程；
3. 如何表达“某个词元属于各话题的概率”？
4. 如何用似然原则学习参数、比较模型并处理隐话题？

概率潜在语义分析（probabilistic latent semantic analysis，PLSA，也称 PLSI）给出的答案是：

> 每个文档有一个话题分布；生成每个词元时，先从文档的话题分布抽取话题，再从该话题的单词分布抽取单词。

$$
\boxed{
 d\longrightarrow z\longrightarrow w
}
$$

- $d$：文档（观测变量）；
- $z$：话题（隐变量）；
- $w$：单词（观测变量）。

PLSA 由 Hofmann 于 1999 年提出。它受 LSA 启发，但把“潜在语义方向”改造成有明确归一化约束的概率分布。

### 0.2 真正的难点：隐话题让似然出现“对数套求和”

对一个文档-单词对 $(d,w)$，话题不可观测，必须边缘化：

$$
P(w\mid d)=\sum_{z}P(z\mid d)P(w\mid z).
$$

语料对数似然包含

$$
\log\sum_zP(z\mid d)P(w\mid z).
$$

对数不能直接移入求和号，参数彼此纠缠，无法像有完整话题标签时那样直接数频数。第 9 章的 EM 算法正适合这种结构：

```text
看不见每个词元的话题
  ↓ E 步
用当前参数计算“词元属于各话题的后验概率”
  ↓ M 步
把后验概率当作软计数，重新估计词-话题和文档-话题分布
  ↓
反复迭代，观测数据似然单调不降
```

### 0.3 本章逻辑

```text
18.1 概率潜在语义分析模型
 ├─ 18.1.1 基本想法：话题是词与文档的软类别
 ├─ 18.1.2 生成模型：P(d)P(z|d)P(w|z)
 ├─ 18.1.3 共现模型：P(z)P(w|z)P(d|z)
 └─ 18.1.4 模型性质：参数压缩、单纯形几何、与 LSA 的关系

18.2 概率潜在语义分析算法
 ├─ 观测似然与完全数据似然
 ├─ E 步：P(z|w,d)
 ├─ M 步：拉格朗日乘子推导两组归一化软计数
 └─ 算法 18.1、收敛与复杂度
```

---

## 18.1 概率潜在语义分析模型

### 18.1.1 基本想法

给定文本集合，PLSA 希望同时回答：

- 每篇文档主要讨论哪些话题？即 $P(z\mid d)$；
- 每个话题常使用哪些词？即 $P(w\mid z)$；
- 某次观察到 $(w,d)$ 后，它最可能由哪个话题产生？即 $P(z\mid w,d)$。

话题 $z$ 不能直接观察，是**隐变量**。语义相近的词和文档会对同一话题具有较高概率，但不是被硬分到一个类别：

- 一篇文档可同时属于多个话题；
- 一个词可在多个话题出现；
- 后验 $P(z\mid w,d)$ 会利用具体文档语境给多义词分配不同责任。

这就是“软聚类”的含义。

#### 数据表示

设：

| 符号 | 含义 |
| --- | --- |
| $W=\{w_1,\ldots,w_M\}$ | 词汇集合，大小为 $M$ |
| $D=\{d_1,\ldots,d_N\}$ | 文档指标集合，大小为 $N$ |
| $Z=\{z_1,\ldots,z_K\}$ | 预设的话题集合，大小为 $K$ |
| $n(w_i,d_j)$ | 词 $w_i$ 在文档 $d_j$ 中的出现次数 |
| $n(d_j)=\sum_i n(w_i,d_j)$ | 文档 $d_j$ 的长度 |
| $C=\sum_jn(d_j)$ | 全语料词元总数 |

共现矩阵

$$
T=[n(w_i,d_j)]_{M\times N}
$$

只保留词袋统计，忽略词序。这是 PLSA 的首要建模假设和适用边界：它分析全局词共现话题，不描述语法和长距离顺序关系。

### 18.1.2 生成模型

#### 1. 参数与归一化约束

生成模型使用三组概率：

$$
P(d_j)\ge0,
\qquad
\sum_{j=1}^{N}P(d_j)=1;
$$

$$
P(z_k\mid d_j)\ge0,
\qquad
\sum_{k=1}^{K}P(z_k\mid d_j)=1;
$$

$$
P(w_i\mid z_k)\ge0,
\qquad
\sum_{i=1}^{M}P(w_i\mid z_k)=1.
$$

直觉上：

- $P(d_j)$：随机取一个语料词元时，它来自文档 $d_j$ 的概率；
- $P(z_k\mid d_j)$：文档 $d_j$ 中话题 $z_k$ 的比例；
- $P(w_i\mid z_k)$：话题 $z_k$ 使用单词 $w_i$ 的概率。

在给定语料中，$P(d_j)$ 可直接用文档长度估计：

$$
\widehat P(d_j)=\frac{n(d_j)}{C}.
$$

因此 EM 重点学习后两组参数。

#### 2. 生成过程

对语料中的每个词元独立重复：

1. 按 $P(d)$ 选择文档指标 $d$；
2. 按该文档的 $P(z\mid d)$ 选择话题 $z$；
3. 按该话题的 $P(w\mid z)$ 选择单词 $w$。

原书为叙述方便假设各文档等长 $L$，现实中不需要。长度不同只会改变 $n(d_j)$ 与经验 $P(d_j)$。

#### 3. 联合分布与条件独立

有向图分解为

$$
P(w,z,d)=P(d)P(z\mid d)P(w\mid z).
$$

边缘化隐话题：

$$
\begin{aligned}
P(w,d)
&=\sum_zP(w,z,d)\\
&=P(d)\sum_zP(z\mid d)P(w\mid z)\\
&=P(d)P(w\mid d).
\end{aligned}
\tag{18.2}
$$

模型假设：给定话题后，单词与文档条件独立，

$$
P(w\mid z,d)=P(w\mid z),
\quad\text{即}\quad
w\perp d\mid z.
\tag{18.3}
$$

为什么合理？文档对词的影响完全由话题中介：知道当前话题后，词的选择不再直接依赖文档编号。为什么又只是近似？同一话题在不同作者、时代和文体中仍可能使用不同词，PLSA 不表达这种差异。

#### 4. 语料似然

若把 $C$ 个词元视为条件独立同分布的 $(w,d)$ 观察，则

$$
P(T\mid\theta)
\propto
\prod_{w,d}P(w,d)^{n(w,d)}.
\tag{18.1}
$$

严格的计数数据概率还包含多项式系数

$$
\frac{C!}{\prod_{w,d}n(w,d)!},
$$

但它与模型参数 $\theta$ 无关，所以极大似然时可省略。这解释了式 (18.1) 为什么写成“正比”更严谨。

若文档指标和长度视为给定，常最大化条件似然

$$
\begin{aligned}
\ell(\theta)
&=\sum_{i=1}^{M}\sum_{j=1}^{N}
 n(w_i,d_j)\log P(w_i\mid d_j)\\
&=\sum_{i,j}n(w_i,d_j)
\log\left[\sum_{k=1}^{K}P(w_i\mid z_k)P(z_k\mid d_j)\right].
\end{aligned}
$$

这与联合似然只相差固定的
$\sum_jn(d_j)\log P(d_j)$，所以对 $P(w\mid z),P(z\mid d)$ 得到相同最优解。

#### 5. 图模型中的“重复方框”【补充】

原书图 18.2 用 plate notation 表示重复抽样：

- 外层文档有 $N$ 次；
- 每篇文档内有 $L$ 个词元；
- $d,w$ 为观测节点，$z$ 为隐节点。

更贴近实际的不等长写法是每个文档重复 $n(d_j)$ 次，而不是统一的 $L$。

### 18.1.3 共现模型

生成模型突出 $d\to z\to w$ 的过程；共现模型把文档和单词对称地看作话题生成的两个结果：

$$
z\longrightarrow
\begin{cases}
 w,\\
 d.
\end{cases}
$$

#### 1. 定义

先按 $P(z)$ 选话题，再分别按 $P(w\mid z)$ 与 $P(d\mid z)$ 选词和文档。于是

$$
P(w,z,d)=P(z)P(w\mid z)P(d\mid z),
$$

$$
P(w,d)=\sum_{z\in Z}P(z)P(w\mid z)P(d\mid z).
\tag{18.5}
$$

语料似然仍为

$$
P(T\mid\theta)
\propto\prod_{w,d}P(w,d)^{n(w,d)}.
\tag{18.4}
$$

共现模型假设

$$
P(w,d\mid z)=P(w\mid z)P(d\mid z),
\quad\text{即}\quad
w\perp d\mid z.
\tag{18.6}
$$

#### 2. 为什么称为对称模型

式 (18.5) 中 $w,d$ 地位对称：给定 $z$ 后二者分别生成。生成模型式 (18.2) 则以文档为起点，$P(z\mid d)$ 直接依赖文档，因此也称非对称模型。

两者表达同一个联合分布族，却使用不同坐标描述参数，因此 EM 的 M 步形式不同。

#### 3. 两种模型等价的完整证明

从生成模型出发，定义

$$
P(z)=\sum_dP(d)P(z\mid d),
$$

当 $P(z)>0$ 时由贝叶斯公式定义

$$
P(d\mid z)=\frac{P(d)P(z\mid d)}{P(z)}.
$$

代入共现模型：

$$
\begin{aligned}
\sum_zP(z)P(w\mid z)P(d\mid z)
&=\sum_zP(z)P(w\mid z)
\frac{P(d)P(z\mid d)}{P(z)}\\
&=P(d)\sum_zP(z\mid d)P(w\mid z),
\end{aligned}
$$

正是生成模型式 (18.2)。

反过来，从共现模型定义

$$
P(d)=\sum_zP(z)P(d\mid z),
$$

当 $P(d)>0$ 时令

$$
P(z\mid d)=\frac{P(z)P(d\mid z)}{P(d)},
$$

同样可恢复式 (18.2)。故两者对 $P(w,d)$ 的表示等价。

**成立条件与边界**：若某个 $P(z)=0$，其条件分布 $P(d\mid z)$ 不可由除法定义，但该话题对联合分布没有贡献，可以删除或任意指定其条件分布；若 $P(d)=0$，该文档也不在观测支持集内。

### 18.1.4 模型性质

#### 1. 模型参数

若直接为每个 $(w_i,d_j)$ 指定概率，需要 $MN-1$ 个自由参数。生成模型在不计固定 $P(d)$ 时有

$$
K(M-1)+N(K-1)
$$

个自由参数，数量级为

$$
O(MK+NK).
$$

当 $K\ll M,N$ 时，它用少量话题共享结构，既压缩数据，也降低直接估计 $MN$ 个共现概率的方差。

但“参数更少”不自动保证不过拟合：$P(z\mid d_j)$ 为每篇训练文档单独设置 $K-1$ 个参数，因此参数仍随文档数 $N$ 线性增长。这也是 PLSA 与 LDA 的关键差别。

#### 2. 单纯形的几何解释

固定文档 $d$ 后，

$$
P(w\mid d)=\sum_zP(z\mid d)P(w\mid z).
\tag{18.7}
$$

向量

$$
\bigl(P(w_1\mid d),\ldots,P(w_M\mid d)\bigr)
$$

满足元素非负、总和为 1，因此位于 $M$ 维空间中的 $(M-1)$ 维概率单纯形

$$
\Delta^{M-1}=\left\{p\in\mathbb R^M:p_i\ge0,\ \sum_ip_i=1\right\}.
$$

每个话题分布 $P(w\mid z_k)$ 也是单词单纯形中的一个点。式 (18.7) 说明，每篇文档分布是这 $K$ 个话题点的凸组合，因此所有可表示文档都落在

$$
\operatorname{conv}\{P(w\mid z_1),\ldots,P(w\mid z_K)\}
$$

内。这个凸包称为**话题单纯形**，维数至多为 $K-1$。

- $K=1$：话题单纯形退化为一个点，所有文档词分布相同；
- $K=2$：是一条线段；
- $K=3$：通常是三角形；
- 若话题点仿射相关，实际维数低于 $K-1$。

这给“潜在语义空间”一个比 SVD 子空间更严格的概率几何解释：文档只能做非负且和为 1 的凸组合，不能任意线性组合或相互抵消。

#### 3. 与潜在语义分析的关系

令联合概率矩阵

$$
X'=[P(w_i,d_j)]_{M\times N},
$$

并定义

$$
U'=[P(w_i\mid z_k)]_{M\times K},
$$

$$
\Sigma'=\operatorname{diag}(P(z_1),\ldots,P(z_K)),
$$

$$
V'=[P(d_j\mid z_k)]_{N\times K}.
$$

共现模型可写成

$$
X'=U'\Sigma'V'^\top.
\tag{18.8}
$$

逐元素检查：

$$
(U'\Sigma'V'^\top)_{ij}
=\sum_{k=1}^{K}P(w_i\mid z_k)P(z_k)P(d_j\mid z_k)
=P(w_i,d_j).
$$

| 对比 | SVD-LSA | PLSA |
| --- | --- | --- |
| 分解 | $X\approx U\Sigma V^\top$ | $X'=U'\Sigma'V'^\top$ |
| 元素 | 可正可负 | 全部非负 |
| 约束 | $U,V$ 列正交 | 各列是归一化概率分布 |
| 目标 | 最小平方重构误差 | 最大化多项分布似然 |
| 含义 | 潜在正交方向 | 概率话题与生成机制 |
| 求解 | 截断 SVD | EM，非凸迭代 |

#### 4. 与 NMF 的关系【补充】

用经验联合分布

$$
\widehat X_{ij}=\frac{n(w_i,d_j)}{C}
$$

逼近模型联合分布 $X'_{ij}$。忽略只依赖数据的常数，负平均对数似然等价于广义 KL 散度：

$$
\begin{aligned}
D_{\mathrm{KL}}(\widehat X\Vert X')
&=\sum_{ij}\left[
\widehat X_{ij}\log\frac{\widehat X_{ij}}{X'_{ij}}
-\widehat X_{ij}+X'_{ij}
\right]\\
&=\text{常数}-\sum_{ij}\widehat X_{ij}\log X'_{ij},
\end{aligned}
$$

因为 $\sum_{ij}\widehat X_{ij}=\sum_{ij}X'_{ij}=1$。所以 PLSA 与第 17 章 KL-NMF 都是在做非负低秩近似，但 PLSA 给因子加了概率归一化和隐变量生成解释。

---

## 18.2 概率潜在语义分析的算法

原书学习生成模型。目标是在给定计数矩阵 $T$ 时，以极大似然估计

$$
\phi_{ik}=P(w_i\mid z_k),
\qquad
	heta_{kj}=P(z_k\mid d_j).
$$

为简化记号，下文用 $n_{ij}=n(w_i,d_j)$。

### 18.2.1 为什么不能直接极大化观测似然

观测数据对数似然为

$$
\ell(\phi,\theta)
=\sum_{i=1}^{M}\sum_{j=1}^{N}n_{ij}
\log\left(\sum_{k=1}^{K}\phi_{ik}\theta_{kj}\right).
$$

困难是 $\log\sum_k$：对 $\phi_{ik}$ 求导时分母含所有话题，对 $\theta_{kj}$ 亦然，两组参数耦合，同时还要满足多组单纯形约束，不能得到一次性的闭式解。

若每个词元的话题标签都已知，问题反而很简单：统计“话题 $k$ 产生词 $i$”和“文档 $j$ 使用话题 $k$”的次数，再分别归一化即可。EM 的思路就是用后验概率补出这些不可见计数的期望。

### 18.2.2 完全数据与 $Q$ 函数

设一个位置上的隐话题指示变量为

$$
I_{ijk}=\mathbf 1\{(w_i,d_j)\text{ 的该词元由 }z_k\text{ 产生}\}.
$$

若所有指示变量可见，忽略固定的 $P(d_j)$ 后，完全数据对数似然是

$$
\ell_c
=\sum_{i,j,k}N_{ijk}
\log[\phi_{ik}\theta_{kj}],
$$

其中 $N_{ijk}$ 是 $(w_i,d_j,z_k)$ 三元组的真实次数，并满足

$$
\sum_kN_{ijk}=n_{ij}.
$$

在第 $t$ 轮参数 $(\phi^{(t)},\theta^{(t)})$ 下，定义责任度

$$
\gamma_{ijk}^{(t)}
=P(z_k\mid w_i,d_j;\phi^{(t)},\theta^{(t)}).
$$

不可见计数的条件期望为

$$
\mathbb E[N_{ijk}\mid T,\phi^{(t)},\theta^{(t)}]
=n_{ij}\gamma_{ijk}^{(t)}.
$$

因此 $Q$ 函数是

$$
\begin{aligned}
Q(\phi,\theta\mid\phi^{(t)},\theta^{(t)})
={}&\sum_{j=1}^{N}n(d_j)\log P(d_j)\\
&+\sum_{i=1}^{M}\sum_{j=1}^{N}\sum_{k=1}^{K}
n_{ij}\gamma_{ijk}^{(t)}
\log[\phi_{ik}\theta_{kj}].
\end{aligned}
\qquad\mathrm{(18.9)}
$$

$P(d_j)$ 可由数据直接估计，第一项与待更新的 $\phi,\theta$ 无关。去掉它得到原书的 $Q'$：

$$
Q'
=\sum_{i=1}^{M}\sum_{j=1}^{N}\sum_{k=1}^{K}
n_{ij}\gamma_{ijk}^{(t)}
\log[\phi_{ik}\theta_{kj}].
\qquad\mathrm{(18.10)}
$$

### 18.2.3 E 步：计算隐话题后验

由贝叶斯公式：

$$
\begin{aligned}
\gamma_{ijk}^{(t)}
&=P(z_k\mid w_i,d_j)\\
&=\frac{P(w_i\mid z_k,d_j)P(z_k\mid d_j)}
{P(w_i\mid d_j)}\\
&=\frac{P(w_i\mid z_k)P(z_k\mid d_j)}
{\sum_{l=1}^{K}P(w_i\mid z_l)P(z_l\mid d_j)}\\
&=\frac{\phi_{ik}^{(t)}\theta_{kj}^{(t)}}
{\sum_{l=1}^{K}\phi_{il}^{(t)}\theta_{lj}^{(t)}}.
\end{aligned}
\qquad\mathrm{(18.11)}
$$

第二行到第三行使用了条件独立假设
$P(w_i\mid z_k,d_j)=P(w_i\mid z_k)$。

对每个有观测的 $(i,j)$：

$$
\gamma_{ijk}\ge0,
\qquad
\sum_{k=1}^{K}\gamma_{ijk}=1.
$$

**直觉**：分子是“文档 $j$ 使用话题 $k$”与“话题 $k$ 生成词 $i$”的联合支持；分母对所有可能话题归一化。

### 18.2.4 M 步：极大化 $Q'$ 的完整推导

把 $Q'$ 拆开：

$$
\begin{aligned}
Q'={}&\sum_{i,j,k}n_{ij}\gamma_{ijk}\log\phi_{ik}\\
&+\sum_{i,j,k}n_{ij}\gamma_{ijk}\log\theta_{kj}.
\end{aligned}
$$

$\phi$ 与 $\theta$ 已经解耦，可以分别在各自单纯形上优化。

#### 1. 更新 $P(w_i\mid z_k)$

定义话题-单词软计数

$$
S_{ik}=\sum_{j=1}^{N}n_{ij}\gamma_{ijk}.
$$

对每个话题 $k$，求解

$$
\max_{\phi_{1k},\ldots,\phi_{Mk}}
\sum_{i=1}^{M}S_{ik}\log\phi_{ik}
\quad\text{s.t.}\quad
\sum_i\phi_{ik}=1,
\quad\phi_{ik}\ge0.
$$

引入拉格朗日乘子 $\tau_k$：

$$
\mathcal L_k
=\sum_iS_{ik}\log\phi_{ik}+\tau_k\left(1-\sum_i\phi_{ik}\right).
$$

对 $\phi_{ik}$ 求偏导并令其为 0：

$$
\frac{\partial\mathcal L_k}{\partial\phi_{ik}}
=\frac{S_{ik}}{\phi_{ik}}-\tau_k=0,
$$

故

$$
\phi_{ik}=\frac{S_{ik}}{\tau_k}.
$$

对 $i$ 求和并使用 $\sum_i\phi_{ik}=1$：

$$
1=\frac{\sum_iS_{ik}}{\tau_k}
\quad\Longrightarrow\quad
	au_k=\sum_iS_{ik}.
$$

于是

$$
\boxed{
P(w_i\mid z_k)
=\frac{\sum_{j=1}^{N}n(w_i,d_j)P(z_k\mid w_i,d_j)}
{\sum_{m=1}^{M}\sum_{j=1}^{N}n(w_m,d_j)P(z_k\mid w_m,d_j)}
}
\qquad\mathrm{(18.12)}
$$

分子是话题 $k$ 分给词 $i$ 的期望次数，分母是话题 $k$ 分到的全部期望词元数。

#### 2. 更新 $P(z_k\mid d_j)$

定义文档-话题软计数

$$
R_{kj}=\sum_{i=1}^{M}n_{ij}\gamma_{ijk}.
$$

对每个文档 $j$，求解

$$
\max_{\theta_{1j},\ldots,\theta_{Kj}}
\sum_{k=1}^{K}R_{kj}\log\theta_{kj}
\quad\text{s.t.}\quad
\sum_k\theta_{kj}=1.
$$

引入 $\rho_j$，同样有

$$
\frac{R_{kj}}{\theta_{kj}}-\rho_j=0
\quad\Longrightarrow\quad
	heta_{kj}=\frac{R_{kj}}{\rho_j}.
$$

归一化给出

$$
\rho_j=\sum_kR_{kj}
=\sum_i n_{ij}\sum_k\gamma_{ijk}
=\sum_i n_{ij}
=n(d_j).
$$

故

$$
\boxed{
P(z_k\mid d_j)
=\frac{\sum_{i=1}^{M}n(w_i,d_j)P(z_k\mid w_i,d_j)}
{n(d_j)}
}
\qquad\mathrm{(18.13)}
$$

它就是文档内各词元对话题 $k$ 的平均责任度。

#### 3. 若同时估计 $P(d_j)$【补充】

保留 $Q$ 的第一项并约束 $\sum_jP(d_j)=1$，完全相同的拉格朗日推导得到

$$
P(d_j)=\frac{n(d_j)}{C}.
$$

这不依赖隐话题，因此可在 EM 前直接算出。

### 18.2.5 算法 18.1

**输入**：词集合 $W$、文档集合 $D$、话题集合 $Z$、计数矩阵 $T=[n_{ij}]$。

**输出**：$P(w_i\mid z_k)$ 和 $P(z_k\mid d_j)$。

1. 取严格正且已归一化的初值 $\phi_{ik},\theta_{kj}$；
2. 重复直到收敛：
  - **E 步**：按式 (18.11) 计算所有非零 $n_{ij}$ 对应的 $\gamma_{ijk}$；
  - **M 步**：按式 (18.12) 更新 $\phi$，按式 (18.13) 更新 $\theta$；
  - 计算对数似然，检查相对增量或参数变化；
3. 返回参数。

严格正初始化很重要：若 $\phi_{ik}$ 或 $\theta_{kj}$ 为 0，相应责任度可能永远为 0，EM 无法恢复该路径。这与 NMF 的零锁定相似。

### 18.2.6 EM 为什么有效：似然单调性

令任意分布 $q_{ijk}$ 满足 $\sum_kq_{ijk}=1$。对每个 $(i,j)$，

$$
\begin{aligned}
\log P(w_i\mid d_j;\phi,\theta)
&=\log\sum_kq_{ijk}
\frac{\phi_{ik}\theta_{kj}}{q_{ijk}}\\
&\ge\sum_kq_{ijk}
\log\frac{\phi_{ik}\theta_{kj}}{q_{ijk}},
\end{aligned}
$$

其中不等式来自对数函数的凹性（Jensen 不等式）。

E 步选择旧参数下的后验

$$
q_{ijk}=\gamma_{ijk}^{(t)}
=\frac{\phi_{ik}^{(t)}\theta_{kj}^{(t)}}
{\sum_l\phi_{il}^{(t)}\theta_{lj}^{(t)}},
$$

此时 $\phi_{ik}^{(t)}\theta_{kj}^{(t)}/q_{ijk}$ 对 $k$ 为同一常数，Jensen 等号成立，下界在当前参数处贴住真实似然。M 步最大化下界中依赖新参数的 $Q'$，因此

$$
\ell(\phi^{(t+1)},\theta^{(t+1)})
\ge
\ell(\phi^{(t)},\theta^{(t)}).
$$

**保证到哪里为止**：

- 保证观测似然单调不降；
- 在正则条件下，极限点是驻点；
- 不保证全局最大值，因为 PLSA 目标关于 $\phi,\theta$ 联合非凸；
- 话题标签可任意置换，因此至少有 $K!$ 个等价参数表示。

### 18.2.7 复杂度与工程实现【补充】

令 $S=\operatorname{nnz}(T)$ 为非零词-文档对数量。

- 稠密实现每轮时间 $O(MNK)$；
- 稀疏实现只遍历非零计数，每轮时间 $O(SK)$；
- 显式保存全部责任度需 $O(SK)$ 内存；
- 可在 E 步流式累计两组软计数，将额外内存降到 $O(MK+NK)$。

常用停止条件：

$$
\frac{\ell^{(t+1)}-\ell^{(t)}}{\max(1,|\ell^{(t)}|)}<\varepsilon.
$$

由于局部最优，应使用多个随机初值，按最终似然或验证集困惑度选择结果。

### 18.2.8 新文档、过拟合与替代方案【补充】

#### 新文档的 folding-in

训练后固定 $P(w\mid z)$，对新文档只迭代其 $P(z\mid d_{\mathrm{new}})$：

1. 用现有话题词分布做 E 步；
2. 只用式 (18.13) 更新新文档话题分布。

这称为 folding-in。它能用于检索，但暴露了 PLSA 的根本局限：模型没有定义“未见文档的话题分布如何产生”，每篇新文档都要另做参数估计。

#### 与 LDA 的区别

LDA 在文档话题比例上引入狄利克雷先验：

$$
	heta_d\sim\operatorname{Dirichlet}(\alpha),
$$

从而真正定义新文档的生成机制，并通过先验平滑短文档。PLSA 则把每个 $\theta_d$ 当作独立参数，训练文档增多时参数数目随之增长，更容易过拟合。

#### 其他局限

1. **词袋假设**：忽略词序和上下文；
2. **固定话题数**：$K$ 需外部选择；
3. **局部最优**：结果依赖初始化；
4. **无先验平滑**：稀有词和短文档估计不稳定；
5. **可辨识性有限**：除标签置换外，还可能存在不同参数给出相同或近似联合分布；
6. **话题不必符合人类语义**：最大似然只优化预测共现数据，不直接优化可解释性。

### 18.2.9 易混淆概念与常见误解【补充】

| 误解 | 正确理解 |
| --- | --- |
| 每篇文档只属于一个话题 | $P(z\mid d)$ 是分布，一篇文档可混合多个话题 |
| 每个词固定属于一个话题 | 责任度是 $P(z\mid w,d)$，同一词在不同文档可归属不同话题 |
| $P(w\mid z)$ 与 $P(z\mid w)$ 相同 | 二者条件方向不同，需贝叶斯公式转换 |
| EM 补出真实话题标签 | E 步只计算当前参数下的软后验，不知道真实标签 |
| 似然上升意味着全局最优 | EM 只保证单调到某个驻点 |
| 生成模型与共现模型结构不同，所以分布不同 | 参数化和图方向不同，但表示的 $P(w,d)$ 等价 |
| 参数少于共现表就一定不过拟合 | 每篇文档仍有独立参数，且无先验正则化 |
| 训练完成即可直接处理新文档 | 需要 folding-in；LDA 对新文档生成更自然 |
| 话题编号有固定含义 | 编号可置换，比较两次训练需先对齐话题 |
| 困惑度越低，人工可解释性越高 | 二者常相关但不等价，需分别评估 |

---

## 18.3 【补充】可运行代码：算法 18.1 与习题 18.3

下面只使用 Python 标准库。矩阵存储方向与公式的对应关系是：

| 代码 | 公式 |
| --- | --- |
| `COUNTS[word][document]` | $n(w_i,d_j)$ |
| `phi[topic][word]` | $P(w_i\mid z_k)$ |
| `theta[document][topic]` | $P(z_k\mid d_j)$ |
| `responsibilities[topic]` | $P(z_k\mid w_i,d_j)$ |
| `topic_word_counts` | 式 (18.12) 分子的软计数 |
| `document_topic_counts` | 式 (18.13) 分子的软计数 |

代码利用共现矩阵的稀疏性，只遍历非零元素；固定随机种子以复现输出。

```python
"""《统计学习方法》第 18 章：PLSA 的 EM 算法（仅用 Python 标准库）。"""
import math
import random


def normalize(values):
  """把正数列表归一化为概率分布。"""
  total = sum(values)
  return [value / total for value in values]


def conditional_log_likelihood(counts, word_given_topic, topic_given_document):
  """对应观测似然：sum_ij n_ij log(sum_k phi_ki theta_jk)。"""
  topics = len(word_given_topic)
  value = 0.0
  for word in range(len(counts)):
    for document in range(len(counts[0])):
      count = counts[word][document]
      if count == 0:
        continue
      probability = sum(
        word_given_topic[topic][word]
        * topic_given_document[document][topic]
        for topic in range(topics)
      )
      value += count * math.log(max(probability, 1e-300))
  return value


def fit_plsa(counts, topics, max_iterations=500, tolerance=1e-10, seed=7):
  """按式 (18.11)~(18.13) 训练生成模型。"""
  words = len(counts)
  documents = len(counts[0])
  random_generator = random.Random(seed)

  # phi[k][i] = P(w_i | z_k)，每个话题对单词归一化。
  word_given_topic = [
    normalize([random_generator.random() + 0.2 for _ in range(words)])
    for _ in range(topics)
  ]
  # theta[j][k] = P(z_k | d_j)，每篇文档对话题归一化。
  topic_given_document = [
    normalize([random_generator.random() + 0.2 for _ in range(topics)])
    for _ in range(documents)
  ]

  nonzero_entries = [
    (word, document, counts[word][document])
    for word in range(words)
    for document in range(documents)
    if counts[word][document] > 0
  ]
  history = [
    conditional_log_likelihood(
      counts, word_given_topic, topic_given_document
    )
  ]

  for _ in range(max_iterations):
    # M 步需要的两组期望充分统计量（软计数）。
    topic_word_counts = [
      [0.0 for _ in range(words)] for _ in range(topics)
    ]
    document_topic_counts = [
      [0.0 for _ in range(topics)] for _ in range(documents)
    ]

    # E 步：式 (18.11)，只遍历非零共现项。
    for word, document, count in nonzero_entries:
      weights = [
        word_given_topic[topic][word]
        * topic_given_document[document][topic]
        for topic in range(topics)
      ]
      responsibilities = normalize(weights)
      for topic, responsibility in enumerate(responsibilities):
        expected_count = count * responsibility
        topic_word_counts[topic][word] += expected_count
        document_topic_counts[document][topic] += expected_count

    # M 步：式 (18.12)，按话题归一化词的软计数。
    word_given_topic = [
      normalize(topic_word_counts[topic]) for topic in range(topics)
    ]
    # M 步：式 (18.13)，按文档归一化话题的软计数。
    topic_given_document = [
      normalize(document_topic_counts[document])
      for document in range(documents)
    ]

    new_likelihood = conditional_log_likelihood(
      counts, word_given_topic, topic_given_document
    )
    history.append(new_likelihood)
    relative_gain = (history[-1] - history[-2]) / max(1.0, abs(history[-2]))
    if relative_gain < tolerance:
      break

  return word_given_topic, topic_given_document, history


def to_cooccurrence_parameters(counts, word_given_topic, topic_given_document):
  """用贝叶斯公式把生成模型转换为等价共现模型。"""
  documents = len(counts[0])
  topics = len(word_given_topic)
  document_lengths = [
    sum(counts[word][document] for word in range(len(counts)))
    for document in range(documents)
  ]
  token_count = sum(document_lengths)
  document_prior = [length / token_count for length in document_lengths]
  topic_prior = [
    sum(
      document_prior[document]
      * topic_given_document[document][topic]
      for document in range(documents)
    )
    for topic in range(topics)
  ]
  document_given_topic = [
    [
      document_prior[document]
      * topic_given_document[document][topic]
      / topic_prior[topic]
      for document in range(documents)
    ]
    for topic in range(topics)
  ]
  return document_prior, topic_prior, document_given_topic


def top_items(probabilities, labels, count=4):
  """返回概率最大的若干标签。"""
  order = sorted(
    range(len(probabilities)),
    key=lambda index: (-probabilities[index], labels[index]),
  )
  return ", ".join(
    f"{labels[index]}:{probabilities[index]:.3f}" for index in order[:count]
  )


WORDS = [
  "book", "dads", "dummies", "estate", "guide", "investing",
  "market", "real", "rich", "stock", "value",
]
DOCUMENTS = [f"T{index}" for index in range(1, 10)]
COUNTS = [
  [0, 0, 1, 1, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 1, 0, 0, 1],
  [0, 1, 0, 0, 0, 0, 0, 1, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 1, 0, 0, 0],
  [1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 1, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 1],
  [0, 0, 0, 0, 0, 2, 0, 0, 1],
  [1, 0, 1, 0, 0, 0, 0, 1, 0],
  [0, 0, 0, 1, 1, 0, 0, 0, 0],
]

phi, theta, likelihoods = fit_plsa(COUNTS, topics=3)
token_count = sum(sum(row) for row in COUNTS)
print("【算法 18.1：生成模型 EM】")
print("iterations =", len(likelihoods) - 1)
checkpoints = [0, 1, 2, 5, 20, len(likelihoods) - 1]
checkpoints = list(dict.fromkeys(index for index in checkpoints if index < len(likelihoods)))
print("log-likelihood checkpoints =")
for index in checkpoints:
  print(f"  {index:3d}: {likelihoods[index]:.6f}")
print("nondecreasing =", all(
  likelihoods[index + 1] >= likelihoods[index] - 1e-10
  for index in range(len(likelihoods) - 1)
))
print("perplexity =", round(math.exp(-likelihoods[-1] / token_count), 6))
print("topic word sums =", [round(sum(row), 12) for row in phi])
print("document topic sums =", [round(sum(row), 12) for row in theta])

print("\n【每个话题的高概率词 P(w|z)】")
for topic in range(3):
  print(f"z{topic + 1}: {top_items(phi[topic], WORDS, 3)}")

print("\n【每篇文档的主要话题 P(z|d)】")
for document, label in enumerate(DOCUMENTS):
  print(f"{label}: {top_items(theta[document], ['z1', 'z2', 'z3'], 3)}")

word = WORDS.index("investing")
document = DOCUMENTS.index("T3")
weights = [phi[topic][word] * theta[document][topic] for topic in range(3)]
print("E-step P(z|investing,T3) =", [round(value, 6) for value in normalize(weights)])

print("\n【生成模型与共现模型的等价性】")
p_d, p_z, p_d_given_z = to_cooccurrence_parameters(COUNTS, phi, theta)
maximum_error = 0.0
for word in range(len(WORDS)):
  for document in range(len(DOCUMENTS)):
    asymmetric = p_d[document] * sum(
      phi[topic][word] * theta[document][topic]
      for topic in range(3)
    )
    symmetric = sum(
      p_z[topic] * phi[topic][word] * p_d_given_z[topic][document]
      for topic in range(3)
    )
    maximum_error = max(maximum_error, abs(asymmetric - symmetric))
print("P(z) =", [round(value, 6) for value in p_z])
print("P(d|z) row sums =", [round(sum(row), 12) for row in p_d_given_z])
print("maximum joint-probability error =", f"{maximum_error:.3e}")
```

运行输出：

```text
【算法 18.1：生成模型 EM】
iterations = 45
log-likelihood checkpoints =
    0: -73.112642
    1: -67.711038
    2: -66.108550
    5: -57.303243
   20: -49.270589
   45: -49.268912
nondecreasing = True
perplexity = 4.900414
topic word sums = [1.0, 1.0, 1.0]
document topic sums = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

【每个话题的高概率词 P(w|z)】
z1: investing:0.374, value:0.313, book:0.313
z2: investing:0.311, stock:0.258, dummies:0.172
z3: rich:0.231, investing:0.231, dads:0.154

【每篇文档的主要话题 P(z|d)】
T1: z2:1.000, z3:0.000, z1:0.000
T2: z2:1.000, z1:0.000, z3:0.000
T3: z2:0.652, z1:0.348, z3:0.000
T4: z1:1.000, z2:0.000, z3:0.000
T5: z1:1.000, z2:0.000, z3:0.000
T6: z3:1.000, z2:0.000, z1:0.000
T7: z3:1.000, z1:0.000, z2:0.000
T8: z2:1.000, z1:0.000, z3:0.000
T9: z3:1.000, z1:0.000, z2:0.000
E-step P(z|investing,T3) = [0.39075, 0.60925, 0.0]

【生成模型与共现模型的等价性】
P(z) = [0.206153, 0.374492, 0.419355]
P(d|z) row sums = [1.0, 1.0, 1.0]
maximum joint-probability error = 6.939e-18
```

#### 输出解读

1. 对数似然每轮不降，数值验证了 EM 的理论保证；
2. 三个 `topic word sums` 和九个 `document topic sums` 都为 1，验证参数满足概率约束；
3. $z_1$ 侧重 `value/book`，$z_2$ 侧重 `stock/dummies/market`，$z_3$ 侧重 `rich/dads/estate/real`；`investing` 在所有标题出现，因而在三个话题中都有较高概率，区分作用较弱；
4. T3 同时包含 `book` 与 `market/stock`，所以混合 $z_1,z_2$，而不是硬分到单一话题；
5. `investing` 在 T3 的后验由词概率和文档话题比例共同决定，并不等于任何一个单独参数；
6. 两种参数化计算联合概率的误差仅为浮点舍入量级，验证了模型等价性。

本例语料很小，极大似然给出了许多接近 0 或 1 的概率。这不是“发现了绝对纯的话题”，而是无先验 PLSA 在小样本上的过拟合表现；加入平滑或使用 LDA 会更保守。

---

## 18.4 习题解答

### 习题 18.1

> 证明生成模型与共现模型是等价的。

生成模型为

$$
P(w,d)=P(d)\sum_zP(z\mid d)P(w\mid z).
$$

令

$$
P(z)=\sum_dP(d)P(z\mid d),
\qquad
P(d\mid z)=\frac{P(d)P(z\mid d)}{P(z)}.
$$

则

$$
\begin{aligned}
\sum_zP(z)P(w\mid z)P(d\mid z)
&=\sum_zP(z)P(w\mid z)
\frac{P(d)P(z\mid d)}{P(z)}\\
&=P(d)\sum_zP(z\mid d)P(w\mid z),
\end{aligned}
$$

得到共现模型与生成模型相同的 $P(w,d)$。

反之，给定共现参数，令

$$
P(d)=\sum_zP(z)P(d\mid z),
\qquad
P(z\mid d)=\frac{P(z)P(d\mid z)}{P(d)},
$$

代回即可得到生成模型。两方向都只是边缘化与贝叶斯公式，故表示的联合分布族相同。零概率话题或文档需要按 18.1.3 所述从支持集中删除或单独约定。

### 习题 18.2

> 推导共现模型的 EM 算法。

令

$$
\pi_k=P(z_k),
\quad
\phi_{ik}=P(w_i\mid z_k),
\quad
\psi_{jk}=P(d_j\mid z_k).
$$

约束为

$$
\sum_k\pi_k=1,
\qquad
\sum_i\phi_{ik}=1,
\qquad
\sum_j\psi_{jk}=1.
$$

#### E 步

由贝叶斯公式：

$$
\boxed{
\gamma_{ijk}
=P(z_k\mid w_i,d_j)
=\frac{\pi_k\phi_{ik}\psi_{jk}}
{\sum_{l=1}^{K}\pi_l\phi_{il}\psi_{jl}}
}.
$$

#### $Q$ 函数

$$
Q
=\sum_{i,j,k}n_{ij}\gamma_{ijk}
[\log\pi_k+\log\phi_{ik}+\log\psi_{jk}].
$$

记

$$
S_{ijk}=n_{ij}\gamma_{ijk},
\qquad
S_k=\sum_{i,j}S_{ijk},
\qquad
C=\sum_{i,j}n_{ij}.
$$

#### M 步

对 $\pi$ 的部分，用乘子 $\lambda$：

$$
\mathcal L_\pi
=\sum_kS_k\log\pi_k+\lambda\left(1-\sum_k\pi_k\right).
$$

驻点条件给出 $S_k/\pi_k-\lambda=0$，归一化后 $\lambda=C$，所以

$$
\boxed{P(z_k)=\frac{S_k}{C}}.
$$

对每个固定 $k$，$\phi_{\cdot k}$ 的拉格朗日问题与式 (18.12) 相同：

$$
\boxed{
P(w_i\mid z_k)
=\frac{\sum_jS_{ijk}}{S_k}
}.
$$

同理，对 $\psi_{\cdot k}$：

$$
\boxed{
P(d_j\mid z_k)
=\frac{\sum_iS_{ijk}}{S_k}
}.
$$

因此共现模型 EM 是：正初始化三组参数，交替执行上述 E 步和三组 M 步，直到联合对数似然

$$
\ell=\sum_{i,j}n_{ij}
\log\sum_k\pi_k\phi_{ik}\psi_{jk}
$$

收敛。它同样每轮耗时 $O(SK)$，并同样只保证到局部驻点。

#### 与生成模型更新的对应

两种参数满足

$$
P(d_j)=\sum_k\pi_k\psi_{jk},
\qquad
P(z_k\mid d_j)=\frac{\pi_k\psi_{jk}}{P(d_j)}.
$$

把共现模型 M 步代入上式：

$$
P(z_k\mid d_j)
=\frac{\sum_iS_{ijk}}{n(d_j)},
$$

恰为生成模型式 (18.13)。这不只证明最终分布等价，也解释了两套 EM 更新为何可以互相转换。

### 习题 18.3

> 对原书给出的文本数据集进行概率潜在语义分析。

扫描页恢复的数据为：

| word / title | T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 | T9 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| book | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0 |
| dads | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| dummies | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 0 |
| estate | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| guide | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 |
| investing | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| market | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |
| real | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| rich | 0 | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 1 |
| stock | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 |
| value | 0 | 0 | 0 | 1 | 1 | 0 | 0 | 0 | 0 |

取 $K=3$，使用上面的算法 18.1，得到：

| 话题 | 高概率词 | 语义解释 |
| --- | --- | --- |
| $z_1$ | investing, value, book | 价值投资/投资书籍 |
| $z_2$ | investing, stock, dummies, market | 股票市场与入门投资 |
| $z_3$ | rich, investing, dads, estate, real | 财富与房地产投资 |

文档分组：

- T1、T2、T8 主要为 $z_2$；
- T4、T5 主要为 $z_1$；
- T6、T7、T9 主要为 $z_3$；
- T3 同时含 `book` 与 `market/stock`，得到 $P(z_1\mid T3)=0.348$、$P(z_2\mid T3)=0.652$。

在固定随机种子下，条件对数似然由 $-73.112642$ 单调升至 $-49.268912$，训练困惑度为

$$
\operatorname{perplexity}
=\exp\left(-\frac{\ell}{C}\right)
=4.900414.
$$

困惑度可理解为模型预测每个词元时的“有效候选词数”，越低表示对保留数据的预测越好。但训练困惑度会随模型复杂度增大而下降，选择 $K$ 应看验证集困惑度、稳定性和话题可解释性。

**结果不唯一**：EM 有局部最优，改变随机种子可能交换话题编号或得到不同局部解；改变 $K$ 会改变话题粒度。因此习题结果应报告 $K$、初始化、停止条件和似然，而不能只列一张话题表。

---

## 18.5 【补充】方法对比与选择

| 方法 | 表示约束 | 学习目标 | 新文档 | 主要优点 | 主要局限 |
| --- | --- | --- | --- | --- | --- |
| SVD-LSA | 正交，可负 | 最小平方误差 | 直接投影 | 全局最优、计算成熟 | 非概率、负权重难解释 |
| NMF-LSA | 非负 | 平方或 KL 重构 | 求非负系数 | 加法解释直观 | 局部最优、无完整概率语义 |
| PLSA | 条件概率单纯形 | 最大似然 | folding-in | 隐话题后验清晰 | 参数随文档增长、无文档先验 |
| LDA | 概率分布加狄利克雷先验 | 后验/边缘似然 | 由先验自然生成 | 平滑、泛化更合理 | 推断更复杂 |

选择建议：

- 只需快速降维和检索：截断 SVD；
- 强调非负部件解释：NMF；
- 希望理解概率话题模型和 EM：PLSA；
- 需要严谨的新文档生成、先验平滑和泛化：LDA。

---

## 18.6 本章知识清单

### 必须会写的模型

$$
P(w,d)=P(d)\sum_zP(z\mid d)P(w\mid z),
$$

$$
P(w,d)=\sum_zP(z)P(w\mid z)P(d\mid z).
$$

### 必须会解释的三个概率

| 概率 | 含义 | 在算法中的角色 |
| --- | --- | --- |
| $P(w\mid z)$ | 话题的词分布 | M 步学习 |
| $P(z\mid d)$ | 文档的话题分布 | M 步学习 |
| $P(z\mid w,d)$ | 观察词和文档后的话题后验 | E 步计算 |

### 必须会推导的公式

1. 边缘化隐话题得到式 (18.2) 和式 (18.5)；
2. 用贝叶斯公式证明生成模型与共现模型等价；
3. 用条件独立假设推出 E 步式 (18.11)；
4. 用拉格朗日乘子把期望软计数归一化，得到式 (18.12)、(18.13)；
5. 用 Jensen 不等式说明 EM 似然单调不降；
6. 用矩阵乘积 $X'=U'\Sigma'V'^\top$ 联系 PLSA 与 LSA。

### 必须记住的边界

- PLSA 是词袋模型，不表达词序；
- EM 只保证到局部驻点，话题编号可置换；
- 每篇文档都有独立 $P(z\mid d)$，参数量随文档数增长；
- 新文档需要 folding-in，PLSA 没有文档话题分布的先验；
- 极大似然在小语料上会产生极端概率并过拟合；
- 统计共现话题不保证等于人类期望的语义概念。

## 第 18 章一句话回顾

**PLSA 把词-文档共现解释为“文档选择隐话题、话题生成单词”的概率过程，再用 EM 将不可见话题替换为后验软计数并反复归一化；它赋予低秩话题分解清晰的概率语义，却仍受局部最优、过拟合和无法自然生成新文档的限制。**
