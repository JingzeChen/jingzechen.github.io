---
title: "《统计学习方法（第 2 版）》第 15 章：奇异值分解"
date: 2026-08-01 02:15:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch15-singular-value-decomposition
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch14-clustering, statistical-learning-methods-ch16-principal-component-analysis]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「奇异值分解」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

> 凡标注 **【补充】** 的内容为书外补充（背景知识、推导细节、辨析、代码实验等），请与原书内容区分。原书结论不作任何虚构或改写。

---

## 0. 本章解决什么问题

### 0.1 本章的定位

> **奇异值分解**（singular value decomposition，SVD）是一种**矩阵因子分解**方法，是**线性代数的概念**，但在统计学习中被广泛使用，成为其重要工具。本书介绍的**主成分分析、潜在语义分析**都用到奇异值分解。

**本章是纯粹的数学工具章**——它本身不是一个学习算法，而是为第 16 章（主成分分析）、第 17 章（潜在语义分析）打地基。

回到第 13 章 13.1.4 节的**矩阵分解统一视角**：

$$
X_{m\times n}\;\approx\;A_{m\times k}\cdot B_{k\times n},\qquad k\ll\min(m,n)
$$

第 13 章说过，"要求 $A$ 列正交、最小化重构误差"就得到 PCA/SVD。**本章要做的，就是把这句话完全说清楚**：这样的分解**存在吗**？**怎么算**？**为什么它是最优的**？

### 0.2 核心陈述

> 任意一个 $m\times n$ 矩阵，都可以表示为**三个矩阵的乘积（因子分解）形式**，分别是 **$m$ 阶正交矩阵**、由**降序排列的非负的对角线元素**组成的 **$m\times n$ 矩形对角矩阵**和 **$n$ 阶正交矩阵**，称为该矩阵的奇异值分解。矩阵的奇异值分解**一定存在，但不唯一**。奇异值分解可以看作是**矩阵数据压缩**的一种方法，即用因子分解的方式**近似地**表示原始矩阵，这种近似是在**平方损失意义下的最优近似**。

$$
\boxed{\;
A_{m\times n}=U_{m\times m}\;\Sigma_{m\times n}\;V^\top_{n\times n}
\;}
$$

这段话包含了全章的四个要点：

| 要点 | 在哪一节展开 |
| --- | --- |
| **一定存在** | 15.1.1 定理 15.1（构造性证明） |
| **但不唯一** | 15.1.1 例 15.1 给出两个不同的 $U$ |
| **怎么算** | 15.2 五步算法 + 例 15.5 |
| **是平方损失下的最优近似** | 15.3 定理 15.2、15.3 |

### 0.3 问题从哪来：从"方阵对角化"到"任意矩阵分解"

**线性代数里最漂亮的结果之一是实对称矩阵的谱定理**：

$$
S=Q\Lambda Q^\top,\qquad S^\top=S,\;Q\text{ 正交},\;\Lambda\text{ 对角}
$$

它把一个复杂的线性变换拆成"**旋转 → 沿坐标轴缩放 → 转回来**"。

**但这个结果的适用面太窄**：

| 限制 | 后果 |
| --- | --- |
| 必须是**方阵** | $5\times4$ 的数据矩阵完全用不上 |
| 必须**对称** | 绝大多数矩阵不对称 |

而机器学习中的数据矩阵 $X_{m\times n}$（第 13 章约定：行是特征、列是样本）**几乎从不是方阵，更不可能对称**。

$$
\boxed{\;
\text{SVD 要解决的问题：把"对角化"推广到任意 }m\times n\text{ 实矩阵}
\;}
$$

原书的这句话点明了这层关系：

> 注意奇异值分解**不要求矩阵 $A$ 是方阵**，事实上矩阵的奇异值分解可以看作是**方阵的对角化的推广**。

**难点在哪**【补充】：对角化 $S=Q\Lambda Q^\top$ 两边用的是**同一个** $Q$。这对非方阵根本讲不通——$A$ 把 $\mathbb R^n$ 里的向量送到 $\mathbb R^m$ 里，**输入空间和输出空间维数都不一样**，不可能用同一组基。

**突破口**：既然输入输出是两个空间，那就**用两组不同的正交基**——输入空间用 $V$（$n$ 阶），输出空间用 $U$（$m$ 阶）。这就是 $A=U\Sigma V^\top$ 中 $U\ne V$ 的根本原因。

### 0.4 全章的逻辑链条

```
   15.1.1 定义 15.1 + 定理 15.1（存在性，构造性证明）
          │  证明思路：A^T A 是对称的 -> 可对角化 -> 由它造出 V 和 Σ
          │            再令 u_j = (1/σ_j) A v_j 造出 U
          ↓
   15.1.2 紧 SVD（k = r，无损）与截断 SVD（k < r，有损）
          ↓
   15.1.3 几何解释：旋转 → 缩放 → 旋转
          ↓
   15.1.4 主要性质（A^TA、AA^T 的特征分解；奇异向量的关系；秩；四个子空间）
          ↓
   15.2   计算：把 15.1.1 的构造性证明变成算法（五步）
          ↓
   15.3.1 弗罗贝尼乌斯范数（= 平方损失）+ 引理 15.1：||A||_F = sqrt(Σσ²)
          ↓
   15.3.2 定理 15.2（最优近似存在）+ 定理 15.3（截断 SVD 就是那个最优解）
          ↓
   15.3.3 外积展开式：A = Σ σ_k u_k v_k^T，把 A 拆成秩 1 矩阵的加权和
```

$$
\boxed{\;
\text{15.1 说"存在"，15.2 说"怎么算"，15.3 说"为什么有用"}
\;}
$$

### 0.5 【补充】前置知识

#### （a）正交矩阵

$n$ 阶实矩阵 $Q$ 称为**正交矩阵**，若

$$
Q^\top Q=QQ^\top=I
$$

等价说法：**$Q$ 的列（也是行）构成 $\mathbb R^n$ 的一组标准正交基**。

**三条关键性质**（本章反复使用）：

| 性质 | 表达式 | 意义 |
| --- | --- | --- |
| 保内积 | $(Qx)^\top(Qy)=x^\top Q^\top Qy=x^\top y$ | 夹角不变 |
| **保长度** | $\lVert Qx\rVert=\lVert x\rVert$ | 不拉伸 |
| 行列式 | $\det Q=\pm1$ | $+1$ 是旋转，$-1$ 是反射 |

**保长度的证明**：$\lVert Qx\rVert^2=(Qx)^\top(Qx)=x^\top Q^\top Qx=x^\top x=\lVert x\rVert^2$ $\blacksquare$

$$
\boxed{\;
\text{正交矩阵 = 不改变形状的变换（只旋转/翻转，不拉伸）}
\;}
$$

**这正是 SVD 的设计意图**：把一个复杂变换里的"拉伸"部分**全部集中到 $\Sigma$ 上**，两边只剩不改变形状的正交变换。

#### （b）实对称矩阵的谱定理

若 $S\in\mathbb R^{n\times n}$ 且 $S^\top=S$，则

1. $S$ 的特征值**全是实数**
2. 存在**正交矩阵** $Q$ 使 $Q^\top SQ=\Lambda$ 为对角矩阵
3. $Q$ 的列是 $S$ 的标准正交特征向量

**定理 15.1 的证明完全建立在这条定理上**——因为 $A^\top A$ 总是对称的。

#### （c）矩阵的四个基本子空间

对 $A\in\mathbb R^{m\times n}$，$\operatorname{rank}(A)=r$：

| 子空间 | 定义 | 所在空间 | 维数 |
| --- | --- | --- | :---: |
| **列空间/值域** $R(A)$ | $\{Ax:x\in\mathbb R^n\}$ | $\mathbb R^m$ | $r$ |
| **零空间** $N(A)$ | $\{x:Ax=0\}$ | $\mathbb R^n$ | $n-r$ |
| **行空间** $R(A^\top)$ | $\{A^\top y:y\in\mathbb R^m\}$ | $\mathbb R^n$ | $r$ |
| **左零空间** $N(A^\top)$ | $\{y:A^\top y=0\}$ | $\mathbb R^m$ | $m-r$ |

**两组正交补关系**（原书 15.1.1 节和 15.1.4 节都用到，出处为原书附录 D）：

$$
R(A)^\perp=N(A^\top)\quad(\text{在 }\mathbb R^m\text{ 中}),\qquad
R(A^\top)^\perp=N(A)\quad(\text{在 }\mathbb R^n\text{ 中})
$$

$$
\boxed{\;
\text{SVD 的一大价值：}U\text{ 的列同时给出 }R(A)\text{ 与 }N(A^\top)\text{ 的标准正交基，}\\
V\text{ 的列同时给出 }R(A^\top)\text{ 与 }N(A)\text{ 的标准正交基}
\;}
$$

这就是 15.1.4 节性质 (5) 的内容。

---

## 15.1 奇异值分解的定义与性质

### 15.1.1 定义与定理

#### 定义 15.1

> **定义 15.1（奇异值分解）** 矩阵的奇异值分解是指，将一个**非零的** $m\times n$ **实矩阵** $A$，$A\in\mathbb R^{m\times n}$，表示为以下三个实矩阵乘积形式的运算，即进行矩阵的因子分解：

$$
A=U\Sigma V^\top
\tag{15.1}
$$

> 其中 $U$ 是 $m$ 阶**正交矩阵**（orthogonal matrix），$V$ 是 $n$ 阶正交矩阵，$\Sigma$ 是由**降序排列的非负的对角线元素**组成的 $m\times n$ **矩形对角矩阵**（rectangular diagonal matrix），满足

$$
UU^\top=I
$$
$$
VV^\top=I
$$
$$
\Sigma=\operatorname{diag}(\sigma_1,\sigma_2,\ldots,\sigma_p)
$$
$$
\sigma_1\ge\sigma_2\ge\cdots\ge\sigma_p\ge0
$$
$$
p=\min(m,n)
$$

> $U\Sigma V^\top$ 称为矩阵 $A$ 的**奇异值分解**，$\sigma_i$ 称为矩阵 $A$ 的**奇异值**（singular value），$U$ 的列向量称为**左奇异向量**（left singular vector），$V$ 的列向量称为**右奇异向量**（right singular vector）。

（原书脚注：奇异值分解可以更一般地定义在复数矩阵上，这里并不涉及。）

**符号与形状必须看清**：

| 符号 | 形状 | 性质 |
| --- | :---: | --- |
| $A$ | $m\times n$ | 任意非零实矩阵 |
| $U$ | $m\times m$ | **正交**（方阵） |
| $\Sigma$ | $m\times n$ | **矩形**对角，元素非负且降序 |
| $V$ | $n\times n$ | **正交**（方阵） |
| $\sigma_i$ | 标量 | 奇异值，$i=1,\ldots,p=\min(m,n)$ |

```
       A         =        U         ·        Σ         ·       V^T
    ┌──────┐          ┌────────┐        ┌──────┐         ┌────────┐
    │      │          │        │        │σ₁    │         │        │
  m │      │    =   m │        │    m   │  σ₂  │       n │        │
    │      │          │        │        │    ⋱ │         │        │
    └──────┘          └────────┘        └──────┘         └────────┘
       n                   m                n                 n
```

**【易混淆点 1】$\Sigma$ 一般不是方阵。**

当 $m>n$ 时，$\Sigma$ 下方有 $m-n$ 行全零；当 $m<n$ 时，右侧有 $n-m$ 列全零。原书例 15.5 特意强调："**注意在 $\Sigma$ 中要加上零行向量，使得 $\Sigma$ 能够与 $U$，$V$ 进行矩阵乘法运算。**"

**【易混淆点 2】"降序排列"是定义的一部分，不是附加约定。**

若不要求降序，分解就更不唯一（可以任意置换）。降序保证了"前 $k$ 个奇异值最大"，这是 15.3 节截断 SVD 最优性的前提。

#### 例 15.1

> **例 15.1** 给定一个 $5\times4$ 矩阵 $A$

$$
A=\begin{bmatrix}
1&0&0&0\\
0&0&0&4\\
0&3&0&0\\
0&0&0&0\\
2&0&0&0
\end{bmatrix}
$$

> 它的奇异值分解由三个矩阵的乘积 $U\Sigma V^\top$ 给出，矩阵 $U$，$\Sigma$，$V^\top$ 分别为

$$
U=\begin{bmatrix}
0&0&\sqrt{0.2}&0&\sqrt{0.8}\\
1&0&0&0&0\\
0&1&0&0&0\\
0&0&0&1&0\\
0&0&\sqrt{0.8}&0&-\sqrt{0.2}
\end{bmatrix}
$$

$$
\Sigma=\begin{bmatrix}
4&0&0&0\\
0&3&0&0\\
0&0&\sqrt5&0\\
0&0&0&0\\
0&0&0&0
\end{bmatrix},
\qquad
V^\top=\begin{bmatrix}
0&0&0&1\\
0&1&0&0\\
1&0&0&0\\
0&0&1&0
\end{bmatrix}
$$

> 矩阵 $\Sigma$ 是对角矩阵，对角线外的元素都是 0，对角线上的元素非负，按降序排列。矩阵 $U$ 和 $V$ 是正交矩阵，它们与各自的转置矩阵相乘是单位矩阵，即 $UU^\top=I_5$，$VV^\top=I_4$。

**代码验证**：$\lVert U\Sigma V^\top-A\rVert_F=0.00\times10^{0}$，$\max\lvert UU^\top-I\rvert=1.11\times10^{-16}$，$\max\lvert VV^\top-I\rvert=0$ ✅

**【补充】这个例子的数值为什么这么整齐**

因为 $A$ 的列两两正交！算一下：

$$
A^\top A=\operatorname{diag}(5,\;9,\;0,\;16)
$$

（$A$ 的四列分别是 $(1,0,0,0,2)^\top$、$(0,0,3,0,0)^\top$、$\mathbf0$、$(0,4,0,0,0)^\top$，两两内积全为 0。）

于是特征值按降序为 $16,9,5,0$，奇异值 $\sigma=\sqrt{16},\sqrt9,\sqrt5,0=4,3,\sqrt5,0$ ✅

**特征向量就是标准基向量**（因为 $A^\top A$ 已经是对角的），按特征值降序排列得

$$
V=[e_4,\;e_2,\;e_1,\;e_3]\;\Longrightarrow\;
V^\top=\begin{bmatrix}0&0&0&1\\0&1&0&0\\1&0&0&0\\0&0&1&0\end{bmatrix}\;✅
$$

这正是书中的 $V^\top$（**它只是一个置换矩阵**）。

#### 非唯一性

> 矩阵的奇异值分解**不是唯一的**。在此例中如果选择 $U$ 为

$$
U'=\begin{bmatrix}
0&0&\sqrt{0.2}&\sqrt{0.4}&-\sqrt{0.4}\\
1&0&0&0&0\\
0&1&0&0&0\\
0&0&0&\sqrt{0.5}&\sqrt{0.5}\\
0&0&\sqrt{0.8}&-\sqrt{0.1}&\sqrt{0.1}
\end{bmatrix}
$$

> 而 $\Sigma$ 与 $V$ 不变，那么 $U'\Sigma V^\top$ 也是 $A$ 的一个奇异值分解。

**代码验证**：$\lVert U'\Sigma V^\top-A\rVert_F=0$，$U'$ 也正交，且两个 $U$ 的最大逐元素差为 $1.5269$ ✅

**【补充】为什么可以随便换？关键在于 $\Sigma$ 的零行**

注意 $\Sigma$ 的**第 4、5 行全是 0**。在乘积 $U\Sigma$ 中，

$$
U\Sigma=\big[\;\sigma_1u_1\;\;\sigma_2u_2\;\;\sigma_3u_3\;\;\mathbf0\;\big]
$$

**$u_4,u_5$ 根本没有出现！** 它们乘的都是 $\Sigma$ 的零行。所以只要 $u_4,u_5$ 与 $u_1,u_2,u_3$ 正交、且彼此标准正交（保证 $U$ 仍是正交矩阵），随便怎么取都行。

对比两个 $U$：

| 列 | $U$ | $U'$ | 是否相同 |
| :---: | --- | --- | :---: |
| $u_1,u_2,u_3$ | 对应正奇异值 | 同左 | **完全相同** |
| $u_4,u_5$ | $N(A^\top)$ 的一组基 | $N(A^\top)$ 的**另一组**基 | 不同 |

$$
\boxed{\;
\text{对应正奇异值的左奇异向量由 }V\text{ 唯一确定（式 15.12）；}\\
\text{对应零奇异值的部分只要求张成 }N(A^\top)\text{，可任意选正交基}
\;}
$$

**这就是"奇异值唯一、$U$ 和 $V$ 不唯一"（15.1.4 节性质 3）的机制。**

**【补充】还有一种更普遍的不唯一性**：即使所有奇异值都是正的且互不相同，仍可以把 $u_j$ 和 $v_j$ **同时取反**：

$$
\sigma_j(-u_j)(-v_j)^\top=\sigma_ju_jv_j^\top
$$

分解不变。若某个奇异值**重复**（$\sigma_i=\sigma_j$），则对应的二维子空间内可以任意旋转，自由度更大。

#### 定理 15.1（奇异值分解基本定理）

> 任意给定一个实矩阵，其奇异值分解是否一定存在呢？答案是肯定的。

> **定理 15.1（奇异值分解基本定理）** 若 $A$ 为一 $m\times n$ 实矩阵，$A\in\mathbb R^{m\times n}$，则 $A$ 的奇异值分解存在

$$
A=U\Sigma V^\top
\tag{15.2}
$$

> 其中 $U$ 是 $m$ 阶正交矩阵，$V$ 是 $n$ 阶正交矩阵，$\Sigma$ 是 $m\times n$ 矩形对角矩阵，其对角线元素非负，且按降序排列。

**这是全章最重要的定理，而且它的证明是构造性的**——15.2 节的算法就是把这个证明逐字翻译成计算步骤。

> **证明** 证明是**构造性的**，对给定的矩阵 $A$，构造出其奇异值分解的各个矩阵。为了方便，不妨假设 $m\ge n$，如果 $m<n$ 证明仍然成立。证明由**三步**完成。

**证明的总体思路**【补充】：

```
   难点：A 不对称、不是方阵，无法直接对角化
                    ↓
   突破口：A^T A 一定是 n 阶实对称矩阵！
                    ↓
   第一步：对 A^T A 用谱定理 -> 得到 V（右奇异向量）和 Σ（奇异值 = 特征值开方）
                    ↓
   第二步：定义 u_j = (1/σ_j) A v_j -> 得到 U 的前 r 列；再补齐 N(A^T) 的基
                    ↓
   第三步：验证 UΣV^T = A
```

$$
\boxed{\;
\text{"把不对称的 }A\text{ 变成对称的 }A^\top A\text{" 是全部的关键}
\;}
$$

#### 证明第 (1) 步：确定 $V$ 和 $\Sigma$

> 首先构造 $n$ 阶正交实矩阵 $V$ 和 $m\times n$ 矩形对角实矩阵 $\Sigma$。
>
> 矩阵 $A$ 是 $m\times n$ 实矩阵，则矩阵 $A^\top A$ 是 **$n$ 阶实对称矩阵**。因而 $A^\top A$ 的特征值都是实数，并且存在一个 $n$ 阶正交实矩阵 $V$ 实现 $A^\top A$ 的对角化，使得 $V^\top(A^\top A)V=\Lambda$ 成立，其中 $\Lambda$ 是 $n$ 阶对角矩阵，其对角线元素由 $A^\top A$ 的特征值组成。

**为什么 $A^\top A$ 对称**：$(A^\top A)^\top=A^\top(A^\top)^\top=A^\top A$ ✅ 于是**谱定理适用**。

##### 特征值非负（式 15.3）

> 而且，$A^\top A$ 的特征值都是**非负**的。事实上，令 $\lambda$ 是 $A^\top A$ 的一个特征值，$x$ 是对应的特征向量，则
>
> $$\lVert Ax\rVert^2=x^\top A^\top Ax=\lambda x^\top x=\lambda\lVert x\rVert^2$$
>
> 于是

$$
\lambda=\frac{\lVert Ax\rVert^2}{\lVert x\rVert^2}\ge0
\tag{15.3}
$$

**逐步解读**：

| 等式 | 依据 |
| --- | --- |
| $\lVert Ax\rVert^2=(Ax)^\top(Ax)=x^\top A^\top Ax$ | 范数的定义 |
| $x^\top A^\top Ax=x^\top(\lambda x)=\lambda x^\top x$ | $x$ 是特征向量：$A^\top Ax=\lambda x$ |
| $x^\top x=\lVert x\rVert^2$ | 范数的定义 |
| $\lambda=\lVert Ax\rVert^2/\lVert x\rVert^2\ge0$ | 分子分母都非负，且 $x\ne0$ 故分母 $>0$ |

$$
\boxed{\;
\text{特征值非负 }\Rightarrow\text{ 可以开平方根 }\Rightarrow\text{ 奇异值有定义}
\;}
$$

**这一步是奇异值"非负"的全部来源**。

**代码验证**（例 15.1）：$\lambda_j=\lVert Av_j\rVert^2$ 分别为 $16,9,5,0$，全部 $\ge0$ ✅

##### 排序与开方

> 可以假设正交矩阵 $V$ 的列的排列使得对应的特征值形成**降序排列**
>
> $$\lambda_1\ge\lambda_2\ge\cdots\ge\lambda_n\ge0$$
>
> 计算特征值的平方根（实际就是矩阵 $A$ 的奇异值）
>
> $$\sigma_j=\sqrt{\lambda_j},\qquad j=1,2,\ldots,n$$

##### 秩的关系（式 15.4、15.5）

> 设矩阵 $A$ 的秩是 $r$，$\operatorname{rank}(A)=r$，则矩阵 $A^\top A$ 的秩也是 $r$。由于 $A^\top A$ 是对称矩阵，它的秩等于**正的特征值的个数**，所以

$$
\lambda_1\ge\lambda_2\ge\cdots\ge\lambda_r>0,\qquad\lambda_{r+1}=\lambda_{r+2}=\cdots=\lambda_n=0
\tag{15.4}
$$

> 对应地有

$$
\sigma_1\ge\sigma_2\ge\cdots\ge\sigma_r>0,\qquad\sigma_{r+1}=\sigma_{r+2}=\cdots=\sigma_n=0
\tag{15.5}
$$

**【补充】"$\operatorname{rank}(A^\top A)=\operatorname{rank}(A)$"的完整证明**

原书直接给出了这个结论，这里补上证明。

**只需证 $N(A^\top A)=N(A)$**（零空间相同），再用秩-零化度定理。

**"$\supseteq$" 方向**：若 $Ax=0$，则 $A^\top Ax=A^\top\mathbf0=\mathbf0$，故 $x\in N(A^\top A)$ ✅

**"$\subseteq$" 方向**：若 $A^\top Ax=0$，左乘 $x^\top$：

$$
0=x^\top A^\top Ax=(Ax)^\top(Ax)=\lVert Ax\rVert^2
$$

范数为零 $\Rightarrow Ax=\mathbf0$，故 $x\in N(A)$ ✅

于是 $N(A^\top A)=N(A)$，两者维数相同。由**秩-零化度定理**（$A$ 与 $A^\top A$ 都有 $n$ 列）：

$$
\operatorname{rank}(A^\top A)=n-\dim N(A^\top A)=n-\dim N(A)=\operatorname{rank}(A)=r\qquad\blacksquare
$$

**注意这个证明第二步用的正是式 (15.3) 的同一个技巧**：把 $x^\top A^\top Ax$ 变成 $\lVert Ax\rVert^2$。

##### 分块（式 15.6、15.7）

令

$$
V_1=[v_1\;\;v_2\;\cdots\;v_r],\qquad V_2=[v_{r+1}\;\;v_{r+2}\;\cdots\;v_n]
$$

（$V_1$ 是对应正特征值的特征向量，$V_2$ 是对应零特征值的特征向量），则

$$
V=[V_1\;\;V_2]
\tag{15.6}
$$

> 这就是矩阵 $A$ 的奇异值分解中的 $n$ 阶正交矩阵 $V$。

令 $\Sigma_1=\operatorname{diag}(\sigma_1,\ldots,\sigma_r)$（$r$ 阶对角矩阵，对角线是**正**的奇异值），则 $m\times n$ 矩形对角矩阵 $\Sigma$ 可表为

$$
\Sigma=\begin{bmatrix}\Sigma_1&0\\0&0\end{bmatrix}
\tag{15.7}
$$

##### 关键引理：$AV_2=0$（式 15.8~15.11）

> 下面推出后面要用到的一个公式。在式 (15.6) 中，$V_2$ 的列向量是 $A^\top A$ 对应于特征值为 0 的特征向量。因此

$$
A^\top Av_j=0,\qquad j=r+1,\ldots,n
\tag{15.8}
$$

> 于是，$V_2$ 的列向量构成了 $A^\top A$ 的零空间 $N(A^\top A)$，而 $N(A^\top A)=N(A)$。所以 $V_2$ 的列向量构成 $A$ 的零空间的一组标准正交基。因此，

$$
AV_2=0
\tag{15.9}
$$

**注意这里正是用上了刚才证明的 $N(A^\top A)=N(A)$。**

> 由于 $V$ 是正交矩阵，由式 (15.6) 可得

$$
I=VV^\top=V_1V_1^\top+V_2V_2^\top
\tag{15.10}
$$

$$
A=AI=AV_1V_1^\top+AV_2V_2^\top=AV_1V_1^\top
\tag{15.11}
$$

**式 (15.10) 的依据**【补充】：分块矩阵乘法

$$
VV^\top=[V_1\;\;V_2]\begin{bmatrix}V_1^\top\\V_2^\top\end{bmatrix}=V_1V_1^\top+V_2V_2^\top
$$

**式 (15.11) 的依据**：把式 (15.10) 代入 $A=AI$，再用式 (15.9) 的 $AV_2=0$ 消掉第二项 ✅

$$
\boxed{\;
\text{式 (15.11) 的含义：}A\text{ 的全部信息只装在 }V_1\text{ 张成的 }r\text{ 维子空间上}
\;}
$$

**代码验证**（例 15.1，$r=3$）：$\lVert AV_2\rVert_F=0$，$\lVert A-AV_1V_1^\top\rVert_F=0$，$\max\lvert I-(V_1V_1^\top+V_2V_2^\top)\rvert=0$ ✅

#### 证明第 (2) 步：确定 $U$

> 接着构造 $m$ 阶正交实矩阵 $U$。令

$$
u_j=\frac{1}{\sigma_j}Av_j,\qquad j=1,2,\ldots,r
\tag{15.12}
$$

$$
U_1=[u_1\;\;u_2\;\cdots\;u_r]
\tag{15.13}
$$

> 则有

$$
AV_1=U_1\Sigma_1
\tag{15.14}
$$

**式 (15.14) 就是式 (15.12) 的矩阵写法**：$Av_j=\sigma_ju_j$，把 $j=1,\ldots,r$ 并排即得 ✅

**注意 $\sigma_j>0$（$j\le r$）保证了式 (15.12) 的除法有意义**——这就是为什么要先按式 (15.4)(15.5) 分出正奇异值。

##### $U_1$ 的列标准正交（式 15.15）

> $U_1$ 的列向量构成了一组标准正交集，因为

$$
u_i^\top u_j=\left(\frac{1}{\sigma_i}Av_i\right)^\top\left(\frac{1}{\sigma_j}Av_j\right)
=\frac{1}{\sigma_i\sigma_j}v_i^\top A^\top Av_j
=\frac{\sigma_j}{\sigma_i}v_i^\top v_j=\delta_{ij}
\tag{15.15}
$$

> $i=1,2,\ldots,r$；$j=1,2,\ldots,r$

**【补充】把这个推导每一步的依据写清楚**

$$
\begin{aligned}
u_i^\top u_j
&=\frac{1}{\sigma_i\sigma_j}(Av_i)^\top(Av_j)&&\text{代入式 (15.12)}\\
&=\frac{1}{\sigma_i\sigma_j}v_i^\top A^\top Av_j&&(Ax)^\top(Ay)=x^\top A^\top Ay\\
&=\frac{1}{\sigma_i\sigma_j}v_i^\top(\lambda_jv_j)&&v_j\text{ 是 }A^\top A\text{ 的特征向量}\\
&=\frac{\lambda_j}{\sigma_i\sigma_j}v_i^\top v_j&&\text{提出标量}\\
&=\frac{\sigma_j^2}{\sigma_i\sigma_j}v_i^\top v_j=\frac{\sigma_j}{\sigma_i}v_i^\top v_j&&\lambda_j=\sigma_j^2\\
&=\frac{\sigma_j}{\sigma_i}\delta_{ij}=\delta_{ij}&&V\text{ 正交故 }v_i^\top v_j=\delta_{ij}\text{；}i=j\text{ 时 }\sigma_j/\sigma_i=1
\end{aligned}
$$

$\blacksquare$

$$
\boxed{\;
\text{"}u_j\text{ 标准正交"是白送的 —— 它直接来自"}v_j\text{ 标准正交"与"}\sigma_j\text{ 是归一化因子"}
\;}
$$

**这正是式 (15.12) 里为什么要除以 $\sigma_j$**：不除的话 $\lVert Av_j\rVert=\sigma_j\ne1$，就不是单位向量了。

##### 补齐 $U_2$（式 15.16）

> 由式 (15.12) 和式 (15.15) 可知，$u_1,u_2,\ldots,u_r$ 构成 $A$ 的**列空间**的一组标准正交基，列空间的维数为 $r$。如果将 $A$ 看成是从 $\mathbb R^n$ 到 $\mathbb R^m$ 的线性变换，则 $A$ 的列空间和 $A$ 的**值域** $R(A)$ 是相同的。因此 $u_1,u_2,\ldots,u_r$ 也是 $R(A)$ 的一组标准正交基。
>
> 若 $R(A)^\perp$ 表示 $R(A)$ 的正交补，则有 $R(A)$ 的维数为 $r$，$R(A)^\perp$ 的维数为 $m-r$，两者的维数之和等于 $m$。而且有 $R(A)^\perp=N(A^\top)$ 成立。（原书脚注：参照附录 D。）
>
> 令 $\{u_{r+1},u_{r+2},\ldots,u_m\}$ 为 $N(A^\top)$ 的一组标准正交基，并令

$$
U_2=[u_{r+1}\;\;u_{r+2}\;\cdots\;u_m],\qquad U=[U_1\;\;U_2]
\tag{15.16}
$$

> 则 $u_1,u_2,\ldots,u_m$ 构成了 $\mathbb R^m$ 的一组标准正交基。因此，$U$ 是 $m$ 阶正交矩阵。

**为什么可以"令 $U_2$ 是 $N(A^\top)$ 的标准正交基"就万事大吉**【补充】：

- $U_1$ 的列张成 $R(A)$，$U_2$ 的列张成 $R(A)^\perp=N(A^\top)$
- 两个**互为正交补**的子空间，其基自然互相正交
- 维数 $r+(m-r)=m$，恰好凑满 $\mathbb R^m$

所以 $U=[U_1\;U_2]$ 是 $m$ 阶正交矩阵 ✅

**这一步同时揭示了非唯一性的来源**：$N(A^\top)$ 的标准正交基**有无穷多组**（当 $m-r\ge2$ 时可以任意旋转），所以 $U$ 不唯一——正是例 15.1 中两个 $U$ 的差别所在。

**代码验证**（例 15.1）：$\max\lvert U_1^\top U_1-I\rvert=1.11\times10^{-16}$，$\lVert A^\top U_2\rVert_F=1.11\times10^{-16}$ ✅

#### 证明第 (3) 步：验证 $U\Sigma V^\top=A$（式 15.17）

> 由式 (15.6)、式 (15.7)、式 (15.11)、式 (15.14) 和式 (15.16) 得

$$
\begin{aligned}
U\Sigma V^\top
&=[U_1\;\;U_2]\begin{bmatrix}\Sigma_1&0\\0&0\end{bmatrix}\begin{bmatrix}V_1^\top\\V_2^\top\end{bmatrix}\\
&=U_1\Sigma_1V_1^\top\\
&=AV_1V_1^\top\\
&=A
\end{aligned}
\tag{15.17}
$$

> 至此证明了矩阵 $A$ 存在奇异值分解。

**每一步的依据**：

| 步骤 | 依据 |
| --- | --- |
| $[U_1\;U_2]\begin{bmatrix}\Sigma_1&0\\0&0\end{bmatrix}\begin{bmatrix}V_1^\top\\V_2^\top\end{bmatrix}=U_1\Sigma_1V_1^\top$ | 分块矩阵乘法；$\Sigma$ 的零块把 $U_2,V_2$ 全部消掉 |
| $U_1\Sigma_1=AV_1$ | **式 (15.14)** |
| $AV_1V_1^\top=A$ | **式 (15.11)** |

$\blacksquare$

$$
\boxed{\;
\text{整个证明只用了两个工具：实对称矩阵的谱定理 + 正交性的定义}
\;}
$$

**代码验证**：$\lVert U\Sigma V^\top-A\rVert_F=0$ ✅

**【补充】这个证明的"可操作性"**

证明的三步**完全可以照抄成程序**：

| 证明步骤 | 对应的计算 |
| --- | --- |
| (1) 对 $A^\top A$ 用谱定理 | 求对称矩阵的特征值/特征向量 |
| (1) $\sigma_j=\sqrt{\lambda_j}$ | 开平方根、降序排列 |
| (2) $u_j=\frac{1}{\sigma_j}Av_j$ | 矩阵-向量乘法 + 缩放 |
| (2) 补齐 $N(A^\top)$ 的基 | Gram-Schmidt 正交化 |
| (3) 组装 | 拼矩阵 |

**15.2 节的算法就是这张表**。这也是原书说"奇异值分解基本定理证明的过程蕴含了奇异值分解的计算方法"的意思。

---

### 15.1.2 紧奇异值分解与截断奇异值分解

> 定理 15.1 给出的奇异值分解 $A=U\Sigma V^\top$ 又称为矩阵的**完全奇异值分解**（full singular value decomposition）。实际常用的是奇异值分解的**紧凑形式**和**截断形式**。**紧奇异值分解是与原始矩阵等秩的奇异值分解，截断奇异值分解是比原始矩阵低秩的奇异值分解。**

**动机**【补充】：完全 SVD 里有大量"白算"的部分。以例 15.1 为例（$m=5,n=4,r=3$）：

- $U$ 是 $5\times5$，但只有前 3 列真正参与（$u_4,u_5$ 乘的是 $\Sigma$ 的零行）
- $V$ 是 $4\times4$，但只有前 3 列参与
- $\Sigma$ 是 $5\times4=20$ 个数，其中只有 3 个非零

$$
\boxed{\;
\text{完全 SVD 存了 }25+20+16=61\text{ 个数；紧 SVD 只需 }15+3+12=30\text{ 个}
\;}
$$

#### 1. 紧奇异值分解

> **定义 15.2** 设有 $m\times n$ 实矩阵 $A$，其秩为 $\operatorname{rank}(A)=r$，$r\le\min(m,n)$，则称 $U_r\Sigma_rV_r^\top$ 为 $A$ 的**紧奇异值分解**（compact singular value decomposition），即

$$
A=U_r\Sigma_rV_r^\top
\tag{15.18}
$$

> 其中 $U_r$ 是 $m\times r$ 矩阵，$V_r$ 是 $n\times r$ 矩阵，$\Sigma_r$ 是 $r$ 阶对角矩阵；矩阵 $U_r$ 由完全奇异值分解中 $U$ 的**前 $r$ 列**、矩阵 $V_r$ 由 $V$ 的**前 $r$ 列**、矩阵 $\Sigma_r$ 由 $\Sigma$ 的**前 $r$ 个对角线元素**得到。**紧奇异值分解的对角矩阵 $\Sigma_r$ 的秩与原始矩阵 $A$ 的秩相等。**

**注意式 (15.18) 用的是等号"$=$"**——紧 SVD 是**精确的**，不是近似。

#### 例 15.2

> **例 15.2** 由例 15.1 给出的矩阵 $A$ 的秩 $r=3$，$A$ 的紧奇异值分解是 $A=U_r\Sigma_rV_r^\top$，其中

$$
U_r=\begin{bmatrix}
0&0&\sqrt{0.2}\\
1&0&0\\
0&1&0\\
0&0&0\\
0&0&\sqrt{0.8}
\end{bmatrix},
\qquad
\Sigma_r=\begin{bmatrix}4&0&0\\0&3&0\\0&0&\sqrt5\end{bmatrix},
\qquad
V_r=\begin{bmatrix}
0&0&1\\
0&1&0\\
0&0&0\\
1&0&0
\end{bmatrix}
$$

**代码验证**：$\lVert U_r\Sigma_rV_r^\top-A\rVert_F=0.00\times10^{0}$ ✅ **完全无损**。

#### 2. 截断奇异值分解

> 在矩阵的奇异值分解中，**只取最大的 $k$ 个奇异值**（$k<r$，$r$ 为矩阵的秩）对应的部分，就得到矩阵的截断奇异值分解。**实际应用中提到矩阵的奇异值分解时，通常指截断奇异值分解。**

> **定义 15.3** 设 $A$ 为 $m\times n$ 实矩阵，其秩 $\operatorname{rank}(A)=r$，且 $0<k<r$，则称 $U_k\Sigma_kV_k^\top$ 为矩阵 $A$ 的**截断奇异值分解**（truncated singular value decomposition）

$$
A\approx U_k\Sigma_kV_k^\top
\tag{15.19}
$$

> 其中 $U_k$ 是 $m\times k$ 矩阵，$V_k$ 是 $n\times k$ 矩阵，$\Sigma_k$ 是 $k$ 阶对角矩阵；矩阵 $U_k$ 由完全奇异值分解中 $U$ 的前 $k$ 列、矩阵 $V_k$ 由 $V$ 的前 $k$ 列、矩阵 $\Sigma_k$ 由 $\Sigma$ 的前 $k$ 个对角线元素得到。**对角矩阵 $\Sigma_k$ 的秩比原始矩阵 $A$ 的秩低。**

**【易混淆点 3】式 (15.19) 用的是约等号"$\approx$"**——截断 SVD 是**近似**。

| | 紧 SVD | 截断 SVD |
| --- | --- | --- |
| 取几个奇异值 | 全部 $r$ 个正奇异值 | 最大的 $k$ 个（$k<r$） |
| 关系符 | $=$（**精确**） | $\approx$（**近似**） |
| 秩 | 与 $A$ **相等** | 比 $A$ **低** |
| 压缩类型 | **无损压缩** | **有损压缩** |
| 误差 | $0$ | $\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}$（定理 15.3） |

#### 例 15.3

> **例 15.3** 由例 15.1 所给出的矩阵 $A$ 的秩为 3，若取 $k=2$ 则其截断奇异值分解是 $A\approx A_2=U_2\Sigma_2V_2^\top$，其中

$$
U_2=\begin{bmatrix}0&0\\1&0\\0&1\\0&0\\0&0\end{bmatrix},\quad
\Sigma_2=\begin{bmatrix}4&0\\0&3\end{bmatrix},\quad
V_2=\begin{bmatrix}0&0\\0&1\\0&0\\1&0\end{bmatrix}
$$

$$
A_2=U_2\Sigma_2V_2^\top=\begin{bmatrix}
0&0&0&0\\
0&0&0&4\\
0&3&0&0\\
0&0&0&0\\
0&0&0&0
\end{bmatrix}
$$

> 这里的 $U_2$，$V_2$ 是例 15.1 的 $U$ 和 $V$ 的前 2 列，$\Sigma_2$ 是 $\Sigma$ 的前 2 行前 2 列。$A_2$ 与 $A$ 比较，**$A$ 的元素 1 和 2 在 $A_2$ 中均变成 0**。

**代码验证**：$A_2[1][1]=0.0$，$A_2[5][1]=0.0$（原本是 1 和 2）✅ 近似误差 $\lVert A-A_2\rVert_F=2.236068=\sqrt5=\sigma_3$ ✅

**为什么恰好丢掉的是 1 和 2**【补充】：这两个元素都在 $A$ 的**第 1 列**上，而第 1 列对应的奇异值恰好是 $\sigma_3=\sqrt5$（最小的正奇异值）。截断掉第 3 个奇异值，就等于把这一列整个抹掉。

> 在实际应用中，常常需要对矩阵的数据进行压缩，将其近似表示，奇异值分解提供了一种方法。后面将要叙述，**奇异值分解是在平方损失（弗罗贝尼乌斯范数）意义下对矩阵的最优近似。紧奇异值分解对应着无损压缩，截断奇异值分解对应着有损压缩。**

### 15.1.3 几何解释

> 从**线性变换**的角度理解奇异值分解，$m\times n$ 矩阵 $A$ 表示从 $\mathbb R^n$ 到 $\mathbb R^m$ 的一个线性变换，
>
> $$T:x\to Ax$$
>
> $x\in\mathbb R^n$，$Ax\in\mathbb R^m$，$x$ 和 $Ax$ 分别是各自空间的向量。线性变换可以分解为**三个简单的变换：一个坐标系的旋转或反射变换、一个坐标轴的缩放变换、另一个坐标系的旋转或反射变换。** 奇异值定理保证这种分解一定存在。这就是奇异值分解的几何解释。

> 对矩阵 $A$ 进行奇异值分解，得到 $A=U\Sigma V^\top$，$V$ 和 $U$ 都是正交矩阵，所以：
>
> - $V$ 的列向量 $v_1,v_2,\ldots,v_n$ 构成 $\mathbb R^n$ 空间的一组标准正交基，表示 $\mathbb R^n$ 中的**正交坐标系的旋转或反射变换**；
> - $U$ 的列向量 $u_1,u_2,\ldots,u_m$ 构成 $\mathbb R^m$ 空间的一组标准正交基，表示 $\mathbb R^m$ 中的**正交坐标系的旋转或反射变换**；
> - $\Sigma$ 的对角元素 $\sigma_1,\sigma_2,\ldots,\sigma_n$ 是一组非负实数，表示 $\mathbb R^n$ 中的原始正交坐标系坐标轴的 $\sigma_1,\sigma_2,\ldots,\sigma_n$ 倍的**缩放变换**。

> 任意一个向量 $x\in\mathbb R^n$，经过基于 $A=U\Sigma V^\top$ 的线性变换，等价于经过**坐标系的旋转或反射变换 $V^\top$、坐标轴的缩放变换 $\Sigma$、以及坐标系的旋转或反射变换 $U$**，得到向量 $Ax\in\mathbb R^m$。

#### 图 15.1 的示意

```
     原始空间 R^n              旋转 V^T             缩放 Σ              旋转 U

        v₂ ↑                    e₂ ↑                  ↑                   ↗
           │  ○ ○ ○                │ ○ ○ ○            │   ○                  ○
        ───┼───→ v₁          ──────┼──────→      ─────┼─────→          ↗   ○   ↘
           │  单位圆               │  单位圆          │ 半轴 σ₁,σ₂         椭圆
                                                                  （方向由 u₁,u₂ 决定）

     ①把 v₁,v₂ 转成坐标轴  ②沿坐标轴按 σ₁,σ₂ 拉伸  ③再转到 u₁,u₂ 的方向
```

$$
\boxed{\;
\text{SVD 的几何本质：任何线性变换都可以拆成"转 → 拉 → 转"}\\
\text{单位球}\;\xrightarrow{\;A\;}\;\text{椭球，椭球的半轴长恰好是奇异值 }\sigma_i
\;}
$$

**为什么这是"椭球"**【补充】：单位球 $\lVert x\rVert=1$。因为 $V^\top$ 保长度，$V^\top x$ 仍在单位球上；$\Sigma$ 把第 $i$ 个坐标轴方向拉伸 $\sigma_i$ 倍，单位球变成半轴为 $\sigma_1,\ldots,\sigma_p$ 的椭球；$U$ 再把这个椭球整体旋转/反射（不改变形状）。

**这也解释了 $\sigma_1$ 的含义**：$\sigma_1=\max_{\lVert x\rVert=1}\lVert Ax\rVert$，即 $A$ 能把单位向量**最多拉伸多少倍**（这就是矩阵的**谱范数**）。

#### 例 15.4

> **例 15.4** 给定一个 2 阶矩阵
>
> $$A=\begin{bmatrix}3&1\\2&1\end{bmatrix}$$
>
> 其奇异值分解为

$$
U=\begin{bmatrix}0.8174&-0.5760\\0.5760&0.8174\end{bmatrix},\quad
\Sigma=\begin{bmatrix}3.8643&0\\0&0.2588\end{bmatrix},\quad
V^\top=\begin{bmatrix}0.9327&0.3606\\-0.3606&0.9327\end{bmatrix}
$$

> 观察基于矩阵 $A$ 的奇异值分解将 $\mathbb R^2$ 的标准正交基 $e_1=\begin{bmatrix}1\\0\end{bmatrix}$，$e_2=\begin{bmatrix}0\\1\end{bmatrix}$ 进行线性转换的情况。

**第一步：$V^\top$ 表示一个旋转变换**

$$
V^\top e_1=\begin{bmatrix}0.9327\\-0.3606\end{bmatrix},\qquad
V^\top e_2=\begin{bmatrix}0.3606\\0.9327\end{bmatrix}
$$

**第二步：$\Sigma$ 表示一个缩放变换**，将向量在坐标轴方向缩放 $\sigma_1$ 倍和 $\sigma_2$ 倍

$$
\Sigma V^\top e_1=\begin{bmatrix}3.6042\\-0.0933\end{bmatrix},\qquad
\Sigma V^\top e_2=\begin{bmatrix}1.3935\\0.2414\end{bmatrix}
$$

**验算**：$3.8643\times0.9327=3.6042$ ✅，$0.2588\times(-0.3606)=-0.0933$ ✅

**第三步：$U$ 表示一个旋转变换**

$$
U\Sigma V^\top e_1=Ae_1=\begin{bmatrix}3\\2\end{bmatrix},\qquad
U\Sigma V^\top e_2=Ae_2=\begin{bmatrix}1\\1\end{bmatrix}
$$

（$Ae_1$、$Ae_2$ 就是 $A$ 的第 1、2 列 ✅）

> 综上，矩阵的奇异值分解也可以看作是将其对应的**线性变换分解为旋转变换、缩放变换及旋转变换的组合**。根据定理 15.1，这个变换的组合一定存在。

**代码验证**（三步逐一跟踪）：

| | $V^\top e$ | $\Sigma V^\top e$ | $U\Sigma V^\top e$ | 直接 $Ae$ | 差 |
| --- | --- | --- | --- | --- | ---: |
| $e_1$ | $(+0.9327,-0.3606)$ | $(+3.6042,-0.0933)$ | $(+2.9999,+1.9998)$ | $(3,2)$ | $2.44\times10^{-4}$ |
| $e_2$ | $(+0.3606,+0.9327)$ | $(+1.3935,+0.2414)$ | $(+1.0000,+0.9999)$ | $(1,1)$ | $5.70\times10^{-5}$ |

**注意误差不是 0，而是 $10^{-4}$ 量级**——这是因为**书中的 $U,\Sigma,V^\top$ 只保留了 4 位小数**。同样地，$\lVert V^\top e_1\rVert=0.999981$ 而非严格的 $1$。这是舍入造成的，不是分解错误。

**代码还验证了**：$\det U=+0.999919$，$\det(V^\top)=+0.999962$，都约为 $+1$ ⟹ 两个正交变换都是**旋转**（不含反射）✅

### 15.1.4 主要性质

#### 性质 (1)：$A^\top A$ 与 $AA^\top$ 的特征分解（式 15.20、15.21）

> 设矩阵 $A$ 的奇异值分解为 $A=U\Sigma V^\top$，则以下关系成立：

$$
A^\top A=(U\Sigma V^\top)^\top(U\Sigma V^\top)=V(\Sigma^\top\Sigma)V^\top
\tag{15.20}
$$

$$
AA^\top=(U\Sigma V^\top)(U\Sigma V^\top)^\top=U(\Sigma\Sigma^\top)U^\top
\tag{15.21}
$$

**【补充】推导式 (15.20)**

$$
\begin{aligned}
A^\top A&=(U\Sigma V^\top)^\top(U\Sigma V^\top)\\
&=V\Sigma^\top U^\top\cdot U\Sigma V^\top&&(XYZ)^\top=Z^\top Y^\top X^\top\\
&=V\Sigma^\top(U^\top U)\Sigma V^\top&&\text{结合律}\\
&=V\Sigma^\top I\Sigma V^\top=V(\Sigma^\top\Sigma)V^\top&&U\text{ 正交}
\end{aligned}
$$

**式 (15.21) 同理**，只是这次消掉的是 $V^\top V=I$。

$$
\boxed{\;
\text{关键就一步：正交矩阵在中间"自我抵消"}
\;}
$$

> 也就是说，矩阵 $A^\top A$ 和 $AA^\top$ 的**特征分解存在**，且可以由矩阵 $A$ 的奇异值分解的矩阵表示。**$V$ 的列向量是 $A^\top A$ 的特征向量，$U$ 的列向量是 $AA^\top$ 的特征向量，$\Sigma$ 的奇异值是 $A^\top A$ 和 $AA^\top$ 的特征值的平方根。**

**$\Sigma^\top\Sigma$ 与 $\Sigma\Sigma^\top$ 的形状**【补充】：

| | 形状 | 对角元 |
| --- | :---: | --- |
| $\Sigma^\top\Sigma$ | $n\times n$ | $\sigma_1^2,\ldots,\sigma_p^2$，其余补 0 |
| $\Sigma\Sigma^\top$ | $m\times m$ | $\sigma_1^2,\ldots,\sigma_p^2$，其余补 0 |

**所以 $A^\top A$ 和 $AA^\top$ 的非零特征值完全相同**（都是 $\sigma_i^2$），只是零特征值的个数不同。

**代码验证**（例 15.1）：$\lVert A^\top A-V(\Sigma^\top\Sigma)V^\top\rVert_F=8.88\times10^{-16}$，$\lVert AA^\top-U(\Sigma\Sigma^\top)U^\top\rVert_F=1.11\times10^{-15}$ ✅
$A^\top A$ 的特征值 $=16,9,5,0$，奇异值平方 $=16,9,5,0$ ✅

#### 性质 (2)：奇异值与奇异向量的关系（式 15.22~15.24）

> 由 $A=U\Sigma V^\top$ 易知 $AV=U\Sigma$。比较这一等式两端的第 $j$ 列，得到

$$
Av_j=\sigma_ju_j,\qquad j=1,2,\ldots,n
\tag{15.22}
$$

> 这是矩阵 $A$ 的右奇异向量和奇异值、左奇异向量的关系。
>
> 类似地，由 $A^\top U=V\Sigma^\top$ 得到

$$
A^\top u_j=\sigma_jv_j,\qquad j=1,2,\ldots,n
\tag{15.23}
$$

$$
A^\top u_j=0,\qquad j=n+1,n+2,\ldots,m
\tag{15.24}
$$

> 这是矩阵 $A$ 的左奇异向量和奇异值、右奇异向量的关系。

**式 (15.22) 的推导**【补充】：由 $A=U\Sigma V^\top$ 右乘 $V$（$V^\top V=I$）：

$$
AV=U\Sigma V^\top V=U\Sigma
$$

$AV$ 的第 $j$ 列是 $Av_j$；$U\Sigma$ 的第 $j$ 列是 $\sigma_ju_j$（因为 $\Sigma$ 的第 $j$ 列只有第 $j$ 个元素 $\sigma_j$ 非零）✅

**式 (15.24) 为什么会出现**：$\Sigma^\top$ 是 $n\times m$，当 $j>n$ 时它的第 $j$ 列全为零，故 $A^\top u_j=0$。这正说明 **$u_{n+1},\ldots,u_m$ 落在 $N(A^\top)$ 里**。

**式 (15.22) 与 (15.23) 合起来的意思**【补充】：

$$
\boxed{\;
v_j\;\xrightarrow{\;A\;}\;\sigma_ju_j\;\xrightarrow{\;A^\top\;}\;\sigma_j^2v_j
\;}
$$

即 $A^\top Av_j=\sigma_j^2v_j$——**回到了特征方程**，与式 (15.20) 一致 ✅

**代码验证**（例 15.1）：式 (15.22) 对 $j=1,2,3,4$ 的最大误差均为 $0$；式 (15.23) 对 $j=1,\ldots,4$ 误差 $\le1.11\times10^{-16}$；式 (15.24) 对 $j=5$ 得 $\max\lvert A^\top u_5\rvert=0$ ✅

#### 性质 (3)：唯一性

> 矩阵 $A$ 的奇异值分解中，**奇异值 $\sigma_1,\sigma_2,\ldots,\sigma_n$ 是唯一的**，而矩阵 $U$ 和 $V$ **不是唯一的**。

**为什么奇异值唯一**【补充】：由式 (15.20)，$\sigma_j^2$ 是 $A^\top A$ 的特征值。而**矩阵的特征值集合是唯一确定的**（是特征多项式的根），故 $\sigma_j=\sqrt{\lambda_j}$ 唯一（加上降序排列的约定，顺序也唯一）✅

**为什么 $U,V$ 不唯一**：见 15.1.1 节例 15.1 的讨论（三种自由度：零奇异值对应的基可任选、$u_j$ 与 $v_j$ 可同时变号、重复奇异值对应的子空间可任意旋转）。

#### 性质 (4)：秩

> 矩阵 $A$ 和 $\Sigma$ 的**秩相等**，等于**正奇异值 $\sigma_i$ 的个数 $r$**（包含重复的奇异值）。

$$
\boxed{\;
\operatorname{rank}(A)=\#\{i:\sigma_i>0\}
\;}
$$

**为什么**【补充】：$U,V$ 可逆（正交矩阵），左乘/右乘可逆矩阵**不改变秩**，故 $\operatorname{rank}(A)=\operatorname{rank}(U\Sigma V^\top)=\operatorname{rank}(\Sigma)$。而对角矩阵的秩就是非零对角元的个数 ✅

**这是 SVD 一个极其实用的性质**：**判断秩最可靠的方法就是数正奇异值**。（用高斯消元判断秩在浮点运算下很不稳定，而奇异值给出了"离奇异有多远"的定量刻画。）

**代码验证**（例 15.1）：正奇异值个数 $=3=\operatorname{rank}(A)$ ✅

#### 性质 (5)：四个基本子空间的标准正交基

> - 矩阵 $A$ 的 $r$ 个**右奇异向量** $v_1,v_2,\ldots,v_r$ 构成 $A^\top$ 的值域 $R(A^\top)$ 的一组标准正交基。
> - 矩阵 $A$ 的 $n-r$ 个右奇异向量 $v_{r+1},v_{r+2},\ldots,v_n$ 构成 $A$ 的零空间 $N(A)$ 的一组标准正交基。
> - 矩阵 $A$ 的 $r$ 个**左奇异向量** $u_1,u_2,\ldots,u_r$ 构成值域 $R(A)$ 的一组标准正交基。
> - 矩阵 $A$ 的 $m-r$ 个左奇异向量 $u_{r+1},u_{r+2},\ldots,u_m$ 构成 $A^\top$ 的零空间 $N(A^\top)$ 的一组标准正交基。

$$
\boxed{\;
\text{一次 SVD，同时给出四个基本子空间的标准正交基}
\;}
$$

```
        R^n （输入空间，n 维）              R^m （输出空间，m 维）

    ┌──────────────────────┐          ┌──────────────────────┐
    │  R(A^T)   由 v₁..v_r │  ──A──→  │  R(A)     由 u₁..u_r │
    │  维数 r              │          │  维数 r              │
    ├──────────────────────┤          ├──────────────────────┤
    │  N(A)   由 v_{r+1}.. │  ──A──→  │        0             │
    │  维数 n-r            │          │                      │
    └──────────────────────┘          │  N(A^T) 由 u_{r+1}.. │
                                      │  维数 m-r            │
                                      └──────────────────────┘

    A 把 R(A^T) 一一对应到 R(A)（v_j ↦ σ_j u_j，σ_j > 0）
    A 把 N(A) 整个压成 0
    N(A^T) 是 A 够不到的部分
```

**代码验证**（例 15.1，$m=5,n=4,r=3$）：

| 子空间 | 由谁张成 | 维数 | 校验 |
| --- | --- | :---: | --- |
| $R(A)$ | $u_1,u_2,u_3$ | 3 | — |
| $N(A^\top)$ | $u_4,u_5$ | 2 | $\lVert A^\top U_2\rVert_F=1.11\times10^{-16}$ ✅ |
| $R(A^\top)$ | $v_1,v_2,v_3$ | 3 | — |
| $N(A)$ | $v_4$ | 1 | $\lVert AV_2\rVert_F=0$ ✅ |

维数校验：$3+2=5=m$ ✅，$3+1=4=n$ ✅

---

## 15.2 奇异值分解的计算

> **奇异值分解基本定理证明的过程蕴含了奇异值分解的计算方法。** 矩阵 $A$ 的奇异值分解可以通过求**对称矩阵 $A^\top A$ 的特征值和特征向量**得到。$A^\top A$ 的特征向量构成正交矩阵 $V$ 的列；$A^\top A$ 的特征值 $\lambda_j$ 的平方根为奇异值 $\sigma_j$，即
>
> $$\sigma_j=\sqrt{\lambda_j},\qquad j=1,2,\ldots,n$$
>
> 对其由大到小排列作为对角线元素，构成对角矩阵 $\Sigma$；求正奇异值对应的左奇异向量，再求扩充的 $A^\top$ 的标准正交基，构成正交矩阵 $U$ 的列。从而得到 $A$ 的奇异值分解 $A=U\Sigma V^\top$。

### 五步算法

> **（1）首先求 $A^\top A$ 的特征值和特征向量。**
>
> 计算对称矩阵 $W=A^\top A$。求解特征方程
>
> $$(W-\lambda I)x=0$$
>
> 得到特征值 $\lambda_i$，并将特征值由大到小排列
>
> $$\lambda_1\ge\lambda_2\ge\cdots\ge\lambda_n\ge0$$
>
> 将特征值 $\lambda_i$（$i=1,2,\ldots,n$）代入特征方程求得对应的特征向量。

> **（2）求 $n$ 阶正交矩阵 $V$**
>
> 将特征向量单位化，得到单位特征向量 $v_1,v_2,\ldots,v_n$，构成 $n$ 阶正交矩阵 $V$：
>
> $$V=[v_1\;\;v_2\;\cdots\;v_n]$$

> **（3）求 $m\times n$ 对角矩阵 $\Sigma$**
>
> 计算 $A$ 的奇异值 $\sigma_i=\sqrt{\lambda_i}$，$i=1,2,\ldots,n$。构造 $m\times n$ 矩形对角矩阵 $\Sigma$，主对角线元素是奇异值，其余元素是零，
>
> $$\Sigma=\operatorname{diag}(\sigma_1,\sigma_2,\ldots,\sigma_n)$$

> **（4）求 $m$ 阶正交矩阵 $U$**
>
> 对 $A$ 的前 $r$ 个正奇异值，令
>
> $$u_j=\frac{1}{\sigma_j}Av_j,\qquad j=1,2,\ldots,r$$
>
> 得到 $U_1=[u_1\;u_2\;\cdots\;u_r]$。
>
> 求 $A^\top$ 的零空间的一组标准正交基 $\{u_{r+1},u_{r+2},\ldots,u_m\}$，令 $U_2=[u_{r+1}\;\cdots\;u_m]$，并令 $U=[U_1\;\;U_2]$。

> **（5）得到奇异值分解** $A=U\Sigma V^\top$

**这五步与定理 15.1 证明的对应关系**：

| 算法步骤 | 证明中的位置 |
| --- | --- |
| (1)(2) 对 $A^\top A$ 对角化 | 证明第 (1) 步，谱定理 |
| (3) $\sigma_j=\sqrt{\lambda_j}$ | 式 (15.3)、(15.5) |
| (4) 前半：$u_j=\frac{1}{\sigma_j}Av_j$ | **式 (15.12)** |
| (4) 后半：补 $N(A^\top)$ 的基 | **式 (15.16)** |
| (5) 组装 | 式 (15.17) |

### 例 15.5（完整演算）

> **例 15.5** 试求矩阵
>
> $$A=\begin{bmatrix}1&1\\2&2\\0&0\end{bmatrix}$$
>
> 的奇异值分解。

#### （1）求 $A^\top A$ 的特征值和特征向量

$$
A^\top A=\begin{bmatrix}1&2&0\\1&2&0\end{bmatrix}\begin{bmatrix}1&1\\2&2\\0&0\end{bmatrix}=\begin{bmatrix}5&5\\5&5\end{bmatrix}
$$

特征值 $\lambda$ 和特征向量 $x$ 满足特征方程 $(A^\top A-\lambda I)x=0$，即齐次线性方程组

$$
\begin{cases}
(5-\lambda)x_1+5x_2=0\\
5x_1+(5-\lambda)x_2=0
\end{cases}
$$

> 该方程组有非零解的**充要条件**是

$$
\begin{vmatrix}5-\lambda&5\\5&5-\lambda\end{vmatrix}=0
$$

即

$$
(5-\lambda)^2-25=\lambda^2-10\lambda=0
$$

解此方程，得矩阵 $A^\top A$ 的特征值 $\lambda_1=10$ 和 $\lambda_2=0$。

**代入 $\lambda_1=10$**：$-5x_1+5x_2=0\Rightarrow x_1=x_2$，单位化得

$$
v_1=\begin{bmatrix}\dfrac{1}{\sqrt2}\\[6pt]\dfrac{1}{\sqrt2}\end{bmatrix}
$$

**代入 $\lambda_2=0$**：$5x_1+5x_2=0\Rightarrow x_1=-x_2$，单位化得

$$
v_2=\begin{bmatrix}\dfrac{1}{\sqrt2}\\[6pt]-\dfrac{1}{\sqrt2}\end{bmatrix}
$$

#### （2）求正交矩阵 $V$

$$
V=\begin{bmatrix}\dfrac{1}{\sqrt2}&\dfrac{1}{\sqrt2}\\[8pt]\dfrac{1}{\sqrt2}&-\dfrac{1}{\sqrt2}\end{bmatrix}
$$

#### （3）求对角矩阵 $\Sigma$

奇异值 $\sigma_1=\sqrt{\lambda_1}=\sqrt{10}$，$\sigma_2=0$。构造对角矩阵

$$
\Sigma=\begin{bmatrix}\sqrt{10}&0\\0&0\\0&0\end{bmatrix}
$$

> **注意在 $\Sigma$ 中要加上零行向量，使得 $\Sigma$ 能够与 $U$，$V$ 进行矩阵乘法运算。**

（$A$ 是 $3\times2$，故 $\Sigma$ 必须是 $3\times2$。）

#### （4）求正交矩阵 $U$

**基于 $A$ 的正奇异值计算得到列向量 $u_1$**：

$$
u_1=\frac{1}{\sigma_1}Av_1=\frac{1}{\sqrt{10}}
\begin{bmatrix}1&1\\2&2\\0&0\end{bmatrix}
\begin{bmatrix}1/\sqrt2\\1/\sqrt2\end{bmatrix}
=\frac{1}{\sqrt{10}}\begin{bmatrix}2/\sqrt2\\4/\sqrt2\\0\end{bmatrix}
=\begin{bmatrix}\dfrac{1}{\sqrt5}\\[6pt]\dfrac{2}{\sqrt5}\\[6pt]0\end{bmatrix}
$$

**验算**：$\frac{2/\sqrt2}{\sqrt{10}}=\frac{2}{\sqrt{20}}=\frac{2}{2\sqrt5}=\frac{1}{\sqrt5}$ ✅

**列向量 $u_2,u_3$ 是 $A^\top$ 的零空间 $N(A^\top)$ 的一组标准正交基。** 为此求解

$$
A^\top x=\begin{bmatrix}1&2&0\\1&2&0\end{bmatrix}\begin{bmatrix}x_1\\x_2\\x_3\end{bmatrix}=0
$$

即

$$
x_1+2x_2+0x_3=0\quad\Longrightarrow\quad x_1=-2x_2+0x_3
$$

分别取 $(x_2,x_3)$ 为 $(1,0)$ 和 $(0,1)$，得到 $N(A^\top)$ 的基

$$
(-2,1,0)^\top,\qquad(0,0,1)^\top
$$

$N(A^\top)$ 的一组**标准正交基**是

$$
u_2=\begin{bmatrix}-\dfrac{2}{\sqrt5}\\[6pt]\dfrac{1}{\sqrt5}\\[6pt]0\end{bmatrix},
\qquad u_3=(0,0,1)^\top
$$

（这两个向量恰好已经正交，只需单位化第一个。）

构造正交矩阵

$$
U=\begin{bmatrix}
\dfrac{1}{\sqrt5}&-\dfrac{2}{\sqrt5}&0\\[8pt]
\dfrac{2}{\sqrt5}&\dfrac{1}{\sqrt5}&0\\[8pt]
0&0&1
\end{bmatrix}
$$

#### （5）矩阵 $A$ 的奇异值分解

$$
A=U\Sigma V^\top=
\begin{bmatrix}
\frac{1}{\sqrt5}&-\frac{2}{\sqrt5}&0\\
\frac{2}{\sqrt5}&\frac{1}{\sqrt5}&0\\
0&0&1
\end{bmatrix}
\begin{bmatrix}\sqrt{10}&0\\0&0\\0&0\end{bmatrix}
\begin{bmatrix}\frac{1}{\sqrt2}&\frac{1}{\sqrt2}\\\frac{1}{\sqrt2}&-\frac{1}{\sqrt2}\end{bmatrix}
$$

**代码验证**：$\lambda=10.000000,\;0.000000$ ✅；$\sigma_1=3.162278=\sqrt{10}$ ✅；重构误差 $\lVert U\Sigma V^\top-A\rVert_F=7.02\times10^{-16}$ ✅；$U,V$ 正交性误差 $2.22\times10^{-16}$ ✅；秩 $r=1$ ✅

（代码算出的 $u_2=(0.8944,-0.4472,0)^\top$ 与书中的 $(-0.8944,0.4472,0)^\top$ **差一个整体符号**——这是特征向量符号自由度造成的，两者都正确。）

### 【重要】原书对这个算法的评价

> 上面的算法和例题**只是为了说明计算的过程，并不是实际应用中的算法**。可以看出，奇异值分解算法关键在于 $A^\top A$ 的特征值的计算。**实际应用的奇异值分解算法是通过求 $A^\top A$ 的特征值进行，但不直接计算 $A^\top A$。** 按照这个思路产生了许多矩阵奇异值分解的有效算法，这里不予介绍。

**【补充】为什么不能直接计算 $A^\top A$：条件数平方问题**

这是数值线性代数中的经典陷阱。

**条件数**衡量矩阵"离奇异有多远"：$\kappa(A)=\dfrac{\sigma_1}{\sigma_r}$。而

$$
\kappa(A^\top A)=\frac{\lambda_1}{\lambda_r}=\frac{\sigma_1^2}{\sigma_r^2}=\kappa(A)^2
$$

$$
\boxed{\;
\text{形成 }A^\top A\text{ 会把条件数平方 }\Rightarrow\text{ 有效数字位数直接减半}
\;}
$$

**一个具体例子**：设 $\varepsilon$ 小到 $1+\varepsilon^2$ 在浮点数中舍入为 $1$，取

$$
A=\begin{bmatrix}1&1\\\varepsilon&0\\0&\varepsilon\end{bmatrix}
\quad\Longrightarrow\quad
A^\top A=\begin{bmatrix}1+\varepsilon^2&1\\1&1+\varepsilon^2\end{bmatrix}
\;\xrightarrow{\;\text{浮点}\;}\;
\begin{bmatrix}1&1\\1&1\end{bmatrix}
$$

真实的 $A$ 秩为 2，但算出的 $A^\top A$ 秩只有 1——**$\sigma_2$ 被彻底丢失了**。

**实际算法怎么做**（原书引文献 [3,4]，此处只说思路）：

| 方法 | 思路 |
| --- | --- |
| **Golub-Kahan 双对角化** | 先用 Householder 变换把 $A$ 化成双对角矩阵 $B$（$A=U_1BV_1^\top$），再对 $B$ 做隐式 QR 迭代 |
| **单边 Jacobi** | 直接对 $A$ 的列做 Jacobi 旋转，始终不形成 $A^\top A$ |
| **随机化 SVD** | 大规模低秩场景：先随机投影降维，再对小矩阵做 SVD |

**共同点**：**全程只对 $A$ 本身做正交变换，从不显式形成 $A^\top A$。**

**本笔记的代码采用的是原书的教学算法**（先形成 $A^\top A$ 再用 Jacobi 求特征值），因为它与定理 15.1 的证明一一对应，最便于理解；小规模、良态的矩阵上结果是准确的。

---

## 15.3 奇异值分解与矩阵近似

本节回答全章最重要的应用问题：

> 已知一个大矩阵 $A$，如果只能用一个低秩矩阵 $X$ 来近似它，怎样选 $X$ 才能让信息损失最小？

答案是：**保留最大的 $k$ 个奇异值，丢掉其余的。** 更令人惊讶的是，这不是一个经验规则，而是一个严格的全局最优定理。

### 15.3.1 弗罗贝尼乌斯范数

> 奇异值分解也是一种矩阵近似的方法，这个近似是在**弗罗贝尼乌斯范数**（Frobenius norm）意义下的近似。矩阵的弗罗贝尼乌斯范数是向量的 $L_2$ 范数的直接推广，对应着机器学习中的**平方损失函数**。

#### 定义 15.4

> **定义 15.4（弗罗贝尼乌斯范数）** 设矩阵 $A\in\mathbb R^{m\times n}$，$A=[a_{ij}]_{m\times n}$，定义矩阵 $A$ 的弗罗贝尼乌斯范数为

$$
\lVert A\rVert_F=\left(\sum_{i=1}^{m}\sum_{j=1}^{n}a_{ij}^2\right)^{\frac12}
	ag{15.25}
$$

**三种等价理解**【补充】：

$$
\boxed{\;
\lVert A\rVert_F
=\lVert\operatorname{vec}(A)\rVert_2
=\sqrt{\operatorname{tr}(A^\top A)}
=\sqrt{\operatorname{tr}(AA^\top)}
\;}
$$

**第一条**：把 $A$ 的 $mn$ 个元素摊平成一个长向量，取普通欧氏范数。

**第二条的证明**：$A^\top A$ 的第 $j$ 个对角元为 $\sum_i a_{ij}^2$，故

$$
\operatorname{tr}(A^\top A)=\sum_{j=1}^{n}(A^\top A)_{jj}=\sum_j\sum_i a_{ij}^2=\lVert A\rVert_F^2
$$

**为什么它对应平方损失**：若 $A$ 是真实数据矩阵、$X$ 是近似矩阵，则

$$
\lVert A-X\rVert_F^2=\sum_{i,j}(a_{ij}-x_{ij})^2
$$

正是对每个矩阵元素的**平方误差求和**。所以定理 15.3 说的“弗罗贝尼乌斯范数下最优”，翻译成机器学习语言就是“**均方误差最小**”。

#### 引理 15.1

> **引理 15.1** 设矩阵 $A\in\mathbb R^{m\times n}$，$A$ 的奇异值分解为 $U\Sigma V^\top$，其中 $\Sigma=\operatorname{diag}(\sigma_1,\sigma_2,\ldots,\sigma_n)$，则

$$
\lVert A\rVert_F=\left(\sigma_1^2+\sigma_2^2+\cdots+\sigma_n^2\right)^{\frac12}
	ag{15.26}
$$

**证明。** 原书先证明弗罗贝尼乌斯范数在左右正交变换下不变。

若 $Q$ 是 $m$ 阶正交矩阵，把 $A$ 按列写为 $A=(a_1,a_2,\ldots,a_n)$，则

$$
\begin{aligned}
\lVert QA\rVert_F^2
&=\lVert(Qa_1,Qa_2,\ldots,Qa_n)\rVert_F^2\\
&=\sum_{i=1}^{n}\lVert Qa_i\rVert^2\\
&=\sum_{i=1}^{n}\lVert a_i\rVert^2\\
&=\lVert A\rVert_F^2
\end{aligned}
$$

第三个等号用了正交矩阵**保向量长度**。故

$$
\lVert QA\rVert_F=\lVert A\rVert_F
	ag{15.27}
$$

同样，若 $P$ 是 $n$ 阶正交矩阵，则

$$
\lVert AP^\top\rVert_F=\lVert A\rVert_F
	ag{15.28}
$$

于是对 $A=U\Sigma V^\top$：

$$
\lVert A\rVert_F=\lVert U\Sigma V^\top\rVert_F=\lVert\Sigma\rVert_F
	ag{15.29}
$$

而 $\Sigma$ 只有对角元非零，所以

$$
\lVert\Sigma\rVert_F=\left(\sigma_1^2+\sigma_2^2+\cdots+\sigma_n^2\right)^{\frac12}
	ag{15.30}
$$

引理得证 $\blacksquare$

**【补充】用迹可以一行证完**：

$$
\lVert A\rVert_F^2=\operatorname{tr}(A^\top A)
=\operatorname{tr}\left(V\Sigma^\top U^\top U\Sigma V^\top\right)
=\operatorname{tr}\left(V\Sigma^\top\Sigma V^\top\right)
=\operatorname{tr}\left(\Sigma^\top\Sigma V^\top V\right)
=\operatorname{tr}(\Sigma^\top\Sigma)=\sum_i\sigma_i^2
$$

这里用了迹的循环不变性 $\operatorname{tr}(XYZ)=\operatorname{tr}(ZXY)$。

**直觉**：$\sigma_i^2$ 是矩阵在第 $i$ 个奇异方向上的“能量”，$\lVert A\rVert_F^2$ 是总能量。

**代码验证**：

| 矩阵 | $\lVert A\rVert_F$ | $\sqrt{\sum_i\sigma_i^2}$ | 差 |
| --- | ---: | ---: | ---: |
| 例 15.1 | $5.47722558$ | $5.47722558$ | $0$ |
| 例 15.4 | $3.87298335$ | $3.87298335$ | $0$ |
| 例 15.5 | $3.16227766$ | $3.16227766$ | $4.44\times10^{-16}$ |

并且对正交矩阵 $Q=\begin{bmatrix}0.6&-0.8\\0.8&0.6\end{bmatrix}$，$\lVert A\rVert_F=\lVert QA\rVert_F=\lVert AQ^\top\rVert_F=3.87298335$ ✅

### 15.3.2 矩阵的最优近似

> 奇异值分解是在**平方损失（弗罗贝尼乌斯范数）意义下**对矩阵的最优近似，即数据压缩。

#### 定理 15.2（最优近似存在）

> **定理 15.2** 设矩阵 $A\in\mathbb R^{m\times n}$，矩阵的秩 $\operatorname{rank}(A)=r$，并设 $\mathcal M_k$ 为 $\mathbb R^{m\times n}$ 中所有秩不超过 $k$ 的矩阵集合，$0<k<r$，则存在一个秩为 $k$ 的矩阵 $X\in\mathcal M_k$，使得

$$
\lVert A-X\rVert_F=\min_{S\in\mathcal M_k}\lVert A-S\rVert_F
	ag{15.31}
$$

> 称矩阵 $X$ 为矩阵 $A$ 在弗罗贝尼乌斯范数意义下的**最优近似**。

**它解决什么问题**：保证“最好的秩 $k$ 近似”不是一个只有下确界、但没有任何矩阵真正达到的空目标——**最优解确实存在**。

原书不证明这一定理，而是马上用定理 15.3 告诉我们**具体哪个矩阵能达到这个最优值**。

#### 定理 15.3（Eckart-Young-Mirsky 定理的弗罗贝尼乌斯范数版本）

> **定理 15.3** 设矩阵 $A\in\mathbb R^{m\times n}$，$\operatorname{rank}(A)=r$，有奇异值分解 $A=U\Sigma V^\top$，并设 $\mathcal M_k$ 为所有秩不超过 $k$ 的 $m\times n$ 矩阵集合，$0<k<r$。若秩为 $k$ 的矩阵 $X\in\mathcal M_k$ 满足

$$
\lVert A-X\rVert_F=\min_{S\in\mathcal M_k}\lVert A-S\rVert_F
	ag{15.32}
$$

> 则

$$
\lVert A-X\rVert_F=\left(\sigma_{k+1}^2+\sigma_{k+2}^2+\cdots+\sigma_r^2\right)^{\frac12}
	ag{15.33}
$$

> 特别地，若 $A'=U\Sigma'V^\top$，其中

$$
\Sigma'=\begin{bmatrix}
\sigma_1&&&0\\
&\ddots&&\\
&&\sigma_k&\\
0&&&0
\end{bmatrix}
$$

> 则

$$
\lVert A-A'\rVert_F=\left(\sigma_{k+1}^2+\sigma_{k+2}^2+\cdots+\sigma_r^2\right)^{\frac12}
=\min_{S\in\mathcal M_k}\lVert A-S\rVert_F
	ag{15.34}
$$

$$
\boxed{\;
A_k=U_k\Sigma_kV_k^\top\text{ 是秩不超过 }k\text{ 的所有矩阵中离 }A\text{ 最近的一个，}\\
	ext{最小误差 = 被丢掉的奇异值的平方和开根号}
\;}
$$

**为什么这条定理强大**：它不是说“在某种分解方法中截断 SVD 最好”，而是说在**全体秩不超过 $k$ 的 $m\times n$ 矩阵**中，没有任何方法能做得更好。这个搜索空间是无限的，截断 SVD 却给出了闭式全局最优解。

#### 先证明“截断 SVD 达到这个误差”（容易的上界）

令

$$
A'=U\Sigma'V^\top
$$

由于正交变换不改变弗罗贝尼乌斯范数，

$$
\begin{aligned}
\lVert A-A'\rVert_F
&=\lVert U(\Sigma-\Sigma')V^\top\rVert_F\\
&=\lVert\Sigma-\Sigma'\rVert_F\\
&=\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}
\end{aligned}
$$

所以

$$
\min_{S\in\mathcal M_k}\lVert A-S\rVert_F\le\lVert A-A'\rVert_F=\sqrt{\sum_{i=k+1}^{r}\sigma_i^2}
	ag{15.35}
$$

**还缺什么**：必须证明**任何**秩不超过 $k$ 的 $X$ 都不可能低于这个误差，即下界

$$
\lVert A-X\rVert_F\ge\sqrt{\sum_{i=k+1}^{r}\sigma_i^2}
$$

原书接下来用分块矩阵完成这个下界证明。

#### 原书定理 15.3 的证明路线（按原书逻辑整理）

设 $X$ 是满足式 (15.32) 的一个最优秩 $k$ 矩阵，其 SVD 为

$$
X=Q\Omega P^\top,
\qquad
\Omega=\begin{bmatrix}\Omega_k&0\\0&0\end{bmatrix},
\qquad
\Omega_k=\operatorname{diag}(\omega_1,\ldots,\omega_k)
$$

令

$$
B=Q^\top AP
$$

则 $A=QBP^\top$。利用正交不变性：

$$
\lVert A-X\rVert_F
=\lVert Q(B-\Omega)P^\top\rVert_F
=\lVert B-\Omega\rVert_F
	ag{15.36}
$$

**这一步的意义**：把坐标系转到 $X$ 自己的奇异向量基里。在这个坐标系里 $X$ 的形状最简单——只有左上角 $k\times k$ 的 $\Omega_k$ 非零。

把 $B$ 按同样大小分块：

$$
B=\begin{bmatrix}B_{11}&B_{12}\\B_{21}&B_{22}\end{bmatrix}
$$

其中 $B_{11}$ 是 $k\times k$，$B_{12}$ 是 $k\times(n-k)$，$B_{21}$ 是 $(m-k)\times k$，$B_{22}$ 是 $(m-k)\times(n-k)$。

于是

$$
\begin{aligned}
\lVert A-X\rVert_F^2
&=\lVert B-\Omega\rVert_F^2\\
&=\lVert B_{11}-\Omega_k\rVert_F^2+\lVert B_{12}\rVert_F^2+\lVert B_{21}\rVert_F^2+\lVert B_{22}\rVert_F^2
\end{aligned}
	ag{15.37}
$$

**这一步只是“矩阵元素平方和”的分块相加**——四个块互不重叠，故总平方和等于四块平方和。

##### 第一步：最优解必须有 $B_{12}=B_{21}=0$

原书用反证法。若 $B_{12}\ne0$，构造

$$
Y=Q\begin{bmatrix}B_{11}&B_{12}\\0&0\end{bmatrix}P^\top
$$

它只有前 $k$ 行可能非零，所以 $\operatorname{rank}(Y)\le k$，即 $Y\in\mathcal M_k$。而

$$
\lVert A-Y\rVert_F^2=\lVert B_{21}\rVert_F^2+\lVert B_{22}\rVert_F^2
	ag{15.38}
$$

若 $B_{12}\ne0$（或者 $B_{11}\ne\Omega_k$），式 (15.38) 会严格小于式 (15.37)，与 $X$ 已经是最优解矛盾。故最优解坐标系下的“交叉块”不能保留额外误差。类似可处理 $B_{21}$。

原书结论写为 $B_{12}=0,B_{21}=0$，于是

$$
\lVert A-X\rVert_F^2=\lVert B_{11}-\Omega_k\rVert_F^2+\lVert B_{22}\rVert_F^2
	ag{15.39}
$$

##### 第二步：最优解必须有 $B_{11}=\Omega_k$

构造

$$
Z=Q\begin{bmatrix}B_{11}&0\\0&0\end{bmatrix}P^\top
$$

$Z$ 的秩不超过 $k$，且

$$
\lVert A-Z\rVert_F^2=\lVert B_{22}\rVert_F^2
\le\lVert B_{11}-\Omega_k\rVert_F^2+\lVert B_{22}\rVert_F^2
=\lVert A-X\rVert_F^2
	ag{15.40}
$$

因为 $X$ 已经是最优解，不能存在严格更小的 $Z$，故必须

$$
B_{11}-\Omega_k=0\quad\Longrightarrow\quad B_{11}=\Omega_k
$$

于是所有误差只剩右下角：

$$
\lVert A-X\rVert_F=\lVert B_{22}\rVert_F
	ag{15.41}
$$

##### 第三步：$B_{22}$ 的奇异值就是 $A$ 剩余的奇异值

若 $B_{22}$ 有 SVD

$$
B_{22}=U_2\Lambda V_2^\top
$$

构造分块正交矩阵

$$
\widetilde U=\begin{bmatrix}I_k&0\\0&U_2\end{bmatrix},
\qquad
\widetilde V=\begin{bmatrix}I_k&0\\0&V_2\end{bmatrix}
$$

则

$$
\widetilde U^\top Q^\top AP\widetilde V
=\begin{bmatrix}\Omega_k&0\\0&\Lambda\end{bmatrix}
	ag{15.42}
$$

等价地

$$
A=(Q\widetilde U)
\begin{bmatrix}\Omega_k&0\\0&\Lambda\end{bmatrix}
(P\widetilde V)^\top
	ag{15.43}
$$

这本身是 $A$ 的一个 SVD，故对角线上的数合起来必须是 $A$ 的奇异值。前 $k$ 个由 $X$ 捕获，$B_{22}$ 的奇异值是剩下的部分。因此由引理 15.1：

$$
\lVert A-X\rVert_F=\lVert B_{22}\rVert_F
=\lVert\Lambda\rVert_F
\ge\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}
	ag{15.44}
$$

结合式 (15.35) 的上界，得到

$$
\boxed{\;
\lVert A-X\rVert_F=\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}
=\lVert A-A_k\rVert_F
\;}
$$

定理得证 $\blacksquare$

**【补充】证明的核心思想，其实只有一句话**：

> 正交变换不改变距离，所以可以转到最优矩阵 $X$ 的奇异向量坐标系；在这个坐标系里，秩 $k$ 矩阵最多只能“装下” $k$ 个正交方向，剩下方向的能量至少是 $\sigma_{k+1}^2+\cdots+\sigma_r^2$。

#### 数值验证

代码对一个随机 $6\times5$ 矩阵，既算截断 SVD，又用 **40 次随机重启的交替最小二乘（ALS）**在所有形如 $BC$（秩 $\le k$）的矩阵中数值搜索：

| $k$ | $\lVert A-A_k\rVert_F$ | 定理 15.3：$\sqrt{\sum_{i>k}\sigma_i^2}$ | ALS 找到的最优值 |
| ---: | ---: | ---: | ---: |
| 1 | $7.24186868$ | $7.24186868$ | $7.24186868$ |
| 2 | $4.73118326$ | $4.73118326$ | $4.73118326$ |
| 3 | $2.86425041$ | $2.86425041$ | $2.86425041$ |
| 4 | $0.32680543$ | $0.32680543$ | $0.32680543$ |

三列完全一致 ✅ 数值搜索也找不到比截断 SVD 更好的秩 $k$ 矩阵。

#### 压缩率怎么计算【补充】

原矩阵 $A$ 需要存 $mn$ 个数。秩 $k$ 截断 SVD 存：

- $U_k$：$mk$ 个数
- $\Sigma_k$：只需存 $k$ 个奇异值（对角线）
- $V_k$：$nk$ 个数

总计

$$
k(m+n+1)
$$

压缩才有意义的条件是

$$
k(m+n+1)<mn
\quad\Longleftrightarrow\quad
k<\frac{mn}{m+n+1}
$$

**例**：$30\times40$ 矩阵用 $k=3$：原始存 $1200$ 个数，截断 SVD 存 $3(30+40+1)=213$ 个数，存储率 $213/1200=17.75\%$，节省 $82.25\%$。

代码构造了一个“3 个强秩 1 成分 + 噪声”的 $30\times40$ 矩阵，前 8 个奇异值为

$$
304.048,\;104.536,\;46.831,\;5.525,\;5.128,\;4.823,\;4.405,\;4.161
$$

前三个远大于后面，说明真实结构近似秩 3。取 $k=3$ 时：

- 相对误差仅 $0.0495$
- 累计能量占比 $99.7553\%$
- 存储量仅为原来的 $17.7\%$

这就是原书所说“**由于通常奇异值递减很快，所以 $k$ 取很小值时，$A_k$ 也可以对 $A$ 有很好的近似**”的数值版。

### 15.3.3 矩阵的外积展开式

> 下面介绍利用外积展开式对矩阵 $A$ 的近似。矩阵 $A$ 的奇异值分解 $U\Sigma V^\top$ 也可以由**外积形式**表示。

把 $U\Sigma$ 按列分块、$V^\top$ 按行分块：

$$
U\Sigma=[\sigma_1u_1\;\;\sigma_2u_2\;\cdots\;\sigma_nu_n],
\qquad
V^\top=\begin{bmatrix}v_1^\top\\v_2^\top\\\vdots\\v_n^\top\end{bmatrix}
$$

矩阵乘法的“列乘行再求和”规则给出

$$
A=\sigma_1u_1v_1^\top+\sigma_2u_2v_2^\top+\cdots+\sigma_nu_nv_n^\top
	ag{15.45}
$$

> 式 (15.45) 称为矩阵 $A$ 的**外积展开式**，其中 $u_kv_k^\top$ 为 $m\times n$ 矩阵，是列向量 $u_k$ 和行向量 $v_k^\top$ 的外积，其第 $i$ 行第 $j$ 列元素为 $u_k$ 的第 $i$ 个元素与 $v_k$ 的第 $j$ 个元素的乘积。

若定义

$$
A_k=\sigma_ku_kv_k^\top
$$

则

$$
A=\sum_{k=1}^{n}A_k=\sum_{k=1}^{n}\sigma_ku_kv_k^\top
	ag{15.46}
$$

> 式 (15.46) 将矩阵 $A$ 分解为矩阵的**有序加权和**。

**【易混淆点 4】原书这里同时用 $A_k$ 表示“第 $k$ 个秩 1 成分”和“前 $k$ 项的截断和”，上下文不同。** 为避免混淆，本笔记建议：

- 单个成分记 $E_k=\sigma_ku_kv_k^\top$
- 前 $k$ 项的截断矩阵记 $A^{(k)}=\sum_{i=1}^{k}E_i$

#### 为什么每一项的秩都是 1【补充】

$u_kv_k^\top$ 的每一列都是 $u_k$ 的标量倍：第 $j$ 列 $=v_{jk}u_k$。所以所有列都落在一维空间 $\operatorname{span}\{u_k\}$ 里；只要 $u_k,v_k\ne0$，秩恰为 1。

$$
\boxed{\;
	ext{SVD 把任意矩阵拆成一串互相正交的秩 1“图层”，}\\
\sigma_k\text{ 是第 }k\text{ 层的权重，越大越重要}
\;}
$$

#### 逐项截断

若 $\operatorname{rank}(A)=n$（原书在此段取满列秩情形），则

$$
A=\sigma_1u_1v_1^\top+\sigma_2u_2v_2^\top+\cdots+\sigma_nu_nv_n^\top
	ag{15.47}
$$

保留前 $n-1$ 项得到秩 $n-1$ 的最优近似，保留前 $n-2$ 项得到秩 $n-2$ 的最优近似。一般地：

$$
A^{(k)}=\sigma_1u_1v_1^\top+\cdots+\sigma_ku_kv_k^\top
$$

是所有秩不超过 $k$ 的矩阵中对 $A$ 的弗罗贝尼乌斯范数最优近似——这就是截断 SVD。

**为什么 $\operatorname{rank}(A^{(k)})=k$**（当 $\sigma_k>0$）【补充】：

$$
A^{(k)}V_k=U_k\Sigma_k
$$

右端的 $k$ 列 $\sigma_i u_i$ 线性无关（$u_i$ 标准正交且 $\sigma_i>0$），故 $A^{(k)}$ 的值域至少有 $k$ 维；而 $A^{(k)}=U_k(\Sigma_kV_k^\top)$ 的列空间包含在 $U_k$ 的 $k$ 维列空间中，秩至多 $k$。上下界合起来，秩恰为 $k$。

#### 例 15.6

> **例 15.6** 由例 15.1 给出的矩阵 $A$ 的秩为 3，求 $A$ 的秩为 2 的最优近似。

由例 15.3 可知

$$
u_1=\begin{bmatrix}0\\1\\0\\0\\0\end{bmatrix},\quad
u_2=\begin{bmatrix}0\\0\\1\\0\\0\end{bmatrix},\quad
v_1=\begin{bmatrix}0\\0\\0\\1\end{bmatrix},\quad
v_2=\begin{bmatrix}0\\1\\0\\0\end{bmatrix},\quad
\sigma_1=4,\;\sigma_2=3
$$

于是

$$
\begin{aligned}
A_2&=\sigma_1u_1v_1^\top+\sigma_2u_2v_2^\top\\
&=\begin{bmatrix}
0&0&0&0\\
0&0&0&4\\
0&3&0&0\\
0&0&0&0\\
0&0&0&0
\end{bmatrix}
\end{aligned}
$$

> 以此矩阵作为 $A$ 的最优近似。

**代码验证**：它与例 15.3 的 $U_2\Sigma_2V_2^\top$ 完全相同（差为 0）✅，$\lVert A-A_2\rVert_F=2.236068=\sigma_3$ ✅

**逐项增加图层时，误差严格按照被丢奇异值的能量下降**：

| 保留项数 $k$ | 新增奇异值 | $\lVert A-A_k\rVert_F$ | 理论值 |
| ---: | ---: | ---: | ---: |
| 1 | $4$ | $\sqrt{3^2+(\sqrt5)^2}=3.741657$ | $3.741657$ |
| 2 | $3$ | $\sqrt{(\sqrt5)^2}=2.236068$ | $2.236068$ |
| 3 | $\sqrt5$ | $0$ | $0$ |

$$
\boxed{\;
       ext{第 }k\text{ 个奇异值 }\sigma_k\text{ 精确衡量了第 }k\text{ 个秩 1 图层带来的能量}
\;}
$$

---

## 15.4 代码实现与验证

下面给出**纯 Python**（不依赖第三方库）的教学实现。它严格按 15.2 节的五步算法：对 $A^\top A$ 做 Jacobi 特征分解，构造 $V$ 与 $\Sigma$，再由 $u_j=Av_j/\sigma_j$ 构造 $U$。

> **适用边界**：这段代码用于理解与复现实验，不用于生产环境。原书已提醒实际算法不应显式构造 $A^\top A$，因为条件数会平方。

```python
"""第 15 章奇异值分解：纯 Python 实现，不依赖第三方库。"""
import math


def transpose(A):
       return [list(row) for row in zip(*A)]


def matmul(A, B):
       return [[sum(A[i][k] * B[k][j] for k in range(len(B)))
                      for j in range(len(B[0]))] for i in range(len(A))]


def matvec(A, x):
       return [sum(a * b for a, b in zip(row, x)) for row in A]


def fnorm(A):
       """式(15.25) 弗罗贝尼乌斯范数。"""
       return math.sqrt(sum(x * x for row in A for x in row))


def error(A, B):
       return fnorm([[a - b for a, b in zip(x, y)] for x, y in zip(A, B)])


def jacobi(A, tol=1e-14):
       """实对称矩阵特征分解；V 的列是单位特征向量。"""
       n = len(A)
       a = [row[:] for row in A]
       V = [[float(i == j) for j in range(n)] for i in range(n)]
       for _ in range(100000):
              _, p, q = max((abs(a[i][j]), i, j)
                                     for i in range(n) for j in range(i + 1, n))
              if abs(a[p][q]) < tol:
                     break
              z = (a[q][q] - a[p][p]) / (2 * a[p][q])
              t = math.copysign(1.0, z) / (abs(z) + math.sqrt(z * z + 1))
              c, s = 1 / math.sqrt(1 + t * t), t / math.sqrt(1 + t * t)
              for k in range(n):
                     x, y = a[k][p], a[k][q]
                     a[k][p], a[k][q] = c*x - s*y, s*x + c*y
              for k in range(n):
                     x, y = a[p][k], a[q][k]
                     a[p][k], a[q][k] = c*x - s*y, s*x + c*y
              for k in range(n):
                     x, y = V[k][p], V[k][q]
                     V[k][p], V[k][q] = c*x - s*y, s*x + c*y
       return [a[i][i] for i in range(n)], V


def extend_basis(cols, m):
       """把 R(A) 的标准正交基扩充为 R^m 的标准正交基。"""
       basis = [v[:] for v in cols]
       for i in range(m):
              if len(basis) == m:
                     break
              x = [float(i == j) for j in range(m)]
              for q in basis:
                     proj = sum(a*b for a, b in zip(x, q))
                     x = [a - proj*b for a, b in zip(x, q)]
              norm = math.sqrt(sum(a*a for a in x))
              if norm > 1e-10:
                     basis.append([a / norm for a in x])
       return basis


def svd(A, tol=1e-7):
       """按 15.2 节五步算法计算 A = U Sigma V^T。"""
       A = [[float(x) for x in row] for row in A]
       m, n = len(A), len(A[0])
       eig, V0 = jacobi(matmul(transpose(A), A))             # (1)
       order = sorted(range(n), key=lambda j: -eig[j])
       eig = [max(eig[j], 0.0) for j in order]
       V = [[V0[i][j] for j in order] for i in range(n)]    # (2)
       sigma = [math.sqrt(x) for x in eig]                   # (3)
       cutoff = tol * max(m, n) * max(sigma[0], 1.0)
       sigma = [x if x > cutoff else 0.0 for x in sigma]
       rank = sum(x > 0 for x in sigma)
       Sigma = [[sigma[j] if i == j else 0.0 for j in range(n)]
                      for i in range(m)]
       ucols = []                                            # (4)
       for j in range(rank):
              Av = matvec(A, [V[i][j] for i in range(n)])
              ucols.append([x / sigma[j] for x in Av])
       ucols = extend_basis(ucols, m)
       U = [[ucols[j][i] for j in range(m)] for i in range(m)]
       return U, Sigma, V, sigma, rank                       # (5)


def reconstruct(U, Sigma, V):
       return matmul(matmul(U, Sigma), transpose(V))


def truncate(A, k):
       """式(15.19) 截断 SVD：A_k = U_k Sigma_k V_k^T。"""
       U, _, V, s, rank = svd(A)
       Uk = [[row[j] for j in range(k)] for row in U]
       Vk = [[row[j] for j in range(k)] for row in V]
       Sk = [[s[j] if i == j else 0.0 for j in range(k)] for i in range(k)]
       return reconstruct(Uk, Sk, Vk), s, rank


def report(name, A):
       U, S, V, s, rank = svd(A)
       print(f"{name}: shape={len(A)}x{len(A[0])}, rank={rank}")
       print("  sigma =", [round(x, 8) for x in s])
       print(f"  reconstruction error = {error(reconstruct(U,S,V), A):.2e}")
       print(f"  F-norm={fnorm(A):.8f}, sqrt(sum sigma^2)="
                f"{math.sqrt(sum(x*x for x in s)):.8f}")
       return U, S, V, s


print("【例 15.1 / 15.3 / 15.6】")
A1 = [[1,0,0,0], [0,0,0,4], [0,3,0,0], [0,0,0,0], [2,0,0,0]]
report("A", A1)
for k in (1, 2, 3):
       Ak, s, _ = truncate(A1, k)
       print(f"  k={k}: error={error(A1,Ak):.8f}, "
                f"theory={math.sqrt(sum(x*x for x in s[k:])):.8f}")

print("\n【例 15.5】")
report("A", [[1,1], [2,2], [0,0]])

print("\n【习题 15.1】")
report("A", [[1,2,0], [2,0,2]])

print("\n【习题 15.2】")
H2 = [[2,4], [1,3], [0,0], [0,0]]
report("A", H2)
A1rank, _, _ = truncate(H2, 1)
print(f"  rank-1 error = {error(H2,A1rank):.8f}")

print("\n【习题 15.5：图 15.2】")
C = [[0,20,5,0,0], [10,0,0,3,0], [0,0,0,0,1], [0,0,1,0,0]]
_, _, _, s = report("click matrix", C)
print("  energy ratio =", [round(x*x/sum(y*y for y in s), 6) for x in s])
C2, _, _ = truncate(C, 2)
print(f"  rank-2 error = {error(C,C2):.8f}")
```

**运行结果：**

```text
【例 15.1 / 15.3 / 15.6】
A: shape=5x4, rank=3
  sigma = [4.0, 3.0, 2.23606798, 0.0]
  reconstruction error = 0.00e+00
  F-norm=5.47722558, sqrt(sum sigma^2)=5.47722558
  k=1: error=3.74165739, theory=3.74165739
  k=2: error=2.23606798, theory=2.23606798
  k=3: error=0.00000000, theory=0.00000000

【例 15.5】
A: shape=3x2, rank=1
  sigma = [3.16227766, 0.0]
  reconstruction error = 7.02e-16
  F-norm=3.16227766, sqrt(sum sigma^2)=3.16227766

【习题 15.1】
A: shape=2x3, rank=2
  sigma = [3.0, 2.0, 0.0]
  reconstruction error = 2.40e-15
  F-norm=3.60555128, sqrt(sum sigma^2)=3.60555128

【习题 15.2】
A: shape=4x2, rank=2
  sigma = [5.4649857, 0.36596619]
  reconstruction error = 1.72e-15
  F-norm=5.47722558, sqrt(sum sigma^2)=5.47722558
  rank-1 error = 0.36596619

【习题 15.5：图 15.2】
click matrix: shape=4x5, rank=4
  sigma = [20.61695792, 10.44030651, 1.0, 0.97007522, 0.0]
  reconstruction error = 7.54e-15
  F-norm=23.15167381, sqrt(sum sigma^2)=23.15167381
  energy ratio = [0.79302, 0.203358, 0.001866, 0.001756, 0.0]
  rank-2 error = 1.39321425
```

> **Windows 运行提示**：若报 `UnicodeEncodeError`，执行前设置 `$env:PYTHONIOENCODING = "utf-8"`。

### 验证结论

| 结论 | 证据 |
| --- | --- |
| 五步教学算法可重构原矩阵 | 所有重构误差均在 $10^{-15}$ 量级 |
| 引理 15.1 正确 | 每个例子的 $\lVert A\rVert_F=\sqrt{\sum\sigma_i^2}$ |
| 定理 15.3 正确 | 截断误差与 $\sqrt{\sum_{i>k}\sigma_i^2}$ 逐项一致 |
| 例 15.1 的奇异值正确 | $4,3,\sqrt5,0$ |
| 例 15.5 的秩正确 | 只有一个正奇异值 $\sqrt{10}$，秩为 1 |
| 习题 15.1 的奇异值正确 | $3,2,0$，秩为 2 |
| 图 15.2 的点击矩阵近似低秩 | 前两个奇异值占总能量 $99.64\%$ |

---

## 15.5 【补充】深入理解

### 15.5.1 SVD、特征分解与 PCA 的关系

| | 特征分解 | SVD |
| --- | --- | --- |
| 适用矩阵 | 方阵；正交对角化还要求实对称 | **任意 $m\times n$ 实矩阵** |
| 形式 | $A=Q\Lambda Q^{-1}$；对称时 $Q^\top$ | $A=U\Sigma V^\top$ |
| 左右基 | 同一组（对称时） | 两组：$U$ 与 $V$ |
| 对角元素 | 特征值，可负/复 | 奇异值，恒非负实数 |
| 几何 | 在不变方向上缩放 | 输入旋转 → 缩放 → 输出旋转 |

**PCA 为什么用 SVD**：对中心化数据矩阵 $X$，协方差矩阵与 $XX^\top$（或 $X^\top X$，取决于样本排布）只差常数。由式 (15.20)(15.21)，其特征向量就是 $X$ 的奇异向量，特征值就是 $\sigma_i^2$ 的常数倍。因此第 16 章既可以对协方差矩阵做特征分解，也可以直接对数据矩阵做 SVD。

### 15.5.2 奇异值谱告诉我们什么

$$
\underbrace{\sigma_1\ge\cdots\ge\sigma_r}_{\text{奇异值谱}}
$$

| 现象 | 解释 |
| --- | --- |
| 前几个很大、后面迅速趋零 | 数据具有明显的**低秩结构**，适合压缩 |
| 缓慢衰减 | 信息分散在很多方向，低秩压缩损失大 |
| $\sigma_r$ 接近 0 | 矩阵接近秩亏，数值问题严重 |
| $\sigma_1/\sigma_r$ 很大 | 条件数大，线性方程对扰动敏感 |

**选择 $k$ 的能量准则**：选最小的 $k$ 使

$$
\frac{\sum_{i=1}^{k}\sigma_i^2}{\sum_{i=1}^{r}\sigma_i^2}\ge\eta
$$

其中 $\eta$ 常取 $0.90,0.95,0.99$。由引理 15.1 与定理 15.3，这等价于控制相对重构误差：

$$
\frac{\lVert A-A_k\rVert_F^2}{\lVert A\rVert_F^2}
=1-\frac{\sum_{i=1}^{k}\sigma_i^2}{\sum_{i=1}^{r}\sigma_i^2}
$$

### 15.5.3 常见误解辨析

1. **“SVD 只适用于方阵。”** 错。它正是为了推广方阵对角化，适用于任意矩形矩阵。
2. **“$\Sigma$ 总是方阵。”** 错。完全 SVD 中它与 $A$ 同形，为 $m\times n$；只有紧/截断 SVD 的 $\Sigma_r,\Sigma_k$ 是方阵。
3. **“紧 SVD 是近似。”** 错。紧 SVD 与 $A$ 等秩，关系是精确等号；截断 SVD 才是有损近似。
4. **“奇异向量唯一。”** 错。可同时变号；重复奇异值子空间内可旋转；零奇异值对应的零空间基可任选。奇异值本身唯一。
5. **“最大奇异值就是最大元素。”** 错。$\sigma_1$ 是最大拉伸倍数 $\max_{\lVert x\rVert=1}\lVert Ax\rVert$，由全矩阵共同决定。
6. **“直接算 $A^\top A$ 是生产级 SVD。”** 错。它会把条件数平方；原书明确说教学算法不用于实际。
7. **“截断 SVD 对任何损失都最优。”** 错。定理 15.3 针对弗罗贝尼乌斯范数；它也对谱范数最优，但对 $L_1$、缺失值加权误差等一般不成立。
8. **“保留 99% 能量就一定保留 99% 任务信息。”** 错。能量是无监督的平方误差指标，低能量方向仍可能含有对分类极重要的信号。
9. **“低秩近似不会在原来为 0 的位置产生非零值。”** 错。习题 15.5 中 $q_4,u_2$ 原为 0，秩 2 近似为 $0.236$；这正是潜在语义泛化，也可能是假阳性。
10. **“矩阵秩在浮点数中是绝对概念。”** 数学上是，数值上不是。必须用相对阈值判断 $\sigma_i$ 是否“足够接近 0”。

---

## 15.6 本章概要与必须掌握的结论

1. 任意 $A\in\mathbb R^{m\times n}$ 都存在 $A=U\Sigma V^\top$，$U,V$ 正交，$\Sigma$ 矩形对角且奇异值非负降序。
2. SVD 一定存在但不唯一；奇异值唯一，奇异向量有符号、重复子空间与零空间基的自由度。
3. 定理 15.1 的突破口是 $A^\top A$ 总为实对称半正定矩阵。
4. $A^\top A$ 特征值非负，因为 $\lambda=\lVert Ax\rVert^2/\lVert x\rVert^2$。
5. $\sigma_j=\sqrt{\lambda_j}$；$v_j$ 是 $A^\top A$ 的特征向量；$u_j=Av_j/\sigma_j$。
6. $N(A^\top A)=N(A)$，故 $\operatorname{rank}(A^\top A)=\operatorname{rank}(A)$。
7. 完全 SVD 用 $m\times m,m\times n,n\times n$ 三个矩阵；紧 SVD 只保留 $r$ 个正奇异方向，仍精确无损。
8. 截断 SVD 保留前 $k<r$ 个方向，是有损低秩近似。
9. 几何上，SVD 是“输入空间旋转/反射 → 按 $\sigma_i$ 缩放 → 输出空间旋转/反射”；单位球变成椭球。
10. $A^\top A=V(\Sigma^\top\Sigma)V^\top$，$AA^\top=U(\Sigma\Sigma^\top)U^\top$。
11. $Av_j=\sigma_ju_j$，$A^\top u_j=\sigma_jv_j$。
12. 正奇异值个数等于矩阵的秩。
13. $u_1..u_r$、$u_{r+1}..u_m$ 分别是 $R(A)$、$N(A^\top)$ 的标准正交基；$v_1..v_r$、$v_{r+1}..v_n$ 分别对应 $R(A^\top)$、$N(A)$。
14. 弗罗贝尼乌斯范数是所有元素平方和开根号，等于 $\sqrt{\operatorname{tr}(A^\top A)}$，对应平方损失。
15. 正交变换不改变弗罗贝尼乌斯范数。
16. $\lVert A\rVert_F^2=\sum_i\sigma_i^2$：奇异值平方可解释为各方向能量。
17. 定理 15.3：$A_k=U_k\Sigma_kV_k^\top$ 是全体秩不超过 $k$ 的矩阵中弗罗贝尼乌斯误差最小者。
18. 最小误差为 $\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}$。
19. 外积展开 $A=\sum_i\sigma_iu_iv_i^\top$ 把矩阵拆成有序的秩 1 图层。
20. 截断 SVD 的存储量为 $k(m+n+1)$，原矩阵为 $mn$；只有前者更小时才真正压缩。
21. 实际算法不显式形成 $A^\top A$，否则条件数平方、有效精度下降。
22. SVD 是第 16 章 PCA 与第 17 章 LSA 的核心计算工具。

---

## 15.7 习题解答

### 习题 15.1

**题目**：求

$$
A=\begin{bmatrix}1&2&0\\2&0&2\end{bmatrix}
$$

的奇异值分解。

**解**。因 $m<n$，为简便先算较小的 $AA^\top$：

$$
AA^\top=\begin{bmatrix}5&2\\2&8\end{bmatrix}
$$

特征方程

$$
\det(AA^\top-\lambda I)=(5-\lambda)(8-\lambda)-4
=\lambda^2-13\lambda+36=(\lambda-9)(\lambda-4)=0
$$

故奇异值 $\sigma_1=3,\sigma_2=2$。

$\lambda_1=9$ 时，$-4x_1+2x_2=0$，取单位特征向量

$$
u_1=\frac1{\sqrt5}(1,2)^\top
$$

$\lambda_2=4$ 时，$x_1+2x_2=0$，取

$$
u_2=\frac1{\sqrt5}(-2,1)^\top
$$

由 $v_j=A^\top u_j/\sigma_j$：

$$
v_1=\frac{1}{3\sqrt5}(5,2,4)^\top,
\qquad
v_2=\frac1{\sqrt5}(0,-2,1)^\top
$$

再取 $N(A)$ 的单位基。解 $Ax=0$：$x_1+2x_2=0$，$2x_1+2x_3=0$，得 $x=(-2,1,2)t$，故

$$
v_3=\frac13(-2,1,2)^\top
$$

于是一个完全 SVD 为

$$
U=\frac1{\sqrt5}\begin{bmatrix}1&-2\\2&1\end{bmatrix},
\quad
\Sigma=\begin{bmatrix}3&0&0\\0&2&0\end{bmatrix},
\quad
V=\begin{bmatrix}
\frac5{3\sqrt5}&0&-\frac23\\
\frac2{3\sqrt5}&-\frac2{\sqrt5}&\frac13\\
\frac4{3\sqrt5}&\frac1{\sqrt5}&\frac23
\end{bmatrix}
$$

代码验证重构误差 $2.40\times10^{-15}$。

### 习题 15.2

对

$$
A=\begin{bmatrix}2&4\\1&3\\0&0\\0&0\end{bmatrix},
\qquad
A^\top A=\begin{bmatrix}5&11\\11&25\end{bmatrix}
$$

特征方程为 $\lambda^2-30\lambda+4=0$，故

$$
\lambda_{1,2}=15\pm\sqrt{221},
\quad
\sigma_1=\sqrt{15+\sqrt{221}}\approx5.46498570,
\quad
\sigma_2=\sqrt{15-\sqrt{221}}\approx0.36596619
$$

单位右奇异向量数值为

$$
v_1\approx(0.4046,0.9145)^\top,
\qquad
v_2\approx(0.9145,-0.4046)^\top
$$

由 $u_j=Av_j/\sigma_j$：

$$
u_1\approx(0.8174,0.5760,0,0)^\top,
\qquad
u_2\approx(0.5760,-0.8174,0,0)^\top
$$

补 $u_3=e_3,u_4=e_4$，即得完整 $U$。外积展开为

$$
A=\sigma_1u_1v_1^\top+\sigma_2u_2v_2^\top
$$

其中两项数值分别为

$$
\begin{bmatrix}1.807207&4.085286\\1.273574&2.878979\\0&0\\0&0\end{bmatrix}
+
\begin{bmatrix}0.192793&-0.085286\\-0.273574&0.121021\\0&0\\0&0\end{bmatrix}
=A
$$

秩 1 最优近似误差恰为 $\sigma_2=0.36596619$。

### 习题 15.3

**相同点**：两者都是正交基下的“对角化”，都把复杂变换分成正交方向上的独立缩放；对称矩阵的 SVD 可由其特征分解得到。

**不同点**：

| | 对称矩阵对角化 | SVD |
| --- | --- | --- |
| 适用对象 | 实对称方阵 | 任意矩形实矩阵 |
| 形式 | $A=Q\Lambda Q^\top$ | $A=U\Sigma V^\top$ |
| 基 | 同一组 $Q$ | 输入 $V$、输出 $U$ 两组 |
| 对角值 | 特征值，可正可负 | 奇异值，恒非负 |
| 几何 | 特征方向可能翻转（负特征值） | 符号翻转吸收到 $U,V$，$\Sigma$ 只缩放 |

若 $A$ 对称正定，则 $U=V=Q$（至多差列符号），$\sigma_i=\lambda_i$。若 $A$ 对称但不定，则 $\sigma_i=\lvert\lambda_i\rvert$，负号吸收到一侧奇异向量。非对称矩阵通常不能正交对角化，但总有 SVD。

### 习题 15.4

**证明**。设 $A\ne0$ 且 $\operatorname{rank}(A)=1$。取 $A$ 的一个非零列 $u$。因为列空间维数为 1，$A$ 的每一列都必是 $u$ 的标量倍：第 $j$ 列 $A_{:j}=v_j u$。令 $v=(v_1,\ldots,v_n)^\top$，则

$$
A=[v_1u\;v_2u\;\cdots\;v_nu]=uv^\top
$$

$\blacksquare$

反之，若 $u,v\ne0$，$uv^\top$ 的每列都是 $u$ 的倍数，且至少一列非零，故秩为 1。

**实例**：

$$
u=v=(1,2,3)^\top,
\quad
uv^\top=\begin{bmatrix}1&2&3\\2&4&6\\3&6&9\end{bmatrix}
$$

其唯一正奇异值为 $\lVert u\rVert\lVert v\rVert=14$，紧 SVD 就是一个外积。

### 习题 15.5

由扫描图 15.2 精确读出边：$q_1\to u_2(20)$、$q_1\to u_3(5)$、$q_2\to u_1(10)$、$q_2\to u_4(3)$、$q_3\to u_5(1)$、$q_4\to u_3(1)$。取行表示查询、列表示 URL：

$$
A=\begin{bmatrix}
0&20&5&0&0\\
10&0&0&3&0\\
0&0&0&0&1\\
0&0&1&0&0
\end{bmatrix}
$$

代码得到

$$
\sigma\approx(20.61696,\;10.44031,\;1,\;0.97008,\;0)
$$

能量占比为 $(0.793020,0.203358,0.001866,0.001756,0)$，前两个方向占 $99.6378\%$，说明该点击矩阵近似秩 2。

**三个矩阵的含义**：

| 矩阵 | 含义 |
| --- | --- |
| $U$（$4\times4$） | 行对应查询，前 $k$ 列是查询在潜在语义/意图空间中的方向 |
| $\Sigma$ | 各潜在语义的重要度；$\sigma_i$ 越大，该模式解释的点击能量越多 |
| $V$（$5\times5$） | 行对应 URL，前 $k$ 列是 URL 在同一潜在语义空间中的方向 |

秩 2 截断近似为

$$
A_2\approx\begin{bmatrix}
0&19.997&5.011&0&0\\
10&0&0&3&0\\
0&0&0&0&0\\
0&0.236&0.059&0&0
\end{bmatrix},
\qquad
\lVert A-A_2\rVert_F=1.393214
$$

原矩阵中 $q_4\to u_2$ 为 0，但低秩近似给出 $0.236$：因为 $q_4$ 与 $q_1$ 都点击了 $u_3$，模型推断它们具有相似潜在意图，于是认为 $q_4$ 也可能点击 $u_2$。这就是 SVD 在搜索推荐中的意义：**通过共享潜在语义，给未观察到的查询-URL 对预测非零相关性。**

---

## 第 15 章一句话回顾

奇异值分解把任意矩形实矩阵 $A$ 拆成 $A=U\Sigma V^\top$：$V^\top$ 在输入空间旋转/反射，$\Sigma$ 沿正交轴按非负奇异值缩放，$U$ 再把结果旋转/反射到输出空间；其存在性的全部突破口是 $A^\top A$ 总为实对称半正定矩阵，故可由谱定理得到右奇异向量与 $\sigma_i=\sqrt{\lambda_i}$，再令 $u_i=Av_i/\sigma_i$ 并用 $N(A^\top)$ 的基补齐 $U$。完全 SVD 展示四个基本子空间，紧 SVD 去掉零方向而无损，截断 SVD 只保留前 $k$ 个方向并把矩阵写成 $\sum_{i=1}^{k}\sigma_iu_iv_i^\top$；引理 $\lVert A\rVert_F^2=\sum_i\sigma_i^2$ 把奇异值平方解释为能量，而定理 15.3 保证截断结果是所有秩不超过 $k$ 的矩阵中平方损失最小者，且最小误差精确等于 $\sqrt{\sigma_{k+1}^2+\cdots+\sigma_r^2}$，因此奇异值衰减越快，低秩压缩越有效；这套“正交方向 + 能量排序 + 最优截断”的框架正是下一章 PCA 与再下一章 LSA 的数学核心。
