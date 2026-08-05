---
title: "《统计学习方法（第 2 版）》附录 A–E：基础数学工具"
date: 2026-08-01 02:23:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-appendices-math-tools
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: statistical-learning-methods
series_order: 24
related: [statistical-learning-methods-ch22-unsupervised-learning-summary]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "串联梯度下降、牛顿与拟牛顿、拉格朗日对偶与 KKT、矩阵基本子空间、KL 散度和 Dirichlet 期望，补齐正文的优化与概率推导工具。"
toc: true
math: true
---

> 本文按原书附录 A–E 的顺序整理：梯度下降、牛顿与拟牛顿、拉格朗日对偶、矩阵基本子空间、KL 散度与 Dirichlet 性质。凡标注 **【补充】** 或 **【辨析】** 的内容为原书之外的严格条件、证明、数值实践或边界说明。

---

## 0. 为什么这些附录必须放在一起理解

五个附录分别支撑正文中的三类核心计算：

| 数学工具 | 解决的问题 | 正文中的典型应用 |
| --- | --- | --- |
| 梯度下降 | 一阶无约束优化 | 逻辑回归、最大熵、一般损失最小化 |
| 牛顿/拟牛顿 | 利用曲率加速优化 | 最大熵、CRF、LDA 超参数估计 |
| 拉格朗日对偶/KKT | 带约束优化 | 最大熵、SVM、概率归一化约束 |
| 四个基本子空间 | 理解矩阵映射、秩与正交 | SVD、PCA、最小二乘 |
| KL/指数族/Dirichlet | 分布差异与期望计算 | EM、变分推理、LDA |

```text
无约束目标 → 梯度 / Newton / 拟 Newton
有约束目标 → Lagrangian → 对偶与 KKT
线性结构 → 行列空间 / 零空间 → SVD
概率近似 → KL → ELBO
共轭指数族 → 对数配分函数导数 → Dirichlet 对数期望
```

---

## 附录 A 梯度下降法

### A.1 要解决什么问题

考虑一阶连续可微函数

$$
f:\mathbb R^n\to\mathbb R,
$$

无约束优化问题为

$$
\min_{x\in\mathbb R^n}f(x).
\qquad\mathrm{(A.1)}
$$

当无法直接解方程 $\nabla f(x)=0$，或维数很高、Hessian 计算昂贵时，使用只需梯度的一阶迭代法。

### A.2 为什么负梯度是最速下降方向

在当前点 $x^{(k)}$ 附近，一阶 Taylor 展开：

$$
f(x^{(k)}+s)
=f(x^{(k)})+\nabla f(x^{(k)})^\top s+o(\|s\|).
\qquad\mathrm{(A.2)}
$$

记

$$
g_k=\nabla f(x^{(k)}).
$$

若只比较欧氏单位方向 $p$，方向导数为

$$
D_pf(x^{(k)})=g_k^\top p,
\qquad \|p\|_2=1.
$$

由 Cauchy–Schwarz：

$$
g_k^\top p\ge-\|g_k\|_2\|p\|_2=-\|g_k\|_2.
$$

等号在

$$
p_k=-\frac{g_k}{\|g_k\|_2}
$$

时成立。因此在欧氏范数定义的单位球内，负梯度给出一阶下降最快方向。

**【边界】** “最速”依赖所选范数和坐标尺度。若用其他范数，最速方向是相应对偶范数问题的解；特征缩放会显著改变普通梯度下降轨迹。

### A.3 更新公式和步长

原书写作

$$
x^{(k+1)}=x^{(k)}+\lambda_kp_k.
\qquad\mathrm{(A.3)}
$$

取 $p_k=-g_k$：

$$
\boxed{x^{(k+1)}=x^{(k)}-\lambda_k\nabla f(x^{(k)})}.
$$

原书使用精确一维搜索：

$$
\lambda_k
=\arg\min_{\lambda\ge0}
f(x^{(k)}+\lambda p_k).
\qquad\mathrm{(A.4)}
$$

精确搜索理论清楚，但每轮本身可能很贵。实践常用固定步长、衰减步长、Armijo 回溯、Wolfe 线搜索或自适应方法。

### A.4 步长为什么不能随便选【补充推导】

若 $f$ 是 $L$-smooth：

$$
\|\nabla f(x)-\nabla f(y)\|_2
\le L\|x-y\|_2,
$$

则下降引理给出

$$
f(y)\le f(x)+\nabla f(x)^\top(y-x)+\frac L2\|y-x\|_2^2.
$$

令 $y=x-\lambda\nabla f(x)$：

$$
\begin{aligned}
f(x-\lambda\nabla f(x))
&\le f(x)-\lambda\|\nabla f(x)\|_2^2+\frac{L\lambda^2}{2}\|\nabla f(x)\|_2^2\\
&=f(x)-\lambda
\left(1-\frac{L\lambda}{2}\right)
\|\nabla f(x)\|_2^2.
\end{aligned}
$$

所以当

$$
0<\lambda<\frac2L
$$

时，非驻点处函数值严格下降；常取 $\lambda\le1/L$ 获得稳健保证。

- 步长过大：越过谷底甚至发散；
- 步长过小：稳定但收敛缓慢；
- 病态曲率：在狭长谷底来回振荡。

### A.5 Armijo 回溯线搜索【补充】

给定下降方向 $p_k$，选择 $0<c<1$、$0<\rho<1$，从步长 1 开始不断令 $\lambda\leftarrow\rho\lambda$，直到

$$
f(x_k+\lambda p_k)
\le f(x_k)+c\lambda g_k^\top p_k.
$$

若 $p_k$ 是下降方向且 $f$ 光滑，足够小的步长必满足条件。

### A.6 算法 A.1

**输入**：目标函数 $f$、梯度 $g=\nabla f$、精度 $\varepsilon$。

1. 取初值 $x^{(0)}$，令 $k=0$；
2. 计算 $g_k=g(x^{(k)})$；
3. 若 $\|g_k\|<\varepsilon$，停止；
4. 取 $p_k=-g_k$，用一维搜索确定 $\lambda_k$；
5. 更新
   $$
   x^{(k+1)}=x^{(k)}+\lambda_kp_k;
   $$
6. 若函数变化或参数变化足够小则停止，否则 $k\leftarrow k+1$。

### A.7 收敛性边界【补充】

| 条件 | 典型结论 |
| --- | --- |
| $f$ 凸且 $L$-smooth，步长 $1/L$ | $f(x_k)-f^*=O(1/k)$ |
| $f$ 为 $\mu$-强凸且 $L$-smooth | 线性/几何收敛 |
| 一般非凸 smooth 函数 | 可保证某种梯度范数趋小，不保证全局最优 |
| 函数非光滑 | 应使用次梯度、近端法等 |

强凸指

$$
f(y)\ge f(x)+\nabla f(x)^\top(y-x)+\frac\mu2\|y-x\|_2^2.
$$

取步长 $1/L$ 时：

$$
f(x_k)-f^*
\le\left(1-\frac\mu L\right)^k
[f(x_0)-f^*].
$$

条件数 $\kappa=L/\mu$ 越大，收敛越慢，这解释了标准化和预条件的重要性。

### A.8 停止条件的误区

- $\|x_{k+1}-x_k\|$ 小可能只是步长太小；
- $|f_{k+1}-f_k|$ 小可能位于平坦区而非最优点；
- $\|\nabla f\|$ 小在非凸问题中可能是极大点或鞍点；
- 应结合梯度、目标变化、参数变化、最大迭代数和验证集表现。

---

## 附录 B 牛顿法和拟牛顿法

### B.1 牛顿法

#### 1. 问题和二阶局部模型

仍考虑

$$
\min_{x\in\mathbb R^n}f(x).
\qquad\mathrm{(B.1)}
$$

假设 $f$ 二阶连续可微。在 $x^{(k)}$ 附近令步长向量 $p=x-x^{(k)}$，二阶 Taylor 近似为

$$
f(x^{(k)}+p)
\approx f(x^{(k)})+g_k^\top p+\frac12p^\top H_kp,
\qquad\mathrm{(B.2)}
$$

其中

$$
g_k=\nabla f(x^{(k)}),
\qquad
H_k=\nabla^2f(x^{(k)}).
\qquad\mathrm{(B.3)}
$$

若 $H_k$ 正定，这个二次模型严格凸。对 $p$ 求梯度：

$$
\nabla_pq_k(p)=g_k+H_kp.
$$

令其为零：

$$
H_kp_k=-g_k.
\qquad\mathrm{(B.10)}
$$

因此

$$
p_k=-H_k^{-1}g_k,
$$

$$
\boxed{
x^{(k+1)}=x^{(k)}-H_k^{-1}g_k
}.
\qquad\mathrm{(B.8)}
$$

实际实现不应显式求逆，而应解线性方程 $H_kp_k=-g_k$。

#### 2. 从求根角度推导

极小点必要条件为

$$
\nabla f(x)=0.
\qquad\mathrm{(B.4)}
$$

对梯度在 $x^{(k)}$ 处线性化：

$$
\nabla f(x)
\approx g_k+H_k(x-x^{(k)}).
\qquad\mathrm{(B.6)}
$$

要求下一点满足线性化方程为零：

$$
g_k+H_k(x^{(k+1)}-x^{(k)})=0,
\qquad\mathrm{(B.7)}
$$

得到同一更新。这说明 Newton 法既是二次模型最小化，也是对一阶最优条件做 Newton 求根。

#### 3. Newton 方向为何下降

若 $H_k$ 正定且 $g_k\ne0$：

$$
g_k^\top p_k
=-g_k^\top H_k^{-1}g_k<0.
$$

所以 $p_k$ 是下降方向。若 Hessian 不定，$p_k$ 可能指向鞍点或使函数上升；若 Hessian 奇异，方向甚至不存在。

稳健做法包括：

- 阻尼 Newton：$x_{k+1}=x_k+\lambda_kp_k$；
- 修正 Hessian：$H_k+\tau I$；
- 信赖域；
- 截断 Newton / 共轭梯度近似求解。

#### 4. 算法 B.1

1. 取 $x^{(0)}$；
2. 计算 $g_k$，若 $\|g_k\|<\varepsilon$ 则停止；
3. 计算 $H_k$，解
   $$
   H_kp_k=-g_k;
   $$
4. 原书取全步 $x^{(k+1)}=x^{(k)}+p_k$；实践常加线搜索；
5. 重复。

#### 5. 收敛边界【补充】

若 $x^*$ 附近 Hessian Lipschitz 连续、$H(x^*)$ 非奇异且初值足够接近，则 Newton 法局部二次收敛：

$$
\|x^{(k+1)}-x^*\|
\le C\|x^{(k)}-x^*\|^2.
$$

“收敛快”是局部结论；远离最优点时二次模型不可靠，必须全局化。

对严格凸二次函数

$$
f(x)=\frac12x^\top Hx-b^\top x+c,
$$

Hessian 恒为 $H$，Newton 一步到达

$$
x^*=H^{-1}b.
$$

### B.2 拟牛顿法的思路

#### 1. 为什么近似 Hessian

Newton 每轮需形成并求解 Hessian，稠密情形存储 $O(n^2)$、分解约 $O(n^3)$。拟牛顿法只用梯度差逐步学习曲率。

记

$$
\delta_k=x^{(k+1)}-x^{(k)},
$$

$$
y_k=g_{k+1}-g_k.
$$

由梯度基本定理：

$$
y_k
=\int_0^1
\nabla^2f(x^{(k)}+t\delta_k)\delta_k\,dt.
$$

若区间内 Hessian 变化不大：

$$
y_k\approx H_k\delta_k.
\qquad\mathrm{(B.12)}
$$

因此 Hessian 近似 $B_{k+1}$ 应满足割线条件

$$
B_{k+1}\delta_k=y_k,
\qquad\mathrm{(B.25)}
$$

逆 Hessian 近似 $G_{k+1}$ 应满足

$$
G_{k+1}y_k=\delta_k.
\qquad\mathrm{(B.16)}
$$

一个向量方程不足以唯一确定矩阵，因此还需对称、正定和“尽量接近旧矩阵”等准则。

#### 2. 曲率条件

正定更新的关键是

$$
\delta_k^\top y_k>0.
$$

若 $f$ 严格凸，该条件自然成立；一般函数可用满足 Wolfe 曲率条件的线搜索保证。若不成立，应跳过、阻尼或修正更新。

### B.3 DFP 算法

DFP 直接更新逆 Hessian 近似 $G_k$。设

$$
G_{k+1}=G_k+P_k+Q_k.
\qquad\mathrm{(B.18)}
$$

为满足 $G_{k+1}y_k=\delta_k$，分别令

$$
P_ky_k=\delta_k,
\qquad\mathrm{(B.20)}
$$

$$
Q_ky_k=-G_ky_k.
\qquad\mathrm{(B.21)}
$$

取两个对称秩一矩阵：

$$
P_k=\frac{\delta_k\delta_k^\top}
{\delta_k^\top y_k},
\qquad\mathrm{(B.22)}
$$

$$
Q_k=-\frac{G_ky_ky_k^\top G_k}
{y_k^\top G_ky_k}.
\qquad\mathrm{(B.23)}
$$

得到 DFP 更新：

$$
\boxed{
G_{k+1}
=G_k+\frac{\delta_k\delta_k^\top}{\delta_k^\top y_k}
-\frac{G_ky_ky_k^\top G_k}{y_k^\top G_ky_k}
}.
\qquad\mathrm{(B.24)}
$$

验证割线条件：

$$
G_{k+1}y_k
=G_ky_k+\delta_k-G_ky_k
=\delta_k.
$$

若 $G_k$ 正定且 $\delta_k^\top y_k>0$，$G_{k+1}$ 仍正定。原因是 DFP 的第二项在 $G_k$ 内积下移除 $y_k$ 方向，第一项再沿 $\delta_k$ 加入正曲率；Cauchy–Schwarz 保证其余子空间非负。

#### 算法 B.2

1. 取 $x^{(0)}$ 和正定对称 $G_0$，常用 $I$；
2. $p_k=-G_kg_k$；
3. 一维搜索得到 $\lambda_k$；
4. $x^{(k+1)}=x^{(k)}+\lambda_kp_k$；
5. 计算 $y_k,\delta_k$，按式 (B.24) 更新 $G$；
6. 直到梯度足够小。

### B.4 BFGS 算法

BFGS 原书先更新 Hessian 近似 $B_k$。设

$$
B_{k+1}=B_k+P_k+Q_k.
\qquad\mathrm{(B.26)}
$$

要求

$$
P_k\delta_k=y_k,
\qquad
Q_k\delta_k=-B_k\delta_k.
$$

得到

$$
\boxed{
B_{k+1}
=B_k+\frac{y_ky_k^\top}{y_k^\top\delta_k}
-\frac{B_k\delta_k\delta_k^\top B_k}
{\delta_k^\top B_k\delta_k}
}.
\qquad\mathrm{(B.30)}
$$

它满足

$$
B_{k+1}\delta_k=y_k.
$$

若 $B_k$ 正定且 $y_k^\top\delta_k>0$，则 $B_{k+1}$ 正定。

#### 算法 B.3

1. 取 $x^{(0)}$ 和正定对称 $B_0$，常用 $I$；
2. 计算 $g_k$，若 $\|g_k\|<\varepsilon$ 则停止；
3. 解

$$
B_kp_k=-g_k,
$$

   得到下降方向；
4. 一维搜索得到 $\lambda_k$，更新
   $$
   x^{(k+1)}=x^{(k)}+\lambda_kp_k;
   $$
5. 计算 $g_{k+1},y_k,\delta_k$，若未收敛则按式 (B.30) 更新 $B_{k+1}$；
6. 继续迭代。

实践更常直接维护逆近似。令

$$
\rho_k=\frac1{y_k^\top\delta_k},
$$

则 Sherman–Morrison–Woodbury 公式给出

$$
\boxed{
G_{k+1}
=(I-\rho_k\delta_ky_k^\top)
G_k
(I-\rho_ky_k\delta_k^\top)+\rho_k\delta_k\delta_k^\top
}.
\qquad\mathrm{(B.31)}
$$

这个形式数值稳定、对称性清楚，并直接用于 $p_k=-G_kg_k$。

### B.5 Broyden 类算法

记 DFP 和 BFGS 的逆 Hessian 更新分别为

$$
G_{k+1}^{DFP},
\qquad
G_{k+1}^{BFGS}.
$$

二者都满足 $Gy=\delta$，所以线性组合也满足：

$$
G_{k+1}
=\xi G_{k+1}^{DFP}+(1-\xi)G_{k+1}^{BFGS},
\quad0\le\xi\le1.
\qquad\mathrm{(B.32)}
$$

正定矩阵的凸组合仍正定，这形成 Broyden 类。

### B.6 方法比较与适用边界

| 方法 | 每轮信息 | 存储 | 局部速度 | 主要风险 |
| --- | --- | --- | --- | --- |
| 梯度下降 | 梯度 | $O(n)$ | 线性或更慢 | 病态方向慢 |
| Newton | 梯度 + Hessian | $O(n^2)$ | 二次 | Hessian 不定/昂贵 |
| DFP | 梯度差 | $O(n^2)$ | 超线性条件下可达 | 数值上通常不如 BFGS |
| BFGS | 梯度差 | $O(n^2)$ | 常见超线性 | 需曲率条件 |
| L-BFGS【补充】 | 少量历史向量 | $O(mn)$ | 实践高效 | 曲率近似有限 |

Newton 与拟 Newton 都是局部模型法。对非凸目标，线搜索、信赖域和正定修正不是可选装饰，而是全局稳定性的必要机制。

---

## 附录 C 拉格朗日对偶性

### C.1 原始问题

考虑

$$
\min_{x\in\mathbb R^n}f(x)
\qquad\mathrm{(C.1)}
$$

满足

$$
c_i(x)\le0,
\quad i=1,\ldots,k,
\qquad\mathrm{(C.2)}
$$

$$
h_j(x)=0,
\quad j=1,\ldots,l.
\qquad\mathrm{(C.3)}
$$

广义 Lagrangian：

$$
L(x,\alpha,\beta)
=f(x)+\sum_{i=1}^{k}\alpha_i c_i(x)+\sum_{j=1}^{l}\beta_j h_j(x),
\qquad\mathrm{(C.4)}
$$

其中不等式乘子要求

$$
\alpha_i\ge0,
$$

等式乘子 $\beta_j$ 可取任意实数。

定义

$$
   heta_P(x)
=\sup_{\alpha\ge0,\beta}L(x,\alpha,\beta).
\qquad\mathrm{(C.5)}
$$

为什么它等价于约束惩罚？

- 若 $x$ 可行，$c_i(x)\le0,h_j(x)=0$，最大值在 $\alpha=0$ 处给 $f(x)$；
- 若某 $c_i(x)>0$，令对应 $\alpha_i\to\infty$，上确界为 $+\infty$；
- 若某 $h_j(x)\ne0$，选择 $\beta_j$ 与它同号并令绝对值趋于无穷，上确界也是 $+\infty$。

故

$$
   heta_P(x)=
\begin{cases}
f(x),&x\text{ 可行},\\
{+}\infty,&x\text{ 不可行}.
\end{cases}
\qquad\mathrm{(C.7)}
$$

原问题等价于

$$
p^*
=\inf_x\sup_{\alpha\ge0,\beta}L(x,\alpha,\beta).
\qquad\mathrm{(C.8)/(C.9)}
$$

### C.2 对偶问题

定义对偶函数

$$
   heta_D(\alpha,\beta)
=\inf_xL(x,\alpha,\beta).
\qquad\mathrm{(C.10)}
$$

它是仿射函数族关于 $(\alpha,\beta)$ 的逐点下确界，因此无论原问题是否凸，$\theta_D$ 总是凹函数。

对偶问题为

$$
d^*
=\sup_{\alpha\ge0,\beta}
   heta_D(\alpha,\beta)
=\sup_{\alpha\ge0,\beta}\inf_xL(x,\alpha,\beta).
\qquad\mathrm{(C.11)-(C.14)}
$$

对偶的作用：

- 给原问题最优值下界；
- 有时比原问题更易求解；
- 揭示支持向量、影子价格和约束敏感性；
- 允许核技巧等只依赖内积的重参数化。

### C.3 弱对偶（定理 C.1）

对任意对偶可行 $(\alpha,\beta)$ 和原始可行 $x$：

$$
   heta_D(\alpha,\beta)
=\inf_zL(z,\alpha,\beta)
\le L(x,\alpha,\beta).
$$

因 $c_i(x)\le0$、$\alpha_i\ge0$、$h_j(x)=0$：

$$
L(x,\alpha,\beta)
=f(x)+\sum_i\alpha_i c_i(x)
\le f(x).
$$

所以

$$
   heta_D(\alpha,\beta)\le f(x).
$$

对左侧取上确界、右侧取下确界：

$$
\boxed{d^*\le p^*}.
\qquad\mathrm{(C.15)}
$$

这就是弱对偶，对凸与非凸问题都成立。差

$$
p^*-d^*\ge0
$$

称为对偶间隙。

若找到原始可行 $x$、对偶可行 $(\alpha,\beta)$ 且目标值相等，它们立即都是最优解（推论 C.1），这是可验证最优性的证书。

### C.4 强对偶与 Slater 条件（定理 C.2）

若

- $f,c_i$ 为凸函数；
- $h_j$ 为仿射函数；
- 存在严格可行点 $\bar x$，使所有不等式 $c_i(\bar x)<0$ 且等式成立；

则 Slater 条件保证

$$
\boxed{p^*=d^*=L(x^*,\alpha^*,\beta^*)}.
\qquad\mathrm{(C.20)}
$$

原书定理 C.2 把所有不等式都要求严格可行。更一般版本允许仿射不等式不严格；核心是相对内部非空等约束资格条件。

**【边界】** 凸性本身不总保证强对偶，仍需适当约束资格；非凸问题即使有 KKT 点也可能存在正对偶间隙。

### C.5 KKT 条件（定理 C.3）

在上述凸性与 Slater 条件下，最优解当且仅当满足：

1. **驻点**
   $$
   \nabla_xL(x^*,\alpha^*,\beta^*)=0;
   \qquad\mathrm{(C.21)}
   $$
2. **互补松弛**
   $$
   \alpha_i^*c_i(x^*)=0;
   \qquad\mathrm{(C.22)}
   $$
3. **原始可行**
   $$
   c_i(x^*)\le0,
   \quad h_j(x^*)=0;
   \qquad\mathrm{(C.23),(C.25)}
   $$
4. **对偶可行**
   $$
   \alpha_i^*\ge0.
   \qquad\mathrm{(C.24)}
   $$

互补松弛含义：

$$
\alpha_i^*>0\Longrightarrow c_i(x^*)=0,
$$

$$
c_i(x^*)<0\Longrightarrow\alpha_i^*=0.
$$

只有活跃约束才能有正影子价格。

#### 为什么 KKT 足够【补充证明】

若 $f,c_i$ 凸、$h_j$ 仿射，驻点说明 $x^*$ 是凸函数

$$
L(x,\alpha^*,\beta^*)
$$

的全局极小点，因此

$$
   heta_D(\alpha^*,\beta^*)
=L(x^*,\alpha^*,\beta^*).
$$

由原始可行和互补松弛：

$$
L(x^*,\alpha^*,\beta^*)=f(x^*).
$$

于是对偶值等于原始值，弱对偶迫使二者最优。

#### 一个数值例子

求

$$
\min_x (x-2)^2
\quad\text{s.t.}\quad x\le1.
$$

令 $c(x)=x-1$：

$$
L(x,\alpha)=(x-2)^2+\alpha(x-1),
\quad\alpha\ge0.
$$

KKT：

$$
2(x-2)+\alpha=0,
$$

$$
\alpha(x-1)=0,
\quad x\le1,
\quad\alpha\ge0.
$$

无约束解 $x=2$ 不可行，所以约束活跃：$x^*=1$，进而 $\alpha^*=2$，最优值 $p^*=1$。

### C.6 常见误解

- Lagrange 乘子不是随意惩罚系数，而是对偶变量；
- 弱对偶永远成立，强对偶需要条件；
- KKT 在一般非凸问题中通常只是局部最优的必要条件，不充分；
- 互补松弛不是“约束都取等号”，只有正乘子对应约束活跃；
- 等式乘子不要求非负；
- 实现时 `min`/`max` 可能只达到下确界/上确界，严格写法应使用 $\inf/\sup$。

---

## 附录 D 矩阵的基本子空间

设

$$
A\in\mathbb R^{m\times n}
$$

表示线性映射

$$
A:\mathbb R^n\to\mathbb R^m.
$$

### D.1 子空间、基与维数

非空集合 $S\subseteq V$ 是子空间，当且仅当对任意 $x,y\in S$ 与标量 $a,b$：

$$
ax+by\in S.
$$

原书分成“数乘封闭”和“加法封闭”，合并形式更简洁。

向量 $v_1,\ldots,v_r$ 的张成为

$$
\operatorname{span}(v_1,\ldots,v_r)
=\left\{\sum_{i=1}^{r}a_iv_i:a_i\in\mathbb R\right\}.
$$

若一组向量线性无关且张成 $V$，称为 $V$ 的基；任一基的向量数相同，定义为空间维数。

### D.2 行空间、列空间与秩

- 列空间/值域：
  $$
  R(A)=\{Ax:x\in\mathbb R^n\}
  \subseteq\mathbb R^m;
  \qquad\mathrm{(D.3)}
  $$
- 行空间：
  $$
  R(A^\top)=\{A^\top y:y\in\mathbb R^m\}
  \subseteq\mathbb R^n.
  \qquad\mathrm{(D.4)}
  $$

行秩等于列秩，统一称

$$
r=\operatorname{rank}(A).
$$

可由消元证明：行最简形中主元个数既是独立行数也是独立列数；也可由 SVD 证明，见后文。

### D.3 零空间与秩–零度定理

零空间：

$$
N(A)=\{x\in\mathbb R^n:Ax=0\}.
\qquad\mathrm{(D.1)}
$$

其维数称为零度。若秩为 $r$，消元后有 $r$ 个主元变量、$n-r$ 个自由变量，因此

$$
\boxed{
\operatorname{rank}(A)+\dim N(A)=n
}.
$$

这不是“独立变量个数为 $r$”这么简单：每个自由变量对应零空间的一条基向量，所有齐次解是它们的线性组合。

对转置同理：

$$
\operatorname{rank}(A)+\dim N(A^\top)=m.
$$

### D.4 正交补

子空间 $Y\subseteq\mathbb R^n$ 的正交补为

$$
Y^\perp
=\{x\in\mathbb R^n:x^\top y=0,
\ \forall y\in Y\}.
\qquad\mathrm{(D.2)}
$$

$Y^\perp$ 也是子空间，并有

$$
\dim Y+\dim Y^\perp=n,
$$

$$
(Y^\perp)^\perp=Y
$$

（有限维闭子空间）。

### D.5 四个基本子空间（定理 D.1）

| 空间 | 所在环境 | 维数 | SVD 基 |
| --- | --- | ---: | --- |
| 行空间 $R(A^\top)$ | $\mathbb R^n$ | $r$ | $v_1,\ldots,v_r$ |
| 零空间 $N(A)$ | $\mathbb R^n$ | $n-r$ | $v_{r+1},\ldots,v_n$ |
| 列空间 $R(A)$ | $\mathbb R^m$ | $r$ | $u_1,\ldots,u_r$ |
| 左零空间 $N(A^\top)$ | $\mathbb R^m$ | $m-r$ | $u_{r+1},\ldots,u_m$ |

核心关系：

$$
\boxed{N(A)=R(A^\top)^\perp},
\qquad\mathrm{(D.5)}
$$

$$
\boxed{N(A^\top)=R(A)^\perp}.
\qquad\mathrm{(D.6)}
$$

#### 直接证明

若 $x\in N(A)$，则 $Ax=0$。对任意行空间向量 $A^\top y$：

$$
x^\top A^\top y=(Ax)^\top y=0,
$$

故 $x\perp R(A^\top)$，即

$$
N(A)\subseteq R(A^\top)^\perp.
$$

反之，若 $x\perp R(A^\top)$，则它与 $A^\top$ 的每个列向量正交，也就是与 $A$ 每一行正交，所以 $Ax=0$。两集合相等。

第二个关系对 $A^\top$ 重复同一证明。

#### SVD 证明与几何意义【补充】

若

$$
A=U\Sigma V^\top,
$$

秩为 $r$，则

$$
Av_i=\sigma_i u_i,
\quad i\le r,
$$

$$
Av_i=0,
\quad i>r.
$$

因此 $V$ 的前 $r$ 列张成行空间，后 $n-r$ 列张成零空间；它们本来就是正交规范基。$U$ 对列空间与左零空间同理。

线性映射 $A$：

1. 把定义域分成“可见的行空间方向”和“被压成 0 的零空间方向”；
2. 把行空间中的 $v_i$ 沿奇异值缩放并旋转到列空间中的 $u_i$；
3. 输出永远没有左零空间分量。

### D.6 最小二乘与基本子空间【补充】

求

$$
\min_x\|Ax-b\|_2^2.
$$

残差 $r=b-Ax$ 在最优点满足

$$
A^\top r=0,
$$

即

$$
r\in N(A^\top)=R(A)^\perp.
$$

所以 $Ax^*$ 是 $b$ 在列空间上的正交投影，正规方程为

$$
A^\top Ax=A^\top b.
$$

若 $A$ 不满列秩，解不唯一；所有解相差零空间向量。Moore–Penrose 伪逆给最小范数解

$$
x^*=A^+b.
$$

### D.7 常见误解

- 行空间在 $\mathbb R^n$，列空间在 $\mathbb R^m$，通常不能直接说二者正交；
- 与零空间正交的是行空间，与左零空间正交的是列空间；
- 秩是行/列空间维数，零度是零空间维数；
- $A^\top A$ 会平方条件数，数值最小二乘更宜用 QR 或 SVD；
- 零空间非平凡意味着映射不单射，左零空间非平凡意味着映射不满射。

---

## 附录 E KL 散度的定义和 Dirichlet 分布的性质

### E.1 KL 散度的定义

#### 1. 离散与连续形式

离散分布 $Q,P$：

$$
D_{KL}(Q\Vert P)
=\sum_xQ(x)\log\frac{Q(x)}{P(x)}.
\qquad\mathrm{(E.1)}
$$

连续密度：

$$
D_{KL}(Q\Vert P)
=\int q(x)\log\frac{q(x)}{p(x)}dx.
\qquad\mathrm{(E.2)}
$$

约定 $0\log(0/p)=0$。若存在集合使 $Q$ 给正概率而 $P$ 给零概率，则

$$
D_{KL}(Q\Vert P)=+\infty.
$$

严格地说，有限 KL 要求 $Q$ 关于 $P$ 绝对连续，记作 $Q\ll P$。

#### 2. KL 为什么非负

利用凹函数 $\log$ 和 Jensen：

$$
\begin{aligned}
-D_{KL}(Q\Vert P)
&=E_Q\left[\log\frac{p(X)}{q(X)}\right]\\
&\le\log E_Q\left[\frac{p(X)}{q(X)}\right]\\
&=\log\int q(x)\frac{p(x)}{q(x)}dx\\
&=\log\int p(x)dx=0.
\end{aligned}
\qquad\mathrm{(E.3)}
$$

因此

$$
\boxed{D_{KL}(Q\Vert P)\ge0}.
$$

由于 $\log$ 严格凹，Jensen 等号要求 $p(x)/q(x)$ 在 $Q$ 支持上几乎处处为常数。归一化迫使常数为 1，故当且仅当 $P=Q$ 几乎处处时 KL 为 0。

也可用

$$
-\log t\ge1-t
$$

令 $t=p/q$ 得到 Gibbs 不等式。

#### 3. 为什么 KL 不是距离

- 一般
   $$
   D_{KL}(Q\Vert P)\ne D_{KL}(P\Vert Q);
   $$
- 不满足三角不等式；
- 数值可为无穷；
- 连续情形依赖测度下的密度比，但在可逆变量变换下保持不变。

例如 Bernoulli 分布：

$$
D_{KL}(\operatorname{Ber}(q)\Vert\operatorname{Ber}(p))
=q\log\frac qp+(1-q)\log\frac{1-q}{1-p}.
$$

取 $q=0.9,p=0.5$ 与反向计算，数值不同。

#### 4. 与交叉熵、最大似然的关系【补充】

离散情形

$$
D_{KL}(Q\Vert P)=H(Q,P)-H(Q),
$$

其中

$$
H(Q,P)=-E_Q[\log P(X)]
$$

是交叉熵，$H(Q)$ 与模型 $P$ 无关。因此固定经验分布 $Q$ 时，最小化 KL 等价于最小化负对数似然。

这连接了：

- PLSA 极大似然与 KL-NMF；
- 分类交叉熵与条件极大似然；
- 变分推理中的后验 KL。

#### 5. KL 方向为何重要【补充】

变分推理常最小化

$$
D_{KL}(q\Vert p).
$$

若 $q$ 在 $p$ 很小处放质量，惩罚很大；若 $q$ 漏掉 $p$ 的某个模式却在那里取 0，该区域不进入 $E_q$。因此反向 KL 常“找一个模式”并低估方差。

相反

$$
D_{KL}(p\Vert q)
$$

要求 $q$ 覆盖 $p$ 的所有有质量区域，更偏向质量覆盖。两者没有普遍优劣，取决于近似目标。

### E.2 指数分布族

指数族写作

$$
p(x\mid\eta)
=h(x)\exp\{\eta^\top T(x)-A(\eta)\}.
\qquad\mathrm{(E.4)}
$$

- $\eta$：自然参数；
- $T(x)$：充分统计量；
- $h(x)$：基准测度；
- $A(\eta)$：对数规范化因子。

规范化要求

$$
A(\eta)
=\log\int h(x)e^{\eta^\top T(x)}dx.
$$

### E.3 配分函数一阶导数等于充分统计量期望

在可交换微分与积分的正则条件下：

$$
\begin{aligned}
\nabla_\eta A(\eta)
&=\frac{
\int T(x)h(x)e^{\eta^\top T(x)}dx
}{
\int h(x)e^{\eta^\top T(x)}dx
}\\
&=\int T(x)
h(x)e^{\eta^\top T(x)-A(\eta)}dx\\
&=E_\eta[T(X)].
\end{aligned}
\qquad\mathrm{(E.5)}
$$

这使很多期望无需直接积分，只需对 $A$ 求导。

进一步求二阶导【补充】：

$$
\nabla_\eta^2A(\eta)
=\operatorname{Cov}_\eta[T(X)]\succeq0.
$$

所以 $A$ 是凸函数；若充分统计量无冗余，协方差正定，$A$ 严格凸。这也是自然参数到均值参数映射的基础。

### E.4 Dirichlet 分布属于指数族

设

$$
   heta\sim\operatorname{Dir}(\alpha),
\qquad
\alpha_0=\sum_{k=1}^{K}\alpha_k.
$$

密度为

$$
p(\theta\mid\alpha)
=\frac{\Gamma(\alpha_0)}
{\prod_{k=1}^{K}\Gamma(\alpha_k)}
\prod_{k=1}^{K}\theta_k^{\alpha_k-1}.
$$

写成指数形式：

$$
\begin{aligned}
p(\theta\mid\alpha)
=\exp\Bigg\{
&\sum_{k=1}^{K}(\alpha_k-1)\log\theta_k\\
&+\log\Gamma(\alpha_0)
-\sum_{k=1}^{K}\log\Gamma(\alpha_k)
\Bigg\}.
\end{aligned}
\qquad\mathrm{(E.6)}
$$

对应：

$$
\eta_k=\alpha_k-1,
\qquad
T_k(\theta)=\log\theta_k,
$$

$$
A(\alpha)
=\sum_{k=1}^{K}\log\Gamma(\alpha_k)
-\log\Gamma(\alpha_0).
$$

注意严格自然参数是 $\eta=\alpha-1$，但对 $\alpha$ 求导与对 $\eta$ 求导相同，因为 $d\eta_k/d\alpha_k=1$。

### E.5 Dirichlet 对数期望

由式 (E.5)：

$$
E[\log\theta_k]
=\frac{\partial A(\alpha)}{\partial\alpha_k}.
$$

定义 digamma 函数

$$
\psi(x)=\frac{d}{dx}\log\Gamma(x).
$$

则

$$
\begin{aligned}
E[\log\theta_k]
&=\frac{\partial}{\partial\alpha_k}
\left[
\sum_j\log\Gamma(\alpha_j)
-\log\Gamma(\alpha_0)
\right]\\
&=\psi(\alpha_k)-\psi(\alpha_0).
\end{aligned}
$$

所以

$$
\boxed{
E_{Dir(\alpha)}[\log\theta_k]
=\psi(\alpha_k)-\psi\left(\sum_j\alpha_j\right)
}.
\qquad\mathrm{(E.7)}
$$

这正是 LDA 变分更新

$$
\eta_{nk}
\propto\phi_{k,w_n}
\exp\{E_q[\log\theta_k]\}
$$

中的关键期望。

### E.6 为什么 $E[\log\theta_k]\ne\log E[\theta_k]$

因 $\log$ 凹，Jensen 给出

$$
E[\log\theta_k]
\le\log E[\theta_k]
=\log\frac{\alpha_k}{\alpha_0}.
$$

只有 $\theta_k$ 几乎确定时接近等号。变分推理必须使用 digamma 期望，不能用后验均值取对数替代。

### E.7 二阶性质【补充】

定义 trigamma

$$
\psi_1(x)=\psi'(x)>0.
$$

由 $\nabla^2A=\operatorname{Cov}(T)$：

$$
\operatorname{Cov}(\log\theta_i,\log\theta_j)
=\mathbf1(i=j)\psi_1(\alpha_i)
-\psi_1(\alpha_0).
$$

这也解释 LDA 变分 EM 中更新 $\alpha$ 的 Hessian 为“对角项加共享秩一项”。

### E.8 常见误解

- KL 非负不代表对称或满足三角不等式；
- 连续分布 KL 用密度比，单独的微分熵可为负但 KL 不会；
- $D_{KL}(q\Vert p)$ 有限要求 $q$ 的支持包含于 $p$ 支持；
- 指数族不等于“密度长得像指数函数”，关键是自然参数与充分统计量的线性内积；
- $\nabla A$ 给充分统计量均值，$\nabla^2A$ 给协方差；
- Dirichlet 的 $E[\theta]$ 与 $E[\log\theta]$ 是不同公式。

---

## 综合代码：验证附录 A–E 的核心结论

下面只使用 Python 标准库：

- 在 Rosenbrock 函数上比较梯度下降、Newton、DFP、BFGS；
- 验证拟牛顿割线条件；
- 验证约束例子的 KKT 残差；
- 验证四个基本子空间的正交关系；
- 验证 KL 非负但不对称；
- 用 Gamma 归一化抽样验证 Dirichlet 均值与对数期望。

```python
"""《统计学习方法》附录 A-E：优化、对偶、子空间与概率工具。"""
import math
import random


def dot(left, right):
   return sum(a * b for a, b in zip(left, right))


def norm(vector):
   return math.sqrt(dot(vector, vector))


def add(left, right):
   return [a + b for a, b in zip(left, right)]


def scale(value, vector):
   return [value * item for item in vector]


def matvec(matrix, vector):
   return [dot(row, vector) for row in matrix]


def outer(left, right):
   return [[a * b for b in right] for a in left]


def matadd(*matrices):
   return [[sum(matrix[i][j] for matrix in matrices)
          for j in range(len(matrices[0][0]))]
         for i in range(len(matrices[0]))]


def matscale(value, matrix):
   return [[value * item for item in row] for row in matrix]


def solve_2x2(matrix, right):
   determinant = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
   return [
      (right[0] * matrix[1][1] - matrix[0][1] * right[1]) / determinant,
      (matrix[0][0] * right[1] - right[0] * matrix[1][0]) / determinant,
   ]


def rosenbrock(point):
   x, y = point
   return (1.0 - x) ** 2 + 100.0 * (y - x * x) ** 2


def rosenbrock_gradient(point):
   x, y = point
   return [-2.0 * (1.0 - x) - 400.0 * x * (y - x * x),
         200.0 * (y - x * x)]


def rosenbrock_hessian(point):
   x, y = point
   return [[2.0 - 400.0 * y + 1200.0 * x * x, -400.0 * x],
         [-400.0 * x, 200.0]]


def armijo(point, direction, gradient, initial=1.0):
   """附录 A：回溯到充分下降。"""
   step = initial
   slope = dot(gradient, direction)
   while rosenbrock(add(point, scale(step, direction))) > (
      rosenbrock(point) + 1e-4 * step * slope
   ):
      step *= 0.5
   return step


def gradient_descent(initial, tolerance=1e-6, max_iterations=100_000):
   point = initial[:]
   for iteration in range(max_iterations):
      gradient = rosenbrock_gradient(point)
      if norm(gradient) < tolerance:
         return point, iteration
      direction = scale(-1.0, gradient)
      point = add(point, scale(armijo(point, direction, gradient), direction))
   raise RuntimeError("梯度下降未收敛")


def newton(initial, tolerance=1e-9, max_iterations=100):
   point = initial[:]
   for iteration in range(max_iterations):
      gradient = rosenbrock_gradient(point)
      if norm(gradient) < tolerance:
         return point, iteration
      direction = solve_2x2(rosenbrock_hessian(point), scale(-1.0, gradient))
      # Hessian 不定时回退到负梯度，保证是下降方向。
      if dot(gradient, direction) >= 0.0:
         direction = scale(-1.0, gradient)
      point = add(point, scale(armijo(point, direction, gradient), direction))
   raise RuntimeError("Newton 法未收敛")


def quasi_newton(initial, update, tolerance=1e-7, max_iterations=1_000):
   """附录 B：维护逆 Hessian 近似 G。"""
   point = initial[:]
   inverse_hessian = [[1.0, 0.0], [0.0, 1.0]]
   secant_residual = math.inf
   for iteration in range(max_iterations):
      gradient = rosenbrock_gradient(point)
      if norm(gradient) < tolerance:
         return point, iteration, secant_residual
      direction = scale(-1.0, matvec(inverse_hessian, gradient))
      if dot(gradient, direction) >= 0.0:
         inverse_hessian = [[1.0, 0.0], [0.0, 1.0]]
         direction = scale(-1.0, gradient)
      step = armijo(point, direction, gradient)
      new_point = add(point, scale(step, direction))
      new_gradient = rosenbrock_gradient(new_point)
      delta = add(new_point, scale(-1.0, point))
      y = add(new_gradient, scale(-1.0, gradient))
      curvature = dot(delta, y)
      if curvature > 1e-12:
         inverse_hessian = update(inverse_hessian, delta, y)
         secant_residual = norm(add(matvec(inverse_hessian, y), scale(-1.0, delta)))
      point = new_point
   raise RuntimeError("拟 Newton 法未收敛")


def dfp_update(inverse_hessian, delta, y):
   gy = matvec(inverse_hessian, y)
   return matadd(
      inverse_hessian,
      matscale(1.0 / dot(delta, y), outer(delta, delta)),
      matscale(-1.0 / dot(y, gy), outer(gy, gy)),
   )


def bfgs_update(inverse_hessian, delta, y):
   """BFGS 逆矩阵更新的等价展开式。"""
   rho = 1.0 / dot(delta, y)
   gy = matvec(inverse_hessian, y)
   coefficient = (1.0 + dot(y, gy) * rho) * rho
   return matadd(
      inverse_hessian,
      matscale(coefficient, outer(delta, delta)),
      matscale(-rho, outer(delta, gy)),
      matscale(-rho, outer(gy, delta)),
   )


def bernoulli_kl(q, p):
   return q * math.log(q / p) + (1.0 - q) * math.log((1.0 - q) / (1.0 - p))


def digamma(value):
   result = 0.0
   while value < 8.0:
      result -= 1.0 / value
      value += 1.0
   inverse = 1.0 / value
   inverse2 = inverse * inverse
   return (result + math.log(value) - 0.5 * inverse
         - inverse2 * (1.0 / 12.0
                    - inverse2 * (1.0 / 120.0 - inverse2 / 252.0)))


def dirichlet_sample(alpha, rng):
   values = [rng.gammavariate(item, 1.0) for item in alpha]
   total = sum(values)
   return [item / total for item in values]


print("【附录 A-B：Rosenbrock 优化】")
initial = [-1.2, 1.0]
for name, optimizer in [
   ("gradient", gradient_descent),
   ("Newton", newton),
]:
   point, iterations = optimizer(initial)
   print(f"{name:8}: x={[round(v, 8) for v in point]}, "
        f"f={rosenbrock(point):.3e}, iterations={iterations}")
for name, update in [("DFP", dfp_update), ("BFGS", bfgs_update)]:
   point, iterations, residual = quasi_newton(initial, update)
   print(f"{name:8}: x={[round(v, 8) for v in point]}, "
        f"f={rosenbrock(point):.3e}, iterations={iterations}, "
        f"secant={residual:.3e}")

print("\n【附录 C：KKT】")
x_star, alpha_star = 1.0, 2.0
stationarity = 2.0 * (x_star - 2.0) + alpha_star
complementarity = alpha_star * (x_star - 1.0)
print("x* =", x_star, "alpha* =", alpha_star, "objective =", (x_star - 2.0) ** 2)
print("stationarity residual =", stationarity)
print("complementarity residual =", complementarity)

print("\n【附录 D：四个基本子空间】")
row_basis = [1.0, 2.0, 3.0]
null_basis = [[-2.0, 1.0, 0.0], [-3.0, 0.0, 1.0]]
column_basis = [1.0, 2.0]
left_null_basis = [-2.0, 1.0]
print("rank = 1, nullity = 2, left nullity = 1")
print("row-null dot products =", [dot(row_basis, vector) for vector in null_basis])
print("column-left-null dot =", dot(column_basis, left_null_basis))

print("\n【附录 E：KL 与 Dirichlet】")
forward = bernoulli_kl(0.9, 0.5)
reverse = bernoulli_kl(0.5, 0.9)
print(f"KL(Ber(0.9)||Ber(0.5)) = {forward:.6f}")
print(f"KL(Ber(0.5)||Ber(0.9)) = {reverse:.6f}")
rng = random.Random(24)
alpha = [2.0, 3.0, 5.0]
samples = [dirichlet_sample(alpha, rng) for _ in range(100_000)]
sample_mean = [sum(row[k] for row in samples) / len(samples) for k in range(3)]
sample_log_mean = [sum(math.log(row[k]) for row in samples) / len(samples)
               for k in range(3)]
theory_log_mean = [digamma(value) - digamma(sum(alpha)) for value in alpha]
print("Dirichlet sample mean =", [round(value, 6) for value in sample_mean])
print("Dirichlet theory mean = [0.2, 0.3, 0.5]")
print("E[log theta] sample =", [round(value, 6) for value in sample_log_mean])
print("E[log theta] theory =", [round(value, 6) for value in theory_log_mean])
```

运行输出：

```text
【附录 A-B：Rosenbrock 优化】
gradient: x=[0.99999922, 0.99999843], f=6.120e-13, iterations=13756
Newton  : x=[1.0, 1.0], f=3.744e-21, iterations=21
DFP     : x=[1.0, 1.0], f=7.345e-18, iterations=49, secant=1.084e-19
BFGS    : x=[1.0, 0.99999999], f=2.746e-17, iterations=34, secant=2.424e-19

【附录 C：KKT】
x* = 1.0 alpha* = 2.0 objective = 1.0
stationarity residual = 0.0
complementarity residual = 0.0

【附录 D：四个基本子空间】
rank = 1, nullity = 2, left nullity = 1
row-null dot products = [0.0, 0.0]
column-left-null dot = 0.0

【附录 E：KL 与 Dirichlet】
KL(Ber(0.9)||Ber(0.5)) = 0.368064
KL(Ber(0.5)||Ber(0.9)) = 0.510826
Dirichlet sample mean = [0.199779, 0.30054, 0.499681]
Dirichlet theory mean = [0.2, 0.3, 0.5]
E[log theta] sample = [-1.831277, -1.327812, -0.746202]
E[log theta] theory = [-1.828968, -1.328968, -0.745635]
```

实验清楚展示：曲率信息大幅减少优化迭代；DFP/BFGS 更新满足割线条件；KKT 和子空间关系可用残差验证；KL 的两个方向不同；Dirichlet 的 $E[\theta]$ 与 $E[\log\theta]$ 都吻合理论。

---

## 五个附录之间的关系

### 1. 从目标结构选择优化方法

```text
目标是否有约束？
├─ 无约束
│  ├─ 只有一阶梯度：梯度下降 / L-BFGS
│  ├─ Hessian 可算且规模适中：Newton
│  └─ Hessian 太贵：BFGS / DFP
└─ 有约束
   ├─ 凸且满足约束资格：对偶 + KKT
   ├─ 简单投影集合：投影/近端方法【补充】
   └─ 一般非线性约束：SQP、内点法【补充】
```

线性代数结构决定优化难度：Hessian 的零空间意味着局部平坦或不可识别方向；条件数决定梯度下降速度；正交分解与预条件可以改善几何。

### 2. 从概率目标连接 KL 与优化

最大似然可以写成经验分布到模型分布的 KL 最小化；变分推理把难后验近似转成 KL 最小化与 ELBO 最大化；指数族让所需期望变成对数配分函数导数。

$$
   ext{最大似然}
\Longleftrightarrow
\min D_{KL}(\widehat P\Vert P_\theta),
$$

$$
\log p(x)
=\operatorname{ELBO}(q)+D_{KL}(q(z)\Vert p(z\mid x)).
$$

优化附录给出“怎么最大化 ELBO”，附录 E 解释“为什么这是下界以及如何计算期望”。

### 3. 对偶与子空间的联系【补充】

等式约束

$$
Ax=b
$$

的 Lagrangian 为

$$
L(x,\beta)=f(x)+\beta^\top(Ax-b).
$$

驻点条件

$$
\nabla f(x)+A^\top\beta=0
$$

说明最优点梯度位于 $R(A^\top)$，即约束法向量张成的行空间。可行方向满足

$$
A\delta=0,
$$

即属于 $N(A)$。因为

$$
N(A)=R(A^\top)^\perp,
$$

驻点梯度与所有一阶可行方向正交。这给 KKT 驻点一个清楚的几何解释。

## 常见误解辨析

1. **负梯度在任何意义下都是最快方向。** 它只是在所选欧氏度量下最速；预条件会改变度量。
2. **步长越大收敛越快。** 超过稳定区间会振荡或发散。
3. **梯度为零就是局部最小。** 也可能是极大点或鞍点，需看 Hessian 或更高阶结构。
4. **Newton 法总比梯度下降好。** Hessian 不定、奇异或过大时可能更差且更贵。
5. **实现 Newton 应计算 $H^{-1}$。** 应解线性方程，显式求逆更慢且更不稳定。
6. **DFP/BFGS 不需要线搜索。** 正定保持依赖曲率条件，Wolfe 线搜索很重要。
7. **DFP 更新 Hessian，BFGS 更新逆 Hessian。** 原书 DFP 更新逆近似 $G$，BFGS 先更新 Hessian 近似 $B$；二者都有对应的逆形式。
8. **弱对偶只对凸问题成立。** 弱对偶对任何原问题成立；强对偶才依赖条件。
9. **KKT 对所有问题都是充分必要条件。** 在凸性和适当约束资格下才充分必要；非凸时通常只必要。
10. **互补松弛表示所有约束都活跃。** 它表示乘子与松弛量不能同时非零。
11. **行空间与列空间彼此正交。** 它们通常位于不同环境空间；行空间正交于零空间，列空间正交于左零空间。
12. **秩低只表示列相关。** 行秩与列秩相等，低秩同时限制输入可见方向和输出可达方向。
13. **KL 是概率分布之间的距离。** 它非对称且无三角不等式。
14. **$D_{KL}(q\Vert p)$ 与 $D_{KL}(p\Vert q)$ 可互换。** 两个方向惩罚漏模与额外质量的方式不同。
15. **$E[\log\theta]=\log E[\theta]$。** 凹性给出前者不大于后者，Dirichlet 中分别用 digamma 和比例公式。
16. **指数族所有期望都容易。** 配分函数导数给充分统计量的矩，但 $A(\eta)$ 本身有时仍难计算。

## 公式与算法速查

### 优化

$$
x_{k+1}=x_k-\lambda_k\nabla f(x_k),
$$

$$
H_kp_k=-g_k,
\qquad x_{k+1}=x_k+p_k,
$$

$$
G_{k+1}^{DFP}
=G_k+\frac{\delta\delta^\top}{\delta^\top y}
-\frac{G_kyy^\top G_k}{y^\top G_ky},
$$

$$
B_{k+1}^{BFGS}
=B_k+\frac{yy^\top}{y^\top\delta}
-\frac{B_k\delta\delta^\top B_k}
{\delta^\top B_k\delta}.
$$

### 对偶

$$
L(x,\alpha,\beta)
=f(x)+\sum_i\alpha_ic_i(x)+\sum_j\beta_jh_j(x),
$$

$$
d^*\le p^*,
$$

$$
\nabla_xL=0,
\quad
\alpha_ic_i(x)=0,
\quad
c_i(x)\le0,
\quad
\alpha_i\ge0,
\quad
h_j(x)=0.
$$

### 子空间

$$
\operatorname{rank}(A)+\dim N(A)=n,
$$

$$
N(A)=R(A^\top)^\perp,
\qquad
N(A^\top)=R(A)^\perp.
$$

### 概率

$$
D_{KL}(Q\Vert P)
=E_Q\left[\log\frac{Q(X)}{P(X)}\right]\ge0,
$$

$$
\nabla A(\eta)=E_\eta[T(X)],
\qquad
\nabla^2A(\eta)=\operatorname{Cov}_\eta[T(X)],
$$

$$
E_{Dir(\alpha)}[\log\theta_k]
=\psi(\alpha_k)-\psi(\alpha_0).
$$

## 原书附录习题说明

原书附录 A–E 没有设置独立习题。本笔记通过 Rosenbrock 优化、KKT 数值残差、基本子空间正交和 Dirichlet 蒙特卡罗检验，提供了可复现的替代练习。

## 附录一句话回顾

**梯度和曲率决定无约束优化方向，Lagrangian 与 KKT 把约束变成可验证的对偶条件，四个基本子空间揭示线性映射的可见与丢失方向，而 KL 和指数族把概率近似与可计算期望连接起来。**
