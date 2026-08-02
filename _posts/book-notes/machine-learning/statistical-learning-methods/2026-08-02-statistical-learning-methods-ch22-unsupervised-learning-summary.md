---
title: "《统计学习方法（第 2 版）》第 22 章：无监督学习方法总结"
date: 2026-08-01 02:22:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch22-unsupervised-learning-summary
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch21-pagerank, statistical-learning-methods-appendices-math-tools]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「无监督学习方法总结」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

> 凡标注 **【补充】** 或 **【辨析】** 的内容为原书之外的推导、严格条件、实践建议或纠错说明。本章不是简单复述结论，而是把第 13–21 章的方法按“任务—模型—策略—算法—假设—边界”重新串联。

---

## 0. 本章解决什么问题

### 0.1 学完很多算法后，真正缺少的是选择框架

第二篇介绍了八类主要方法：

1. 聚类：层次聚类、$k$ 均值、高斯混合模型；
2. 矩阵工具：SVD；
3. 降维：PCA；
4. 话题分析：LSA、NMF、PLSA、LDA；
5. 概率计算：MCMC（MH、Gibbs）；
6. 图分析：PageRank；
7. 还穿插了 EM、变分推理、幂法等基础算法。

如果只记公式，遇到新问题时仍会困惑：究竟该聚类还是降维？该选代数模型还是概率模型？EM、变分推理与 MCMC 是竞争算法，还是不同条件下的工具？本章的任务就是建立一张方法地图。

### 0.2 三层视角

```text
业务问题层
聚类 / 降维 / 话题分析 / 图排序
        ↓ 选择表示与假设
模型与目标层
距离、低秩矩阵、概率生成模型、马尔可夫链
        ↓ 选择求解工具
基础算法层
SVD / NMF / EM / 变分推理 / MCMC / 幂法
```

同一个基础算法可以服务多个模型：SVD 同时支撑 PCA 和 LSA；EM 同时支撑高斯混合与 PLSA；MCMC 同时用于一般贝叶斯后验和 LDA；幂法用于矩阵主特征向量和 PageRank。

### 0.3 无监督学习的共同难点

没有标签并不意味着没有目标，而是目标来自建模假设：

- “近”代表同类；
- 大方差方向保留信息；
- 低秩结构代表潜在因素；
- 共现模式代表话题；
- 长期访问概率代表图结点重要性。

这些假设无法仅靠训练误差证明。无监督模型尤其需要外部任务指标、稳定性、可解释性和领域知识验证。

---

## 22.1 无监督学习方法的关系和特点

### 22.1.1 各种方法之间的关系

原书图 22.1 把方法分为两层。

#### 1. 上层：面向任务的无监督学习方法

| 任务 | 方法 | 直接输出 |
| --- | --- | --- |
| 聚类 | 层次聚类、$k$ 均值、高斯混合 | 簇树、硬标签、软责任度 |
| 降维 | PCA | 低维正交坐标 |
| 话题分析 | LSA、NMF、PLSA、LDA | 话题与文档话题表示 |
| 图分析 | PageRank | 结点重要度概率 |

#### 2. 下层：可复用的基础方法

| 数学问题 | 基础方法 | 服务的上层模型 |
| --- | --- | --- |
| 矩阵分解 | SVD、NMF | PCA、LSA、NMF 话题模型 |
| 特征值求解 | 幂法 | PCA 的主方向、PageRank |
| 隐变量概率学习 | EM | 高斯混合、PLSA |
| 后验近似 | 变分推理 | LDA 及复杂贝叶斯模型 |
| 后验抽样 | MCMC / Gibbs | LDA 及复杂贝叶斯模型 |

#### 3. 为什么要区分“模型”和“算法”

- **模型**规定变量、概率或代数结构以及可表达的现象；
- **策略**规定学习目标，例如重构误差最小、似然最大、后验估计；
- **算法**规定如何数值求解目标，例如 SVD、EM、Gibbs、幂法。

例如 PCA 不是 SVD：PCA 是“中心化数据在低维正交空间中保留最大方差”的模型与策略，SVD 是计算其解的一种算法。LDA 也不是 Gibbs：LDA 是生成模型，Gibbs 和变分推理是两种后验推断方法。

#### 4. 贯穿各章的统一结构

许多方法都可写成“观测 = 潜在结构 + 误差”：

$$
\text{数据}
\approx
\text{基或中心}
\times
\text{潜在坐标或责任度}.
$$

- $k$ 均值：每个样本由一个中心加残差表示；
- PCA/LSA/NMF：矩阵由低秩因子乘积近似；
- GMM/PLSA/LDA：观测由隐类别或隐话题混合生成；
- PageRank：结点分数由邻接转移的固定点决定。

不同方法主要差在约束、噪声模型和隐变量是硬的、软的还是随机的。

### 22.1.2 无监督学习方法

原书表 22.1 用“模型—策略—算法”总结各方法。下面逐项补全其问题来源、目标函数和边界。

#### 1. 层次聚类

**问题**：不知道簇数，或希望同时观察粗粒度与细粒度结构。

凝聚式层次聚类从单点簇开始，反复合并最近的两个簇，形成树状图。若簇间距离为 $D(C_a,C_b)$：

$$
(C_a,C_b)
=\arg\min_{a\ne b}D(C_a,C_b).
$$

距离可取：

- single linkage：两簇最近点距离；
- complete linkage：最远点距离；
- average linkage：跨簇平均距离；
- Ward：合并后类内平方和增量。

**为什么有效**：嵌套合并保留多尺度关系，不需一开始指定唯一簇数。

**边界**：贪心合并不可撤销；不同 linkage 对链状、离群点和球状簇偏好不同；原书称其“类内样本距离最小”是总括性描述，不是所有 linkage 共享的同一全局目标。

#### 2. $k$ 均值聚类

**模型**：每个样本硬分给一个中心。目标为

$$
J(C,\mu)
=\sum_{i=1}^{n}\sum_{k=1}^{K}
c_{ik}\|x_i-\mu_k\|_2^2,
$$

其中 $c_{ik}\in\{0,1\}$ 且 $\sum_kc_{ik}=1$。

交替最小化：

1. 固定中心，选择最近中心；
2. 固定分配，对
   $$
   \sum_{i:c_i=k}\|x_i-\mu_k\|^2
   $$
   求导，得到
   $$
   \mu_k=\frac1{|C_k|}\sum_{i\in C_k}x_i.
   $$

每步不增加 $J$，有限种分配意味着算法最终停止于局部最优。

**适用假设**：欧氏空间、簇近似球状且尺度相近。

**边界**：需预设 $K$；对尺度、初值和离群点敏感；非凸，不保证全局最优；类别变量和非欧氏距离不适合直接套用。

#### 3. 高斯混合模型（GMM）

**问题**：硬分配无法表达边界不确定性和椭圆簇。

生成模型：

$$
p(x_i)=\sum_{k=1}^{K}\pi_k
\mathcal N(x_i\mid\mu_k,\Sigma_k).
$$

隐变量 $z_i$ 表示成分。EM 的 E 步计算软责任度：

$$
r_{ik}
=P(z_i=k\mid x_i)
=\frac{\pi_k\mathcal N(x_i\mid\mu_k,\Sigma_k)}
{\sum_l\pi_l\mathcal N(x_i\mid\mu_l,\Sigma_l)}.
$$

M 步用软计数更新：

$$
N_k=\sum_i r_{ik},
\quad
\pi_k=\frac{N_k}{n},
$$

$$
\mu_k=\frac1{N_k}\sum_i r_{ik}x_i,
$$

$$
\Sigma_k
=\frac1{N_k}\sum_i r_{ik}
(x_i-\mu_k)(x_i-\mu_k)^\top.
$$

**与 $k$ 均值关系**：若各成分协方差为相同的 $\sigma^2I$ 且 $\sigma\to0$，后验责任趋向最近中心的硬分配，GMM 退化到 $k$ 均值式行为。

**边界**：似然非凸；协方差可塌缩到单样本导致似然无界，需正则化或先验；高维全协方差参数量大。

#### 4. PCA

**问题**：在尽量保留信息的同时降低连续特征维数。

对中心化数据 $X\in\mathbb R^{n\times p}$，寻找正交投影 $W\in\mathbb R^{p\times q}$：

$$
W^\top W=I_q.
$$

最大方差形式：

$$
\max_W\operatorname{tr}(W^\top S W),
\quad S=\frac1nX^\top X.
$$

拉格朗日驻点条件：

$$
SW=W\Lambda,
$$

所以列向量是协方差矩阵前 $q$ 个特征向量。

等价最小重构形式：

$$
\min_{W^\top W=I}
\|X-XWW^\top\|_F^2.
$$

由 Eckart–Young 定理，截断 SVD 给全局最优低秩投影。

**边界**：只捕获线性、大方差方向；未标准化时受量纲支配；大方差不必等于任务相关信息；对异常值敏感。

#### 5. LSA

对词文档矩阵 $D\in\mathbb R^{m\times n}$ 作截断 SVD：

$$
D\approx U_K\Sigma_KV_K^\top.
$$

它以全局最小平方重构误差寻找潜在正交语义方向。文档话题坐标可取

$$
\Sigma_KV_K^\top.
$$

**兼具降维与软聚类**：词和文档被映射到连续话题空间，而不是只获得离散标签。

**边界**：因子可正可负，不能直接解释为概率；正交话题不一定符合语义；平方损失未必适合计数数据；同义词改善依赖足够共现证据。

#### 6. NMF

寻找非负因子：

$$
\min_{U,V\ge0}\|D-UV\|_F^2
$$

或最小化广义 KL 散度。非负约束让文档由话题做加法组合，更易解释。

**为什么有效**：无正负抵消，常形成部件化表示。

**边界**：目标联合非凸；存在尺度、排列和局部解不唯一；乘法更新可能零锁定；非负权重未归一化前仍不是概率。

#### 7. PLSA

生成/共现模型：

$$
P(w\mid d)=\sum_zP(w\mid z)P(z\mid d),
$$

或

$$
P(w,d)=\sum_zP(z)P(w\mid z)P(d\mid z).
$$

EM 交替计算 $P(z\mid w,d)$ 和两组软计数归一化，以最大化似然。

**优势**：因子是概率分布，隐话题后验含义明确。

**边界**：每篇训练文档都有独立参数 $P(z\mid d)$，参数随文档数增长；无文档话题先验，短文档易过拟合；新文档需 folding-in。

#### 8. LDA

在 PLSA 基础上加入层次先验：

$$
\theta_d\sim\operatorname{Dir}(\alpha),
\qquad
\phi_z\sim\operatorname{Dir}(\beta),
$$

$$
z_{dn}\sim\operatorname{Cat}(\theta_d),
\qquad
w_{dn}\sim\operatorname{Cat}(\phi_{z_{dn}}).
$$

目标是后验估计，而非单纯极大似然。Dirichlet 共轭使折叠 Gibbs 的更新成为“计数 + 伪计数”，变分推理则用平均场近似后验。

**优势**：共享先验平滑短文档，并为新文档定义生成机制。

**边界**：词袋假设忽略词序；话题数通常预设；Gibbs 可能混合慢，变分推理有系统偏差；Dirichlet 难以表达话题正相关。

#### 9. PageRank

修复悬挂结点后，对列随机链接矩阵 $M$ 定义

$$
R=dMR+(1-d)s,
\quad0\le d<1.
$$

$R$ 是随机浏览者长期访问结点的平稳概率。均匀 $s$ 给一般 PageRank，非均匀 $s$ 给 Personalized PageRank。

**为什么有效**：链接投票按来源重要度递归加权，阻尼保证唯一正固定点。

**边界**：只衡量模型定义下的拓扑重要度，不等于内容质量或查询相关性；会受链接农场影响；$d$ 越接近 1 收敛越慢。

#### 10. 表 22.1 的统一版本

| 任务/方法 | 模型 | 学习策略 | 主要算法 | 核心边界 |
| --- | --- | --- | --- | --- |
| 层次聚类 | 聚类树 | 局部簇距离最小 | 贪心启发式 | 合并不可撤销 |
| $k$ 均值 | $K$ 个中心 | 类内平方和最小 | 交替迭代 | 球状簇、局部最优 |
| GMM | 高斯混合 | 似然最大 | EM | 塌缩与局部最优 |
| PCA | 低维正交空间 | 方差最大/重构最小 | SVD/特征分解 | 仅线性、大方差 |
| LSA | 正交低秩分解 | 平方损失最小 | 截断 SVD | 负权重、非概率 |
| NMF | 非负低秩分解 | 平方/KL 损失最小 | 乘法/坐标更新 | 非凸、不唯一 |
| PLSA | 概率话题混合 | 似然最大 | EM | 文档参数增长 |
| LDA | 贝叶斯话题模型 | 后验估计 | Gibbs/变分 | 混合或近似误差 |
| PageRank | 图上马尔可夫链 | 平稳分布求解 | 幂法 | 拓扑偏差与垃圾链接 |

### 22.1.3 基础机器学习方法

#### 1. 矩阵分解：SVD 与 NMF

SVD 对任意矩阵给出

$$
D=U\Sigma V^\top,
$$

其中 $U,V$ 正交、$\Sigma$ 非负对角。截断 SVD 是无约束低秩平方误差的全局最优解。

NMF 只要求

$$
D\approx UV,
\qquad U,V\ge0,
$$

不要求正交。非负约束改善解释性，却失去闭式全局最优。

| 对比 | SVD | NMF |
| --- | --- | --- |
| 因子符号 | 可正可负 | 非负 |
| 几何约束 | 正交 | 通常不正交 |
| 平方损失全局最优 | 截断 SVD 是 | 一般否 |
| 解的不唯一性 | 符号、重根子空间 | 尺度、排列、局部解 |
| 主要用途 | 降维、压缩、LSA | 部件表示、话题分析 |

#### 2. 隐变量模型：EM、变分推理与 Gibbs

**EM** 使用精确隐变量后验构造

$$
Q(\vartheta\mid\vartheta^{old})
=E_{p(z\mid x,\vartheta^{old})}
[\log p(x,z\mid\vartheta)].
$$

E 步算后验，M 步最大化 $Q$。似然单调不减，但非凸模型只保证局部驻点。

**变分推理** 选择可处理分布族 $q$，最大化

$$
\mathcal L(q,\vartheta)
=E_q[\log p(x,z\mid\vartheta)]-E_q[\log q(z)],
$$

其中

$$
\log p(x\mid\vartheta)-\mathcal L
=D_{\mathrm{KL}}(q\Vert p(z\mid x,\vartheta))\ge0.
$$

它把难后验转成确定性优化，保证 ELBO 单调，不一般保证真实证据每轮单调。

**Gibbs 抽样** 从满条件分布依次抽样：

$$
z_j^{(t)}\sim p(z_j\mid z_{-j}^{(t)},x).
$$

在不可约、非周期、正常返等条件下，链收敛到目标后验，遍历均值收敛到后验期望。

#### 3. 对原书表 22.2 的严谨修订【辨析】

| 方法 | 后验处理 | 保证 | 典型速度 | 实现 | 更适合 |
| --- | --- | --- | --- | --- | --- |
| EM | 精确后验期望 | 似然到局部驻点 | 每轮常较快 | 后验可解时容易 | 简单共轭/指数族模型 |
| 变分 | 受限族近似后验 | ELBO 到局部驻点 | 常比 MCMC 快 | 推导较复杂 | 大规模复杂模型 |
| Gibbs | 后验随机抽样 | 分布/遍历均值收敛 | 可能慢 | 满条件易抽时容易 | 需后验不确定性 |

原书称 Gibbs“依概率收敛于全局最优”不准确：Gibbs 的目标是后验分布，不是优化器。它可以访问多模式后验，但有限时间未必跨越模式，也不自动找到某个全局最优点。

“EM 较快、变分较慢”也不是普遍定律。变分在复杂模型和大数据上常比 MCMC 快；EM 若 E 步昂贵也可能很慢。应比较每轮成本、轮数、精度和并行性。

#### 4. 幂法

对具有唯一严格主特征值的矩阵 $A$：

$$
x_{t+1}=\frac{Ax_t}{\|Ax_t\|}
$$

收敛到主特征向量方向，渐近速度由

$$
\left|\frac{\lambda_2}{\lambda_1}\right|^t
$$

控制。PageRank 的阻尼正矩阵有主特征值 1，其他方向收缩，因此适合幂法。

#### 5. 如何选择推断工具

```text
隐变量后验是否可精确算？
├─ 是：EM（若目标是点估计）
└─ 否：
        ├─ 需要速度/可扩展：变分推理
        ├─ 需要后验不确定性：MCMC
        └─ 两者都重要：先变分初始化，再 MCMC 校准或使用更高级方法
```

---

## 22.2 话题模型之间的关系和特点

本书的四类话题模型为 LSA、NMF、PLSA、LDA。前两者首先是代数低秩模型，后两者是概率生成模型；但它们都试图用少量话题解释高维稀疏词文档数据。

### 22.2.1 从 Bregman 矩阵分解统一 LSA、NMF、PLSA

#### 1. 一般框架

设数据矩阵

$$
D\in\mathbb R^{m\times n},
$$

$m$ 是词汇量、$n$ 是文档数，话题数为 $K$。寻找

$$
U\in\mathbb R^{m\times K},
\qquad
V\in\mathbb R^{K\times n},
$$

使

$$
D\approx UV.
$$

统一优化问题为

$$
\boxed{
\min_{U,V}B_F(D\Vert UV)
\quad\text{s.t. 模型特定约束}
}.
$$

#### 2. Bregman 散度是什么

对严格凸可微函数 $F$，向量 Bregman 散度为

$$
B_F(x\Vert y)
=F(x)-F(y)-\langle\nabla F(y),x-y\rangle.
$$

凸函数的一阶支撑超平面性质给出

$$
F(x)\ge F(y)+\langle\nabla F(y),x-y\rangle,
$$

所以 $B_F(x\Vert y)\ge0$；严格凸时当且仅当 $x=y$ 取 0。

Bregman 散度一般不对称，也不满足三角不等式，因此不是度量。

对矩阵通常逐元素求和。

#### 3. 平方损失是 Bregman 散度

取

$$
F(X)=\frac12\|X\|_F^2,
\qquad \nabla F(Y)=Y.
$$

则

$$
\begin{aligned}
B_F(X\Vert Y)
&=\frac12\|X\|_F^2-\frac12\|Y\|_F^2
-\langle Y,X-Y\rangle\\
&=\frac12\|X-Y\|_F^2.
\end{aligned}
$$

所以 LSA 与平方损失 NMF 共享同一损失，差别来自约束。

#### 4. 广义 KL 散度也是 Bregman 散度

对正元素取

$$
F(X)=\sum_{ij}(x_{ij}\log x_{ij}-x_{ij}).
$$

因 $\partial F/\partial x_{ij}=\log x_{ij}$：

$$
B_F(X\Vert Y)
=\sum_{ij}\left[
x_{ij}\log\frac{x_{ij}}{y_{ij}}-x_{ij}+y_{ij}
\right].
$$

若 $X,Y$ 都全局归一化为概率矩阵，后两项求和抵消，得到普通 KL：

$$
D_{\mathrm{KL}}(X\Vert Y)
=\sum_{ij}x_{ij}\log\frac{x_{ij}}{y_{ij}}.
$$

### 22.2.2 三种矩阵分解模型的具体形式

#### 1. LSA

目标与约束可写为

$$
\min_{U,V}\|D-UV\|_F^2,
$$

$$
U^\top U=I,
\qquad
VV^\top=\Lambda^2,
$$

其中

$$
U=U_K,
\qquad
V=\Sigma_KV_K^\top,
\qquad
\Lambda=\Sigma_K.
$$

因此 $U$ 的列是正交话题方向，$V$ 的行也彼此正交并按奇异值缩放。截断 SVD 给出平方损失下全局最优秩 $K$ 近似。

#### 2. NMF

$$
\min_{U,V\ge0}\|D-UV\|_F^2
$$

或用广义 KL 散度。约束仅为

$$
u_{mk}\ge0,
\qquad
v_{kn}\ge0.
$$

非负让文档成为话题的加法组合，但不自动归一化。对任意正对角矩阵 $S$：

$$
UV=(US)(S^{-1}V),
$$

故存在尺度不唯一；话题还可排列。

#### 3. PLSA

若每个文档的词频列归一化成条件经验分布

$$
D_{wn}=\widehat P(w\mid d_n),
$$

可取

$$
U_{wk}=P(w\mid z_k),
\qquad
V_{kn}=P(z_k\mid d_n).
$$

于是

$$
D\approx UV,
$$

约束为

$$
U\ge0,
\quad V\ge0,
\quad U^\top\mathbf1_m=\mathbf1_K,
\quad V^\top\mathbf1_K=\mathbf1_n.
$$

即 $U,V$ 每列都是概率分布。这正对应原书表 22.3 的约束。

若使用全局归一化的联合矩阵

$$
D_{wn}=\widehat P(w,d_n),
\qquad\sum_{w,n}D_{wn}=1,
$$

则可以令

$$
V_{kn}=P(z_k,d_n)=P(z_k\mid d_n)P(d_n).
$$

此时 $U$ 各列和为 1，但 $V$ 第 $n$ 列和是 $P(d_n)$，不是 1；只有全矩阵和为 1。

**【辨析】** 原书正文说 PLSA 的 $D$ 全局归一化，而表 22.3 又列出 $V^\top\mathbf1=\mathbf1$。这对应两套不同参数化，不能同时直接成立。条件矩阵使用双列归一化；联合矩阵需把 $P(d)$ 吸收到 $V$。

#### 4. 为什么 PLSA 极大似然等价于 KL 分解

令联合经验概率

$$
\widehat P(w,d)=\frac{n(w,d)}{C},
\qquad C=\sum_{w,d}n(w,d),
$$

模型概率为 $Q(w,d)=(UV)_{wd}$。每词元平均对数似然：

$$
\frac1C\ell(U,V)
=\sum_{w,d}\widehat P(w,d)\log Q(w,d).
$$

而

$$
\begin{aligned}
D_{\mathrm{KL}}(\widehat P\Vert Q)
&=\sum_{w,d}\widehat P(w,d)
\log\frac{\widehat P(w,d)}{Q(w,d)}\\
&=\sum_{w,d}\widehat P(w,d)\log\widehat P(w,d)
-\frac1C\ell(U,V).
\end{aligned}
$$

第一项只依赖数据，所以

$$
\boxed{
\max\ell(U,V)
\Longleftrightarrow
\min D_{\mathrm{KL}}(\widehat P\Vert UV)
}.
$$

这就是 PLSA 与 KL-NMF 的深层联系；PLSA 额外赋予因子概率语义和隐变量后验。

#### 5. 表 22.3 的严谨重写

| 方法 | 损失 | $U$ 约束 | $V$ 约束 | 求解性质 |
| --- | --- | --- | --- | --- |
| LSA | $\|D-UV\|_F^2$ | $U^\top U=I$ | $VV^\top=\Lambda^2$ | 截断 SVD 全局最优 |
| NMF | 平方或广义 KL | $U\ge0$ | $V\ge0$ | 联合非凸、局部解 |
| PLSA | KL / 负对数似然 | 非负、词条件归一化 | 非负、条件或联合归一化 | EM 局部驻点 |

### 22.2.3 从概率生成模型统一四种话题模型

#### 1. LSA 与 NMF 的高斯解释

令文档向量为 $d_n$，话题基为 $U$，文档潜在坐标为 $v_n$。假设

$$
d_n\mid U,v_n
\sim\mathcal N(Uv_n,\sigma^2I).
$$

则

$$
p(d_n\mid U,v_n)
\propto
\exp\left[-\frac1{2\sigma^2}
\|d_n-Uv_n\|_2^2\right].
$$

全语料负对数似然忽略常数后为

$$
-\log p(D\mid U,V)
=\frac1{2\sigma^2}\|D-UV\|_F^2+\text{常数}.
$$

所以平方损失矩阵分解等价于各维独立同方差高斯噪声的极大似然。LSA 加正交约束，NMF 加非负约束。

**边界**：词频是离散、非负且方差常随均值变化，高斯同方差假设只是代数解释；Poisson/KL 模型往往更适合计数。

#### 2. PLSA 的隐类别解释

PLSA 对每个词元：

$$
d\to z\to w,
$$

$$
P(w\mid d)=\sum_zP(w\mid z)P(z\mid d).
$$

话题 $z$ 是隐类别，EM 用

$$
P(z\mid w,d)
\propto P(w\mid z)P(z\mid d)
$$

形成软计数。与 NMF 不同，因子归一化为概率；与 LDA 不同，$P(z\mid d)$ 是每篇训练文档的固定参数。

#### 3. LDA 的分层贝叶斯解释

LDA 把 PLSA 的文档话题参数随机化：

$$
	heta_d\sim\operatorname{Dir}(\alpha),
$$

并在完整模型中令

$$
\phi_z\sim\operatorname{Dir}(\beta).
$$

每个位置：

$$
z_{dn}\sim\operatorname{Cat}(\theta_d),
\qquad
w_{dn}\sim\operatorname{Cat}(\phi_{z_{dn}}).
$$

边缘化 $\theta_d$ 后，同文档话题指派不再独立，却因共享先验形成可交换相关；Dirichlet 伪计数实现平滑并为新文档提供统一生成机制。

#### 4. 四种模型的统一对比

| 维度 | LSA | NMF | PLSA | LDA |
| --- | --- | --- | --- | --- |
| 类型 | 代数/可作高斯解释 | 代数/可作非负概率解释 | 概率模型 | 分层贝叶斯模型 |
| 因子 | 可负、正交 | 非负 | 条件概率 | 随机概率向量 |
| 目标 | 平方重构 | 平方/KL 重构 | 最大似然 | 后验/边缘似然 |
| 算法 | 截断 SVD | 迭代非负优化 | EM | Gibbs/变分 |
| 全局保证 | 平方低秩全局最优 | 无 | 无 | 无 |
| 新文档 | 正交投影 | 固定基求系数 | folding-in | 由共享先验推断 |
| 不确定性 | 不表达 | 不表达 | 词元话题后验 | 完整后验近似/样本 |
| 主要优势 | 快、稳定 | 加法解释 | 概率语义 | 平滑与泛化 |
| 主要局限 | 负权重 | 非凸、不唯一 | 参数随文档增长 | 推断复杂、词袋假设 |

### 22.2.4 聚类、降维与话题模型为什么相互重叠【补充】

话题模型兼有两种性质：

- **降维**：文档从 $m$ 维词空间变为 $K$ 维话题表示；
- **软聚类**：话题是词和文档的共享软类别。

若文档话题向量接近 one-hot，话题模型表现得像硬聚类；若文档混合多个话题，它更像连续降维。区别不在算法名称，而在潜在坐标的约束：

| 坐标形式 | 典型模型 | 含义 |
| --- | --- | --- |
| one-hot | $k$ 均值 | 每样本一个簇 |
| 概率单纯形 | GMM、PLSA、LDA | 软类别或混合比例 |
| 任意实数 | PCA、LSA | 连续潜在轴 |
| 非负实数 | NMF | 加法部件权重 |

---

## 22.3 【补充】可运行代码：四类任务的统一实验

本章是总结章，代码不重复前面各章的全部实现，而用一个纯标准库脚本验证共同的学习规律：

- $k$ 均值类内平方和不增；
- GMM 的 EM 似然不减；
- PCA 找到最大方差方向；
- NMF 平方重构损失不增；
- PLSA 的 EM 似然不减且概率因子归一化；
- PageRank 满足平稳固定点。

```python
"""《统计学习方法》第 22 章：无监督方法统一实验，纯 Python。"""
import math
import random


def normalize(values):
        total = sum(values)
        return [value / total for value in values]


def kmeans(points, centers, iterations=20):
        """交替最小化类内平方和。"""
        centers = [center[:] for center in centers]
        history = []
        assignments = None
        for _ in range(iterations):
                assignments = [
                        min(
                                range(len(centers)),
                                key=lambda cluster: sum(
                                        (point[d] - centers[cluster][d]) ** 2
                                        for d in range(len(point))
                                ),
                        )
                        for point in points
                ]
                new_centers = []
                for cluster in range(len(centers)):
                        members = [
                                point for point, label in zip(points, assignments)
                                if label == cluster
                        ]
                        new_centers.append([
                                sum(point[d] for point in members) / len(members)
                                for d in range(len(points[0]))
                        ])
                centers = new_centers
                objective = sum(
                        sum((point[d] - centers[label][d]) ** 2 for d in range(len(point)))
                        for point, label in zip(points, assignments)
                )
                history.append(objective)
                if len(history) > 1 and abs(history[-1] - history[-2]) < 1e-12:
                        break
        return assignments, centers, history


def gaussian_density(value, mean, variance):
        return math.exp(-(value - mean) ** 2 / (2 * variance)) / math.sqrt(
                2 * math.pi * variance
        )


def gmm_em(data, iterations=30):
        """一维两成分 GMM：E 步软责任，M 步加权更新。"""
        weights, means, variances = [0.5, 0.5], [-1.0, 1.0], [4.0, 4.0]

        def log_likelihood():
                return sum(math.log(sum(
                        weights[k] * gaussian_density(value, means[k], variances[k])
                        for k in range(2)
                )) for value in data)

        history = [log_likelihood()]
        for _ in range(iterations):
                responsibilities = []
                for value in data:
                        unnormalized = [
                                weights[k] * gaussian_density(value, means[k], variances[k])
                                for k in range(2)
                        ]
                        responsibilities.append(normalize(unnormalized))
                effective_counts = [
                        sum(row[k] for row in responsibilities) for k in range(2)
                ]
                weights = [count / len(data) for count in effective_counts]
                means = [
                        sum(row[k] * value for row, value in zip(responsibilities, data))
                        / effective_counts[k]
                        for k in range(2)
                ]
                variances = [
                        max(1e-6, sum(
                                row[k] * (value - means[k]) ** 2
                                for row, value in zip(responsibilities, data)
                        ) / effective_counts[k])
                        for k in range(2)
                ]
                history.append(log_likelihood())
        return weights, means, variances, history


def pca_first_component(points, iterations=100):
        """中心化协方差矩阵的幂法，求第一主成分。"""
        dimension = len(points[0])
        mean = [sum(point[d] for point in points) / len(points) for d in range(dimension)]
        centered = [[point[d] - mean[d] for d in range(dimension)] for point in points]
        covariance = [[
                sum(point[i] * point[j] for point in centered) / len(centered)
                for j in range(dimension)
        ] for i in range(dimension)]
        vector = normalize([1.0] * dimension)
        for _ in range(iterations):
                product = [sum(covariance[i][j] * vector[j] for j in range(dimension))
                                   for i in range(dimension)]
                norm = math.sqrt(sum(value * value for value in product))
                vector = [value / norm for value in product]
        eigenvalue = sum(
                vector[i] * covariance[i][j] * vector[j]
                for i in range(dimension) for j in range(dimension)
        )
        total_variance = sum(covariance[i][i] for i in range(dimension))
        return vector, eigenvalue / total_variance


def matmul(left, right):
        return [[
                sum(left[i][k] * right[k][j] for k in range(len(right)))
                for j in range(len(right[0]))
        ] for i in range(len(left))]


def transpose(matrix):
        return [list(row) for row in zip(*matrix)]


def squared_loss(data, left, right):
        estimate = matmul(left, right)
        return sum(
                (data[i][j] - estimate[i][j]) ** 2
                for i in range(len(data)) for j in range(len(data[0]))
        )


def nmf(data, rank=2, iterations=200, seed=22):
        """平方损失 NMF 的乘法更新。"""
        rng = random.Random(seed)
        rows, columns = len(data), len(data[0])
        left = [[rng.random() + 0.2 for _ in range(rank)] for _ in range(rows)]
        right = [[rng.random() + 0.2 for _ in range(columns)] for _ in range(rank)]
        history = [squared_loss(data, left, right)]
        epsilon = 1e-15
        for _ in range(iterations):
                numerator = matmul(data, transpose(right))
                denominator = matmul(matmul(left, right), transpose(right))
                left = [[
                        left[i][k] * numerator[i][k] / max(denominator[i][k], epsilon)
                        for k in range(rank)
                ] for i in range(rows)]
                numerator = matmul(transpose(left), data)
                denominator = matmul(matmul(transpose(left), left), right)
                right = [[
                        right[k][j] * numerator[k][j] / max(denominator[k][j], epsilon)
                        for j in range(columns)
                ] for k in range(rank)]
                history.append(squared_loss(data, left, right))
        return left, right, history


def plsa(counts, topics=2, iterations=100, seed=23):
        """PLSA 的 EM：概率因子与 KL 分解对应。"""
        rng = random.Random(seed)
        words, documents = len(counts), len(counts[0])
        word_given_topic = [normalize([rng.random() + 0.2 for _ in range(words)])
                                                for _ in range(topics)]
        topic_given_document = [normalize([rng.random() + 0.2 for _ in range(topics)])
                                                        for _ in range(documents)]

        def log_likelihood():
                return sum(
                        counts[word][document] * math.log(sum(
                                word_given_topic[topic][word]
                                * topic_given_document[document][topic]
                                for topic in range(topics)
                        ))
                        for word in range(words) for document in range(documents)
                        if counts[word][document]
                )

        history = [log_likelihood()]
        for _ in range(iterations):
                topic_word_counts = [[0.0] * words for _ in range(topics)]
                document_topic_counts = [[0.0] * topics for _ in range(documents)]
                for word in range(words):
                        for document in range(documents):
                                if counts[word][document] == 0:
                                        continue
                                posterior = normalize([
                                        word_given_topic[topic][word]
                                        * topic_given_document[document][topic]
                                        for topic in range(topics)
                                ])
                                for topic in range(topics):
                                        expected = counts[word][document] * posterior[topic]
                                        topic_word_counts[topic][word] += expected
                                        document_topic_counts[document][topic] += expected
                word_given_topic = [normalize(row) for row in topic_word_counts]
                topic_given_document = [normalize(row) for row in document_topic_counts]
                history.append(log_likelihood())
        return word_given_topic, topic_given_document, history


def pagerank(matrix, damping=0.85, tolerance=1e-13):
        """幂迭代求一般 PageRank。"""
        size = len(matrix)
        rank = [1.0 / size] * size
        for iteration in range(1, 100_001):
                new_rank = [
                        damping * sum(matrix[i][j] * rank[j] for j in range(size))
                        + (1.0 - damping) / size
                        for i in range(size)
                ]
                if sum(abs(new_rank[i] - rank[i]) for i in range(size)) < tolerance:
                        return new_rank, iteration
                rank = new_rank
        raise RuntimeError("PageRank 未收敛")


def nondecreasing(values, tolerance=1e-10):
        return all(values[i + 1] >= values[i] - tolerance for i in range(len(values) - 1))


def nonincreasing(values, tolerance=1e-10):
        return all(values[i + 1] <= values[i] + tolerance for i in range(len(values) - 1))


POINTS = [[-3.0, -2.5], [-2.0, -1.8], [-1.2, -1.0],
                  [1.0, 1.1], [2.1, 1.8], [3.0, 2.7]]
labels, centers, kmeans_history = kmeans(POINTS, [POINTS[0], POINTS[-1]])
print("【聚类：k 均值与 GMM】")
print("k-means labels =", labels)
print("k-means centers =", [[round(value, 4) for value in row] for row in centers])
print("k-means objective =", [round(value, 6) for value in kmeans_history])
print("k-means nonincreasing =", nonincreasing(kmeans_history))
weights, means, variances, gmm_history = gmm_em([point[0] for point in POINTS])
print("GMM weights =", [round(value, 6) for value in weights])
print("GMM means =", [round(value, 6) for value in means])
print("GMM variances =", [round(value, 6) for value in variances])
print("GMM log-likelihood checkpoints =", [round(gmm_history[i], 6) for i in [0, 1, 5, 30]])
print("GMM nondecreasing =", nondecreasing(gmm_history))

component, ratio = pca_first_component(POINTS)
print("\n【降维：PCA】")
print("first component =", [round(value, 6) for value in component])
print("explained variance ratio =", round(ratio, 6))

DOCUMENT_MATRIX = [
        [3.0, 2.0, 0.0, 0.0],
        [2.0, 3.0, 0.0, 0.0],
        [0.0, 0.0, 3.0, 2.0],
        [0.0, 0.0, 2.0, 3.0],
]
left, right, nmf_history = nmf(DOCUMENT_MATRIX)
print("\n【话题分析：NMF 与 PLSA】")
print("NMF loss checkpoints =", [round(nmf_history[i], 6) for i in [0, 1, 10, 200]])
print("NMF nonincreasing =", nonincreasing(nmf_history))
phi, theta, plsa_history = plsa(DOCUMENT_MATRIX)
print("PLSA log-likelihood checkpoints =", [round(plsa_history[i], 6) for i in [0, 1, 10, 100]])
print("PLSA nondecreasing =", nondecreasing(plsa_history))
print("PLSA topic-word sums =", [round(sum(row), 12) for row in phi])
print("PLSA document-topic sums =", [round(sum(row), 12) for row in theta])
print("PLSA document mixtures =", [[round(value, 4) for value in row] for row in theta])

GRAPH = [
        [0.0, 0.0, 1.0],
        [0.5, 0.0, 0.0],
        [0.5, 1.0, 0.0],
]
rank, iterations = pagerank(GRAPH)
residual = max(abs(
        rank[i] - (0.85 * sum(GRAPH[i][j] * rank[j] for j in range(3)) + 0.05)
) for i in range(3))
print("\n【图分析：PageRank】")
print("rank =", [round(value, 9) for value in rank], "iterations =", iterations)
print("fixed-point residual =", f"{residual:.3e}")
```

运行输出：

```text
【聚类：k 均值与 GMM】
k-means labels = [0, 0, 0, 1, 1, 1]
k-means centers = [[-2.0667, -1.7667], [2.0333, 1.8667]]
k-means objective = [6.046667, 6.046667]
k-means nonincreasing = True
GMM weights = [0.499946, 0.500054]
GMM means = [-2.066443, 2.032669]
GMM variances = [0.543442, 0.671295]
GMM log-likelihood checkpoints = [-13.184936, -13.159821, -12.371476, -11.150021]
GMM nondecreasing = True

【降维：PCA】
first component = [0.751684, 0.659524]
explained variance ratio = 0.999411

【话题分析：NMF 与 PLSA】
NMF loss checkpoints = [28.832749, 25.917269, 2.000002, 2.0]
NMF nonincreasing = True
PLSA log-likelihood checkpoints = [-29.606034, -27.705735, -13.862944, -13.862944]
PLSA nondecreasing = True
PLSA topic-word sums = [1.0, 1.0]
PLSA document-topic sums = [1.0, 1.0, 1.0, 1.0]
PLSA document mixtures = [[0.0, 1.0], [0.0, 1.0], [1.0, 0.0], [1.0, 0.0]]

【图分析：PageRank】
rank = [0.387789712, 0.214810627, 0.397399661] iterations = 59
fixed-point residual = 1.810e-14
```

代码展示的不是“所有无监督算法都单调优化同一个目标”，而是每类方法有自己的正确性证据：距离目标、似然、方差、重构误差或固定点残差。

---

## 22.4 【补充】如何选择无监督学习方法

### 22.4.1 先问任务，不要先问算法

```text
你需要什么输出？
├─ 样本分组
│  ├─ 硬标签：k 均值、层次聚类
│  └─ 软概率：GMM
├─ 连续低维表示
│  ├─ 线性、重构：PCA
│  └─ 非线性：核 PCA、流形学习、自动编码器【补充】
├─ 文本潜在主题
│  ├─ 快速正交表示：LSA
│  ├─ 非负可解释：NMF
│  ├─ 概率极大似然：PLSA
│  └─ 贝叶斯平滑与新文档：LDA
├─ 图结点重要度：PageRank
└─ 复杂后验积分
         ├─ 精确 E 步可解：EM
         ├─ 速度优先：变分推理
         └─ 不确定性优先：MCMC
```

### 22.4.2 再检查数据与假设

| 检查项 | 问题 | 影响 |
| --- | --- | --- |
| 距离是否有意义 | 特征尺度、类别变量、稀疏高维 | 决定聚类与 PCA 是否合理 |
| 簇几何 | 球状、椭圆、非凸、密度差异 | 选择 $k$ 均值、GMM 或其他方法 |
| 数据类型 | 连续、计数、概率、图 | 决定平方、Poisson/KL、马尔可夫模型 |
| 潜在表示约束 | 正交、非负、概率单纯形 | 决定 LSA、NMF、PLSA/LDA |
| 是否需要不确定性 | 点表示还是后验区间 | 决定代数、变分、MCMC |
| 规模与稀疏性 | $n,p,|E|$ 和内存 | 决定稀疏算法、在线/分布式算法 |
| 新样本推断 | 是否频繁加入新数据 | PLSA folding-in 与 LDA 生成机制不同 |

### 22.4.3 预处理不是附属步骤

- 距离方法通常需要特征缩放；
- PCA 必须中心化，是否标准化取决于量纲含义；
- 文本需定义词表、分词、停用词、计数或 TF-IDF；
- SVD/LSA 可用 TF-IDF，概率话题模型通常以非负计数为输入；
- PageRank 必须明确边方向、边权、悬挂结点和传送向量；
- 缺失值、异常值和重复样本会改变无监督结构。

预处理实际上定义了模型看到的几何与概率事件，因此属于建模假设。

## 22.5 【补充】没有标签时如何评估

### 22.5.1 聚类

**内部指标**：轮廓系数、类内平方和、簇间分离度。这些指标与距离和簇形状假设绑定，例如轮廓系数偏好凸簇。

**稳定性**：重采样、扰动数据或改变初值，比较分组是否一致。可用 adjusted Rand index 比较两次聚类，即使没有真实标签。

**外部/下游评估**：若有少量人工标签或实际任务，检查簇是否改善检索、推荐、分层抽样或异常发现。

训练目标不能跨模型直接比较：$k$ 均值平方和随 $K$ 增大必然不增，GMM 训练似然也通常随成分数增加，因此需要惩罚、验证集或稳定性。

### 22.5.2 降维

- 累计解释方差；
- 重构误差；
- 邻域/距离保持；
- 下游预测、聚类或检索性能；
- 不同样本切分下子空间稳定性。

解释方差高只说明保留了二阶方差信息，不保证保留类别、因果或语义信息。

### 22.5.3 话题模型

- 留出文档困惑度或预测对数似然；
- 话题 coherence（高概率词是否共同出现）；
- 不同随机种子、语料子样本下的话题稳定性；
- 人工检查高概率词与代表文档；
- 下游分类、推荐、探索效果。

困惑度与人类可解释性不等价。模型可能靠常见词提高预测，却产生语义模糊话题。

### 22.5.4 PageRank

- 固定点残差
        $$
        \|R-dMR-(1-d)s\|;
        $$
- 分量和与非负性；
- 对阻尼、传送向量、边扰动的敏感性；
- 与点击、引用、人工质量或下游排序指标比较；
- 检查链接垃圾、闭合社区和数据采集偏差。

### 22.5.5 无监督评估的基本原则

$$
\boxed{
	ext{优化目标验证数值正确性，}
\quad
	ext{外部任务与稳定性验证结构是否有用。}
}
$$

## 22.6 【补充】常见误解

1. **无监督学习没有目标函数。** 它没有标签损失，但有距离、重构、似然、ELBO 或平稳方程。
2. **算法发现的是数据中客观唯一结构。** 结果由表示、距离、先验、$K$ 和初始化共同决定。
3. **训练目标更优就代表语义更好。** 数值目标只度量模型内部准则。
4. **$k$ 均值能处理任意形状簇。** 它偏好欧氏空间中方差相近的球状簇。
5. **软聚类就是贝叶斯不确定性。** GMM 责任度是给定点参数的类别后验，不包含参数后验不确定性。
6. **PCA 是特征选择。** PCA 构造原特征的线性组合；特征选择保留原坐标子集。
7. **PCA 与 LSA 完全相同。** 都可用 SVD，但 PCA 中心化并最大化样本方差，LSA 通常直接分解词文档矩阵。
8. **非负因子就是概率。** NMF 还需归一化，并说明归一化方向，才可作概率解释。
9. **EM、变分、MCMC 都是优化器。** MCMC 的核心目标是抽取目标分布，不是单调寻找最优点。
10. **Gibbs 保证找到全局最优。** 在遍历条件下它渐近采样后验；混合慢时有限链可能困在模式。
11. **变分 EM 保证真实似然每轮上升。** 一般只保证 ELBO 上升；精确后验在变分族内时才退化为普通 EM 等号。
12. **话题编号有固定含义。** 话题、混合成分和聚类标签都存在排列不识别。
13. **PageRank 是普适质量分。** 它是特定随机游走下的拓扑访问概率。
14. **随机种子只影响可忽略小数。** 非凸目标和多峰后验可能产生结构不同的解。
15. **更复杂模型一定更好。** 复杂模型增加表达力，也增加估计方差、计算成本和不可识别性。

## 22.7 【补充】一套完整的无监督建模流程

1. **定义问题**：明确对象、输出、使用方式和错误成本；
2. **审计数据**：尺度、稀疏性、缺失、异常、图方向和采样偏差；
3. **建立基线**：均匀/随机、入度、单簇、简单 PCA 等；
4. **选择假设**：距离、低秩、概率混合、先验或随机游走；
5. **选择算法**：根据闭式解、后验可解性、规模和不确定性需求；
6. **监控数值量**：目标单调性、ELBO、似然、重构误差、固定点残差；
7. **多次运行**：改变初值、随机种子、样本和超参数；
8. **处理不可识别性**：对齐簇/话题标签，使用子空间或预测分布比较；
9. **外部验证**：稳定性、人工解释、下游任务和真实业务指标；
10. **记录边界**：明确模型没表达什么、对哪些分布漂移敏感。

## 22.8 本章知识清单

### 必须掌握的方法地图

| 任务 | 代数路线 | 概率路线 |
| --- | --- | --- |
| 聚类 | 层次聚类、$k$ 均值 | GMM + EM |
| 降维 | PCA + SVD | 概率 PCA【补充】 |
| 话题 | LSA、NMF | PLSA、LDA |
| 图排序 | 幂法/线性方程 | 马尔可夫链平稳分布 |

### 必须掌握的统一关系

1. PCA 与 LSA 共享 SVD，但数据预处理和目标解释不同；
2. LSA、NMF、PLSA 可统一为带不同损失与约束的矩阵分解；
3. 平方损失对应各向同性高斯噪声，KL 对应计数/类别似然；
4. $k$ 均值是硬分配，GMM/PLSA 是软责任度，LDA 进一步对混合比例加先验；
5. EM 用精确后验期望，变分用受限近似，MCMC 用相关样本；
6. 幂法连接主成分方向和 PageRank 主特征向量；
7. 所有非凸方法都要重视初始化、局部解与稳定性；
8. 无监督学习的有效性必须通过模型外证据验证。

### 原书本章习题说明

原书第 22 章没有设置章末习题。本笔记用前面的统一推导、综合代码和方法选择流程代替机械练习，作为第二篇的整体复盘。

## 第 22 章一句话回顾

**无监督学习不是一组互不相干的算法，而是一套从任务选择表示假设、从模型确定学习目标、再用矩阵分解、特征值计算或隐变量推断求解的体系；真正可靠的结果既要优化正确，也要在重采样、外部任务和领域解释中稳定有用。**
