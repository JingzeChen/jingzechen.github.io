---
title: "《算法面试（全二册）》第 13 章：树状数组"
date: 2026-08-03 02:13:00 +0800
updated: 2026-08-04
uid: algorithm-interview-ch13
type: reading
content_lang: zh-CN
status: growing
topics: [algorithms, books]
series: algorithm-interview
series_order: 14
related: [algorithm-interview-ch12, algorithm-interview-ch14]
categories: [读书笔记, 算法, 算法面试]
tags: [algorithms, data-structures, coding-interviews, reading-notes]
description: "围绕「树状数组」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
render_with_liquid: false
math: true
mermaid: true
---

> 本笔记按原书第 13 章的小节顺序展开。原书概念、例题与算法按原顺序讲解；超出原书的统一推导、扩展结构与替代方案均标注为“补充”。

## 本章要解决什么问题

设有数组 $a[1..n]$，需要反复执行：

1. 单点增加：$a[i]\mathrel{+}=x$；
2. 前缀求和：$a[1]+a[2]+\cdots+a[i]$。

直接数组让修改为 $O(1)$，但前缀查询为 $O(n)$；前缀和数组让查询为 $O(1)$，但一次修改会使后面大量前缀失效，需要 $O(n)$ 更新。Fenwick 在 1994 年提出的树状数组（Binary Indexed Tree，BIT）把两种操作都降为 $O(\log n)$，并只使用 $O(n)$ 空间。

树状数组可以看作“按二进制长度分组的前缀摘要”。它没有显式左右孩子，却通过下标最低位的 1 决定每个结点覆盖多长区间，以及查询和修改应跳到哪里。

```mermaid
flowchart LR
    A[原数组单点] -->|i += lowbit(i)| B[所有包含它的摘要]
    C[前缀 i] -->|累加 tree[i]| D[i -= lowbit(i)]
    D -->|直到 i=0| E[得到前缀和]
```

### 本章内容盘点与代码约定

本章按原书顺序整理为 **4 个基础算法单元、7 道正文题、5 道章末练习**：

| 类别 | 编号 | 内容 |
|---|---:|---|
| 基础算法单元 | B1 | 一维 Fenwick：`lowbit`、负责区间、单点加、前缀和、闭区间和与线性构建 |
| 基础算法单元 | B2 | 差分 Fenwick：闭区间加、单点查询 |
| 基础算法单元 | B3 | 双 Fenwick：闭区间加、闭区间和 |
| 基础算法单元 | B4 | 原生二维 Fenwick：单点加、前缀矩形和、矩形和 |
| 正文题 | P1 | 例 13-1 / HDU 1166：敌兵布阵 |
| 正文题 | P2 | LeetCode 1649：通过指令创建有序数组 |
| 正文题 | P3 | LeetCode 1409：查询带键的排列 |
| 正文题 | P4 | LeetCode 683：$k$ 个关闭的灯泡 |
| 正文题 | P5 | LeetCode 308：二维区域和检索（可修改） |
| 正文题 | P6 | LeetCode 327：区间和的个数 |
| 正文题 | P7 | LeetCode 315：计算右侧小于当前元素的个数 |

后文 C++17 采用统一边界：**原数组或题目 API 使用 0 基下标，`FenwickTree` 的公开接口也接收 0 基下标；只有类内部的 `tree_[1..n]` 使用 1 基下标。** 因而公开接口满足

$$
\begin{aligned}
PrefixSum(r)&=\sum_{k=0}^{r}a[k],\\
RangeSum(l,r)&=PrefixSum(r)-PrefixSum(l-1).
\end{aligned}
$$

其中约定 $PrefixSum(-1)=0$，于是 `RangeSum(0,r)` 不需要特判。若题目输入本身按 1 编号（如 HDU 1166 的士兵编号），只在调用公开接口时减 1；若离散化得到 0 基 `rank`，直接把 `rank` 交给公开接口，不能再次加 1。Python 与 Go 的完整实现只放在章末附录 A、B，正文以 C++17 为主。

## 13.1 树状数组概述

### 13.1.1 树状数组的定义

#### 1. 为什么必须理解 `lowbit`

对正整数 $i$，`lowbit(i)` 定义为其二进制表示中最低位 1 的权值。若最低位 1 在从右向左第 $t+1$ 位，则

$$
lowbit(i)=2^t.
$$

例如：

| $i$ | 二进制 | 最低位 1 | $lowbit(i)$ |
|---:|---:|---:|---:|
| 5 | $0101_2$ | $2^0$ | 1 |
| 6 | $0110_2$ | $2^1$ | 2 |
| 8 | $1000_2$ | $2^3$ | 8 |
| 12 | $1100_2$ | $2^2$ | 4 |

它可用位运算计算：

$$
\boxed{lowbit(i)=i\mathbin{\&}(-i).}
$$

#### 2. `i & (-i)` 的完整推导

设 $i$ 的最低位 1 右侧有 $t$ 个 0，可写成二进制形式

$$
i=(\text{高位})\,1\underbrace{00\cdots0}_{t\text{ 个}}.
$$

在补码系统中，$-i$ 等于按位取反再加 1。取反后，原最低位 1 变成 0，右侧 $t$ 个 0 变成 1；再加 1 时，这 $t$ 个低位 1 全部进位成 0，原最低位位置变成 1。该位置左侧虽可能有其他位，但与原数按位与时都会被消去。于是

$$
i\mathbin{\&}(-i)
=00\cdots001\underbrace{00\cdots0}_{t\text{ 个}}
=2^t.
$$

以 $i=5$ 的 8 位表示为例：

$$
\begin{aligned}
i&=00000101_2,\\
-i&=11111011_2,\\
i\mathbin{\&}(-i)&=00000001_2=1.
\end{aligned}
$$

原书 OCR 文本中公式一度显示成 `i&(i)`，结合补码推导和示例，正确公式显然是 `i&(-i)`。

#### 3. 为什么采用 1 基下标

树状数组通常使用下标 $1\sim n$。因为

$$
lowbit(0)=0,
$$

若更新循环从 0 开始执行 `i += lowbit(i)`，下标永远不变，会形成死循环。对外若使用 0 基数组，应在进入 BIT 时统一加 1。

#### 4. `tree[i]` 的严格区间含义

令

$$
b=lowbit(i).
$$

树状数组结点 `tree[i]` 保存原数组末尾在 $i$、长度为 $b$ 的区间和：

$$
\boxed{
tree[i]=\sum_{k=i-lowbit(i)+1}^{i}a[k].
}
$$

也就是覆盖闭区间

$$
[i-lowbit(i)+1,i].
$$

对 $n=8$：

| $i$ | 二进制 | $lowbit(i)$ | `tree[i]` 覆盖区间 |
|---:|---:|---:|---|
| 1 | 001 | 1 | $[1,1]$ |
| 2 | 010 | 2 | $[1,2]$ |
| 3 | 011 | 1 | $[3,3]$ |
| 4 | 100 | 4 | $[1,4]$ |
| 5 | 101 | 1 | $[5,5]$ |
| 6 | 110 | 2 | $[5,6]$ |
| 7 | 111 | 1 | $[7,7]$ |
| 8 | 1000 | 8 | $[1,8]$ |

这些区间按二进制边界对齐，既能拼出任意前缀，又能让一个单点只影响对数个摘要。

#### 5. 前缀查询为何执行 `i -= lowbit(i)`

要求

$$
prefix(i)=\sum_{k=1}^{i}a[k].
$$

首先取 `tree[i]`，它覆盖

$$
[i-lowbit(i)+1,i].
$$

剩余尚未覆盖的前缀恰是

$$
[1,i-lowbit(i)].
$$

所以把

$$
i\leftarrow i-lowbit(i)
$$

并重复同一过程。每一步都去掉当前二进制最低位的 1；区间彼此相邻、不重叠，最终 $i=0$ 时完整覆盖原前缀。

例如 $i=7=111_2$：

$$
\begin{aligned}
prefix(7)
&=tree[7]+tree[6]+tree[4]\\
&=a[7]+(a[5]+a[6])+(a[1]+a[2]+a[3]+a[4]).
\end{aligned}
$$

对应跳转：

$$
7\to6\to4\to0.
$$

#### 6. 单点修改为何执行 `i += lowbit(i)`

执行

$$
a[p]\mathrel{+}=x
$$

时，所有覆盖位置 $p$ 的 `tree` 摘要都必须增加 $x$。从 $i=p$ 开始，

$$
i\leftarrow i+lowbit(i)
$$

会跳到包含当前区间的下一个更大二进制对齐区间。

例如 $p=5$：

$$
5\to6\to8.
$$

- `tree[5]` 覆盖 $[5,5]$；
- `tree[6]` 覆盖 $[5,6]$；
- `tree[8]` 覆盖 $[1,8]$。

三者都包含 $a[5]$，且在 $1\sim8$ 中没有其他 BIT 结点既是该更新路径祖先又需维护。

#### 7. 一次贯穿四个概念的数值走查

取外部 0 基数组

$$
a=[3,1,4,1,5,9,2,6].
$$

BIT 内部把外部位置 $p_0$ 迁移为 $p_1=p_0+1$。线性构建后，省略 `tree[0]` 的数组为

$$
tree=[3,4,4,9,5,14,2,31].
$$

先查询外部前缀 `PrefixSum(6)`。外部右端 6 进入内部后是 $i_1=7=0111_2$：

| 内部 $i_1$ | $lowbit(i_1)$ | 内部负责区间 | 外部 0 基区间 | 摘要值 |
|---:|---:|---|---|---:|
| 7 | 1 | $[7,7]$ | $[6,6]$ | 2 |
| 6 | 2 | $[5,6]$ | $[4,5]$ | 14 |
| 4 | 4 | $[1,4]$ | $[0,3]$ | 9 |

查询路径为

$$
7\to6\to4\to0,
$$

覆盖区间在外部坐标中恰好拼成 $[0,6]$，所以

$$
PrefixSum(6)=2+14+9=25.
$$

再令外部 `a[4] += 7`。外部位置 4 进入内部后是 $i_1=5=0101_2$，更新路径为

$$
5\to6\to8\to16>n.
$$

| 内部 $i_1$ | $lowbit(i_1)$ | 内部负责区间 | 外部负责区间 | 更新后摘要 |
|---:|---:|---|---|---:|
| 5 | 1 | $[5,5]$ | $[4,4]$ | $5+7=12$ |
| 6 | 2 | $[5,6]$ | $[4,5]$ | $14+7=21$ |
| 8 | 8 | $[1,8]$ | $[0,7]$ | $31+7=38$ |

每个被修改摘要都覆盖外部位置 4。此后

$$
\begin{aligned}
RangeSum(2,6)
&=PrefixSum(6)-PrefixSum(1)\\
&=32-4=28,
\end{aligned}
$$

对应新数组的 $4+1+12+9+2=28$。这组数据同时检验了四个最容易错的迁移点：公开下标加 1 后才进入 BIT、`tree[i]` 覆盖长度等于 `lowbit(i)`、查询向下清除最低位 1、更新向上跳到所有包含该点的摘要。

**迁移判断。** 面对新题时，不应只看到“动态数组”就套 BIT，而应依次判断：

1. 若状态是单点增量，查询能写成前缀或两个前缀之差，直接使用 B1；
2. 若外部操作是单点赋值，先保存旧值并迁移成 `delta=new-old`；
3. 若操作是区间加、查询是单点值，把原数组迁移成差分数组，使用 B2；
4. 若操作和查询都是区间和，使用 B3 的两个 BIT；
5. 若坐标过大但只依赖次序，把原坐标迁移成 0 基排名；严格小于查 `rank-1`，闭区间右端必须包含端点；
6. 若查询是不可逆的一般区间最值、赋值覆盖或复杂组合更新，普通 BIT 无法由两个前缀消去，应迁移到线段树等结构。

#### 8. 两种操作为何都是 $O(\log n)$

前缀查询每次清除一个二进制 1，步数不超过二进制位数。单点修改每次跳到更大的负责区间，最多沿隐式树上升到超过 $n$。二者步数均不超过

$$
\lfloor\log_2n\rfloor+1,
$$

所以时间为 $O(\log n)$。

### 13.1.2 树状数组的实现

下面的共享模板只定义一次，后续 4 个基础单元和 7 道正文题均复用它。`index0`/`right0` 是公开的 0 基下标；进入循环后统一转换为 `index1=index0+1`，因此更新循环永远不会从 0 起步。

```cpp
#include <algorithm>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

class FenwickTree {
public:
    explicit FenwickTree(int size) : tree_(size + 1, 0) {
        if (size < 0) {
            throw std::invalid_argument("size must be non-negative");
        }
    }

    explicit FenwickTree(const std::vector<long long>& values)
        : tree_(values.size() + 1, 0) {
        for (int index1 = 1; index1 <= Size(); ++index1) {
            tree_[index1] += values[index1 - 1];
            const int parent1 = index1 + Lowbit(index1);
            if (parent1 <= Size()) {
                tree_[parent1] += tree_[index1];
            }
        }
    }

    int Size() const {
        return static_cast<int>(tree_.size()) - 1;
    }

    void Add(int index0, long long delta) {
        if (index0 < 0 || index0 >= Size()) {
            throw std::out_of_range("FenwickTree::Add index");
        }
        for (int index1 = index0 + 1;
             index1 <= Size();
             index1 += Lowbit(index1)) {
            tree_[index1] += delta;
        }
    }

    long long PrefixSum(int right0) const {
        if (right0 >= Size()) {
            throw std::out_of_range("FenwickTree::PrefixSum index");
        }
        long long answer = 0;
        for (int index1 = right0 + 1;
             index1 > 0;
             index1 -= Lowbit(index1)) {
            answer += tree_[index1];
        }
        return answer;
    }

    long long RangeSum(int left0, int right0) const {
        if (left0 < 0 || right0 >= Size()) {
            throw std::out_of_range("FenwickTree::RangeSum index");
        }
        if (left0 > right0) {
            return 0;
        }
        return PrefixSum(right0) - PrefixSum(left0 - 1);
    }

private:
    static int Lowbit(int index1) {
        return index1 & -index1;
    }

    std::vector<long long> tree_;
};
```

这一个代码块同时给出 B1 的核心实现与 $O(n)$ 线性构建。构造函数从左到右把 `tree_[index1]` 传给 `parent1=index1+lowbit(index1)`；`Add`、`PrefixSum`、`RangeSum` 的调用者始终看不到内部 1 基坐标。

#### 1. 单点增加 `add`

对 1 基下标 $i$ 增加 $x$：

```text
while i <= n:
    tree[i] += x
    i += lowbit(i)
```

循环不变量是：当前 `i` 所负责区间包含原修改位置；更新后跳到下一个包含它的祖先摘要。越过 $n$ 后，不再有需要维护的有效结点。

#### 2. 前缀查询 `sum`

```text
answer = 0
while i > 0:
    answer += tree[i]
    i -= lowbit(i)
```

每次取出的区间与已取区间不重叠，并紧邻剩余前缀右端，因此循环结束时 `answer` 恰等于 $a[1..i]$ 的原始前缀和。

#### 3. 闭区间求和

虽然 BIT 的基本查询是前缀，但任意闭区间可由两个前缀相减：

$$
\boxed{
sumRange(l,r)=prefix(r)-prefix(l-1).
}
$$

前提是维护的聚合具有可逆差分；整数加法满足。每次区间查询执行两次前缀查询，仍为 $O(\log n)$。

#### 4. 单点赋值与单点增加的区别

BIT 原生操作是

$$
a[i]\mathrel{+}=delta.
$$

若 API 要求把 $a[i]$ 直接改为 `value`，必须知道旧值并计算

$$
delta=value-a[i],
$$

然后调用 `add(i,delta)`。忘记转换会把新值误当增量。

#### 5. 原书区间修改：维护差分数组

对原数组闭区间

$$
a[l..r]\mathrel{+}=x,
$$

令 BIT 维护差分数组 $d$，只需：

$$
\boxed{
add(l,x),
\qquad
add(r+1,-x).
}
$$

此时

$$
a[i]=\sum_{k=1}^{i}d[k]=BIT.prefix(i).
$$

必须注意：这种单 BIT 结构支持的是“区间加 + 单点查询”。`prefix(i)` 恢复的是原数组第 $i$ 个值，不是原数组 $a[1..i]$ 的和。

> **补充：区间加 + 区间和。** 若还要查询原数组区间和，可维护两个 BIT。对更新 `[l,r]+=x`：
> $$
> \begin{aligned}
> B_1:&\ add(l,x),\ add(r+1,-x),\\
> B_2:&\ add(l,x(l-1)),\ add(r+1,-xr).
> \end{aligned}
> $$
> 原数组前缀和为
> $$
> prefixA(p)=p\cdot sum(B_1,p)-sum(B_2,p).
> $$
> 推导来自
> $$
> \sum_{k=1}^{p}a[k]
> =\sum_{t=1}^{p}d[t](p-t+1)
> =(p+1)\sum d[t]-\sum t\,d[t],
> $$
> 与上面的 $B_2$ 记法代数等价。

B2 与 B3 都沿用共享 `FenwickTree` 的 0 基公开接口。对外部闭区间 `[left0,right0]`，B2 在 `right0+1` 处撤销差分；B3 中内部位置 $p=right0+1$，所以第二棵树撤销项的系数也是 `right0+1`。

```cpp
class RangeAddPointQuery {
public:
    explicit RangeAddPointQuery(int size) : difference_(size) {}

    void RangeAdd(int left0, int right0, long long delta) {
        difference_.Add(left0, delta);
        if (right0 + 1 < difference_.Size()) {
            difference_.Add(right0 + 1, -delta);
        }
    }

    long long PointQuery(int index0) const {
        return difference_.PrefixSum(index0);
    }

private:
    FenwickTree difference_;
};
```

B2 的 `PointQuery(index0)` 对差分数组求前缀，恢复的是原数组单点 $a[index0]$，不是原数组前缀和。

```cpp
class RangeAddRangeSum {
public:
    explicit RangeAddRangeSum(int size) : first_(size), second_(size) {}

    void RangeAdd(int left0, int right0, long long delta) {
        AddBoundary(left0, delta);
        if (right0 + 1 < first_.Size()) {
            AddBoundary(right0 + 1, -delta);
        }
    }

    long long PrefixSum(int right0) const {
        const long long internal_position = right0 + 1LL;
        return internal_position * first_.PrefixSum(right0)
             - second_.PrefixSum(right0);
    }

    long long RangeSum(int left0, int right0) const {
        return PrefixSum(right0) - PrefixSum(left0 - 1);
    }

private:
    void AddBoundary(int index0, long long delta) {
        first_.Add(index0, delta);
        second_.Add(index0, delta * index0);
    }

    FenwickTree first_;
    FenwickTree second_;
};
```

在 B3 中，外部 `index0` 对应内部 $p=index0+1$，而标准公式第二项更新的是 $delta\cdot(p-1)$，因此代码恰为 `delta * index0`。`RangeAddRangeSum::PrefixSum(-1)` 不会被直接调用两棵树：它先得到内部位置 0，两次共享前缀查询也都按约定返回 0。

#### 6. 用单点添加构建：$O(n\log n)$

从全零 BIT 开始，对每个 $i$ 调用

$$
add(i,a[i]),
$$

每次 $O(\log n)$，总时间 $O(n\log n)$。原书也给出按定义逐项累加每个 `tree[i]` 覆盖区间的方法，渐近复杂度同样为 $O(n\log n)$。

#### 7. 线性构建：$O(n)$

从左到右执行：

$$
tree[i]\mathrel{+}=a[i],
$$

并令

$$
parent=i+lowbit(i).
$$

若 `parent<=n`，执行

$$
tree[parent]\mathrel{+}=tree[i].
$$

为什么正确？处理到 $i$ 时，`tree[i]` 已汇总其负责区间 $[i-lowbit(i)+1,i]$；该区间完整包含在 `parent` 的负责区间中。把它一次传给父摘要，随后更靠右的元素仍会继续加入。每个下标只做常数次操作，总时间 $O(n)$。

以

$$
a=[1,2,3,4,5,6,7,8]
$$

为例，最终

$$
tree=[1,3,3,10,5,11,7,36]
$$

（此处省略未使用的 `tree[0]`）。验证：

$$
prefix(7)=tree[7]+tree[6]+tree[4]=7+11+10=28.
$$

#### 8. 二维扩展

原书指出树状数组可扩展到二维或更高维，也可先通过坐标映射复用一维结构。本章 13.2.4 将矩阵按行展开，并逐行查询一维 BIT。

> **补充：原生二维 BIT。** 若维护 `tree[x][y]`，单点增加沿两个维度分别执行
> $$
> x\mathrel{+}=lowbit(x),\qquad y\mathrel{+}=lowbit(y),
> $$
> 前缀矩形查询则分别减去 `lowbit`。任意矩形和再用四项容斥得到，单次更新和查询为 $O(\log m\log n)$。

B4 的公开行列仍从 0 开始，内部两个维度分别加 1。`PrefixSum(row0,column0)` 表示外部矩形 $[0,row0]\times[0,column0]$；任意闭矩形使用四项容斥。

```cpp
class FenwickTree2D {
public:
    FenwickTree2D(int rows, int columns)
        : rows_(rows),
          columns_(columns),
          tree_(rows + 1, std::vector<long long>(columns + 1, 0)) {}

    void Add(int row0, int column0, long long delta) {
        for (int row1 = row0 + 1; row1 <= rows_; row1 += Lowbit(row1)) {
            for (int column1 = column0 + 1;
                 column1 <= columns_;
                 column1 += Lowbit(column1)) {
                tree_[row1][column1] += delta;
            }
        }
    }

    long long PrefixSum(int row0, int column0) const {
        long long answer = 0;
        for (int row1 = row0 + 1; row1 > 0; row1 -= Lowbit(row1)) {
            for (int column1 = column0 + 1;
                 column1 > 0;
                 column1 -= Lowbit(column1)) {
                answer += tree_[row1][column1];
            }
        }
        return answer;
    }

    long long RangeSum(
        int row1, int column1, int row2, int column2) const {
        return PrefixSum(row2, column2)
             - PrefixSum(row1 - 1, column2)
             - PrefixSum(row2, column1 - 1)
             + PrefixSum(row1 - 1, column1 - 1);
    }

private:
    static int Lowbit(int index1) {
        return index1 & -index1;
    }

    int rows_;
    int columns_;
    std::vector<std::vector<long long>> tree_;
};
```

#### 9. 例 13-1：HDU 1166 敌兵布阵

题目操作对应为：

- `Add i j`：`add(i,+j)`；
- `Sub i j`：`add(i,-j)`；
- `Query i j`：`prefix(j)-prefix(i-1)`。

输入中的士兵编号是 1 基，而共享类公开接口是 0 基，因此三条命令都只在边界处执行 `i-1`。这道题的 C++17 核心实现如下；它复用 B1，不重新定义 Fenwick 类。

```cpp
void SolveHdu1166(std::istream& input, std::ostream& output) {
    int test_count = 0;
    input >> test_count;
    for (int case_index = 1; case_index <= test_count; ++case_index) {
        int size = 0;
        input >> size;
        std::vector<long long> values(size);
        for (long long& value : values) {
            input >> value;
        }

        FenwickTree troops(values);
        output << "Case " << case_index << ":\n";
        std::string command;
        while (input >> command && command != "End") {
            int first = 0;
            int second = 0;
            input >> first >> second;
            if (command == "Query") {
                output << troops.RangeSum(first - 1, second - 1) << '\n';
            } else if (command == "Add") {
                troops.Add(first - 1, second);
            } else if (command == "Sub") {
                troops.Add(first - 1, -second);
            }
        }
    }
}
```

若初始人数为 $[1,2,\ldots,10]$，原书样例中的三次查询结果为：

```text
6
33
59
```

每条命令 $O(\log n)$，空间 $O(n)$。

#### 10. 树状数组与线段树比较

原书总结，在能用 BIT 解决的加法前缀问题上，BIT 通常有三点优势：

1. 只需 $n+1$ 个数组槽位，空间更小；
2. 循环和位运算常数较小；
3. 无递归、无显式结点和懒标记，实现更短。

但 BIT 的结构围绕前缀聚合及其逆运算设计。区间和可由两个前缀相减，而普通区间最小值不能由“两个前缀最小值相减”得到，所以原书指出 BIT 无法像线段树那样直接处理一般动态区间最值。

| 需求 | 树状数组 | 线段树 |
|---|---|---|
| 单点加 + 前缀/区间和 | 简单、常数小 | 可以但更重 |
| 区间加 + 单点查询 | 一个差分 BIT | 懒标记树 |
| 区间加 + 区间和 | 两个 BIT | 懒标记树 |
| 通用区间最小/最大值 | 不直接支持 | 直接支持 |
| 复杂赋值、覆盖、仿射更新 | 不擅长 | 可设计懒标记 |

> **补充：边界说明。** 在更新只增不减等受限条件下，可以设计“前缀最大值 BIT”，但它不具备一般可逆区间查询能力，不能据此把普通 BIT 当作通用最值结构。

## 13.2 树状数组应用的算法设计

### 13.2.1 LeetCode 1649：通过指令创建有序数组（★★★）

#### 1. 从维护有序数组转为维护值域频次

直接把每个新数插入数组并保持有序，寻找位置可二分，但数组移动仍是 $O(n)$。题目其实不要求输出最终有序数组，只要求插入前：

- 严格小于当前值 $x$ 的元素数；
- 严格大于当前值 $x$ 的元素数。

因此可让 BIT 的下标表示数值，`tree` 维护已插入数字的频次。原书约束

$$
1\le x\le10^5,
$$

值域足够小，无需离散化。

#### 2. 两个计数公式

处理第 $j$ 条指令前，已有元素数恰为 $j$。令 BIT 前缀频次为 $S(v)$。

严格小于 $x$：

$$
\boxed{smaller=S(x-1).}
$$

小于或等于 $x$：

$$
S(x).
$$

因此严格大于 $x$ 的数量为

$$
\boxed{larger=j-S(x).}
$$

等于 $x$ 的重复元素既不属于严格小于，也不属于严格大于；两个边界分别用 $x-1$ 和 $x$ 正好排除了它们。

本次代价为

$$
\boxed{cost_j=\min(smaller,larger).}
$$

随后执行 `add(x,1)`，把当前元素加入历史。

> **原文勘误说明：** 原书解题思路段落写成“两者取最大值”，但题目定义、样例和紧随其后的 C++/Python 代码均使用 `min`，正确操作是取较小值。

#### 3. 原书样例走查

对

$$
instructions=[1,2,3,6,5,4]：
$$

| 插入 $x$ | 已有元素 | `smaller` | `larger` | 代价 |
|---:|---|---:|---:|---:|
| 1 | 空 | 0 | 0 | 0 |
| 2 | 1 | 1 | 0 | 0 |
| 3 | 1,2 | 2 | 0 | 0 |
| 6 | 1,2,3 | 3 | 0 | 0 |
| 5 | 1,2,3,6 | 3 | 1 | 1 |
| 4 | 1,2,3,5,6 | 3 | 2 | 2 |

总代价为 3。

#### 4. C++17 核心实现

题目值从 1 开始，但共享 Fenwick 的公开坐标从 0 开始，因此值 $x$ 存在外部位置 `x-1`。严格小于 $x$ 查询到 `x-2`，小于等于 $x$ 查询到 `x-1`。

```cpp
int CreateSortedArray(const std::vector<int>& instructions) {
    if (instructions.empty()) {
        return 0;
    }
    constexpr long long kMod = 1'000'000'007LL;
    const int maximum_value =
        *std::max_element(instructions.begin(), instructions.end());
    FenwickTree frequency(maximum_value);
    long long answer = 0;

    for (int inserted = 0;
         inserted < static_cast<int>(instructions.size());
         ++inserted) {
        const int value0 = instructions[inserted] - 1;
        const long long smaller = frequency.PrefixSum(value0 - 1);
        const long long not_larger = frequency.PrefixSum(value0);
        const long long larger = inserted - not_larger;
        answer = (answer + std::min(smaller, larger)) % kMod;
        frequency.Add(value0, 1);
    }
    return static_cast<int>(answer);
}
```

#### 5. 正确性与复杂度

处理 $x$ 前，归纳假设 BIT 叶子频次恰表示此前所有指令。前缀 $S(x-1)$ 精确统计较小值，$j-S(x)$ 精确统计较大值，故本次代价正确；插入 $x$ 后不变量对下一轮成立。各轮代价相加即为定义中的总代价。

设最大值为 $V$、指令数为 $n$。每轮两次查询和一次更新，时间 $O(n\log V)$，空间 $O(V)$。答案每轮按

$$
10^9+7
$$

取模，累计变量应使用足够宽的整数类型。

### 13.2.2 LeetCode 1409：查询带键的排列（★★）

#### 1. 难点：移动到最前面会让大量下标变化

直接在数组中删除一个元素并插到开头，每次可能移动 $O(m)$ 个元素。原书不真正移动数据，而是为排列元素分配“虚拟位置”，BIT 只记录每个位置是否被占用。

设查询数为 $n$。开辟位置 $1\sim n+m$：

- 前 $n$ 个位置预留给以后“移到最前面”的操作；
- 初始排列 $1,2,\ldots,m$ 放在位置 $n+1,n+2,\ldots,n+m$。

令

$$
pos[v]=n+v,
$$

并在这些位置都写入占用频次 1。

#### 2. 如何求当前零基下标

查询值 $v$ 当前位于物理位置 $p=pos[v]$。BIT 前缀

$$
S(p)
$$

表示位置不大于 $p$ 的有效元素数，其中包含 $v$ 自身。因此 $v$ 前面的元素数，也就是题目要求的零基下标，为

$$
\boxed{S(p)-1.}
$$

#### 3. 如何用空槽模拟移到开头

处理第 $j$ 个查询（$j$ 从 0 开始）：

1. 在旧位置执行 `add(p,-1)`；
2. 新位置选为
     $$
     newPos=n-j;
     $$
3. 执行 `add(newPos,+1)`；
4. 更新 `pos[v]=newPos`。

新位置按 $n,n-1,\ldots,1$ 递减，每次都比所有当前有效位置更小，所以元素自然位于逻辑最前面，无需移动其他元素。

#### 4. 数值走查

`queries=[3,1,2,1]`、$m=5$：

| 查询 | 查询前排列 | 返回位置 | 移到前面后 |
|---:|---|---:|---|
| 3 | $[1,2,3,4,5]$ | 2 | $[3,1,2,4,5]$ |
| 1 | $[3,1,2,4,5]$ | 1 | $[1,3,2,4,5]$ |
| 2 | $[1,3,2,4,5]$ | 2 | $[2,1,3,4,5]$ |
| 1 | $[2,1,3,4,5]$ | 1 | $[1,2,3,4,5]$ |

答案为 `[2,1,2,1]`。

#### 5. C++17 核心实现

这里把原书的物理位置整体迁移成 0 基：预留槽为 `[0,n-1]`，初始排列放在 `[n,n+m-1]`，第 $j$ 次查询的新位置为 `n-1-j`。

```cpp
std::vector<int> ProcessQueries(
    const std::vector<int>& queries, int maximum_value) {
    const int query_count = static_cast<int>(queries.size());
    FenwickTree occupied(query_count + maximum_value);
    std::vector<int> position(maximum_value + 1, 0);

    for (int value = 1; value <= maximum_value; ++value) {
        position[value] = query_count + value - 1;
        occupied.Add(position[value], 1);
    }

    std::vector<int> answer;
    answer.reserve(query_count);
    for (int query_index = 0; query_index < query_count; ++query_index) {
        const int value = queries[query_index];
        const int old_position0 = position[value];
        answer.push_back(
            static_cast<int>(occupied.PrefixSum(old_position0) - 1));
        occupied.Add(old_position0, -1);

        const int new_position0 = query_count - 1 - query_index;
        position[value] = new_position0;
        occupied.Add(new_position0, 1);
    }
    return answer;
}
```

#### 6. 正确性与复杂度

BIT 中值为 1 的位置从左到右顺序始终等于当前排列顺序。前缀频次减 1 正好给出当前元素左侧有效位置数；删除旧位置并占用更小的新位置，恰好模拟移到最前。该不变量从初始化开始，每轮保持成立。

初始化 $m$ 个元素需 $O(m\log(m+n))$；每个查询三次 BIT 操作为 $O(\log(m+n))$。总时间

$$
O((m+n)\log(m+n)),
$$

空间 $O(m+n)$。

### 13.2.3 LeetCode 683：$k$ 个关闭的灯泡（★★★）

#### 1. 把每天状态变成位置频次

灯泡位置为 $1\sim n$。BIT 中位置 $p$ 的值为：

$$
open[p]=
\begin{cases}
1,&p\text{ 已打开},\\
0,&p\text{ 仍关闭}.
\end{cases}
$$

另用布尔数组快速判断某个候选端点是否已经打开。BIT 负责查询两个端点之间打开灯泡的数量。

第 $day$ 天将位置 $x$ 打开。与 $x$ 之间恰有 $k$ 个位置的候选端点只有两个：

$$
p_{right}=x+k+1,
\qquad
p_{left}=x-k-1.
$$

#### 2. 正确的内部关闭判定

在把 $x$ 插入 BIT **之前**检查。

右侧候选 $p=x+k+1$ 合法，需要：

1. $p\le n$ 且 `open[p]=true`；
2. 内部位置 $x+1\sim p-1$ 全部关闭。

内部打开数为

$$
\boxed{S(p-1)-S(x).}
$$

它等于 0 时内部全关。

左侧候选 $p=x-k-1$ 合法，需要 `open[p]=true`，且内部 $p+1\sim x-1$ 的打开数

$$
\boxed{S(x-1)-S(p)}
$$

等于 0。

若任一方向成立，立即返回当前天数；否则标记 `open[x]=true` 并执行 `add(x,1)`。

> **原文勘误说明：** 原书第 588 页把右侧条件写为 `Sum(x+1)=Sum(p)`，左侧写为 `Sum(p+1)=Sum(x)`。按本章已定义的包含端点前缀和，这两式分别错移了一个端点；尤其右式会把已打开的 $p$ 计入差值而无法为 0。正确公式是上面的 `Sum(p-1)-Sum(x)=0` 与 `Sum(x-1)-Sum(p)=0`。

#### 3. 样例走查

`bulbs=[1,3,2]`、$k=1$：

- 第 1 天打开位置 1；没有另一已开端点；
- 第 2 天当前 $x=3$，左候选
    $$
    p=3-1-1=1
    $$
    已打开；内部只有位置 2，
    $$
    S(2)-S(1)=1-1=0.
    $$

所以第 2 天满足条件，返回 2。

#### 4. C++17 核心实现

题目灯泡编号为 $1\sim n$，代码进入算法时统一减 1。候选端点与当前灯泡相距 `gap+1`；`RangeSum` 查询的只是两个端点之间的开灯数。

```cpp
int KEmptySlots(const std::vector<int>& bulbs, int gap) {
    const int size = static_cast<int>(bulbs.size());
    std::vector<bool> opened(size, false);
    FenwickTree state(size);

    for (int day0 = 0; day0 < size; ++day0) {
        const int position0 = bulbs[day0] - 1;
        const int right0 = position0 + gap + 1;
        if (right0 < size && opened[right0]
            && state.RangeSum(position0 + 1, right0 - 1) == 0) {
            return day0 + 1;
        }

        const int left0 = position0 - gap - 1;
        if (left0 >= 0 && opened[left0]
            && state.RangeSum(left0 + 1, position0 - 1) == 0) {
            return day0 + 1;
        }

        opened[position0] = true;
        state.Add(position0, 1);
    }
    return -1;
}
```

#### 5. 正确性与复杂度

新形成的合法灯泡对必须包含当天刚打开的 $x$；若两个端点都在更早打开，它们会在第二个端点打开当天被发现。因此只检查与 $x$ 距离 $k+1$ 的两个位置不会遗漏。前缀差为 0 当且仅当内部没有已打开灯泡。

每天常数次前缀查询和一次更新，时间 $O(n\log n)$，空间 $O(n)$。

> **补充：滑动窗口替代。** 也可先构造 `days[position]` 表示每个位置在哪天打开，再用长度 $k+2$ 的窗口检查两端开启天数是否都早于内部最小开启天数，可做到 $O(n)$。原书使用 BIT 是为了从“按天动态开灯”的角度维护当前状态。

### 13.2.4 LeetCode 308：二维区域和检索（可修改）（★★★）

#### 1. 原书方案：矩阵按行展开

问题描述与第 12 章 12.2.2 相同。原书把 $m\times n$ 矩阵按行映射为一维 BIT。使用 1 基 BIT 位置：

$$
\boxed{p(r,c)=rn+c+1,}
$$

其中矩阵行列 $r,c$ 从 0 开始。

#### 2. 单元格更新

BIT 原生支持增量，而 API 要求赋值。保存当前矩阵值，计算

$$
delta=val-matrix[r][c],
$$

再执行

$$
add(p(r,c),delta),
$$

最后更新保存的矩阵值。

#### 3. 子矩阵查询

跨多行矩形在行展开数组中不连续，所以逐行查询。对每一行 $r_1\le r\le r_2$：

$$
rowSum(r)=prefix(p(r,c_2))-prefix(p(r,c_1)-1).
$$

累加：

$$
\boxed{
sumRegion(r_1,c_1,r_2,c_2)
=\sum_{r=r_1}^{r_2}rowSum(r).
}
$$

与第 12 章线段树版本相比，只是底层一维区间和结构换成 BIT。

#### 4. 示例与复杂度

原书矩阵中 `sumRegion(2,1,4,3)=8`。把 `(3,2)` 从 0 更新为 2 后，查询结果变为 10。

构建若逐点加入，时间 $O(mn\log(mn))$；使用展开数组的线性 BIT 构建可降为 $O(mn)$。单点更新 $O(\log(mn))$。若矩形高度为 $h=r_2-r_1+1$，查询时间

$$
O(h\log(mn)).
$$

空间 $O(mn)$。

#### 5. C++17 核心实现

矩阵 API 的 `(row,column)` 已是 0 基。共享类也接收 0 基位置，所以行展开位置直接是 `row*columns+column`；只在 `FenwickTree` 内部再加 1。

```cpp
class NumMatrix {
public:
    explicit NumMatrix(const std::vector<std::vector<int>>& matrix)
        : columns_(matrix.empty() ? 0 : static_cast<int>(matrix[0].size())),
          matrix_(matrix),
          tree_(Flatten(matrix)) {}

    void Update(int row, int column, int value) {
        const long long delta = value - matrix_[row][column];
        matrix_[row][column] = value;
        tree_.Add(Position0(row, column), delta);
    }

    long long SumRegion(
        int row1, int column1, int row2, int column2) const {
        long long answer = 0;
        for (int row = row1; row <= row2; ++row) {
            answer += tree_.RangeSum(
                Position0(row, column1), Position0(row, column2));
        }
        return answer;
    }

private:
    static std::vector<long long> Flatten(
        const std::vector<std::vector<int>>& matrix) {
        std::vector<long long> values;
        for (const auto& row : matrix) {
            values.insert(values.end(), row.begin(), row.end());
        }
        return values;
    }

    int Position0(int row, int column) const {
        return row * columns_ + column;
    }

    int columns_;
    std::vector<std::vector<int>> matrix_;
    FenwickTree tree_;
};
```

> **补充：原生二维 BIT。** 直接使用二维树状数组，可把单点更新和矩形查询都做到 $O(\log m\log n)$，不再逐行扫描。原书采用一维坐标转换，复用了前面的一维 BIT 类，代码更容易与第 12 章方案对照。

## 13.3 离散化在树状数组中的应用

### 13.3.1 LeetCode 327：区间和的个数（★★★）

#### 1. 区间和方程保持不变

定义前缀和

$$
P[0]=0,
\qquad
P[j]=\sum_{t=0}^{j-1}nums[t].
$$

对 $i<j$：

$$
lower\le P[j]-P[i]\le upper
$$

等价于

$$
\boxed{P[j]-upper\le P[i]\le P[j]-lower.}
$$

所以处理当前前缀 $x=P[j]$ 时，需要统计此前前缀落在 `[x-upper,x-lower]` 的频次。

#### 2. 离散化坐标

对每个前缀 $x$ 收集：

$$
x,\qquad x-upper,\qquad x-lower.
$$

排序去重后，令 0 基压缩编号为

$$
rank(v)\in[0,d-1].
$$

BIT 内部必须使用 1 基位置，所以原值 $v$ 存在

$$
\boxed{position(v)=rank(v)+1}
$$

处。

#### 3. 为什么查询是 `Sum(j+1)-Sum(i)`

令

$$
i=rank(x-upper),
\qquad
j=rank(x-lower).
$$

需要压缩闭区间 $[i,j]$ 的频次。BIT 的 `Sum(p)` 返回内部位置 $1\sim p$，也就是压缩编号 $0\sim p-1$ 的频次。因此：

$$
\begin{aligned}
count[i..j]
&=count[0..j]-count[0..i-1]\\
&=\boxed{Sum(j+1)-Sum(i)}.
\end{aligned}
$$

若误写成 `Sum(j)-Sum(i-1)`，就把 0 基编号直接当成 BIT 下标，边界会整体错一位。

#### 4. 扫描顺序

对每个前缀 $x$：

1. 查询上述压缩区间并加入答案；
2. 执行
    $$
    add(rank(x)+1,1).
    $$

仍须先查询、后插入，保证树中只含 $P[0..j-1]$，不把 $i=j$ 的空子数组计入。

#### 5. 数值演算

对

$$
nums=[-2,5,-1],
\qquad lower=-2,
\qquad upper=2,
$$

有

$$
P=[0,-2,3,2].
$$

候选坐标排序去重为

$$
[-4,-2,0,1,2,3,4,5].
$$

依次处理四个前缀时新增计数为 $0,1,0,2$，最终答案 3。

#### 6. 离散化闭边界与 C++17 核心实现

本题收集了每个 $x$、$x-upper$、$x-lower$，所以查询端点一定真实存在于去重坐标中。`lower_bound` 得到 0 基 `left0`、`right0` 后可直接调用

$$
RangeSum(left0,right0)
=PrefixSum(right0)-PrefixSum(left0-1).
$$

若只离散化实际前缀和而没有预先插入查询端点，则闭区间 $[L,R]$ 必须改用

$$
left0=lower\_bound(L),\qquad
right0=upper\_bound(R)-1.
$$

当 `left0>right0` 时频次为 0。不能把右端也写成 `lower_bound(R)-1`，否则恰等于 $R$ 的前缀会被漏掉。

```cpp
long long CountRangeSums(
    const std::vector<int>& nums, long long lower, long long upper) {
    std::vector<long long> prefix_sums = {0};
    for (int value : nums) {
        prefix_sums.push_back(prefix_sums.back() + value);
    }

    std::vector<long long> coordinates;
    coordinates.reserve(3 * prefix_sums.size());
    for (long long value : prefix_sums) {
        coordinates.push_back(value);
        coordinates.push_back(value - upper);
        coordinates.push_back(value - lower);
    }
    std::sort(coordinates.begin(), coordinates.end());
    coordinates.erase(
        std::unique(coordinates.begin(), coordinates.end()),
        coordinates.end());

    const auto Rank0 = [&coordinates](long long value) {
        return static_cast<int>(std::lower_bound(
            coordinates.begin(), coordinates.end(), value)
            - coordinates.begin());
    };

    FenwickTree frequency(static_cast<int>(coordinates.size()));
    long long answer = 0;
    for (long long value : prefix_sums) {
        const int left0 = Rank0(value - upper);
        const int right0 = Rank0(value - lower);
        answer += frequency.RangeSum(left0, right0);
        frequency.Add(Rank0(value), 1);
    }
    return answer;
}
```

#### 7. 正确性与复杂度

离散化保持大小关系，BIT 前缀差准确统计查询闭区间中的历史前缀频次；前缀方程又与目标子数组一一对应，故算法正确。

候选坐标为 $O(n)$ 个，排序 $O(n\log n)$；每个前缀一次查询和更新，各 $O(\log n)$。总时间 $O(n\log n)$，空间 $O(n)$。前缀和与坐标必须使用 64 位整数。

与第 12 章离散化线段树版本相比，状态和扫描顺序完全相同；BIT 用两个前缀查询代替线段树区间查询，代码和常数更小。

### 13.3.2 LeetCode 315：计算右侧小于当前元素的个数（★★★）

#### 1. 从右向左维护后缀频次

把不同值升序离散化为 1 基编号：

$$
x<y\iff rank(x)<rank(y),
\qquad rank(x)\in[1,d].
$$

从右向左处理下标 $j$。在处理 `nums[j]` 前，BIT 中恰保存右侧

$$
nums[j+1..n-1]
$$

的值频次。

令

$$
id=rank(nums[j]).
$$

严格小于它的值对应压缩编号 $1\sim id-1$，所以

$$
\boxed{answer[j]=Sum(id-1).}
$$

随后执行

$$
add(id,1),
$$

把当前值加入供更左位置查询。

#### 2. 重复值为何不会误计

等于当前值的元素都位于同一个编号 $id$。查询只到 $id-1$，因此不会计入相等元素；叶子频次可以累加多个重复值。

原书文字把单点插入放在分情况之前描述。即使先插入当前值，查询 `Sum(id-1)` 也不会包含它；但“先查询、后插入”更直接地维持“树中只含严格右侧元素”的循环不变量。

#### 3. 样例走查

对

$$
nums=[5,2,6,1],
$$

升序不同值为 `[1,2,5,6]`，编号分别为 1、2、3、4。从右向左：

| 当前值 | $id$ | `Sum(id-1)` | 右侧更小数 |
|---:|---:|---:|---:|
| 1 | 1 | 0 | 0 |
| 6 | 4 | 1 | 1 |
| 2 | 2 | 1 | 1 |
| 5 | 3 | 2 | 2 |

按原下标写回得到 `[2,1,1,0]`。

#### 4. C++17 核心实现

不同值排序去重后得到 0 基排名。共享 Fenwick 的外部坐标同样是 0 基，所以 `rank0` 直接用于更新，而严格较小只查询到 `rank0-1`。相等值落在同一 `rank0`，不会进入查询前缀。

```cpp
std::vector<int> CountSmallerOnRight(const std::vector<int>& nums) {
    std::vector<int> coordinates(nums);
    std::sort(coordinates.begin(), coordinates.end());
    coordinates.erase(
        std::unique(coordinates.begin(), coordinates.end()),
        coordinates.end());

    FenwickTree frequency(static_cast<int>(coordinates.size()));
    std::vector<int> answer(nums.size(), 0);
    for (int index = static_cast<int>(nums.size()) - 1;
         index >= 0;
         --index) {
        const int rank0 = static_cast<int>(std::lower_bound(
            coordinates.begin(), coordinates.end(), nums[index])
            - coordinates.begin());
        answer[index] = static_cast<int>(frequency.PrefixSum(rank0 - 1));
        frequency.Add(rank0, 1);
    }
    return answer;
}
```

#### 5. 正确性与复杂度

归纳假设 BIT 频次恰等于当前下标右侧多重集合。离散化保序，所以编号小于 $id$ 当且仅当原值严格小于 `nums[j]`，前缀频次即为答案；插入当前值后，不变量对 $j-1$ 成立。

离散化 $O(n\log n)$，每个元素一次查询和更新，共 $O(n\log n)$；空间 $O(n)$。

> **补充：替代方案。** 第 12 章使用离散化线段树解决同题；也可在归并排序合并阶段统计右侧较小元素。三种方法均为 $O(n\log n)$，BIT 在这里只需前缀频次，最为简洁。

## 推荐练习题

原书在本章末尾列出以下 5 道练习，未在正文中展开解法：

1. LeetCode 307：区域和检索（数组可修改）（★★）
2. LeetCode 406：根据身高重建队列（★★）
3. LeetCode 673：最长递增子序列的个数（★★）
4. LeetCode 1395：统计作战单位数（★★）
5. LeetCode 2250：统计包含每个点的矩形数目（★★）

## 实现索引与易错边界

### 公式、正文 C++ 与附录的对应关系

下表只做定位，不改变原书章节顺序。C++17 实现紧跟对应原理或题目；Python、Go 的同构完整实现分别集中在附录 A、B。

| 编号 | 公式或状态 | 正文 C++17 | Python / Go |
|---|---|---|---|
| B1 | `lowbit`、单点加、$S(r)$、$S(r)-S(l-1)$ | `FenwickTree` | `FenwickTree` |
| B2 | 差分端点 $+x,-x$ | `RangeAddPointQuery` | `RangeAddPointQuery` |
| B3 | $pS(B_1,p)-S(B_2,p)$ | `RangeAddRangeSum` | `RangeAddRangeSum` |
| B4 | 二维前缀和四项容斥 | `FenwickTree2D` | `FenwickTree2D` |
| P1 / HDU 1166 | 1 基输入在边界减 1 | `SolveHdu1166` | `solve_hdu_1166` / `solveHDU1166` |
| P2 / 1649 | 严格小于与严格大于频次 | `CreateSortedArray` | `create_sorted_array` / `createSortedArray` |
| P3 / 1409 | 虚拟位置占用前缀 | `ProcessQueries` | `process_queries` / `processQueries` |
| P4 / 683 | 两端之间打开频次为 0 | `KEmptySlots` | `k_empty_slots` / `kEmptySlots` |
| P5 / 308 | 外部展开位置 $rn+c$ | `NumMatrix` | `NumMatrixMutable` |
| P6 / 327 | 历史前缀落入闭区间 | `CountRangeSums` | `count_range_sums` / `countRangeSums` |
| P7 / 315 | 从右向左查 `rank0-1` | `CountSmallerOnRight` | `count_smaller_on_right` / `countSmallerOnRight` |

### 三条循环不变量

1. `Add(index0,delta)` 中，内部当前 `index1` 的负责区间始终包含原修改位置 `index0+1`；
2. `PrefixSum(right0)` 中，已累加的内部区间互不重叠，并与尚未覆盖的前缀相邻；
3. 值域频次题处理当前元素前，BIT 只包含题目定义的历史部分或右侧部分。

前两条由 `lowbit` 的加减路径保证，第三条由扫描方向与“先查询、后插入”保证。

### 语言实现差异

- 三种语言都把公开坐标定为 0 基，并在 Fenwick 方法入口统一加 1；线性构建直接操作内部 1 基数组。
- Python 整数自动扩展；C++ 前缀、坐标和答案使用 `long long`；Go 使用 `int64`。
- C++ 使用 `sort`、`unique`、`lower_bound`，Go 使用 `sort` 后手动去重，Python 使用 `sorted(set(...))`；三者都把重复值映射到同一 0 基排名。
- 三种语言只对正的内部下标计算 `index & -index`。外部 `PrefixSum(-1)=0` 在转换后直接令内部循环从 0 结束。

### 高频错误清单

| 错误 | 为什么错 | 正确边界 |
|---|---|---|
| 把 `tree[i]` 当成 `a[i]` | 它汇总长度为 `lowbit(i)` 的区间 | 单点值用两个前缀之差 |
| 让内部更新从 0 开始 | `lowbit(0)=0`，循环不前进 | 外部下标进入内部先加 1 |
| 把赋值值当增量 | 旧值没有被移除 | `delta=new-old` |
| 用单个差分 BIT 查原数组区间和 | 其前缀恢复的是原数组单点 | 区间和使用两个 BIT |
| 逆序做线性构建 | 子摘要尚未完成就传给父摘要 | 从小下标向大下标传播 |
| 严格小于查到 `rank0` | 会计入相等值 | 查到 `rank0-1` |
| 0 基排名再次手工加 1 | 公开接口会再加一次 | `rank0` 直接传入共享类 |
| 327 先插入当前前缀 | 会把空子数组纳入候选 | 先查询历史，再插入当前值 |
| 327 用 `lower_bound(R)-1` 作闭右端 | 会漏掉恰等于 $R$ 的值 | `upper_bound(R)-1` |
| 683 把端点计入内部 | 已打开端点使内部频次不可能为 0 | 只查 `[left+1,right-1]` |
| 把行展开当作二维 BIT | 跨行矩形在一维数组中不连续 | 逐行查，或改用原生二维 BIT |
| 把相邻排名当真实距离 1 | 离散化只保序，不保距离 | 涉及长度时保留原坐标差 |
| 1409 只按值域开树 | 没有前置空槽 | 容量为 `queries.size()+m` |
| 用两个前缀恢复一般最小值 | 最小值没有可逆差分 | 改用线段树等结构 |

## 本章总结

### 核心不变量

树状数组的全部基础操作来自内部 1 基区间定义

$$
\boxed{
tree[i]=\sum_{k=i-lowbit(i)+1}^{i}a[k].
}
$$

由此得到方向相反的两条路径：

$$
\begin{aligned}
{\text{查询：}}&\quad i\leftarrow i-lowbit(i),\\
{\text{更新：}}&\quad i\leftarrow i+lowbit(i).
\end{aligned}
$$

查询把前缀拆成互不重叠的二进制块，更新触达所有包含单点的祖先块。公开 0 基接口只负责在边界加 1，不改变这个内部不变量。

### 复杂度总览

| 操作或结构 | 时间 | 总空间 |
|---|---:|---:|
| 单点加、前缀和、闭区间和 | $O(\log n)$ | $O(n)$ |
| 逐点构建 | $O(n\log n)$ | $O(n)$ |
| 线性构建 | $O(n)$ | $O(n)$ |
| 一个差分 BIT：区间加、单点查 | $O(\log n)$ | $O(n)$ |
| 两个 BIT：区间加、区间和 | $O(\log n)$ | $O(n)$ |
| 行展开矩阵查询，高度为 $h$ | $O(h\log(mn))$ | $O(mn)$ |
| 原生二维 BIT | $O(\log m\log n)$ | $O(mn)$ |

### 七道正文题的共同模式

1. **按实际位置维护动态和**：HDU 1166；
2. **按值统计频次**：1649、327、315；
3. **按虚拟位置统计占用**：1409；
4. **按实际位置统计开关状态**：683；
5. **按展开位置维护动态矩阵和**：308。

叶子的语义会变化，但操作始终归结为“单点频次或权值变化 + 前缀累计”。迁移新题时依次检查：查询能否写成前缀差、修改能否写成单点增量、是否需要差分、外部坐标是否要压缩，以及严格/非严格边界落在哪个排名。若聚合不可逆或更新包含复杂覆盖，普通 BIT 就不是合适结构。

## 附录 A：Python 3 完整参考实现

正文只保留 C++17；本附录按相同的 0 基公开接口给出可执行 Python 版本。

```python
from __future__ import annotations

from bisect import bisect_left


class FenwickTree:
    """公开坐标 0 基、内部 tree 1 基的一维 Fenwick。"""

    def __init__(self, size: int):
        if size < 0:
            raise ValueError("size must be non-negative")
        self.size = size
        self.tree = [0] * (size + 1)

    @staticmethod
    def lowbit(index: int) -> int:
        return index & -index

    @classmethod
    def from_values(cls, values: list[int]) -> FenwickTree:
        result = cls(len(values))
        for index1, value in enumerate(values, 1):
            result.tree[index1] += value
            parent1 = index1 + cls.lowbit(index1)
            if parent1 <= result.size:
                result.tree[parent1] += result.tree[index1]
        return result

    def add(self, index0: int, increment: int) -> None:
        if not 0 <= index0 < self.size:
            raise IndexError("FenwickTree.add index")
        index1 = index0 + 1
        while index1 <= self.size:
            self.tree[index1] += increment
            index1 += self.lowbit(index1)

    def prefix_sum(self, right0: int) -> int:
        if right0 < -1 or right0 >= self.size:
            raise IndexError("FenwickTree.prefix_sum index")
        answer = 0
        index1 = right0 + 1
        while index1 > 0:
            answer += self.tree[index1]
            index1 -= self.lowbit(index1)
        return answer

    def range_sum(self, left0: int, right0: int) -> int:
        if left0 > right0:
            return 0
        if left0 < 0 or right0 >= self.size:
            raise IndexError("FenwickTree.range_sum index")
        return self.prefix_sum(right0) - self.prefix_sum(left0 - 1)


class RangeAddPointQuery:
    def __init__(self, size: int):
        self.difference = FenwickTree(size)

    def range_add(self, left0: int, right0: int, increment: int) -> None:
        self.difference.add(left0, increment)
        if right0 + 1 < self.difference.size:
            self.difference.add(right0 + 1, -increment)

    def point_query(self, index0: int) -> int:
        return self.difference.prefix_sum(index0)


class RangeAddRangeSum:
    def __init__(self, size: int):
        self.first = FenwickTree(size)
        self.second = FenwickTree(size)

    def _add_boundary(self, index0: int, increment: int) -> None:
        self.first.add(index0, increment)
        self.second.add(index0, increment * index0)

    def range_add(self, left0: int, right0: int, increment: int) -> None:
        self._add_boundary(left0, increment)
        if right0 + 1 < self.first.size:
            self._add_boundary(right0 + 1, -increment)

    def prefix_sum(self, right0: int) -> int:
        return (right0 + 1) * self.first.prefix_sum(
            right0
        ) - self.second.prefix_sum(right0)

    def range_sum(self, left0: int, right0: int) -> int:
        if left0 > right0:
            return 0
        return self.prefix_sum(right0) - self.prefix_sum(left0 - 1)


class FenwickTree2D:
    def __init__(self, rows: int, columns: int):
        self.rows = rows
        self.columns = columns
        self.tree = [[0] * (columns + 1) for _ in range(rows + 1)]

    def add(self, row0: int, column0: int, increment: int) -> None:
        if not 0 <= row0 < self.rows or not 0 <= column0 < self.columns:
            raise IndexError("FenwickTree2D.add index")
        row1 = row0 + 1
        while row1 <= self.rows:
            column1 = column0 + 1
            while column1 <= self.columns:
                self.tree[row1][column1] += increment
                column1 += FenwickTree.lowbit(column1)
            row1 += FenwickTree.lowbit(row1)

    def prefix_sum(self, row0: int, column0: int) -> int:
        if (
            row0 < -1
            or column0 < -1
            or row0 >= self.rows
            or column0 >= self.columns
        ):
            raise IndexError("FenwickTree2D.prefix_sum index")
        answer = 0
        row1 = row0 + 1
        while row1 > 0:
            column1 = column0 + 1
            while column1 > 0:
                answer += self.tree[row1][column1]
                column1 -= FenwickTree.lowbit(column1)
            row1 -= FenwickTree.lowbit(row1)
        return answer

    def range_sum(
        self, row1: int, column1: int, row2: int, column2: int
    ) -> int:
        if row1 > row2 or column1 > column2:
            return 0
        return (
            self.prefix_sum(row2, column2)
            - self.prefix_sum(row1 - 1, column2)
            - self.prefix_sum(row2, column1 - 1)
            + self.prefix_sum(row1 - 1, column1 - 1)
        )


def solve_hdu_1166(data: str) -> str:
    tokens = iter(data.split())
    test_count = int(next(tokens))
    output: list[str] = []
    for case_index in range(1, test_count + 1):
        size = int(next(tokens))
        values = [int(next(tokens)) for _ in range(size)]
        troops = FenwickTree.from_values(values)
        output.append(f"Case {case_index}:")
        while True:
            command = next(tokens)
            if command == "End":
                break
            first = int(next(tokens))
            second = int(next(tokens))
            if command == "Query":
                output.append(str(troops.range_sum(first - 1, second - 1)))
            elif command == "Add":
                troops.add(first - 1, second)
            elif command == "Sub":
                troops.add(first - 1, -second)
    return "\n".join(output)


def create_sorted_array(instructions: list[int]) -> int:
    if not instructions:
        return 0
    modulo = 1_000_000_007
    frequency = FenwickTree(max(instructions))
    answer = 0
    for inserted_count, value in enumerate(instructions):
        value0 = value - 1
        smaller = frequency.prefix_sum(value0 - 1)
        larger = inserted_count - frequency.prefix_sum(value0)
        answer = (answer + min(smaller, larger)) % modulo
        frequency.add(value0, 1)
    return answer


def process_queries(queries: list[int], maximum_value: int) -> list[int]:
    query_count = len(queries)
    occupied = FenwickTree(query_count + maximum_value)
    positions = [0] * (maximum_value + 1)
    for value in range(1, maximum_value + 1):
        positions[value] = query_count + value - 1
        occupied.add(positions[value], 1)

    answer: list[int] = []
    for query_index, value in enumerate(queries):
        old_position = positions[value]
        answer.append(occupied.prefix_sum(old_position) - 1)
        occupied.add(old_position, -1)
        new_position = query_count - 1 - query_index
        positions[value] = new_position
        occupied.add(new_position, 1)
    return answer


def k_empty_slots(bulbs: list[int], gap: int) -> int:
    size = len(bulbs)
    opened = [False] * size
    state = FenwickTree(size)

    for day0, position in enumerate(bulbs):
        position0 = position - 1
        right0 = position0 + gap + 1
        if (
            right0 < size
            and opened[right0]
            and state.range_sum(position0 + 1, right0 - 1) == 0
        ):
            return day0 + 1

        left0 = position0 - gap - 1
        if (
            left0 >= 0
            and opened[left0]
            and state.range_sum(left0 + 1, position0 - 1) == 0
        ):
            return day0 + 1

        opened[position0] = True
        state.add(position0, 1)
    return -1


class NumMatrixMutable:
    def __init__(self, matrix: list[list[int]]):
        self.rows = len(matrix)
        self.columns = len(matrix[0]) if matrix else 0
        self.matrix = [row[:] for row in matrix]
        flattened = [value for row in matrix for value in row]
        self.tree = FenwickTree.from_values(flattened)

    def _position(self, row: int, column: int) -> int:
        return row * self.columns + column

    def update(self, row: int, column: int, value: int) -> None:
        increment = value - self.matrix[row][column]
        self.matrix[row][column] = value
        self.tree.add(self._position(row, column), increment)

    def sum_region(
        self, row1: int, column1: int, row2: int, column2: int
    ) -> int:
        answer = 0
        for row in range(row1, row2 + 1):
            answer += self.tree.range_sum(
                self._position(row, column1),
                self._position(row, column2),
            )
        return answer


def count_range_sums(nums: list[int], lower: int, upper: int) -> int:
    prefix_sums = [0]
    for value in nums:
        prefix_sums.append(prefix_sums[-1] + value)

    coordinates = sorted(
        {
            coordinate
            for value in prefix_sums
            for coordinate in (value, value - upper, value - lower)
        }
    )
    frequency = FenwickTree(len(coordinates))
    answer = 0
    for value in prefix_sums:
        left0 = bisect_left(coordinates, value - upper)
        right0 = bisect_left(coordinates, value - lower)
        answer += frequency.range_sum(left0, right0)
        frequency.add(bisect_left(coordinates, value), 1)
    return answer


def count_smaller_on_right(nums: list[int]) -> list[int]:
    coordinates = sorted(set(nums))
    frequency = FenwickTree(len(coordinates))
    answer = [0] * len(nums)
    for index in range(len(nums) - 1, -1, -1):
        rank0 = bisect_left(coordinates, nums[index])
        answer[index] = frequency.prefix_sum(rank0 - 1)
        frequency.add(rank0, 1)
    return answer


if __name__ == "__main__":
    basic = FenwickTree.from_values([1, 2, 3, 4, 5, 6, 7, 8])
    prefix_seven = basic.prefix_sum(6)
    range_three_six = basic.range_sum(2, 5)
    basic.add(4, 10)
    print([prefix_seven, range_three_six, basic.prefix_sum(7)])

    difference = RangeAddPointQuery(8)
    difference.range_add(1, 4, 3)
    print([difference.point_query(index) for index in range(8)])

    dual = RangeAddRangeSum(8)
    dual.range_add(1, 4, 3)
    dual.range_add(3, 6, 2)
    assert dual.range_sum(0, 7) == 20
    assert dual.range_sum(3, 4) == 10

    plane = FenwickTree2D(2, 3)
    for row, values in enumerate([[1, 2, 3], [4, 5, 6]]):
        for column, value in enumerate(values):
            plane.add(row, column, value)
    assert plane.range_sum(0, 1, 1, 2) == 16

    hdu_output = solve_hdu_1166(
        "1 5 1 2 3 4 5 "
        "Query 1 3 Add 2 3 Query 1 3 Sub 3 1 Query 2 5 End"
    )
    assert hdu_output == "Case 1:\n6\n9\n16"

    print(create_sorted_array([1, 2, 3, 6, 5, 4]))
    print(process_queries([3, 1, 2, 1], 5))
    print(k_empty_slots([1, 3, 2], 1))

    matrix = NumMatrixMutable(
        [
            [3, 0, 1, 4, 2],
            [5, 6, 3, 2, 1],
            [1, 2, 0, 1, 5],
            [4, 1, 0, 1, 7],
            [1, 0, 3, 0, 5],
        ]
    )
    before = matrix.sum_region(2, 1, 4, 3)
    matrix.update(3, 2, 2)
    print([before, matrix.sum_region(2, 1, 4, 3)])

    print(count_range_sums([-2, 5, -1], -2, 2))
    print(count_smaller_on_right([5, 2, 6, 1]))
```

示例输出：

```text
[28, 18, 46]
[0, 3, 3, 3, 3, 0, 0, 0]
3
[2, 1, 2, 1]
2
[8, 10]
3
[2, 1, 1, 0]
```

## 附录 B：Go 1.22 完整参考实现

本附录与正文使用同一套 0 基公开坐标，并保留可独立静态检查的完整 Go 程序。

```go
package main

import (
    "fmt"
    "sort"
    "strings"
)

type FenwickTree struct {
    size int
    tree []int64
}

func newFenwickTree(size int) *FenwickTree {
    return &FenwickTree{
        size: size,
        tree: make([]int64, size+1),
    }
}

func fenwickFromValues(values []int64) *FenwickTree {
    result := newFenwickTree(len(values))
    for index, value := range values {
        index1 := index + 1
        result.tree[index1] += value
        parent1 := index1 + lowbit(index1)
        if parent1 <= result.size {
            result.tree[parent1] += result.tree[index1]
        }
    }
    return result
}

func lowbit(index int) int {
    return index & -index
}

func (sets *FenwickTree) add(index0 int, increment int64) {
    if index0 < 0 || index0 >= sets.size {
        panic("FenwickTree.add index")
    }
    for index1 := index0 + 1; index1 <= sets.size; index1 += lowbit(index1) {
        sets.tree[index1] += increment
    }
}

func (sets *FenwickTree) prefixSum(right0 int) int64 {
    if right0 < -1 || right0 >= sets.size {
        panic("FenwickTree.prefixSum index")
    }
    answer := int64(0)
    for index1 := right0 + 1; index1 > 0; index1 -= lowbit(index1) {
        answer += sets.tree[index1]
    }
    return answer
}

func (sets *FenwickTree) rangeSum(left0, right0 int) int64 {
    if left0 > right0 {
        return 0
    }
    if left0 < 0 || right0 >= sets.size {
        panic("FenwickTree.rangeSum index")
    }
    return sets.prefixSum(right0) - sets.prefixSum(left0-1)
}

type RangeAddPointQuery struct {
    difference *FenwickTree
}

func newRangeAddPointQuery(size int) *RangeAddPointQuery {
    return &RangeAddPointQuery{difference: newFenwickTree(size)}
}

func (sets *RangeAddPointQuery) rangeAdd(
    left0, right0 int,
    increment int64,
) {
    sets.difference.add(left0, increment)
    if right0+1 < sets.difference.size {
        sets.difference.add(right0+1, -increment)
    }
}

func (sets *RangeAddPointQuery) pointQuery(index0 int) int64 {
    return sets.difference.prefixSum(index0)
}

type RangeAddRangeSum struct {
    first  *FenwickTree
    second *FenwickTree
}

func newRangeAddRangeSum(size int) *RangeAddRangeSum {
    return &RangeAddRangeSum{
        first:  newFenwickTree(size),
        second: newFenwickTree(size),
    }
}

func (sets *RangeAddRangeSum) addBoundary(index0 int, increment int64) {
    sets.first.add(index0, increment)
    sets.second.add(index0, increment*int64(index0))
}

func (sets *RangeAddRangeSum) rangeAdd(
    left0, right0 int,
    increment int64,
) {
    sets.addBoundary(left0, increment)
    if right0+1 < sets.first.size {
        sets.addBoundary(right0+1, -increment)
    }
}

func (sets *RangeAddRangeSum) prefixSum(right0 int) int64 {
    return int64(right0+1)*sets.first.prefixSum(right0) -
        sets.second.prefixSum(right0)
}

func (sets *RangeAddRangeSum) rangeSum(left0, right0 int) int64 {
    if left0 > right0 {
        return 0
    }
    return sets.prefixSum(right0) - sets.prefixSum(left0-1)
}

type FenwickTree2D struct {
    rows    int
    columns int
    tree    [][]int64
}

func newFenwickTree2D(rows, columns int) *FenwickTree2D {
    tree := make([][]int64, rows+1)
    for row := range tree {
        tree[row] = make([]int64, columns+1)
    }
    return &FenwickTree2D{rows: rows, columns: columns, tree: tree}
}

func (sets *FenwickTree2D) add(row0, column0 int, increment int64) {
    if row0 < 0 || row0 >= sets.rows || column0 < 0 || column0 >= sets.columns {
        panic("FenwickTree2D.add index")
    }
    for row1 := row0 + 1; row1 <= sets.rows; row1 += lowbit(row1) {
        for column1 := column0 + 1;
            column1 <= sets.columns;
            column1 += lowbit(column1) {
            sets.tree[row1][column1] += increment
        }
    }
}

func (sets *FenwickTree2D) prefixSum(row0, column0 int) int64 {
    if row0 < -1 || row0 >= sets.rows || column0 < -1 || column0 >= sets.columns {
        panic("FenwickTree2D.prefixSum index")
    }
    answer := int64(0)
    for row1 := row0 + 1; row1 > 0; row1 -= lowbit(row1) {
        for column1 := column0 + 1; column1 > 0; column1 -= lowbit(column1) {
            answer += sets.tree[row1][column1]
        }
    }
    return answer
}

func (sets *FenwickTree2D) rangeSum(
    row1, column1, row2, column2 int,
) int64 {
    if row1 > row2 || column1 > column2 {
        return 0
    }
    return sets.prefixSum(row2, column2) -
        sets.prefixSum(row1-1, column2) -
        sets.prefixSum(row2, column1-1) +
        sets.prefixSum(row1-1, column1-1)
}

func solveHDU1166(data string) string {
    reader := strings.NewReader(data)
    testCount := 0
    fmt.Fscan(reader, &testCount)
    var output strings.Builder

    for caseIndex := 1; caseIndex <= testCount; caseIndex++ {
        size := 0
        fmt.Fscan(reader, &size)
        values := make([]int64, size)
        for index := range values {
            fmt.Fscan(reader, &values[index])
        }
        troops := fenwickFromValues(values)
        fmt.Fprintf(&output, "Case %d:\n", caseIndex)

        for {
            command := ""
            fmt.Fscan(reader, &command)
            if command == "End" {
                break
            }
            first, second := 0, 0
            fmt.Fscan(reader, &first, &second)
            switch command {
            case "Query":
                fmt.Fprintln(&output, troops.rangeSum(first-1, second-1))
            case "Add":
                troops.add(first-1, int64(second))
            case "Sub":
                troops.add(first-1, -int64(second))
            }
        }
    }
    return strings.TrimSuffix(output.String(), "\n")
}

func createSortedArray(instructions []int) int {
    if len(instructions) == 0 {
        return 0
    }
    const modulo int64 = 1_000_000_007
    maximum := instructions[0]
    for _, value := range instructions[1:] {
        if value > maximum {
            maximum = value
        }
    }
    frequency := newFenwickTree(maximum)
    answer := int64(0)
    for inserted, value := range instructions {
        value0 := value - 1
        smaller := frequency.prefixSum(value0 - 1)
        larger := int64(inserted) - frequency.prefixSum(value0)
        if smaller < larger {
            answer += smaller
        } else {
            answer += larger
        }
        answer %= modulo
        frequency.add(value0, 1)
    }
    return int(answer)
}

func processQueries(queries []int, maximumValue int) []int64 {
    queryCount := len(queries)
    occupied := newFenwickTree(queryCount + maximumValue)
    positions := make([]int, maximumValue+1)
    for value := 1; value <= maximumValue; value++ {
        positions[value] = queryCount + value - 1
        occupied.add(positions[value], 1)
    }

    answer := make([]int64, 0, queryCount)
    for queryIndex, value := range queries {
        oldPosition := positions[value]
        answer = append(answer, occupied.prefixSum(oldPosition)-1)
        occupied.add(oldPosition, -1)
        newPosition := queryCount - 1 - queryIndex
        positions[value] = newPosition
        occupied.add(newPosition, 1)
    }
    return answer
}

func kEmptySlots(bulbs []int, gap int) int {
    size := len(bulbs)
    opened := make([]bool, size)
    state := newFenwickTree(size)
    for index, position := range bulbs {
        day := index + 1
        position0 := position - 1
        right0 := position0 + gap + 1
        if right0 < size && opened[right0] &&
            state.rangeSum(position0+1, right0-1) == 0 {
            return day
        }
        left0 := position0 - gap - 1
        if left0 >= 0 && opened[left0] &&
            state.rangeSum(left0+1, position0-1) == 0 {
            return day
        }
        opened[position0] = true
        state.add(position0, 1)
    }
    return -1
}

type NumMatrixMutable struct {
    rows    int
    columns int
    matrix  [][]int64
    tree    *FenwickTree
}

func newNumMatrixMutable(matrix [][]int64) *NumMatrixMutable {
    rows, columns := len(matrix), len(matrix[0])
    copyMatrix := make([][]int64, rows)
    flattened := make([]int64, 0, rows*columns)
    for row := range matrix {
        copyMatrix[row] = append([]int64(nil), matrix[row]...)
        flattened = append(flattened, matrix[row]...)
    }
    return &NumMatrixMutable{
        rows:    rows,
        columns: columns,
        matrix:  copyMatrix,
        tree:    fenwickFromValues(flattened),
    }
}

func (matrix *NumMatrixMutable) position(row, column int) int {
    return row*matrix.columns + column
}

func (matrix *NumMatrixMutable) update(row, column int, value int64) {
    increment := value - matrix.matrix[row][column]
    matrix.matrix[row][column] = value
    matrix.tree.add(matrix.position(row, column), increment)
}

func (matrix *NumMatrixMutable) sumRegion(
    row1, column1, row2, column2 int,
) int64 {
    answer := int64(0)
    for row := row1; row <= row2; row++ {
        answer += matrix.tree.rangeSum(
            matrix.position(row, column1),
            matrix.position(row, column2),
        )
    }
    return answer
}

func countRangeSums(nums []int, lower, upper int64) int64 {
    prefixSums := []int64{0}
    for _, value := range nums {
        prefixSums = append(prefixSums, prefixSums[len(prefixSums)-1]+int64(value))
    }
    coordinates := make([]int64, 0, 3*len(prefixSums))
    for _, value := range prefixSums {
        coordinates = append(coordinates, value, value-upper, value-lower)
    }
    sort.Slice(coordinates, func(first, second int) bool {
        return coordinates[first] < coordinates[second]
    })
    unique := coordinates[:0]
    for _, value := range coordinates {
        if len(unique) == 0 || unique[len(unique)-1] != value {
            unique = append(unique, value)
        }
    }
    position := make(map[int64]int, len(unique))
    for index, value := range unique {
        position[value] = index
    }

    frequency := newFenwickTree(len(unique))
    answer := int64(0)
    for _, value := range prefixSums {
        answer += frequency.rangeSum(
            position[value-upper], position[value-lower],
        )
        frequency.add(position[value], 1)
    }
    return answer
}

func countSmallerOnRight(nums []int) []int64 {
    coordinates := append([]int(nil), nums...)
    sort.Ints(coordinates)
    unique := coordinates[:0]
    for _, value := range coordinates {
        if len(unique) == 0 || unique[len(unique)-1] != value {
            unique = append(unique, value)
        }
    }
    position := make(map[int]int, len(unique))
    for index, value := range unique {
        position[value] = index
    }

    frequency := newFenwickTree(len(unique))
    answer := make([]int64, len(nums))
    for index := len(nums) - 1; index >= 0; index-- {
        rank := position[nums[index]]
        answer[index] = frequency.prefixSum(rank - 1)
        frequency.add(rank, 1)
    }
    return answer
}

func main() {
    basic := fenwickFromValues([]int64{1, 2, 3, 4, 5, 6, 7, 8})
    prefixSeven := basic.prefixSum(6)
    rangeThreeSix := basic.rangeSum(2, 5)
    basic.add(4, 10)
    fmt.Println([]int64{prefixSeven, rangeThreeSix, basic.prefixSum(7)})

    difference := newRangeAddPointQuery(8)
    difference.rangeAdd(1, 4, 3)
    points := make([]int64, 8)
    for index := range points {
        points[index] = difference.pointQuery(index)
    }
    fmt.Println(points)

    dual := newRangeAddRangeSum(8)
    dual.rangeAdd(1, 4, 3)
    dual.rangeAdd(3, 6, 2)
    if dual.rangeSum(0, 7) != 20 || dual.rangeSum(3, 4) != 10 {
        panic("RangeAddRangeSum validation failed")
    }

    plane := newFenwickTree2D(2, 3)
    planeValues := [][]int64{{1, 2, 3}, {4, 5, 6}}
    for row, values := range planeValues {
        for column, value := range values {
            plane.add(row, column, value)
        }
    }
    if plane.rangeSum(0, 1, 1, 2) != 16 {
        panic("FenwickTree2D validation failed")
    }

    hduOutput := solveHDU1166(
        "1 5 1 2 3 4 5 " +
            "Query 1 3 Add 2 3 Query 1 3 Sub 3 1 Query 2 5 End",
    )
    if hduOutput != "Case 1:\n6\n9\n16" {
        panic("solveHDU1166 validation failed")
    }

    fmt.Println(createSortedArray([]int{1, 2, 3, 6, 5, 4}))
    fmt.Println(processQueries([]int{3, 1, 2, 1}, 5))
    fmt.Println(kEmptySlots([]int{1, 3, 2}, 1))

    matrix := newNumMatrixMutable([][]int64{
        {3, 0, 1, 4, 2},
        {5, 6, 3, 2, 1},
        {1, 2, 0, 1, 5},
        {4, 1, 0, 1, 7},
        {1, 0, 3, 0, 5},
    })
    before := matrix.sumRegion(2, 1, 4, 3)
    matrix.update(3, 2, 2)
    fmt.Println([]int64{before, matrix.sumRegion(2, 1, 4, 3)})

    fmt.Println(countRangeSums([]int{-2, 5, -1}, -2, 2))
    fmt.Println(countSmallerOnRight([]int{5, 2, 6, 1}))
}
```

示例输出（Go 使用切片的原生空格分隔格式）：

```text
[28 18 46]
[0 3 3 3 3 0 0 0]
3
[2 1 2 1]
2
[8 10]
3
[2 1 1 0]
```
