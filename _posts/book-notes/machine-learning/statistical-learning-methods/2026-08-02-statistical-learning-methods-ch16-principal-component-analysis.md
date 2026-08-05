---
title: "《统计学习方法（第 2 版）》第 16 章：主成分分析"
date: 2026-08-01 02:16:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch16-principal-component-analysis
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: statistical-learning-methods
series_order: 17
related: [statistical-learning-methods-ch15-singular-value-decomposition, statistical-learning-methods-ch17-latent-semantic-analysis]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "从最大投影方差与最小重构误差的等价性推导 PCA，比较协方差或相关矩阵的特征分解与数据矩阵 SVD 两条算法路径。"
toc: true
math: true
---

> 凡标注 **【补充】** 的内容为书外补充（背景知识、推导细节、辨析、代码实验等），请与原书内容区分。原书结论不作虚构；对原书中需要成立条件或可能存在统计学争议的表述，会明确标注。

---

## 0. 本章解决什么问题

### 0.1 为什么需要 PCA

> **主成分分析**（principal component analysis，PCA）是一种常用的无监督学习方法。这一方法利用**正交变换**，把由线性相关变量表示的观测数据转换为少数几个由线性无关变量表示的数据，线性无关的变量称为**主成分**。主成分的个数通常小于原始变量的个数，所以主成分分析属于**降维方法**。

现实数据中的变量常常重复表达同一信息。例如学生的数学和物理成绩通常正相关，身高和体重也相关。若直接保留所有变量，会带来：

- 维数高、计算量大；
- 变量共线，模型参数不稳定；
- 可视化困难；
- 同一信息被重复计算。

PCA 要寻找一组新的正交坐标轴，使数据沿第 1 轴变化最大、沿第 2 轴次大，依次类推；然后只保留前几个方向。

$$
\boxed{\;
\text{PCA = 换一组正交坐标轴，把信息按方差从大到小重新排列，再丢掉低方差方向}
\;}
$$

### 0.2 目标与用途

> PCA 主要用于发现数据的基本结构，即数据中变量之间的关系，是数据分析的有力工具，也用于其他机器学习方法的前处理。

| 用途 | 具体含义 |
| --- | --- |
| 结构发现 | 通过主成分系数和因子负荷量理解变量关系 |
| 降维 | 用 $k\ll m$ 个主成分代替 $m$ 个原变量 |
| 可视化 | 投影到 2D/3D 后观察样本分组与异常值 |
| 去噪 | 丢弃方差很小、常由噪声主导的方向 |
| 监督学习前处理 | 缓解多重共线性、减少计算量 |

PCA 属于多元统计分析的经典方法：Pearson 于 1901 年首先提出（针对非随机变量），Hotelling 于 1933 年推广到随机变量。

### 0.3 PCA 的两种等价解释

原书通过图 16.1、16.2 给出两条互补的几何解释：

1. **最大方差解释**：找投影后方差最大的方向；
2. **最小重构误差解释**：找离样本点平方距离和最小的低维子空间。

两者为什么等价？对中心化样本 $x_j$ 与单位方向 $a$，由勾股定理：

$$
\lVert x_j\rVert^2=(a^\top x_j)^2+\lVert x_j-aa^\top x_j\rVert^2
$$

对全部样本求和：

$$
\underbrace{\sum_j\lVert x_j\rVert^2}_{\text{旋转中恒定}}
+=\underbrace{\sum_j(a^\top x_j)^2}_{\text{投影方差/保留信息}}
++\underbrace{\sum_j\lVert x_j-aa^\top x_j\rVert^2}_{\text{到轴的平方距离/丢失信息}}
$$

因此保留方差最大，等价于重构误差最小。

$$
\boxed{\;
\text{最大方差}\Longleftrightarrow\text{最小平方重构误差}
\;}
$$

这条等价关系会在习题 16.3 中借助第 15 章截断 SVD 的最优低秩定理得到矩阵形式的严格证明。

### 0.4 本章结构

```text
16.1 总体主成分分析（理论层）
 ├─ 16.1.1 基本想法：旋转坐标、最大方差、最小距离
 ├─ 16.1.2 定义：逐个最大化互不相关的线性组合
 ├─ 16.1.3 定理 16.1：主成分 = 协方差矩阵特征向量
 ├─ 16.1.4 主成分个数：最大保留方差、最小丢失方差、贡献率
 └─ 16.1.5 规范化：协方差 PCA vs 相关矩阵 PCA

16.2 样本主成分分析（算法层）
 ├─ 16.2.1 用样本均值、协方差替代总体量
 ├─ 16.2.2 相关矩阵特征值分解算法 + 例 16.1
 └─ 16.2.3 数据矩阵 SVD 算法（算法 16.1）
```

---

## 【补充】前置知识与记号

### A. 数据矩阵方向

延续第 13~15 章约定，$m\times n$ 样本矩阵

$$
X=[x_1\;x_2\;\cdots\;x_n]
$$

的**列是样本**、行是变量：$m$ 个变量，$n$ 个样本。

### B. 中心化与标准化

| 操作 | 公式 | 结果 |
| --- | --- | --- |
| 中心化 | $x_i\leftarrow x_i-E(x_i)$ | 每个变量均值为 0 |
| 标准化/规范化 | $x_i\leftarrow\dfrac{x_i-E(x_i)}{\sqrt{\operatorname{var}(x_i)}}$ | 每个变量均值 0、方差 1 |

**中心化是 PCA 必需的**：否则 $XX^\top$ 包含均值位置的信息，最大方向可能只是“离原点最远”而非“数据变化最大”。

**标准化并非总是必需**：它取决于是否希望消除量纲与尺度。本章原书主要讨论标准化后基于相关矩阵的 PCA。

### C. 不相关不等于独立

若 $\operatorname{cov}(y_i,y_j)=0$，只说明两者**线性不相关**，一般不能推出统计独立。只有在联合高斯等特殊分布下，不相关才蕴含独立。

因此原书图 16.1 后“知道 $y_1$ 后对 $y_2$ 的预测完全随机”应理解为**线性预测意义下没有帮助**，不是对任意分布都严格独立。

---

## 16.1 总体主成分分析

### 16.1.1 基本想法

> 统计分析中，数据的变量之间可能存在相关性，以致增加分析难度。于是考虑由少数不相关变量代替相关变量，并要求保留数据中的大部分信息。

原书先规范化数据，使每个变量均值为 0、方差为 1；再进行正交变换，把线性相关变量变成互不相关的新变量。新变量按方差从大到小排列，依次称为第一、第二……主成分。

#### 图 16.1：椭圆的长轴与短轴

二维中心化数据分布在倾斜椭圆内：

```text
x2 ↑                 y2 ↑
   |   ·                   |  ·
   | ··· ·                 | · ·
   |·····       旋转       |········ → y1（长轴）
   | ··· ·      ───→       | · ·
   +------→ x1             +------

原变量 x1,x2 相关       新变量 y1,y2 不相关
第一主成分：椭圆长轴；第二主成分：短轴
```

若只保留 $y_1$，就是把二维数据正交投影到长轴，压缩为一维。

#### 图 16.2：最大投影方差 = 最小到轴距离

样本 $A,B,C$ 在候选轴 $y_1$ 上投影为 $A',B',C'$。中心化后投影坐标平方和

$$
OA'^2+OB'^2+OC'^2
$$

与投影方差成正比。旋转坐标轴不改变

$$
OA^2+OB^2+OC^2,
$$

又由勾股定理

$$
OA^2=OA'^2+AA'^2
$$

故最大化投影平方和等价于最小化垂直距离平方和 $AA'^2+BB'^2+CC'^2$。

### 16.1.2 定义和导出

设

$$
x=(x_1,x_2,\ldots,x_m)^\top
$$

是 $m$ 维随机变量，均值向量与协方差矩阵分别为

$$
\mu=E(x)=(\mu_1,\ldots,\mu_m)^\top,
\qquad
\Sigma=\operatorname{cov}(x,x)=E[(x-\mu)(x-\mu)^\top].
$$

考虑线性变换

$$
y_i=a_i^\top x=a_{1i}x_1+a_{2i}x_2+\cdots+a_{mi}x_m,
\qquad i=1,\ldots,m
\tag{16.1}
$$

其中 $a_i=(a_{1i},\ldots,a_{mi})^\top$。

由期望和协方差的线性性质：

$$
E(y_i)=a_i^\top\mu
\tag{16.2}
$$

$$
\operatorname{var}(y_i)=a_i^\top\Sigma a_i
\tag{16.3}
$$

$$
\operatorname{cov}(y_i,y_j)=a_i^\top\Sigma a_j.
\tag{16.4}
$$

**式 (16.3) 的推导**：

$$
\begin{aligned}
\operatorname{var}(a_i^\top x)
&=E[(a_i^\top(x-\mu))^2]\\
&=E[a_i^\top(x-\mu)(x-\mu)^\top a_i]\\
&=a_i^\top E[(x-\mu)(x-\mu)^\top]a_i\\
&=a_i^\top\Sigma a_i.
\end{aligned}
$$

#### 定义 16.1（总体主成分）

给定式 (16.1) 的线性变换，若满足：

1. $a_i^\top a_i=1$；
2. $\operatorname{cov}(y_i,y_j)=0$（$i\ne j$）；
3. $y_1$ 在所有单位线性组合中方差最大；$y_2$ 在与 $y_1$ 不相关的单位线性组合中方差最大；一般地，$y_k$ 在与前 $k-1$ 个主成分不相关的单位线性组合中方差最大；

则 $y_1,\ldots,y_m$ 分别称为第一到第 $m$ 主成分。

**为什么必须约束 $\lVert a_i\rVert=1$**：若无此约束，任取一个方差非零方向 $a$，把它乘常数 $c$，方差变为

$$
\operatorname{var}(c a^\top x)=c^2a^\top\Sigma a,
$$

令 $c\to\infty$ 就可无限增大，优化问题无解。单位约束消除了这种任意缩放。

### 16.1.3 主要性质

#### 定理 16.1

设协方差矩阵 $\Sigma$ 的特征值为

$$
\lambda_1\ge\lambda_2\ge\cdots\ge\lambda_m\ge0,
$$

对应单位特征向量为 $a_1,\ldots,a_m$。则第 $k$ 主成分为

$$
y_k=a_k^\top x=a_{1k}x_1+\cdots+a_{mk}x_m,
\qquad k=1,\ldots,m
\tag{16.5}
$$

且

$$
\operatorname{var}(y_k)=a_k^\top\Sigma a_k=\lambda_k.
\tag{16.6}
$$

#### 第一主成分的推导

求解 Rayleigh 商最大化：

$$
\max_{a_1}\;a_1^\top\Sigma a_1
\quad\text{s.t.}\quad a_1^\top a_1=1.
\tag{16.7}
$$

拉格朗日函数

$$
L(a_1,\lambda)=a_1^\top\Sigma a_1-\lambda(a_1^\top a_1-1).
$$

因 $\Sigma$ 对称，

$$
\nabla_{a_1}L=2\Sigma a_1-2\lambda a_1=0
$$

故

$$
\Sigma a_1=\lambda a_1.
$$

即最优方向必须是协方差矩阵的特征向量。目标值

$$
 a_1^\top\Sigma a_1=\lambda a_1^\top a_1=\lambda.
$$

要最大化它，选最大特征值 $\lambda_1$ 对应的单位特征向量。因此

$$
\operatorname{var}(a_1^\top x)=\lambda_1.
\tag{16.8}
$$

#### 第二主成分的推导

第二主成分需要单位约束和与第一主成分不相关：

$$
\max_{a_2}a_2^\top\Sigma a_2
\tag{16.9}
$$

满足

$$
a_2^\top a_2=1,
\qquad
a_1^\top\Sigma a_2=0.
$$

因为 $\Sigma a_1=\lambda_1a_1$，

$$
a_1^\top\Sigma a_2=(\Sigma a_1)^\top a_2=\lambda_1a_1^\top a_2.
$$

当 $\lambda_1>0$ 时，不相关约束等价于 $a_1^\top a_2=0$。

拉格朗日函数

$$
L=a_2^\top\Sigma a_2-\lambda(a_2^\top a_2-1)-\phi a_2^\top a_1.
$$

一阶条件

$$
2\Sigma a_2-2\lambda a_2-\phi a_1=0.
\tag{16.10}
$$

左乘 $a_1^\top$，前两项因不相关与正交为 0，$a_1^\top a_1=1$，故 $\phi=0$。于是仍有

$$
\Sigma a_2=\lambda a_2.
$$

在与 $a_1$ 正交的子空间中，最大值由第二大特征值取得：

$$
\operatorname{var}(a_2^\top x)=\lambda_2.
\tag{16.11}
$$

递推可得

$$
\operatorname{var}(a_k^\top x)=a_k^\top\Sigma a_k=\lambda_k.
\tag{16.12}
$$

#### 重根时的非唯一性

若某特征值有重根，对应特征子空间内任意一组标准正交基都可作为主成分方向。此时**主子空间唯一，但子空间内的具体坐标轴不唯一**；这与第 15 章重复奇异值的奇异向量不唯一完全类似。

#### 推论 16.1 与矩阵形式

令

$$
A=[a_1\;a_2\;\cdots\;a_m],
\qquad
y=A^\top x.
$$

$y$ 的分量依次是所有主成分，当且仅当：

1. $A$ 正交；
2. $\operatorname{cov}(y)=\operatorname{diag}(\lambda_1,\ldots,\lambda_m)$，且特征值降序。

由

$$
\Sigma a_k=\lambda_ka_k
\tag{16.13}
$$

可写为

$$
\Sigma A=A\Lambda,
\tag{16.14}
$$

其中 $\Lambda=\operatorname{diag}(\lambda_1,\ldots,\lambda_m)$。左乘 $A^\top$：

$$
A^\top\Sigma A=\Lambda,
\tag{16.15}
$$

右乘 $A^\top$：

$$
\Sigma=A\Lambda A^\top.
\tag{16.16}
$$

因此

$$
\operatorname{cov}(y)=A^\top\Sigma A=\Lambda.
\tag{16.17}
$$

这说明 PCA 正交旋转把协方差矩阵**对角化**，主成分两两不相关。

#### 性质 1：总方差守恒

$$
\sum_{i=1}^{m}\operatorname{var}(x_i)
+=\operatorname{tr}(\Sigma)
+=\operatorname{tr}(A\Lambda A^\top)
+=\operatorname{tr}(A^\top A\Lambda)
+=\operatorname{tr}(\Lambda)
+=\sum_{i=1}^{m}\lambda_i
+=\sum_{i=1}^{m}\operatorname{var}(y_i).
\tag{16.18--16.19}
$$

PCA 不创造也不消灭总方差，只是把方差重新分配并排序。

#### 性质 2：因子负荷量

第 $k$ 主成分与原变量 $x_i$ 的相关系数称为**因子负荷量**：

$$
\rho(y_k,x_i)=\frac{\sqrt{\lambda_k}\,a_{ik}}{\sqrt{\sigma_{ii}}}.
\tag{16.20}
$$

推导：

$$
\operatorname{cov}(y_k,x_i)
+=\operatorname{cov}(a_k^\top x,e_i^\top x)
+=a_k^\top\Sigma e_i
+=e_i^\top\Sigma a_k
+=\lambda_ke_i^\top a_k
+=\lambda_ka_{ik}.
$$

又 $\operatorname{var}(y_k)=\lambda_k$、$\operatorname{var}(x_i)=\sigma_{ii}$，故

$$
\rho(y_k,x_i)
+=\frac{\lambda_ka_{ik}}{\sqrt{\lambda_k}\sqrt{\sigma_{ii}}}
+=\frac{\sqrt{\lambda_k}a_{ik}}{\sqrt{\sigma_{ii}}}.
$$

**系数 $a_{ik}$ 与因子负荷量不是同一个量**：前者描述如何组合变量，后者描述主成分与原变量的相关强度；只有标准化且 $\lambda_k=1$ 时数值才相同。

#### 性质 3：负荷量平方和

对固定主成分 $y_k$：

$$
\sum_{i=1}^{m}\sigma_{ii}\rho^2(y_k,x_i)
+=\sum_i\lambda_ka_{ik}^2
+=\lambda_k a_k^\top a_k
+=\lambda_k.
\tag{16.21}
$$

对固定原变量 $x_i$，全部主成分对它的解释率之和为 1：

$$
\sum_{k=1}^{m}\rho^2(y_k,x_i)=1.
\tag{16.22}
$$

这源于完整正交变换可无损恢复 $x_i$；若只保留前 $q$ 个，则

$$
\sum_{k=1}^{q}\rho^2(y_k,x_i)
$$

就是前 $q$ 个主成分对变量 $x_i$ 的解释比例。

---

### 16.1.4 主成分的个数

PCA 的目的通常是用 $k\ll m$ 个主成分代替 $m$ 个原变量。关键问题是：**为什么一定选前 $k$ 个，而不是任意 $k$ 个正交方向？$k$ 又应取多少？**

#### 定理 16.2（前 $q$ 个主成分保留总方差最多）

对任意 $1\le q\le m$，考虑正交线性变换

$$
y=B^\top x,
\tag{16.23}
$$

其中 $B\in\mathbb R^{m\times q}$ 且 $B^\top B=I_q$。则

$$
\Sigma_y=B^\top\Sigma B.
\tag{16.24}
$$

定理断言：$\operatorname{tr}(\Sigma_y)$ 在 $B=A_q=[a_1,\ldots,a_q]$ 时最大，最大值为

$$
\lambda_1+\cdots+\lambda_q.
$$

**为什么迹代表保留信息**：$\operatorname{tr}(\Sigma_y)=\sum_{k=1}^{q}\operatorname{var}(y_k)$，即 $q$ 个新变量的总方差。

#### 定理 16.2 的证明

因为 $A=[a_1,\ldots,a_m]$ 是 $\mathbb R^m$ 的正交基，$B$ 的每列 $\beta_k$ 可展开为

$$
\beta_k=\sum_{j=1}^{m}c_{jk}a_j,
$$

矩阵形式

$$
B=AC,
\tag{16.25}
$$

其中 $C\in\mathbb R^{m\times q}$。

利用 $A^\top\Sigma A=\Lambda$：

$$
B^\top\Sigma B=C^\top A^\top\Sigma AC=C^\top\Lambda C.
$$

若 $c_j^\top$ 是 $C$ 的第 $j$ 行，则

$$
\operatorname{tr}(B^\top\Sigma B)
=\sum_{j=1}^{m}\lambda_j\operatorname{tr}(c_jc_j^\top)
=\sum_{j=1}^{m}\lambda_j\sum_{k=1}^{q}c_{jk}^2.
\tag{16.26}
$$

另一方面，由 $B^\top B=I_q$ 与 $A$ 正交：

$$
C^\top C=B^\top AA^\top B=B^\top B=I_q.
$$

所以所有系数平方之和为

$$
\sum_{j=1}^{m}\sum_{k=1}^{q}c_{jk}^2
=\operatorname{tr}(C^\top C)=q.
\tag{16.27}
$$

又因为 $C$ 的 $q$ 个正交列可扩充成 $m$ 阶正交矩阵，每行前 $q$ 个元素的平方和不超过整行平方和 1：

$$
\sum_{k=1}^{q}c_{jk}^2\le1.
\tag{16.28}
$$

令

$$
w_j:=\sum_{k=1}^{q}c_{jk}^2.
$$

问题化为：

$$
\max\sum_{j=1}^{m}\lambda_jw_j,
\quad0\le w_j\le1,
\quad\sum_jw_j=q.
$$

由于 $\lambda_1\ge\cdots\ge\lambda_m$，最优策略显然是把总权重 $q$ 全放到最大的 $q$ 个特征值上：

$$
w_j=\begin{cases}1,&j\le q\\0,&j>q.
\end{cases}
\tag{16.29}
$$

取 $B=A_q$ 时恰能实现。因此

$$
\boxed{\;
\max_{B^\top B=I_q}\operatorname{tr}(B^\top\Sigma B)
=\sum_{j=1}^{q}\lambda_j
\;}
$$

$\blacksquare$

**代码验证**：对例 16.1 的相关矩阵随机生成 10,000 组二维正交方向，最大保留方差为 $3.034934$，仍低于 PCA 理论最优

$$
\lambda_1+\lambda_2=2.170165+0.871005=3.041171.
$$

#### 定理 16.3（舍弃后 $p$ 个主成分损失最小）

若 $B$ 有 $p$ 个正交列，则 $\operatorname{tr}(B^\top\Sigma B)$ 在 $B=A_p$（由 $A$ 的后 $p$ 列组成）时最小：

$$
\min_{B^\top B=I_p}\operatorname{tr}(B^\top\Sigma B)
=\lambda_{m-p+1}+\cdots+\lambda_m.
$$

证明与定理 16.2 相同，只需把权重放到最小的 $p$ 个特征值上。

**解释**：保留前 $k=m-p$ 个，与舍弃后 $p$ 个是同一件事。前者最大化保留方差，后者最小化丢失方差。

$$
\boxed{\;
\text{前 }k\text{ 主成分是最优的，不是“按惯例取前几个”}
\;}
$$

#### 定义 16.2：方差贡献率

第 $k$ 主成分方差贡献率：

$$
\eta_k=\frac{\lambda_k}{\sum_{i=1}^{m}\lambda_i}.
\tag{16.30}
$$

前 $k$ 个累计方差贡献率：

$$
\sum_{j=1}^{k}\eta_j
=\frac{\sum_{j=1}^{k}\lambda_j}{\sum_{i=1}^{m}\lambda_i}.
\tag{16.31}
$$

原书建议通常选择累计贡献率达到 $70\%\sim80\%$ 以上的最小 $k$。实践中常用 $90\%$、$95\%$ 或结合下游任务交叉验证。

**局限**【补充】：方差大不一定对分类有用；一个低方差方向可能正好区分类别。PCA 是无监督方法，只保留总体变化，不知道标签目标。

#### 定义 16.3：对单个原变量的贡献率

前 $k$ 主成分对原变量 $x_i$ 的贡献率：

$$
\nu_i=\rho^2(x_i,(y_1,\ldots,y_k))
=\sum_{j=1}^{k}\rho^2(y_j,x_i).
\tag{16.32}
$$

它回答“前 $k$ 个主成分对变量 $x_i$ 保留了多少信息”，与全局累计方差贡献率回答的问题不同。

| 指标 | 关注对象 | 问题 |
| --- | --- | --- |
| 累计方差贡献率 | 全体变量总方差 | 总体保留多少信息？ |
| $\nu_i$ | 单个变量 $x_i$ | 这个变量被解释多少？ |

### 16.1.5 规范化变量的总体主成分

不同变量可能量纲不同。若一个变量以“元”计、另一个以“米”计，数值尺度较大的变量会主导协方差 PCA。原书因此定义规范化变量：

$$
x_i^*=\frac{x_i-E(x_i)}{\sqrt{\operatorname{var}(x_i)}},
\qquad i=1,\ldots,m.
\tag{16.33}
$$

其均值为 0、方差为 1，协方差矩阵就是相关矩阵 $R$。

#### 协方差 PCA 与相关矩阵 PCA

| | 协方差矩阵 PCA | 相关矩阵 PCA |
| --- | --- | --- |
| 预处理 | 仅中心化 | 中心化并除以标准差 |
| 是否保留原尺度 | 是 | 否 |
| 适合 | 同量纲且尺度有意义 | 异量纲、尺度不可比 |
| 风险 | 大尺度变量支配结果 | 低方差噪声也被放大到方差 1 |

**不要机械标准化**【补充】：若变量同量纲且方差差异本身有业务意义，标准化会抹去这种信息。

#### 规范化后的性质

设 $R$ 的特征值为 $\lambda_1^*\ge\cdots\ge\lambda_m^*\ge0$：

$$
\operatorname{cov}(y)=\Lambda^*=\operatorname{diag}(\lambda_1^*,\ldots,\lambda_m^*)
\tag{16.34}
$$

因为 $R$ 对角元全为 1：

$$
\sum_{k=1}^{m}\lambda_k^*=\operatorname{tr}(R)=m.
\tag{16.35}
$$

因子负荷量简化为

$$
\rho(y_k,x_i^*)=\sqrt{\lambda_k^*}\,e_{ik},
\tag{16.36}
$$

其中 $e_k$ 是 $R$ 对应 $\lambda_k^*$ 的单位特征向量。并有

$$
\sum_i\rho^2(y_k,x_i^*)=\lambda_k^*,
\tag{16.37}
$$

$$
\sum_k\rho^2(y_k,x_i^*)=1.
\tag{16.38}
$$

---

## 16.2 样本主成分分析

总体协方差矩阵未知，实际只能用有限样本估计，这就是样本 PCA。

### 16.2.1 样本主成分的定义和性质

对 $m$ 维随机变量独立观测 $n$ 次，样本矩阵为

$$
X=[x_1\;x_2\;\cdots\;x_n]
=\begin{bmatrix}
x_{11}&\cdots&x_{1n}\\
\vdots&&\vdots\\
x_{m1}&\cdots&x_{mn}
\end{bmatrix}.
\tag{16.39}
$$

样本均值向量：

$$
\bar x=\frac1n\sum_{j=1}^{n}x_j.
\tag{16.40}
$$

样本协方差矩阵：

$$
S=[s_{ij}]_{m\times m},
\qquad
s_{ij}=\frac1{n-1}\sum_{k=1}^{n}(x_{ik}-\bar x_i)(x_{jk}-\bar x_j).
\tag{16.41}
$$

样本相关矩阵：

$$
R=[r_{ij}],
\qquad
r_{ij}=\frac{s_{ij}}{\sqrt{s_{ii}s_{jj}}}.
\tag{16.42}
$$

令 $y=A^\top x$：

$$
y=A^\top x.
\tag{16.43}
$$

单个线性组合为

$$
y_i=a_i^\top x.
\tag{16.44}
$$

样本均值、方差和协方差分别为

$$
\bar y_i=a_i^\top\bar x,
\tag{16.45}
$$

$$
\operatorname{var}(y_i)=a_i^\top Sa_i,
\tag{16.46}
$$

$$
\operatorname{cov}(y_i,y_k)=a_i^\top Sa_k.
\tag{16.47}
$$

#### 定义 16.4（样本主成分）

把总体定义中的 $\Sigma$ 换成样本协方差 $S$：第一个样本主成分在单位方向中使 $a_1^\top Sa_1$ 最大；第 $i$ 个在单位约束及与前面样本协方差为 0 的条件下使 $a_i^\top Sa_i$ 最大。

因此定理 16.1~16.3 对样本 PCA 同样成立。

#### 样本规范化

$$
x_{ij}^*=\frac{x_{ij}-\bar x_i}{\sqrt{s_{ii}}}.
\tag{16.48}
$$

规范化后每行均值 0、样本方差 1，样本协方差矩阵就是样本相关矩阵：

$$
R=\frac1{n-1}XX^\top.
\tag{16.49}
$$

**【辨析】原书的两个统计估计表述**：

- $S$（分母 $n-1$）是总体协方差矩阵的无偏估计：正确，习题 16.2 证明；
- “样本相关矩阵 $R$ 是总体相关矩阵的无偏估计”：一般**不严格成立**，因为 $r_{ij}$ 是随机协方差与随机标准差之比，期望通常不等于总体相关系数；
- “$S$ 的特征值和特征向量是总体协方差特征值/向量的极大似然估计”也需要分布假设与参数化讨论，不能仅凭 $S$ 无偏直接推出。

这些辨析属于书外统计学说明，不影响 PCA 算法本身。

### 16.2.2 相关矩阵的特征值分解算法

给定样本矩阵 $X$：

1. 按式 (16.48) 规范化；
2. 计算 $R=XX^\top/(n-1)$；
3. 求 $R$ 的降序特征值与单位特征向量，按累计贡献率选 $k$；
4. 求主成分

$$
y_i=a_i^\top x,
\qquad i=1,\ldots,k;
\tag{16.50}
$$

5. 计算因子负荷量与对原变量贡献率；
6. 计算全部样本主成分得分

$$
Y=A_k^\top X\in\mathbb R^{k\times n}.
$$

#### 例 16.1

四门课的样本相关矩阵：

$$
R=\begin{bmatrix}
1&0.44&0.29&0.33\\
0.44&1&0.35&0.32\\
0.29&0.35&1&0.60\\
0.33&0.32&0.60&1
\end{bmatrix}.
$$

原书给出

$$
\lambda=(2.17,0.87,0.57,0.39),
$$

精确计算为

$$
(2.170165,0.871005,0.566179,0.392650),
$$

和为 4，与 $\operatorname{tr}(R)=4$ 一致。

前两项累计贡献率

$$
\frac{2.170165+0.871005}{4}=0.760293>75\%,
$$

故取 $k=2$。

按与原书一致的符号方向，前两个单位特征向量精确值约为

$$
a_1=(0.459908,0.476312,0.528750,0.531070)^\top,
$$

$$
a_2=(0.567909,0.490907,-0.475571,-0.458609)^\top.
$$

原书表 16.2 四舍五入写为

$$
a_1\approx(0.460,0.476,0.523,0.537)^\top,
$$

$$
a_2\approx(0.574,0.486,-0.476,-0.456)^\top.
$$

因此主成分为

$$
y_1=0.460x_1+0.476x_2+0.523x_3+0.537x_4,
$$

$$
y_2=0.574x_1+0.486x_2-0.476x_3-0.456x_4.
$$

**解释**：$y_1$ 系数全正且接近，表示整体成绩；$y_2$ 文科为正、理科为负，表示文理差异。

因标准化变量方差为 1，负荷量为 $\sqrt{\lambda_k}a_{ik}$。原书表 16.3（使用表 16.2 的舍入值）给出：

| | 语文 | 外语 | 数学 | 物理 |
| --- | ---: | ---: | ---: | ---: |
| $y_1$ 负荷 | 0.678 | 0.701 | 0.770 | 0.791 |
| $y_2$ 负荷 | 0.536 | 0.453 | -0.444 | -0.425 |
| 前两主成分贡献率 | 0.747 | 0.697 | 0.790 | 0.806 |

用未舍入特征向量计算得到负荷量

$$
y_1:(0.677512,0.701679,0.778927,0.782344),
$$

$$
y_2:(0.530017,0.458152,-0.443839,-0.428009),
$$

贡献率为

$$
(0.739940,0.702256,0.803720,0.795254).
$$

与书中略有差异仅来自输入特征向量的四舍五入，不影响解释。

图 16.3 将四个变量的负荷坐标 $(\rho(y_1,x_i),\rho(y_2,x_i))$ 画在平面上：语文、外语聚在上方（文科），数学、物理聚在下方（理科）。

### 16.2.3 数据矩阵的奇异值分解算法

传统方法分解 $m\times m$ 的相关矩阵。现代实现常直接对数据矩阵做 SVD。

假设 $X$ 已中心化，定义

$$
X'=\frac1{\sqrt{n-1}}X^\top\in\mathbb R^{n\times m}.
\tag{16.51}
$$

则

$$
X'^\top X'
=\left(\frac1{\sqrt{n-1}}X^\top\right)^\top
\left(\frac1{\sqrt{n-1}}X^\top\right)
=\frac1{n-1}XX^\top.
\tag{16.52}
$$

所以

$$
S_X=X'^\top X'.
\tag{16.53}
$$

若

$$
X'=U\Sigma V^\top,
$$

由第 15 章式 (15.20)：

$$
X'^\top X'=V\Sigma^\top\Sigma V^\top.
$$

因此：

- $V$ 的列就是协方差矩阵特征向量，即主成分方向；
- 协方差特征值 $\lambda_i=\sigma_i^2$；
- 样本得分矩阵 $Y=V_k^\top X$。

#### 算法 16.1

**输入**：每行均值为 0 的 $m\times n$ 样本矩阵 $X$；主成分个数 $k$。

1. 构造 $X'=X^\top/\sqrt{n-1}$；
2. 对 $X'$ 作截断 SVD：$X'=U_k\Sigma_kV_k^\top$；
3. 输出主成分矩阵

$$
Y=V_k^\top X.
$$

#### 两种算法严格等价

特征分解法计算 $R=XX^\top/(n-1)$ 的特征向量；SVD 法利用 $R=X'^\top X'$，右奇异向量就是同一组特征向量。

代码对习题 16.1 验证：

- $R$ 的最大元素差 $2.22\times10^{-16}$；
- SVD 奇异值 $(1.396542,0.222870)$ 等于 $(\sqrt{\lambda_1},\sqrt{\lambda_2})$；
- 第一主子空间投影矩阵差 $2.22\times10^{-16}$。

**什么时候用哪一种**【补充】：

| 情形 | 推荐 |
| --- | --- |
| $m$ 很小，需要完整载荷解释 | 分解 $m\times m$ 协方差/相关矩阵 |
| $m,n$ 很大，只要前 $k$ 个 | 截断/随机化 SVD |
| $m\gg n$ | 可分解较小的 $X^\top X$，但注意数值稳定性 |
| 稀疏高维数据 | 不要显式形成稠密协方差，直接稀疏 SVD |

---

## 16.3 代码实现与验证

下面是纯 Python 实现，不依赖第三方库。它按原书 16.2.2 节计算相关矩阵并特征分解，同时按式 (16.51)~(16.53) 验证 SVD 路线。

```python
"""《统计学习方法》第 16 章：纯 Python PCA，不依赖第三方库。"""
import math


def transpose(A): return [list(r) for r in zip(*A)]
def matmul(A,B): return [[sum(A[i][k]*B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]


def jacobi(A,tol=1e-14):
		"""实对称矩阵特征分解，V 的列是单位特征向量。"""
		n=len(A); a=[r[:] for r in A]; V=[[float(i==j) for j in range(n)] for i in range(n)]
		for _ in range(100000):
				_,p,q=max((abs(a[i][j]),i,j) for i in range(n) for j in range(i+1,n))
				if abs(a[p][q])<tol: break
				z=(a[q][q]-a[p][p])/(2*a[p][q])
				t=math.copysign(1,z)/(abs(z)+math.sqrt(z*z+1))
				c=1/math.sqrt(1+t*t); s=t*c
				for k in range(n):
						x,y=a[k][p],a[k][q]; a[k][p],a[k][q]=c*x-s*y,s*x+c*y
				for k in range(n):
						x,y=a[p][k],a[q][k]; a[p][k],a[q][k]=c*x-s*y,s*x+c*y
				for k in range(n):
						x,y=V[k][p],V[k][q]; V[k][p],V[k][q]=c*x-s*y,s*x+c*y
		order=sorted(range(n),key=lambda j:-a[j][j])
		return [a[j][j] for j in order],[[V[i][j] for j in order] for i in range(n)]


def standardize(X):
		"""式(16.48)：按行标准化（行=变量，列=样本）。"""
		m,n=len(X),len(X[0]); mean=[sum(r)/n for r in X]
		var=[sum((x-mean[i])**2 for x in X[i])/(n-1) for i in range(m)]
		Z=[[(X[i][j]-mean[i])/math.sqrt(var[i]) for j in range(n)] for i in range(m)]
		return Z,mean,var


def covariance(X):
		"""式(16.41)/(16.49)：假设 X 每行均值为 0。"""
		n=len(X[0])
		return [[sum(X[i][k]*X[j][k] for k in range(n))/(n-1)
						 for j in range(len(X))] for i in range(len(X))]


def pca(X,k,do_standardize=True):
		"""16.2.2 节相关矩阵特征值分解算法。"""
		if do_standardize: Z,mean,var=standardize(X)
		else:
				m,n=len(X),len(X[0]); mean=[sum(r)/n for r in X]
				Z=[[X[i][j]-mean[i] for j in range(n)] for i in range(m)]
				var=[sum(x*x for x in Z[i])/(n-1) for i in range(m)]
		S=covariance(Z); eig,V=jacobi(S)
		Vk=[[V[i][j] for j in range(k)] for i in range(len(V))]
		scores=matmul(transpose(Vk),Z)
		loadings=[[math.sqrt(eig[j])*V[i][j]/math.sqrt(S[i][i])
							 for i in range(len(V))] for j in range(k)]
		return Z,S,eig,V,scores,loadings,mean,var


def show(A,d=6):
		for r in A: print('  ['+' '.join(f'{x: .{d}f}' for x in r)+']')


print('【例 16.1】')
R=[[1,.44,.29,.33],[.44,1,.35,.32],[.29,.35,1,.60],[.33,.32,.60,1]]
e,V=jacobi(R)
for j,target in [(0,[1,1,1,1]),(1,[1,1,-1,-1])]:
		if sum(V[i][j]*target[i] for i in range(4))<0:
				for i in range(4): V[i][j]*=-1
print('eigenvalues =',[round(x,8) for x in e])
print('cumulative first 2 =',round(sum(e[:2])/4,8))
L=[[math.sqrt(e[j])*V[i][j] for i in range(4)] for j in range(2)]
print('loadings:');show(L)

print('\n【习题 16.1】')
X=[[2,3,3,4,5,7],[2,4,5,5,6,8]]
Z,S,e,V,Y,L,mean,var=pca(X,1,True)
print('mean =',mean,'sample variance =',var)
print('correlation matrix:');show(S)
print('eigenvalues =',[round(x,8) for x in e])
print('variance ratio =',[round(x/sum(e),8) for x in e])
print('eigenvectors:');show(V)
print('first-PC scores:');show(Y)
print('first-PC loadings:');show(L)
Z1=matmul([[V[i][0]] for i in range(2)],Y)
err=math.sqrt(sum((Z[i][j]-Z1[i][j])**2 for i in range(2) for j in range(6)))
print('rank-1 reconstruction error =',round(err,8))
print('theory sqrt((n-1)*lambda_2) =',round(math.sqrt(5*e[1]),8))

print('\n【协方差 PCA 对比】')
_,S2,e2,V2,_,_,_,_=pca(X,1,False)
print('covariance matrix:');show(S2)
print('eigenvalues =',[round(x,8) for x in e2])
print('first direction =',[round(V2[i][0],8) for i in range(2)])

print('\n【算法 16.1：SVD 等价性】')
Xp=[[Z[i][j]/math.sqrt(5) for i in range(2)] for j in range(6)]
Rt=matmul(transpose(Xp),Xp); es,Vs=jacobi(Rt)
print('max covariance difference =',max(abs(Rt[i][j]-S[i][j]) for i in range(2) for j in range(2)))
print('singular values =',[round(math.sqrt(x),8) for x in es])
print('sqrt eigenvalues =',[round(math.sqrt(x),8) for x in e])
P1=[[V[i][0]*V[j][0] for j in range(2)] for i in range(2)]
P2=[[Vs[i][0]*Vs[j][0] for j in range(2)] for i in range(2)]
print('projection difference =',max(abs(P1[i][j]-P2[i][j]) for i in range(2) for j in range(2)))
```

**运行结果：**

```text
【例 16.1】
eigenvalues = [2.17016506, 0.87100546, 0.56617908, 0.3926504]
cumulative first 2 = 0.76029263
loadings:
  [ 0.677512  0.701679  0.778927  0.782344]
  [ 0.530017  0.458152 -0.443839 -0.428009]

【习题 16.1】
mean = [4.0, 5.0] sample variance = [3.2, 4.0]
correlation matrix:
  [ 1.000000  0.950329]
  [ 0.950329  1.000000]
eigenvalues = [1.95032889, 0.04967111]
variance ratio = [0.97516445, 0.02483555]
eigenvectors:
  [ 0.707107 -0.707107]
  [ 0.707107  0.707107]
first-PC scores:
  [-1.851230 -0.748838 -0.395285  0.000000  0.748838  2.246514]
first-PC loadings:
  [ 0.987504  0.987504]
rank-1 reconstruction error = 0.49835283
theory sqrt((n-1)*lambda_2) = 0.49835283

【协方差 PCA 对比】
covariance matrix:
  [ 3.200000  3.400000]
  [ 3.400000  4.000000]
eigenvalues = [7.02344855, 0.17655145]
first direction = [0.66451439, 0.74727547]

【算法 16.1：SVD 等价性】
max covariance difference = 2.220446049250313e-16
singular values = [1.39654176, 0.22287016]
sqrt eigenvalues = [1.39654176, 0.22287016]
projection difference = 2.220446049250313e-16
```

> Windows 若出现中文编码错误，运行前设置 `$env:PYTHONIOENCODING="utf-8"`。

---

## 16.4 【补充】深入理解、局限与替代方法

### 16.4.1 PCA 的模型、策略、算法

| 要素 | 内容 |
| --- | --- |
| 模型 | 线性正交投影 $z=A_k^\top(x-\mu)$ |
| 策略 | 最大化投影总方差，等价于最小化平方重构误差 |
| 算法 | 协方差/相关矩阵特征分解，或中心化数据矩阵 SVD |

### 16.4.2 PCA 的适用假设

1. 低维结构近似是**线性子空间**；
2. 方差大的方向更重要；
3. 平方损失合适，异常值不会主导结果；
4. 样本足以稳定估计协方差结构。

不满足时：

| 问题 | 后果 | 替代方法 |
| --- | --- | --- |
| 非线性流形 | 线性投影展开不了弯曲结构 | 核 PCA、Isomap、UMAP 等 |
| 严重离群/稀疏破坏 | 平方损失被极端点主导 | Robust PCA |
| 需要可解释稀疏载荷 | 每个主成分混合所有变量 | Sparse PCA |
| 两组变量关系 | PCA 只分析一组变量内部 | 典型相关分析 CCA |
| 目标是分类 | 高方差方向未必判别性强 | LDA/监督降维 |

### 16.4.3 易混淆概念

1. **不相关不等于独立**；仅联合高斯等情形下等价。
2. **主成分方向、主成分变量、主成分得分不同**：$a_k$ 是方向，$y_k=a_k^\top x$ 是随机变量，$y_{kj}=a_k^\top x_j$ 是第 $j$ 个样本得分。
3. **系数不等于因子负荷量**：负荷量还乘 $\sqrt{\lambda_k}/\sqrt{\sigma_{ii}}$。
4. **中心化与标准化不同**：PCA 必须围绕均值分析；是否除标准差取决于尺度语义。
5. **特征向量符号无意义**：$a_k$ 与 $-a_k$ 给出同一主轴，得分只整体取反。
6. **重复特征值时轴不唯一**：主子空间唯一，内部任意正交旋转都同样最优。
7. **PCA 不是特征选择**：主成分通常是所有原变量的线性组合，没有直接删除原变量。
8. **累计方差高不保证下游准确率高**：PCA 不看标签。
9. **SVD 中哪组向量是主方向取决于矩阵方向**：原书对 $X'=X^\top/\sqrt{n-1}$ 做 SVD，因此主方向是右奇异向量 $V$；若直接对 $X$ 做 SVD，则主方向是左奇异向量。
10. **样本相关系数一般有偏**：不能把协方差无偏性机械搬到相关系数。

---

## 16.5 本章概要与必须掌握的结论

1. PCA 用正交变换把相关变量变成按方差降序、两两不相关的主成分。
2. 最大投影方差等价于最小到低维子空间的平方距离。
3. 单位约束防止通过任意放大系数使方差无界。
4. $\operatorname{var}(a^\top x)=a^\top\Sigma a$，$\operatorname{cov}(a_i^\top x,a_j^\top x)=a_i^\top\Sigma a_j$。
5. 定理 16.1：主成分方向是协方差矩阵单位特征向量，主成分方差是对应特征值。
6. PCA 使 $A^\top\Sigma A=\Lambda$，从而主成分协方差矩阵对角化。
7. 总方差守恒：$\operatorname{tr}(\Sigma)=\sum_i\lambda_i$。
8. 因子负荷量为 $\rho(y_k,x_i)=\sqrt{\lambda_k}a_{ik}/\sqrt{\sigma_{ii}}$。
9. 完整主成分对每个变量的负荷平方和为 1。
10. 定理 16.2：任意 $q$ 维正交投影中，前 $q$ 主成分保留总方差最大。
11. 定理 16.3：舍弃后 $p$ 主成分造成方差损失最小。
12. 方差贡献率与累计贡献率用于选择 $k$，但不能保证下游任务最优。
13. 标准化后协方差矩阵就是相关矩阵，特征值和为 $m$。
14. 样本 PCA 用 $S$ 替代总体 $\Sigma$，理论形式完全一致。
15. 规范化样本矩阵满足 $R=XX^\top/(n-1)$。
16. 特征分解算法输出方向 $A_k$ 与得分 $Y=A_k^\top X$。
17. 算法 16.1 对 $X'=X^\top/\sqrt{n-1}$ 做 SVD，右奇异向量就是主成分方向。
18. 协方差特征值等于 $X'$ 奇异值平方。
19. PCA 是第 15 章最优低秩近似在中心化数据上的直接应用。
20. PCA 对尺度、异常值与非线性结构敏感。

---

## 16.6 习题解答

### 习题 16.1

给定

$$
X=\begin{bmatrix}
2&3&3&4&5&7\\
2&4&5&5&6&8
\end{bmatrix}.
$$

原书本章主要采用规范化变量，故进行相关矩阵 PCA。

#### 1. 均值与样本方差

$$
\bar x_1=4,\qquad \bar x_2=5.
$$

中心化平方和：

$$
\sum_j(x_{1j}-4)^2=16,
\qquad
\sum_j(x_{2j}-5)^2=20.
$$

$n=6$，故

$$
s_{11}=\frac{16}{5}=3.2,
\qquad
s_{22}=\frac{20}{5}=4.
$$

样本协方差

$$
s_{12}=\frac1{5}\sum_j(x_{1j}-4)(x_{2j}-5)=\frac{17}{5}=3.4.
$$

相关系数

$$
r=\frac{3.4}{\sqrt{3.2\cdot4}}=0.95032889.
$$

所以

$$
R=\begin{bmatrix}1&r\\r&1\end{bmatrix}
=\begin{bmatrix}1&0.950329\\0.950329&1\end{bmatrix}.
$$

#### 2. 特征值与主方向

矩阵 $\begin{bmatrix}1&r\\r&1\end{bmatrix}$ 的特征值为 $1+r$ 与 $1-r$：

$$
\lambda_1=1.95032889,
\qquad
\lambda_2=0.04967111.
$$

对应单位特征向量可取

$$
a_1=\frac1{\sqrt2}(1,1)^\top,
\qquad
a_2=\frac1{\sqrt2}(-1,1)^\top.
$$

贡献率：

$$
\eta_1=\frac{\lambda_1}{2}=0.97516445,
\qquad
\eta_2=0.02483555.
$$

第一主成分已解释 $97.52\%$ 方差，取 $k=1$ 即可。

#### 3. 标准化数据与得分

$$
x_1^*=\frac{x_1-4}{\sqrt{3.2}},
\qquad
x_2^*=\frac{x_2-5}{2}.
$$

第一主成分

$$
y_1=\frac{x_1^*+x_2^*}{\sqrt2}.
$$

六个样本得分为

$$
(-1.851230,-0.748838,-0.395285,0,0.748838,2.246514).
$$

第一主成分对两个标准化变量的负荷量相同：

$$
\sqrt{\lambda_1}\frac1{\sqrt2}=0.987504.
$$

秩 1 重构误差

$$
\lVert Z-Z_1\rVert_F=0.49835283
=\sqrt{(n-1)\lambda_2},
$$

与定理 15.3/习题 16.3 一致。

**若不标准化**，协方差 PCA 的第一方向为 $(0.664514,0.747275)^\top$，会更偏向方差较大的第二变量；这说明标准化确实改变结果。

### 习题 16.2

证明样本协方差矩阵 $S$ 是总体协方差矩阵 $\Sigma$ 的无偏估计。

设 $X_1,\ldots,X_n$ 独立同分布，$E(X_i)=\mu$，$\operatorname{cov}(X_i)=\Sigma$，样本均值 $\bar X=n^{-1}\sum_iX_i$。样本协方差

$$
S=\frac1{n-1}\sum_{i=1}^{n}(X_i-\bar X)(X_i-\bar X)^\top.
$$

利用恒等式

$$
\sum_i(X_i-\bar X)(X_i-\bar X)^\top
=\sum_i(X_i-\mu)(X_i-\mu)^\top
-n(\bar X-\mu)(\bar X-\mu)^\top.
$$

证明该恒等式：写 $X_i-\bar X=(X_i-\mu)-(\bar X-\mu)$ 展开，交叉项利用

$$
\sum_i(X_i-\mu)=n(\bar X-\mu)
$$

合并即可。

取期望。第一项：

$$
E\left[\sum_i(X_i-\mu)(X_i-\mu)^\top\right]=n\Sigma.
$$

又因独立同分布：

$$
\operatorname{cov}(\bar X)
=\operatorname{cov}\left(\frac1n\sum_iX_i\right)
=\frac1{n^2}\sum_i\operatorname{cov}(X_i)
=\frac1n\Sigma.
$$

所以

$$
E[n(\bar X-\mu)(\bar X-\mu)^\top]=n\operatorname{cov}(\bar X)=\Sigma.
$$

因此

$$
E[(n-1)S]=n\Sigma-\Sigma=(n-1)\Sigma,
$$

即

$$
\boxed{E(S)=\Sigma}.
$$

成立条件：样本独立同分布且二阶矩存在。若分母用 $n$，期望为 $(n-1)\Sigma/n$，是有偏估计；但高斯模型下它对应极大似然估计。

### 习题 16.3

设 $X$ 为规范化样本矩阵，证明 PCA 等价于

$$
\min_L\lVert X-L\rVert_F
\quad\text{s.t.}\quad\operatorname{rank}(L)\le k.
$$

由第 15 章，令

$$
X'=\frac1{\sqrt{n-1}}X^\top=U\Sigma V^\top.
$$

则

$$
R=X'^\top X'=V\Sigma^\top\Sigma V^\top,
$$

所以 $V$ 的前 $k$ 列就是 PCA 的前 $k$ 个主方向。

PCA 对 $X$ 的秩 $k$ 重构为

$$
L=V_kV_k^\top X.
$$

另一方面，由 $X=\sqrt{n-1}\,V\Sigma^\top U^\top$，

$$
V_kV_k^\top X
=\sqrt{n-1}\,V_k\Sigma_k^\top U_k^\top,
$$

这恰好是 $X$ 的秩 $k$ 截断 SVD。

由第 15 章定理 15.3（Eckart-Young-Mirsky）：截断 SVD 是所有秩不超过 $k$ 矩阵中弗罗贝尼乌斯误差最小者。因此

$$
\boxed{\;
L^*=V_kV_k^\top X
=\arg\min_{\operatorname{rank}(L)\le k}\lVert X-L\rVert_F
\;}
$$

且最小误差满足

$$
\lVert X-L^*\rVert_F^2
=(n-1)\sum_{i=k+1}^{r}\lambda_i.
$$

这也从矩阵角度严格证明了本章开头的等价性：

$$
\text{最大化保留方差}\Longleftrightarrow\text{最小化平方重构误差}.
$$

---

## 第 16 章一句话回顾

PCA 从“变量相关导致信息重复”出发，对中心化或标准化数据寻找一组正交方向：第一个方向最大化 $a^\top\Sigma a$，后续方向在与已有方向正交的约束下依次最大化；拉格朗日乘子把这个问题化为协方差矩阵特征方程，因此主方向是降序单位特征向量、主成分方差是特征值、变换后协方差为对角矩阵，总方差只被重新分配而不改变。定理 16.2 保证前 $k$ 个主成分在所有 $k$ 维正交投影中保留方差最多，定理 16.3 等价地保证舍弃后面的方向损失最少；方差贡献率决定全局保留比例，因子负荷量 $\sqrt{\lambda_k}a_{ik}/\sqrt{\sigma_{ii}}$ 则解释单个变量与主成分的关系。实际样本中用 $S$ 或 $R$ 替代总体协方差，并可直接对 $X'=X^\top/\sqrt{n-1}$ 做 SVD，因为 $X'^\top X'=XX^\top/(n-1)$，其右奇异向量正是主方向；由第 15 章最优低秩定理，PCA 同时也是中心化数据在弗罗贝尼乌斯平方损失下的最优秩 $k$ 重构。它高效、闭式、可解释，但只捕捉线性高方差结构，并对尺度与离群点敏感。
