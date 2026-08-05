---
title: "《统计学习方法（第 2 版）》第 17 章：潜在语义分析"
date: 2026-08-01 02:17:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch17-latent-semantic-analysis
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: statistical-learning-methods
series_order: 18
related: [statistical-learning-methods-ch16-principal-component-analysis, statistical-learning-methods-ch18-probabilistic-latent-semantic-analysis]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "由 TF-IDF 单词文本矩阵进入话题空间，比较 SVD-LSA 的最优低秩近似与 NMF-LSA 的非负可解释分解及乘法更新。"
toc: true
math: true
---

> 凡标注 **【补充】** 的内容为书外补充（推导、辨析、数值实验、工程实践等），请与原书内容区分。对扫描页恢复的数据会明确说明来源。

---

## 0. 本章解决什么问题

### 0.1 从“词面相同”到“语义相近”

> 潜在语义分析（latent semantic analysis，LSA）是一种无监督学习方法，主要用于文本的话题分析，其特点是通过矩阵分解发现文本与单词之间基于话题的语义关系。

传统向量空间模型把每个词当成一个独立坐标。它高效，但遇到自然语言的两个基本现象就会失真：

- **多词一义（synonymy）**：`airplane` 与 `aircraft` 词面不同、语义相近；
- **一词多义（polysemy）**：`apple` 既可指水果，也可指公司。

词袋模型只看词是否重合：同义词导致真正相似的文档被判得不相似；多义词导致内容不同的文档因共享一个词而被判得相似。

LSA 的出发点是：**词背后存在更少量的潜在话题，文档应在话题空间比较，而不只在词空间比较。**

$$
\boxed{
\text{单词-文本矩阵 }X
\xrightarrow{\text{低秩矩阵分解}}
\text{单词-话题矩阵 }T
\times
\text{话题-文本矩阵 }Y
}
$$

### 0.2 为什么矩阵分解能发现话题

若一批词经常在同一批文档中共同出现，它们在单词-文本矩阵中具有相似的行模式；若一批文档使用相似的词，它们具有相似的列模式。低秩分解用少数共同模式近似这些行和列：

$$
X_{m\times n}\approx T_{m\times k}Y_{k\times n},
\qquad k\ll\min(m,n).
$$

- $T$ 的每列表示一种词共现模式，可解释为话题；
- $Y$ 的每列表示一个文档在各话题上的坐标。

这正是第 13 章“同时发现横向与纵向结构”的矩阵分解主线，也是第 15 章最优低秩近似的直接应用。

### 0.3 本章的两条技术路线

| 路线 | 分解 | 约束 | 优势 | 局限 |
| --- | --- | --- | --- | --- |
| SVD-LSA | $X\approx U_k\Sigma_kV_k^\top$ | 正交 | 闭式全局最优低秩近似 | 含负值，话题不易解释 |
| NMF-LSA | $X\approx WH$ | $W,H\ge0$ | 加法式“部件”解释直观 | 非凸、依赖初值、仅局部最优 |

> LSA 由 Deerwester 等于 1990 年提出，最初用于文本信息检索，也称潜在语义索引（LSI）。NMF 在 Lee 与 Seung 1999 年论文后得到广泛应用。

### 0.4 全章结构

```text
17.1 为什么需要话题空间
 ├─ 17.1.1 单词向量空间：VSM、TF-IDF、余弦、同义/多义局限
 └─ 17.1.2 话题向量空间：X≈TY，文档从 m 维词空间压到 k 维话题空间

17.2 SVD 路线
 ├─ 17.2.1 X≈U_kΣ_kV_k^T，U_k 是话题空间，Σ_kV_k^T 是文档表示
 └─ 17.2.2 11×9 数值例子

17.3 NMF 路线
 ├─ 定义 X≈WH，W/H 的话题含义
 ├─ 平方损失与广义 KL 散度
 ├─ 两组乘法更新定理
 └─ 算法 17.1 与梯度下降解释
```

---

## 17.1 单词向量空间与话题向量空间

### 17.1.1 单词向量空间

#### 向量空间模型

给定文本集合

$$
D=\{d_1,d_2,\ldots,d_n\}
$$

和词汇集合

$$
W=\{w_1,w_2,\ldots,w_m\},
$$

定义单词-文本矩阵

$$
X=[x_{ij}]_{m\times n}
=\begin{bmatrix}
 x_{11}&x_{12}&\cdots&x_{1n}\\
 x_{21}&x_{22}&\cdots&x_{2n}\\
 \vdots&\vdots&&\vdots\\
 x_{m1}&x_{m2}&\cdots&x_{mn}
\end{bmatrix}.
\tag{17.1}
$$

$x_{ij}$ 是词 $w_i$ 在文档 $d_j$ 中的频数或权值。矩阵通常高度稀疏，因为词汇量很大，而单篇文档只出现少量词。

第 $j$ 列

$$
x_j=(x_{1j},x_{2j},\ldots,x_{mj})^\top
\tag{17.3}
$$

就是文档 $d_j$ 的词向量，故

$$
X=[x_1\;x_2\;\cdots\;x_n].
$$

**基本假设**：文档中所有词的出现情况能够表示语义；向量空间中的内积或余弦能够表示语义相似度。

#### TF-IDF（式 17.2）

原始频数会高估在所有文档中都常见的词。原书采用

$$
\operatorname{TFIDF}_{ij}
=\frac{\operatorname{tf}_{ij}}{\operatorname{tf}_{\cdot j}}
\log\frac{\operatorname{df}}{\operatorname{df}_i},
\quad i=1,\ldots,m,
\quad j=1,\ldots,n.
\tag{17.2}
$$

其中：

| 符号 | 含义 |
| --- | --- |
| $\operatorname{tf}_{ij}$ | 词 $w_i$ 在文档 $d_j$ 中的出现次数 |
| $\operatorname{tf}_{\cdot j}=\sum_i\operatorname{tf}_{ij}$ | 文档 $d_j$ 的总词频 |
| $\operatorname{df}_i$ | 包含 $w_i$ 的文档数 |
| $\operatorname{df}=n$ | 文档总数 |

解释：

- TF 高：该词在当前文档中重要；
- DF 低：该词能区分文档；
- 二者相乘得到综合权重。

**边界情况**【补充】：若某词出现在全部文档，$\log(n/n)=0$，权重变为 0。17.2.2 的 `investing` 出现在 9 篇文档中，代码确认其整行 TF-IDF 都为 0。

实际系统常用平滑 IDF：

$$
\log\frac{n+1}{\operatorname{df}_i+1}+1,
$$

避免零权重与未登录词问题；这是工程变体，不是原书式 (17.2)。

#### 文档相似度（式 17.4）

原书排版表示标准化内积，即余弦相似度：

$$
\operatorname{sim}(d_i,d_j)
=\frac{x_i^\top x_j}{\lVert x_i\rVert\lVert x_j\rVert}.
\tag{17.4}
$$

- 取值通常在 $[0,1]$，因为词频/TF-IDF 非负；
- 不受文档整体长度缩放影响；
- 共同非零词越多、权重模式越一致，余弦越大。

**为什么不用裸内积**【补充】：同样词频比例下，长文档向量范数大，裸内积会偏爱长文档；余弦归一化后只比较方向。

#### 信息检索

查询可视作伪文档：把查询与候选文档映射成词向量，按余弦排序。稀疏向量只需遍历共同非零维度，计算高效，因此 VSM 至今仍是检索基本组件。

#### 局限：同义词与多义词

扫描图 17.1 恢复的矩阵为：

| 词 | $d_1$ | $d_2$ | $d_3$ | $d_4$ |
| --- | ---: | ---: | ---: | ---: |
| airplane | 2 | 0 | 0 | 0 |
| aircraft | 0 | 2 | 0 | 0 |
| computer | 0 | 0 | 1 | 0 |
| apple | 0 | 0 | 2 | 3 |
| fruit | 0 | 0 | 0 | 1 |
| produce | 1 | 2 | 2 | 1 |

原词空间余弦：

$$
\cos(d_1,d_2)=0.316228,
\qquad
\cos(d_3,d_4)=0.804030.
$$

- $d_1,d_2$ 都谈飞行器，但 `airplane`、`aircraft` 是不同维度，相似度低；
- $d_3,d_4$ 语义不同，却共享多义词 `apple`，相似度高。

$$
\boxed{
\text{VSM 只能识别“相同词”，无法直接识别“相同语义”}
}
$$

**注意**：语义不是由一两个词决定，而由全部词共同出现的模式决定；这正给低秩共现分析提供了可能。

### 17.1.2 话题向量空间

#### 话题的直觉

原书不对“话题”作严格定义，仅指文本讨论的内容或主题。一个话题可由一组语义相关词表示；一个文档通常包含多个话题。

同义词可以因相似共现模式落到同一话题，多义词则可能通过多个话题方向被拆分解释。这里的“可以”是建模动机，不是对任意数据的必然保证；需要足够多的文档和共现证据。

#### 1. 话题向量空间

假设有 $k$ 个话题，每个话题由 $m$ 维词权重向量表示：

$$
t_l=(t_{1l},t_{2l},\ldots,t_{ml})^\top,
\quad l=1,\ldots,k.
\tag{17.6}
$$

$t_{il}$ 越大，词 $w_i$ 对话题 $t_l$ 越重要。话题向量组成单词-话题矩阵

$$
T=[t_1\;t_2\;\cdots\;t_k]
=\begin{bmatrix}
 t_{11}&\cdots&t_{1k}\\
 \vdots&&\vdots\\
 t_{m1}&\cdots&t_{mk}
\end{bmatrix}
\in\mathbb R^{m\times k}.
\tag{17.7}
$$

其列空间是词空间 $\mathbb R^m$ 中的 $k$ 维话题子空间。

#### 2. 文本在话题空间的表示

文档 $d_j$ 的话题坐标为

$$
y_j=(y_{1j},y_{2j},\ldots,y_{kj})^\top\in\mathbb R^k,
\tag{17.8}
$$

$y_{lj}$ 表示话题 $l$ 在文档 $j$ 中的权重。把所有文档坐标并列：

$$
Y=[y_1\;y_2\;\cdots\;y_n]
=\begin{bmatrix}
 y_{11}&\cdots&y_{1n}\\
 \vdots&&\vdots\\
 y_{k1}&\cdots&y_{kn}
\end{bmatrix}
\in\mathbb R^{k\times n}.
\tag{17.9}
$$

#### 3. 从词空间到话题空间

每个文档词向量由话题向量线性组合近似：

$$
x_j\approx y_{1j}t_1+y_{2j}t_2+\cdots+y_{kj}t_k,
\quad j=1,\ldots,n.
\tag{17.10}
$$

矩阵形式：

$$
X\approx TY.
\tag{17.11}
$$

这就是 LSA 的模型。

| 矩阵 | 形状 | 含义 |
| --- | ---: | --- |
| $X$ | $m\times n$ | 词-文档数据 |
| $T$ | $m\times k$ | 词-话题基，列是话题方向 |
| $Y$ | $k\times n$ | 话题-文档坐标，列是文档表示 |

原空间相似度用 $x_i,x_j$ 比较；话题空间相似度改用 $y_i,y_j$ 比较。维数从 $m$ 降到 $k$，同时利用全局共现平滑稀疏词面差异。

**【易混淆】式 (17.11) 不是唯一分解**：对任意可逆 $Q\in\mathbb R^{k\times k}$，

$$
TY=(TQ)(Q^{-1}Y).
$$

必须增加正交、非负、概率或稀疏等约束，才能决定具体分解。SVD 选择正交约束；NMF 选择非负约束。

---

## 17.2 潜在语义分析算法

### 17.2.1 矩阵奇异值分解算法

#### 1. 输入矩阵

再次写出单词-文本矩阵：

$$
X=[x_{ij}]_{m\times n}.
\tag{17.12}
$$

实际可使用频数或 TF-IDF。频数保留原始共现强度；TF-IDF 抑制高频常见词，通常更适合检索。

#### 2. 截断奇异值分解

确定话题数 $k$，对 $X$ 作秩 $k$ 截断 SVD：

$$
X\approx U_k\Sigma_kV_k^\top.
\tag{17.13}
$$

其中：

- $U_k\in\mathbb R^{m\times k}$：前 $k$ 个左奇异向量，列正交；
- $\Sigma_k\in\mathbb R^{k\times k}$：前 $k$ 个奇异值；
- $V_k\in\mathbb R^{n\times k}$：前 $k$ 个右奇异向量，列正交。

依第 15 章定理 15.3，这个分解在所有秩不超过 $k$ 的矩阵中使

$$
\lVert X-U_k\Sigma_kV_k^\top\rVert_F
$$

最小。最小误差为

$$
\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}.
$$

#### 3. 话题向量空间

原书把 $U_k$ 的每列 $u_l$ 解释为一个话题向量，$U_k$ 的列空间解释为话题空间。

**适用边界**：SVD 话题向量可正可负、两列正交。自然语言话题并不必然正交，负权重也不是词概率；因此它是“潜在方向”的代数解释，不是概率话题。

#### 4. 文本话题表示

把式 (17.13) 写为

$$
X\approx U_k(\Sigma_kV_k^\top).
\tag{17.16}
$$

于是对应式 (17.11)：

$$
T=U_k,
\qquad
Y=\Sigma_kV_k^\top.
$$

对第 $j$ 列：

$$
x_j\approx U_k(\Sigma_kV_k^\top)_j
=\sum_{l=1}^{k}\sigma_l v_{jl}u_l.
\tag{17.15}
$$

因此文档 $j$ 的话题坐标是

$$
y_j=(\sigma_1v_{j1},\ldots,\sigma_kv_{jk})^\top.
$$

**为什么不是直接用 $v_j$**：$V_k$ 只给方向，$\Sigma_k$ 把各话题按能量缩放；文档重构系数必须是 $\Sigma_kV_k^\top$。

#### 新文档如何投影【补充】

对训练语料之外的新词向量 $x_{\text{new}}$，若 $U_k$ 列正交，则最小二乘话题坐标为

$$
y_{\text{new}}=U_k^\top x_{\text{new}}.
$$

若要得到与右奇异向量同尺度的坐标，可再乘 $\Sigma_k^{-1}$。必须使用与训练一致的词表和 TF-IDF 变换。

### 17.2.2 原书 11×9 例子

扫描页恢复的词-文档矩阵如下（行顺序与原书一致）：

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

取 $k=3$，代码得到前三奇异值

$$
3.909418,
\quad2.609119,
\quad1.996828,
$$

与原书舍入值 $3.91,2.61,2.00$ 一致。

原书给出的 $U_3$ 与代码值仅可能差列符号，例如代码第一列均为正，表示所有词共同的总体使用方向；第二、三列有正有负，用来对比不同共现群组。

文本话题坐标 $Y=\Sigma_3V_3^\top$ 的第一行约为

$$
(1.383,0.870,1.320,1.016,0.863,1.920,1.109,1.121,1.709),
$$

与原书舍入表 $(1.37,0.86,1.33,1.02,0.86,1.92,1.09,1.13,1.72)$ 接近。

前三个方向保留能量比例

$$
\frac{\sigma_1^2+\sigma_2^2+\sigma_3^2}{\sum_i\sigma_i^2}
=0.790254,
$$

相对弗罗贝尼乌斯误差约 $0.45798$。这说明 $k=3$ 是较强压缩，不是几乎无损。

**TF-IDF 观察**：`investing` 出现在全部 9 个标题中，原书式 (17.2) 的 IDF 为 0；`book` 只出现在 T3、T4，具有非零区分权重。这说明直接频数 SVD 与 TF-IDF SVD 可能得到不同话题。

### 17.2.3 话题数 $k$ 的选择【补充】

| 方法 | 做法 | 局限 |
| --- | --- | --- |
| 奇异值能量 | 选累计 $\sum_{i\le k}\sigma_i^2/\sum_i\sigma_i^2$ 达阈值 | 重构好不等于语义好 |
| 检索验证集 | 选择 MAP/NDCG 最优 $k$ | 需要相关性标注 |
| 聚类稳定性 | 多次采样看话题/文档聚类是否稳定 | 计算贵 |
| 可解释性 | 人工检查关键词与文档 | 主观 |

$k$ 太小会把不同话题混在一起；太大则接近原词空间，失去平滑与压缩作用。

图 17.1 实验清楚显示：

| $k$ | $\cos(d_1,d_2)$ | $\cos(d_3,d_4)$ | 重构误差 |
| ---: | ---: | ---: | ---: |
| 原词空间 / 4 | 0.3162 | 0.8040 | 0 |
| 1 | 1.0000 | 1.0000 | 3.5996 |
| 2 | 1.0000 | 0.9269 | 2.3202 |
| 3 | 0.3116 | 0.9269 | 1.1762 |

过小 $k$ 把所有文档压成近乎同向；$k=3$ 也没有修复同义词，且放大了多义词假相似。LSA 依赖大规模、丰富的共现统计，不能保证在这个极小矩阵上改善语义。

---

## 17.3 非负矩阵分解算法

SVD 的正交基含正负权重：一个话题可以通过“正向词减去反向词”表达，代数上自然，但不符合“文档由若干非负话题相加”的直觉。

> 非负矩阵分解也可用于话题分析：对非负单词-文本矩阵分解，将左矩阵作为话题空间，右矩阵作为文本表示。

### 17.3.1 非负矩阵分解

若矩阵所有元素非负，记作 $X\ge0$。给定 $X\in\mathbb R_+^{m\times n}$，寻找

$$
W\in\mathbb R_+^{m\times k},
\qquad
H\in\mathbb R_+^{k\times n},
$$

使

$$
X\approx WH.
\qquad\mathrm{(17.17)}
$$

通常 $k<\min(m,n)$，所以是压缩。

对第 $j$ 列：

$$
x_j\approx Wh_j
=\begin{bmatrix}w_1&w_2&\cdots&w_k\end{bmatrix}
\begin{bmatrix}h_{1j}\\h_{2j}\\\vdots\\h_{kj}\end{bmatrix}
=\sum_{l=1}^{k}h_{lj}w_l.
\qquad\mathrm{(17.18)}
$$

- $W=[w_1,\ldots,w_k]$ 是**基矩阵**；
- $H=[h_1,\ldots,h_n]$ 是**系数矩阵**；
- 非负约束意味着文档由话题做**加法叠加**，没有相互抵消。

#### 为什么 NMF 更易解释

| SVD | NMF |
| --- | --- |
| 话题向量可正可负 | 话题词权重非负 |
| 文档坐标可正可负 | 文档话题权重非负 |
| 正交全局方向 | 部件的加法组合 |
| 截断解全局最优且闭式 | 非凸，仅局部最优 |

**非负不等于概率**：$W,H$ 的列/行不自动和为 1。原书称其为“伪概率分布”，因为非负且可归一化解释，但未经归一化不是严格概率。

#### 分解的尺度与排列不唯一【补充】

对任意正对角矩阵 $D$：

$$
WH=(WD)(D^{-1}H).
$$

所以可任意放大 $W$ 的一列并缩小 $H$ 对应行。话题还可任意置换。算法中归一化 $W$ 的列用于固定尺度，但不会消除排列不唯一。

### 17.3.2 基于 NMF 的潜在语义模型

对非负单词-文本矩阵 $X$：

$$
X\approx WH,
\quad W,H\ge0.
\qquad\mathrm{(17.19)}
$$

- $W$ 的 $k$ 列是话题向量；
- $H$ 的 $n$ 列是各文档话题表示。

与式 (17.11) 对应：$T=W,Y=H$。

### 17.3.3 形式化：两类损失

#### 1. 平方损失

对同形非负矩阵 $A=[a_{ij}]$、$B=[b_{ij}]$：

$$
\lVert A-B\rVert_F^2
=\sum_{i,j}(a_{ij}-b_{ij})^2.
\qquad\mathrm{(17.20)}
$$

下界为 0，当且仅当 $A=B$。

NMF 问题：

$$
\min_{W,H}\lVert X-WH\rVert_F^2
\quad\text{s.t.}\quad W,H\ge0.
\qquad\mathrm{(17.22)}
$$

适合近似高斯加性噪声的连续数据。

#### 2. 散度损失

$$
D(A\Vert B)
=\sum_{i,j}\left(a_{ij}\log\frac{a_{ij}}{b_{ij}}-a_{ij}+b_{ij}\right).
\qquad\mathrm{(17.21)}
$$

约定 $0\log(0/b)=0$，且若 $a>0,b=0$ 则散度为 $+\infty$。

它也非负，且仅当 $A=B$ 时为 0；一般不对称：

$$
D(A\Vert B)\ne D(B\Vert A).
$$

若 $\sum a_{ij}=\sum b_{ij}=1$，则 $-a+b$ 项求和抵消，退化为 KL 散度。

对应 NMF：

$$
\min_{W,H}D(X\Vert WH)
\quad\text{s.t.}\quad W,H\ge0.
\qquad\mathrm{(17.23)}
$$

广义 KL 散度与 Poisson 计数似然密切相关，常适合词频数据【补充】：若 $x_{ij}\sim\operatorname{Poisson}((WH)_{ij})$，去掉与参数无关项后，负对数似然就是式 (17.21)。

### 17.3.4 乘法更新算法

目标关于 $W,H$ **联合非凸**（$WH$ 是双线性），但固定一个时关于另一个是凸二次问题。因此采用交替更新，只保证局部稳定点。

#### 定理 17.1（平方损失乘法更新）

平方损失对以下更新非增：

$$
H_{lj}\leftarrow H_{lj}
\frac{(W^\top X)_{lj}}{(W^\top WH)_{lj}},
\qquad\mathrm{(17.24)}
$$

$$
W_{il}\leftarrow W_{il}
\frac{(XH^\top)_{il}}{(WHH^\top)_{il}}.
\qquad\mathrm{(17.25)}
$$

仅在稳定点更新不变。原书不证明单调性定理，引用 Lee 与 Seung 的辅助函数证明。

#### 定理 17.2（散度乘法更新）

$$
H_{lj}\leftarrow H_{lj}
\frac{\sum_i W_{il}X_{ij}/(WH)_{ij}}{\sum_iW_{il}},
\qquad\mathrm{(17.26)}
$$

$$
W_{il}\leftarrow W_{il}
\frac{\sum_jH_{lj}X_{ij}/(WH)_{ij}}{\sum_jH_{lj}}.
\qquad\mathrm{(17.27)}
$$

散度同样非增，仅在稳定点不变。

#### 平方损失更新的梯度推导

为方便令

$$
J(W,H)=\frac12\lVert X-WH\rVert_F^2
=\frac12\sum_{i,j}[X_{ij}-(WH)_{ij}]^2.
$$

对 $W_{il}$：

$$
\frac{\partial(WH)_{ij}}{\partial W_{il}}=H_{lj}.
$$

链式法则：

$$
\begin{aligned}
\frac{\partial J}{\partial W_{il}}
&=-\sum_j[X_{ij}-(WH)_{ij}]H_{lj}\\
&=-(XH^\top)_{il}+(WHH^\top)_{il}.
\end{aligned}
\qquad\mathrm{(17.28)}
$$

矩阵形式：

$$
\nabla_WJ=WHH^\top-XH^\top.
$$

同理

$$
\nabla_HJ=W^\top WH-W^\top X.
\qquad\mathrm{(17.29)}
$$

普通梯度下降：

$$
W_{il}\leftarrow W_{il}+\lambda_{il}
[(XH^\top)_{il}-(WHH^\top)_{il}],
\qquad\mathrm{(17.30)}
$$

$$
H_{lj}\leftarrow H_{lj}+\mu_{lj}
[(W^\top X)_{lj}-(W^\top WH)_{lj}].
\qquad\mathrm{(17.31)}
$$

选逐元素步长

$$
\lambda_{il}=\frac{W_{il}}{(WHH^\top)_{il}},
\qquad
\mu_{lj}=\frac{H_{lj}}{(W^\top WH)_{lj}},
\qquad\mathrm{(17.32)}
$$

代入式 (17.30)：

$$
\begin{aligned}
W_{il}^{\text{new}}
&=W_{il}+\frac{W_{il}}{(WHH^\top)_{il}}
[(XH^\top)_{il}-(WHH^\top)_{il}]\\
&=W_{il}\frac{(XH^\top)_{il}}{(WHH^\top)_{il}},
\end{aligned}
$$

得到

$$
W_{il}\leftarrow W_{il}
\frac{(XH^\top)_{il}}{(WHH^\top)_{il}}.
\qquad\mathrm{(17.33)}
$$

同理

$$
H_{lj}\leftarrow H_{lj}
\frac{(W^\top X)_{lj}}{(W^\top WH)_{lj}}.
\qquad\mathrm{(17.34)}
$$

这说明乘法更新可看作具有特殊自适应步长的梯度下降。

#### 为什么保持非负

若 $X,W,H\ge0$，则分子、分母均非负；正数乘非负比值仍非负。因此只要初始化非负，所有迭代保持非负。

**零锁定问题【补充】**：若某元素初始化为 0，乘法更新后永远为 0，即使最优解应非零也无法恢复。因此通常严格正随机初始化，并在分母加小量 $\varepsilon$。

#### 算法 17.1

**输入**：$X\ge0$、话题数 $k$、最大迭代次数 $t$。

1. 初始化 $W\ge0$，每列归一化；$H>0$；
2. 对每轮：
	- 按式 (17.33) 更新 $W$；
	- 按式 (17.34) 更新 $H$；
3. 输出 $W,H$。

**归一化细节【补充】**：若把 $W$ 第 $l$ 列除以 $c_l$，应把 $H$ 第 $l$ 行乘 $c_l$，才能保持 $WH$ 不变。原书说每轮归一化 $W$ 的列，但算法条目未显式写出补偿；实现时需要处理。

#### 收敛与停止

定理只保证损失非增，不保证：

- 收敛到全局最优；
- 分解唯一；
- 固定轮数足够。

实践可在相对损失变化小于阈值时停止，并多次随机初始化取最低损失。

代码验证平方损失从 $13.4390\to1.7336\to1.5440\to1.543964$ 单调下降；散度从 $11.1605\to1.7001\to1.656871$ 单调下降，且 $W,H$ 最小元素始终非负。

---

## 17.4 【补充】LSA 与 NMF 的适用边界

### 17.4.1 两种方法的本质差异

| 维度 | SVD-LSA | NMF-LSA |
| --- | --- | --- |
| 目标 | 弗罗贝尼乌斯最优秩 $k$ 近似 | 平方或散度损失下非负分解 |
| 解法 | 截断 SVD，闭式/数值线代 | 迭代乘法更新 |
| 全局最优 | 是（平方损失、无非负约束） | 否 |
| 基向量 | 正交，可负 | 非负，通常不正交 |
| 文档坐标 | 可负 | 非负 |
| 解释 | 全局潜在轴 | 加法部件/伪概率 |
| 唯一性 | 奇异值唯一；向量有符号/重根自由度 | 尺度、排列和局部解均不唯一 |

### 17.4.2 LSA 不能保证解决多义与同义

LSA 假设“相似语义产生相似共现模式”。若语料太小、同义词从不与共同上下文共现，矩阵分解无从知道两词相关。多义词的不同意义若上下文不足，也可能仍被混在一个方向中。

图 17.1 的实验就是反例：$k=3$ 后同义文档余弦没有提高，多义文档假相似反而增大。因此应把原书描述理解为**潜在能力与建模动机**，不是逐数据集保证。

### 17.4.3 与概率话题模型的关系

| LSA/NMF | 第 18 章 PLSA / 第 20 章 LDA |
| --- | --- |
| 矩阵近似模型 | 概率生成模型 |
| 话题权重未必归一化 | 词-话题、话题-文档是概率分布 |
| SVD 可负；NMF 非负 | 概率恒非负 |
| 优化重构误差/散度 | 最大化数据似然/后验 |
| 不直接表达不确定性 | 可计算隐话题后验 |

NMF 的 KL 散度与 Poisson 似然使它成为从代数分解走向概率模型的桥梁。

### 17.4.4 常见误解

1. **话题向量就是单词概率分布。** SVD 话题含负值；NMF 也需归一化后才是伪概率。
2. **$V_k$ 的行就是文档坐标。** 原书采用 $Y=\Sigma_kV_k^\top$，必须包含奇异值缩放。
3. **SVD 的负值表示“负概率”。** 它不是概率，而是正交坐标中的方向与对比关系。
4. **NMF 解唯一。** 存在尺度、排列、局部最优等多重不唯一性。
5. **损失单调下降就达到全局最优。** 乘法更新仅保证非增和稳定点。
6. **所有零词频都应在低秩近似后仍为零。** 低秩平滑会在未观察位置产生非零预测。
7. **截断秩越大语义越好。** $k$ 太大趋近原词空间，噪声和词面局限重新出现。
8. **TF-IDF 总优于词频。** 它改善常见词权重，但短文本、领域词或下游目标不同，需验证。
9. **余弦高就是语义相同。** 它只反映选定表示空间中的方向接近。
10. **NMF 乘法更新是最快算法。** 它实现简单但通常较慢；坐标下降、HALS、拟牛顿等可更快。

---

## 17.5 可运行代码：SVD-LSA、TF-IDF 与两种 NMF

下面只使用 Python 标准库，完整实现：

- 对称 Jacobi 特征分解与截断 SVD；
- 图 17.1 在各个 $k$ 下的余弦与重构误差；
- 17.2.2 的 $11\times9$ 数值例子；
- 原书式 (17.2) 的 TF-IDF；
- 平方损失和散度损失的 NMF 乘法更新。

**适用边界【补充】**：Jacobi 实现用于展示公式并复现本章小矩阵。真实大规模稀疏文本应使用成熟线性代数库的稀疏截断 SVD 和优化过的 NMF，避免显式形成稠密 $X^\top X$。

```python
"""第 17 章：潜在语义分析与非负矩阵分解，纯 Python。"""
import math
import random


def transpose(A): return [list(r) for r in zip(*A)]
def matmul(A,B): return [[sum(A[i][k]*B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]
def fnorm(A): return math.sqrt(sum(x*x for r in A for x in r))
def error(A,B): return fnorm([[a-b for a,b in zip(x,y)] for x,y in zip(A,B)])
def cosine(x,y):
	d=math.sqrt(sum(a*a for a in x)*sum(b*b for b in y))
	return sum(a*b for a,b in zip(x,y))/d if d else 0.0


def jacobi(A,tol=1e-14):
	"""对称矩阵特征分解。"""
	n=len(A); a=[r[:] for r in A]; V=[[float(i==j) for j in range(n)] for i in range(n)]
	for _ in range(200000):
		_,p,q=max((abs(a[i][j]),i,j) for i in range(n) for j in range(i+1,n))
		if abs(a[p][q])<tol: break
		z=(a[q][q]-a[p][p])/(2*a[p][q]); t=math.copysign(1,z)/(abs(z)+math.sqrt(z*z+1)); c=1/math.sqrt(1+t*t); s=t*c
		for k in range(n): x,y=a[k][p],a[k][q]; a[k][p],a[k][q]=c*x-s*y,s*x+c*y
		for k in range(n): x,y=a[p][k],a[q][k]; a[p][k],a[q][k]=c*x-s*y,s*x+c*y
		for k in range(n): x,y=V[k][p],V[k][q]; V[k][p],V[k][q]=c*x-s*y,s*x+c*y
	order=sorted(range(n),key=lambda j:-a[j][j])
	return [max(a[j][j],0) for j in order],[[V[i][j] for j in order] for i in range(n)]


def svd_lsa(X,k):
	"""式(17.13)/(17.16)：返回 U_k、Y=Sigma_k V_k^T、全部奇异值。"""
	m,n=len(X),len(X[0]); eig,V=jacobi(matmul(transpose(X),X)); sigma=[math.sqrt(x) for x in eig]
	U=[]
	for i in range(m):
		U.append([sum(X[i][j]*V[j][l] for j in range(n))/sigma[l] for l in range(k)])
	Y=[[sigma[l]*V[j][l] for j in range(n)] for l in range(k)]
	return U,Y,sigma


def square_loss(X,W,H):
	return error(X,matmul(W,H))**2


def divergence(X,W,H,eps=1e-12):
	WH=matmul(W,H); total=0.0
	for i in range(len(X)):
		for j in range(len(X[0])):
			a,b=X[i][j],max(WH[i][j],eps)
			total += a*math.log(a/b)-a+b if a>0 else b
	return total


def tfidf(C):
	"""原书式 (17.2)，输入为词频矩阵。"""
	m,n=len(C),len(C[0]); document_frequency=[sum(C[i][j]>0 for j in range(n)) for i in range(m)]
	return [[C[i][j]/max(sum(C[t][j] for t in range(m)),1)*math.log(n/document_frequency[i])
			 if document_frequency[i] else 0.0 for j in range(n)] for i in range(m)]


def nmf(X,k,iterations=500,seed=0,kind='square'):
	"""式(17.24)~(17.27)/(17.33)~(17.34) 的乘法更新。"""
	m,n=len(X),len(X[0]); rng=random.Random(seed); eps=1e-12
	W=[[rng.random()+0.2 for _ in range(k)] for _ in range(m)]
	H=[[rng.random()+0.2 for _ in range(n)] for _ in range(k)]
	history=[]
	for _ in range(iterations):
		if kind=='square':
			XHt=matmul(X,transpose(H)); WHHt=matmul(matmul(W,H),transpose(H))
			W=[[W[i][l]*XHt[i][l]/max(WHHt[i][l],eps) for l in range(k)] for i in range(m)]
			WtX=matmul(transpose(W),X); WtWH=matmul(matmul(transpose(W),W),H)
			H=[[H[l][j]*WtX[l][j]/max(WtWH[l][j],eps) for j in range(n)] for l in range(k)]
			history.append(square_loss(X,W,H))
		else:
			WH=matmul(W,H)
			for l in range(k):
				den=sum(W[i][l] for i in range(m))
				for j in range(n):
					H[l][j]*=sum(W[i][l]*X[i][j]/max(WH[i][j],eps) for i in range(m))/max(den,eps)
			WH=matmul(W,H)
			for i in range(m):
				for l in range(k):
					W[i][l]*=sum(H[l][j]*X[i][j]/max(WH[i][j],eps) for j in range(n))/max(sum(H[l]),eps)
			history.append(divergence(X,W,H))
	return W,H,history


def show(A,d=3):
	for r in A: print('  ['+' '.join(f'{x: .{d}f}' for x in r)+']')


print('【图 17.1 / 习题 17.1】')
X=[[2,0,0,0],[0,2,0,0],[0,0,1,0],[0,0,2,3],[0,0,0,1],[1,2,2,1]]
print('word cosine d1,d2 =',round(cosine([r[0] for r in X],[r[1] for r in X]),6))
print('word cosine d3,d4 =',round(cosine([r[2] for r in X],[r[3] for r in X]),6))
for k in range(1,5):
	U,Y,s=svd_lsa(X,k)
	print(f'k={k}: cos12={cosine([r[0] for r in Y],[r[1] for r in Y]):.6f}, '
		  f'cos34={cosine([r[2] for r in Y],[r[3] for r in Y]):.6f}, '
		  f'error={error(X,matmul(U,Y)):.6f}')

print('\n【17.2.2 原书 11x9 例子】')
X2=[[0,0,1,1,0,0,0,0,0],[0,0,0,0,0,1,0,0,1],[0,1,0,0,0,0,0,1,0],
	[0,0,0,0,0,0,1,0,1],[1,0,0,0,0,1,0,0,0],[1,1,1,1,1,1,1,1,1],
	[1,0,1,0,0,0,0,0,0],[0,0,0,0,0,0,1,0,1],[0,0,0,0,0,2,0,0,1],
	[1,0,1,0,0,0,0,1,0],[0,0,0,1,1,0,0,0,0]]
U3,Y3,s=svd_lsa(X2,3)
print('first 3 singular values =',[round(x,6) for x in s[:3]])
print('energy ratio =',round(sum(x*x for x in s[:3])/sum(x*x for x in s),6))
print('relative error =',round(error(X2,matmul(U3,Y3))/fnorm(X2),6))
print('first topic document coordinates =',[round(x,3) for x in Y3[0]])
X2_tfidf=tfidf(X2)
print('tfidf investing row =',[round(x,4) for x in X2_tfidf[5]])
print('tfidf book row =',[round(x,4) for x in X2_tfidf[0]])

print('\n【NMF 平方损失】')
W,H,h=nmf(X,3,800,7,'square')
print('loss =',[round(h[i],6) for i in [0,9,99,799]])
print('nonincreasing =',all(h[i+1]<=h[i]+1e-10 for i in range(len(h)-1)))
print('W =');show(W);print('H =');show(H)

print('\n【习题 17.2：散度损失】')
W,H,h=nmf(X,3,800,7,'kl')
print('divergence =',[round(h[i],6) for i in [0,9,99,799]])
print('nonincreasing =',all(h[i+1]<=h[i]+1e-10 for i in range(len(h)-1)))
print('minimum factor entry =',min(x for r in W+H for x in r))
```

运行输出：

```text
【图 17.1 / 习题 17.1】
word cosine d1,d2 = 0.316228
word cosine d3,d4 = 0.80403
k=1: cos12=1.000000, cos34=1.000000, error=3.599552
k=2: cos12=1.000000, cos34=0.926924, error=2.320228
k=3: cos12=0.311642, cos34=0.926924, error=1.176204
k=4: cos12=0.316228, cos34=0.804030, error=0.000000

【17.2.2 原书 11x9 例子】
first 3 singular values = [3.909418, 2.609119, 1.996828]
energy ratio = 0.790254
relative error = 0.457981
first topic document coordinates = [1.383, 0.87, 1.32, 1.016, 0.863, 1.92, 1.109, 1.121, 1.709]
tfidf investing row = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
tfidf book row = [0.0, 0.0, 0.376, 0.5014, 0.0, 0.0, 0.0, 0.0, 0.0]

【NMF 平方损失】
loss = [13.439009, 1.73364, 1.544032, 1.543964]
nonincreasing = True
W =
  [ 0.000  1.091  0.000]
  [ 0.000  0.000  0.985]
  [ 0.222  0.038  0.081]
  [ 1.400  0.000  0.000]
  [ 0.311  0.000  0.000]
  [ 0.626  0.577  1.099]
H =
  [ 0.000  0.000  1.544  2.057]
  [ 1.809  0.000  0.205  0.000]
  [ 0.000  1.908  0.485  0.000]

【习题 17.2：散度损失】
divergence = [11.16047, 1.700078, 1.656871, 1.656871]
nonincreasing = True
minimum factor entry = 0.0
```

最后一行的 `0.0` 是极小正数在浮点乘法中下溢得到的 0，不是负值；它也展示了乘法更新会产生近似稀疏解和零锁定现象。

---

## 17.6 习题解答

### 习题 17.1

> 试将图 17.1 的例子进行潜在语义分析，并对结果进行观察。

图 17.1 的矩阵与各 $k$ 结果已在 17.2.3 和代码中列出。

1. 原空间：同义文档 $d_1,d_2$ 余弦仅 $0.316228$；不同义文档 $d_3,d_4$ 因 `apple` 得到 $0.804030$。
2. $k=1$：所有非零文档在一维空间只有正/负方向，本例均同向，所以两个余弦都是 1，发生严重过压缩。
3. $k=2$：$d_1,d_2$ 都投影到主方向，余弦为 1；但 $d_3,d_4$ 也升到 $0.926924$，没有区分多义词语境。
4. $k=3$：同义文档余弦为 $0.311642$，未改善；多义文档仍为 $0.926924$。
5. $k=4$：矩阵秩为 4，完整重构，余弦回到原空间。

结论：低秩分解确实平滑了词面表示，但**平滑不等于正确消歧**。该极小语料缺乏足够的共现桥梁，不能支持可靠语义恢复；选择 $k$ 还会决定欠拟合与原空间噪声之间的折中。

### 习题 17.2

> 给出损失函数是散度损失时的非负矩阵分解（潜在语义分析）的算法。

求解

$$
\min_{W,H\ge0}D(X\Vert WH).
$$

**输入**：$X\in\mathbb R_+^{m\times n}$，话题数 $k$，最大迭代次数 $t$，容差 $\varepsilon$。

**初始化**：取严格正的 $W\in\mathbb R_+^{m\times k}$、$H\in\mathbb R_+^{k\times n}$。

**循环**：

1. 固定 $W$，按式 (17.26) 同步更新全部 $H_{lj}$；
2. 用新 $H$ 重算 $WH$，固定 $H$，按式 (17.27) 同步更新全部 $W_{il}$；
3. 若散度相对下降量小于 $\varepsilon$，停止；否则继续。

**输出**：$W$ 为单词-话题矩阵，$H$ 为话题-文档矩阵。

为防止分母为 0，实现中给 $(WH)_{ij}$ 和归一化分母加小量。定理 17.2 保证每次更新散度不增，但只保证到稳定点，不保证全局最优。上面的 `kind='kl'` 分支就是完整实现。

### 习题 17.3

> 给出潜在语义分析的两种算法的计算复杂度，包括奇异值分解法和非负矩阵分解法。

设 $X\in\mathbb R^{m\times n}$，保留 $k$ 个话题，NMF 迭代 $t$ 轮。

#### SVD-LSA

稠密完整 SVD 的典型时间复杂度为

$$
O\bigl(mn\min(m,n)\bigr)
=
\begin{cases}
O(mn^2),&m\ge n,\\
O(m^2n),&m<n.
\end{cases}
$$

若只用迭代方法求前 $k$ 个奇异三元组，稠密主项通常约为

$$
O(mnk)
$$

乘以幂迭代/Lanczos 重启次数。对含 $s=\operatorname{nnz}(X)$ 个非零元素的稀疏矩阵，矩阵-向量乘法主项可写成约 $O(sk)$，再加正交化 $O((m+n)k^2)$；精确常数与迭代次数取决于谱间隔和算法。

输出存储为

$$
O((m+n)k),
$$

另加输入稀疏矩阵存储 $O(s)$。

#### NMF-LSA

平方损失每轮主要计算

$$
XH^\top,\quad WHH^\top,\quad W^\top X,\quad W^\top WH,
$$

散度更新也需形成 $WH$ 并遍历元素。稠密情况下每轮主项均为

$$
O(mnk),
$$

故 $t$ 轮为

$$
\boxed{O(tmnk)}.
$$

若按 $W(HH^\top)$ 与 $(W^\top W)H$ 的结合顺序优化，平方损失每轮更细地写作

$$
O\bigl(mnk+(m+n)k^2\bigr).
$$

存储为 $O(mn+(m+n)k)$；稀疏实现可把输入项降为 $O(s)$，但 $WH$ 通常稠密。NMF 还要乘迭代轮数并可能多次随机重启，故常比一次截断 SVD 更耗时。

### 习题 17.4

> 列出潜在语义分析与主成分分析的异同。

#### 相同点

1. 都用低维线性子空间表示高维数据；
2. SVD-LSA 与 PCA 都可由奇异值分解计算；
3. 都按奇异值/特征值排序，前 $k$ 个方向保留最多平方能量；
4. 在平方损失意义下都对应最优低秩重构；
5. 都可用于压缩、去噪、可视化和下游相似度计算。

#### 不同点

| 对比 | LSA | PCA |
| --- | --- | --- |
| 对象 | 单词-文本计数或 TF-IDF 矩阵 | 一般连续特征样本矩阵 |
| 中心化 | 通常直接分解非负稀疏 $X$，不中心化 | 标准 PCA 必须减去每个特征均值 |
| 目标解释 | 发现词与文档的潜在话题结构 | 发现样本方差最大的正交方向 |
| 坐标含义 | 话题坐标、文档相似性 | 主成分得分、方差解释率 |
| 数据预处理 | 分词、词表、停用词、TF-IDF | 中心化，必要时标准化 |
| 方法范围 | 还包括非负矩阵分解 LSA | 经典 PCA 依赖协方差/中心化 SVD |

关键关系：若把每篇文档看作 $m$ 维样本，并对词维度中心化后做 SVD，那么计算形式就是 PCA；LSA 通常不中心化，因为零有“词未出现”的明确含义，减均值会破坏稀疏性并引入大量负值。

---

## 17.7 本章知识清单

### 必须会写的模型

$$
X\approx TY,
\qquad
X\approx U_k\Sigma_kV_k^\top,
\qquad
X\approx WH,\ W,H\ge0.
$$

### 必须会解释的矩阵

| 方法 | 话题空间 | 文档话题表示 |
| --- | --- | --- |
| SVD-LSA | $U_k$ | $\Sigma_kV_k^\top$ |
| NMF-LSA | $W$ | $H$ |

### 必须掌握的推导

1. 文档由话题线性组合得到 $X\approx TY$；
2. 截断 SVD 是平方损失下最优秩 $k$ 近似；
3. $\nabla_WJ=WHH^\top-XH^\top$、$\nabla_HJ=W^\top WH-W^\top X$；
4. 特殊逐元素步长把加法梯度下降变成乘法更新；
5. 非负初始化加非负乘法因子保证迭代非负。

### 必须记住的边界

- 共现模式不足时，LSA 不保证识别同义词或消除多义性；
- SVD 的负权重不是概率，NMF 的非负权重也需归一化才可作伪概率解释；
- SVD 截断有全局最优低秩保证，NMF 只有损失非增和局部稳定点保证；
- $k$ 控制压缩、平滑与信息损失，必须依任务验证；
- NMF 有尺度、排列、初值依赖和零锁定问题。

## 第 17 章一句话回顾

**潜在语义分析把稀疏的词-文档矩阵压缩为少数话题与文档话题坐标：SVD 提供正交的全局最优低秩近似，NMF 提供非负可解释的加法分解，但二者能否恢复真实语义都取决于语料共现信息、话题数和优化条件。**
