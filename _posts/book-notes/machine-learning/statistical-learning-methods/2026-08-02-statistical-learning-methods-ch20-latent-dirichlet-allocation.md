---
title: "《统计学习方法（第 2 版）》第 20 章：潜在狄利克雷分配"
date: 2026-08-01 02:20:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-ch20-latent-dirichlet-allocation
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
series_order: 21
related: [statistical-learning-methods-ch19-markov-chain-monte-carlo, statistical-learning-methods-ch21-pagerank]
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: "围绕「潜在狄利克雷分配」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
math: true
---

> 凡标注 **【补充】** 或 **【辨析】** 的内容为原书之外的推导、严格条件、数值实验或纠错说明。本文用 $\theta_m$ 表示文档 $m$ 的话题分布，用 $\phi_k$ 表示话题 $k$ 的词分布，用 $\alpha,\beta$ 表示两类 Dirichlet 超参数。

---

## 0. 本章解决什么问题

### 0.1 PLSA 已经有概率模型，为什么还需要 LDA

第 18 章 PLSA 用

$$
P(w\mid d)=\sum_{k=1}^{K}P(w\mid z_k)P(z_k\mid d)
$$

描述话题混合，但每篇训练文档的 $P(z\mid d)$ 都是独立待估参数：文档越多，参数越多；新文档没有生成机制；短文档的极大似然估计还容易走向 0 或 1。

LDA（latent Dirichlet allocation，潜在狄利克雷分配）的关键改动是：

> 不再把每篇文档的话题比例当成固定参数，而把它视为从 Dirichlet 先验随机生成的隐变量；话题的词分布也使用 Dirichlet 先验。

$$
\theta_m\sim\operatorname{Dir}(\alpha),
\qquad
\phi_k\sim\operatorname{Dir}(\beta).
$$

先验带来三件事：

1. **平滑**：未观察到的词或话题仍有非零概率；
2. **正则化**：伪计数抑制短文档过拟合；
3. **新文档生成机制**：新文档的话题比例也来自同一个 $\operatorname{Dir}(\alpha)$。

### 0.2 LDA 的核心困难

模型生成过程很简单：

$$
\theta_m\longrightarrow z_{mn}\longrightarrow w_{mn},
\qquad
\phi_{z_{mn}}\longrightarrow w_{mn}.
$$

但学习时只观察 $w_{mn}$，看不见每个位置的话题 $z_{mn}$、每篇文档的话题分布 $\theta_m$ 和每个话题的词分布 $\phi_k$。后验

$$
p(z,\theta,\phi\mid w,\alpha,\beta)
$$

需要对所有话题指派求和并对连续参数积分，组合规模约为 $K^{\sum_mN_m}$，不能精确枚举。

本章给出两条近似路线：

| 路线 | 做法 | 近似来源 | 优势 | 局限 |
| --- | --- | --- | --- | --- |
| 折叠 Gibbs | 积掉 $\theta,\phi$，对 $z$ 作 MCMC | 有限样本与混合误差 | 实现直观、渐近精确 | 迭代多、样本相关 |
| 变分 EM | 用平均场 $q$ 逼近后验 | 分布族限制 | 确定性、通常更快 | 系统近似偏差、局部最优 |

### 0.3 作者的完整思路

```text
多项/类别分布描述“从若干类别中选择”
        ↓ 概率向量本身未知
Dirichlet 分布描述“概率向量的不确定性”
        ↓ 与多项分布共轭
后验参数 = 先验伪计数 + 观测计数
        ↓ 分层生成模型
LDA：Dirichlet → 文档话题比例 → 位置话题 → 单词
        ↓ 后验不可精确计算
折叠 Gibbs：积掉概率向量，只抽话题指派
变分 EM：断开后验依赖，坐标上升最大化 ELBO
```

### 0.4 本章结构

```text
20.1 Dirichlet 分布
 ├─ 多项分布、Dirichlet 分布、Beta 特例
 └─ Dirichlet-多项共轭与伪计数
20.2 LDA 模型
 ├─ 基本想法与生成算法
 ├─ 图模型与可交换性
 └─ 联合、条件与边缘概率
20.3 折叠 Gibbs
 ├─ 积掉 theta、phi
 ├─ 推导单位置满条件分布
 └─ 后处理估计 theta、phi
20.4 变分 EM
 ├─ KL、ELBO 与平均场
 ├─ eta/gamma 坐标更新
 └─ phi/alpha 的 M 步
```

---

## 20.1 狄利克雷分布

### 20.1.1 分布定义

#### 1. 多项分布

进行 $n$ 次相互独立、类别概率不变的试验，每次结果属于 $K$ 类之一，第 $i$ 类概率为 $p_i$。令 $X_i$ 为第 $i$ 类出现次数，则

$$
X=(X_1,\ldots,X_K)\sim\operatorname{Mult}(n,p),
$$

其中

$$
p_i\ge0,
\qquad
\sum_{i=1}^{K}p_i=1,
\qquad
\sum_{i=1}^{K}n_i=n.
$$

概率质量函数为

$$
P(X_1=n_1,\ldots,X_K=n_K)
=\frac{n!}{\prod_{i=1}^{K}n_i!}
\prod_{i=1}^{K}p_i^{n_i}.
\qquad\mathrm{(20.1)}
$$

多项系数是产生同一计数向量的序列排列数；乘积是任一具体序列的概率。

当 $n=1$ 时，只有一个分量为 1，得到类别分布。LDA 每个位置只抽一个话题或单词，严格说使用的是类别分布；机器学习文献常沿用 `Multinomial` 称呼。

**假设边界**：给定 $p$ 后各次试验条件独立同分布。词袋 LDA 因而忽略词序。

#### 2. Dirichlet 分布

概率向量

$$
\theta=(\theta_1,\ldots,\theta_K)
$$

位于概率单纯形

$$
\Delta^{K-1}
=\left\{\theta:\theta_i\ge0,
\sum_i\theta_i=1\right\}.
$$

给定超参数

$$
\alpha=(\alpha_1,\ldots,\alpha_K),
\qquad \alpha_i>0,
$$

若密度为

$$
p(\theta\mid\alpha)
=\frac{1}{B(\alpha)}
\prod_{i=1}^{K}\theta_i^{\alpha_i-1},
\qquad \theta\in\Delta^{K-1},
\qquad\mathrm{(20.2)}
$$

则

$$
\theta\sim\operatorname{Dir}(\alpha).
$$

多元 Beta 函数为

$$
B(\alpha)
=\frac{\prod_{i=1}^{K}\Gamma(\alpha_i)}
{\Gamma(\alpha_0)},
\qquad
\alpha_0=\sum_{i=1}^{K}\alpha_i.
\qquad\mathrm{(20.3)}
$$

所以也可写成

$$
p(\theta\mid\alpha)
=\frac{\Gamma(\alpha_0)}
{\prod_i\Gamma(\alpha_i)}
\prod_i\theta_i^{\alpha_i-1}.
\qquad\mathrm{(20.4)}
$$

Gamma 函数定义为

$$
\Gamma(s)=\int_0^\infty x^{s-1}e^{-x}dx,
\qquad s>0,
$$

并满足

$$
\Gamma(s+1)=s\Gamma(s),
\qquad
\Gamma(n+1)=n!.
$$

#### 3. 规范化常数为什么是 $B(\alpha)$

由多元 Beta 积分：

$$
B(\alpha)
=\int_{\Delta^{K-1}}
\prod_{i=1}^{K}\theta_i^{\alpha_i-1}d\theta.
\qquad\mathrm{(20.5)}
$$

可用独立 Gamma 变量证明。令

$$
Y_i\sim\operatorname{Gamma}(\alpha_i,1),
\quad
S=\sum_iY_i,
\quad
\theta_i=Y_i/S.
$$

变量变换 $Y_i=S\theta_i$ 的 Jacobian 为 $S^{K-1}$。联合密度中 $S$ 的幂为

$$
S^{\sum_i(\alpha_i-1)}S^{K-1}=S^{\alpha_0-1}.
$$

于是联合密度分解为

$$
\left[\frac{S^{\alpha_0-1}e^{-S}}{\Gamma(\alpha_0)}\right]
\left[\frac{\Gamma(\alpha_0)}{\prod_i\Gamma(\alpha_i)}
\prod_i\theta_i^{\alpha_i-1}\right].
$$

第一括号是 $S\sim\operatorname{Gamma}(\alpha_0,1)$，第二括号必须是归一化的 $\theta$ 密度，于是得到式 (20.3)–(20.5)。这也给出 Dirichlet 的直接采样法。

#### 4. 参数的直觉

写成

$$
\alpha_i=\alpha_0m_i,
\qquad \sum_i m_i=1.
$$

- $m_i$ 决定分布中心；
- $\alpha_0$ 是总浓度，控制围绕中心的集中程度。

其矩为【补充】：

$$
E[\theta_i]=\frac{\alpha_i}{\alpha_0},
$$

$$
\operatorname{Var}(\theta_i)
=\frac{\alpha_i(\alpha_0-\alpha_i)}
{\alpha_0^2(\alpha_0+1)},
$$

$$
\operatorname{Cov}(\theta_i,\theta_j)
=-\frac{\alpha_i\alpha_j}
{\alpha_0^2(\alpha_0+1)},
\quad i\ne j.
$$

负协方差来自总和必须为 1：一个分量上升会挤压其他分量。

对称先验 $\alpha_i=a$ 时：

- $a<1$：质量靠近单纯形边角，鼓励稀疏混合；
- $a=1$：单纯形上均匀；
- $a>1$：质量偏向内部和均匀比例。

这不是“$a$ 越小概率越小”，而是概率向量更倾向由少数分量主导。

#### 5. 二项/Beta 特例

$K=2$ 时令 $\theta_1=x,\theta_2=1-x$，Dirichlet 退化为 Beta：

$$
p(x)
=\frac{x^{s-1}(1-x)^{t-1}}{B(s,t)},
\quad0\le x\le1.
\qquad\mathrm{(20.7)}
$$

其中

$$
B(s,t)=\int_0^1x^{s-1}(1-x)^{t-1}dx
=\frac{\Gamma(s)\Gamma(t)}{\Gamma(s+t)}.
\qquad\mathrm{(20.8)}
$$

若 $s,t$ 为正整数：

$$
B(s,t)=\frac{(s-1)!(t-1)!}{(s+t-1)!}.
\qquad\mathrm{(20.9)}
$$

多项分布相应退化为二项分布

$$
P(X=m)=\binom nm p^m(1-p)^{n-m}.
\qquad\mathrm{(20.6)}
$$

$n=1$ 时又得到 Bernoulli 分布。

### 20.1.2 共轭先验

#### 1. 为什么需要共轭

贝叶斯更新为

$$
p(\theta\mid D)
\propto p(D\mid\theta)p(\theta).
$$

若先验与后验属于同一分布族，更新只需修改有限个超参数，不必每次重新求复杂积分，这就是共轭。

#### 2. Dirichlet-多项共轭推导

观测计数为

$$
n=(n_1,\ldots,n_K),
\quad n_0=\sum_i n_i.
$$

忽略与 $\theta$ 无关的多项系数，似然核为

$$
p(D\mid\theta)
\propto\prod_{i=1}^{K}\theta_i^{n_i}.
\qquad\mathrm{(20.10)}
$$

先验为

$$
p(\theta\mid\alpha)
=\frac1{B(\alpha)}
\prod_i\theta_i^{\alpha_i-1}.
\qquad\mathrm{(20.11)}
$$

相乘：

$$
\begin{aligned}
p(\theta\mid D,\alpha)
&\propto
\prod_i\theta_i^{n_i}
\prod_i\theta_i^{\alpha_i-1}\\
&=\prod_i\theta_i^{\alpha_i+n_i-1}.
\end{aligned}
$$

这正是 Dirichlet 核，规范化后

$$
\boxed{
\theta\mid D,\alpha
\sim\operatorname{Dir}(\alpha+n)
}.
\qquad\mathrm{(20.12)}
$$

所以 $\alpha_i$ 可解释为第 $i$ 类的先验伪计数。

#### 3. 后验预测

下一次观察为类别 $i$ 的概率为

$$
\begin{aligned}
P(X_{n+1}=i\mid D)
&=\int\theta_i p(\theta\mid D)d\theta\\
&=E[\theta_i\mid D]\\
&=\frac{n_i+\alpha_i}{n_0+\alpha_0}.
\end{aligned}
$$

这条“计数加伪计数再归一化”的公式就是折叠 Gibbs 更新的核心。

#### 4. 期望公式完整推导

记 $e_i$ 为第 $i$ 个单位向量：

$$
\begin{aligned}
E[\theta_i]
&=\frac1{B(\alpha)}
\int_{\Delta}\theta_i
\prod_j\theta_j^{\alpha_j-1}d\theta\\
&=\frac{B(\alpha+e_i)}{B(\alpha)}\\
&=\frac{\Gamma(\alpha_i+1)}{\Gamma(\alpha_i)}
\frac{\Gamma(\alpha_0)}{\Gamma(\alpha_0+1)}\\
&=\frac{\alpha_i}{\alpha_0}.
\end{aligned}
$$

第三步中除第 $i$ 个和总和 Gamma 项外其余全部抵消，第四步使用 $\Gamma(s+1)=s\Gamma(s)$。

---

## 20.2 潜在狄利克雷分配模型

### 20.2.1 基本想法

LDA 是文本集合的分层贝叶斯生成模型：

- 每个话题是词汇上的类别分布；
- 每篇文档是话题上的类别分布；
- 两类概率向量各有 Dirichlet 先验；
- 每个词元先选择话题，再由话题选择单词。

LDA 与 PLSA 都使用

$$
P(w=v\mid d=m)
=\sum_{k=1}^{K}\theta_{mk}\phi_{kv},
$$

但参数解释不同：

| 项目 | PLSA | LDA |
| --- | --- | --- |
| 文档话题比例 | 每篇文档的固定参数 | $\theta_m\sim\operatorname{Dir}(\alpha)$ |
| 话题词比例 | 固定参数 | 完整模型中 $\phi_k\sim\operatorname{Dir}(\beta)$ |
| 学习 | 极大似然 EM | 后验推断 |
| 新文档 | folding-in | 从同一先验生成和推断 |
| 正则化 | 无显式先验 | 伪计数平滑 |

**【辨析】** “PLSA 等价于均匀先验 LDA”并不严格。即使 Dirichlet 参数全为 1，LDA 仍对 $\theta_m$ 积分或作后验推断，而 PLSA 把它当点参数极大化；两种边缘似然和复杂度惩罚不同。

### 20.2.2 模型定义

#### 1. 模型要素

| 符号 | 维度或范围 | 含义 |
| --- | --- | --- |
| $V$ | 正整数 | 词汇量 |
| $M$ | 正整数 | 文档数 |
| $K$ | 正整数 | 话题数，预先给定 |
| $N_m$ | 正整数 | 文档 $m$ 的词元数 |
| $w_{mn}$ | $\{1,\ldots,V\}$ | 文档 $m$ 位置 $n$ 的观测词 |
| $z_{mn}$ | $\{1,\ldots,K\}$ | 该位置的隐话题 |
| $\theta_m$ | $\Delta^{K-1}$ | 文档 $m$ 的话题比例 |
| $\phi_k$ | $\Delta^{V-1}$ | 话题 $k$ 的词比例 |
| $\alpha$ | $\mathbb R_+^K$ | 文档话题 Dirichlet 超参数 |
| $\beta$ | $\mathbb R_+^V$ | 话题词 Dirichlet 超参数 |

概率定义：

$$
	heta_m\sim\operatorname{Dir}(\alpha),
\qquad
P(z_{mn}=k\mid\theta_m)=\theta_{mk},
$$

$$
\phi_k\sim\operatorname{Dir}(\beta),
\qquad
P(w_{mn}=v\mid z_{mn}=k,\phi)=\phi_{kv}.
$$

#### 2. 生成过程（算法 20.1）

给定 $K,V,M,N_m,\alpha,\beta$：

1. 对每个话题 $k=1,\ldots,K$：
        $$
        \phi_k\sim\operatorname{Dir}(\beta).
        $$
2. 对每篇文档 $m=1,\ldots,M$：
        $$
        \theta_m\sim\operatorname{Dir}(\alpha).
        $$
3. 对文档 $m$ 的每个位置 $n=1,\ldots,N_m$：
        - 抽话题
          $$
          z_{mn}\sim\operatorname{Cat}(\theta_m);
          $$
        - 抽单词
          $$
          w_{mn}\sim\operatorname{Cat}(\phi_{z_{mn}}).
          $$

$N_m$ 在本章模型中视为给定；完整文档生成模型还需为长度指定分布。

#### 3. 超参数如何影响话题

- 小而对称的 $\alpha$ 鼓励每篇文档只使用少数话题；
- 大 $\alpha$ 鼓励文档混合多个话题；
- 小 $\beta$ 鼓励每个话题集中于少数词；
- 大 $\beta$ 使话题词分布更平坦。

原书说无先验知识可令所有分量为 1，这是合法默认值，但不一定适合稀疏文本。超参数影响很大，应通过经验贝叶斯、验证集或层次先验选择。

### 20.2.3 概率图模型

板块图中的依赖关系为：

```text
beta → phi_k ──────┐
                                                 ↓
alpha → theta_m → z_mn → w_mn
```

- $\alpha,\beta$：给定超参数；
- $\theta_m,\phi_k,z_{mn}$：隐变量；
- $w_{mn}$：观测变量；
- $k$ 板块重复 $K$ 次，文档板块重复 $M$ 次，位置板块在文档内重复 $N_m$ 次。

关键条件独立关系：

$$
z_{mn}\perp z_{mn'}\mid\theta_m,
$$

$$
w_{mn}\perp(\theta_m,w_{-mn})\mid z_{mn},\phi.
$$

边缘化 $\theta,\phi$ 后，原本条件独立的位置会因共享随机概率向量而相关。这正是分层贝叶斯模型表达“同文档词元倾向共享话题、同话题词元倾向共享词汇”的方式。

### 20.2.4 随机变量序列的可交换性

有限序列 $X_1,\ldots,X_N$ 可交换，若对任意排列 $\pi$：

$$
P(X_1,\ldots,X_N)
=P(X_{\pi(1)},\ldots,X_{\pi(N)}).
\qquad\mathrm{(20.13)}
$$

无限序列若每个有限子序列都可交换，则称无限可交换。iid 必然无限可交换，反之边缘上不一定独立。

De Finetti 定理说明：在相应正则条件下，无限可交换分布可表示为条件 iid 分布的混合：

$$
P(X_1,X_2,\ldots\mid Y)
=\prod_iP(X_i\mid Y).
\qquad\mathrm{(20.14)}
$$

在 LDA 中，给定 $\theta_m$ 后，文档内话题 $z_{mn}$ 条件 iid；积分掉 $\theta_m$ 后它们不独立，但可交换。给定 $\theta_m,\phi$ 后，固定长度文档中的词元也条件 iid，所以词袋似然不依赖位置排列。

**适用边界**：自然语言词序显然包含语义，LDA 的可交换性是有意简化，不是语言事实。短语、语法和上下文需 n-gram、HMM、神经主题模型或 Transformer 等替代。

### 20.2.5 概率公式

#### 1. 完整联合分布

由图模型分解：

$$
\boxed{
p(w,z,\theta,\phi\mid\alpha,\beta)
=\prod_{k=1}^{K}p(\phi_k\mid\beta)
\prod_{m=1}^{M}
\left[
p(\theta_m\mid\alpha)
\prod_{n=1}^{N_m}
p(z_{mn}\mid\theta_m)
p(w_{mn}\mid z_{mn},\phi)
\right]
}.
\qquad\mathrm{(20.15)}
$$

单文档对应式 (20.16)，但 $\phi$ 是全语料共享变量，不应误解为每篇文档重新生成一套话题。

逐元素形式：

$$
p(z_{mn}=k\mid\theta_m)=\theta_{mk},
$$

$$
p(w_{mn}=v\mid z_{mn}=k,\phi)=\phi_{kv}.
$$

#### 2. 给定参数时的文档概率

边缘化单个位置的话题：

$$
P(w_{mn}=v\mid\theta_m,\phi)
=\sum_{k=1}^{K}\theta_{mk}\phi_{kv}.
$$

位置条件独立，所以

$$
p(w_m\mid\theta_m,\phi)
=\prod_{n=1}^{N_m}
\sum_{k=1}^{K}\theta_{mk}\phi_{k,w_{mn}}.
\qquad\mathrm{(20.17)}
$$

#### 3. 边缘似然

若话题词参数 $\phi$ 固定，积分文档话题比例：

$$
p(w_m\mid\alpha,\phi)
=\int p(\theta_m\mid\alpha)
\prod_{n=1}^{N_m}
\sum_k\theta_{mk}\phi_{k,w_{mn}}
d\theta_m.
\qquad\mathrm{(20.18)}
$$

完整贝叶斯 LDA 还要对共享的 $\phi$ 积分，并对 $z$ 求和：

$$
p(w\mid\alpha,\beta)
=\sum_z\int\int
p(w,z,\theta,\phi\mid\alpha,\beta)
d\theta\,d\phi.
\qquad\mathrm{(20.19)}
$$

求和规模指数增长，积分变量又高维，这就是必须使用 Gibbs 或变分推理的根本原因。

---

## 20.3 LDA 的吉布斯抽样算法

### 20.3.1 基本想法

给定观测词序列 $w$ 和超参数 $\alpha,\beta$，完整后验为

$$
p(z,\theta,\phi\mid w,\alpha,\beta).
$$

直接对 $z,\theta,\phi$ 做整体 Gibbs 可以，但维度高、变量相关强。由于 Dirichlet 与类别分布共轭，可解析积分掉 $\theta,\phi$，只对离散话题指派抽样：

$$
p(z\mid w,\alpha,\beta)
\propto p(w,z\mid\alpha,\beta).
\qquad\mathrm{(20.20)}
$$

这称为**折叠 Gibbs 抽样**。降低维数相当于 Rao-Blackwell 化，通常比显式抽取概率向量混合更好。

### 20.3.2 算法的主要部分

#### 1. 计数记号

令总词元数为 $I=\sum_mN_m$，定义：

| 记号 | 含义 |
| --- | --- |
| $n_{kv}$ | 话题 $k$ 分配给词 $v$ 的词元数 |
| $n_{k\cdot}=\sum_vn_{kv}$ | 分配给话题 $k$ 的总词元数 |
| $n_{mk}$ | 文档 $m$ 中分配给话题 $k$ 的词元数 |
| $n_{m\cdot}=\sum_kn_{mk}=N_m$ | 文档 $m$ 的长度 |
| 上标 $^{-i}$ | 移除当前词元 $i=(m,n)$ 后的计数 |
| $\alpha_0=\sum_k\alpha_k$ | 文档话题先验总浓度 |
| $\beta_0=\sum_v\beta_v$ | 话题词先验总浓度 |

#### 2. 积掉话题词分布 $\phi$

给定话题指派 $z$，词似然为

$$
p(w\mid z,\phi)
=\prod_{k=1}^{K}\prod_{v=1}^{V}
\phi_{kv}^{n_{kv}}.
\qquad\mathrm{(20.22)}
$$

每个话题先验为

$$
p(\phi_k\mid\beta)
=\frac1{B(\beta)}
\prod_v\phi_{kv}^{\beta_v-1}.
$$

逐话题积分：

$$
\begin{aligned}
p(w\mid z,\beta)
&=\prod_{k=1}^{K}
\int p(w\mid z,\phi_k)p(\phi_k\mid\beta)d\phi_k\\
&=\prod_{k=1}^{K}
\frac1{B(\beta)}
\int_{\Delta^{V-1}}
\prod_v\phi_{kv}^{n_{kv}+\beta_v-1}d\phi_k\\
&=\prod_{k=1}^{K}
\frac{B(n_k+\beta)}{B(\beta)}.
\end{aligned}
\qquad\mathrm{(20.23)}
$$

最后一步直接使用多元 Beta 积分式 (20.5)。

#### 3. 积掉文档话题分布 $\theta$

给定 $\theta$ 时：

$$
p(z\mid\theta)
=\prod_{m=1}^{M}\prod_{k=1}^{K}
	heta_{mk}^{n_{mk}}.
\qquad\mathrm{(20.24)}
$$

同理：

$$
\begin{aligned}
p(z\mid\alpha)
&=\prod_{m=1}^{M}
\int p(z_m\mid\theta_m)p(\theta_m\mid\alpha)d\theta_m\\
&=\prod_{m=1}^{M}
\frac{B(n_m+\alpha)}{B(\alpha)}.
\end{aligned}
\qquad\mathrm{(20.25)}
$$

由于给定 $z$ 后 $w$ 与 $\alpha$ 无关、$z$ 与 $\beta$ 无关：

$$
p(w,z\mid\alpha,\beta)
=p(w\mid z,\beta)p(z\mid\alpha),
\qquad\mathrm{(20.21)}
$$

故折叠联合分布为

$$
\boxed{
p(w,z\mid\alpha,\beta)
=\prod_{k=1}^{K}\frac{B(n_k+\beta)}{B(\beta)}
\prod_{m=1}^{M}\frac{B(n_m+\alpha)}{B(\alpha)}
}.
\qquad\mathrm{(20.26)}
$$

于是

$$
p(z\mid w,\alpha,\beta)
\propto
\prod_k\frac{B(n_k+\beta)}{B(\beta)}
\prod_m\frac{B(n_m+\alpha)}{B(\alpha)}.
\qquad\mathrm{(20.27)}
$$

#### 4. 单位置满条件分布

考虑当前词元 $i=(m,n)$，观测词为 $w_i=v$。固定其他话题 $z_{-i}$，候选 $z_i=k$ 的条件概率为

$$
p(z_i=k\mid z_{-i},w,\alpha,\beta)
\propto p(z_i=k,z_{-i},w\mid\alpha,\beta).
\qquad\mathrm{(20.28)}
$$

式 (20.26) 中只有话题 $k$ 的词计数和文档 $m$ 的话题计数改变。利用

$$
\frac{B(a+e_j)}{B(a)}
=\frac{a_j}{\sum_la_l},
$$

得到话题词因子：

$$
\frac{B(n_k^{-i}+\beta+e_v)}
{B(n_k^{-i}+\beta)}
=\frac{n_{kv}^{-i}+\beta_v}
{n_{k\cdot}^{-i}+\beta_0}.
$$

文档话题因子：

$$
\frac{B(n_m^{-i}+\alpha+e_k)}
{B(n_m^{-i}+\alpha)}
=\frac{n_{mk}^{-i}+\alpha_k}
{N_m-1+\alpha_0}.
$$

相乘即得

$$
\boxed{
p(z_i=k\mid z_{-i},w,\alpha,\beta)
\propto
\frac{n_{kv}^{-i}+\beta_v}
{n_{k\cdot}^{-i}+\beta_0}
\frac{n_{mk}^{-i}+\alpha_k}
{N_m-1+\alpha_0}
}.
\qquad\mathrm{(20.29)}
$$

- 第一因子是“话题 $k$ 生成词 $v$”的后验预测概率；
- 第二因子是“文档 $m$ 使用话题 $k$”的后验预测概率。

第二因子的分母对所有候选 $k$ 相同，归一化抽样时可省略；保留它更清楚地显示概率意义。

**为什么必须先减 1**：当前词元的话题未知，计算其条件分布时必须从计数中移除旧指派。否则会让旧话题凭借当前词元给自己加分，破坏正确的 Gibbs 转移核。

### 20.3.3 算法的后处理

#### 1. 文档话题分布

由共轭性：

$$
	heta_m\mid z_m,\alpha
\sim\operatorname{Dir}(n_m+\alpha).
\qquad\mathrm{(20.30)}
$$

后验均值为

$$
\boxed{
\widehat\theta_{mk}
=E[\theta_{mk}\mid z]
=\frac{n_{mk}+\alpha_k}
{N_m+\alpha_0}
}.
\qquad\mathrm{(20.31)}
$$

#### 2. 话题词分布

同理：

$$
\phi_k\mid w,z,\beta
\sim\operatorname{Dir}(n_k+\beta),
\qquad\mathrm{(20.32)}
$$

$$
\boxed{
\widehat\phi_{kv}
=E[\phi_{kv}\mid w,z]
=\frac{n_{kv}+\beta_v}
{n_{k\cdot}+\beta_0}
}.
\qquad\mathrm{(20.33)}
$$

**【辨析】** 式 (20.31)、(20.33) 是后验均值，不是 MAP。若所有后验参数大于 1，Dirichlet MAP 为

$$
\frac{n_i+\alpha_i-1}
{n_0+\alpha_0-K}.
$$

参数小于等于 1 时众数可能落在边界，不能机械使用该式。

若保留多个燃烧期后样本，最好对每个样本的后验均值再平均，而不是只用最后一次话题指派，以降低蒙特卡罗方差。

### 20.3.4 算法 20.2

**输入**：文档词元序列 $w$，话题数 $K$，超参数 $\alpha,\beta$。

**输出**：后验话题样本及 $\theta,\phi$ 估计。

1. 初始化所有 $n_{mk},n_{kv},n_{k\cdot}$ 为 0；
2. 为每个词元随机指派话题，并增加相应计数；
3. 重复若干扫描：
        1. 对每个词元 $i=(m,n)$，记词为 $v$、旧话题为 $k_{old}$；
        2. 从 $n_{mk_{old}},n_{k_{old}v},n_{k_{old}\cdot}$ 各减 1；
        3. 对每个候选 $k$ 按式 (20.29) 计算权重并归一化；
        4. 从该类别分布抽新话题 $k_{new}$；
        5. 对新话题对应的三个计数各加 1；
4. 丢弃燃烧期，收集后验样本；
5. 用式 (20.31)、(20.33) 后处理。

#### 复杂度与边界【补充】

令总词元数 $I=\sum_mN_m$。朴素实现每个词元计算 $K$ 个权重：

$$
	ext{每次扫描时间}=O(IK).
$$

计数存储为

$$
O(MK+KV+I),
$$

其中 $I$ 用于保存每个词元的话题。大词表下 $n_{kv}$ 可稀疏存储，Alias、稀疏分解等方法可降低实际抽样成本。

Gibbs 的目标后验通常多峰且有标签置换对称：任意重排话题编号不改变模型。小语料尤其可能受初始化影响；应运行多条链，检查话题稳定性和后验预测，而不只看某一次最终计数。

---

## 20.4 LDA 的变分 EM 算法

### 20.4.1 变分推理

#### 1. 从后验近似到 ELBO

设 $x$ 是观测变量，$z$ 包含全部隐变量，目标后验为

$$
p(z\mid x)=\frac{p(x,z)}{p(x)}.
$$

直接计算 $p(x)=\int p(x,z)dz$ 困难。选择一个易计算的变分分布 $q(z)$，希望最小化

$$
D_{\mathrm{KL}}(q(z)\Vert p(z\mid x)).
$$

展开：

$$
\begin{aligned}
D_{\mathrm{KL}}(q\Vert p)
&=E_q[\log q(z)]-E_q[\log p(z\mid x)]\\
&=E_q[\log q(z)]-E_q[\log p(x,z)]+\log p(x)\\
&=\log p(x)-\mathcal L(q),
\end{aligned}
\qquad\mathrm{(20.35)}
$$

其中

$$
\boxed{
\mathcal L(q)
=E_q[\log p(x,z)]-E_q[\log q(z)]
}
\qquad\mathrm{(20.37)}
$$

称为证据下界（ELBO）。由于 KL 散度非负：

$$
\log p(x)\ge\mathcal L(q).
\qquad\mathrm{(20.36)}
$$

且

$$
\log p(x)-\mathcal L(q)
=D_{\mathrm{KL}}(q\Vert p(z\mid x)).
$$

因此在固定模型时，最大化 ELBO 等价于在所选分布族中最小化反向 KL。

#### 2. 平均场假设

常限制

$$
q(z)=\prod_{j=1}^{J}q_j(z_j).
\qquad\mathrm{(20.38)}
$$

这称为平均场。它人为切断后验依赖，使期望和坐标更新可计算。

对任意一个因子，固定其他因子后，变分法给出通用更新：

$$
\boxed{
\log q_j^*(z_j)
=E_{q_{-j}}[\log p(x,z)]+\text{常数}
}.
$$

证明：只保留 ELBO 中与 $q_j$ 有关部分，并加约束 $\int q_j=1$：

$$
\int q_j(z_j)E_{q_{-j}}[\log p(x,z)]dz_j
-\int q_j(z_j)\log q_j(z_j)dz_j
{}+\lambda\left(\int q_jdz_j-1\right).
$$

对 $q_j$ 作泛函求导并令零，即得上述指数族形式。

**适用边界**：若真实后验强相关或多峰，乘积分布无法准确表达。反向 KL 常偏向覆盖一个高密度模式并低估方差；变分推理速度快，但不是渐近精确抽样。

### 20.4.2 变分 EM 算法

设模型为 $p(x,z\mid\vartheta)$，$\vartheta$ 是待估点参数。定义

$$
\mathcal L(q,\vartheta)
=E_q[\log p(x,z\mid\vartheta)]
-E_q[\log q(z)].
\qquad\mathrm{(20.39)}
$$

并有

$$
\log p(x\mid\vartheta)-\mathcal L(q,\vartheta)
=D_{\mathrm{KL}}(q(z)\Vert p(z\mid x,\vartheta))\ge0.
\qquad\mathrm{(20.40)}
$$

算法 20.3 交替：

1. **变分 E 步**：固定 $\vartheta$，在变分族内最大化 $\mathcal L$；
2. **M 步**：固定 $q$，关于 $\vartheta$ 最大化 $\mathcal L$。

所以

$$
\mathcal L(q^{(t)},\vartheta^{(t-1)})
\ge\mathcal L(q^{(t-1)},\vartheta^{(t-1)}),
$$

$$
\mathcal L(q^{(t)},\vartheta^{(t)})
\ge\mathcal L(q^{(t)},\vartheta^{(t-1)}).
$$

ELBO 每轮不减。

**【辨析式 (20.41)】** 原书写

$$
\log p(x\mid\vartheta^{(t-1)})
=\mathcal L(q^{(t)},\vartheta^{(t-1)}).
\qquad\mathrm{(20.41)}
$$

该等号只在 E 步能取到精确后验
$q^{(t)}=p(z\mid x,\vartheta^{(t-1)})$ 时成立，即普通 EM 的情形。平均场通常无法表示精确后验，故变分 EM 一般保证 **ELBO 单调不减**，不能仅由这条链式不等式断言每轮真实证据都不减。若 ELBO 有上界，其数值收敛；参数通常只收敛到局部驻点，且还需每个坐标子问题被充分优化。

### 20.4.3 算法推导

原书本节使用简化 LDA：只考虑一篇文档，话题词分布

$$
\Phi=(\phi_{kv})_{K\times V}
$$

作为待估模型参数，不再给 $\phi_k$ 配置 $\operatorname{Dir}(\beta)$。隐变量为 $\theta,z$。

#### 1. 联合分布与变分分布

一篇长度为 $N$ 的文档 $w=(w_1,\ldots,w_N)$：

$$
p(\theta,z,w\mid\alpha,\Phi)
=p(\theta\mid\alpha)
\prod_{n=1}^{N}p(z_n\mid\theta)p(w_n\mid z_n,\Phi).
\qquad\mathrm{(20.42)}
$$

平均场取

$$
q(\theta,z\mid\gamma,\eta)
=q(\theta\mid\gamma)
\prod_{n=1}^{N}q(z_n\mid\eta_n),
\qquad\mathrm{(20.43)}
$$

其中

$$
q(\theta\mid\gamma)=\operatorname{Dir}(\gamma),
$$

$$
q(z_n=k\mid\eta_n)=\eta_{nk},
\quad \sum_k\eta_{nk}=1.
$$

$\gamma$、$\eta$ 是每篇文档自己的变分参数；$\alpha$、$\Phi$ 是全语料共享模型参数。

单文档 ELBO：

$$
\mathcal L(\gamma,\eta;\alpha,\Phi)
=E_q[\log p(\theta,z,w\mid\alpha,\Phi)]
-E_q[\log q(\theta,z\mid\gamma,\eta)].
\qquad\mathrm{(20.44)}
$$

全语料为各文档 ELBO 之和：

$$
\mathcal L_W
=\sum_{m=1}^{M}\mathcal L_m.
\qquad\mathrm{(20.45)}
$$

#### 2. ELBO 的五项展开

由联合和平均场分解：

$$
\begin{aligned}
\mathcal L={}&E_q[\log p(\theta\mid\alpha)]+E_q[\log p(z\mid\theta)]\\
&+E_q[\log p(w\mid z,\Phi)]-E_q[\log q(\theta\mid\gamma)]\\
&-E_q[\log q(z\mid\eta)].
\end{aligned}
\qquad\mathrm{(20.46)}
$$

定义 digamma 函数

$$
\psi(x)=\frac{d}{dx}\log\Gamma(x),
\qquad\mathrm{(20.48)}
$$

并记

$$
\gamma_0=\sum_k\gamma_k,
\qquad
E_q[\log\theta_k]
=\psi(\gamma_k)-\psi(\gamma_0).
\qquad\mathrm{(20.50)}
$$

五项分别为：

$$
\begin{aligned}
E_q[\log p(\theta\mid\alpha)]
={}&\log\Gamma(\alpha_0)-\sum_k\log\Gamma(\alpha_k)\\
&+\sum_k(\alpha_k-1)
[\psi(\gamma_k)-\psi(\gamma_0)],
\end{aligned}
\qquad\mathrm{(20.51)}
$$

$$
E_q[\log p(z\mid\theta)]
=\sum_{n=1}^{N}\sum_{k=1}^{K}
\eta_{nk}[\psi(\gamma_k)-\psi(\gamma_0)],
\qquad\mathrm{(20.52)}
$$

$$
E_q[\log p(w\mid z,\Phi)]
=\sum_{n=1}^{N}\sum_{k=1}^{K}
\eta_{nk}\log\phi_{k,w_n},
\qquad\mathrm{(20.53)}
$$

$$
\begin{aligned}
E_q[\log q(\theta\mid\gamma)]
={}&\log\Gamma(\gamma_0)-\sum_k\log\Gamma(\gamma_k)\\
&+\sum_k(\gamma_k-1)
[\psi(\gamma_k)-\psi(\gamma_0)],
\end{aligned}
\qquad\mathrm{(20.54)}
$$

$$
E_q[\log q(z\mid\eta)]
=\sum_{n=1}^{N}\sum_{k=1}^{K}
\eta_{nk}\log\eta_{nk}.
\qquad\mathrm{(20.55)}
$$

把五项按式 (20.46) 的正负号组合，就是原书式 (20.47)。

#### 3. 更新位置话题参数 $\eta$

固定 $\gamma$，与某个 $\eta_n$ 有关的部分是

$$
\sum_k\eta_{nk}
\left[
\psi(\gamma_k)-\psi(\gamma_0)+\log\phi_{k,w_n}
-\log\eta_{nk}
\right].
$$

加入约束 $\sum_k\eta_{nk}=1$ 的乘子 $\lambda_n$，拉格朗日函数对应式 (20.56)。偏导为

$$
\psi(\gamma_k)-\psi(\gamma_0)+\log\phi_{k,w_n}
-\log\eta_{nk}-1+\lambda_n.
\qquad\mathrm{(20.57)}
$$

令其为 0 并归一化：

$$
\boxed{
\eta_{nk}
\propto
\phi_{k,w_n}
\exp\{\psi(\gamma_k)-\psi(\gamma_0)\}
}.
\qquad\mathrm{(20.58)}
$$

第一因子衡量话题生成该词的能力，指数因子是文档使用该话题的变分期望权重。

#### 4. 更新文档 Dirichlet 参数 $\gamma$

使用平均场通用公式：

$$
\begin{aligned}
\log q^*(\theta)
&=E_{q(z)}[\log p(\theta,z,w\mid\alpha,\Phi)]+C\\
&=\sum_k\left(\alpha_k-1+\sum_n\eta_{nk}\right)
\log\theta_k+C.
\end{aligned}
$$

这是 Dirichlet 核，因此

$$
\boxed{
\gamma_k=\alpha_k+\sum_{n=1}^{N}\eta_{nk}
}.
\qquad\mathrm{(20.62)}
$$

这也可通过对原书式 (20.59)–(20.61) 求导得到。它仍是“先验伪计数 + 期望计数”。

#### 5. 算法 20.4：单文档变分 E 步

1. 初始化 $\eta_{nk}=1/K$；
2. 初始化 $\gamma_k=\alpha_k+N/K$；
3. 重复直到文档 ELBO 或参数收敛：
        - 对每个位置按式 (20.58) 更新 $\eta_n$；
        - 按式 (20.62) 更新 $\gamma$。

实现时用 log-sum-exp 归一化式 (20.58)，防止 $\phi$ 很小时下溢。

#### 6. M 步更新话题词参数 $\Phi$

全语料中与 $\Phi$ 有关的 ELBO 为

$$
\sum_{m=1}^{M}\sum_{n=1}^{N_m}
\sum_{k=1}^{K}\sum_{v=1}^{V}
\eta_{mnk}\mathbf1(w_{mn}=v)\log\phi_{kv}.
$$

对每个 $k$ 加约束 $\sum_v\phi_{kv}=1$，对应原书拉格朗日式 (20.63)。求导并归一化：

$$
\boxed{
\phi_{kv}
=\frac{
\sum_m\sum_n\eta_{mnk}\mathbf1(w_{mn}=v)
}{
\sum_m\sum_n\eta_{mnk}
}
}.
\qquad\mathrm{(20.64)}
$$

即用变分话题责任度形成期望计数。

**边界**：若某话题期望总计数为 0，分母为 0。工程上可保留旧参数、重新初始化，或加入 Dirichlet 平滑；原书简化模型的纯极大似然更新没有 $\beta$ 平滑。

#### 7. M 步更新超参数 $\alpha$

固定各文档变分参数 $\gamma_m$，与 $\alpha$ 有关的目标为

$$
\begin{aligned}
\mathcal L(\alpha)
={}&M\left[\log\Gamma(\alpha_0)
-\sum_k\log\Gamma(\alpha_k)\right]\\
&+\sum_{m=1}^{M}\sum_{k=1}^{K}
(\alpha_k-1)
[\psi(\gamma_{mk})-\psi(\gamma_{m0})].
\end{aligned}
\qquad\mathrm{(20.65)}
$$

梯度为

$$
g_k
=M[\psi(\alpha_0)-\psi(\alpha_k)]+\sum_{m=1}^{M}
[\psi(\gamma_{mk})-\psi(\gamma_{m0})].
\qquad\mathrm{(20.66)}
$$

令 trigamma 函数 $\psi_1(x)=\psi'(x)$，Hessian 为

$$
H_{kl}
=M\psi_1(\alpha_0)
-\mathbf1(k=l)M\psi_1(\alpha_k).
\qquad\mathrm{(20.67)}
$$

Newton 更新：

$$
\alpha^{new}
=\alpha^{old}-H(\alpha^{old})^{-1}g(\alpha^{old}).
\qquad\mathrm{(20.68)}
$$

必须用阻尼或线搜索保持 $\alpha_k>0$ 并确保 ELBO 不下降；无约束 Newton 可能跨出参数域。

### 20.4.4 算法总结（算法 20.5）

**输入**：语料 $D$、话题数 $K$、初始 $\alpha,\Phi$。

重复直到全语料 ELBO 收敛：

1. **E 步**：固定 $\alpha,\Phi$，对每篇文档运行算法 20.4，得到 $\gamma_m,\eta_m$；
2. **M 步**：固定变分参数：
        - 用式 (20.64) 更新 $\Phi$；
        - 用式 (20.66)–(20.68) 更新 $\alpha$。

后验近似为

$$
q(\theta_m)=\operatorname{Dir}(\gamma_m),
$$

所以文档话题比例可估计为

$$
E_q[\theta_{mk}]=\frac{\gamma_{mk}}{\sum_l\gamma_{ml}},
$$

位置话题后验近似为 $q(z_{mn}=k)=\eta_{mnk}$。

#### Gibbs 与变分 EM 对比

| 项目 | 折叠 Gibbs | 变分 EM |
| --- | --- | --- |
| 后验处理 | MCMC 样本 | 平均场确定性近似 |
| 概率向量 | 解析积掉后再恢复 | $q(\theta)$；简化模型中 $\Phi$ 点估计 |
| 单次扫描 | $O(IK)$ | E 步约 $O(IK)$，另有 M 步 |
| 误差 | 混合与有限样本 | 变分族偏差与局部最优 |
| 并行化 | 同步计数较麻烦 | 文档 E 步易并行 |
| 不确定性 | 样本可表达 | 平均场常低估相关与方差 |

---

## 20.5 【补充】可运行代码：折叠 Gibbs 与变分 EM

以下代码只使用 Python 标准库。对应关系：

| 代码 | 公式或算法 |
| --- | --- |
| `dirichlet_sample` | Gamma 归一化采样及习题 20.1 |
| `collapsed_gibbs` | 式 (20.29)、算法 20.2 |
| `variational_e_step` | 式 (20.58)、(20.62)、算法 20.4 |
| `document_elbo` | 式 (20.46)–(20.55) |
| `variational_em` | 式 (20.64)、算法 20.5 的固定 $\alpha$ 版本 |

示例采用原书 17.2.2/习题 20.2 的 $11\times9$ 词频矩阵，取 $K=3$、对称稀疏先验 $\alpha_k=\beta_v=0.1$。代码中的话题标签对齐仅用于演示小 $K$ 时的标签交换问题，全排列法不适合大 $K$。

```python
"""《统计学习方法》第 20 章：LDA 折叠 Gibbs 与变分 EM，纯 Python。"""
import math
import random
import itertools


def normalize(values):
        total = sum(values)
        return [value / total for value in values]


def sample_categorical(weights, rng):
        threshold = rng.random() * sum(weights)
        cumulative = 0.0
        for index, weight in enumerate(weights):
                cumulative += weight
                if threshold <= cumulative:
                        return index
        return len(weights) - 1


def digamma(value):
        """递推到大参数后使用渐近展开。"""
        result = 0.0
        while value < 8.0:
                result -= 1.0 / value
                value += 1.0
        inverse = 1.0 / value
        inverse2 = inverse * inverse
        return (
                result + math.log(value) - 0.5 * inverse
                - inverse2 * (1.0 / 12.0 - inverse2 * (1.0 / 120.0 - inverse2 / 252.0))
        )


def dirichlet_sample(alpha, rng):
        """利用独立 Gamma 变量归一化生成 Dirichlet 样本。"""
        draws = [rng.gammavariate(value, 1.0) for value in alpha]
        return normalize(draws)


def collapsed_gibbs(documents, topics, vocabulary_size, alpha, beta,
                                        sweeps=2_000, burn_in=500, sample_lag=10, seed=20):
        """算法 20.2：按式 (20.29) 更新每个词元的话题。"""
        rng = random.Random(seed)
        document_topic = [[0] * topics for _ in documents]
        topic_word = [[0] * vocabulary_size for _ in range(topics)]
        topic_total = [0] * topics
        assignments = []

        for document_index, document in enumerate(documents):
                document_assignments = []
                for word in document:
                        topic = rng.randrange(topics)
                        document_assignments.append(topic)
                        document_topic[document_index][topic] += 1
                        topic_word[topic][word] += 1
                        topic_total[topic] += 1
                assignments.append(document_assignments)

        alpha_sum, beta_sum = sum(alpha), sum(beta)
        theta_sum = [[0.0] * topics for _ in documents]
        phi_sum = [[0.0] * vocabulary_size for _ in range(topics)]
        saved_samples = 0
        reference_phi = None
        for sweep in range(sweeps):
                for document_index, document in enumerate(documents):
                        document_denominator = len(document) - 1 + alpha_sum
                        for position, word in enumerate(document):
                                old_topic = assignments[document_index][position]
                                document_topic[document_index][old_topic] -= 1
                                topic_word[old_topic][word] -= 1
                                topic_total[old_topic] -= 1

                                weights = [
                                        (topic_word[topic][word] + beta[word])
                                        / (topic_total[topic] + beta_sum)
                                        * (document_topic[document_index][topic] + alpha[topic])
                                        / document_denominator
                                        for topic in range(topics)
                                ]
                                new_topic = sample_categorical(weights, rng)
                                assignments[document_index][position] = new_topic
                                document_topic[document_index][new_topic] += 1
                                topic_word[new_topic][word] += 1
                                topic_total[new_topic] += 1

                if sweep >= burn_in and (sweep - burn_in) % sample_lag == 0:
                        saved_samples += 1
                        current_theta = []
                        for document in range(len(documents)):
                                current_theta.append(normalize([
                                        document_topic[document][topic] + alpha[topic]
                                        for topic in range(topics)
                                ]))
                        current_phi = []
                        for topic in range(topics):
                                current_phi.append(normalize([
                                        topic_word[topic][word] + beta[word]
                                        for word in range(vocabulary_size)
                                ]))

                        if reference_phi is None:
                                reference_phi = [row[:] for row in current_phi]
                                alignment = tuple(range(topics))
                        else:
                                alignment = min(
                                        itertools.permutations(range(topics)),
                                        key=lambda permutation: sum(
                                                (reference_phi[reference][word]
                                                 - current_phi[permutation[reference]][word]) ** 2
                                                for reference in range(topics)
                                                for word in range(vocabulary_size)
                                        ),
                                )
                        for document in range(len(documents)):
                                for reference, current in enumerate(alignment):
                                        theta_sum[document][reference] += current_theta[document][current]
                        for reference, current in enumerate(alignment):
                                for word in range(vocabulary_size):
                                        phi_sum[reference][word] += current_phi[current][word]

        theta = [[value / saved_samples for value in row] for row in theta_sum]
        phi = [[value / saved_samples for value in row] for row in phi_sum]
        return theta, phi


def document_elbo(document, alpha, phi, gamma, eta):
        """式 (20.46)：计算一篇文档的五项 ELBO。"""
        alpha_sum, gamma_sum = sum(alpha), sum(gamma)
        expected_log_theta = [
                digamma(gamma[topic]) - digamma(gamma_sum)
                for topic in range(len(alpha))
        ]
        value = math.lgamma(alpha_sum) - sum(math.lgamma(item) for item in alpha)
        value += sum(
                (alpha[topic] - 1.0) * expected_log_theta[topic]
                for topic in range(len(alpha))
        )
        for position, word in enumerate(document):
                for topic in range(len(alpha)):
                        responsibility = eta[position][topic]
                        value += responsibility * expected_log_theta[topic]
                        value += responsibility * math.log(max(phi[topic][word], 1e-300))
                        if responsibility > 0.0:
                                value -= responsibility * math.log(responsibility)
        value -= math.lgamma(gamma_sum) - sum(math.lgamma(item) for item in gamma)
        value -= sum(
                (gamma[topic] - 1.0) * expected_log_theta[topic]
                for topic in range(len(alpha))
        )
        return value


def variational_e_step(document, alpha, phi, max_iterations=200, tolerance=1e-10):
        """算法 20.4：交替更新式 (20.58) 与式 (20.62)。"""
        topics = len(alpha)
        eta = [[1.0 / topics] * topics for _ in document]
        gamma = [alpha[topic] + len(document) / topics for topic in range(topics)]
        for _ in range(max_iterations):
                old_gamma = gamma[:]
                expected_log_theta = [
                        digamma(gamma[topic]) - digamma(sum(gamma))
                        for topic in range(topics)
                ]
                for position, word in enumerate(document):
                        log_weights = [
                                math.log(max(phi[topic][word], 1e-300))
                                + expected_log_theta[topic]
                                for topic in range(topics)
                        ]
                        maximum = max(log_weights)
                        eta[position] = normalize([
                                math.exp(value - maximum) for value in log_weights
                        ])
                gamma = [
                        alpha[topic] + sum(row[topic] for row in eta)
                        for topic in range(topics)
                ]
                if max(abs(gamma[i] - old_gamma[i]) for i in range(topics)) < tolerance:
                        break
        return gamma, eta


def variational_em(documents, topics, vocabulary_size, alpha,
                                   max_iterations=200, seed=21):
        """算法 20.5 的固定 alpha 版本：E 步后按式 (20.64) 更新 Phi。"""
        rng = random.Random(seed)
        phi = [
                normalize([rng.random() + 0.2 for _ in range(vocabulary_size)])
                for _ in range(topics)
        ]
        history = []
        gammas = etas = None
        for _ in range(max_iterations):
                gammas, etas = [], []
                for document in documents:
                        gamma, eta = variational_e_step(document, alpha, phi)
                        gammas.append(gamma)
                        etas.append(eta)

                expected_counts = [[0.0] * vocabulary_size for _ in range(topics)]
                for document, eta in zip(documents, etas):
                        for word, responsibilities in zip(document, eta):
                                for topic in range(topics):
                                        expected_counts[topic][word] += responsibilities[topic]
                phi = [normalize(row) for row in expected_counts]

                elbo = sum(
                        document_elbo(document, alpha, phi, gamma, eta)
                        for document, gamma, eta in zip(documents, gammas, etas)
                )
                history.append(elbo)
                if len(history) > 1:
                        gain = history[-1] - history[-2]
                        if gain >= -1e-8 and gain / max(1.0, abs(history[-2])) < 1e-10:
                                break

        # 用最终 Phi 再做一次 E 步，使返回的变分参数与模型参数一致。
        gammas, etas = [], []
        for document in documents:
                gamma, eta = variational_e_step(document, alpha, phi)
                gammas.append(gamma)
                etas.append(eta)
        theta = [normalize(gamma) for gamma in gammas]
        return theta, phi, history


def top_words(probabilities, words, count=4):
        order = sorted(
                range(len(words)), key=lambda index: (-probabilities[index], words[index])
        )
        return ", ".join(
                f"{words[index]}:{probabilities[index]:.3f}" for index in order[:count]
        )


def canonical_order(phi, words):
        """话题标签可置换；按高概率词签名排序，仅用于稳定展示。"""
        return sorted(
                range(len(phi)),
                key=lambda topic: tuple(
                        words[index]
                        for index in sorted(
                                range(len(words)), key=lambda i: (-phi[topic][i], words[i])
                        )[:3]
                ),
        )


WORDS = [
        "book", "dads", "dummies", "estate", "guide", "investing",
        "market", "real", "rich", "stock", "value",
]
MATRIX = [
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
DOCUMENTS = [
        [word for word in range(len(WORDS)) for _ in range(MATRIX[word][document])]
        for document in range(9)
]
ALPHA = [0.1, 0.1, 0.1]
BETA = [0.1] * len(WORDS)

rng = random.Random(22)
dirichlet_draws = [dirichlet_sample([2.0, 3.0, 5.0], rng) for _ in range(50_000)]
print("【Dirichlet 期望】")
print("sample mean =", [
        round(sum(row[index] for row in dirichlet_draws) / len(dirichlet_draws), 6)
        for index in range(3)
])
print("theory mean = [0.2, 0.3, 0.5]")

gibbs_theta, gibbs_phi = collapsed_gibbs(
        DOCUMENTS, 3, len(WORDS), ALPHA, BETA,
        sweeps=2_000, burn_in=1_999, sample_lag=1
)
gibbs_order = canonical_order(gibbs_phi, WORDS)
print("\n【习题 20.2：折叠 Gibbs】")
for display, topic in enumerate(gibbs_order, 1):
        print(f"z{display}: {top_words(gibbs_phi[topic], WORDS)}")
print("document mixtures =")
for document, row in enumerate(gibbs_theta, 1):
        print(f"  T{document}: {[round(row[topic], 3) for topic in gibbs_order]}")

vi_theta, vi_phi, elbo_history = variational_em(
        DOCUMENTS, 3, len(WORDS), ALPHA
)
vi_order = canonical_order(vi_phi, WORDS)
print("\n【习题 20.2：变分 EM】")
print("iterations =", len(elbo_history))
indices = list(dict.fromkeys(
        index for index in [0, 1, 2, 5, len(elbo_history) - 1]
        if 0 <= index < len(elbo_history)
))
print("ELBO checkpoints =", [round(elbo_history[index], 6) for index in indices])
print("ELBO nondecreasing =", all(
        elbo_history[index + 1] >= elbo_history[index] - 1e-8
        for index in range(len(elbo_history) - 1)
))
for display, topic in enumerate(vi_order, 1):
        print(f"z{display}: {top_words(vi_phi[topic], WORDS)}")
print("document mixtures =")
for document, row in enumerate(vi_theta, 1):
        print(f"  T{document}: {[round(row[topic], 3) for topic in vi_order]}")
```

运行输出：

```text
【Dirichlet 期望】
sample mean = [0.200081, 0.30001, 0.499909]
theory mean = [0.2, 0.3, 0.5]

【习题 20.2：折叠 Gibbs】
z1: investing:0.512, dummies:0.268, book:0.024, dads:0.024
z2: investing:0.317, stock:0.193, book:0.130, market:0.130
z3: rich:0.220, dads:0.149, estate:0.149, guide:0.149
document mixtures =
  T1: [0.023, 0.721, 0.256]
  T2: [0.913, 0.043, 0.043]
  T3: [0.023, 0.953, 0.023]
  T4: [0.03, 0.939, 0.03]
  T5: [0.043, 0.913, 0.043]
  T6: [0.208, 0.019, 0.774]
  T7: [0.03, 0.03, 0.939]
  T8: [0.03, 0.939, 0.03]
  T9: [0.019, 0.019, 0.962]

【习题 20.2：变分 EM】
iterations = 16
ELBO checkpoints = [-71.206232, -62.907786, -62.904015, -62.903934, -62.903933]
ELBO nondecreasing = True
z1: investing:0.314, stock:0.257, dummies:0.171, market:0.171
z2: investing:0.368, value:0.316, book:0.316, market:0.000
z3: rich:0.231, investing:0.231, dads:0.154, estate:0.154
document mixtures =
  T1: [0.953, 0.023, 0.023]
  T2: [0.913, 0.043, 0.043]
  T3: [0.644, 0.333, 0.023]
  T4: [0.03, 0.939, 0.03]
  T5: [0.043, 0.913, 0.043]
  T6: [0.019, 0.019, 0.962]
  T7: [0.03, 0.03, 0.939]
  T8: [0.939, 0.03, 0.03]
  T9: [0.019, 0.019, 0.962]
```

Gibbs 输出是一个燃烧期后的代表状态；若平均多个样本，必须先对齐可置换的话题标签。这个仅 30 个词元的数据集后验不确定性很大，不同种子、超参数和推断方法得到的细节可能不同。共同稳定结构比某一列具体数值更值得解释。

---

## 20.6 习题解答

### 习题 20.1

> 推导 Dirichlet 分布数学期望公式。

设

$$
	heta\sim\operatorname{Dir}(\alpha),
\qquad
\alpha_0=\sum_j\alpha_j.
$$

对第 $i$ 个分量：

$$
\begin{aligned}
E[\theta_i]
&=\int_{\Delta}\theta_i
\frac1{B(\alpha)}
\prod_j\theta_j^{\alpha_j-1}d\theta\\
&=\frac1{B(\alpha)}
\int_{\Delta}
	heta_i^{\alpha_i}
\prod_{j\ne i}\theta_j^{\alpha_j-1}d\theta\\
&=\frac{B(\alpha+e_i)}{B(\alpha)}\\
&=\frac{
\Gamma(\alpha_i+1)
\prod_{j\ne i}\Gamma(\alpha_j)
}{\Gamma(\alpha_0+1)}
\frac{\Gamma(\alpha_0)}
{\prod_j\Gamma(\alpha_j)}\\
&=\frac{\alpha_i}{\alpha_0}.
\end{aligned}
$$

最后一步用

$$
\Gamma(x+1)=x\Gamma(x).
$$

因此

$$
\boxed{E[\theta_i]=\frac{\alpha_i}{\sum_j\alpha_j}}.
$$

代码用 $\operatorname{Dir}(2,3,5)$ 的 50000 个样本得到 $(0.200081,0.300010,0.499909)$，与理论 $(0.2,0.3,0.5)$ 一致。

### 习题 20.2

> 针对 17.2.2 的文本例子，使用 LDA 模型进行话题分析。

原书数据为：

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

取

$$
K=3,
\qquad
\alpha=(0.1,0.1,0.1),
\qquad
\beta_v=0.1.
$$

稀疏先验适合这个极短标题集合。折叠 Gibbs 的一个燃烧期后代表状态给出：

| 话题 | 高概率词 | 可解释含义 |
| --- | --- | --- |
| $z_1$ | investing, dummies | 投资入门 |
| $z_2$ | investing, stock, book, market | 股票与投资书籍 |
| $z_3$ | rich, dads, estate, guide | 财富与房地产/指南 |

变分 EM 给出更清晰的三组：

| 话题 | 高概率词 | 可解释含义 |
| --- | --- | --- |
| $z_1$ | investing, stock, dummies, market | 股票市场与入门投资 |
| $z_2$ | investing, value, book | 价值投资与书籍 |
| $z_3$ | rich, investing, dads, estate | 财富与房地产投资 |

文档 T3 同时包含 `book`、`market`、`stock`，变分结果为

$$
	heta_{T3}\approx(0.644,0.333,0.023),
$$

体现混合话题；T6、T9 的财富类话题权重分别约为 $0.962$。

**如何理解两种结果不同**：

- 语料只有 30 个词元，后验非常宽；
- Gibbs 输出是随机后验状态，变分 EM 是一个局部最优平均场近似；
- 话题标签可任意置换；
- 超参数控制稀疏程度；
- `investing` 出现在所有标题中，区分力弱，却因频数高而在每个话题占较大概率。

因此不能把某次运行的每个小数当作唯一真相。应报告随机种子、$K,\alpha,\beta$、收敛信息，并比较多次运行的稳定结构。

### 习题 20.3

> 找出 Gibbs、变分 EM 中利用 Dirichlet 分布的部分，并说明其重要性。

#### Gibbs 中的使用

1. 积掉话题词分布：
        $$
        \int p(w\mid z,\phi)p(\phi\mid\beta)d\phi
        =\prod_k\frac{B(n_k+\beta)}{B(\beta)};
        $$
2. 积掉文档话题分布：
        $$
        \int p(z\mid\theta)p(\theta\mid\alpha)d\theta
        =\prod_m\frac{B(n_m+\alpha)}{B(\alpha)};
        $$
3. 满条件分布成为两个后验预测概率的乘积：
        $$
        \frac{n_{kv}^{-i}+\beta_v}{n_{k\cdot}^{-i}+\beta_0}
        \frac{n_{mk}^{-i}+\alpha_k}{N_m-1+\alpha_0};
        $$
4. 后处理仍为 Dirichlet 后验，直接得到式 (20.31)、(20.33)。

#### 变分 EM 中的使用

1. 选择
        $$
        q(\theta_m)=\operatorname{Dir}(\gamma_m),
        $$
        与模型先验同族；
2. Dirichlet 的期望对数
        $$
        E_q[\log\theta_{mk}]
        =\psi(\gamma_{mk})-\psi(\gamma_{m0})
        $$
        进入 $\eta$ 更新；
3. 共轭结构使最优变分因子仍为 Dirichlet：
        $$
        \gamma_{mk}=\alpha_k+\sum_n\eta_{mnk};
        $$
4. 超参数 $\alpha$ 的梯度、Hessian 可用 digamma/trigamma 表达。

原书简化变分模型把 $\Phi$ 当点参数，因此 M 步式 (20.64) 不使用 $\beta$；完整贝叶斯变分 LDA 若也为 $\phi_k$ 设置变分 Dirichlet 因子，则会再次出现 $\beta+$ 期望词计数。

#### Dirichlet 的重要性

- **共轭可解**：高维积分化为 Beta 函数比；
- **平滑**：零计数仍有非零预测概率；
- **正则化**：超参数控制文档/话题稀疏性；
- **不确定性**：不是只给一个概率向量，而是给概率向量的分布；
- **可交换混合表示**：共享随机概率向量使条件 iid 位置边缘相关；
- **新文档泛化**：所有文档共享 $\operatorname{Dir}(\alpha)$ 生成机制。

局限是普通 Dirichlet 分量协方差受单纯形约束始终为负，不能灵活表达话题间正相关；相关主题模型可用 logistic-normal 先验替代。

### 习题 20.4

> 给出 Gibbs 和变分 EM 的算法复杂度。

记：

- $I=\sum_mN_m$：总词元数；
- $K$：话题数；
- $V$：词汇量；
- $M$：文档数；
- $S$：Gibbs 扫描次数；
- $T$：变分 EM 外层轮数；
- $L$：每篇文档变分 E 步平均内层轮数；
- $R$：每次 M 步中 Newton 更新 $\alpha$ 的轮数。

#### 折叠 Gibbs

每个词元计算 $K$ 个候选话题权重，单次扫描：

$$
O(IK).
$$

$S$ 次扫描：

$$
\boxed{O(SIK)}.
$$

存储话题指派及两类计数：

$$
\boxed{O(I+MK+KV)}.
$$

若使用稀疏计数、Alias/MH 等快速采样，可降低常数或摊销候选话题成本，但朴素算法就是上述复杂度。

#### 变分 EM

一次文档 E 步内层迭代需更新每个词元的 $K$ 个责任度：

$$
O(IK).
$$

平均 $L$ 次内层迭代为 $O(LIK)$。M 步更新 $\Phi$ 为 $O(IK)$。一般矩阵求解更新 $\alpha$ 为

$$
O\bigl(R(MK+K^3)\bigr),
$$

利用 Hessian“对角 + 秩一”结构可把 $K^3$ 降至线性量级。因此朴素总时间为

$$
\boxed{
O\left(T\left[LIK+IK+R(MK+K^3)\right]\right)
}.
$$

主要存储：

$$
O(IK+MK+KV),
$$

其中 $IK$ 来自每个词元的 $\eta$。分批或在线变分推理可减少内存，并让各文档 E 步并行。

### 习题 20.5

> 证明变分 EM 算法收敛。

令外层第 $t$ 轮开始时为 $(q^{(t-1)},\vartheta^{(t-1)})$。

#### E 步

固定模型参数，在变分族内最大化 ELBO：

$$
\mathcal L(q^{(t)},\vartheta^{(t-1)})
\ge
\mathcal L(q^{(t-1)},\vartheta^{(t-1)}).
$$

若用坐标上升，每个 $q_j$ 更新都是该坐标的条件最大值，所以一次完整内层循环也不降低 ELBO。

#### M 步

固定 $q^{(t)}$ 最大化模型参数：

$$
\mathcal L(q^{(t)},\vartheta^{(t)})
\ge
\mathcal L(q^{(t)},\vartheta^{(t-1)}).
$$

合并得

$$
\mathcal L^{(t)}
=\mathcal L(q^{(t)},\vartheta^{(t)})
\ge
\mathcal L(q^{(t-1)},\vartheta^{(t-1)})
=\mathcal L^{(t-1)}.
$$

所以 $\{\mathcal L^{(t)}\}$ 单调不减。若目标在可行域上有有限上界，则单调有界序列必收敛。

在目标连续、每个坐标子问题被精确求解或至少保证充分上升、参数序列有聚点等正则条件下，任何聚点是 ELBO 的坐标驻点。由于 LDA 目标非凸，只能保证局部驻点，不保证全局最优，也不保证参数序列本身唯一收敛。

**关键纠正**：

$$
\log p(x\mid\vartheta)
=\mathcal L(q,\vartheta)+D_{\mathrm{KL}}(q\Vert p(z\mid x,\vartheta)).
$$

平均场 KL 通常大于 0，所以以上证明保证的是 ELBO 收敛。只有精确 E 步令 KL 为 0 时，才能使用原书式 (20.41) 的等号证明真实证据单调。

代码的 ELBO 检查点

$$
-71.206232,
-62.907786,
-62.904015,
-62.903934,
-62.903933
$$

单调上升，为推导提供数值验证。

---

## 20.7 【补充】常见误解与方法边界

1. **LDA 是线性判别分析。** 本章 LDA 是 latent Dirichlet allocation，不是 linear discriminant analysis。
2. **每篇文档只有一个话题。** $\theta_m$ 是混合比例，一篇文档可含多个话题。
3. **每个词固定属于一个话题。** 话题是词元级隐变量；同一词在不同位置可有不同话题。
4. **$\alpha,\beta$ 越小，所有概率越小。** 它们控制概率向量形状和浓度，不是直接概率。
5. **Gibbs 每轮似然都上升。** Gibbs 在后验上随机游走，目标值会波动；单调上升是 EM/坐标优化性质。
6. **变分 ELBO 就是真实对数似然。** 二者差一个非负 KL，平均场下通常不相等。
7. **话题编号有固定语义。** 后验对标签置换不变，多链比较必须对齐标签或比较置换不变量。
8. **话题数越多越好。** 过大 $K$ 会分裂主题、产生重复/空话题并降低稳定性。
9. **困惑度低就一定更可解释。** 预测似然与人类语义一致性并不等价，应同时看 coherence、稳定性和任务指标。
10. **停用词总会自动消失。** 高频常见词可能占据所有话题；预处理、背景话题或更合理先验仍很重要。
11. **Dirichlet 能表达任意话题相关。** 其协方差结构受限；logistic-normal、相关主题模型更灵活。
12. **一次运行足够。** 两种算法都受初始化和局部结构影响，应多次运行并报告不确定性。

现代扩展【补充】：

| 需求 | 可选模型或方法 |
| --- | --- |
| 自动推断话题数 | HDP / 非参数贝叶斯主题模型 |
| 话题正相关 | Correlated Topic Model（logistic-normal） |
| 时间演化 | Dynamic Topic Model |
| 海量流数据 | Online Variational Bayes |
| 利用词向量与上下文 | Neural Topic Model、上下文化主题模型 |
| 监督预测 | Supervised LDA |

---

## 20.8 本章知识清单

### 必须掌握的主线

1. Dirichlet 是单纯形上的分布，均值由比例决定、总浓度控制离散程度；
2. Dirichlet 与多项/类别分布共轭，后验参数等于伪计数加计数；
3. LDA 在 PLSA 上增加文档话题比例和话题词比例的先验；
4. 折叠 Gibbs 积掉 $\theta,\phi$，满条件是两个后验预测概率之积；
5. 变分推理通过最大化 ELBO 逼近后验；
6. LDA 平均场更新仍是“先验 + 期望计数”。

### 必须会写的公式

$$
p(\theta\mid\alpha)
=\frac1{B(\alpha)}\prod_i\theta_i^{\alpha_i-1},
$$

$$
	heta\mid D\sim\operatorname{Dir}(\alpha+n),
$$

$$
p(z_i=k\mid\cdots)
\propto
\frac{n_{kv}^{-i}+\beta_v}{n_{k\cdot}^{-i}+\beta_0}
\frac{n_{mk}^{-i}+\alpha_k}{N_m-1+\alpha_0},
$$

$$
\eta_{nk}
\propto\phi_{k,w_n}
\exp\{\psi(\gamma_k)-\psi(\gamma_0)\},
$$

$$
\gamma_k=\alpha_k+\sum_n\eta_{nk}.
$$

### 必须记住的边界

- 词袋可交换假设忽略词序；
- $K$ 和超参数会显著改变结果；
- Gibbs 渐近精确但可能混合慢，变分更快但有平均场偏差；
- 后验均值不等于 MAP；
- 标签交换使未经对齐的参数平均失去意义；
- 变分 EM 严格保证 ELBO 单调，而非一般情况下的真实证据单调。

## 第 20 章一句话回顾

**LDA 用 Dirichlet 先验把文档话题比例和话题词比例变成可共享、可平滑的随机变量；共轭性让折叠 Gibbs 化为“计数加伪计数”的抽样，让变分 EM 化为“期望计数加先验”的坐标更新，但两种推断仍分别受混合误差与平均场偏差限制。**
