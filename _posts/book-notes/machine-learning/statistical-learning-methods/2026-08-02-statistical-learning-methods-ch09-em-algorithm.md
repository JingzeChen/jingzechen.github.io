---
title: "《统计学习方法（第 2 版）》第 9 章：EM 算法及其推广"
date: 2026-08-01 02:09:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch09-em-algorithm
type: reading
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
related: [statistical-learning-methods-ch08-boosting, statistical-learning-methods-ch10-hidden-markov-models]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「EM 算法及其推广」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

### 0. 本章解决什么问题

前八章的模型都有一个共同前提：**训练数据是完整的**。监督学习给出 $(x_i,y_i)$ 对，第 4 章的朴素贝叶斯直接数频数就能估计参数。

但如果**有些变量根本观测不到**呢？

> 例如：你观察到一堆人的身高数据，知道它们来自男性和女性两个群体（各自服从正态分布），但**不知道每个数据是男是女**。怎么估计两个群体的均值和方差？

这就是**含隐变量**的参数估计问题，EM 算法正是为此而生。

本章的完整逻辑链条：

```text
含隐变量时，对数似然是 log Σ_Z P(Y,Z|θ)
    ↓ 对数里面套着求和，无法拆开求导
直接极大化没有解析解
    ↓ 换个思路：构造一个容易优化的下界
用 Jensen 不等式构造下界 B(θ, θ⁽ⁱ⁾)
    ↓ 下界在当前点与目标函数相切
极大化下界 ⟹ 目标函数必然上升
    ↓ 去掉常数项后
下界的极大化 = Q 函数的极大化
    ↓
E 步（求 Q）+ M 步（极大化 Q），反复迭代
    ↓ 理论保证
似然函数单调不减（定理 9.1）
    ↓ 推广
F 函数的极大-极大解释 → GEM 算法
```

**EM 的核心思想一句话**：

$$
\boxed{\;
\text{不会直接爬山，就反复"造一个贴着山面的下界，爬到下界的顶点"}
\;}
$$

这类方法在优化中称为 **MM 算法**（Minorize-Maximization，下界最大化）。

#### 为什么隐变量让问题变难

先看清困难在哪。完全数据的对数似然：

$$
\log P(Y,Z\mid\theta)
$$

通常很容易求导（比如高斯分布取对数后就是二次式）。但我们只观测到 $Y$，必须把 $Z$ 边缘化掉：

$$
L(\theta)=\log P(Y\mid\theta)
=\log\sum_ZP(Y,Z\mid\theta)。
$$

$$
\underbrace{\log\sum_Z}_{\text{对数套着求和}}
$$

**这个结构是万恶之源**：

- 若是 $\sum_Z\log(\cdot)$，可以逐项求导，很好办；
- 但 $\log\sum_Z(\cdot)$ **无法把对数移进求和号**，求导后会得到分式，各参数纠缠在一起，没有解析解。

EM 的贡献就是：**用 Jensen 不等式把 $\log\sum$ 换成 $\sum\log$**，从而恢复可解性。

#### 与前几章的定位

| 章节 | 数据 | 方法 |
| --- | --- | --- |
| 第 4 章 朴素贝叶斯 | 有标签 $(x,y)$ | 直接数频数（闭式解） |
| 第 6 章 逻辑斯谛回归 | 有标签 | 梯度/牛顿法 |
| **本章 EM** | **标签缺失（隐变量）** | **迭代下界最大化** |

**一个漂亮的对应**（习题 9.4 会展开）：

$$
\text{朴素贝叶斯（有监督）}
\xrightarrow[\text{硬标签}\to\text{软责任}]{\text{标签变成隐变量}}
\text{混合朴素贝叶斯（EM）}
$$

有监督时用 $\mathbf 1(y_j=c_k)$ 计数，无监督时换成后验概率 $\gamma_{jk}$ 加权计数——公式结构完全一样。

---

### 9.1 EM 算法的引入

#### 9.1.1 例 9.1：三硬币模型

**问题**。有 3 枚硬币 A、B、C，正面概率分别是 $\pi,p,q$。试验过程：

1. 先掷硬币 A；
2. A 正面则选硬币 B，反面则选硬币 C；
3. 掷选出的硬币，正面记 1，反面记 0。

独立重复 $n=10$ 次，观测结果：

$$
1,1,0,1,0,0,1,0,1,1
$$

（6 个 1，4 个 0。）

**关键**：只能观测掷硬币的**结果**，不能观测掷硬币的**过程**——即不知道每次用的是 B 还是 C。

**模型**。设：

- $y$ 是观测变量（0 或 1）；
- $z$ 是**隐变量**，表示掷硬币 A 的结果（选了 B 还是 C）；
- $\theta=(\pi,p,q)$ 是参数。

单次观测的概率为

$$
\begin{aligned}
P(y\mid\theta)
&=\sum_zP(y,z\mid\theta)
=\sum_zP(z\mid\theta)P(y\mid z,\theta)\\
&=\pi p^y(1-p)^{1-y}+(1-\pi)q^y(1-q)^{1-y}。
\end{aligned}
$$

> **读法**：第一项是"A 正面（概率 $\pi$）→ 掷 B 得到 $y$"，第二项是"A 反面 → 掷 C 得到 $y$"。$p^y(1-p)^{1-y}$ 是把 $y=1$ 和 $y=0$ 两种情况写成一个式子的技巧（第 4 章、第 6 章都用过）。

$n$ 次独立观测的似然函数：

$$
P(Y\mid\theta)=\prod_{j=1}^{n}
\left[\pi p^{y_j}(1-p)^{1-y_j}+(1-\pi)q^{y_j}(1-q)^{1-y_j}\right]。
$$

**极大似然估计**

$$
\hat\theta=\arg\max_\theta\log P(Y\mid\theta)
$$

**没有解析解**——正是因为对数里套着求和。只能迭代求解。

#### 9.1.2 三硬币模型的 EM 迭代公式

**E 步**：计算在当前参数下，第 $j$ 次观测**来自硬币 B** 的概率

$$
\mu_j^{(i+1)}=
\frac{\pi^{(i)}\left(p^{(i)}\right)^{y_j}\left(1-p^{(i)}\right)^{1-y_j}}
{\pi^{(i)}\left(p^{(i)}\right)^{y_j}\left(1-p^{(i)}\right)^{1-y_j}
+\left(1-\pi^{(i)}\right)\left(q^{(i)}\right)^{y_j}\left(1-q^{(i)}\right)^{1-y_j}}。
$$

这就是**隐变量的后验概率**：

$$
\mu_j=P(z_j=B\mid y_j,\theta^{(i)})。
$$

**M 步**：用 $\mu_j$ 作为"软标签"更新参数

$$
\pi^{(i+1)}=\frac1n\sum_{j=1}^{n}\mu_j^{(i+1)}，
$$

$$
p^{(i+1)}=\frac{\sum_j\mu_j^{(i+1)}y_j}{\sum_j\mu_j^{(i+1)}},
\qquad
q^{(i+1)}=\frac{\sum_j\left(1-\mu_j^{(i+1)}\right)y_j}
{\sum_j\left(1-\mu_j^{(i+1)}\right)}。
$$

**这三个公式的含义非常直观**：

| 公式 | 含义 |
| --- | --- |
| $\pi$ | 有多大比例的观测"来自 B"（软计数的平均） |
| $p$ | 在"来自 B"的加权观测中，正面的比例 |
| $q$ | 在"来自 C"的加权观测中，正面的比例 |

**对比有完整数据的情形**：如果我们知道每次到底用了 B 还是 C（设指示变量 $z_j\in\{0,1\}$），那么

$$
\hat\pi=\frac1n\sum_jz_j,
\qquad
\hat p=\frac{\sum_jz_jy_j}{\sum_jz_j}。
$$

**EM 的 M 步就是把硬指示 $z_j$ 换成软概率 $\mu_j$**。这是 EM 最重要的直觉。

#### 9.1.3 数值计算与一个重要发现

**初值 $\pi^{(0)}=p^{(0)}=q^{(0)}=0.5$**：

由于 $p=q$，代入 E 步得 $\mu_j=0.5$（对所有 $j$）。M 步：

$$
\pi^{(1)}=0.5,\quad p^{(1)}=0.6,\quad q^{(1)}=0.6。
$$

再迭代仍然 $p=q$，故 $\mu_j$ 恒为 $0.5$，参数不再变化：

$$
\hat\pi=0.5,\quad\hat p=0.6,\quad\hat q=0.6。
$$

**初值 $\pi^{(0)}=0.4,p^{(0)}=0.6,q^{(0)}=0.7$**：

$$
\hat\pi=0.4064,\quad\hat p=0.5368,\quad\hat q=0.6432。
$$

书中据此说"**EM 算法与初值的选择有关**"。这个说法没错，但**容易引起误解**——下面这个发现更值得注意。

**一个深入的观察：三硬币模型是不可辨识的**

代码计算显示，两组解的**对数似然完全相同**：

| $(\pi,p,q)$ | $\theta=\pi p+(1-\pi)q$ | $\log L$ |
| --- | ---: | ---: |
| $(0.5,0.6,0.6)$ | $0.600$ | $-6.730117$ |
| $(0.4064,0.5368,0.6432)$ | $0.600$ | $-6.730117$ |
| $(0.4619,0.5346,0.6561)$ | $0.600$ | $-6.730117$ |
| $(0.2,0.1,0.725)$ | $0.600$ | $-6.730117$ |

**为什么？** 注意到单次观测的边缘概率为

$$
P(y=1\mid\theta)=\pi p+(1-\pi)q\triangleq\theta_{\text{eff}}。
$$

也就是说，**观测数据只是参数为 $\theta_{\text{eff}}$ 的伯努利样本**！似然只通过 $\theta_{\text{eff}}$ 依赖参数：

$$
\log L=6\log\theta_{\text{eff}}+4\log(1-\theta_{\text{eff}})。
$$

伯努利的 MLE 是 $\hat\theta_{\text{eff}}=6/10=0.6$，对应

$$
\log L=6\log0.6+4\log0.4=-6.730117。
$$

**结论**：所有满足 $\pi p+(1-\pi)q=0.6$ 的 $(\pi,p,q)$ 都是**全局最优解**。似然曲面上有一整片"山脊"，而非孤立的峰。

$$
\boxed{\;
\text{三硬币模型的 3 个参数不可辨识，只有组合 }\pi p+(1-\pi)q\text{ 可辨识}
\;}
$$

**这个发现修正了一个常见误解**：

| 常见说法 | 更准确的理解 |
| --- | --- |
| "EM 对初值敏感，会陷入**局部最优**" | 本例中所有收敛点都是**全局最优**，只是解不唯一 |

当然，EM 确实可能陷入局部最优（一般的 GMM 就会），但**本例的初值敏感性源于模型的不可辨识性**，两者要区分开。

> **实践启示**：模型参数个数超过数据能提供的信息量时，会出现不可辨识。此时应减少参数、增加约束或引入先验。

#### 9.1.4 EM 算法的一般形式

**记号约定**：

| 记号 | 含义 |
| --- | --- |
| $Y$ | 观测变量数据（**不完全数据**） |
| $Z$ | 隐变量数据 |
| $(Y,Z)$ | **完全数据** |
| $L(\theta)=\log P(Y\mid\theta)$ | 不完全数据的对数似然（**要极大化的目标**） |
| $\log P(Y,Z\mid\theta)$ | 完全数据的对数似然（**容易处理**） |

**算法 9.1（EM 算法）**

**输入**：观测数据 $Y$，联合分布 $P(Y,Z\mid\theta)$，条件分布 $P(Z\mid Y,\theta)$
**输出**：模型参数 $\theta$

1. 选择参数初值 $\theta^{(0)}$；
2. **E 步**：记 $\theta^{(i)}$ 为第 $i$ 次迭代的估计值，计算

$$
\boxed{\;
Q\bigl(\theta,\theta^{(i)}\bigr)
=\mathbb E_Z\bigl[\log P(Y,Z\mid\theta)\;\big|\;Y,\theta^{(i)}\bigr]
=\sum_Z\log P(Y,Z\mid\theta)\,P\bigl(Z\mid Y,\theta^{(i)}\bigr)
\;}
$$

3. **M 步**：求使 $Q$ 极大化的 $\theta$

$$
\theta^{(i+1)}=\arg\max_\theta Q\bigl(\theta,\theta^{(i)}\bigr)；
$$

4. 重复步骤 2、3 直到收敛。

**定义 9.1（$Q$ 函数）** **完全数据**的对数似然 $\log P(Y,Z\mid\theta)$ 关于**在给定观测数据 $Y$ 和当前参数 $\theta^{(i)}$ 下隐变量的条件分布** $P(Z\mid Y,\theta^{(i)})$ 的**期望**，称为 $Q$ 函数。

**理解 $Q$ 函数的三个要点**：

**（1）两个变元的角色完全不同**

$$
Q(\underbrace{\theta}_{\text{待优化的变量}},\;
\underbrace{\theta^{(i)}}_{\text{当前的固定值}})
$$

第一个变元 $\theta$ 是要极大化的对象；第二个变元 $\theta^{(i)}$ 只用来计算隐变量的后验分布，在本轮中是**常数**。

**（2）为什么要取期望？**

因为 $Z$ 未知。我们不知道 $Z$ 的真值，就用它的**后验分布**求平均——这是在当前信息下最合理的处理。

**（3）$Q$ 函数为什么容易优化？**

$$
Q=\sum_ZP(Z\mid Y,\theta^{(i)})\log P(Y,Z\mid\theta)
$$

注意**对数在求和号内部**（$\sum\log$ 而非 $\log\sum$）！这正是 EM 化难为易的关键。

**关于停止条件**：一般取较小的正数 $\varepsilon_1,\varepsilon_2$，当

$$
\left\lVert\theta^{(i+1)}-\theta^{(i)}\right\rVert<\varepsilon_1
\quad\text{或}\quad
\left\lvert Q(\theta^{(i+1)},\theta^{(i)})-Q(\theta^{(i)},\theta^{(i)})\right\rvert<\varepsilon_2
$$

时停止。

---

### 9.2 EM 算法的导出

上一节直接给出了算法，但**为什么这样做能极大化 $L(\theta)$**？本节给出完整推导。

#### 9.2.1 核心工具：Jensen 不等式

**Jensen 不等式**（针对凹函数 $\log$）：若 $\lambda_j\ge0$ 且 $\sum_j\lambda_j=1$，则

$$
\boxed{\;\log\sum_j\lambda_jy_j\ge\sum_j\lambda_j\log y_j\;}
$$

**几何含义**：$\log$ 是凹函数，**函数值的加权平均 $\le$ 加权平均处的函数值**。

$$
\text{凹函数：}\quad
\log(\text{平均})\ge\text{平均}(\log)
$$

**这个不等式恰好把 $\log\sum$ 变成了 $\sum\log$**——正是我们需要的。

**等号成立条件**：所有 $y_j$ 相等（或 $\lambda_j$ 集中在一点）。这个条件后面很关键。

#### 9.2.2 构造下界

目标是极大化

$$
L(\theta)=\log P(Y\mid\theta)=\log\sum_ZP(Y\mid Z,\theta)P(Z\mid\theta)。
$$

假设第 $i$ 次迭代后的估计是 $\theta^{(i)}$，希望找到 $\theta$ 使 $L(\theta)>L(\theta^{(i)})$。考虑两者之差：

$$
L(\theta)-L\bigl(\theta^{(i)}\bigr)
=\log\sum_ZP(Y\mid Z,\theta)P(Z\mid\theta)-\log P\bigl(Y\mid\theta^{(i)}\bigr)。
$$

**关键技巧：乘一个 1**。把 $P(Z\mid Y,\theta^{(i)})$ 同时乘除：

$$
\log\sum_Z
\underbrace{P\bigl(Z\mid Y,\theta^{(i)}\bigr)}_{\text{权重 }\lambda_Z}
\cdot
\underbrace{\frac{P(Y\mid Z,\theta)P(Z\mid\theta)}{P(Z\mid Y,\theta^{(i)})}}_{y_Z}。
$$

**为什么可以用 Jensen？** 因为 $P(Z\mid Y,\theta^{(i)})$ 是一个概率分布：非负且

$$
\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)=1。
$$

正好满足 Jensen 不等式对权重的要求。应用不等式：

$$
\begin{aligned}
L(\theta)-L\bigl(\theta^{(i)}\bigr)
&\ge\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)
\log\frac{P(Y\mid Z,\theta)P(Z\mid\theta)}{P(Z\mid Y,\theta^{(i)})}
-\log P\bigl(Y\mid\theta^{(i)}\bigr)\\
&=\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)
\log\frac{P(Y\mid Z,\theta)P(Z\mid\theta)}
{P(Z\mid Y,\theta^{(i)})P(Y\mid\theta^{(i)})}。
\end{aligned}
$$

（最后一步把 $\log P(Y\mid\theta^{(i)})$ 移进求和号——因为它与 $Z$ 无关，且权重之和为 1。）

记

$$
B\bigl(\theta,\theta^{(i)}\bigr)
=L\bigl(\theta^{(i)}\bigr)
+\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)
\log\frac{P(Y\mid Z,\theta)P(Z\mid\theta)}
{P(Z\mid Y,\theta^{(i)})P(Y\mid\theta^{(i)})}，
$$

则得到两个关键性质：

$$
\boxed{\;
\text{性质一：}\;L(\theta)\ge B\bigl(\theta,\theta^{(i)}\bigr)
\quad\text{（}B\text{ 是 }L\text{ 的下界）}
\;}
$$

$$
\boxed{\;
\text{性质二：}\;L\bigl(\theta^{(i)}\bigr)=B\bigl(\theta^{(i)},\theta^{(i)}\bigr)
\quad\text{（在当前点相切）}
\;}
$$

**性质二的验证**：令 $\theta=\theta^{(i)}$，则对数中的分式变为

$$
\frac{P(Y\mid Z,\theta^{(i)})P(Z\mid\theta^{(i)})}
{P(Z\mid Y,\theta^{(i)})P(Y\mid\theta^{(i)})}
=\frac{P(Y,Z\mid\theta^{(i)})}{P(Y,Z\mid\theta^{(i)})}=1，
$$

$\log1=0$，故 $B(\theta^{(i)},\theta^{(i)})=L(\theta^{(i)})$ ✓

#### 9.2.3 从下界到 $Q$ 函数

由这两个性质：

$$
\text{任何使 }B\text{ 增大的 }\theta\text{，也必然使 }L\text{ 增大。}
$$

**证明**：设 $B(\theta,\theta^{(i)})>B(\theta^{(i)},\theta^{(i)})$，则

$$
L(\theta)\;\overset{\text{性质一}}{\ge}\;B\bigl(\theta,\theta^{(i)}\bigr)
\;>\;B\bigl(\theta^{(i)},\theta^{(i)}\bigr)
\;\overset{\text{性质二}}{=}\;L\bigl(\theta^{(i)}\bigr)。
$$

于是自然的策略是**极大化下界**：

$$
\theta^{(i+1)}=\arg\max_\theta B\bigl(\theta,\theta^{(i)}\bigr)。
$$

**化简**。去掉与 $\theta$ 无关的项（$L(\theta^{(i)})$、分母中的 $P(Z\mid Y,\theta^{(i)})P(Y\mid\theta^{(i)})$）：

$$
\begin{aligned}
\theta^{(i+1)}
&=\arg\max_\theta\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)
\log\bigl(P(Y\mid Z,\theta)P(Z\mid\theta)\bigr)\\
&=\arg\max_\theta\sum_ZP\bigl(Z\mid Y,\theta^{(i)}\bigr)
\log P(Y,Z\mid\theta)\\
&=\arg\max_\theta Q\bigl(\theta,\theta^{(i)}\bigr)。
\end{aligned}
$$

$$
\boxed{\;\text{极大化下界}\;\Longleftrightarrow\;\text{极大化 }Q\text{ 函数}\;}
$$

**这就完整导出了 EM 算法。**

#### 9.2.4 几何解释

```text
  L(θ)
   │           ╱▔▔▔╲ ← L(θ) 真实目标（难优化）
   │        ╱        ╲
   │     ╱   ╱▔╲      ╲
   │   ╱   ╱     ╲      ╲   ← B(θ,θ⁽ⁱ⁺¹⁾) 新下界
   │  ╱ ╱▔╲ ╲     ╲
   │ ╱╱     ╲╲      ← B(θ,θ⁽ⁱ⁾) 当前下界（易优化）
   │╱         ╲
   └──┬────┬──────┬──────── θ
     θ⁽ⁱ⁾  θ⁽ⁱ⁺¹⁾  θ*

  每轮：① 在 θ⁽ⁱ⁾ 处造一个相切的下界
        ② 爬到下界的顶点 → θ⁽ⁱ⁺¹⁾
        ③ 在新点重新造下界，重复
```

**这就是 MM 算法（Minorize-Maximization）的一般框架**：

1. **Minorize**：构造在当前点相切的下界（E 步）；
2. **Maximize**：极大化下界（M 步）。

由于下界与目标相切，每次爬升都保证目标函数上升。

**从图中还能看出一个重要事实**：

> EM **不能保证找到全局最优**。若初值在某个局部峰的吸引域内，就会收敛到该局部峰。

#### 9.2.5 现代视角：ELBO 与 KL 散度（重要补充）

书中的 $B$ 函数和后面 9.5 节的 $F$ 函数，在现代机器学习中有一个统一的名字：**证据下界**（Evidence Lower BOund, ELBO）。这个视角能把 EM 的所有性质解释得极其干净，值得补充。

**对任意隐变量分布 $q(Z)$**（不必是后验），定义

$$
\mathrm{ELBO}(q,\theta)
=\mathbb E_q\left[\log\frac{P(Y,Z\mid\theta)}{q(Z)}\right]
=\underbrace{\mathbb E_q[\log P(Y,Z\mid\theta)]}_{\text{能量项}}
+\underbrace{H(q)}_{\text{熵}}。
$$

**核心恒等式**：

$$
\boxed{\;
L(\theta)=\mathrm{ELBO}(q,\theta)
+\mathrm{KL}\bigl(q(Z)\,\big\|\,P(Z\mid Y,\theta)\bigr)
\;}
$$

**推导**：

$$
\begin{aligned}
\mathrm{KL}\bigl(q\|P(Z\mid Y,\theta)\bigr)
&=\sum_Zq(Z)\log\frac{q(Z)}{P(Z\mid Y,\theta)}\\
&=\sum_Zq(Z)\log\frac{q(Z)P(Y\mid\theta)}{P(Y,Z\mid\theta)}
\qquad\left(P(Z\mid Y,\theta)=\frac{P(Y,Z\mid\theta)}{P(Y\mid\theta)}\right)\\
&=\underbrace{\sum_Zq(Z)\log P(Y\mid\theta)}_{=L(\theta)}
-\sum_Zq(Z)\log\frac{P(Y,Z\mid\theta)}{q(Z)}\\
&=L(\theta)-\mathrm{ELBO}(q,\theta)。
\end{aligned}
$$

**由这一个恒等式，EM 的一切都清楚了**：

**（1）为什么 ELBO 是下界？**

因为 $\mathrm{KL}\ge0$（相对熵非负），所以

$$
L(\theta)\ge\mathrm{ELBO}(q,\theta)\quad\text{对任意 }q。
$$

**（2）E 步在做什么？**

固定 $\theta=\theta^{(i)}$，极大化 ELBO 关于 $q$：

$$
\max_q\mathrm{ELBO}(q,\theta^{(i)})
\;\Longleftrightarrow\;
\min_q\mathrm{KL}\bigl(q\|P(Z\mid Y,\theta^{(i)})\bigr)
$$

（因为 $L(\theta^{(i)})$ 此时是常数）。KL 散度在 $q=P(Z\mid Y,\theta^{(i)})$ 时取最小值 $0$，故

$$
\boxed{\;q^*(Z)=P\bigl(Z\mid Y,\theta^{(i)}\bigr)\;}
$$

**这正是 E 步计算的后验分布！** 且此时 $\mathrm{KL}=0$，即

$$
\mathrm{ELBO}=L(\theta^{(i)})\quad\text{（下界与目标相切）}。
$$

**（3）M 步在做什么？**

固定 $q$，极大化 ELBO 关于 $\theta$。由于 $H(q)$ 与 $\theta$ 无关：

$$
\max_\theta\mathrm{ELBO}(q,\theta)
\;\Longleftrightarrow\;
\max_\theta\mathbb E_q[\log P(Y,Z\mid\theta)]
=\max_\theta Q\bigl(\theta,\theta^{(i)}\bigr)。
$$

**（4）EM 就是坐标上升法**

$$
\text{EM}=\text{在 }(q,\theta)\text{ 两组变量上交替极大化 ELBO}
$$

| 步骤 | 固定 | 优化 | 结果 |
| --- | --- | --- | --- |
| E 步 | $\theta$ | $q$ | $q=P(Z\mid Y,\theta^{(i)})$，$\mathrm{KL}=0$ |
| M 步 | $q$ | $\theta$ | $\theta^{(i+1)}=\arg\max Q$ |

**代码验证**（三硬币模型，$\theta=(0.45,0.55,0.65)$）：

| $q(Z)$ | $L(\theta)$ | ELBO | KL | ELBO+KL |
| --- | ---: | ---: | ---: | ---: |
| 任意分布 | $-6.73063898$ | $-7.41518517$ | $0.68454618$ | $-6.73063898$ |
| $P(Z\mid Y,\theta)$ | $-6.73063898$ | $-6.73063898$ | $0.00000000$ | $-6.73063898$ |

恒等式在机器精度内精确成立（误差 $10^{-15}$），且**取后验时 KL 恰好为 0**。

> **这个视角的价值**：当后验 $P(Z\mid Y,\theta)$ 无法精确计算时（复杂模型中很常见），可以限制 $q$ 在某个简单分布族中求近似最优——这就是**变分推断**（variational inference），也是变分自编码器 VAE 的理论基础。EM 是变分推断的特例（$q$ 不受限制时）。

---

### 9.3 EM 算法的收敛性

#### 9.3.1 定理 9.1：似然函数单调不减

**定理 9.1** 设 $P(Y\mid\theta)$ 为观测数据的似然函数，$\theta^{(i)}$ 为 EM 得到的参数序列，则

$$
\boxed{\;P\bigl(Y\mid\theta^{(i+1)}\bigr)\ge P\bigl(Y\mid\theta^{(i)}\bigr)\;}
$$

**证明。**

**第一步：分解对数似然**

由 $P(Y\mid\theta)=\dfrac{P(Y,Z\mid\theta)}{P(Z\mid Y,\theta)}$，取对数：

$$
\log P(Y\mid\theta)=\log P(Y,Z\mid\theta)-\log P(Z\mid Y,\theta)。
$$

两边关于 $P(Z\mid Y,\theta^{(i)})$ 取期望（左边与 $Z$ 无关，期望仍是自身）：

$$
\boxed{\;\log P(Y\mid\theta)=Q\bigl(\theta,\theta^{(i)}\bigr)-H\bigl(\theta,\theta^{(i)}\bigr)\;}
$$

其中

$$
H\bigl(\theta,\theta^{(i)}\bigr)
=\sum_Z\log P(Z\mid Y,\theta)\,P\bigl(Z\mid Y,\theta^{(i)}\bigr)。
$$

**第二步：作差**

分别取 $\theta=\theta^{(i+1)}$ 和 $\theta=\theta^{(i)}$ 相减：

$$
\begin{aligned}
&\log P\bigl(Y\mid\theta^{(i+1)}\bigr)-\log P\bigl(Y\mid\theta^{(i)}\bigr)\\
&=\underbrace{\left[Q\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)-Q\bigl(\theta^{(i)},\theta^{(i)}\bigr)\right]}_{\text{第 1 项}}
-\underbrace{\left[H\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)-H\bigl(\theta^{(i)},\theta^{(i)}\bigr)\right]}_{\text{第 2 项}}。
\end{aligned}
$$

只需证明右端非负。

**第三步：第 1 项 $\ge0$**

由 M 步的定义，$\theta^{(i+1)}$ 使 $Q(\theta,\theta^{(i)})$ 达到极大，故

$$
Q\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)\ge Q\bigl(\theta^{(i)},\theta^{(i)}\bigr)。
$$

**第四步：第 2 项 $\le0$**

$$
\begin{aligned}
&H\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)-H\bigl(\theta^{(i)},\theta^{(i)}\bigr)\\
&=\sum_Z\log\frac{P(Z\mid Y,\theta^{(i+1)})}{P(Z\mid Y,\theta^{(i)})}
\,P\bigl(Z\mid Y,\theta^{(i)}\bigr)\\
&\overset{\text{Jensen}}{\le}
\log\left(\sum_Z\frac{P(Z\mid Y,\theta^{(i+1)})}{P(Z\mid Y,\theta^{(i)})}
P\bigl(Z\mid Y,\theta^{(i)}\bigr)\right)\\
&=\log\sum_ZP\bigl(Z\mid Y,\theta^{(i+1)}\bigr)
=\log1=0。
\end{aligned}
$$

**第五步：合并**

第 1 项 $\ge0$，第 2 项 $\le0$，故"第 1 项 $-$ 第 2 项" $\ge0$，即

$$
\log P\bigl(Y\mid\theta^{(i+1)}\bigr)\ge\log P\bigl(Y\mid\theta^{(i)}\bigr)。\quad\blacksquare
$$

> **注意第 2 项其实就是 KL 散度的相反数**：
>
> $$
> -\left[H(\theta^{(i+1)},\theta^{(i)})-H(\theta^{(i)},\theta^{(i)})\right]
> =\mathrm{KL}\bigl(P(Z\mid Y,\theta^{(i)})\,\big\|\,P(Z\mid Y,\theta^{(i+1)})\bigr)\ge0。
> $$
>
> 用 9.2.5 节的 ELBO 视角看，这个证明就是"E 步让 KL 归零、M 步让 ELBO 上升"的直接推论。

**代码验证**（初值 $(0.4,0.6,0.7)$）：

| 迭代 | $\pi$ | $p$ | $q$ | $\log L$ |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 0.400000 | 0.600000 | 0.700000 | $-6.80833131$ |
| 1 | 0.406417 | 0.536842 | 0.643243 | $-6.73011667$ ↑ |
| 2 | 0.406417 | 0.536842 | 0.643243 | $-6.73011667$ ↑ |

单调不减 ✓

#### 9.3.2 定理 9.2：收敛性

**定理 9.2** 设 $L(\theta)=\log P(Y\mid\theta)$，$\theta^{(i)}$ 为 EM 得到的参数序列：

1. 如果 $P(Y\mid\theta)$ **有上界**，则 $L(\theta^{(i)})$ 收敛到某一值 $L^*$；
2. 在 $Q$ 与 $L$ 满足一定条件下，$\theta^{(i)}$ 的收敛值 $\theta^*$ 是 $L(\theta)$ 的**稳定点**。

**（1）的证明**：由定理 9.1，$L(\theta^{(i)})$ 单调不减；若又有上界，由**单调有界数列必收敛**即得。

**必须注意的三点**：

**（a）两层收敛性不等价**

$$
\underbrace{L(\theta^{(i)})\text{ 收敛}}_{\text{似然值收敛}}
\;\;\not\Longrightarrow\;\;
\underbrace{\theta^{(i)}\text{ 收敛}}_{\text{参数收敛}}
$$

似然值收敛不蕴涵参数收敛（参数可能在等似然的"山脊"上游走——三硬币模型就是例子）。

**（b）只保证收敛到稳定点，不保证极大值点**

稳定点包括极大值点、极小值点和鞍点。EM 保证的只是**梯度为零**。

**（c）$P(Y\mid\theta)$ 未必有上界！**

高斯混合模型的似然函数就**无上界**（9.4.5 节会看到），此时定理 9.2 的条件不满足。

**实践建议**：

> 由于初值影响很大，常用的办法是**选取几个不同的初值迭代，比较各估计值，从中选择最好的**。

这与第 5 章决策树、第 8 章 AdaBoost 中"贪心得到次优解"的处境类似——都是理论保证有限、需靠工程手段弥补。

---

### 9.4 EM 在高斯混合模型中的应用

#### 9.4.1 高斯混合模型

**定义 9.2（高斯混合模型）**

$$
P(y\mid\theta)=\sum_{k=1}^{K}\alpha_k\phi(y\mid\theta_k)，
$$

其中 $\alpha_k\ge0$，$\sum_k\alpha_k=1$，$\theta_k=(\mu_k,\sigma_k^2)$，且

$$
\phi(y\mid\theta_k)=\frac{1}{\sqrt{2\pi}\sigma_k}
\exp\left(-\frac{(y-\mu_k)^2}{2\sigma_k^2}\right)
$$

称为第 $k$ 个**分模型**。

**生成过程的直观理解**：

```text
① 按概率 (α₁,...,α_K) 抽一个分模型编号 k     ← 这一步不可观测（隐变量）
② 从 N(μ_k, σ_k²) 中抽一个样本 y            ← 只能观测到 y
```

这与第 4 章"生成模型"的思路一致：先抽类别，再按类条件分布生成数据。区别在于**类别不可观测**。

#### 9.4.2 明确隐变量与完全数据

定义隐变量 $\gamma_{jk}$（0-1 随机变量）：

$$
\gamma_{jk}=
\begin{cases}
1,&\text{第 }j\text{ 个观测来自第 }k\text{ 个分模型},\\
0,&\text{否则}。
\end{cases}
$$

完全数据为 $(y_j,\gamma_{j1},\ldots,\gamma_{jK})$，$j=1,\ldots,N$。

**完全数据的似然函数**：

$$
\begin{aligned}
P(y,\gamma\mid\theta)
&=\prod_{j=1}^{N}\prod_{k=1}^{K}
\left[\alpha_k\phi(y_j\mid\theta_k)\right]^{\gamma_{jk}}\\
&=\prod_{k=1}^{K}\alpha_k^{n_k}
\prod_{j=1}^{N}\left[\phi(y_j\mid\theta_k)\right]^{\gamma_{jk}}，
\end{aligned}
$$

其中 $n_k=\sum_{j=1}^{N}\gamma_{jk}$，$\sum_kn_k=N$。

> 指数 $\gamma_{jk}$ 的作用：只有 $\gamma_{jk}=1$ 的那一项被"激活"，其余项因指数为 0 而变成 1。这是把"选择"写进连乘的标准技巧。

**完全数据的对数似然**：

$$
\log P(y,\gamma\mid\theta)
=\sum_{k=1}^{K}\left\{n_k\log\alpha_k
+\sum_{j=1}^{N}\gamma_{jk}\left[
\log\frac{1}{\sqrt{2\pi}}-\log\sigma_k
-\frac{(y_j-\mu_k)^2}{2\sigma_k^2}\right]\right\}。
$$

**注意**：如果 $\gamma_{jk}$ 已知，这个式子对每个 $k$ **完全解耦**，求导即得闭式解——这正是"完全数据容易处理"的含义。

#### 9.4.3 E 步：计算响应度

$Q$ 函数为

$$
Q\bigl(\theta,\theta^{(i)}\bigr)
=\mathbb E\bigl[\log P(y,\gamma\mid\theta)\;\big|\;y,\theta^{(i)}\bigr]。
$$

由于对数似然关于 $\gamma_{jk}$ 是**线性**的，取期望只需把 $\gamma_{jk}$ 换成 $\hat\gamma_{jk}=\mathbb E[\gamma_{jk}\mid y,\theta^{(i)}]$。

由于 $\gamma_{jk}$ 是 0-1 变量，其期望等于取 1 的概率：

$$
\begin{aligned}
\hat\gamma_{jk}
&=P(\gamma_{jk}=1\mid y_j,\theta^{(i)})\\
&=\frac{P(\gamma_{jk}=1,y_j\mid\theta)}
{\sum_{k'=1}^{K}P(\gamma_{jk'}=1,y_j\mid\theta)}\\
&=\frac{P(y_j\mid\gamma_{jk}=1,\theta)P(\gamma_{jk}=1\mid\theta)}
{\sum_{k'}P(y_j\mid\gamma_{jk'}=1,\theta)P(\gamma_{jk'}=1\mid\theta)}\\
&=\boxed{\frac{\alpha_k\phi(y_j\mid\theta_k)}
{\sum_{k'=1}^{K}\alpha_{k'}\phi(y_j\mid\theta_{k'})}}
\end{aligned}
$$

$\hat\gamma_{jk}$ 称为**分模型 $k$ 对观测数据 $y_j$ 的响应度**（responsibility）。

**含义**：在当前参数下，$y_j$ 有多大概率来自第 $k$ 个分模型。显然 $\sum_k\hat\gamma_{jk}=1$。

代入得

$$
Q\bigl(\theta,\theta^{(i)}\bigr)
=\sum_{k=1}^{K}\left\{n_k\log\alpha_k
+\sum_{j=1}^{N}\hat\gamma_{jk}\left[
\log\frac{1}{\sqrt{2\pi}}-\log\sigma_k
-\frac{(y_j-\mu_k)^2}{2\sigma_k^2}\right]\right\}，
$$

其中 $n_k=\sum_{j=1}^{N}\hat\gamma_{jk}$（现在是**软计数**）。

#### 9.4.4 M 步：三个更新公式的推导

**（1）求 $\mu_k$**

$$
\frac{\partial Q}{\partial\mu_k}
=\sum_{j=1}^{N}\hat\gamma_{jk}\cdot\frac{y_j-\mu_k}{\sigma_k^2}=0，
$$

$$
\sum_j\hat\gamma_{jk}y_j=\mu_k\sum_j\hat\gamma_{jk}
\quad\Longrightarrow\quad
\boxed{\hat\mu_k=\frac{\sum_{j=1}^{N}\hat\gamma_{jk}y_j}
{\sum_{j=1}^{N}\hat\gamma_{jk}}}
$$

**含义**：第 $k$ 个分模型的均值 = 所有样本的**加权平均**，权重是响应度。

**（2）求 $\sigma_k^2$**

$$
\frac{\partial Q}{\partial\sigma_k}
=\sum_j\hat\gamma_{jk}\left[
-\frac{1}{\sigma_k}+\frac{(y_j-\mu_k)^2}{\sigma_k^3}\right]=0，
$$

两边乘 $\sigma_k^3$：

$$
\sum_j\hat\gamma_{jk}(y_j-\mu_k)^2=\sigma_k^2\sum_j\hat\gamma_{jk}，
$$

$$
\boxed{\hat\sigma_k^2=\frac{\sum_{j=1}^{N}\hat\gamma_{jk}(y_j-\hat\mu_k)^2}
{\sum_{j=1}^{N}\hat\gamma_{jk}}}
$$

**含义**：加权方差。

**（3）求 $\alpha_k$（有约束 $\sum_k\alpha_k=1$）**

用拉格朗日乘子法（与第 4 章习题 4.1 完全相同的套路）：

$$
\mathcal L=\sum_kn_k\log\alpha_k+\lambda\left(\sum_k\alpha_k-1\right)。
$$

$$
\frac{\partial\mathcal L}{\partial\alpha_k}=\frac{n_k}{\alpha_k}+\lambda=0
\quad\Longrightarrow\quad
\alpha_k=-\frac{n_k}{\lambda}。
$$

代入约束：

$$
\sum_k\left(-\frac{n_k}{\lambda}\right)=1
\quad\Longrightarrow\quad
\lambda=-\sum_kn_k=-N，
$$

$$
\boxed{\hat\alpha_k=\frac{n_k}{N}=\frac{\sum_{j=1}^{N}\hat\gamma_{jk}}{N}}
$$

**含义**：第 $k$ 个分模型的混合系数 = 分配给它的**软样本比例**。

**算法 9.2（高斯混合模型参数估计的 EM 算法）**

1. 取参数初始值；
2. **E 步**：计算响应度

$$
\hat\gamma_{jk}=\frac{\alpha_k\phi(y_j\mid\theta_k)}
{\sum_{k'}\alpha_{k'}\phi(y_j\mid\theta_{k'})}；
$$

3. **M 步**：

$$
\hat\mu_k=\frac{\sum_j\hat\gamma_{jk}y_j}{\sum_j\hat\gamma_{jk}},
\qquad
\hat\sigma_k^2=\frac{\sum_j\hat\gamma_{jk}(y_j-\hat\mu_k)^2}{\sum_j\hat\gamma_{jk}},
\qquad
\hat\alpha_k=\frac{\sum_j\hat\gamma_{jk}}{N}；
$$

4. 重复直到收敛。

**一个统一的记忆法**：

$$
\text{把有标签时的计数公式中的 }\mathbf 1(z_j=k)\text{ 换成 }\hat\gamma_{jk}
$$

| 有标签（硬） | 无标签（软，EM） |
| --- | --- |
| $\mu_k=\dfrac{\sum_j\mathbf 1(z_j=k)y_j}{\sum_j\mathbf 1(z_j=k)}$ | $\mu_k=\dfrac{\sum_j\hat\gamma_{jk}y_j}{\sum_j\hat\gamma_{jk}}$ |
| $\alpha_k=\dfrac{\#\{j:z_j=k\}}{N}$ | $\alpha_k=\dfrac{\sum_j\hat\gamma_{jk}}{N}$ |

#### 9.4.5 两个重要问题

**（1）GMM 与 $k$ 均值的关系**

$k$ 均值（第 14 章）可以看作 GMM 的**硬划分极限**：

| | GMM（EM） | $k$ 均值 |
| --- | --- | --- |
| 分配 | **软**：$\hat\gamma_{jk}\in[0,1]$ | **硬**：$\hat\gamma_{jk}\in\{0,1\}$ |
| 协方差 | 每类可不同 | 隐含假设各向同性且相等 |
| 更新 | 加权均值 | 简单均值 |

当所有 $\sigma_k^2=\sigma^2\to0$ 时，响应度会退化为 0/1（离得最近的那一类概率趋于 1），EM 就变成了 $k$ 均值。

$$
\boxed{\;k\text{ 均值是 GMM 在 }\sigma\to0\text{ 时的极限}\;}
$$

**（2）似然函数的奇异性（必须知道的陷阱）**

GMM 的似然函数**无上界**！

考虑让某个分模型 $k$ **塌缩到单个数据点** $y_{j_0}$：令 $\mu_k=y_{j_0}$，$\sigma_k\to0$，则

$$
\phi(y_{j_0}\mid\mu_k,\sigma_k)=\frac{1}{\sqrt{2\pi}\sigma_k}\to+\infty，
$$

整个似然也趋于 $+\infty$。

**代码验证**（让分量 1 塌缩到 $y=6$）：

| $\sigma_1$ | $\log L$ |
| ---: | ---: |
| 5.000 | $-86.3149$ |
| 1.000 | $-85.5807$ |
| 0.100 | $-83.9314$ |
| 0.010 | $-81.6450$ |
| 0.001 | $-79.3440$ |

似然持续增大，无上界。

**后果**：

- 严格意义上 GMM 的 MLE **不存在**（全局最优是退化解）；
- 定理 9.2 中"$P(Y\mid\theta)$ 有上界"的条件**不满足**；
- EM 可能收敛到这种无意义的退化解。

**实践对策**：

| 办法 | 说明 |
| --- | --- |
| 方差下界 | 强制 $\sigma_k^2\ge\varepsilon$ |
| 正则化 / MAP | 给 $\sigma_k^2$ 加逆伽马先验 |
| 多次随机初始化 | 丢弃退化解 |
| 共享协方差 | 所有分量用同一个 $\Sigma$ |

> 这是一个很好的提醒：**"极大似然"并非总是良定的**。第 6 章可分数据下逻辑斯谛回归的 MLE 不存在，这里 GMM 的 MLE 也不存在——都需要正则化来补救。

---

### 9.5 EM 的推广：F 函数与 GEM

#### 9.5.1 F 函数

**定义 9.3（F 函数）** 设隐变量 $Z$ 的概率分布为 $\tilde P(Z)$，定义

$$
F\bigl(\tilde P,\theta\bigr)
=\mathbb E_{\tilde P}\bigl[\log P(Y,Z\mid\theta)\bigr]+H\bigl(\tilde P\bigr)，
$$

其中 $H(\tilde P)=-\mathbb E_{\tilde P}\log\tilde P(Z)$ 是分布 $\tilde P$ 的熵。

> **这就是 9.2.5 节的 ELBO**：
>
> $$
> F(\tilde P,\theta)=\mathbb E_{\tilde P}\left[\log\frac{P(Y,Z\mid\theta)}{\tilde P(Z)}\right]
> =\mathrm{ELBO}(\tilde P,\theta)。
> $$
>
> 书中用"能量 + 熵"的形式书写，是统计物理的习惯（对应自由能）。

#### 9.5.2 引理 9.1：F 关于分布的极大

**引理 9.1** 对于固定的 $\theta$，存在唯一的分布 $\tilde P_\theta$ 极大化 $F(\tilde P,\theta)$，且

$$
\boxed{\;\tilde P_\theta(Z)=P(Z\mid Y,\theta)\;}
$$

并且 $\tilde P_\theta$ 随 $\theta$ 连续变化。

**证明（拉格朗日乘子法）**。约束是 $\sum_Z\tilde P(Z)=1$，构造

$$
\mathcal L=\mathbb E_{\tilde P}\log P(Y,Z\mid\theta)
-\mathbb E_{\tilde P}\log\tilde P(Z)
+\lambda\left(1-\sum_Z\tilde P(Z)\right)。
$$

对 $\tilde P(Z)$ 求偏导：

$$
\frac{\partial\mathcal L}{\partial\tilde P(Z)}
=\log P(Y,Z\mid\theta)-\log\tilde P(Z)-1-\lambda。
$$

（注意 $\frac{d}{dp}(-p\log p)=-\log p-1$。）

令偏导为零：

$$
\log\frac{P(Y,Z\mid\theta)}{\tilde P(Z)}=1+\lambda
\quad\Longrightarrow\quad
\frac{P(Y,Z\mid\theta)}{\tilde P(Z)}=e^{1+\lambda}=\text{常数}。
$$

即 $\tilde P(Z)\propto P(Y,Z\mid\theta)$。由归一化条件

$$
\tilde P(Z)=\frac{P(Y,Z\mid\theta)}{\sum_{Z'}P(Y,Z'\mid\theta)}
=\frac{P(Y,Z\mid\theta)}{P(Y\mid\theta)}
=P(Z\mid Y,\theta)。\quad\blacksquare
$$

> **用 ELBO 视角一行就能看出**：由 $L(\theta)=F+\mathrm{KL}(\tilde P\|P(Z\mid Y,\theta))$，固定 $\theta$ 时 $L$ 是常数，极大化 $F$ 等价于极小化 KL，而 KL 在 $\tilde P=P(Z\mid Y,\theta)$ 时取到最小值 0。

#### 9.5.3 引理 9.2

**引理 9.2** 若 $\tilde P(Z)=P(Z\mid Y,\theta)$，则

$$
F\bigl(\tilde P,\theta\bigr)=\log P(Y\mid\theta)。
$$

（证明见 9.9 节习题 9.2。）

**含义**：**在后验分布处，下界与目标函数相等**——这正是 9.2.2 节"性质二"的另一种表述。

#### 9.5.4 EM 的极大-极大解释

**定理 9.4** EM 算法的一次迭代可由 F 函数的**极大-极大算法**实现：

1. 对固定的 $\theta^{(i)}$，求 $\tilde P^{(i+1)}$ 使 $F(\tilde P,\theta^{(i)})$ 极大化；
2. 对固定的 $\tilde P^{(i+1)}$，求 $\theta^{(i+1)}$ 使 $F(\tilde P^{(i+1)},\theta)$ 极大化。

**证明。**

**（1）** 由引理 9.1，

$$
\tilde P^{(i+1)}(Z)=P\bigl(Z\mid Y,\theta^{(i)}\bigr)。
$$

此时

$$
\begin{aligned}
F\bigl(\tilde P^{(i+1)},\theta\bigr)
&=\sum_Z\log P(Y,Z\mid\theta)P\bigl(Z\mid Y,\theta^{(i)}\bigr)+H\bigl(\tilde P^{(i+1)}\bigr)\\
&=Q\bigl(\theta,\theta^{(i)}\bigr)+H\bigl(\tilde P^{(i+1)}\bigr)。
\end{aligned}
$$

**（2）** 由于 $H(\tilde P^{(i+1)})$ 与 $\theta$ 无关：

$$
\theta^{(i+1)}=\arg\max_\theta F\bigl(\tilde P^{(i+1)},\theta\right)
=\arg\max_\theta Q\bigl(\theta,\theta^{(i)}\bigr)。\quad\blacksquare
$$

$$
\boxed{\;
\text{EM}=\text{在}(\tilde P,\theta)\text{上交替极大化同一个函数 }F
\;}
$$

**定理 9.3** 若 $F(\tilde P,\theta)$ 在 $(\tilde P^*,\theta^*)$ 有局部极大值，则 $L(\theta)$ 也在 $\theta^*$ 有局部极大值；全局最大值的结论类似。

**证明思路**：由引理 9.1、9.2，$L(\theta)=F(\tilde P_\theta,\theta)$ 对任意 $\theta$ 成立。若存在 $\theta^{**}$ 使 $L(\theta^{**})>L(\theta^*)$，则 $F(\tilde P_{\theta^{**}},\theta^{**})>F(\tilde P^*,\theta^*)$；由 $\tilde P_\theta$ 随 $\theta$ 连续变化，$\tilde P_{\theta^{**}}$ 应接近 $\tilde P^*$，与 $(\tilde P^*,\theta^*)$ 是局部极大点矛盾。

#### 9.5.5 GEM 算法

**动机**：有时 M 步中求 $Q$ 的**精确极大**很困难。GEM 的想法是——

> 不必求极大，**只要能让 $Q$ 增大**就够了。

回顾定理 9.1 的证明：第 1 项只需要

$$
Q\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)\ge Q\bigl(\theta^{(i)},\theta^{(i)}\bigr)
$$

即可保证似然不减，**并不需要 $\theta^{(i+1)}$ 是极大点**。这就是 GEM 的理论依据。

**算法 9.3（GEM 算法 1）**：直接用 F 函数的两步极大化（即定理 9.4）。

**算法 9.4（GEM 算法 2）**：M 步只要求

$$
Q\bigl(\theta^{(i+1)},\theta^{(i)}\bigr)>Q\bigl(\theta^{(i)},\theta^{(i)}\bigr)。
$$

> 例如可以在 M 步只做**一步梯度上升**，而非解到极大。这样每轮更便宜，总体可能更快。

**算法 9.5（GEM 算法 3）**：当 $\theta$ 是 $d$ 维时，把 M 步分解为 $d$ 次**条件极大化**：每次只改变一个分量，其余固定。

$$
\theta_1^{(i+1)}=\arg\max_{\theta_1}Q\bigl((\theta_1,\theta_2^{(i)},\ldots,\theta_d^{(i)}),\theta^{(i)}\bigr)，
$$

$$
\theta_2^{(i+1)}=\arg\max_{\theta_2}Q\bigl((\theta_1^{(i+1)},\theta_2,\theta_3^{(i)},\ldots),\theta^{(i)}\bigr)，
$$

依次类推。经过 $d$ 次条件极大化后必有 $Q(\theta^{(i+1)},\theta^{(i)})\ge Q(\theta^{(i)},\theta^{(i)})$。

> 这称为 **ECM 算法**（Expectation Conditional Maximization），思路与第 7 章 SMO"每次只优化两个变量"、坐标下降法一脉相承：**把高维难题拆成一系列低维易题**。

---

### 9.6 代码实现与验证

```python
"""EM 算法及其推广（《统计学习方法》第 9 章）"""
import math
import random


class ThreeCoins:
    """三硬币模型：P(y|θ) = π·p^y(1-p)^(1-y) + (1-π)·q^y(1-q)^(1-y)"""

    def __init__(self, Y):
        self.Y = Y
        self.n = len(Y)

    def loglik(self, pi, p, q):
        return sum(math.log(pi * p ** y * (1 - p) ** (1 - y) +
                            (1 - pi) * q ** y * (1 - q) ** (1 - y))
                   for y in self.Y)

    def e_step(self, pi, p, q):
        """响应度 μ_j = P(z_j = B | y_j, θ)"""
        mu = []
        for y in self.Y:
            a = pi * p ** y * (1 - p) ** (1 - y)
            b = (1 - pi) * q ** y * (1 - q) ** (1 - y)
            mu.append(a / (a + b))
        return mu

    def m_step(self, mu):
        """用软标签 μ 代替硬标签做加权计数"""
        n = self.n
        s1, s0 = sum(mu), sum(1 - m for m in mu)
        pi = s1 / n
        p = sum(mu[j] * self.Y[j] for j in range(n)) / s1
        q = sum((1 - mu[j]) * self.Y[j] for j in range(n)) / s0
        return pi, p, q

    def fit(self, pi, p, q, iters=100, tol=1e-12, verbose=False):
        hist = [(0, pi, p, q, self.loglik(pi, p, q))]
        for it in range(1, iters + 1):
            new = self.m_step(self.e_step(pi, p, q))
            d = max(abs(a - b) for a, b in zip(new, (pi, p, q)))
            pi, p, q = new
            hist.append((it, pi, p, q, self.loglik(pi, p, q)))
            if d < tol:
                break
        if verbose:
            print("   iter      π          p          q         logL")
            for (it, a, b, c, L) in hist[:4]:
                print(f"    {it}    {a:.6f}   {b:.6f}   {c:.6f}   {L:.8f}")
        return pi, p, q, len(hist) - 1


def gaussian(y, mu, sigma):
    return (math.exp(-(y - mu) ** 2 / (2 * sigma ** 2))
            / (math.sqrt(2 * math.pi) * sigma))


class GMM:
    """一维高斯混合模型，用 EM 估计参数"""

    def __init__(self, data, K=2):
        self.data, self.K, self.N = data, K, len(data)

    def loglik(self, alpha, mu, sigma):
        return sum(math.log(sum(alpha[k] * gaussian(y, mu[k], sigma[k])
                                for k in range(self.K)))
                   for y in self.data)

    def e_step(self, alpha, mu, sigma):
        """响应度 γ_jk = α_k φ(y_j|θ_k) / Σ_k' α_k' φ(y_j|θ_k')"""
        gam = []
        for y in self.data:
            w = [alpha[k] * gaussian(y, mu[k], sigma[k]) for k in range(self.K)]
            s = sum(w)
            gam.append([v / s for v in w])
        return gam

    def m_step(self, gam):
        """加权均值 / 加权方差 / 软样本比例"""
        N, K = self.N, self.K
        nk = [sum(gam[j][k] for j in range(N)) for k in range(K)]
        mu = [sum(gam[j][k] * self.data[j] for j in range(N)) / nk[k]
              for k in range(K)]
        sigma = [math.sqrt(sum(gam[j][k] * (self.data[j] - mu[k]) ** 2
                               for j in range(N)) / nk[k]) for k in range(K)]
        alpha = [nk[k] / N for k in range(K)]
        return alpha, mu, sigma

    def fit(self, alpha, mu, sigma, iters=2000, tol=1e-12):
        for it in range(1, iters + 1):
            na, nm, ns = self.m_step(self.e_step(alpha, mu, sigma))
            d = max(max(abs(x - y) for x, y in zip(a, b))
                    for a, b in [(na, alpha), (nm, mu), (ns, sigma)])
            alpha, mu, sigma = na, nm, ns
            if d < tol:
                break
        return alpha, mu, sigma, it


class MixtureNaiveBayes:
    """朴素贝叶斯的无监督版本：类标签作为隐变量，用 EM 学习"""

    def __init__(self, X, K, n_values, lam=1.0):
        self.X, self.K, self.N = X, K, len(X)
        self.n_feat = len(X[0])
        self.S = n_values                 # 各特征的取值个数
        self.lam = lam                    # 平滑系数（防止 0 概率）

    def _prob(self, pi, theta, x, k):
        """π_k · Π_l P(x^(l) | c_k)"""
        p = pi[k]
        for l, v in enumerate(x):
            p *= theta[k][l][v]
        return p

    def e_step(self, pi, theta):
        """γ_jk = P(z_j = c_k | x_j, θ)"""
        gam = []
        for x in self.X:
            w = [self._prob(pi, theta, x, k) for k in range(self.K)]
            s = sum(w)
            gam.append([v / s for v in w])
        return gam

    def m_step(self, gam):
        """把有监督计数中的 1(y_j=c_k) 换成软责任 γ_jk"""
        K, N = self.K, self.N
        nk = [sum(gam[j][k] for j in range(N)) for k in range(K)]
        pi = [nk[k] / N for k in range(K)]
        theta = []
        for k in range(K):
            per_feat = []
            for l in range(self.n_feat):
                cnt = [self.lam] * self.S[l]
                for j in range(N):
                    cnt[self.X[j][l]] += gam[j][k]
                tot = nk[k] + self.lam * self.S[l]
                per_feat.append([c / tot for c in cnt])
            theta.append(per_feat)
        return pi, theta

    def loglik(self, pi, theta):
        return sum(math.log(sum(self._prob(pi, theta, x, k)
                                for k in range(self.K))) for x in self.X)

    def fit(self, pi, theta, iters=500, tol=1e-12):
        prev = self.loglik(pi, theta)
        for it in range(1, iters + 1):
            pi, theta = self.m_step(self.e_step(pi, theta))
            cur = self.loglik(pi, theta)
            if abs(cur - prev) < tol:
                break
            prev = cur
        return pi, theta, it


def show(t):
    print("\n" + "=" * 62)
    print(t)
    print("=" * 62)


show("【例 9.1】三硬币模型")
Y = [1, 1, 0, 1, 0, 0, 1, 0, 1, 1]
tc = ThreeCoins(Y)
print(f"  观测数据: {Y}   (1 的个数={sum(Y)}, 0 的个数={len(Y)-sum(Y)})")

for init in [(0.5, 0.5, 0.5), (0.4, 0.6, 0.7), (0.46, 0.55, 0.67)]:
    pi, p, q, n_it = tc.fit(*init)
    tag = "  ← 习题 9.1" if init == (0.46, 0.55, 0.67) else ""
    print(f"\n  初值 {init}{tag}")
    print(f"    收敛 → π={pi:.4f}  p={p:.4f}  q={q:.4f}   "
          f"(迭代 {n_it} 次)  logL={tc.loglik(pi,p,q):.6f}")
    print(f"    边缘概率 πp+(1-π)q = {pi*p+(1-pi)*q:.6f}")

show("【关键发现】三硬币模型不可辨识")
print("  似然只依赖组合 θ_eff = πp + (1-π)q：\n")
print("      (π, p, q)                θ_eff        logL")
for (pi, p, q) in [(0.5, 0.6, 0.6), (0.4064, 0.5368, 0.6432),
                   (0.2, 0.1, 0.725), (0.8, 0.65, 0.4)]:
    print(f"    ({pi:.4f}, {p:.4f}, {q:.4f})    {pi*p+(1-pi)*q:.6f}    "
          f"{tc.loglik(pi,p,q):.6f}")
s, n = sum(Y), len(Y)
print(f"\n  伯努利 MLE: θ̂ = {s}/{n} = {s/n}")
print(f"  对应 logL = {s}·log(0.6) + {n-s}·log(0.4) = "
      f"{s*math.log(0.6)+(n-s)*math.log(0.4):.6f}")
print("  ⇒ 满足 πp+(1-π)q=0.6 的解都是全局最优，参数不可辨识")

show("【定理 9.1】似然函数单调不减")
tc.fit(0.4, 0.6, 0.7, verbose=True)

show("【ELBO 分解】L(θ) = F(P̃,θ) + KL(P̃ ‖ P(Z|Y,θ))")
pi, p, q = 0.45, 0.55, 0.65
post = tc.e_step(pi, p, q)
random.seed(0)

for desc, P in [("任意分布 P̃(Z)", [random.uniform(0.15, 0.85) for _ in Y]),
                ("P̃(Z) = P(Z|Y,θ)（E 步的解）", post)]:
    F = KL = 0.0
    for j, y in enumerate(Y):
        pz = P[j]
        jb = pi * p ** y * (1 - p) ** (1 - y)
        jc = (1 - pi) * q ** y * (1 - q) ** (1 - y)
        F += pz * math.log(jb) + (1 - pz) * math.log(jc)          # 能量项
        F += -(pz * math.log(pz) + (1 - pz) * math.log(1 - pz))   # 熵
        pb = post[j]
        KL += pz * math.log(pz / pb) + (1 - pz) * math.log((1 - pz) / (1 - pb))
    L = tc.loglik(pi, p, q)
    print(f"\n  {desc}:")
    print(f"    L={L:.8f}   F={F:.8f}   KL={KL:.8f}")
    print(f"    F+KL={F+KL:.8f}   |L-(F+KL)|={abs(L-(F+KL)):.1e}")

show("【习题 9.3】两分量高斯混合模型")
data = [-67, -48, 6, 8, 14, 16, 23, 24, 28, 29, 41, 49, 56, 60, 75]
gmm = GMM(data, K=2)
mean = sum(data) / len(data)
sd = math.sqrt(sum((y - mean) ** 2 for y in data) / len(data))
print(f"  数据 (N={len(data)}): {data}")
print(f"  样本均值={mean:.4f}  样本标准差={sd:.4f}\n")

inits = [([0.5, 0.5], [-30.0, 30.0], [20.0, 20.0]),
         ([0.5, 0.5], [mean - sd, mean + sd], [sd, sd]),
         ([0.3, 0.7], [-50.0, 30.0], [10.0, 25.0]),
         ([0.5, 0.5], [0.0, 50.0], [10.0, 10.0])]
for k, ini in enumerate(inits, 1):
    a, m, s_, it = gmm.fit(*ini)
    print(f"  初值{k}: α={ini[0]}, μ={ini[1]}, σ={ini[2]}")
    print(f"    → α=({a[0]:.4f}, {a[1]:.4f})  μ=({m[0]:.4f}, {m[1]:.4f})  "
          f"σ=({s_[0]:.4f}, {s_[1]:.4f})")
    print(f"      logL={gmm.loglik(a,m,s_):.6f}  ({it} 次迭代)")
print(f"\n  单个高斯拟合的 logL = "
      f"{sum(math.log(gaussian(y, mean, sd)) for y in data):.6f}（对比）")

show("【陷阱】GMM 似然函数无上界")
print("  让分量 1 塌缩到数据点 y=6，令 σ₁ → 0：\n")
print("      σ₁          logL")
for s1 in [5.0, 1.0, 0.1, 0.01, 0.001]:
    print(f"    {s1:<8.3f}   {gmm.loglik([0.1, 0.9], [6.0, 33.0], [s1, 20.0]):.4f}")
print("\n  ⇒ σ→0 时 logL → +∞，MLE 不存在；需方差下界或正则化")

show("【习题 9.4】EM 用于朴素贝叶斯的无监督学习")
random.seed(42)
Xd = []
for _ in range(40):
    Xd.append([random.choice([0, 0, 0, 1]) for _ in range(3)])   # 真实簇 0
for _ in range(40):
    Xd.append([random.choice([1, 2, 2, 2]) for _ in range(3)])   # 真实簇 1
truth = [0] * 40 + [1] * 40

mnb = MixtureNaiveBayes(Xd, K=2, n_values=[3, 3, 3])
random.seed(1)
pi0 = [0.5, 0.5]
theta0 = [[[random.uniform(0.2, 0.5) for _ in range(3)] for _ in range(3)]
          for _ in range(2)]
theta0 = [[[v / sum(row) for v in row] for row in feat] for feat in theta0]

print(f"  数据: {len(Xd)} 个样本，3 个特征（各 3 个取值），2 个簇，标签未知")
print(f"  初始 logL = {mnb.loglik(pi0, theta0):.6f}")
pi_h, th_h, it = mnb.fit(pi0, theta0)
print(f"  收敛 logL = {mnb.loglik(pi_h, th_h):.6f}   ({it} 次迭代)")
print(f"  学到的混合比例 π = ({pi_h[0]:.4f}, {pi_h[1]:.4f})")

gam = mnb.e_step(pi_h, th_h)
pred = [0 if g[0] > 0.5 else 1 for g in gam]
acc = max(sum(p == t for p, t in zip(pred, truth)),
          sum(p != t for p, t in zip(pred, truth))) / len(truth)
print(f"  与真实簇的一致率 = {acc:.4f}（标签置换后取最优）")
print("\n  M 步公式对照：")
print("    有监督： P(x⁽ˡ⁾=a | c_k) = Σ_j 1(y_j=c_k)·1(x_j⁽ˡ⁾=a) / Σ_j 1(y_j=c_k)")
print("    无监督： P(x⁽ˡ⁾=a | c_k) = Σ_j γ_jk·1(x_j⁽ˡ⁾=a) / Σ_j γ_jk")
print("    ⇒ 只是把硬指示 1(y_j=c_k) 换成了软责任 γ_jk")
```

**运行结果：**

```text
==============================================================
【例 9.1】三硬币模型
==============================================================
  观测数据: [1, 1, 0, 1, 0, 0, 1, 0, 1, 1]   (1 的个数=6, 0 的个数=4)

  初值 (0.5, 0.5, 0.5)
    收敛 → π=0.5000  p=0.6000  q=0.6000   (迭代 2 次)  logL=-6.730117
    边缘概率 πp+(1-π)q = 0.600000

  初值 (0.4, 0.6, 0.7)
    收敛 → π=0.4064  p=0.5368  q=0.6432   (迭代 2 次)  logL=-6.730117
    边缘概率 πp+(1-π)q = 0.600000

  初值 (0.46, 0.55, 0.67)  ← 习题 9.1
    收敛 → π=0.4619  p=0.5346  q=0.6561   (迭代 2 次)  logL=-6.730117
    边缘概率 πp+(1-π)q = 0.600000

==============================================================
【关键发现】三硬币模型不可辨识
==============================================================
  似然只依赖组合 θ_eff = πp + (1-π)q：

      (π, p, q)                θ_eff        logL
    (0.5000, 0.6000, 0.6000)    0.600000    -6.730117
    (0.4064, 0.5368, 0.6432)    0.599959    -6.730117
    (0.2000, 0.1000, 0.7250)    0.600000    -6.730117
    (0.8000, 0.6500, 0.4000)    0.600000    -6.730117

  伯努利 MLE: θ̂ = 6/10 = 0.6
  对应 logL = 6·log(0.6) + 4·log(0.4) = -6.730117
  ⇒ 满足 πp+(1-π)q=0.6 的解都是全局最优，参数不可辨识

==============================================================
【定理 9.1】似然函数单调不减
==============================================================
   iter      π          p          q         logL
    0    0.400000   0.600000   0.700000   -6.80833131
    1    0.406417   0.536842   0.643243   -6.73011667
    2    0.406417   0.536842   0.643243   -6.73011667

==============================================================
【ELBO 分解】L(θ) = F(P̃,θ) + KL(P̃ ‖ P(Z|Y,θ))
==============================================================

  任意分布 P̃(Z):
    L=-6.73063898   F=-7.41518517   KL=0.68454618
    F+KL=-6.73063898   |L-(F+KL)|=8.9e-16

  P̃(Z) = P(Z|Y,θ)（E 步的解）:
    L=-6.73063898   F=-6.73063898   KL=0.00000000
    F+KL=-6.73063898   |L-(F+KL)|=1.8e-15

==============================================================
【习题 9.3】两分量高斯混合模型
==============================================================
  数据 (N=15): [-67, -48, 6, 8, 14, 16, 23, 24, 28, 29, 41, 49, 56, 60, 75]
  样本均值=20.9333  样本标准差=36.4645

  初值1: α=[0.5, 0.5], μ=[-30.0, 30.0], σ=[20.0, 20.0]
    → α=(0.1332, 0.8668)  μ=(-57.5111, 32.9849)  σ=(9.5000, 20.7234)
      logL=-71.063362  (12 次迭代)
  初值2: α=[0.5, 0.5], μ=[-15.531200425131512, 57.397867091798176], σ=[36.464533758464846, 36.464533758464846]
    → α=(0.1332, 0.8668)  μ=(-57.5111, 32.9849)  σ=(9.5000, 20.7234)
      logL=-71.063362  (26 次迭代)
  初值3: α=[0.3, 0.7], μ=[-50.0, 30.0], σ=[10.0, 25.0]
    → α=(0.1332, 0.8668)  μ=(-57.5111, 32.9849)  σ=(9.5000, 20.7234)
      logL=-71.063362  (9 次迭代)
  初值4: α=[0.5, 0.5], μ=[0.0, 50.0], σ=[10.0, 10.0]
    → α=(0.1332, 0.8668)  μ=(-57.5111, 32.9849)  σ=(9.5000, 20.7234)
      logL=-71.063362  (28 次迭代)

  单个高斯拟合的 logL = -75.229180（对比）

==============================================================
【陷阱】GMM 似然函数无上界
==============================================================
  让分量 1 塌缩到数据点 y=6，令 σ₁ → 0：

      σ₁          logL
    5.000      -86.3149
    1.000      -85.5807
    0.100      -83.9314
    0.010      -81.6450
    0.001      -79.3440

  ⇒ σ→0 时 logL → +∞，MLE 不存在；需方差下界或正则化

==============================================================
【习题 9.4】EM 用于朴素贝叶斯的无监督学习
==============================================================
  数据: 80 个样本，3 个特征（各 3 个取值），2 个簇，标签未知
  初始 logL = -269.570147
  收敛 logL = -190.935661   (27 次迭代)
  学到的混合比例 π = (0.5231, 0.4769)
  与真实簇的一致率 = 0.9750（标签置换后取最优）

  M 步公式对照：
    有监督： P(x⁽ˡ⁾=a | c_k) = Σ_j 1(y_j=c_k)·1(x_j⁽ˡ⁾=a) / Σ_j 1(y_j=c_k)
    无监督： P(x⁽ˡ⁾=a | c_k) = Σ_j γ_jk·1(x_j⁽ˡ⁾=a) / Σ_j γ_jk
    ⇒ 只是把硬指示 1(y_j=c_k) 换成了软责任 γ_jk
```

> **Windows 运行提示**：若报 `UnicodeEncodeError`，执行前设置 `$env:PYTHONIOENCODING = "utf-8"`。

**代码验证的六个结论：**

| 结论 | 证据 |
| --- | --- |
| 三硬币 EM 复现书中结果 | 两组初值分别得到 $(0.5,0.6,0.6)$ 与 $(0.4064,0.5368,0.6432)$ |
| **模型不可辨识** | 所有解的 $\log L$ 均为 $-6.730117=$ 伯努利 MLE 值 |
| 定理 9.1 单调性 | $-6.808\to-6.730$，单调不减 |
| **ELBO 分解精确成立** | $\lvert L-(F+\mathrm{KL})\rvert\approx10^{-15}$；取后验时 $\mathrm{KL}=0$ |
| **GMM 似然无上界** | $\sigma_1\to0$ 时 $\log L$ 持续增大 |
| 混合朴素贝叶斯有效 | 无标签学习，与真实簇一致率 **97.5%**（80 个样本仅错 2 个）|

---

### 9.7 深入理解

#### 9.7.1 EM 的适用范围

**EM 适合的场景**：

| 条件 | 说明 |
| --- | --- |
| 存在隐变量 | 类别未知、数据缺失、混合模型 |
| **完全数据的 MLE 容易** | E 步和 M 步都有闭式解 |
| 后验 $P(Z\mid Y,\theta)$ 可计算 | 否则要用变分或采样近似 |

**典型应用**：

| 模型 | 隐变量 |
| --- | --- |
| 高斯混合模型 | 样本属于哪个分量 |
| 隐马尔可夫模型（第 10 章） | 状态序列（Baum-Welch = EM） |
| 概率潜在语义分析（第 18 章） | 主题 |
| 潜在狄利克雷分配（第 20 章） | 主题分配 |
| 缺失数据填补 | 缺失值本身 |

> 第 10 章的 Baum-Welch 算法就是 EM 在 HMM 上的具体化，本章的框架会直接复用。

#### 9.7.2 EM 的优缺点

**优点**：

- **每步保证似然不减**（无需调学习率）；
- 实现简单，E/M 两步往往都有闭式解；
- 数值稳定（参数自动满足概率约束，如 $\alpha_k\ge0,\sum\alpha_k=1$）；
- 普适性强，适用于各种含隐变量模型。

**缺点**：

- **只保证局部最优**（甚至只是稳定点）；
- **对初值敏感**；
- 收敛速度只有**线性**（比牛顿法慢）；
- 每步需遍历全部数据，大规模时代价高；
- E 步可能不可解（后验难算）。

**改进方向**：

| 问题 | 方法 |
| --- | --- |
| 局部最优 | 多次随机初始化；$k$ 均值初始化 GMM |
| 收敛慢 | Aitken 加速；准牛顿 EM |
| 大数据 | 增量 EM / 在线 EM / 随机 EM |
| E 步不可解 | **变分 EM**、蒙特卡洛 EM（第 19 章 MCMC） |
| M 步不可解 | **GEM / ECM**（9.5.5 节） |

#### 9.7.3 与其他章节的联系

| 章节 | 联系 |
| --- | --- |
| 第 1 章 | EM 求的是极大似然估计（也可做 MAP） |
| 第 4 章 | 朴素贝叶斯的无监督版本就是 EM（习题 9.4） |
| 第 5 章 | 熵的概念（F 函数中的 $H(\tilde P)$） |
| 第 6 章 | 最大熵模型也用拉格朗日 + 熵；引理 9.1 的推导与之几乎相同 |
| 第 10 章 | **Baum-Welch 算法 = HMM 上的 EM** |
| 第 14 章 | **$k$ 均值是 GMM 的硬划分极限** |
| 第 18、20 章 | PLSA、LDA 都用 EM 或变分 EM |

**一个值得注意的重复出现的模式**：

$$
\text{拉格朗日乘子法 + 归一化约束}\;\Longrightarrow\;\text{解正比于某个量}
$$

| 场景 | 结果 |
| --- | --- |
| 第 4 章习题 4.1 | $\hat\theta_k=m_k/N$ |
| 第 6 章最大熵 | $P_w(y\mid x)\propto\exp(\sum w_if_i)$ |
| 本章引理 9.1 | $\tilde P(Z)\propto P(Y,Z\mid\theta)$ |
| 本章 M 步求 $\alpha_k$ | $\hat\alpha_k=n_k/N$ |

**同一套数学工具在不同问题上反复出现**——这正是掌握方法论的价值。

---

### 9.8 本章方法论总结

#### 9.8.1 用三要素分析

**模型**：含隐变量的概率模型 $P(Y,Z\mid\theta)$，属于**概率生成模型**。

**策略**：极大化观测数据的对数似然

$$
L(\theta)=\log P(Y\mid\theta)=\log\sum_ZP(Y,Z\mid\theta)。
$$

**算法**：EM 迭代（下界最大化）

$$
\text{E 步：}\;Q(\theta,\theta^{(i)})=\mathbb E_{Z\mid Y,\theta^{(i)}}[\log P(Y,Z\mid\theta)]，
$$

$$
\text{M 步：}\;\theta^{(i+1)}=\arg\max_\theta Q(\theta,\theta^{(i)})。
$$

#### 9.8.2 必须掌握的结论

1. 隐变量使对数似然出现 $\log\sum_Z$ 结构，**对数套求和**导致无法解析求解。
2. EM 用 **Jensen 不等式**把 $\log\sum$ 转为 $\sum\log$，构造出易优化的下界。
3. $Q$ 函数是**完全数据对数似然关于隐变量后验分布的期望**；两个变元角色不同。
4. 下界 $B(\theta,\theta^{(i)})$ 有两个关键性质：$L\ge B$，且在 $\theta^{(i)}$ 处**相切**。
5. 极大化下界 $\Leftrightarrow$ 极大化 $Q$ 函数（去掉与 $\theta$ 无关的项）。
6. EM 属于 **MM 算法**（下界最大化）框架。
7. **ELBO 恒等式** $L(\theta)=\mathrm{ELBO}(q,\theta)+\mathrm{KL}(q\|P(Z\mid Y,\theta))$ 统一解释了 E 步与 M 步。
8. E 步 = 固定 $\theta$ 优化 $q$（使 KL $=0$）；M 步 = 固定 $q$ 优化 $\theta$；**EM 是坐标上升**。
9. **定理 9.1**：似然单调不减。证明分解为 $\log P(Y\mid\theta)=Q-H$，$Q$ 项由 M 步保证，$H$ 项由 Jensen 保证。
10. **定理 9.2**：似然值收敛 $\ne$ 参数收敛；只保证收敛到**稳定点**，不保证极大值点。
11. EM 对初值敏感，实践中应**多次随机初始化取最优**。
12. **三硬币模型是不可辨识的**：似然只依赖 $\pi p+(1-\pi)q$，多组解同为全局最优。
13. GMM 的 E 步计算**响应度** $\hat\gamma_{jk}$，M 步是**加权均值、加权方差、软样本比例**。
14. M 步的记忆法：把有标签公式中的 $\mathbf 1(z_j=k)$ 换成 $\hat\gamma_{jk}$。
15. 求 $\alpha_k$ 需用**拉格朗日乘子法**处理 $\sum\alpha_k=1$ 约束。
16. **GMM 的似然函数无上界**（$\sigma\to0$ 时发散），MLE 严格意义上不存在，需正则化。
17. $k$ 均值是 GMM 在 $\sigma\to0$ 时的**硬划分极限**。
18. F 函数就是 **ELBO**；引理 9.1 说明其关于分布的极大点是后验分布。
19. EM 可解释为 F 函数的**极大-极大算法**（定理 9.4）。
20. **GEM** 只要求 M 步使 $Q$ 增大（不必极大），仍保证似然不减；ECM 把 M 步拆成 $d$ 次条件极大化。

---

### 9.9 习题思路与推导

#### 习题 9.1：不同初值下的三硬币模型

**问题**：取 $\pi^{(0)}=0.46$，$p^{(0)}=0.55$，$q^{(0)}=0.67$，求 $\theta=(\pi,p,q)$ 的极大似然估计。

**求解**（代码计算）：

$$
\boxed{\hat\pi=0.4619,\quad\hat p=0.5346,\quad\hat q=0.6561}
$$

$\log L=-6.730117$，仅需 2 次迭代收敛。

**手工验证第一次迭代**：

E 步。对 $y_j=1$ 的样本：

$$
\mu_j=\frac{0.46\times0.55}{0.46\times0.55+0.54\times0.67}
=\frac{0.2530}{0.2530+0.3618}=0.4115。
$$

对 $y_j=0$ 的样本：

$$
\mu_j=\frac{0.46\times0.45}{0.46\times0.45+0.54\times0.33}
=\frac{0.2070}{0.2070+0.1782}=0.5374。
$$

M 步（6 个 $y=1$，4 个 $y=0$）：

$$
\pi^{(1)}=\frac{6\times0.4115+4\times0.5374}{10}=0.4619，
$$

$$
p^{(1)}=\frac{6\times0.4115}{6\times0.4115+4\times0.5374}
=\frac{2.4690}{4.6186}=0.5346，
$$

$$
q^{(1)}=\frac{6\times0.5885}{6\times0.5885+4\times0.4626}
=\frac{3.5310}{5.3814}=0.6561。
$$

与代码结果一致 ✓

**三组初值的对比**：

| 初值 | 收敛解 $(\hat\pi,\hat p,\hat q)$ | $\pi p+(1-\pi)q$ | $\log L$ |
| --- | --- | ---: | ---: |
| $(0.5,0.5,0.5)$ | $(0.5000,0.6000,0.6000)$ | $0.6000$ | $-6.730117$ |
| $(0.4,0.6,0.7)$ | $(0.4064,0.5368,0.6432)$ | $0.6000$ | $-6.730117$ |
| $(0.46,0.55,0.67)$ | $(0.4619,0.5346,0.6561)$ | $0.6000$ | $-6.730117$ |

**结论与分析**（这才是本题的重点）：

1. **三组解的对数似然完全相同**，都等于伯努利 MLE 的最大值 $6\log0.6+4\log0.4$；
2. 三组解的**边缘概率 $\pi p+(1-\pi)q$ 都等于 $0.6$**；
3. 因此**这些都是全局最优解**——模型不可辨识，最优解构成一条"山脊"；
4. EM 收敛到山脊上的哪一点，完全由初值决定（准确说，由初值在第一次 E 步产生的响应度决定）。

> **区分两种"初值敏感"**：
>
> | 类型 | 本质 | 解决办法 |
> | --- | --- | --- |
> | **不可辨识**（本例） | 多个全局最优 | 加约束/先验，或接受任一解 |
> | **多局部极值**（一般 GMM） | 存在次优的局部峰 | 多次初始化取似然最大者 |
>
> 本例属于前者，所以"选不同初值取最好"在这里**没有意义**——它们一样好。

#### 习题 9.2：证明引理 9.2

**命题**：若 $\tilde P(Z)=P(Z\mid Y,\theta)$，则

$$
F\bigl(\tilde P,\theta\bigr)=\log P(Y\mid\theta)。
$$

**证明**。由 F 函数的定义：

$$
\begin{aligned}
F\bigl(\tilde P,\theta\bigr)
&=\mathbb E_{\tilde P}\bigl[\log P(Y,Z\mid\theta)\bigr]+H\bigl(\tilde P\bigr)\\
&=\sum_Z\tilde P(Z)\log P(Y,Z\mid\theta)
-\sum_Z\tilde P(Z)\log\tilde P(Z)\\
&=\sum_Z\tilde P(Z)\log\frac{P(Y,Z\mid\theta)}{\tilde P(Z)}。
\end{aligned}
$$

代入 $\tilde P(Z)=P(Z\mid Y,\theta)$：

$$
F=\sum_ZP(Z\mid Y,\theta)
\log\frac{P(Y,Z\mid\theta)}{P(Z\mid Y,\theta)}。
$$

**关键一步**：由条件概率的定义

$$
P(Z\mid Y,\theta)=\frac{P(Y,Z\mid\theta)}{P(Y\mid\theta)}
\quad\Longrightarrow\quad
\frac{P(Y,Z\mid\theta)}{P(Z\mid Y,\theta)}=P(Y\mid\theta)。
$$

**注意这个比值与 $Z$ 无关**！于是

$$
\begin{aligned}
F&=\sum_ZP(Z\mid Y,\theta)\log P(Y\mid\theta)\\
&=\log P(Y\mid\theta)\underbrace{\sum_ZP(Z\mid Y,\theta)}_{=1}\\
&=\log P(Y\mid\theta)。\quad\blacksquare
\end{aligned}
$$

**另一种证法（用 ELBO 恒等式）**：由 9.2.5 节，

$$
L(\theta)=F\bigl(\tilde P,\theta\bigr)
+\mathrm{KL}\bigl(\tilde P\,\big\|\,P(Z\mid Y,\theta)\bigr)。
$$

当 $\tilde P=P(Z\mid Y,\theta)$ 时，KL 散度为 0（两个分布相同），故 $F=L(\theta)$ ✓

**这个引理的意义**：它说明 **F 函数（下界）在后验分布处恰好"顶到"目标函数**。结合引理 9.1（后验是 F 关于分布的极大点），就得到了 EM 的完整图景：

$$
\max_{\tilde P}F\bigl(\tilde P,\theta\bigr)=F\bigl(P(Z\mid Y,\theta),\theta\bigr)=L(\theta)。
$$

#### 习题 9.3：两分量高斯混合模型

**数据**（$N=15$）：

$$
-67,-48,6,8,14,16,23,24,28,29,41,49,56,60,75
$$

**求解**。5 个参数为 $(\alpha_1,\mu_1,\sigma_1,\mu_2,\sigma_2)$，其中 $\alpha_2=1-\alpha_1$。

用 EM 迭代（4 组不同初值均收敛到同一解）：

$$
\boxed{
\begin{aligned}
\hat\alpha_1&=0.1332, &\hat\mu_1&=-57.5111, &\hat\sigma_1&=9.5000\\
\hat\alpha_2&=0.8668, &\hat\mu_2&=32.9849, &\hat\sigma_2&=20.7234
\end{aligned}}
$$

$\log L=-71.063362$。

**结果解读**（这是本题最有意思的部分）：

观察 $\hat\alpha_1=0.1332\approx\dfrac{2}{15}=0.1333$，说明第一个分量差不多只"负责" **2 个样本**。

再看：

$$
\hat\mu_1=-57.51\approx\frac{-67+(-48)}{2}=-57.5，
$$

$$
\hat\sigma_1=9.50=\frac{|-67-(-48)|}{2}=9.5。
$$

$$
\boxed{\;\text{第一个分量精确地抓住了两个离群点 }-67\text{ 和 }-48\;}
$$

第二个分量则拟合剩下的 13 个样本（大致在 6 到 75 之间），$\hat\mu_2=32.98$，$\hat\sigma_2=20.72$。

**对比单个高斯拟合**：

| 模型 | 参数个数 | $\log L$ |
| --- | ---: | ---: |
| 单个高斯 | 2 | $-75.229180$ |
| 两分量 GMM | 5 | $\boxed{-71.063362}$ |

混合模型的似然明显更高（提升约 4.17），说明数据确实呈现两簇结构。

**收敛稳健性**：4 组差异很大的初值都收敛到同一解，说明本题的似然曲面在该区域比较"干净"，局部最优问题不严重。

| 初值 | 迭代次数 |
| --- | ---: |
| $\alpha=(0.5,0.5),\mu=(-30,30),\sigma=(20,20)$ | 12 |
| $\mu=\bar y\mp s$ | 26 |
| $\alpha=(0.3,0.7),\mu=(-50,30),\sigma=(10,25)$ | 9 |
| $\mu=(0,50),\sigma=(10,10)$ | 28 |

> **但要小心**：如果初值让某个分量的 $\sigma$ 很小且靠近某个数据点，就可能落入 9.4.5 节的**退化解**。实践中应设置方差下界。

#### 习题 9.4：EM 用于朴素贝叶斯的无监督学习

**问题设定**。第 4 章的朴素贝叶斯是**有监督**的：给定 $(x_j,y_j)$，直接数频数。现在假设**类标签 $y_j$ 未知**（作为隐变量），如何学习？

这个模型称为**混合朴素贝叶斯**（mixture of naive Bayes），也是文本聚类的经典模型。

**模型**。设类别数为 $K$，参数为

$$
\theta=\bigl\{\pi_k,\;\theta_{kl s}\bigr\},
$$

其中

- $\pi_k=P(y=c_k)$ 是混合系数，$\sum_k\pi_k=1$；
- $\theta_{kls}=P(x^{(l)}=a_{ls}\mid y=c_k)$ 是类条件概率，对每个 $(k,l)$ 满足 $\sum_s\theta_{kls}=1$。

由**条件独立假设**（第 4 章的核心），

$$
P(x_j\mid y=c_k,\theta)=\prod_{l=1}^{n}P\bigl(x_j^{(l)}\mid y=c_k\bigr)。
$$

观测数据的似然：

$$
P(x_j\mid\theta)=\sum_{k=1}^{K}\pi_k\prod_{l=1}^{n}P\bigl(x_j^{(l)}\mid c_k\bigr)。
$$

**完全数据的对数似然**。引入隐变量 $\gamma_{jk}=\mathbf 1(y_j=c_k)$：

$$
\log P(X,\gamma\mid\theta)
=\sum_{j=1}^{N}\sum_{k=1}^{K}\gamma_{jk}
\left[\log\pi_k+\sum_{l=1}^{n}\log P\bigl(x_j^{(l)}\mid c_k\bigr)\right]。
$$

**E 步**：计算响应度

$$
\boxed{\;
\hat\gamma_{jk}=P(y_j=c_k\mid x_j,\theta)
=\frac{\pi_k\prod_{l}P\bigl(x_j^{(l)}\mid c_k\bigr)}
{\sum_{k'=1}^{K}\pi_{k'}\prod_{l}P\bigl(x_j^{(l)}\mid c_{k'}\bigr)}
\;}
$$

> **这正是第 4 章的朴素贝叶斯分类公式**！区别在于：第 4 章用它做**预测**，这里用它做**软标签分配**。

**M 步**：对 $Q$ 函数关于各参数求极大。

**（1）求 $\pi_k$**（带约束 $\sum_k\pi_k=1$，用拉格朗日乘子法，与 9.4.4 节相同）：

$$
\boxed{\;\hat\pi_k=\frac{1}{N}\sum_{j=1}^{N}\hat\gamma_{jk}\;}
$$

**（2）求 $\theta_{kls}$**（带约束 $\sum_s\theta_{kls}=1$）：

$Q$ 中与 $\theta_{kl\cdot}$ 有关的项为

$$
\sum_{j}\hat\gamma_{jk}\sum_s\mathbf 1\bigl(x_j^{(l)}=a_{ls}\bigr)\log\theta_{kls}，
$$

同样用拉格朗日乘子法得

$$
\boxed{\;
P\bigl(x^{(l)}=a_{ls}\mid c_k\bigr)
=\frac{\sum_{j=1}^{N}\hat\gamma_{jk}\,\mathbf 1\bigl(x_j^{(l)}=a_{ls}\bigr)}
{\sum_{j=1}^{N}\hat\gamma_{jk}}
\;}
$$

**加平滑**（防止 0 概率，同第 4 章）：

$$
P\bigl(x^{(l)}=a_{ls}\mid c_k\bigr)
=\frac{\sum_j\hat\gamma_{jk}\mathbf 1\bigl(x_j^{(l)}=a_{ls}\bigr)+\lambda}
{\sum_j\hat\gamma_{jk}+S_l\lambda}。
$$

**完整算法**

**输入**：无标签数据 $X=\{x_1,\ldots,x_N\}$，类别数 $K$，平滑系数 $\lambda$
**输出**：$\pi_k$ 和 $P(x^{(l)}\mid c_k)$

1. 随机初始化 $\pi_k^{(0)}$ 和 $\theta^{(0)}$（需打破对称，否则所有类完全相同）；
2. **E 步**：按上式计算所有 $\hat\gamma_{jk}$；
3. **M 步**：按上两式更新 $\pi_k$ 和 $\theta_{kls}$；
4. 重复直到对数似然收敛。

**与第 4 章的完整对照**（本题的核心洞察）：

| | **第 4 章（有监督）** | **本题（无监督，EM）** |
| --- | --- | --- |
| 标签 | 已知 $y_j$ | **隐变量** |
| 权重 | 硬指示 $\mathbf 1(y_j=c_k)\in\{0,1\}$ | **软责任** $\hat\gamma_{jk}\in[0,1]$ |
| 先验 | $\hat P(c_k)=\dfrac{\sum_j\mathbf 1(y_j=c_k)}{N}$ | $\hat\pi_k=\dfrac{\sum_j\hat\gamma_{jk}}{N}$ |
| 条件概率 | $\dfrac{\sum_j\mathbf 1(y_j=c_k)\mathbf 1(x_j^{(l)}=a)}{\sum_j\mathbf 1(y_j=c_k)}$ | $\dfrac{\sum_j\hat\gamma_{jk}\mathbf 1(x_j^{(l)}=a)}{\sum_j\hat\gamma_{jk}}$ |
| 求解 | **一次**计数即可 | **迭代**（因为 $\hat\gamma$ 依赖参数，参数又依赖 $\hat\gamma$） |

$$
\boxed{\;
\text{无监督版本 = 把硬计数换成软加权计数，再迭代}
\;}
$$

**为什么必须迭代？** 因为存在"鸡生蛋"问题：

```text
要算 γ_jk（软标签）  →  需要参数 θ
要算参数 θ          →  需要 γ_jk
```

EM 通过交替求解打破这个循环，并保证每轮似然不减。

**代码验证**：构造 80 个样本、3 个特征（各 3 个取值）、2 个真实簇的无标签数据：

| 项目 | 结果 |
| --- | --- |
| 初始 $\log L$ | $-269.570147$ |
| 收敛 $\log L$ | $-190.935661$（27 次迭代） |
| 学到的混合比例 | $(0.5231,0.4769)$（真实为 40:40） |
| **与真实簇的一致率** | **97.5%**（80 个样本仅错 2 个） |

在完全没有标签的情况下，EM 几乎完全恢复了两个簇。未达 100% 是因为两簇在取值 1 上有重叠，个别样本本来就模棱两可。

> **实际应用**：这个模型在文本聚类中很常用（把特征换成词，就是**混合多项分布模型**）。它也是**半监督学习**的基础——若部分样本有标签，只需把这些样本的 $\hat\gamma_{jk}$ 固定为真实标签的 one-hot 向量即可。

---

### 第 9 章一句话回顾

当模型含有隐变量时，对数似然呈 $\log\sum_Z$ 的形式而无法直接求解，EM 算法用 Jensen 不等式在当前参数处构造一个**相切的下界**（即 ELBO），把 $\log\sum$ 化为易于优化的 $\sum\log$，于是"极大化下界"就归结为"极大化 $Q$ 函数"——E 步求隐变量的后验期望、M 步求极大，两步交替恰好是在 $(q,\theta)$ 上对同一个 ELBO 做**坐标上升**，因而似然单调不减；其代价是只能保证收敛到稳定点，故对初值敏感（三硬币模型的"敏感"更源于**参数不可辨识**，而 GMM 还存在 $\sigma\to0$ 的**似然无上界**陷阱），而把 M 步的"求极大"放宽为"求增大"，就得到更灵活的 GEM/ECM 族算法。
