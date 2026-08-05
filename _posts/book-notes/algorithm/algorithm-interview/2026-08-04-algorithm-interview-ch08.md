---
title: "《算法面试（全二册）》第 8 章“平衡二叉树”读书笔记"
date: 2026-08-03 02:08:00 +0800
updated: 2026-08-04
uid: algorithm-interview-ch08
type: reading
content_lang: zh-CN
status: growing
topics: [algorithms, books]
series: algorithm-interview
series_order: 9
related: [algorithm-interview-ch07, algorithm-interview-ch09]
categories: [读书笔记, 算法, 算法面试]
tags: [algorithms, data-structures, coding-interviews, reading-notes]
description: "围绕「《算法面试（全二册）》第 8 章“平衡二叉树”读书笔记」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
render_with_liquid: false
math: true
mermaid: true
---

> 原书：李春葆、李筱驰《算法面试（全二册）》<br>
> 阅读范围：第 8 章 平衡二叉树<br>
> 说明：本文按原书 8.1～8.4 顺序整理；“补充”用于推导和替代方案，原文误粘或接口风险标为“勘误说明”。

## 0. 本章主线

```mermaid
flowchart TD
    A[BST可能退化] --> B[维持高度O(log n)]
    B --> C[AVL旋转/红黑等弱平衡]
    B --> D[有序集合]
    B --> E[有序映射]
    D --> F[排名/第k值/区间选择]
    E --> G[有序计数/时间检索/多索引系统]
```

本章有 10 道正文题：8.2 三题、8.3 四题、8.4 三题。

## 8.1 平衡二叉树概述

### 8.1.1 平衡二叉树的定义

广义上，含 $n$ 个结点且高度 $h=O(\log n)$ 的 BST 称为平衡 BST，于是沿根到叶路径的搜索、插入、删除为 $O(\log n)$。AVL、红黑树、Treap、Splay、SBT 用不同不变量约束高度或均摊代价。

AVL 对每个结点 $u$ 定义平衡因子

$$
BF(u)=height(u.left)-height(u.right),
$$

并要求

$$
|BF(u)|\le1.
$$

这是局部条件，却递归约束整树。插入或删除先按 BST 更新，再沿祖先路径更新高度；发现 $|BF|>1$ 时旋转恢复平衡。

#### 补充：AVL 高度为何是 $O(\log n)$

设高为 $h$ 的 AVL 最少结点数为 $N(h)$，取空树高 0、单结点高 1。要让高度为 $h$ 且结点最少，两子树高度应为 $h-1$ 与 $h-2$：

$$
N(0)=0,\quad N(1)=1,
$$

$$
N(h)=1+N(h-1)+N(h-2).
$$

取 Fibonacci 数列约定为

$$
F_0=0,\quad F_1=1,\quad F_k=F_{k-1}+F_{k-2}.
$$

下面归纳证明

$$
N(h)=F_{h+2}-1.
$$

基例 $h=0$ 时，$F_2-1=1-1=0=N(0)$；$h=1$ 时，$F_3-1=2-1=1=N(1)$。假设结论对 $h-1$ 与 $h-2$ 成立，则

$$
\begin{aligned}
N(h)
&=1+N(h-1)+N(h-2)\\
&=1+(F_{h+1}-1)+(F_h-1)\\
&=F_{h+2}-1.
\end{aligned}
$$

故结论对所有 $h\ge0$ 成立。Fibonacci 数按指数增长，$F_k=\Theta(\varphi^k)$，其中

$$
\varphi=\frac{1+\sqrt5}{2}>1.
$$

若一棵 AVL 有 $n$ 个结点、高度为 $h$，它至少含 $N(h)$ 个结点，所以

$$
n\ge N(h)=F_{h+2}-1=\Omega(\varphi^h).
$$

于是存在正常数 $C$ 使

$$
h\le\log_\varphi(C(n+1))=O(\log n).
$$

#### 旋转为何保持 BST 次序

右旋局部结构设为：$y$ 的左孩子 $x$，$x$ 的右子树为 $T_2$。旋转后 $x$ 为根、$y$ 为右孩子、$T_2$ 成为 $y$ 左子树。旋转前后中序均为

$$
T_1,x,T_2,y,T_3,
$$

故键顺序不变。左旋完全对称。

失衡分四型：

- LL：结点左高，插入在左孩子左侧，单次右旋；
- RR：右高且插入在右孩子右侧，单次左旋；
- LR：先对左孩子左旋，再对失衡结点右旋；
- RL：先对右孩子右旋，再对失衡结点左旋。

旋转只改常数条指针，但必须按“孩子先更新、旧根后更新”的顺序重新计算高度。

### 8.1.2 平衡二叉树的知识点

有序集合存唯一键；有序映射存唯一键到值；`multiset/multimap`允许重复键。与哈希表相比，它们牺牲平均 $O(1)$ 查找，换取 $O(\log n)$ 的最坏/保证级操作（取决于接口规范）以及按键遍历、最小/最大、`lower_bound/upper_bound` 等顺序能力。

C++ `set/map`常见实现为红黑树，但标准主要规定接口与复杂度，不强制某种树。比较器必须形成严格弱序；改变已在集合中的排序字段会破坏结构，应删除旧记录后插入新记录。

Python 标准库没有树集合/映射。第三方 `sortedcontainers`提供 `SortedList/SortedSet/SortedDict`，其实现是分块有序列表等结构，不是原书所说的平衡树；它提供近似对数查找和高效更新，具体复杂度应以版本文档为准。Go 标准库也没有有序映射，工程中可用排序切片、堆、第三方树或自建平衡树。

插入 `[30,20,10]` 时，30 首次失衡且新键落在左孩子 20 的左侧，是 LL 型；右旋后根为 20。插入 `[30,10,20]` 时，新键落在左孩子 10 的右侧，是 LR 型；先把 10 左旋到 20，再把 30 右旋，根同样为 20。这个对照能防止只凭“左边高”就误判为单旋。

**迁移判断：** 插入修复可用新键与孩子键的关系判断 LL/LR/RR/RL；删除后失衡却不能这样做，因为触发失衡的键可能已经消失，必须直接比较两个孩子的平衡因子。

#### C++17 共享定义

正文后续 C++17 片段默认复用这里的标准库头文件、`TreeNode` 与 `ListNode`，不再重复定义。紧随其后的补充 AVL 实现也复用这些头文件，但使用独立的 `AVLNode`，不改变正文构造题约定的 `TreeNode`。

```cpp
#include <algorithm>
#include <cstddef>
#include <functional>
#include <iterator>
#include <map>
#include <set>
#include <string>
#include <tuple>
#include <unordered_map>
#include <utility>
#include <vector>

struct TreeNode {
    int val;
    TreeNode* left = nullptr;
    TreeNode* right = nullptr;

    explicit TreeNode(int value) : val(value) {}
};

struct ListNode {
    int val;
    ListNode* next = nullptr;

    explicit ListNode(int value, ListNode* successor = nullptr)
        : val(value), next(successor) {}
};
```

#### 补充（书外）：完整 AVL 插入的 C++17 实现

以下完整插入实现用于闭合前述“BST 插入、更新高度、按四型旋转”的推导，不是原书在此处给出的逐行程序。它只演示动态 AVL 边界；本节此前仍按原书顺序介绍平衡树与有序容器，8.2 起继续原书的构造题顺序。

```cpp

struct AVLNode {
    int key;
    int height = 1;
    AVLNode* left = nullptr;
    AVLNode* right = nullptr;

    explicit AVLNode(int value) : key(value) {}
};

int avlHeight(AVLNode* node) {
    return node == nullptr ? 0 : node->height;
}

void updateHeight(AVLNode* node) {
    node->height = 1 + std::max(avlHeight(node->left), avlHeight(node->right));
}

AVLNode* rotateRight(AVLNode* root) {
    AVLNode* nextRoot = root->left;
    root->left = nextRoot->right;
    nextRoot->right = root;
    updateHeight(root);      // 旧根先降到下一层
    updateHeight(nextRoot);  // 新根再读取旧根的新高度
    return nextRoot;
}

AVLNode* rotateLeft(AVLNode* root) {
    AVLNode* nextRoot = root->right;
    root->right = nextRoot->left;
    nextRoot->left = root;
    updateHeight(root);
    updateHeight(nextRoot);
    return nextRoot;
}

AVLNode* avlInsert(AVLNode* root, int key) {
    if (root == nullptr) return new AVLNode(key);
    if (key < root->key) root->left = avlInsert(root->left, key);
    else if (key > root->key) root->right = avlInsert(root->right, key);
    else return root;

    updateHeight(root);
    int balance = avlHeight(root->left) - avlHeight(root->right);
    if (balance > 1) {
        if (key > root->left->key) root->left = rotateLeft(root->left); // LR
        return rotateRight(root);                                      // LL/LR
    }
    if (balance < -1) {
        if (key < root->right->key) root->right = rotateRight(root->right); // RL
        return rotateLeft(root);                                           // RR/RL
    }
    return root;
}
```

#### 补充：旋转与高度维护的常见误区

- 先改指针、再算高度。旋转后旧根先降为孩子，应先更新旧根，再更新读取其高度的新根；若在重连前计算，或只更新新根，缓存高度会与结构不一致。
- 递归插入返回的是该子树旋转后的新根，父结点必须写回 `root->left/right = avlInsert(...)`，最外层调用者也必须接住返回值；忽略返回值会把新根与上层断开。
- 插入时可用新键落在重孩子的哪一侧区分 LL/LR/RR/RL；删除时触发失衡的键已经离树，必须查看重孩子自身的平衡因子，不能照搬插入判型。

到此书外 AVL 实现补充结束，下面回到原书 8.2～8.4 的容器与题目顺序。

## 8.2 构造平衡二叉树的算法设计

### 8.2.1 LeetCode 108：有序数组转平衡 BST（★）

#### 问题与方法选择

输入已经严格递增，因此它天然就是目标 BST 的中序序列。若依次按原顺序插入，树会退化成全右链；要控制高度，根应把区间尽量均分，所以选择中点。

对严格递增区间 $a[L..R]$ 选中点

$$
M=L+\left\lfloor\frac{R-L}{2}\right\rfloor
$$

作根，递归构造左右半区。更适合代码的左闭右开写法是 $[L,R)$，终止条件 $L\ge R$，中点

$$
M=L+\left\lfloor\frac{R-L}{2}\right\rfloor.
$$

#### 数值走查

对 `[-9,-3,0,5,8]`，首根取下标 2 的 0；左区 `[-9,-3]` 可取 -3 为根、-9 为左孩子；右区 `[5,8]` 可取 8 为根、5 为左孩子。另一种中点取法也可能得到不同但合法的平衡树。

#### 正确性与平衡证明

中序遍历递归结果依次为左半区、中点、右半区，正好恢复原递增数组，所以满足 BST 性质。

对区间长度归纳。左右元素数相差至多 1；递归得到的两棵树都是对各自规模尽量均分的平衡树，其高度最多相差 1，因此当前根也满足 AVL 条件。更严格地，两侧规模分别为 $\lfloor(n-1)/2\rfloor$ 与 $\lceil(n-1)/2\rceil$，高度都为 $\Theta(\log n)$。

时间 $O(n)$，每个元素创建一次；递归栈 $O(\log n)$，输出结点 $O(n)$。左右中点都可，答案不唯一。

> **勘误说明：** 原书 8.2.1 思路误粘了“给定先序、排序得到中序”的表述。本题只有有序数组，正确方法就是中点递归。

#### C++17 核心实现

```cpp
TreeNode* sortedArrayToBST(const std::vector<int>& values) {
    auto build = [&](auto&& self, int left, int right) -> TreeNode* {
        if (left >= right) return nullptr;
        int middle = left + (right - left) / 2;
        auto* root = new TreeNode(values[middle]);
        root->left = self(self, left, middle);
        root->right = self(self, middle + 1, right);
        return root;
    };

    return build(build, 0, static_cast<int>(values.size()));
}
```

### 8.2.2 LeetCode 109：有序链表转平衡 BST（★★）

#### 原书方案：先转数组

链表不能 $O(1)$ 随机访问中点。原书先顺序复制到数组，再应用 8.2.1 的中点递归：遍历链表 $O(n)$、建树 $O(n)$，额外数组 $O(n)$，逻辑最简单。

若每层都用快慢指针重新找链表中点，平衡递归各层总扫描量约为 $n$，共有 $O(\log n)$ 层，总时间 $O(n\log n)$；还要小心切断链表和恢复边界。

#### 补充：模拟中序构造

先求链长 $n$，维护全局游标 `current`。函数 `build(size)`：

1. 递归构造大小 $\lfloor size/2\rfloor$ 的左子树；
2. 用 `current.val` 创建根，并令 `current=current.next`；
3. 构造剩余 $size-\lfloor size/2\rfloor-1$ 个结点的右子树。

不变量是：进入 `build(size)` 时，`current` 指向该子树中序序列的第一个值；左递归返回后，游标恰指向中间根；整个函数返回后，游标指向该子树最后值的后继。因为链表本身就是中序序列，所以只需单向读取。

每个链结点只读取一次，时间 $O(n)$；除输出外只有递归栈 $O(\log n)$，优于数组方案的 $O(n)$ 辅助存储。实现依赖链表在构造期间不被并发修改。

对 `[-10,-3,0,5,9]` 调用 `build(5)`：左递归先消费 -10、-3，游标随后指向 0，于是 0 成为根；右递归再消费 5、9。若先创建根再递归左侧，首个 -10 会被误放到根位置，这正是游标法最常见的次序错误。

#### C++17 核心实现

```cpp
TreeNode* sortedListToBST(ListNode* head) {
    int size = 0;
    for (ListNode* node = head; node != nullptr; node = node->next) ++size;

    ListNode* current = head;
    auto build = [&](auto&& self, int count) -> TreeNode* {
        if (count == 0) return nullptr;
        int leftSize = count / 2;
        TreeNode* left = self(self, leftSize);
        auto* root = new TreeNode(current->val);
        current = current->next;
        root->left = left;
        root->right = self(self, count - leftSize - 1);
        return root;
    };

    return build(build, size);
}
```

### 8.2.3 LeetCode 1382：普通 BST 转平衡 BST（★★）

#### 原书的“展平再重建”

普通 BST 可能退化，但其中序仍严格递增。先中序得到值数组，再按中点递归：中序访问 $O(n)$、重建 $O(n)$，总时间 $O(n)$、数组 $O(n)$、递归栈最坏由原树中序阶段决定，斜树可达 $O(n)$。

正确性分两部分：中序数组含原树全部且仅有的键；中点重建的中序仍是该数组且满足高度平衡。因此新树与旧树键集合相同，并成为平衡 BST。

#### 结点身份与替代方案

题目只要求值集合相同，可以创建新结点；外部若持有旧结点引用，这些引用不会指向新树中的对象。

- 要复用结点：中序保存结点指针数组，递归重置每个结点的左右指针；
- **补充 DSW 算法：** 先通过右旋把树变成“藤蔓”右链，再按完全树规模执行若干轮左旋压缩，原地 $O(n)$ 时间、$O(1)$ 额外指针空间；
- 使用 AVL/红黑树逐个插入：$O(n\log n)$，适合需要同时构造动态平衡结构但不是本题最优静态方案。

DSW 实现复杂，若没有严格原地约束，数组中序重建更容易验证。

#### C++17 核心实现

```cpp
TreeNode* balanceBST(TreeNode* root) {
    std::vector<int> values;
    auto collect = [&](auto&& self, TreeNode* node) -> void {
        if (node == nullptr) return;
        self(self, node->left);
        values.push_back(node->val);
        self(self, node->right);
    };
    collect(collect, root);

    auto build = [&](auto&& self, int left, int right) -> TreeNode* {
        if (left >= right) return nullptr;
        int middle = left + (right - left) / 2;
        auto* node = new TreeNode(values[middle]);
        node->left = self(self, left, middle);
        node->right = self(self, middle + 1, right);
        return node;
    };
    return build(build, 0, static_cast<int>(values.size()));
}
```

## 8.3 平衡树集合应用的算法设计

### 8.3.1 LeetCode 506：相对名次（★）

#### 从成绩顺序写回原位置

答案按运动员原下标排列，但名次按成绩降序决定，所以记录必须同时携带 `score` 与 `index`。把复合键 `(-score,index)`放入升序结构，遍历第 $r$ 项就是第 $r+1$ 名，再写入 `answer[index]`。

样例成绩 `[10,3,8,9,4]` 排序后是 `(10,0),(9,3),(8,2),(4,4),(3,1)`，依次写回得到：

```text
[Gold Medal, 5, Bronze Medal, Silver Medal, 4]
```

成绩互异，因此只按成绩也能区分元素；加入下标可让比较器在一般输入中形成稳定的全序。C++ 比较器必须满足严格弱序，不能用 `>=`。

插入有序集合 $n$ 次为 $O(n\log n)$，遍历 $O(n)$，空间 $O(n)$。本题数据完全静态，直接排序数组通常更简单、常数更小；平衡树的优势主要在成绩动态插删、随时查询排名时。

#### C++17 核心实现

```cpp
std::vector<std::string> relativeRanks(const std::vector<int>& scores) {
    std::set<std::pair<int, int>> ordered;
    for (int index = 0; index < static_cast<int>(scores.size()); ++index) {
        ordered.insert({-scores[index], index});
    }

    std::vector<std::string> answer(scores.size());
    int rank = 1;
    for (auto [negativeScore, index] : ordered) {
        if (rank == 1) answer[index] = "Gold Medal";
        else if (rank == 2) answer[index] = "Silver Medal";
        else if (rank == 3) answer[index] = "Bronze Medal";
        else answer[index] = std::to_string(rank);
        ++rank;
    }
    return answer;
}
```

### 8.3.2 LeetCode 414：第三大不同数（★）

#### “第三大”先要求去重

`[2,2,3,1]` 的不同值是 `{1,2,3}`，第三大为 1；重复的 2 不占两个名次。有序集合同时完成去重和排序。若不同值数 $d\ge3$，取降序第 3 个；否则返回最大值。

插入时间 $O(n\log d)$、空间 $O(d)$。若只保留集合中最大的 3 个不同值，每次插入后删除最小值，空间可降为 $O(1)$，时间仍为 $O(n)$（集合规模恒定）。

原书补充的线性方案维护三个不同的最大值。扫描 $x$ 时先跳过已存在值，再按大小移动 `first,second,third`，时间 $O(n)$、空间 $O(1)$；初始化应使用空状态而非可能与合法最小整数冲突的哨兵。

更新规则例如：若 $x>first$，依次令 `third=second, second=first, first=x`；否则尝试插入 second 或 third。必须先判重，否则 `[3,3,2]` 会错误地把第二个 3 当次大值。

#### C++17 核心实现

```cpp
int thirdMaximum(const std::vector<int>& numbers) {
    std::set<int, std::greater<int>> largest;
    for (int value : numbers) {
        largest.insert(value);
        if (largest.size() > 3) largest.erase(std::prev(largest.end()));
    }
    return largest.size() == 3 ? *largest.rbegin() : *largest.begin();
}
```

### 8.3.3 LeetCode 855：考场就座（★★）

#### 候选位置为何只有三类

已占座位按升序为 $s_0<\cdots<s_{m-1}$。任意空座位落在最左端、某个相邻占座区间或最右端：

- 左端 `[0,s_0)`：距离最近者为 $s_0$，最优位置 0，距离 $s_0$；
- 中间 $(a,b)$：要最大化 $\min(x-a,b-x)$，两边尽量相等，所以选靠左中点；
- 右端 $(s_{m-1},n-1]`：选 $n-1$，距离 $n-1-s_{m-1}$。

已占座位有序。若为空选 0。候选只需考虑：最左端 0、相邻占座 $a<b$ 的中点

$$
seat=a+\left\lfloor\frac{b-a}{2}\right\rfloor,
\quad distance=\left\lfloor\frac{b-a}{2}\right\rfloor,
$$

以及最右端 $n-1$，距离 $n-1-last$。比较时只在距离**严格更大**时更新，遍历顺序从左到右便保留并列最小编号。

#### 样例走查

`n=10`：空场选 0；已有 `[0]` 时右端距离 9，选 9；已有 `[0,9]` 时中点 4 距离 4，选 4；区间 `(0,4)` 候选 2、距离 2，与 `(4,9)`候选 6、距离 2 并列，取编号更小的 2。4 离开后，区间 `(2,9)`候选 5、距离 3，下一次选 5。

原书扫描有序集合，`seat`为 $O(m)$、插入/离开 $O(\log m)$，$m$ 是当前人数。仅仅使用平衡树不自动让找最大空隙变成对数时间。

#### 补充：按空区间排序

高性能设计把每个空区间作为对象，排序键为“可获得距离降序、实际座位编号升序”。`seat`取最优区间并分裂为两个；`leave(p)`借助左右端点映射找到相邻空区间并合并。每次需同步更新有序区间集合和端点映射，可达 $O(\log m)$，但开闭边界、端点座位和失效区间更复杂。

#### C++17 核心实现

```cpp
class ExamRoom {
    int seatCount;
    std::set<int> occupied;

public:
    explicit ExamRoom(int size) : seatCount(size) {}

    int seat() {
        if (occupied.empty()) {
            occupied.insert(0);
            return 0;
        }

        int answer = 0;
        int bestDistance = *occupied.begin();
        int previous = *occupied.begin();
        for (auto it = std::next(occupied.begin()); it != occupied.end(); ++it) {
            int distance = (*it - previous) / 2;
            if (distance > bestDistance) {
                bestDistance = distance;
                answer = previous + distance;
            }
            previous = *it;
        }
        if (seatCount - 1 - previous > bestDistance) answer = seatCount - 1;
        occupied.insert(answer);
        return answer;
    }

    void leave(int position) {
        occupied.erase(position);
    }
};
```

### 8.3.4 LeetCode 2353：食物评分系统（★★）

#### 为什么一个映射不够

系统有两种查询方向：按食物名定位并修改；按菜系找最高评分。这要求两个索引指向同一逻辑记录：

需要两个索引：

1. `food -> (rating,cuisine)`，用于更新时找到旧记录；
2. `cuisine -> ordered set of (-rating,food)`，负评分让升序结构先给高分，名称自然按字典序升序。

排序键 `(-rating,food)`把“评分高优先、同分名称小优先”编码为普通升序。若 sushi 从 8 改成 16，必须删除 `(-8,"sushi")`，插入 `(-16,"sushi")`；之后日式集合首项就是 sushi。若 ramen 也改成 16，`ramen < sushi`，集合首项变为 ramen。

修改评分必须从对应 cuisine 集合删除旧复合键，再插入新键，同时更新食物映射。最高评分就是集合首项。初始化 $O(n\log n)$；更新 $O(\log m)$；查询首项 $O(1)$ 或 $O(\log m)$，取决于容器接口。

#### 一致性与替代方案

若只更新食物映射而忘记有序集合，两个索引会对当前评分产生不同答案。工程中应把“删旧项—改主记录—插新项”视为一次原子状态转换。

没有有序集合时可用每菜系堆并惰性删除：评分更新只压入新版本，查询时不断弹出与主映射不一致的旧堆项。这样更新 $O(\log n)$，但堆会积累过期记录，需考虑内存和周期清理。

#### C++17 核心实现

```cpp
class FoodRatings {
    std::unordered_map<std::string, std::pair<int, std::string>> foodInfo;
    std::unordered_map<std::string,
                       std::set<std::pair<int, std::string>>> cuisineFoods;

public:
    FoodRatings(const std::vector<std::string>& foods,
                const std::vector<std::string>& cuisines,
                const std::vector<int>& ratings) {
        for (int index = 0; index < static_cast<int>(foods.size()); ++index) {
            foodInfo[foods[index]] = {ratings[index], cuisines[index]};
            cuisineFoods[cuisines[index]].insert({-ratings[index], foods[index]});
        }
    }

    void changeRating(const std::string& food, int newRating) {
        auto [oldRating, cuisine] = foodInfo.at(food);
        cuisineFoods[cuisine].erase({-oldRating, food});
        cuisineFoods[cuisine].insert({-newRating, food});
        foodInfo[food].first = newRating;
    }

    std::string highestRated(const std::string& cuisine) const {
        return cuisineFoods.at(cuisine).begin()->second;
    }
};
```

## 8.4 平衡树映射应用的算法设计

### 8.4.1 LeetCode 846：一手顺子（★★）

#### 必要条件与贪心选择

先要求 $n\bmod k=0$。有序计数映射中每次取剩余最小键 $x$，必须用掉 $x,x+1,\ldots,x+k-1$ 各一张。

贪心正确性：最小牌 $x$ 不可能放入起点小于 $x$ 的组（那些牌已不存在），也不能放入起点大于 $x$ 的组，因此它所属组只能从 $x$ 开始。若任一后继缺失则无解；用掉后对剩余牌递归同理。

样例 `[1,2,2,3,3,4,6,7,8]`、$k=3$：最小 1 强制组成 `[1,2,3]`；剩余最小 2 强制组成 `[2,3,4]`；最后 `[6,7,8]`。若处理 2 时缺少 4，就不可能通过其他分组补救。

每张牌的计数减少一次，每次映射查询/擦除 $O(\log d)$，总时间 $O(n\log d)$、空间 $O(d)$。若值域小可用数组计数；若先排序，也可结合频次线性扫描，总复杂度由排序 $O(n\log n)$ 主导。

> **实现风险：** 原书 C++ 示例 `erase(it)` 后再 `it++` 会使用失效迭代器。应按键查询/递减，计数归零时安全擦除，或先保存下一迭代器。Python 示例重建普通 `dict` 也可能丢失 SortedDict 类型，应避免。

#### C++17 核心实现

```cpp
bool isNStraightHand(const std::vector<int>& hand, int groupSize) {
    if (hand.size() % groupSize != 0) return false;
    std::map<int, int> counts;
    for (int value : hand) ++counts[value];

    while (!counts.empty()) {
        int start = counts.begin()->first;
        for (int value = start; value < start + groupSize; ++value) {
            auto it = counts.find(value);
            if (it == counts.end()) return false;
            if (--it->second == 0) counts.erase(it);
        }
    }
    return true;
}
```

### 8.4.2 LeetCode 981：基于时间的键值存储（★★）

#### 查询的数学含义

每个键对应按时间升序的版本序列。查询 $t$ 要找

$$
\max\{t_i\mid t_i\le t\},
$$

即 `upper_bound(t)` 的前一个元素。若 upper bound 位于开头，则无合法版本。例如版本 `(1,"bar"),(4,"bar2")`：查询 3 的 upper bound 指向 4，前一个时间 1 对应 `bar`；查询 5 的 upper bound 在末尾，前一个是 4，对应 `bar2`。

原书 C++ 用哈希映射套有序映射，`set/get`为 $O(\log m)$。但题目保证所有 `set` 时间戳全局严格递增，所以每键版本也递增，可尾插数组并二分：`set`摊还 $O(1)$，`get`为 $O(\log m)$。

查询不存在键时，不应使用 C++ `hmap[key]`，它会插入空记录；应先 `find`。原书示例解释“时间戳 3 小于时间戳 1”应为“查询 3 时最近不超过它的是 1”。

#### 成立条件与替代方案

数组尾插方案依赖 `set` 时间戳严格递增。若允许乱序写入，需要按时间插入有序映射、排序数组中间插入，或采用 LSM/数据库索引等更复杂结构。总空间与全部版本数 $V$ 成正比，$O(V)$；同一键有 $m$ 个版本时查询 $O(\log m)$。

#### C++17 核心实现

```cpp
class TimeMap {
    std::unordered_map<std::string,
                       std::vector<std::pair<int, std::string>>> versions;

public:
    void set(const std::string& key, const std::string& value, int timestamp) {
        versions[key].push_back({timestamp, value});
    }

    std::string get(const std::string& key, int timestamp) const {
        auto found = versions.find(key);
        if (found == versions.end()) return "";
        const auto& rows = found->second;
        auto it = std::upper_bound(
            rows.begin(), rows.end(), timestamp,
            [](int time, const std::pair<int, std::string>& row) {
                return time < row.first;
            });
        return it == rows.begin() ? "" : std::prev(it)->second;
    }
};
```

### 8.4.3 LeetCode 1912：电影租借系统（★★★）

#### 先确定记录身份和排序规则

一个副本由 `(shop,movie)` 唯一标识，价格固定。维护三类索引：

- `price[(shop,movie)]`：静态价格；
- `available[movie]`：未租副本按 `(price,shop)`升序；
- `rented`：已租副本按 `(price,shop,movie)`升序。

`rent`从 available 删除并插入 rented；`drop`反向操作。`search`取指定集合前 5 个 shop；`report`取 rented 前 5 个 `(shop,movie)`。一次状态改变必须同步更新所有动态索引，否则查询视图不一致。

各接口的状态转换为：

```text
初始化: price 写一次；每个副本进入 available[movie]
rent:   available[movie] --(price,shop)；rented ++(price,shop,movie)
drop:   rented --(price,shop,movie)；available[movie] ++(price,shop)
search: 读 available[movie] 前 5 项，投影 shop
report: 读 rented 前 5 项，投影 [shop,movie]
```

样例中电影 1 的未租键是 `(4,1),(5,0),(5,2)`，所以 `search(1)`返回 `[1,0,2]`。租出 `(0,1)` 与 `(1,2)` 后，已租键按价格为 `(5,0,1),(7,1,2)`，报告 `[[0,1],[1,2]]`。

> **勘误说明：** 原书文字一处写 `mvset`存 `(shop,price)`并“按价格递减”，但题目需最便宜优先；正确排序键应以 `price`在前并升序，价格相同再按 `shop`升序。

#### 正确性与一致性

不变量是每个副本恰好处于 `available[movie]` 或 `rented` 之一，并且两个动态索引中的复合键都使用静态 `price`。初始化成立；rent/drop 各做一次相反的删除和插入，因此不变量保持。排序键严格对应题目的所有并列规则，所以前 5 项就是答案。

平衡树实现初始化 $O(E\log E)$，租还 $O(\log E)$，查询输出前 5 项为 $O(5)$ 加定位成本，静态价格表与动态索引共 $O(E)$ 空间。

Python 若无有序集合，可用堆+惰性删除：available 与 rented 都只压新状态，查询时用状态集合过滤过期堆顶。实现更复杂，且过期项可能增长到操作数规模。

#### C++17 核心实现

```cpp
class MovieRentingSystem {
    std::map<std::pair<int, int>, int> prices;
    std::unordered_map<int, std::set<std::pair<int, int>>> available;
    std::set<std::tuple<int, int, int>> rented;

public:
    MovieRentingSystem(int /*shopCount*/,
                       const std::vector<std::vector<int>>& entries) {
        for (const auto& entry : entries) {
            int shop = entry[0], movie = entry[1], price = entry[2];
            prices[{shop, movie}] = price;
            available[movie].insert({price, shop});
        }
    }

    std::vector<int> search(int movie) const {
        std::vector<int> answer;
        auto found = available.find(movie);
        if (found == available.end()) return answer;
        for (auto [price, shop] : found->second) {
            answer.push_back(shop);
            if (answer.size() == 5) break;
        }
        return answer;
    }

    void rent(int shop, int movie) {
        int price = prices.at({shop, movie});
        available[movie].erase({price, shop});
        rented.insert({price, shop, movie});
    }

    void drop(int shop, int movie) {
        int price = prices.at({shop, movie});
        rented.erase({price, shop, movie});
        available[movie].insert({price, shop});
    }

    std::vector<std::vector<int>> report() const {
        std::vector<std::vector<int>> answer;
        for (auto [price, shop, movie] : rented) {
            answer.push_back({shop, movie});
            if (answer.size() == 5) break;
        }
        return answer;
    }
};
```

## 推荐练习题

1. LeetCode 110：平衡二叉树（★）
2. LeetCode 635：设计日志存储系统（★★）
3. LeetCode 1086：前 5 科均分（★）
4. LeetCode 1348：推文计数（★★）
5. LeetCode 1756：设计 MRU 队列（★★）
6. LeetCode 1797：设计验证系统（★★）
7. LeetCode 2034：股票价格波动（★★）
8. LeetCode 2349：设计数字容器系统（★★）

## 附录 A：Python 3 实现速查

以下程序按 AVL 与正文题目顺序集中列出，便于复习和运行验证。

```python
from bisect import bisect_right, insort
from collections import Counter, defaultdict


class TreeNode:
    def __init__(self, val): self.val,self.left,self.right,self.height=val,None,None,1
def height(node): return node.height if node else 0
def update(node): node.height=1+max(height(node.left),height(node.right))
def rotate_right(y):
    x,middle=y.left,y.left.right;x.right=y;y.left=middle;update(y);update(x);return x
def rotate_left(x):
    y,middle=x.right,x.right.left;y.left=x;x.right=middle;update(x);update(y);return y
def avl_insert(root,value):
    if not root:return TreeNode(value)
    if value<root.val:root.left=avl_insert(root.left,value)
    elif value>root.val:root.right=avl_insert(root.right,value)
    else:return root
    update(root);balance=height(root.left)-height(root.right)
    if balance>1:
        if value>root.left.val:root.left=rotate_left(root.left) # LR
        return rotate_right(root)
    if balance < -1:
        if value<root.right.val:root.right=rotate_right(root.right) # RL
        return rotate_left(root)
    return root
def inorder(root):return inorder(root.left)+[root.val]+inorder(root.right) if root else []
def balanced(root):return not root or abs(height(root.left)-height(root.right))<=1 and balanced(root.left) and balanced(root.right)


def sorted_array_to_bst(values):
    def build(left,right):
        if left>=right:return None
        middle=left+(right-left)//2;root=TreeNode(values[middle])
        root.left=build(left,middle);root.right=build(middle+1,right);update(root);return root
    return build(0,len(values))
class ListNode:
    def __init__(self,val,next=None):self.val,self.next=val,next
def sorted_list_to_bst(head):
    values=[]
    while head:values.append(head.val);head=head.next
    return sorted_array_to_bst(values)
def balance_bst(root):return sorted_array_to_bst(inorder(root))
def relative_ranks(scores):
    answer=[""]*len(scores)
    for rank,(_,index) in enumerate(sorted([(-score,i) for i,score in enumerate(scores)]),1):
        answer[index]=["Gold Medal","Silver Medal","Bronze Medal"][rank-1] if rank<=3 else str(rank)
    return answer
def third_max(numbers):
    values=sorted(set(numbers),reverse=True);return values[2] if len(values)>=3 else values[0]


class ExamRoom:
    def __init__(self,size):self.size,self.occupied=size,[]
    def seat(self):
        if not self.occupied:answer=0
        else:
            answer,best=0,self.occupied[0]
            for left,right in zip(self.occupied,self.occupied[1:]):
                distance=(right-left)//2
                if distance>best:best,answer=distance,left+distance
            if self.size-1-self.occupied[-1]>best:answer=self.size-1
        insort(self.occupied,answer);return answer
    def leave(self,seat):self.occupied.remove(seat)


class FoodRatings:
    def __init__(self,foods,cuisines,ratings):
        self.info={food:[rating,cuisine] for food,cuisine,rating in zip(foods,cuisines,ratings)}
        self.foods=defaultdict(set)
        for food,cuisine in zip(foods,cuisines):self.foods[cuisine].add(food)
    def change_rating(self,food,rating):self.info[food][0]=rating
    def highest_rated(self,cuisine):return min(self.foods[cuisine],key=lambda f:(-self.info[f][0],f))
def straight_hand(hand,size):
    if len(hand)%size:return False
    counts=Counter(hand)
    while counts:
        start=min(counts)
        for value in range(start,start+size):
            if not counts[value]:return False
            counts[value]-=1
            if counts[value]==0:del counts[value]
    return True


class TimeMap:
    def __init__(self):self.data=defaultdict(list)
    def set(self,key,value,timestamp):self.data[key].append((timestamp,value))
    def get(self,key,timestamp):
        versions=self.data.get(key,[]);index=bisect_right(versions,(timestamp,chr(0x10ffff)))-1
        return versions[index][1] if index>=0 else ""


class MovieRentingSystem:
    def __init__(self,entries):
        self.price={(shop,movie):price for shop,movie,price in entries};self.rented=set()
    def search(self,movie):
        rows=[(price,shop) for (shop,m),price in self.price.items() if m==movie and (shop,m) not in self.rented]
        return [shop for _,shop in sorted(rows)[:5]]
    def rent(self,shop,movie):self.rented.add((shop,movie))
    def drop(self,shop,movie):self.rented.remove((shop,movie))
    def report(self):
        rows=sorted((self.price[x],x[0],x[1]) for x in self.rented)[:5]
        return [[shop,movie] for _,shop,movie in rows]


if __name__=="__main__":
    avl=None
    for value in [30,20,10,25,28,40]:avl=avl_insert(avl,value)
    print(inorder(avl),balanced(avl),avl.val)
    tree=sorted_array_to_bst([-9,-3,0,5,8]);print(inorder(tree),balanced(tree))
    print(relative_ranks([10,3,8,9,4]),third_max([2,2,3,1]))
    room=ExamRoom(10);print([room.seat() for _ in range(4)]);room.leave(4);print(room.seat())
    ratings=FoodRatings(["kimchi","miso","sushi","ramen"],["korean","japanese","japanese","japanese"],[9,12,8,14]);print(ratings.highest_rated("japanese"));ratings.change_rating("sushi",16);print(ratings.highest_rated("japanese"))
    print(straight_hand([1,2,3,6,2,3,4,7,8],3))
    times=TimeMap();times.set("foo","bar",1);times.set("foo","bar2",4);print(times.get("foo",3),times.get("foo",5))
    movies=MovieRentingSystem([[0,1,5],[0,2,6],[1,1,4],[1,2,7],[2,1,5]]);print(movies.search(1));movies.rent(0,1);movies.rent(1,2);print(movies.report());movies.drop(1,2);print(movies.search(2))
```

核对输出：

```text
[10, 20, 25, 28, 30, 40] True 28
[-9, -3, 0, 5, 8] True
['Gold Medal', '5', 'Bronze Medal', 'Silver Medal', '4'] 1
[0, 9, 4, 2]
5
ramen
sushi
True
bar bar2
[1, 0, 2]
[[0, 1], [1, 2]]
[0, 1]
```

## 附录 B：Go 1.22 实现速查

Go 标准库没有有序集合。以下程序分别覆盖 AVL、静态排序/计数方案和其余核心接口；本机没有 Go 工具链，因此采用字符串感知的静态结构检查。

### AVL 插入与中序闭环

```go
package main
import"fmt"
type Node struct{Key,Height int;Left,Right *Node}
func h(n *Node)int{if n==nil{return 0};return n.Height};func max(a,b int)int{if a>b{return a};return b};func update(n *Node){n.Height=1+max(h(n.Left),h(n.Right))}
func rightRotate(y *Node)*Node{x:=y.Left;middle:=x.Right;x.Right=y;y.Left=middle;update(y);update(x);return x}
func leftRotate(x *Node)*Node{y:=x.Right;middle:=y.Left;y.Left=x;x.Right=middle;update(x);update(y);return y}
func insert(r *Node,k int)*Node{if r==nil{return &Node{Key:k,Height:1}};if k<r.Key{r.Left=insert(r.Left,k)}else if k>r.Key{r.Right=insert(r.Right,k)}else{return r};update(r);b:=h(r.Left)-h(r.Right);if b>1{if k>r.Left.Key{r.Left=leftRotate(r.Left)};return rightRotate(r)};if b< -1{if k<r.Right.Key{r.Right=rightRotate(r.Right)};return leftRotate(r)};return r}
func inorder(r *Node,a *[]int){if r!=nil{inorder(r.Left,a);*a=append(*a,r.Key);inorder(r.Right,a)}}
func main(){var r *Node;for _,x:=range []int{30,20,10,25,28,40}{r=insert(r,x)};a:=[]int{};inorder(r,&a);fmt.Println(a);fmt.Println("root=",r.Key,"height=",r.Height)}
```

### 排序键与时间版本应用

Go 标准库没有有序集合。下面使用哈希计数、排序切片和二分实现相同语义；它适合静态批处理，动态插删的目标复杂度不等同于平衡树版本。

```go
package main

import (
	"fmt"
	"sort"
)

type athlete struct {
	negativeScore int
	index         int
}

func relativeRanks(scores []int) []string {
	ordered := make([]athlete, len(scores))
	for index, score := range scores {
		ordered[index] = athlete{-score, index}
	}
	sort.Slice(ordered, func(i, j int) bool {
		if ordered[i].negativeScore != ordered[j].negativeScore {
			return ordered[i].negativeScore < ordered[j].negativeScore
		}
		return ordered[i].index < ordered[j].index
	})
	answer := make([]string, len(scores))
	medals := []string{"Gold Medal", "Silver Medal", "Bronze Medal"}
	for rank, item := range ordered {
		if rank < 3 {
			answer[item.index] = medals[rank]
		} else {
			answer[item.index] = fmt.Sprint(rank + 1)
		}
	}
	return answer
}

func thirdMaximum(numbers []int) int {
	unique := map[int]bool{}
	for _, value := range numbers {
		unique[value] = true
	}
	values := make([]int, 0, len(unique))
	for value := range unique {
		values = append(values, value)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(values)))
	if len(values) < 3 {
		return values[0]
	}
	return values[2]
}

func straightHand(hand []int, groupSize int) bool {
	if len(hand)%groupSize != 0 {
		return false
	}
	counts := map[int]int{}
	for _, value := range hand {
		counts[value]++
	}
	keys := make([]int, 0, len(counts))
	for value := range counts {
		keys = append(keys, value)
	}
	sort.Ints(keys)
	for _, start := range keys {
		groups := counts[start]
		if groups == 0 {
			continue
		}
		for value := start; value < start+groupSize; value++ {
			if counts[value] < groups {
				return false
			}
			counts[value] -= groups
		}
	}
	return true
}

type version struct {
	time  int
	value string
}

type TimeMap struct {
	versions map[string][]version
}

func NewTimeMap() *TimeMap {
	return &TimeMap{versions: map[string][]version{}}
}

func (store *TimeMap) Set(key, value string, timestamp int) {
	store.versions[key] = append(store.versions[key], version{timestamp, value})
}

func (store *TimeMap) Get(key string, timestamp int) string {
	rows := store.versions[key]
	index := sort.Search(len(rows), func(index int) bool {
		return rows[index].time > timestamp
	})
	if index == 0 {
		return ""
	}
	return rows[index-1].value
}

func main() {
	fmt.Println(relativeRanks([]int{10, 3, 8, 9, 4}))
	fmt.Println(thirdMaximum([]int{2, 2, 3, 1}))
	fmt.Println(straightHand([]int{1, 2, 3, 6, 2, 3, 4, 7, 8}, 3))
	times := NewTimeMap()
	times.Set("foo", "bar", 1)
	times.Set("foo", "bar2", 4)
	fmt.Println(times.Get("foo", 3), times.Get("foo", 5))
}
```

预期输出：

```text
[Gold Medal 5 Bronze Medal Silver Medal 4]
1
true
bar bar2
```

### 构造与动态多索引接口

下面补齐有序序列建树、普通 BST 再平衡、考场、食物评分和电影租借接口。`ExamRoom`用有序切片模拟有序集合，`FoodRatings`与电影系统在查询时排序，因此语义与正文一致，但动态操作复杂度不等同于 C++ 平衡树版本。

```go
package main

import (
    "fmt"
    "sort"
)

type TreeNode struct {
    Value       int
    Left, Right *TreeNode
}

type ListNode struct {
    Value int
    Next  *ListNode
}

func sortedArrayToBST(values []int) *TreeNode {
    var build func(int, int) *TreeNode
    build = func(left, right int) *TreeNode {
        if left >= right {
            return nil
        }
        middle := left + (right-left)/2
        return &TreeNode{
            Value: values[middle],
            Left:  build(left, middle),
            Right: build(middle+1, right),
        }
    }
    return build(0, len(values))
}

func sortedListToBST(head *ListNode) *TreeNode {
    size := 0
    for node := head; node != nil; node = node.Next {
        size++
    }
    current := head
    var build func(int) *TreeNode
    build = func(count int) *TreeNode {
        if count == 0 {
            return nil
        }
        leftSize := count / 2
        left := build(leftSize)
        root := &TreeNode{Value: current.Value, Left: left}
        current = current.Next
        root.Right = build(count - leftSize - 1)
        return root
    }
    return build(size)
}

func inorderValues(root *TreeNode) []int {
    answer := []int{}
    var visit func(*TreeNode)
    visit = func(node *TreeNode) {
        if node == nil {
            return
        }
        visit(node.Left)
        answer = append(answer, node.Value)
        visit(node.Right)
    }
    visit(root)
    return answer
}

func balanceBST(root *TreeNode) *TreeNode {
    return sortedArrayToBST(inorderValues(root))
}

type ExamRoom struct {
    size     int
    occupied []int
}

func NewExamRoom(size int) *ExamRoom {
    return &ExamRoom{size: size}
}

func (room *ExamRoom) Seat() int {
    answer := 0
    if len(room.occupied) > 0 {
        bestDistance := room.occupied[0]
        for index := 1; index < len(room.occupied); index++ {
            left, right := room.occupied[index-1], room.occupied[index]
            distance := (right - left) / 2
            if distance > bestDistance {
                bestDistance = distance
                answer = left + distance
            }
        }
        rightDistance := room.size - 1 - room.occupied[len(room.occupied)-1]
        if rightDistance > bestDistance {
            answer = room.size - 1
        }
    }

    index := sort.SearchInts(room.occupied, answer)
    room.occupied = append(room.occupied, 0)
    copy(room.occupied[index+1:], room.occupied[index:])
    room.occupied[index] = answer
    return answer
}

func (room *ExamRoom) Leave(position int) {
    index := sort.SearchInts(room.occupied, position)
    if index < len(room.occupied) && room.occupied[index] == position {
        room.occupied = append(room.occupied[:index], room.occupied[index+1:]...)
    }
}

type foodRecord struct {
    rating  int
    cuisine string
}

type FoodRatings struct {
    info           map[string]foodRecord
    foodsByCuisine map[string]map[string]bool
}

func NewFoodRatings(foods, cuisines []string, ratings []int) *FoodRatings {
    system := &FoodRatings{
        info:           map[string]foodRecord{},
        foodsByCuisine: map[string]map[string]bool{},
    }
    for index, food := range foods {
        cuisine := cuisines[index]
        system.info[food] = foodRecord{rating: ratings[index], cuisine: cuisine}
        if system.foodsByCuisine[cuisine] == nil {
            system.foodsByCuisine[cuisine] = map[string]bool{}
        }
        system.foodsByCuisine[cuisine][food] = true
    }
    return system
}

func (system *FoodRatings) ChangeRating(food string, rating int) {
    record := system.info[food]
    record.rating = rating
    system.info[food] = record
}

func (system *FoodRatings) HighestRated(cuisine string) string {
    best, bestRating := "", 0
    for food := range system.foodsByCuisine[cuisine] {
        rating := system.info[food].rating
        if best == "" || rating > bestRating || (rating == bestRating && food < best) {
            best, bestRating = food, rating
        }
    }
    return best
}

type copyKey [2]int

type movieCopy struct {
    shop, movie, price int
}

type MovieRentingSystem struct {
    prices map[copyKey]int
    rented map[copyKey]bool
}

func NewMovieRentingSystem(entries [][]int) *MovieRentingSystem {
    system := &MovieRentingSystem{
        prices: map[copyKey]int{},
        rented: map[copyKey]bool{},
    }
    for _, entry := range entries {
        system.prices[copyKey{entry[0], entry[1]}] = entry[2]
    }
    return system
}

func (system *MovieRentingSystem) Search(movie int) []int {
    rows := []movieCopy{}
    for key, price := range system.prices {
        if key[1] == movie && !system.rented[key] {
            rows = append(rows, movieCopy{shop: key[0], movie: movie, price: price})
        }
    }
    sort.Slice(rows, func(i, j int) bool {
        if rows[i].price != rows[j].price {
            return rows[i].price < rows[j].price
        }
        return rows[i].shop < rows[j].shop
    })
    answer := []int{}
    for index := 0; index < len(rows) && index < 5; index++ {
        answer = append(answer, rows[index].shop)
    }
    return answer
}

func (system *MovieRentingSystem) Rent(shop, movie int) {
    system.rented[copyKey{shop, movie}] = true
}

func (system *MovieRentingSystem) Drop(shop, movie int) {
    delete(system.rented, copyKey{shop, movie})
}

func (system *MovieRentingSystem) Report() [][]int {
    rows := []movieCopy{}
    for key := range system.rented {
        rows = append(rows, movieCopy{
            shop: key[0], movie: key[1], price: system.prices[key],
        })
    }
    sort.Slice(rows, func(i, j int) bool {
        if rows[i].price != rows[j].price {
            return rows[i].price < rows[j].price
        }
        if rows[i].shop != rows[j].shop {
            return rows[i].shop < rows[j].shop
        }
        return rows[i].movie < rows[j].movie
    })
    answer := [][]int{}
    for index := 0; index < len(rows) && index < 5; index++ {
        answer = append(answer, []int{rows[index].shop, rows[index].movie})
    }
    return answer
}

func main() {
    values := []int{-9, -3, 0, 5, 8}
    fmt.Println(inorderValues(sortedArrayToBST(values)))
    head := &ListNode{-10, &ListNode{-3, &ListNode{0, &ListNode{5, &ListNode{9, nil}}}}}
    fmt.Println(inorderValues(sortedListToBST(head)))
    skewed := &TreeNode{Value: 1, Right: &TreeNode{Value: 2, Right: &TreeNode{Value: 3}}}
    fmt.Println(inorderValues(balanceBST(skewed)))

    room := NewExamRoom(10)
    fmt.Println([]int{room.Seat(), room.Seat(), room.Seat(), room.Seat()})
    room.Leave(4)
    fmt.Println(room.Seat())

    ratings := NewFoodRatings(
        []string{"kimchi", "miso", "sushi", "ramen"},
        []string{"korean", "japanese", "japanese", "japanese"},
        []int{9, 12, 8, 14},
    )
    fmt.Println(ratings.HighestRated("japanese"))
    ratings.ChangeRating("sushi", 16)
    fmt.Println(ratings.HighestRated("japanese"))

    movies := NewMovieRentingSystem([][]int{
        {0, 1, 5}, {0, 2, 6}, {1, 1, 4}, {1, 2, 7}, {2, 1, 5},
    })
    fmt.Println(movies.Search(1))
    movies.Rent(0, 1)
    movies.Rent(1, 2)
    fmt.Println(movies.Report())
    movies.Drop(1, 2)
    fmt.Println(movies.Search(2))
}
```

预期输出：

```text
[-9 -3 0 5 8]
[-10 -3 0 5 9]
[1 2 3]
[0 9 4 2]
5
ramen
sushi
[1 0 2]
[[0 1] [1 2]]
[0 1]
```

## 代码与公式对应

| 主题 | 代码 | 对应关系 |
|---|---|---|
| AVL 平衡 | `height/update` | $BF=h_L-h_R$ |
| LL/RR/LR/RL | `rotate_* / avl_insert` | 单旋或先子后父双旋 |
| 有序序列建树 | `sorted_array_to_bst` | 中点使两半规模差至多 1 |
| 考场距离 | `ExamRoom` | 中间距离 $\lfloor(b-a)/2\rfloor$ |
| 评分复合键 | `FoodRatings` | `(-rating,name)` |
| 时间版本 | `TimeMap` | 找最大 $t_i\le t$ |
| 多索引系统 | `MovieRentingSystem` | 状态变更同步 available/rented |

## 补充：常见误解

| 误解 | 更准确的理解 |
|---|---|
| 平衡树每个结点左右高度必须相同 | AVL 允许差 1；红黑树使用更弱约束 |
| 一次旋转会破坏 BST 顺序 | 旋转前后中序不变 |
| C++ 标准强制 `set` 使用红黑树 | 标准保证接口和复杂度，常见实现才是红黑树 |
| Python `set` 是有序集合 | 它是哈希集合；排序顺序不能依赖 |
| 使用平衡树后所有题都自动 $O(\log n)$ | 扫描全部间隔的 ExamRoom `seat`仍是 $O(m)$ |
| 有序映射可以修改键后留在原位 | 排序键变化必须删除旧项并重新插入 |
| TimeMap 必须每键使用树 | 时间戳递增时数组尾插加二分更简单 |
| 电影价格可以作为唯一键 | 同价副本需继续按 shop、movie 打破并列 |

## 本章总结

平衡树解决普通 BST 因输入顺序退化的问题。AVL 用高度差和旋转给出严格对数高度；有序集合/映射则把这一能力包装成按键查找、边界查询和有序遍历接口。选择它们的理由应是需要顺序、最值或范围，而不是单纯查键；后者通常由哈希表更快完成。

应用设计的关键是排序键：排名用负成绩，评分用 `(-rating,name)`，电影系统用 `(price,shop,movie)`。动态对象若同时出现在多个索引中，更新必须原子地删除旧键、插入新键。理解“维护什么顺序”比记住容器名称更重要。
