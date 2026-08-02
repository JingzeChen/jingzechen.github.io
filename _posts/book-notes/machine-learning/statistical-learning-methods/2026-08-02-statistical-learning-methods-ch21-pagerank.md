---
title: "《统计学习方法（第 2 版）》第 21 章：PageRank 算法"
date: 2026-08-01 02:21:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch21-pagerank
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch20-latent-dirichlet-allocation, statistical-learning-methods-ch22-unsupervised-learning-summary]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「PageRank 算法」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

> 凡标注 **【补充】** 或 **【辨析】** 的内容为原书之外的推导、严格条件、工程实践或纠错说明。本文沿用原书的列随机矩阵约定：$m_{ij}=P(X_{t+1}=i\mid X_t=j)$，故状态分布按 $R_{t+1}=MR_t$ 演化。

---

## 0. 本章解决什么问题

### 0.1 只数入链为什么不够

在网页、论文引用、社交网络等有向图中，希望给每个结点一个全局重要度。最简单的入度有两个明显缺陷：

1. 来自低质量结点和高质量结点的一条入边被同等对待；
2. 一个结点向 2 个目标投票和向 2000 个目标投票，单条边的贡献不应相同。

PageRank 的递归思想是：

> 一个结点的重要度来自指向它的结点；来源越重要、来源出边越少，这条推荐越有分量。

$$
PR(v_i)
=\sum_{v_j\to v_i}
\frac{PR(v_j)}{L(v_j)}.
$$

这看似循环定义，却恰好可以解释为随机浏览者长期访问各结点的概率，即马尔可夫链平稳分布。

### 0.2 从图到概率再到线性代数

```text
有向图的超链接
    ↓ 每个结点均匀选择一条出边
列随机转移矩阵 M
    ↓ 状态分布递推
R_(t+1) = M R_t
    ↓ 理想图满足不可约、非周期
极限平稳分布 MR = R
    ↓ 现实图有悬挂结点、陷阱和周期
加入阻尼与随机传送
R = dMR + (1-d)u
    ↓
固定点迭代 / 幂法 / 线性方程
```

### 0.3 本章真正的难点

- **存在性**：递归分数是否有解？
- **唯一性**：不同初值是否得到同一排序？
- **收敛性**：迭代会不会振荡或困在局部子图？
- **现实图缺陷**：无出边的悬挂结点使转移矩阵列和为 0；封闭链接群会吸走概率；周期图会振荡。
- **规模**：互联网矩阵极大但稀疏，不能显式求逆。

一般 PageRank 用随机传送同时解决前三类结构问题，稀疏幂迭代解决规模问题。

### 0.4 本章结构

```text
21.1 PageRank 定义
 ├─ 基本想法
 ├─ 有向图与随机游走
 ├─ 基本定义：理想图上的平稳分布
 └─ 一般定义：阻尼 + 随机传送
21.2 PageRank 计算
 ├─ 固定点迭代
 ├─ 幂法
 └─ 代数线性方程
```

---

## 21.1 PageRank 的定义

### 21.1.1 基本想法

把网页看作结点、超链接看作有向边。随机浏览者在当前网页中等概率选择一条出链，不断跳转。若长期访问网页 $v_i$ 的概率为 $PR(v_i)$，则它就是网页的 PageRank。

对图 21.1 的四个结点 $A,B,C,D$：

- $A$ 分别以 $1/3$ 跳到 $B,C,D$；
- $B$ 分别以 $1/2$ 跳到 $A,D$；
- $C$ 以 1 跳到 $A$；
- $D$ 分别以 $1/2$ 跳到 $B,C$。

重要度递归包含两层：

- 入链越多，获得概率流通常越多；
- 入链来源 PageRank 越高且其出度越小，贡献越大。

PageRank 只由图拓扑和模型参数决定，与具体查询无关；搜索引擎还需把它与查询相关性、内容质量等信号结合。

### 21.1.2 有向图和随机游走模型

#### 1. 有向图（定义 21.1）

有向图记为

$$
G=(V,E),
$$

其中 $V$ 是结点集合，$E\subseteq V\times V$ 是有向边集合。

- **路径**：首尾相接的有向边序列；
- **路径长度**：路径包含的边数；
- **强连通**：任意两个结点互相可达；
- **结点周期**：从该结点返回自身的所有可能路径长度的最大公约数；
- **非周期图**：强连通类中结点周期为 1。

原书用“所有返回路径长度都是某个 $k>1$ 的倍数”描述周期性。更严格的周期定义是返回时间集合的最大公约数；在强连通图中所有结点周期相同。

#### 2. 随机游走模型（定义 21.2）

设图有 $n$ 个结点。若结点 $v_j$ 的出度为

$$
L(v_j)=k_j>0,
$$

则

$$
m_{ij}=
\begin{cases}
1/k_j,&(v_j,v_i)\in E,\\
0,&\text{否则}.
\end{cases}
\qquad\mathrm{(21.1)}
$$

转移矩阵

$$
M=[m_{ij}]_{n\times n}
$$

满足

$$
m_{ij}\ge0,
\qquad\mathrm{(21.2)}
$$

$$
\sum_{i=1}^{n}m_{ij}=1.
\qquad\mathrm{(21.3)}
$$

因此 $M$ 是**列随机矩阵**。若 $R_t$ 是时刻 $t$ 的结点概率列向量，全概率公式给出

$$
R_{t+1}=MR_t.
\qquad\mathrm{(21.4)}
$$

图 21.1 的矩阵为

$$
M=
\begin{bmatrix}
0&1/2&1&0\\
1/3&0&0&1/2\\
1/3&0&0&1/2\\
1/3&1/2&0&0
\end{bmatrix}.
$$

每一列描述“从该列结点出发”的概率，不要与常见的行随机约定混用。

#### 3. 悬挂结点【补充】

若结点 $v_j$ 无出边，$k_j=0$，式 (21.1) 无法定义；若粗暴把第 $j$ 列置零，概率总质量会流失，矩阵不再随机。例 21.2 正展示了所有分量逐步衰减到 0。

标准修复是把悬挂列替换为某个概率向量 $u$，均匀版本为

$$
m_{ij}=1/n,
\qquad \forall i.
$$

也可使用个性化传送向量。**必须先修复悬挂列，后面的阻尼矩阵才是合法转移矩阵。**

### 21.1.3 PageRank 的基本定义

#### 1. 定义 21.3

若图强连通且非周期，则随机游走链有限、不可约、非周期。由马尔可夫链遍历定理，对任意初始概率向量 $R_0$：

$$
\lim_{t\to\infty}M^tR_0=R.
\qquad\mathrm{(21.5)}
$$

极限 $R$ 是唯一平稳分布：

$$
MR=R.
\qquad\mathrm{(21.6)}
$$

定义 $R$ 为基本 PageRank：

$$
R=
\begin{bmatrix}
PR(v_1)\\
\vdots\\
PR(v_n)
\end{bmatrix},
$$

其中

$$
PR(v_i)\ge0,
\qquad\mathrm{(21.7)}
$$

$$
\sum_{i=1}^{n}PR(v_i)=1.
\qquad\mathrm{(21.8)}
$$

把 $MR=R$ 的第 $i$ 个分量展开：

$$
\boxed{
PR(v_i)=
\sum_{v_j\in\mathcal M(v_i)}
\frac{PR(v_j)}{L(v_j)}
}.
\qquad\mathrm{(21.9)}
$$

$\mathcal M(v_i)$ 是所有指向 $v_i$ 的结点集合。

#### 2. 定理 21.1 为什么适用

定理 21.1：不可约且非周期的有限状态马尔可夫链有唯一平稳分布，并从任意初始分布收敛到它。

- 强连通等价于链不可约；
- 图非周期等价于链非周期；
- 有限不可约已保证唯一平稳分布；
- 非周期进一步保证 $M^tR_0$ 不振荡并收敛。

从 Perron-Frobenius 角度，1 是 $M$ 的单重主特征值，其他特征值模严格小于 1，因此初始向量中其他特征方向随幂次衰减。

#### 3. 例 21.1

从均匀初值

$$
R_0=(1/4,1/4,1/4,1/4)^\top
$$

反复计算 $R_{t+1}=MR_t$，得到

$$
\boxed{
R=(1/3,2/9,2/9,2/9)^\top
}.
$$

可直接代回验证：

$$
MR=R,
\qquad
\mathbf1^\top R=1.
$$

由于链满足遍历条件，不同初始概率向量也收敛到同一结果，这正是习题 21.2。

#### 4. 基本定义为什么不够

现实图经常包含：

- **悬挂结点**：无出边，转移列无法归一化；
- **秩汇/蜘蛛陷阱**：进入封闭子图后无法离开，概率被吸走；
- **周期结构**：状态分布在若干模式间振荡；
- **非强连通**：结果依赖初始可达类，平稳分布可能不唯一。

因此需要一般 PageRank。

### 21.1.4 PageRank 的一般定义

#### 1. 随机传送模型

先把悬挂列修复，使 $M$ 为列随机矩阵。令

$$
u=\frac1n\mathbf1
$$

为均匀传送分布，阻尼因子满足

$$
0\le d<1.
$$

浏览者每步：

- 以概率 $d$ 按图出链跳转；
- 以概率 $1-d$ 忽略链接，按 $\nu$ 随机传送。

一般转移矩阵为

$$
A=dM+(1-d)\nu\mathbf1^\top
=dM+\frac{1-d}{n}E,
$$

其中 $E=\mathbf1\mathbf1^\top$ 是全 1 矩阵。

因为 $M$ 与 $\nu\mathbf1^\top$ 都列随机，$A$ 也列随机；若 $d<1$ 且 $\nu_i>0$，则

$$
a_{ij}\ge(1-d)\nu_i>0.
$$

所以 $A$ 是正矩阵，对应链不可约且非周期，存在唯一正平稳分布。

#### 2. 定义 21.4

一般 PageRank $R$ 满足

$$
\boxed{
R=dMR+\frac{1-d}{n}\mathbf1
}.
\qquad\mathrm{(21.10)/(21.14)}
$$

逐结点写为

$$
\boxed{
PR(v_i)
=d\sum_{v_j\in\mathcal M(v_i)}
\frac{PR(v_j)}{L(v_j)}+\frac{1-d}{n}
}.
\qquad\mathrm{(21.11)}
$$

并有

$$
PR(v_i)>0,
\qquad\mathrm{(21.12)}
$$

$$
\sum_iPR(v_i)=1.
\qquad\mathrm{(21.13)}
$$

常取 $d=0.85$：平均连续沿链接步数约为

$$
\frac{d}{1-d}\approx5.67,
$$

若把发生传送的那一步也算入一个游走段，平均段长为 $1/(1-d)\approx6.67$。

#### 3. 用压缩映射证明存在、唯一与收敛【补充】

定义固定点映射

$$
T(x)=dMx+(1-d)\nu.
$$

列随机非负矩阵的诱导 $L_1$ 范数为 1，因此

$$
\begin{aligned}
\|T(x)-T(y)\|_1
&=d\|M(x-y)\|_1\\
&\le d\|x-y\|_1.
\end{aligned}
$$

当 $d<1$ 时，$T$ 是压缩映射。Banach 不动点定理立即给出：

1. 固定点 $R$ 存在且唯一；
2. 从任意初值迭代 $R_{t+1}=T(R_t)$ 都收敛；
3. 误差满足
   $$
   \|R_t-R\|_1\le d^t\|R_0-R\|_1;
   $$
4. 可计算后验误差界
   $$
   \|R_t-R\|_1
   \le\frac{d}{1-d}\|R_t-R_{t-1}\|_1.
   $$

这比只引用平稳分布定理更直接地解释阻尼为何有效。

#### 4. 边界条件【辨析】

- $d=0$：$R=\nu$，完全忽略图结构；
- $d\to1$：越来越忠实于链接，但收敛变慢且更易受链接操纵影响；
- $d=1$：随机传送消失，对任意图不再保证唯一性或收敛；
- 若悬挂列仍为零，$A$ 的该列和为 $1-d$，不是转移矩阵。原书称一般定义适用于任意图时，隐含了悬挂列必须先修复。

#### 5. 个性化 PageRank【补充】

把均匀 $\nu$ 换成任意概率向量 $s$：

$$
R=dMR+(1-d)s.
$$

若 $s_i>0$ 对所有结点成立，同样有唯一正解；若 $s$ 稀疏，则需要结合图可达性判断不可约性。Personalized PageRank、Topic-Sensitive PageRank 和 TrustRank 都基于传送分布或可信种子的变化。

---

## 21.2 PageRank 的计算

PageRank 的定义本身就是固定点方程，因此自然产生三种视角：

1. 直接反复应用固定点映射；
2. 求一般转移矩阵的主特征向量；
3. 解线性方程组。

### 21.2.1 迭代算法

一般 PageRank 迭代为

$$
R_{t+1}=dMR_t+\frac{1-d}{n}\mathbf1.
\qquad\mathrm{(21.15)}
$$

#### 算法 21.1

**输入**：修复悬挂列后的列随机矩阵 $M$、阻尼 $0\le d<1$、初始概率向量 $R_0$、容差 $\varepsilon$。

1. 令 $t=0$；
2. 计算
    $$
    R_{t+1}=dMR_t+(1-d)\nu;
    $$
3. 若
    $$
    \|R_{t+1}-R_t\|_1<\varepsilon,
    $$
    停止并输出 $R_{t+1}$；
4. 否则令 $t\leftarrow t+1$，继续。

若 $R_t$ 是概率向量：

$$
\mathbf1^\top R_{t+1}
=d\mathbf1^\top MR_t+(1-d)\mathbf1^\top\nu
=d+(1-d)=1,
$$

且元素非负，所以每一步自动保持概率归一化。

#### 收敛速度和停止误差

压缩常数为 $d$，最坏情况下要使误差缩小到 $\varepsilon$，迭代轮数约满足

$$
t
\gtrsim
\frac{\log(\varepsilon/\|R_0-R\|_1)}{\log d}.
$$

$d$ 越接近 1，谱间隙约 $1-d$ 越小，收敛越慢。实际停止时最好用

$$
\frac{d}{1-d}\|R_t-R_{t-1}\|_1
$$

作为真实误差上界，而不只把相邻差值直接当误差。

#### 例 21.3

图 21.4 的矩阵为

$$
M=
\begin{bmatrix}
0&1/2&0&0\\
1/3&0&0&1/2\\
1/3&0&1&1/2\\
1/3&1/2&0&0
\end{bmatrix}.
$$

原无出边结点 $C$ 在这里被处理为自环（第三列在 $C$ 行为 1），故 $M$ 已是随机矩阵。取 $d=0.8$、均匀传送，迭代极限为

$$
R=
\frac1{148}
\begin{bmatrix}
15\\19\\95\\19
\end{bmatrix}
\approx
\begin{bmatrix}
0.101351\\0.128378\\0.641892\\0.128378
\end{bmatrix}.
$$

$C$ 有自环，会积累大部分链接概率；随机传送使其他结点仍保持正分数。若改用“悬挂列均匀替换”，结果会不同，说明悬挂处理是模型选择的一部分。

### 21.2.2 幂法

#### 1. 一般幂法推导

设方阵 $A$ 有线性无关特征向量 $u_1,\ldots,u_n$，特征值按模排列：

$$
|\lambda_1|>|\lambda_2|\ge\cdots\ge|\lambda_n|.
$$

初始向量若在主特征方向分量非零：

$$
x_0=\sum_{i=1}^{n}a_i u_i,
\qquad a_1\ne0,
$$

则

$$
\begin{aligned}
x_k=A^kx_0
&=\sum_i a_i\lambda_i^ku_i\\
&=a_1\lambda_1^k
\left[
u_1+
\sum_{i=2}^{n}\frac{a_i}{a_1}
\left(\frac{\lambda_i}{\lambda_1}\right)^ku_i
\right].
\end{aligned}
\qquad\mathrm{(21.16)}
$$

因 $|\lambda_i/\lambda_1|<1$，括号中第二项趋于 0：

$$
x_k=a_1\lambda_1^k(u_1+\varepsilon_k),
\quad \varepsilon_k\to0.
\qquad\mathrm{(21.17)}
$$

所以方向趋近 $u_1$：

$$
x_k\sim a_1\lambda_1^ku_1.
\qquad\mathrm{(21.18)}
$$

若某分量 $u_{1j}\ne0$：

$$
\lambda_1
\approx\frac{x_{k+1,j}}{x_{k,j}}.
\qquad\mathrm{(21.19)}
$$

为防数值溢出，每步规范化：

$$
y_{t+1}=Ax_t,
\qquad\mathrm{(21.20)}
$$

$$
x_{t+1}=\frac{y_{t+1}}{\|y_{t+1}\|_\infty}.
\qquad\mathrm{(21.21)}
$$

**成立条件**：需要严格主特征值、初值主方向系数非零。若存在同模特征值，迭代可能振荡；矩阵不可对角化时需用 Jordan 形式分析，但有严格谱间隙仍可收敛到主不变子空间。

#### 2. PageRank 为什么适合幂法

一般转移矩阵

$$
A=dM+\frac{1-d}{n}E
$$

满足

$$
R=AR.
\qquad\mathrm{(21.22)}
$$

当 $0\le d<1$ 时，$A$ 为正随机矩阵。Perron-Frobenius 定理给出：

- 谱半径和主特征值为 1；
- 主特征向量可取严格正；
- 特征值 1 单重；
- 其他特征值模小于 1。

更强地，对满足 $\mathbf1^\top x=0$ 的差分向量，传送项消失：

$$
Ax=dMx,
$$

所以非平稳方向收缩速度至多为 $d$。

#### 3. 算法 21.2

1. 取非零初始向量 $x_0$；
2. 构造
    $$
    A=dM+\frac{1-d}{n}E;
    $$
3. 反复计算 $y_{t+1}=Ax_t$，再以无穷范数规范化；
4. 若 $\|x_{t+1}-x_t\|<\varepsilon$，停止；
5. 最后按分量和规范化为概率向量。

对 PageRank 若直接从概率向量开始，算法 21.1 始终保持分量和为 1，本质上就是以 $L_1$ 归一化的幂法，通常无需显式形成稠密的 $E$。

#### 例 21.4

图 21.5 的转移矩阵为

$$
M=
\begin{bmatrix}
0&0&1\\
1/2&0&0\\
1/2&1&0
\end{bmatrix}.
$$

取 $d=0.85$：

$$
A=0.85M+0.05E
=\begin{bmatrix}
0.05&0.05&0.90\\
0.475&0.05&0.05\\
0.475&0.90&0.05
\end{bmatrix}.
$$

幂法规范化后得到方向约

$$
(0.9756,0.5406,1)^\top,
$$

再按分量和归一化：

$$
R\approx(0.3877,0.2149,0.3974)^\top.
$$

### 21.2.3 代数算法

由固定点方程：

$$
R=dMR+(1-d)\nu,
$$

移项：

$$
(I-dM)R=(1-d)\nu.
\qquad\mathrm{(21.23)}
$$

若 $0\le d<1$ 且 $M$ 随机，则 $\rho(M)=1$，所以

$$
\rho(dM)=d<1.
$$

因此 1 不是 $dM$ 的特征值，$I-dM$ 可逆，唯一解为

$$
\boxed{
R=(1-d)(I-dM)^{-1}\nu
}.
\qquad\mathrm{(21.24)}
$$

均匀传送时 $\nu=\mathbf1/n$，即原书公式。

#### Neumann 级数解释【补充】

因 $\rho(dM)<1$：

$$
(I-dM)^{-1}
=\sum_{k=0}^{\infty}d^kM^k.
$$

故

$$
R=(1-d)\sum_{k=0}^{\infty}d^kM^k\nu.
$$

第 $k$ 项表示从传送分布出发，连续沿链接走 $k$ 步的贡献；权重 $(1-d)d^k$ 正是几何分布。这把代数逆矩阵与随机浏览者解释统一起来。

#### 为什么大型图不显式求逆

| 方法 | 稀疏图每轮/总成本 | 内存 | 适用场景 |
| --- | --- | --- | --- |
| 固定点迭代/幂法 | 每轮 $O(|E|+n)$ | $O(|E|+n)$ | 互联网规模，首选 |
| 稠密直接代数法 | $O(n^3)$ | $O(n^2)$ | 小图验证 |
| 稀疏线性求解 | 依条件数和求解器而定 | 稀疏 | 多右端、预条件良好 |

实际不构造全 1 矩阵，只计算标量概率质量并把传送项加到各分量。分布式 PageRank 也只需沿边发送当前结点分数除以出度。

---

## 21.3 【补充】可运行代码：三种 PageRank 算法

代码只使用 Python 标准库，并显式检查列随机性。对应关系：

| 代码 | 公式或算法 |
| --- | --- |
| `pagerank_iteration` | 式 (21.15)、算法 21.1 |
| `pagerank_power` | 式 (21.20)–(21.22)、算法 21.2 |
| `pagerank_algebra` | 式 (21.23)–(21.24) |
| `repair_dangling` | 原书一般定义隐含的悬挂列修复 |
| `random_surfer` | 一般 PageRank 的随机游走解释 |

```python
"""《统计学习方法》第 21 章：PageRank 三种算法，纯 Python。"""
import random


def normalize(vector):
    total = sum(vector)
    return [value / total for value in vector]


def matvec(matrix, vector):
    return [
        sum(matrix[row][column] * vector[column] for column in range(len(vector)))
        for row in range(len(matrix))
    ]


def matmul(left, right):
    size = len(left)
    return [
        [
            sum(left[row][middle] * right[middle][column] for middle in range(size))
            for column in range(size)
        ]
        for row in range(size)
    ]


def matrix_power(matrix, exponent):
    size = len(matrix)
    result = [[float(row == column) for column in range(size)] for row in range(size)]
    base = [row[:] for row in matrix]
    while exponent:
        if exponent % 2:
            result = matmul(result, base)
        base = matmul(base, base)
        exponent //= 2
    return result


def column_sums(matrix):
    return [sum(matrix[row][column] for row in range(len(matrix)))
            for column in range(len(matrix))]


def repair_dangling(matrix, distribution=None):
    """把列和为 0 的悬挂列替换为指定概率向量。"""
    size = len(matrix)
    repaired = [row[:] for row in matrix]
    distribution = normalize(distribution or [1.0] * size)
    for column, total in enumerate(column_sums(repaired)):
        if abs(total) < 1e-15:
            for row in range(size):
                repaired[row][column] = distribution[row]
    return repaired


def assert_stochastic(matrix):
    if any(value < -1e-15 for row in matrix for value in row):
        raise ValueError("转移矩阵不能含负数")
    if any(abs(total - 1.0) > 1e-12 for total in column_sums(matrix)):
        raise ValueError("每一列必须和为 1；请先修复悬挂列")


def pagerank_iteration(matrix, damping, teleport=None, initial=None,
                       tolerance=1e-13, max_iterations=100_000):
    """算法 21.1：R_(t+1)=d M R_t+(1-d)u。"""
    assert_stochastic(matrix)
    size = len(matrix)
    teleport = normalize(teleport or [1.0] * size)
    rank = normalize(initial or [1.0] * size)
    for iteration in range(1, max_iterations + 1):
        linked = matvec(matrix, rank)
        new_rank = [
            damping * linked[row] + (1.0 - damping) * teleport[row]
            for row in range(size)
        ]
        difference = sum(abs(new_rank[row] - rank[row]) for row in range(size))
        rank = new_rank
        if difference < tolerance:
            return rank, iteration
    raise RuntimeError("PageRank 未在最大迭代次数内收敛")


def pagerank_power(matrix, damping, teleport=None, tolerance=1e-13):
    """算法 21.2：对一般转移矩阵使用无穷范数归一化幂法。"""
    assert_stochastic(matrix)
    size = len(matrix)
    teleport = normalize(teleport or [1.0] * size)
    general = [
        [damping * matrix[row][column] + (1.0 - damping) * teleport[row]
         for column in range(size)]
        for row in range(size)
    ]
    vector = [1.0] * size
    for iteration in range(1, 100_001):
        product = matvec(general, vector)
        scale = max(abs(value) for value in product)
        new_vector = [value / scale for value in product]
        difference = max(abs(new_vector[i] - vector[i]) for i in range(size))
        vector = new_vector
        if difference < tolerance:
            return normalize(vector), iteration
    raise RuntimeError("幂法未收敛")


def solve_linear(matrix, right_hand_side):
    """带部分选主元的高斯消元，用于小图验证代数法。"""
    size = len(matrix)
    augmented = [matrix[row][:] + [right_hand_side[row]] for row in range(size)]
    for column in range(size):
        pivot = max(range(column, size), key=lambda row: abs(augmented[row][column]))
        augmented[column], augmented[pivot] = augmented[pivot], augmented[column]
        pivot_value = augmented[column][column]
        for entry in range(column, size + 1):
            augmented[column][entry] /= pivot_value
        for row in range(size):
            if row == column:
                continue
            factor = augmented[row][column]
            for entry in range(column, size + 1):
                augmented[row][entry] -= factor * augmented[column][entry]
    return [augmented[row][-1] for row in range(size)]


def pagerank_algebra(matrix, damping, teleport=None):
    """式 (21.23)~(21.24)：解 (I-dM)R=(1-d)u。"""
    assert_stochastic(matrix)
    size = len(matrix)
    teleport = normalize(teleport or [1.0] * size)
    coefficient = [
        [float(row == column) - damping * matrix[row][column]
         for column in range(size)]
        for row in range(size)
    ]
    right_hand_side = [(1.0 - damping) * value for value in teleport]
    return normalize(solve_linear(coefficient, right_hand_side))


def random_surfer(matrix, damping, steps=200_000, seed=21):
    """按一般随机游走直接模拟，频率应接近 PageRank。"""
    assert_stochastic(matrix)
    rng = random.Random(seed)
    size = len(matrix)
    state = 0
    counts = [0] * size
    for _ in range(steps):
        if rng.random() >= damping:
            state = rng.randrange(size)
        else:
            weights = [matrix[row][state] for row in range(size)]
            threshold = rng.random()
            cumulative = 0.0
            for candidate, weight in enumerate(weights):
                cumulative += weight
                if threshold <= cumulative:
                    state = candidate
                    break
        counts[state] += 1
    return [count / steps for count in counts]


def rounded(vector, digits=6):
    return [round(value, digits) for value in vector]


M_21_1 = [
    [0.0, 1 / 2, 1.0, 0.0],
    [1 / 3, 0.0, 0.0, 1 / 2],
    [1 / 3, 0.0, 0.0, 1 / 2],
    [1 / 3, 1 / 2, 0.0, 0.0],
]
print("【例 21.1 / 习题 21.2】")
for label, initial in [
    ("uniform", [1, 1, 1, 1]),
    ("start A", [1, 0, 0, 0]),
    ("start B", [0, 1, 0, 0]),
]:
    rank, iterations = pagerank_iteration(M_21_1, 1.0, initial=initial)
    print(f"{label:7}: {rounded(rank, 9)}, iterations={iterations}")
print("M^5 column sums =", rounded(column_sums(matrix_power(M_21_1, 5)), 12))

M_21_3 = [
    [0.0, 1 / 2, 0.0, 0.0],
    [1 / 3, 0.0, 0.0, 1 / 2],
    [1 / 3, 0.0, 1.0, 1 / 2],
    [1 / 3, 1 / 2, 0.0, 0.0],
]
rank_21_3, iterations_21_3 = pagerank_iteration(M_21_3, 0.8)
print("\n【例 21.3】")
print("rank =", rounded(rank_21_3, 9), "iterations =", iterations_21_3)
print("exact =", rounded([15 / 148, 19 / 148, 95 / 148, 19 / 148], 9))

M_21_4 = [
    [0.0, 0.0, 1.0],
    [1 / 2, 0.0, 0.0],
    [1 / 2, 1.0, 0.0],
]
rank_iteration, iteration_count = pagerank_iteration(M_21_4, 0.85)
rank_power, power_count = pagerank_power(M_21_4, 0.85)
rank_algebra = pagerank_algebra(M_21_4, 0.85)
print("\n【例 21.4：三种算法】")
print("iteration =", rounded(rank_iteration, 9), "steps =", iteration_count)
print("power     =", rounded(rank_power, 9), "steps =", power_count)
print("algebra   =", rounded(rank_algebra, 9))
print("maximum method difference =", f"{max(abs(a-b) for a,b in zip(rank_iteration, rank_algebra)):.3e}")
print("random-surfer frequency =", rounded(random_surfer(M_21_4, 0.85), 6))

M_DANGLING = [
    [0.0, 1 / 2, 0.0, 0.0],
    [1 / 3, 0.0, 0.0, 1 / 2],
    [1 / 3, 0.0, 0.0, 1 / 2],
    [1 / 3, 1 / 2, 0.0, 0.0],
]
repaired = repair_dangling(M_DANGLING)
rank_repaired, _ = pagerank_iteration(repaired, 0.85)
print("\n【悬挂结点修复】")
print("raw column sums =", rounded(column_sums(M_DANGLING), 3))
print("repaired column sums =", rounded(column_sums(repaired), 3))
print("repaired rank =", rounded(rank_repaired, 9), "sum =", round(sum(rank_repaired), 12))
```

运行输出：

```text
【例 21.1 / 习题 21.2】
uniform: [0.333333333, 0.222222222, 0.222222222, 0.222222222], iterations=43
start A: [0.333333333, 0.222222222, 0.222222222, 0.222222222], iterations=46
start B: [0.333333333, 0.222222222, 0.222222222, 0.222222222], iterations=52
M^5 column sums = [1.0, 1.0, 1.0, 1.0]

【例 21.3】
rank = [0.101351351, 0.128378378, 0.641891892, 0.128378378] iterations = 55
exact = [0.101351351, 0.128378378, 0.641891892, 0.128378378]

【例 21.4：三种算法】
iteration = [0.387789712, 0.214810627, 0.397399661] steps = 59
power     = [0.387789712, 0.214810627, 0.397399661] steps = 60
algebra   = [0.387789712, 0.214810627, 0.397399661]
maximum method difference = 1.527e-14
random-surfer frequency = [0.387655, 0.215075, 0.39727]

【悬挂结点修复】
raw column sums = [1.0, 1.0, 0.0, 1.0]
repaired column sums = [1.0, 1.0, 1.0, 1.0]
repaired rank = [0.206185567, 0.264604811, 0.264604811, 0.264604811] sum = 1.0
```

三种确定性方法在例 21.4 上误差仅为浮点舍入量级；随机浏览频率有 $O(N^{-1/2})$ 蒙特卡罗波动。悬挂示例说明：随机传送项不能替代悬挂列修复，输入矩阵必须先保持概率质量。

---

## 21.4 习题解答

### 习题 21.1

> 若方阵 $A$ 是随机矩阵，即元素非负、每列和为 1，证明 $A^k$ 仍是随机矩阵，其中 $k$ 是自然数。

记全 1 行向量为 $\mathbf1^\top$。列和为 1 等价于

$$
\mathbf1^\top A=\mathbf1^\top.
$$

首先，$A$ 元素非负，非负矩阵乘积的每个元素都是非负数乘积之和，所以 $A^k$ 元素非负。

其次，用归纳或结合律：

$$
\mathbf1^\top A^k
=(\mathbf1^\top A)A^{k-1}
=\mathbf1^\top A^{k-1}
=\cdots
=\mathbf1^\top.
$$

故 $A^k$ 每列和仍为 1，所以是随机矩阵。$k=0$ 时 $A^0=I$ 也成立。

概率解释是：$(A^k)_{ij}$ 是从 $j$ 出发经过 $k$ 步到达 $i$ 的概率；所有终点事件互斥且完备，其概率和必为 1。代码验证例 21.1 的 $M^5$ 四列和全为 1。

### 习题 21.2

> 例 21.1 中使用不同初始分布，验证仍得到同一极限 PageRank。

例 21.1 的图强连通。它既有长度 2 的返回路径（如 $A\to B\to A$），又有长度 3 的返回路径（如 $A\to D\to B\to A$），故周期

$$
\gcd(2,3)=1.
$$

链不可约且非周期，由定理 21.1，对任意初始概率向量 $R_0$：

$$
M^tR_0\to R.
$$

数值结果：

| 初始分布 | 收敛结果 | 迭代轮数（容差 $10^{-13}$） |
| --- | --- | ---: |
| 均匀 $(1/4,1/4,1/4,1/4)$ | $(1/3,2/9,2/9,2/9)$ | 43 |
| 全在 A $(1,0,0,0)$ | 同上 | 46 |
| 全在 B $(0,1,0,0)$ | 同上 | 52 |

初值影响暂态轨迹和收敛轮数，不影响唯一极限。

也可从谱分解理解。写

$$
R_0=R+\sum_{j\ge2}a_ju_j,
$$

其中 $Mu_j=\lambda_ju_j$ 且 $|\lambda_j|<1$，则

$$
M^tR_0
=R+\sum_{j\ge2}a_j\lambda_j^tu_j
	o R.
$$

### 习题 21.3

> 证明一般 PageRank 中的马尔可夫链具有平稳分布，即式 (21.11) 成立。

先明确必要前提：悬挂列已替换成概率向量，使 $M$ 为列随机矩阵；均匀传送；$0\le d<1$。

一般转移矩阵为

$$
A=dM+\frac{1-d}{n}E.
$$

#### 1. $A$ 是随机矩阵

元素显然非负。第 $j$ 列和：

$$
\sum_i a_{ij}
=d\sum_im_{ij}+\frac{1-d}{n}\sum_i1
=d+(1-d)=1.
$$

#### 2. 链不可约且非周期

对任意 $i,j$：

$$
a_{ij}\ge\frac{1-d}{n}>0.
$$

一步就能从任意结点到任意结点，故不可约；又 $a_{ii}>0$，每个结点有自环，故非周期。

由有限马尔可夫链定理，存在唯一正平稳分布 $R$：

$$
AR=R.
$$

展开 $A$：

$$
R=dMR+\frac{1-d}{n}E R.
$$

因 $R$ 是概率向量，$\mathbf1^\top R=1$，所以

$$
ER=\mathbf1(\mathbf1^\top R)=\mathbf1.
$$

于是

$$
R=dMR+\frac{1-d}{n}\mathbf1.
$$

取第 $i$ 个分量，并用 $m_{ij}=1/L(v_j)$ 当 $v_j\to v_i$：

$$
\boxed{
PR(v_i)
=d\sum_{v_j\in\mathcal M(v_i)}
\frac{PR(v_j)}{L(v_j)}+\frac{1-d}{n}
},
$$

即式 (21.11)。

当 $d=1$ 时 $a_{ij}>0$ 的论证失效；一般图可能没有唯一极限。若悬挂列为零，$A$ 也不是随机矩阵。原命题必须带上这些条件。

### 习题 21.4

> 证明随机矩阵的最大特征值为 1。

设 $A$ 为列随机矩阵。其诱导 1-范数为最大绝对列和：

$$
\|A\|_1
=\max_j\sum_i|a_{ij}|
=1.
$$

若 $Ax=\lambda x$ 且 $x\ne0$，则

$$
|\lambda|\|x\|_1
=\|\lambda x\|_1
=\|Ax\|_1
\le\|A\|_1\|x\|_1
=\|x\|_1.
$$

消去 $\|x\|_1>0$：

$$
|\lambda|\le1.
$$

另一方面，列随机性给出

$$
\mathbf1^\top A=\mathbf1^\top,
$$

所以 1 是 $A^\top$ 的特征值。$A$ 与 $A^\top$ 有相同特征多项式，故 1 也是 $A$ 的特征值。因此谱半径

$$
\boxed{\rho(A)=1}.
$$

这里“最大”指特征值绝对值最大。若矩阵可约或周期，模为 1 的其他特征值可能存在；正的 PageRank 矩阵则由 Perron-Frobenius 保证 1 是唯一主特征值。

---

## 21.5 【补充】常见误解与适用边界

1. **PageRank 就是入度。** 入链贡献还乘来源 PageRank，并除以来源出度。
2. **PageRank 越高越匹配查询。** PageRank 是查询无关的结构重要度，相关性需另一模型计算。
3. **有传送项就无需处理悬挂结点。** 零列会使一般矩阵列和仅为 $1-d$，必须先修复。
4. **阻尼只解决悬挂结点。** 它还打破封闭陷阱、周期性和不可约结构，并控制链接影响范围。
5. **$d=1$ 也属于一般 PageRank 的安全范围。** 此时传送消失，唯一性和收敛保证不再普遍成立。
6. **一般 PageRank 是 $M$ 的特征向量。** 它满足仿射方程；它是 $A=dM+(1-d)\nu\mathbf1^\top$ 的特征向量。
7. **幂法与迭代算法完全不同。** 对 PageRank，它们是不同规范化方式下的同一主特征向量迭代。
8. **显式求逆最精确所以适合大图。** 求逆会破坏稀疏性；大型图应用稀疏矩阵-向量乘。
9. **相邻迭代足够接近就等于真实误差很小。** 应结合 $d/(1-d)$ 的后验误差界。
10. **传送必须均匀。** 任意概率向量都可定义 Personalized PageRank。
11. **PageRank 不会被操纵。** 链接农场可制造概率流，TrustRank 等方法专门缓解排名欺诈。
12. **边权只能相等。** 可把点击、引用强度等归一化成加权转移概率，PageRank 推导不变。

### 与相关图排名方法比较

| 方法 | 核心量 | 特点 |
| --- | --- | --- |
| PageRank | 随机游走平稳概率 | 单一全局重要度，含阻尼 |
| Personalized PageRank | 非均匀传送的平稳概率 | 面向用户、种子或话题 |
| 特征向量中心性 | 邻接矩阵主特征向量 | 通常不含出度归一化和传送 |
| HITS | hub 与 authority 两个分数 | 查询相关子图上互相强化 |
| Katz 中心性 | 所有路径的衰减和 | 含外生基线，形式近似 Neumann 级数 |
| TrustRank | 可信种子传送 | 抑制链接垃圾 |
| BrowseRank | 连续时间浏览行为 | 融合停留时间与用户行为 |

---

## 21.6 本章知识清单

### 必须掌握的逻辑

1. 有向图加均匀出边选择定义列随机矩阵；
2. 基本 PageRank 是理想图随机游走的唯一平稳分布；
3. 悬挂结点、陷阱和周期使基本定义失效；
4. 随机传送把一般矩阵变成正随机矩阵；
5. 一般 PageRank 同时是压缩映射固定点、主特征向量和线性方程解；
6. 大规模计算依赖稀疏幂迭代，而非显式求逆。

### 必须会写的公式

$$
R_{t+1}=MR_t,
$$

$$
PR(v_i)=\sum_{v_j\to v_i}\frac{PR(v_j)}{L(v_j)},
$$

$$
R=dMR+(1-d)\nu,
$$

$$
A=dM+(1-d)\nu\mathbf1^\top,
$$

$$
R=(1-d)(I-dM)^{-1}\nu.
$$

### 必须记住的边界

- 原书矩阵按列随机，很多库按行随机；
- 任意图先修复悬挂列；
- 唯一收敛保证需要 $d<1$ 和正传送；
- $d$ 越大越依赖链接但收敛越慢；
- PageRank 衡量模型定义下的结构访问概率，不等于内容质量或因果影响力；
- 大图只存边和少量向量，不能构造全 1 矩阵或稠密逆矩阵。

## 第 21 章一句话回顾

**PageRank 把结点重要度定义为随机浏览者的长期访问概率：理想图上它是 $MR=R$ 的平稳分布，现实图上通过悬挂修复与阻尼传送得到唯一固定点，并可等价地用概率迭代、幂法或线性方程计算。**
