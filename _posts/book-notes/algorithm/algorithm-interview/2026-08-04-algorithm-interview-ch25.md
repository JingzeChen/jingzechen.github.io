---
title: "《算法面试（全二册）》第 25 章：设计问题"
date: 2026-08-03 02:25:00 +0800
updated: 2026-08-04
uid: algorithm-interview-ch25
type: reading
content_lang: zh-CN
status: growing
topics: [algorithms, books]
series: algorithm-interview
series_order: 26
related: [algorithm-interview-ch24]
categories: [读书笔记, 算法, 算法面试]
tags: [algorithms, data-structures, coding-interviews, reading-notes]
description: "围绕「设计问题」梳理核心概念、论证结构、适用边界与实践要点。"
toc: true
render_with_liquid: false
math: true
mermaid: true
---

> 本章原文从 PDF 第 1188 页开始，到附录 A 之前结束，是全书最后一章。内容依次为设计问题概述、例 25-1 LRU 缓存，以及 LeetCode 380、381、432、295 四道设计题。本文严格沿用原书小节顺序；书外证明、工程边界、替代方案和测试方法均明确标注为“补充”。

## 本章要解决什么问题

普通算法题往往给定一次输入并返回一次输出；设计题要求实现一个长期存在的对象，在多次操作之间保存状态，同时满足每个操作的语义和复杂度契约。

因此，设计题不能只回答“某一次操作如何做”，还必须回答：

1. 对象内部保存哪些数据结构？
2. 多个结构之间有什么同步不变量？
3. 每个公开操作如何在不破坏不变量的前提下更新状态？
4. 复杂度要求是最坏、平均还是摊还复杂度？
5. 随机性、重复元素、空结构、容量边界等条件如何定义？

本章五个结构分别体现五种组合思路：

| 结构 | 核心组合 | 要解决的冲突 |
| --- | --- | --- |
| LRUCache | 哈希表 + 双向链表 | O(1) 查找与 O(1) 最近性更新 |
| RandomizedSet | 动态数组 + 值到下标哈希表 | O(1) 随机访问与 O(1) 删除 |
| RandomizedCollection | 动态数组 + 值到下标集合 | 重复值的加权随机与 O(1) 删除一个实例 |
| AllOne | 计数桶双向链表 + 两层哈希结构 | O(1) 增减计数与 O(1) 取极值 |
| MedianFinder | 大根堆 + 小根堆 | 动态插入与 O(1) 读取中位数 |

## 25.1 设计问题概述

### 1. 什么是设计问题

设计问题要求构造一个抽象数据类型（ADT）。一个 ADT 由三部分组成：

- **状态**：对象当前保存的信息；
- **操作**：调用者可以执行的方法；
- **契约**：每个操作的输入、输出、副作用和复杂度保证。

以集合为例，数学状态可以是元素集合 $S$，操作 `insert(x)` 的后置条件是：

$$
S' = S\cup\{x\},
$$

而返回值说明 $x$ 在操作前是否不存在。实现可以使用数组、链表、哈希表或树，但必须与这个外部契约等价。

### 2. 原书的数据结构选择原则

原书归纳了五类常见需求：

1. **按序号查找：使用数组。**

   连续数组支持：

   $$
   access(i)=O(1),
   $$

   因为第 $i$ 个元素地址可由首地址和固定元素大小直接计算。

2. **按已知结点地址插入或删除：使用链表。**

   双向链表已知结点指针 $p$ 时，只需修改常数条链接：

   $$
   p.prev.next\leftarrow p.next,
   $$

   $$
   p.next.prev\leftarrow p.prev.
   $$

   时间为 $O(1)$。但若只有关键字、没有地址，在线性链表中寻找结点仍需 $O(n)$。

3. **数据有序且按关键字查找：使用平衡二叉搜索树。**

   查找、插入和删除通常为：

   $$
   O(\log n),
   $$

   并支持有序遍历、前驱、后继和范围查询。

4. **数据无序且按关键字查找：使用哈希表。**

   在哈希分布良好、负载因子受控的假设下，查找、插入、删除平均为：

   $$
   O(1).
   $$

5. **连续取得最大或最小元素：使用优先队列。**

   二叉堆支持读取堆顶 $O(1)$，插入和删除堆顶：

   $$
   O(\log n).
   $$

这些原则不是互斥选项。设计题的关键往往是组合多个结构，让每个结构负责自己擅长的操作。

### 3. 平均复杂度、摊还复杂度与最坏复杂度

本章多次出现“平均 $O(1)$”，需要区分三个概念。

#### 平均复杂度

在对输入分布、哈希函数或随机化作出假设后，单次操作的期望成本为 $O(1)$。哈希表查找通常属于这一类；极端碰撞下最坏可能退化。

#### 摊还复杂度

不要求每次操作都快，而是在任意长操作序列上分摊成本。例如动态数组扩容一次可能复制 $n$ 个元素，但容量按倍数增长时，连续 $m$ 次追加的总成本为 $O(m)$，所以每次追加摊还：

$$
O(1).
$$

#### 最坏复杂度

对每一次具体操作都给出上界。双向链表在已知结点地址时摘除结点是最坏 $O(1)$。

因此，“数组尾部追加 + 哈希表操作”通常只能严谨地表述为**平均且摊还 $O(1)$**，不是确定性的最坏 $O(1)$。

### 4. 组合数据结构的设计步骤

面对一个设计题，可以按以下顺序分析：

1. 列出每个操作的语义和复杂度目标；
2. 为每个困难操作匹配一种基础结构；
3. 写出结构之间的同步不变量；
4. 将每个公开操作拆成若干原子更新；
5. 检查更新顺序是否会临时丢失定位信息；
6. 用短操作序列和随机参考模型验证不变量。

> **补充：事务式思维。** 多结构更新可看作一个小事务。操作结束时所有不变量必须同时成立；若支持异常、并发或持久化，还要考虑中途失败回滚。本章题目默认单线程、内存充足且基础容器操作成功，因此程序只需保证正常路径上的一致性。

### 5. 例 25-1：LRU 缓存（LeetCode 146，★★）

#### 5.1 问题与语义

LRU 是 Least Recently Used，即“最近最少使用”。缓存容量为正整数 $C$，保存不超过 $C$ 个键值对。

- `get(key)`：键存在时返回值，并把该键标记为最近使用；不存在返回 -1。
- `put(key,value)`：键存在时更新值并标记为最近使用；键不存在时插入。若插入前已满，先淘汰最久未使用键。

两种操作都要求平均：

$$
O(1).
$$

难点是同时支持：

- 按 `key` 常数时间定位；
- 常数时间改变最近性顺序；
- 常数时间找到并删除最旧键。

单独使用哈希表没有顺序；单独使用链表按键查找是 $O(n)$。因此要组合二者。

#### 5.2 状态表示

使用带哨兵 `head`、`tail` 的双向链表。真实结点从前到后按最近使用时间递减：

```text
head <-> 最近使用 <-> ... <-> 最久未使用 <-> tail
```

每个真实结点保存：

$$
(key,value,prev,next).
$$

另有哈希映射：

$$
location[key]=\text{该键对应的链表结点地址}.
$$

哨兵结点不保存用户数据，使空表、单结点和多结点的插入删除使用同一套指针公式。

#### 5.3 三个核心不变量

1. **双射不变量**：哈希表中的每个键恰好对应链表中的一个真实结点，链表每个真实结点也恰好出现在哈希表中。
2. **顺序不变量**：从 `head.next` 到 `tail.prev` 按最后访问时间从新到旧排列。
3. **容量不变量**：

   $$
   0\le |location|\le C.
   $$

#### 5.4 私有原子操作

**摘除结点 `remove(node)`**：

$$
node.prev.next\leftarrow node.next,
$$

$$
node.next.prev\leftarrow node.prev.
$$

**插入到首部 `insert_front(node)`**：

$$
node.prev\leftarrow head,
$$

$$
node.next\leftarrow head.next,
$$

$$
head.next.prev\leftarrow node,
$$

$$
head.next\leftarrow node.
$$

**提升为最近使用 `touch(node)`**：先摘除，再插入首部。

每个原子操作只修改常数个指针，最坏时间 $O(1)$。

#### 5.5 `get` 推导

1. 在 `location` 中查找 `key`；
2. 未找到，返回 -1，状态不变；
3. 找到结点 `node`，调用 `touch(node)`；
4. 返回 `node.value`。

为什么读取也必须移动？“使用”包括读和写。若 `get` 不更新顺序，缓存会错误淘汰刚刚读取的热键。

#### 5.6 `put` 推导

若键已存在：

1. 找到结点；
2. 修改其值；
3. 提升到首部。

缓存元素数量不变，无需淘汰。

若键不存在：

1. 若当前大小等于容量，最旧结点是：

   $$
   victim=tail.prev;
   $$

2. 从链表摘除 `victim`，并从哈希表删除 `victim.key`；
3. 创建新结点，插入首部；
4. 建立 `location[key]=node`。

删除哈希项必须使用被淘汰结点自己的键，且要在丢失结点信息前完成。

#### 5.7 C++17 完整类

实现直接对应前述三个不变量。`detach` 与 `insertFront` 只改链表；公开操作负责同步 `nodes`。淘汰时先保存 `victimKey`，再摘链、删映射、释放结点，避免释放后读取键。

```cpp
#include <stdexcept>
#include <unordered_map>

struct LRUNode {
   int key;
   int value;
   LRUNode* previous = nullptr;
   LRUNode* next = nullptr;

   LRUNode(int keyValue = 0, int dataValue = 0)
      : key(keyValue), value(dataValue) {}
};

class LRUCache {
public:
   explicit LRUCache(int capacityValue) : capacity(capacityValue) {
      if (capacity <= 0) {
         throw std::invalid_argument("capacity must be positive");
      }
      head = new LRUNode();
      tail = new LRUNode();
      head->next = tail;
      tail->previous = head;
   }

   ~LRUCache() {
      LRUNode* node = head;
      while (node != nullptr) {
         LRUNode* next = node->next;
         delete node;
         node = next;
      }
   }

   LRUCache(const LRUCache&) = delete;
   LRUCache& operator=(const LRUCache&) = delete;

   int get(int key) {
      auto iterator = nodes.find(key);
      if (iterator == nodes.end()) {
         return -1;
      }
      touch(iterator->second);
      return iterator->second->value;
   }

   void put(int key, int value) {
      auto iterator = nodes.find(key);
      if (iterator != nodes.end()) {
         iterator->second->value = value;
         touch(iterator->second);
         return;
      }

      if (static_cast<int>(nodes.size()) == capacity) {
         LRUNode* victim = tail->previous;
         const int victimKey = victim->key;
         detach(victim);
         nodes.erase(victimKey);
         delete victim;
      }

      LRUNode* node = new LRUNode(key, value);
      insertFront(node);
      nodes[key] = node;
   }

private:
   int capacity;
   std::unordered_map<int, LRUNode*> nodes;
   LRUNode* head;
   LRUNode* tail;

   void detach(LRUNode* node) {
      node->previous->next = node->next;
      node->next->previous = node->previous;
   }

   void insertFront(LRUNode* node) {
      node->previous = head;
      node->next = head->next;
      head->next->previous = node;
      head->next = node;
   }

   void touch(LRUNode* node) {
      detach(node);
      insertFront(node);
   }
};
```

#### 5.8 示例与状态机走查

容量 $C=2$：

| 操作 | 返回 | 从新到旧的链表 |
| --- | --- | --- |
| `put(1,1)` | - | `[1]` |
| `put(2,2)` | - | `[2,1]` |
| `get(1)` | 1 | `[1,2]` |
| `put(3,3)` | 淘汰 2 | `[3,1]` |
| `get(2)` | -1 | `[3,1]` |
| `put(4,4)` | 淘汰 1 | `[4,3]` |
| `get(1)` | -1 | `[4,3]` |
| `get(3)` | 3 | `[3,4]` |
| `get(4)` | 4 | `[4,3]` |

#### 5.9 正确性论证

用操作序列长度归纳。

- 初始时链表无真实结点、哈希表为空，三个不变量成立。
- `get` 未命中不改变状态；命中时只把对应结点移到首部，所以双射和容量不变，顺序更新为该键最新。
- `put` 更新已有键时同理。
- 插入新键未满时，同时加入链表和哈希表，双射成立，首部是最新键，大小仍不超过容量。
- 已满时先删除唯一最旧的 `tail.prev`，再插入新键；删除和新增各同步修改两种结构，容量仍为 $C$，顺序正确。

因此任意操作后不变量成立，`get` 返回正确值，淘汰对象恰为最近最少使用键。

#### 5.10 复杂度与边界

- 哈希查找平均 $O(1)$；
- 链表摘除、首插最坏 $O(1)$；
- `get`、`put` 平均 $O(1)$；
- 空间 $O(C)$。

原题保证 $C\ge1$。若工程接口允许容量 0，`put` 应直接忽略，否则 `tail.prev` 会是 `head` 哨兵。

> **补充：标准库替代。** Python 可用 `OrderedDict`，Java 可用访问顺序的 `LinkedHashMap`。面试要求手写时，组合哈希表与双链表能直接展示不变量；生产代码优先使用经过测试的标准容器。

> **补充：并发边界。** 本实现不是线程安全的。并发 `get/put` 会同时修改指针和哈希表，需要互斥锁或分段缓存策略。

## 25.2 常见设计问题的求解

### 25.2.1 LeetCode 380：O(1) 时间插入、删除和获取随机元素（★★）

#### 1. 操作契约

实现不含重复值的 `RandomizedSet`：

- `insert(val)`：不存在时插入并返回 `true`，已存在返回 `false`；
- `remove(val)`：存在时删除并返回 `true`，不存在返回 `false`；
- `getRandom()`：从当前元素中等概率返回一个，调用时集合保证非空。

所有操作要求平均 $O(1)$。

#### 2. 为什么单一结构不够

- 哈希集合支持平均 O(1) 插入删除，但不能按连续随机下标等概率抽样；
- 动态数组支持 O(1) 随机下标，但删除中间元素需要搬移后缀，时间 $O(n)$。

组合：

$$
values=[v_0,v_1,\ldots,v_{n-1}],
$$

$$
index[v_i]=i.
$$

数组始终稠密，不留空洞；哈希表记录每个值的唯一位置。

#### 3. 表示不变量

对所有合法下标 $i$：

$$
index[values[i]]=i.
$$

对所有哈希表键 $v$：

$$
values[index[v]]=v.
$$

且：

$$
|values|=|index|.
$$

这说明数组元素与哈希表条目形成双射。

#### 4. 插入

若 `val` 已在 `index` 中，返回假。否则令：

$$
i=|values|,
$$

把 `val` 追加到数组尾部，并记录：

$$
index[val]=i.
$$

动态数组尾部追加摊还 O(1)，哈希写入平均 O(1)。

#### 5. 删除：末尾覆盖空洞

设待删值 `val` 位于：

$$
i=index[val],
$$

数组最后一个值为：

$$
last=values[n-1].
$$

执行：

$$
values[i]\leftarrow last,
$$

$$
index[last]\leftarrow i,
$$

然后删除数组尾元素和哈希项 `index[val]`。

这样把原本需要移动整个后缀的操作，变成一次覆盖和一次尾删。

若 `val==last`，也可以执行同样步骤：先把它的位置写回原下标，再弹出尾部、删除该键，最终结果正确。也可显式判断 `i != n-1` 后再移动，减少无意义写入。

#### 6. C++17 完整类

`values` 是随机抽样的主数据，`index` 是删除所需的反向索引。删除顺序是“读取末尾值 → 覆盖空洞并改索引 → 弹尾 → 删除旧索引”；构造函数允许注入种子，只用于复现实验，不改变均匀分布。

```cpp
#include <cstddef>
#include <random>
#include <stdexcept>
#include <unordered_map>
#include <vector>

class RandomizedSet {
public:
   explicit RandomizedSet(unsigned int seed = std::random_device{}())
      : generator(seed) {}

   bool insert(int value) {
      if (index.count(value) != 0) {
         return false;
      }
      index[value] = values.size();
      values.push_back(value);
      return true;
   }

   bool remove(int value) {
      auto iterator = index.find(value);
      if (iterator == index.end()) {
         return false;
      }

      const std::size_t removeIndex = iterator->second;
      const std::size_t lastIndex = values.size() - 1;
      if (removeIndex != lastIndex) {
         const int lastValue = values[lastIndex];
         values[removeIndex] = lastValue;
         index[lastValue] = removeIndex;
      }
      values.pop_back();
      index.erase(iterator);
      return true;
   }

   int getRandom() {
      if (values.empty()) {
         throw std::out_of_range("getRandom on empty RandomizedSet");
      }
      std::uniform_int_distribution<std::size_t> distribution(
         0, values.size() - 1
      );
      return values[distribution(generator)];
   }

private:
   std::vector<int> values;
   std::unordered_map<int, std::size_t> index;
   std::mt19937 generator;
};
```

> **补充：结构同步错误反例。** 若 `values=[10,20,30]` 删除 20 时只做覆盖和弹尾，却漏掉 `index[30]=1`，会得到 `values=[10,30]`、`index[30]=2`。下一次删除 30 将访问越界下标；错误在前一次操作结束时已经产生，不能等到崩溃时才定位。

#### 7. 数值与状态机走查

依次插入 `1,3,2,5`：

```text
values = [1,3,2,5]
index  = {1:0, 3:1, 2:2, 5:3}
```

删除 3，$i=1$、`last=5`：

```text
覆盖后 values = [1,5,2,5]
更新后 index  = {1:0, 3:1, 2:2, 5:1}
弹尾并删键 3：
values = [1,5,2]
index  = {1:0, 5:1, 2:2}
```

数组顺序改变不影响集合语义。

#### 8. 补充：均匀随机性的证明

生成均匀随机下标：

$$
I\sim Uniform\{0,1,\ldots,n-1\},
$$

返回 `values[I]`。

由于每个集合值在数组中恰好出现一次，对任意 $v\in S$：

$$
P(getRandom()=v)
=P(I=index[v])
=\frac1n.
$$

所以每个元素概率相同。

#### 9. 正确性与复杂度

插入在数组尾部和哈希表中建立一对新映射；删除将末尾值的双向映射改到空洞，再同时移除尾元素和待删键。因此每次操作后双射不变量保持。

| 操作 | 时间 | 说明 |
| --- | --- | --- |
| `insert` | 平均、摊还 O(1) | 哈希 + 数组尾部追加 |
| `remove` | 平均 O(1) | 哈希定位 + 常数次覆盖 + 尾删 |
| `getRandom` | O(1) | 生成随机下标并访问数组 |
| 空间 | O(n) | 数组与哈希表各存一份定位信息 |

#### 10. 边界与常见错误

- 删除后必须更新被移动末尾值的下标；
- 不能用线性搜索寻找 `val`；
- 不能删除数组中间位置后整体平移；
- `getRandom` 只能在非空集合调用；
- 复杂度依赖哈希表平均 O(1) 和数组追加摊还 O(1)；
- 随机数生成器必须能在 $[0,n-1]$ 上均匀取样，不能用有明显模偏差的错误映射。

> **补充：可测试随机性。** 单元测试不应要求一次随机调用返回某个固定值。应注入固定种子的随机数生成器验证确定性边界，或大量采样后用统计容差检查频率；统计测试只能发现明显偏差，不能替代均匀性证明。

### 25.2.2 LeetCode 381：O(1) 时间插入、删除和获取随机元素（可重复）（★★★）

#### 1. 操作契约

`RandomizedCollection` 是允许重复值的多重集合：

- `insert(val)`：总是插入一个 `val`；若插入前该值不存在，返回 `true`，否则返回 `false`；
- `remove(val)`：若存在，删除一个实例并返回 `true`；否则返回 `false`；
- `getRandom()`：按实例均匀随机抽样，因此某个值的概率与其出现次数成正比。

例如当前多重集合为：

$$
\{1,1,2\},
$$

则：

$$
P(1)=\frac23,
\qquad
P(2)=\frac13.
$$

每个操作要求平均 $O(1)$。

#### 2. 从单下标到下标集合

上一题每个值只出现一次，可记录：

$$
index[value]=i.
$$

本题一个值可能对应多个数组槽位，改为：

$$
indices[value]=\{i\mid values[i]=value\}.
$$

其中 `indices[value]` 是哈希集合，可平均 O(1) 插入、删除和任取一个下标。

数组仍保存每个**实例**：

$$
values=[v_0,v_1,\ldots,v_{N-1}].
$$

重复值占据不同下标，因此对数组下标均匀取样自然实现按频次加权。

#### 3. 表示不变量

对每个数组位置 $i$：

$$
i\in indices[values[i]].
$$

对每个值 $v$ 的每个记录下标 $i$：

$$
values[i]=v.
$$

不同值的下标集合不相交，所有下标集合的并集恰好是：

$$
\{0,1,\ldots,N-1\}.
$$

换言之，每个数组槽位属于且只属于一个值桶。

#### 4. 插入

插入前先记录：

$$
isNew=(val\notin indices).
$$

然后令新下标：

$$
i=|values|,
$$

执行：

$$
values.append(val),
$$

$$
indices[val].insert(i).
$$

最后返回 `isNew`。即使值已存在，也要真正追加一个新实例。

#### 5. 删除一个实例

若 `indices[val]` 不存在，返回假。否则从该集合任取一个下标：

$$
removeIndex\in indices[val].
$$

设：

$$
lastIndex=N-1,
$$

$$
lastValue=values[lastIndex].
$$

先从待删值下标集合移除：

$$
indices[val].erase(removeIndex).
$$

若 `removeIndex != lastIndex`，把最后实例移到空洞：

$$
values[removeIndex]\leftarrow lastValue,
$$

并同步最后值的下标集合：

$$
indices[lastValue].erase(lastIndex),
$$

$$
indices[lastValue].insert(removeIndex).
$$

最后弹出数组末尾。若 `indices[val]` 变空，删除整个哈希项。

#### 6. 为什么更新顺序重要

若 `lastValue == val`，待删实例和末尾实例属于同一个下标集合。例如：

```text
values = [2,3,2]
indices[2] = {0,2}
```

删除下标 0 的 `2`：

1. 先删 0，集合变 `{2}`；
2. 用末尾 `2` 覆盖位置 0；
3. 从集合删末尾下标 2，再加入新下标 0；
4. 最终 `values=[2,3]`、`indices[2]={0}`。

若更新时忽略“末尾值可能等于待删值”，很容易留下幽灵下标或误删仍存在的实例。

当 `removeIndex == lastIndex` 时不需要搬移，也不应先删除末尾下标后再尝试从同一集合删除第二次。

#### 7. C++17 完整类

下列实现先从待删值集合移除 `removeIndex`，再转移末尾槽位的所有权。即使 `lastValue == value`，两次集合更新也作用于同一个合法集合，最终不会留下幽灵下标。

```cpp
#include <cstddef>
#include <random>
#include <stdexcept>
#include <unordered_map>
#include <unordered_set>
#include <vector>

class RandomizedCollection {
public:
   explicit RandomizedCollection(unsigned int seed = std::random_device{}())
      : generator(seed) {}

   bool insert(int value) {
      const bool isNew = indices.find(value) == indices.end();
      indices[value].insert(values.size());
      values.push_back(value);
      return isNew;
   }

   bool remove(int value) {
      auto valueIterator = indices.find(value);
      if (valueIterator == indices.end()) {
         return false;
      }

      auto& valueIndices = valueIterator->second;
      const std::size_t removeIndex = *valueIndices.begin();
      const std::size_t lastIndex = values.size() - 1;
      const int lastValue = values[lastIndex];
      valueIndices.erase(removeIndex);

      if (removeIndex != lastIndex) {
         values[removeIndex] = lastValue;
         auto& lastValueIndices = indices.at(lastValue);
         lastValueIndices.erase(lastIndex);
         lastValueIndices.insert(removeIndex);
      }

      values.pop_back();
      if (valueIndices.empty()) {
         indices.erase(valueIterator);
      }
      return true;
   }

   int getRandom() {
      if (values.empty()) {
         throw std::out_of_range(
            "getRandom on empty RandomizedCollection"
         );
      }
      std::uniform_int_distribution<std::size_t> distribution(
         0, values.size() - 1
      );
      return values[distribution(generator)];
   }

private:
   std::vector<int> values;
   std::unordered_map<int, std::unordered_set<std::size_t>> indices;
   std::mt19937 generator;
};
```

`valueIndices.begin()` 任意选择一个实例删除，因此物理数组状态可能因哈希迭代顺序而不同；抽样始终在稠密数组上进行，值 $v$ 仍占据恰好 $c_v$ 个槽位，所以概率不受该选择影响。

#### 8. 原书示例与状态机走查

依次插入 `2,2,3,3,3`：

```text
values     = [2,2,3,3,3]
indices[2] = {0,1}
indices[3] = {2,3,4}
```

假设删除位置 0 的一个 `2`，末尾是位置 4 的 `3`：

```text
移动前：values = [2,2,3,3,3]
移动后：values = [3,2,3,3]
indices[2] = {1}
indices[3] = {0,2,3}
```

数组顺序无关紧要，频次保持为一个 2、三个 3。

#### 9. 补充：按实例加权随机性的证明

设当前实例总数为 $N$，值 $v$ 出现 $c_v$ 次。均匀抽取数组下标 $I$：

$$
I\sim Uniform\{0,1,\ldots,N-1\}.
$$

事件 `values[I]=v` 对应恰好 $c_v$ 个下标，因此：

$$
P(getRandom()=v)
=\frac{c_v}{N}.
$$

这正是题目要求的“概率与出现次数线性相关”。不需要额外计算权重或前缀和。

#### 10. 正确性与复杂度

插入增加一个新槽位并把该槽位加入唯一值桶；删除先移除目标槽位，再把末尾槽位的所有权转移到空洞。每次操作后，下标分区不变量保持。

| 操作 | 时间 |
| --- | --- |
| `insert` | 平均、摊还 O(1) |
| `remove` | 平均 O(1) |
| `getRandom` | O(1) |
| 空间 | O(N) |

其中 $N$ 是实例数，不是不同值的数量。

#### 11. 边界与常见错误

- `insert` 返回的是“插入前是否没有该值”，不是“是否成功插入”；插入总会发生；
- `remove` 只删除一个实例；
- 下标容器必须支持平均 O(1) 任取和删除，不能使用需要线性删除的普通数组列表；
- 桶变空后应删除哈希键，确保下一次插入正确返回 `true`；
- 随机抽样按数组实例，而不是按不同值的哈希键抽样。

### 25.2.3 LeetCode 432：全 O(1) 的数据结构（★★★）

#### 1. 操作契约

`AllOne` 为字符串维护正整数计数：

- `inc(key)`：不存在时创建并置为 1，否则计数加 1；
- `dec(key)`：计数减 1，减到 0 时删除；原题保证调用前键存在；
- `getMaxKey()`：返回任意计数最大的键，空结构返回 `""`；
- `getMinKey()`：返回任意计数最小的键，空结构返回 `""`。

所有方法都要求平均 $O(1)$。

#### 2. 为什么堆或平衡树不满足要求

- 用最大堆和最小堆可快速读极值，但键计数每次变化都要更新堆，通常 $O(\log n)$，还要处理旧条目；
- 平衡树按 `(count,key)` 排序，增减和取极值为 $O(\log n)$；
- 只用哈希表虽然增减为平均 O(1)，但找最大最小需扫描全部键，$O(n)$。

题目有一个关键局部性：每次计数只变化 1。可以把相同计数的键分组为桶，让键只移动到相邻计数桶。

#### 3. 计数桶双向链表

使用带 `head`、`tail` 哨兵的双向链表，真实桶按计数严格递减：

```text
head <-> 最大计数桶 <-> ... <-> 最小计数桶 <-> tail
```

每个桶保存：

$$
Bucket=(count,keys,prev,next),
$$

其中 `keys` 是所有计数等于 `count` 的字符串哈希集合。

另有映射：

$$
location[key]=\text{key 当前所在桶的地址}.
$$

#### 4. 四个核心不变量

1. **排序不变量**：相邻真实桶计数严格递减；
2. **非空不变量**：每个真实桶至少含一个键；
3. **唯一归属不变量**：每个键恰好位于一个桶，并且 `location` 指向该桶；
4. **计数一致性**：键的逻辑计数恰好等于所在桶的 `count`。

因此非空时：

$$
maxCount=head.next.count,
$$

$$
minCount=tail.prev.count.
$$

从这两个桶的 `keys` 任取一个键即可。

#### 5. 为什么目标桶一定相邻

假设键当前计数为 $c$。

- `inc` 后计数为 $c+1$。若 $c+1$ 桶存在，在严格递减链表中它必是当前桶的前驱；否则应在当前桶前新建；
- `dec` 后计数为 $c-1$。若 $c-1$ 桶存在，它必是当前桶的后继；否则应在当前桶后新建。

无需从链表头搜索目标计数，这正是 O(1) 的来源。

#### 6. `inc(key)`

**新键**：目标计数为 1。

- 若 `tail.prev` 是计数 1 桶，直接加入；
- 否则在 `tail` 前创建计数 1 桶；
- 更新 `location[key]`。

**已有键**：设当前桶为 $B_c$。

- 检查前驱是否为 $B_{c+1}$；不存在就紧邻创建；
- 从 $B_c.keys$ 删除键，加入 $B_{c+1}.keys$；
- 更新 `location[key]`；
- 若 $B_c$ 变空，从链表删除该桶。

#### 7. `dec(key)`

设当前桶为 $B_c$。

若 $c=1$：

- 从桶中删除键；
- 从 `location` 删除键；
- 桶空时删除桶。

若 $c>1$：

- 检查后继是否为 $B_{c-1}$；不存在则紧邻创建；
- 把键从 $B_c$ 移到 $B_{c-1}$；
- 更新 `location`；
- 删除变空的 $B_c$。

#### 8. C++17 完整类

真实桶与哨兵均由链表拥有。键迁移时先取得或创建目标桶，再改 `keys` 与 `location`，最后才释放空源桶；这样任何保留下来的映射都不会指向已删除桶。

```cpp
#include <string>
#include <unordered_map>
#include <unordered_set>

struct CountBucket {
   int count;
   std::unordered_set<std::string> keys;
   CountBucket* previous = nullptr;
   CountBucket* next = nullptr;

   explicit CountBucket(int countValue = 0) : count(countValue) {}
};

class AllOne {
public:
   AllOne() {
      head = new CountBucket();
      tail = new CountBucket();
      head->next = tail;
      tail->previous = head;
   }

   ~AllOne() {
      CountBucket* bucket = head;
      while (bucket != nullptr) {
         CountBucket* next = bucket->next;
         delete bucket;
         bucket = next;
      }
   }

   AllOne(const AllOne&) = delete;
   AllOne& operator=(const AllOne&) = delete;

   void inc(const std::string& key) {
      auto iterator = location.find(key);
      if (iterator == location.end()) {
         CountBucket* target = tail->previous;
         if (target == head || target->count != 1) {
            target = new CountBucket(1);
            insertBefore(tail, target);
         }
         target->keys.insert(key);
         location[key] = target;
         return;
      }

      CountBucket* current = iterator->second;
      CountBucket* target = current->previous;
      if (target == head || target->count != current->count + 1) {
         target = new CountBucket(current->count + 1);
         insertBefore(current, target);
      }

      current->keys.erase(key);
      target->keys.insert(key);
      location[key] = target;
      removeIfEmpty(current);
   }

   void dec(const std::string& key) {
      CountBucket* current = location.at(key);
      if (current->count == 1) {
         current->keys.erase(key);
         location.erase(key);
         removeIfEmpty(current);
         return;
      }

      CountBucket* target = current->next;
      if (target == tail || target->count != current->count - 1) {
         target = new CountBucket(current->count - 1);
         insertAfter(current, target);
      }

      current->keys.erase(key);
      target->keys.insert(key);
      location[key] = target;
      removeIfEmpty(current);
   }

   std::string getMaxKey() const {
      if (head->next == tail) {
         return "";
      }
      return *head->next->keys.begin();
   }

   std::string getMinKey() const {
      if (tail->previous == head) {
         return "";
      }
      return *tail->previous->keys.begin();
   }

private:
   std::unordered_map<std::string, CountBucket*> location;
   CountBucket* head;
   CountBucket* tail;

   void insertBefore(CountBucket* position, CountBucket* bucket) {
      bucket->previous = position->previous;
      bucket->next = position;
      position->previous->next = bucket;
      position->previous = bucket;
   }

   void insertAfter(CountBucket* position, CountBucket* bucket) {
      insertBefore(position->next, bucket);
   }

   void removeIfEmpty(CountBucket* bucket) {
      if (!bucket->keys.empty()) {
         return;
      }
      bucket->previous->next = bucket->next;
      bucket->next->previous = bucket->previous;
      delete bucket;
   }
};
```

> **补充：空桶错误反例。** `inc("a"), inc("a"), dec("a")` 后，计数 2 的源桶已经为空。若只移动键而保留该桶，`head.next` 仍指向计数 2 空桶，`getMaxKey()` 将对空集合解引用；因此删除空桶不是空间优化，而是极值正确性的组成部分。

#### 9. 示例与状态机走查

操作序列：

```text
inc("a"), inc("b"), inc("b"), dec("a"), dec("b")
```

桶变化：

```text
inc(a):       [1:{a}]
inc(b):       [1:{a,b}]
inc(b):       [2:{b}] <-> [1:{a}]
dec(a):       [2:{b}]
dec(b):       [1:{b}]
```

每一步只访问当前桶及相邻桶。

#### 10. 补充：正确性证明

初始链表无真实桶、映射为空，四个不变量成立。

假设操作前成立：

- 新键只进入计数 1 的最小桶，排序和计数一致；
- 已有键增 1 只移到前方 $c+1$ 桶，减 1 只移到后方 $c-1$ 桶；目标桶不存在时在唯一正确位置创建，所以排序不变；
- 每次移动同时更新 `location`，唯一归属成立；
- 空桶立即删除，非空不变量成立；
- 计数减到 0 的键同时从桶和映射删除，不再属于结构。

因此归纳得任意操作后不变量成立，头部真实桶包含最大计数键，尾部真实桶包含最小计数键。

#### 11. 复杂度

每次 `inc/dec` 只进行：

- 一次哈希映射查找；
- 常数次哈希集合插入/删除；
- 至多一次桶创建和一次桶删除；
- 常数次链表指针修改。

所以平均时间：

$$
O(1).
$$

`getMaxKey/getMinKey` 访问首尾桶并从集合任取一键，平均 O(1)。若有 $K$ 个键，桶数不超过 $K$，空间 $O(K)$。

#### 12. 边界与常见错误

- 链表方向必须与 `inc/dec` 的前后移动一致；本文按计数递减，原书也是高计数靠头；
- 真实桶不允许为空，否则首尾极值可能错误；
- 键移动后必须更新 `location`；
- `getMaxKey/getMinKey` 可返回并列键中的任意一个，不应依赖固定字符串；
- 原题保证 `dec` 的键存在，工程接口可选择忽略、报错或返回状态，但需明确契约；
- 哈希集合“任取一个元素”平均 O(1) 依赖具体语言容器；C++ `unordered_set.begin()`、Python `next(iter(set))` 可用，Go 迭代映射取首个键。

> **补充：另一种链表方向。** 也可让计数从小到大排列，此时最小桶在 `head.next`、最大桶在 `tail.prev`，`inc` 向后移动、`dec` 向前移动。两种实现都正确，关键是所有不变量、辅助函数和极值接口保持一致。

### 25.2.4 LeetCode 295：数据流的中位数（★★★）

#### 1. 中位数定义

把当前 $n$ 个整数排序：

$$
x_{(1)}\le x_{(2)}\le\cdots\le x_{(n)}.
$$

括号下标表示顺序统计量。

若 $n=2k+1$ 为奇数，中位数是：

$$
median=x_{(k+1)}.
$$

若 $n=2k$ 为偶数，中位数是中间两数平均：

$$
median=\frac{x_{(k)}+x_{(k+1)}}2.
$$

题目要求支持：

- `addNum(num)`：把新整数加入数据流；
- `findMedian()`：返回当前全部元素的中位数。

#### 2. 为什么不能每次排序

保存所有数并在每次查询时排序，需要：

$$
O(n\log n)
$$

查询时间。维护有序数组能二分找到插入位置，但移动元素仍需 $O(n)$。

中位数只依赖排序中心附近元素，不需要完整有序序列。可把数据分成下半部和上半部，只维护两个边界极值。

#### 3. 两个堆的语义

按原书约定：

- `lower`：大根堆，保存较小的一半；堆顶是下半部最大值；
- `upper`：小根堆，保存较大的一半；堆顶是上半部最小值。

建立两个不变量。

**有序分割不变量**：

$$
\forall a\in lower,\ \forall b\in upper:\ a\le b.
$$

等价地，在两堆非空时：

$$
max(lower)\le min(upper).
$$

**数量平衡不变量**：让上半部承担奇数时的中间元素：

$$
|upper|=|lower|
$$

或：

$$
|upper|=|lower|+1.
$$

#### 4. 插入新数

若 `upper` 为空，先放入 `upper`。

否则用上半部最小值作为分界：

- 若

   $$
   num\ge min(upper),
   $$

   放入 `upper`；
- 否则放入 `lower`。

这一步保持有序分割，但可能破坏数量平衡。

#### 5. 重新平衡

若下半部更多：

$$
|lower|>|upper|,
$$

把 `lower` 最大值移到 `upper`：

$$
upper.push(lower.popMax()).
$$

若上半部多两个或更多：

$$
|upper|>|lower|+1,
$$

把 `upper` 最小值移到 `lower`：

$$
lower.push(upper.popMin()).
$$

为什么移动边界元素不会破坏有序分割？

- `lower` 的最大值不大于 `upper` 原有任意元素，移入上半部后仍是合法最小侧边界；
- `upper` 的最小值不小于 `lower` 原有任意元素，移入下半部后仍是合法最大侧边界。

每次插入只增加一个元素，因此最多移动一次就能恢复数量差不超过 1。

#### 6. 读取中位数

若：

$$
|upper|=|lower|+1,
$$

总数为奇数，中位数是：

$$
min(upper).
$$

若两堆等大，总数为偶数，中位数是：

$$
\frac{max(lower)+min(upper)}2.
$$

两个值恰好是排序后中间的 $x_{(k)}$ 和 $x_{(k+1)}$。

#### 7. C++17 完整类

实现先按 `upper.top()` 分流，随后只在堆大小越界时跨堆移动一个边界元素。公开查询仅依赖两个堆顶；空流不在原题合法调用域内，这里显式抛出异常。

```cpp
#include <functional>
#include <queue>
#include <stdexcept>
#include <vector>

class MedianFinder {
public:
   void addNum(int number) {
      if (upper.empty() || number >= upper.top()) {
         upper.push(number);
      } else {
         lower.push(number);
      }

      if (lower.size() > upper.size()) {
         upper.push(lower.top());
         lower.pop();
      } else if (upper.size() > lower.size() + 1) {
         lower.push(upper.top());
         upper.pop();
      }
   }

   double findMedian() const {
      if (upper.empty()) {
         throw std::out_of_range("findMedian on empty stream");
      }
      if (upper.size() > lower.size()) {
         return static_cast<double>(upper.top());
      }
      return static_cast<double>(lower.top()) / 2.0
         + static_cast<double>(upper.top()) / 2.0;
   }

private:
   std::priority_queue<int> lower;
   std::priority_queue<
      int,
      std::vector<int>,
      std::greater<int>
   > upper;
};
```

> **补充：数量平衡不足的反例。** 先分流、后平衡的顺序不可省略。若只按当前大小决定放入较短的堆，例如状态 `lower={1}`、`upper={10}` 时加入 100，放入 `lower` 虽满足数量相等，却破坏 $max(lower)\le min(upper)$；数量平衡不能替代有序分割。

#### 8. 数值与状态机走查

依次插入 `1,2,3,0`：

| 操作 | `lower`（概念集合） | `upper`（概念集合） | 中位数 |
| --- | --- | --- | ---: |
| 加 1 | `{}` | `{1}` | 1 |
| 加 2 | `{1}` | `{2}` | 1.5 |
| 加 3 | `{1}` | `{2,3}` | 2 |
| 加 0 | `{0,1}` | `{2,3}` | 1.5 |

堆内部数组不必整体有序，只保证堆顶和堆序性质。

#### 9. 补充：正确性证明

初始两堆为空，不变量真。

插入时按 `min(upper)` 分流：放入 `lower` 的数不大于上半部边界，放入 `upper` 的数不小于该边界，所以有序分割保持。重新平衡只跨边界移动极值，上文已证明仍保持分割；数量不变量恢复。

因此：

- 等大时，`max(lower)` 是第 $k$ 小，`min(upper)` 是第 $k+1$ 小；
- 上半部多一时，`min(upper)` 是第 $k+1$ 小。

代入中位数定义，`findMedian` 正确。

#### 10. 复杂度与边界

| 操作 | 时间 |
| --- | --- |
| `addNum` | $O(\log n)$ |
| `findMedian` | $O(1)$ |
| 空间 | $O(n)$ |

Python 的 `heapq` 只有小根堆，可把下半部元素取负数存入小根堆：

$$
max(lower)=-negativeLower[0].
$$

C++ 计算偶数中位数时，若数据范围很大，先转浮点或更宽整数再相加，避免：

$$
max(lower)+min(upper)
$$

在整数类型中溢出。本题 $|num|\le10^5$，不会触发，但通用实现仍应防御。

#### 11. 局限与替代方案

- 两堆擅长插入和读中位数，不擅长删除任意旧元素；滑动窗口中位数需要延迟删除或平衡树；
- 若要查询任意分位数，两个堆不够，可使用 order-statistic tree、Fenwick 树（值域可压缩时）或专门的量化摘要；
- 近似中位数的大数据流可使用 GK、KLL、t-digest 等摘要结构，以精度换空间。

## 推荐练习题

原书给出以下 5 道练习：

1. LeetCode 355：设计推特（Twitter）（★★）
2. LeetCode 460：LFU 缓存（★★★）
3. LeetCode 635：设计日志存储系统（★★）
4. LeetCode 677：键值映射（★★）
5. LeetCode 1396：设计地铁系统（★★）

> **补充：练习关注点。** 设计推特组合哈希、链表/时间戳与多路归并堆；LFU 在 LRU 基础上增加频次桶；日志系统考查时间字符串分层索引；键值映射使用前缀树累计权值；地铁系统用哈希表维护进行中的行程和路线聚合统计。

## 代码与不变量的对应关系

| 结构 | 数学状态/不变量 | Python 3 | C++17 | Go 1.22 |
| --- | --- | --- | --- | --- |
| LRU | `key ↔ node` 双射 | `nodes` | `nodes` | `nodes` |
| LRU | `head.next` 最新、`tail.prev` 最旧 | `_insert_front` / `_remove` | `insertFront` / `detach` | `insertFront` / `removeNode` |
| RandomizedSet | $index[values[i]]=i$ | `values` + `index` | 同名成员 | 同名字段 |
| RandomizedCollection | $i\in indices[values[i]]$ | `indices: dict[int,set]` | `unordered_map<int,unordered_set>` | `map[int]map[int]struct{}` |
| AllOne | 桶计数严格递减 | `_CountBucket` 链表 | `CountBucket*` 链表 | `*countBucket` 链表 |
| AllOne | `location[key]` 指向唯一计数桶 | `location` | `location` | `location` |
| MedianFinder | $max(lower)\le min(upper)$ | 负数堆 + 小根堆 | 默认大根堆 + `greater` 小根堆 | `maxHeap` + `minHeap` |
| MedianFinder | $|upper|-|lower|\in\{0,1\}$ | 插入后重平衡 | 插入后重平衡 | 插入后重平衡 |

### 删除时的同步顺序

RandomizedSet 和 RandomizedCollection 都实现：

$$
values[removeIndex]\leftarrow values[lastIndex].
$$

但这只是数组更新；正确实现还必须同步反向索引。

对唯一集合：

$$
index[lastValue]\leftarrow removeIndex.
$$

对可重复集合：

$$
indices[lastValue]
\leftarrow
\left(indices[lastValue]-\{lastIndex\}\right)\cup\{removeIndex\}.
$$

代码中特别先判断 `removeIndex != lastIndex`，避免把同一个末尾实例搬到自己后重复修改集合。

### AllOne 为什么使用结点地址映射

如果 `location[key]` 只保存计数 $c$，仍需从链表中寻找计数桶，无法保证 O(1)。保存桶地址后，可以直接访问当前桶及其前驱/后继：

$$
location[key]\to B_c\to B_{c\pm1}.
$$

这与 LRU 的 `key → node` 是同一种设计模式：哈希表把“按关键字定位”转换为“已知结点地址的链表操作”。

## 三种语言中的实现差异

| 方面 | Python 3 | C++17 | Go 1.22 |
| --- | --- | --- | --- |
| 链表结点生命周期 | 垃圾回收 | `new/delete`，析构遍历释放 | 垃圾回收 |
| 禁止复制含裸指针对象 | 通常按引用使用 | 显式删除复制构造和赋值 | 结构体含指针，按约定只通过指针使用 |
| 值到下标集合 | `dict[int,set[int]]` | `unordered_map<int,unordered_set<size_t>>` | `map[int]map[int]struct{}` |
| 随机源 | 独立 `random.Random` | `mt19937` | 独立 `rand.Rand` |
| 均匀下标 | `randrange(n)` | `uniform_int_distribution` | `Intn(n)` |
| 大根堆 | 存负数模拟 | `priority_queue` 默认大根堆 | 自定义 `maxHeap.Less` |
| 集合任取一项 | `next(iter(set))` | `*set.begin()` | `for key := range map { return key }` |
| 空结构错误 | 抛 `IndexError/ValueError` | 抛标准异常 | 示例使用 `panic` |

### C++ 的资源所有权

LRU 和 AllOne 都动态分配链表结点，因此析构函数沿仍在链表中的结点逐个释放；运行中被淘汰的 LRU 结点和变空的计数桶则立即 `delete`。

两个类还禁用了复制：默认浅复制只会复制裸指针，两个对象随后会重复释放同一链表。生产代码也可使用 `std::list`、智能指针或实现完整的移动语义降低所有权风险。

### 随机源与并发

三种实现都把随机源保存在对象内部，避免修改进程全局随机状态，并允许固定种子复现实验。它们默认不是并发安全的；尤其 Go 的 `rand.Rand` 和所有可变容器都需要外部同步。

### AllOne 返回值不应依赖哈希迭代顺序

题目允许最大/最小计数并列时返回任意键。Python 集合、C++ `unordered_set` 和 Go map 的迭代顺序都不应视为稳定 API。示例中极值桶各只有一个键，所以输出可复现；测试并列情况时应验证返回键属于合法极值集合，而不是固定字符串。

## 原文勘误与边界汇总

1. **整数范围的 OCR 指数丢失。** 原文中的 `-231≤val≤231-1` 应理解为：

   $$
   -2^{31}\le val\le2^{31}-1.
   $$

   类似地，`2×105`、`5×104` 分别是 $2\times10^5$、$5\times10^4$。
2. **RandomizedCollection 的功能是“获取随机元素”。** 原文开头出现“删除随机元素”，但接口和后文均为 `getRandom()`，应是文字/OCR 错误。
3. **本章 O(1) 多为平均或摊还复杂度。** 哈希结构依赖分布假设，动态数组追加依赖倍增扩容；不应误称每次操作确定性最坏 O(1)。
4. **LRU 的读操作也更新最近性。** `get` 命中后必须把结点移到首部；只返回值会破坏淘汰语义。
5. **随机集合删除会改变数组顺序。** 集合/多重集合不承诺插入顺序，末尾覆盖是合法的；若接口还要求稳定顺序，就无法沿用这一 O(1) 删除方案。
6. **可重复集合删除的是一个实例。** 下标集合记录实例位置，不是只记录出现次数；后者无法 O(1) 找到需要填补的数组空洞。
7. **AllOne 的 O(1) 依赖计数每次只变 1。** 若一次任意增加 $k$，目标计数桶不一定相邻，当前链表方案不能直接保证 O(1)。
8. **AllOne 的空桶必须立即删除。** 否则 `head.next` 或 `tail.prev` 可能没有键，极值接口失效。
9. **中位数两堆的命名容易反直觉。** 原书 `minpq` 保存较大一半、`maxpq` 保存较小一半；名称描述的是堆顶类型，不是数据大小范围。

## 补充：易混淆概念与常见误解

### 1. 组合两份数据不是无意义冗余

数组和哈希表保存了部分重复信息，但分别把不同操作降到 O(1)。这种冗余是一种索引：主数据提供随机访问，辅助映射提供反向定位。

代价是每次更新必须原子地维护两份状态。设计题的核心常常不是减少字段，而是证明冗余字段始终一致。

### 2. 数学集合、多重集合与数组槽位

- 集合中每个值最多一个实例；
- 多重集合允许多个相同实例；
- 稠密数组为每个实例提供唯一槽位。

RandomizedCollection 对槽位均匀抽样，不是先对不同值均匀抽样。前者产生 $c_v/N$ 的加权概率，后者错误地产生 $1/|distinct|$。

### 3. “O(1) 获取随机值”为什么需要数组

哈希表虽然能迭代键，但标准接口通常不支持按第 $i$ 个桶或第 $i$ 个元素常数时间访问。数组把所有实例映射到连续整数区间：

$$
[0,N-1],
$$

从而把随机元素问题转成随机整数问题。

### 4. 堆为什么不适合直接实现 AllOne

键每次计数变化后，旧堆条目会过期。可以采用惰性删除，但：

- `inc/dec` 需要 O(log n) 插入新条目；
- 最大与最小通常需要两套堆；
- 过期条目增加空间与清理成本。

AllOne 利用“只变化 1”这一局部性，把更新限制在相邻桶，才达到平均 O(1)。

### 5. 两个堆不是分别维护有序数组

堆内部只有父结点不劣于子结点，并非整体排序。中位数算法只需要：

$$
max(lower),\quad min(upper),
$$

以及跨堆有序分割，不需要知道每一半内部的完整顺序。

### 6. LRU 与 LFU 的区别

- LRU 淘汰最后访问时间最早者；链表按最近性排序；
- LFU 淘汰访问频次最低者，频次并列时通常再按最近性淘汰。

LFU 需要“频次桶 + 桶内 LRU 顺序”，比单链表 LRU 多一层分组，这也是推荐练习 LeetCode 460 的核心。

### 7. 设计题应如何测试

仅测试几组示例不足以发现结构同步错误。可使用**基于模型的状态机测试**：

1. 用简单但较慢的标准结构实现参考模型；
2. 随机生成合法操作序列；
3. 每一步比较返回值和抽象状态；
4. 同时检查内部不变量。

例如：

- LRU 对照 `OrderedDict`；
- 随机集合对照 `set/Counter`；
- AllOne 对照普通 `dict[key]=count`；
- MedianFinder 对照每次排序后的中间元素。

随机方法的具体返回值不适合逐次对照，但可以验证返回值属于当前实例集合，并单独证明/统计抽样概率。

### 8. 迁移判断

当前结构成立的前提一旦改变，应迁移到能直接表达新契约的数据结构，而不是继续堆补丁。

| 需求变化 | 当前方案失效点 | 迁移方向 |
| --- | --- | --- |
| LRU 还要按频次淘汰 | 单一最近性链表没有频次分组 | LFU：频次桶 + 桶内 LRU |
| 随机集合还要保持插入顺序 | 末尾覆盖会改变顺序 | 有序索引，接受删除 $O(n)$，或放宽随机/删除复杂度 |
| RandomizedCollection 要按“不同值”等概率抽样 | 稠密实例数组给出按频次概率 | 另维护不同值数组及反向索引 |
| AllOne 支持任意 `add(key, delta)` | 目标计数桶不再保证相邻 | 平衡树或计数到桶的有序索引，接受 $O(\log n)$ |
| MedianFinder 需要删除旧值或任意分位数 | 两堆不能直接定位任意元素 | 延迟删除双堆、秩统计树或压缩值域 Fenwick 树 |
| 任一结构需要并发或持久化 | 多字段更新不再天然原子 | 锁、分片、事务日志或专用存储组件 |

迁移判断的核心不是“数据量大就换”，而是操作集合、复杂度保证或一致性模型发生了变化。

## 本章总结

```mermaid
flowchart TD
   A[列出操作与复杂度契约] --> B[为每个操作选择基础结构]
   B --> C[写出跨结构同步不变量]
   C --> D[拆分为常数个原子更新]
   D --> E{操作后不变量是否恢复?}
   E -->|否| F[调整状态或更新顺序]
   E -->|是| G[证明正确性与复杂度]
   G --> H[示例 + 参考模型随机测试]

   B --> I[数组: 随机下标]
   B --> J[哈希: 关键字定位]
   B --> K[双链表: O(1) 移动]
   B --> L[堆: 连续取边界极值]
```

本章五个结构展示了设计题最常见的三类思想。

### 1. 用辅助索引换时间

LRU 的哈希表定位链表结点；随机集合的哈希表定位数组槽位；AllOne 的映射定位计数桶。它们都通过额外空间把搜索降为平均 O(1)。

### 2. 用局部更新维持全局性质

- LRU 每次只移动一个结点到首部；
- RandomizedSet 只用末尾元素填一个空洞；
- AllOne 只把键移动到相邻计数桶；
- MedianFinder 每次至多跨堆移动一个边界元素。

局部操作之所以足够，是因为不变量把全局目标压缩成少量边界信息。

### 3. 让数据布局直接表达概率或答案

随机集合让每个实例恰占一个数组槽位，所以均匀下标自然产生正确概率；MedianFinder 让中间元素永远位于两个堆顶，所以查询无需重新排序。

面对新的设计题，可依次追问：

1. 每个操作必须多快，保证是平均、摊还还是最坏？
2. 哪个操作需要按键定位、按序号访问、移动结点或读取极值？
3. 是否需要组合结构，结构之间的双向映射是什么？
4. 删除末尾、删除最后一个实例、桶变空、容量为 1 等边界会怎样？
5. 更新顺序是否在中间阶段覆盖了后续仍需的信息？
6. 能否用简单参考模型和随机操作序列持续检查不变量？

设计题的答案不是某个容器名称，而是一组可维护、可证明、可测试的状态不变量。

## 附录 A：Python 3 完整实现

下面的程序保留五个公开结构 `LRUCache`、`RandomizedSet`、`RandomizedCollection`、`AllOne`、`MedianFinder`；结点和桶是下划线开头的实现细节。随机结构允许注入种子，便于测试复现；算法正确性不依赖具体种子。

```python
from __future__ import annotations

import heapq
import random


class _LRUNode:
   def __init__(self, key: int = 0, value: int = 0) -> None:
      self.key = key
      self.value = value
      self.previous: _LRUNode | None = None
      self.next: _LRUNode | None = None


class LRUCache:
   def __init__(self, capacity: int) -> None:
      if capacity <= 0:
         raise ValueError("capacity 必须为正整数")
      self.capacity = capacity
      self.nodes: dict[int, _LRUNode] = {}
      self.head = _LRUNode()
      self.tail = _LRUNode()
      self.head.next = self.tail
      self.tail.previous = self.head

   def _remove(self, node: _LRUNode) -> None:
      """从双向链表摘除一个真实结点。"""
      assert node.previous is not None and node.next is not None
      node.previous.next = node.next
      node.next.previous = node.previous

   def _insert_front(self, node: _LRUNode) -> None:
      """把结点插到 head 之后，使其成为最近使用项。"""
      first = self.head.next
      assert first is not None
      node.previous = self.head
      node.next = first
      first.previous = node
      self.head.next = node

   def _touch(self, node: _LRUNode) -> None:
      self._remove(node)
      self._insert_front(node)

   def get(self, key: int) -> int:
      node = self.nodes.get(key)
      if node is None:
         return -1
      self._touch(node)
      return node.value

   def put(self, key: int, value: int) -> None:
      node = self.nodes.get(key)
      if node is not None:
         node.value = value
         self._touch(node)
         return

      if len(self.nodes) == self.capacity:
         victim = self.tail.previous
         assert victim is not None and victim is not self.head
         self._remove(victim)
         del self.nodes[victim.key]

      node = _LRUNode(key, value)
      self.nodes[key] = node
      self._insert_front(node)


class RandomizedSet:
   def __init__(self, seed: int | None = None) -> None:
      self.values: list[int] = []
      self.index: dict[int, int] = {}
      self.random = random.Random(seed)

   def insert(self, value: int) -> bool:
      if value in self.index:
         return False
      self.index[value] = len(self.values)
      self.values.append(value)
      return True

   def remove(self, value: int) -> bool:
      remove_index = self.index.get(value)
      if remove_index is None:
         return False

      last_value = self.values[-1]
      self.values[remove_index] = last_value
      self.index[last_value] = remove_index
      self.values.pop()
      del self.index[value]
      return True

   def get_random(self) -> int:
      if not self.values:
         raise IndexError("空集合不能随机取值")
      return self.values[self.random.randrange(len(self.values))]


class RandomizedCollection:
   def __init__(self, seed: int | None = None) -> None:
      self.values: list[int] = []
      self.indices: dict[int, set[int]] = {}
      self.random = random.Random(seed)

   def insert(self, value: int) -> bool:
      is_new = value not in self.indices
      self.indices.setdefault(value, set()).add(len(self.values))
      self.values.append(value)
      return is_new

   def remove(self, value: int) -> bool:
      value_indices = self.indices.get(value)
      if not value_indices:
         return False

      remove_index = next(iter(value_indices))
      last_index = len(self.values) - 1
      last_value = self.values[last_index]
      value_indices.remove(remove_index)

      if remove_index != last_index:
         self.values[remove_index] = last_value
         self.indices[last_value].remove(last_index)
         self.indices[last_value].add(remove_index)

      self.values.pop()
      if not self.indices[value]:
         del self.indices[value]
      return True

   def get_random(self) -> int:
      if not self.values:
         raise IndexError("空集合不能随机取值")
      return self.values[self.random.randrange(len(self.values))]


class _CountBucket:
   def __init__(self, count: int = 0) -> None:
      self.count = count
      self.keys: set[str] = set()
      self.previous: _CountBucket | None = None
      self.next: _CountBucket | None = None


class AllOne:
   def __init__(self) -> None:
      self.head = _CountBucket()
      self.tail = _CountBucket()
      self.head.next = self.tail
      self.tail.previous = self.head
      self.location: dict[str, _CountBucket] = {}

   def _insert_before(self, position: _CountBucket, bucket: _CountBucket) -> None:
      previous = position.previous
      assert previous is not None
      bucket.previous = previous
      bucket.next = position
      previous.next = bucket
      position.previous = bucket

   def _insert_after(self, position: _CountBucket, bucket: _CountBucket) -> None:
      next_bucket = position.next
      assert next_bucket is not None
      self._insert_before(next_bucket, bucket)

   def _remove_bucket(self, bucket: _CountBucket) -> None:
      assert bucket.previous is not None and bucket.next is not None
      bucket.previous.next = bucket.next
      bucket.next.previous = bucket.previous

   def inc(self, key: str) -> None:
      current = self.location.get(key)
      if current is None:
         target = self.tail.previous
         assert target is not None
         if target is self.head or target.count != 1:
            target = _CountBucket(1)
            self._insert_before(self.tail, target)
         target.keys.add(key)
         self.location[key] = target
         return

      target = current.previous
      assert target is not None
      if target is self.head or target.count != current.count + 1:
         target = _CountBucket(current.count + 1)
         self._insert_before(current, target)

      current.keys.remove(key)
      target.keys.add(key)
      self.location[key] = target
      if not current.keys:
         self._remove_bucket(current)

   def dec(self, key: str) -> None:
      current = self.location[key]
      current.keys.remove(key)

      if current.count == 1:
         del self.location[key]
      else:
         target = current.next
         assert target is not None
         if target is self.tail or target.count != current.count - 1:
            target = _CountBucket(current.count - 1)
            self._insert_after(current, target)
         target.keys.add(key)
         self.location[key] = target

      if not current.keys:
         self._remove_bucket(current)

   def get_max_key(self) -> str:
      bucket = self.head.next
      if bucket is self.tail:
         return ""
      assert bucket is not None
      return next(iter(bucket.keys))

   def get_min_key(self) -> str:
      bucket = self.tail.previous
      if bucket is self.head:
         return ""
      assert bucket is not None
      return next(iter(bucket.keys))


class MedianFinder:
   def __init__(self) -> None:
      # lower 用负数模拟大根堆；upper 是普通小根堆。
      self.lower: list[int] = []
      self.upper: list[int] = []

   def add_num(self, number: int) -> None:
      if not self.upper or number >= self.upper[0]:
         heapq.heappush(self.upper, number)
      else:
         heapq.heappush(self.lower, -number)

      if len(self.lower) > len(self.upper):
         heapq.heappush(self.upper, -heapq.heappop(self.lower))
      elif len(self.upper) > len(self.lower) + 1:
         heapq.heappush(self.lower, -heapq.heappop(self.upper))

   def find_median(self) -> float:
      if not self.upper:
         raise IndexError("空数据流没有中位数")
      if len(self.upper) > len(self.lower):
         return float(self.upper[0])
      return (self.upper[0] - self.lower[0]) / 2.0


if __name__ == "__main__":
   cache = LRUCache(2)
   cache.put(1, 1)
   cache.put(2, 2)
   lru_results = [cache.get(1)]
   cache.put(3, 3)
   lru_results.append(cache.get(2))
   cache.put(4, 4)
   lru_results.extend([cache.get(1), cache.get(3), cache.get(4)])
   print("lru:", *lru_results)

   randomized_set = RandomizedSet(seed=25)
   set_results = [
      randomized_set.insert(1),
      randomized_set.remove(2),
      randomized_set.insert(2),
      randomized_set.remove(1),
      randomized_set.insert(2),
      randomized_set.get_random(),
   ]
   print("randomized_set:", *set_results)

   collection = RandomizedCollection(seed=25)
   collection_results = [
      collection.insert(1),
      collection.insert(1),
      collection.insert(2),
      collection.remove(1),
      collection.remove(1),
      collection.get_random(),
   ]
   print("randomized_collection:", *collection_results)

   all_one = AllOne()
   all_one.inc("hello")
   all_one.inc("hello")
   first_max = all_one.get_max_key()
   first_min = all_one.get_min_key()
   all_one.inc("leet")
   print(
      "all_one:",
      first_max,
      first_min,
      all_one.get_max_key(),
      all_one.get_min_key(),
   )

   median_finder = MedianFinder()
   median_finder.add_num(1)
   median_finder.add_num(2)
   first_median = median_finder.find_median()
   median_finder.add_num(3)
   print("median_finder:", first_median, median_finder.find_median())
```

运行输出：

```text
lru: 1 -1 -1 3 4
randomized_set: True False True True False 2
randomized_collection: True False True True True 2
all_one: hello hello hello leet
median_finder: 1.5 2.0
```

## 附录 B：Go 1.22 完整实现

下面保留与附录 A 相同的五个公开结构；`lruNode`、`countBucket`、`minHeap`、`maxHeap` 只服务于实现。随机源通过构造函数注入固定种子，便于静态示例与外部测试复现。

```go
package main

import (
   "container/heap"
   "fmt"
   "math/rand"
)

type lruNode struct {
   key      int
   value    int
   previous *lruNode
   next     *lruNode
}

type LRUCache struct {
   capacity int
   nodes    map[int]*lruNode
   head     *lruNode
   tail     *lruNode
}

func NewLRUCache(capacity int) *LRUCache {
   if capacity <= 0 {
      panic("capacity 必须为正整数")
   }
   head, tail := &lruNode{}, &lruNode{}
   head.next = tail
   tail.previous = head
   return &LRUCache{
      capacity: capacity,
      nodes:    make(map[int]*lruNode),
      head:     head,
      tail:     tail,
   }
}

func (cache *LRUCache) removeNode(node *lruNode) {
   node.previous.next = node.next
   node.next.previous = node.previous
}

func (cache *LRUCache) insertFront(node *lruNode) {
   node.previous = cache.head
   node.next = cache.head.next
   cache.head.next.previous = node
   cache.head.next = node
}

func (cache *LRUCache) touch(node *lruNode) {
   cache.removeNode(node)
   cache.insertFront(node)
}

func (cache *LRUCache) Get(key int) int {
   node, exists := cache.nodes[key]
   if !exists {
      return -1
   }
   cache.touch(node)
   return node.value
}

func (cache *LRUCache) Put(key, value int) {
   if node, exists := cache.nodes[key]; exists {
      node.value = value
      cache.touch(node)
      return
   }

   if len(cache.nodes) == cache.capacity {
      victim := cache.tail.previous
      cache.removeNode(victim)
      delete(cache.nodes, victim.key)
   }

   node := &lruNode{key: key, value: value}
   cache.nodes[key] = node
   cache.insertFront(node)
}

type RandomizedSet struct {
   values []int
   index  map[int]int
   random *rand.Rand
}

func NewRandomizedSet(seed int64) *RandomizedSet {
   return &RandomizedSet{
      index:  make(map[int]int),
      random: rand.New(rand.NewSource(seed)),
   }
}

func (set *RandomizedSet) Insert(value int) bool {
   if _, exists := set.index[value]; exists {
      return false
   }
   set.index[value] = len(set.values)
   set.values = append(set.values, value)
   return true
}

func (set *RandomizedSet) Remove(value int) bool {
   removeIndex, exists := set.index[value]
   if !exists {
      return false
   }

   lastValue := set.values[len(set.values)-1]
   set.values[removeIndex] = lastValue
   set.index[lastValue] = removeIndex
   set.values = set.values[:len(set.values)-1]
   delete(set.index, value)
   return true
}

func (set *RandomizedSet) GetRandom() int {
   if len(set.values) == 0 {
      panic("空集合不能随机取值")
   }
   return set.values[set.random.Intn(len(set.values))]
}

type RandomizedCollection struct {
   values  []int
   indices map[int]map[int]struct{}
   random  *rand.Rand
}

func NewRandomizedCollection(seed int64) *RandomizedCollection {
   return &RandomizedCollection{
      indices: make(map[int]map[int]struct{}),
      random:  rand.New(rand.NewSource(seed)),
   }
}

func (collection *RandomizedCollection) Insert(value int) bool {
   positions, exists := collection.indices[value]
   if !exists {
      positions = make(map[int]struct{})
      collection.indices[value] = positions
   }
   positions[len(collection.values)] = struct{}{}
   collection.values = append(collection.values, value)
   return !exists
}

func (collection *RandomizedCollection) Remove(value int) bool {
   positions, exists := collection.indices[value]
   if !exists {
      return false
   }

   removeIndex := 0
   for index := range positions {
      removeIndex = index
      break
   }
   lastIndex := len(collection.values) - 1
   lastValue := collection.values[lastIndex]
   delete(positions, removeIndex)

   if removeIndex != lastIndex {
      collection.values[removeIndex] = lastValue
      delete(collection.indices[lastValue], lastIndex)
      collection.indices[lastValue][removeIndex] = struct{}{}
   }

   collection.values = collection.values[:lastIndex]
   if len(positions) == 0 {
      delete(collection.indices, value)
   }
   return true
}

func (collection *RandomizedCollection) GetRandom() int {
   if len(collection.values) == 0 {
      panic("空集合不能随机取值")
   }
   return collection.values[collection.random.Intn(len(collection.values))]
}

type countBucket struct {
   count    int
   keys     map[string]struct{}
   previous *countBucket
   next     *countBucket
}

func newCountBucket(count int) *countBucket {
   return &countBucket{count: count, keys: make(map[string]struct{})}
}

type AllOne struct {
   location map[string]*countBucket
   head     *countBucket
   tail     *countBucket
}

func NewAllOne() *AllOne {
   head, tail := newCountBucket(0), newCountBucket(0)
   head.next = tail
   tail.previous = head
   return &AllOne{
      location: make(map[string]*countBucket),
      head:     head,
      tail:     tail,
   }
}

func (allOne *AllOne) insertBefore(position, bucket *countBucket) {
   bucket.previous = position.previous
   bucket.next = position
   position.previous.next = bucket
   position.previous = bucket
}

func (allOne *AllOne) insertAfter(position, bucket *countBucket) {
   allOne.insertBefore(position.next, bucket)
}

func (allOne *AllOne) removeBucket(bucket *countBucket) {
   bucket.previous.next = bucket.next
   bucket.next.previous = bucket.previous
}

func (allOne *AllOne) Inc(key string) {
   current, exists := allOne.location[key]
   if !exists {
      target := allOne.tail.previous
      if target == allOne.head || target.count != 1 {
         target = newCountBucket(1)
         allOne.insertBefore(allOne.tail, target)
      }
      target.keys[key] = struct{}{}
      allOne.location[key] = target
      return
   }

   target := current.previous
   if target == allOne.head || target.count != current.count+1 {
      target = newCountBucket(current.count + 1)
      allOne.insertBefore(current, target)
   }
   delete(current.keys, key)
   target.keys[key] = struct{}{}
   allOne.location[key] = target
   if len(current.keys) == 0 {
      allOne.removeBucket(current)
   }
}

func (allOne *AllOne) Dec(key string) {
   current := allOne.location[key]
   delete(current.keys, key)

   if current.count == 1 {
      delete(allOne.location, key)
   } else {
      target := current.next
      if target == allOne.tail || target.count != current.count-1 {
         target = newCountBucket(current.count - 1)
         allOne.insertAfter(current, target)
      }
      target.keys[key] = struct{}{}
      allOne.location[key] = target
   }

   if len(current.keys) == 0 {
      allOne.removeBucket(current)
   }
}

func (allOne *AllOne) GetMaxKey() string {
   if allOne.head.next == allOne.tail {
      return ""
   }
   for key := range allOne.head.next.keys {
      return key
   }
   return ""
}

func (allOne *AllOne) GetMinKey() string {
   if allOne.tail.previous == allOne.head {
      return ""
   }
   for key := range allOne.tail.previous.keys {
      return key
   }
   return ""
}

type minHeap []int

func (values minHeap) Len() int           { return len(values) }
func (values minHeap) Less(i, j int) bool { return values[i] < values[j] }
func (values minHeap) Swap(i, j int)      { values[i], values[j] = values[j], values[i] }
func (values *minHeap) Push(value any)    { *values = append(*values, value.(int)) }
func (values *minHeap) Pop() any {
   old := *values
   last := old[len(old)-1]
   *values = old[:len(old)-1]
   return last
}

type maxHeap []int

func (values maxHeap) Len() int           { return len(values) }
func (values maxHeap) Less(i, j int) bool { return values[i] > values[j] }
func (values maxHeap) Swap(i, j int)      { values[i], values[j] = values[j], values[i] }
func (values *maxHeap) Push(value any)    { *values = append(*values, value.(int)) }
func (values *maxHeap) Pop() any {
   old := *values
   last := old[len(old)-1]
   *values = old[:len(old)-1]
   return last
}

type MedianFinder struct {
   lower *maxHeap
   upper *minHeap
}

func NewMedianFinder() *MedianFinder {
   lower, upper := &maxHeap{}, &minHeap{}
   heap.Init(lower)
   heap.Init(upper)
   return &MedianFinder{lower: lower, upper: upper}
}

func (finder *MedianFinder) AddNum(number int) {
   if finder.upper.Len() == 0 || number >= (*finder.upper)[0] {
      heap.Push(finder.upper, number)
   } else {
      heap.Push(finder.lower, number)
   }

   if finder.lower.Len() > finder.upper.Len() {
      heap.Push(finder.upper, heap.Pop(finder.lower).(int))
   } else if finder.upper.Len() > finder.lower.Len()+1 {
      heap.Push(finder.lower, heap.Pop(finder.upper).(int))
   }
}

func (finder *MedianFinder) FindMedian() float64 {
   if finder.upper.Len() == 0 {
      panic("空数据流没有中位数")
   }
   if finder.upper.Len() > finder.lower.Len() {
      return float64((*finder.upper)[0])
   }
   return float64((*finder.lower)[0])/2.0 + float64((*finder.upper)[0])/2.0
}

func main() {
   cache := NewLRUCache(2)
   cache.Put(1, 1)
   cache.Put(2, 2)
   firstGet := cache.Get(1)
   cache.Put(3, 3)
   secondGet := cache.Get(2)
   cache.Put(4, 4)
   fmt.Println(
      "lru:",
      firstGet,
      secondGet,
      cache.Get(1),
      cache.Get(3),
      cache.Get(4),
   )

   randomizedSet := NewRandomizedSet(25)
   fmt.Println(
      "randomized_set:",
      randomizedSet.Insert(1),
      randomizedSet.Remove(2),
      randomizedSet.Insert(2),
      randomizedSet.Remove(1),
      randomizedSet.Insert(2),
      randomizedSet.GetRandom(),
   )

   collection := NewRandomizedCollection(25)
   fmt.Println(
      "randomized_collection:",
      collection.Insert(1),
      collection.Insert(1),
      collection.Insert(2),
      collection.Remove(1),
      collection.Remove(1),
      collection.GetRandom(),
   )

   allOne := NewAllOne()
   allOne.Inc("hello")
   allOne.Inc("hello")
   firstMax := allOne.GetMaxKey()
   firstMin := allOne.GetMinKey()
   allOne.Inc("leet")
   fmt.Println(
      "all_one:",
      firstMax,
      firstMin,
      allOne.GetMaxKey(),
      allOne.GetMinKey(),
   )

   medianFinder := NewMedianFinder()
   medianFinder.AddNum(1)
   medianFinder.AddNum(2)
   firstMedian := medianFinder.FindMedian()
   medianFinder.AddNum(3)
   fmt.Println("median_finder:", firstMedian, medianFinder.FindMedian())
}
```

运行输出：

```text
lru: 1 -1 -1 3 4
randomized_set: true false true true false 2
randomized_collection: true false true true true 2
all_one: hello hello hello leet
median_finder: 1.5 2
```
