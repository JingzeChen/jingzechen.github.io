---
uid: cmu-csapp-f15-module-03
type: course
document_type: module
course: cmu-csapp-f15
module_number: 3
title: 模块 03：内存层次与缓存
description: 连接 Lecture 11–12 的概念、证据与掌握路径。
excerpt: 连接 Lecture 11–12 的概念、证据与掌握路径。
content_lang: zh-CN
permalink: "/courses/cmu-csapp-f15/modules/03/"
toc: true
---

{% raw %}
> 对应课程：CMU 15-213/15-513 Introduction to Computer Systems, Fall 2015  
> 教学顺序：Lecture 11, The Memory Hierarchy → Lecture 12, Cache Memories  
> 证据范围：仅使用以下两份课堂笔记，不引入外部体系结构知识。  
> - [Lecture 11 NOTES.md](/courses/cmu-csapp-f15/lectures/011/)
> - [Lecture 12 NOTES.md](/courses/cmu-csapp-f15/lectures/012/)

## 如何使用本模块

本模块保留两讲的依赖顺序：先回答“为什么必须有 memory hierarchy”，再回答“hardware cache 怎样组织、命中、替换、写入和影响程序性能”。如果跳过前半部分直接背 $S/E/B$，很容易会算地址却无法解释 block、miss penalty 与 locality 为什么彼此相连。

证据标记约定：

- `[L11 ...]` 指向 Lecture 11 的时间戳和课件页。
- `[L12 ...]` 指向 Lecture 12 的时间戳和课件页。
- `[需回听 ...]` 表示源笔记仍保留 ASR、口述或材料差异，本文不替它消除不确定性。
- 所有硬件容量、周期、吞吐量和策略示例都受课堂型号、年份和简化模型约束，不能当成所有机器的固定规格。

## 一、总依赖链：从设备约束到缓存行为

两讲合起来的完整推理链是：

```text
存储设备存在速度、容量、单位成本、功耗与物理访问方式的约束
                              +
CPU 与 DRAM / SSD / disk 的访问速度存在巨大鸿沟
                              +
程序倾向于近期复用同一地址或访问邻近地址
                              ↓
                       memory hierarchy
                              ↓
较快、较小的 L_k 保存较慢、较大的 L_(k+1) 的数据子集
                              ↓
                       数据按 block 搬运
                              ↓
          地址被拆为 tag | set index | block offset
                              ↓
         hit 由快层服务；miss 向下取块并执行放置/替换
                              ↓
    miss rate、hit time、miss penalty 决定平均访问成本
                              ↓
循环顺序、stride 与复用时机改变实际 hit/miss 序列
```

这里没有任何单独一条性质足够推出缓存：

1. 只有“快设备很快”不够，因为快设备昂贵、容量小。
2. 只有“慢设备容量大”不够，因为 CPU 等待下层会付出高延迟。
3. 只有 locality 不够，如果 working set 仍大于 cache，或者 placement restriction 让活跃 blocks 竞争同一位置，仍会频繁 miss。
4. 层次结构的目标是通常接近顶层服务速度，同时保留底层容量与成本特征；它不是“每次访问必定在顶层 hit”的保证。[L11 00:53:58-01:01:37，课件 p.49-p.52]

## 二、设备约束：为什么存储不能是一块均匀的“大数组”

### 2.1 线性地址空间只是抽象

汇编层面可以把内存看成按 byte 编址的大数组，但真实系统由性质不同的 devices、controllers、buses 和层次共同实现。总线图同样只是信息流抽象，不是现代芯片的字面布线。[L11 00:00:33-00:02:15；00:07:07-00:08:57，课件 p.2、p.6]

一次 `movq A, %rax` 的 load 可按课堂模型拆成：

1. CPU 把地址 `A` 放上总线。
2. Main memory 取出地址 `A` 处的 8-byte word `x` 并返回。
3. CPU 从总线取得 `x`，写入 `%rax`。

一次 `movq %rax, A` 的 store 则先发送地址 `A`，再发送 8-byte word `y`，最后由主存把 `y` 写到 `A`。[L11 00:09:05-00:10:45，课件 p.7-p.12]

课堂给出的量级是：register 间操作低于 `1 ns`，main-memory read/write 约 `50-100 ns`，已经形成约 `1-2` 个数量级的片上/片外差距。这些是课堂量级，不是某一型号的严格常数。[L11 00:10:45-00:12:04]

### 2.2 SRAM 与 DRAM 的约束

| 项目 | SRAM | DRAM |
|---|---:|---:|
| 每 bit 晶体管数 | 4 或 6 | 1 |
| 相对访问时间 | `1X` | `10X` |
| refresh | No | Yes |
| EDC | Maybe | Yes |
| 相对成本 | `100X` | `1X` |
| 课堂用途 | cache memories | main memories、frame buffers |

推理方向是：更复杂的 SRAM cell 每 bit 更贵，但访问更快，适合容量较小的 cache；DRAM 更便宜、容量可更大，但较慢，适合 main memory。[L11 00:02:18-00:04:18，课件 p.3-p.4]

复核边界：refresh/EDC 处的口述转写自相矛盾，表中采用课件 p.4 的明确内容，不把 ASR 当成另一套结论。[需回听 L11 00:03:21]

### 2.3 Rotating disk：容量大，但机械动作主导访问时间

Disk capacity 按几何组织逐层相乘：[L11 00:18:11-00:18:32，课件 p.18]

$$
\text{Capacity}=
(\text{bytes/sector})
(\text{avg sectors/track})
(\text{tracks/surface})
(\text{surfaces/platter})
(\text{platters/disk}).
$$

课堂例题：

$$
512\times300\times20{,}000\times2\times5
=30{,}720{,}000{,}000\ \text{bytes}
=30.72\ \text{GB}.
$$

这里严格使用 disk 厂商单位 $1\ \text{GB}=10^9\ \text{bytes}$；sector 是 `512 bytes`，不是老师口误后更正前的 `512 bits`。[L11 00:13:51-00:15:28，课件 p.16、p.18]

一次 sector access 被拆为：

$$
T_{access}=T_{avg\ seek}+T_{avg\ rotation}+T_{avg\ transfer}.
$$

若转速为 `RPM`，平均每轨有 $S_{track}$ 个 sectors，则：

$$
T_{avg\ rotation}=\frac12\times\frac{60}{RPM}\ \text{seconds},
$$

$$
T_{avg\ transfer}=\frac{60}{RPM}\times\frac{1}{S_{track}}\ \text{seconds}.
$$

对 `7,200 RPM`、`9 ms` average seek、`400 sectors/track`：

$$
\frac{60}{7200}\ \text{s}=8.333\ldots\ \text{ms/revolution},
$$

$$
T_{avg\ rotation}=4.166\ldots\ \text{ms}\approx4\ \text{ms},
$$

$$
T_{avg\ transfer}=\frac{8.333\ldots}{400}\ \text{ms}
=0.020833\ldots\ \text{ms}\approx0.02\ \text{ms}.
$$

课件先取整再相加：

$$
T_{access}=9+4+0.02=13.02\ \text{ms}.
$$

若保留原始小数到最后才取整，会得到约 `13.19 ms`。课堂答案 `13.02 ms` 与后者的差别来自取整时点。结论是 seek 与 rotation 主导，不是 transfer time 为零；“first bit 最贵，rest free”只是数量级概括。[L11 00:20:31-00:24:26，课件 p.21-p.32]

Logical blocks 把 `(surface, track, sector)` 隐藏在 controller 后面，并允许坏 sector 重映射到 spare cylinder；课堂只为简化暂设一个 logical block 对应一个 sector。[L11 00:25:08-00:26:53，课件 p.33]

### 2.4 DMA：慢设备不能让 CPU 原地搬运和等待

CPU 发起 disk read 时向 controller 提供 `command + logical block number + destination memory address`。Controller 读取 sector 后，以 DMA 直接把数据写入 main memory，CPU 不逐 word 搬运；完成后 controller 再以 interrupt 通知 CPU。约 `10 ms` 的磁盘操作期间，CPU 可执行数百万条指令，所以异步传输避免让处理器同步等待整个机械访问。[L11 00:29:10-00:31:42，课件 p.35-p.37]

### 2.5 SSD：去掉机械运动，但保留写入、寿命与成本约束

SSD 对上层呈现 logical disk block 接口，内部由 flash 和 controller/FTL 实现。Flash 以 page 读写，以包含多个 pages 的 flash block 擦除；flash block 与 logical disk block 是不同单位。[L11 00:31:53-00:33:23，课件 p.38]

修改一个 page 的课堂定性路径是：

```text
找已擦除 block
→ 复制原 block 中其他 pages
→ 写入目标 page
→ 擦除旧 block，供后续使用
```

因此 random write 可能承担搬移与 erase 成本。课堂把 flash endurance 记为约 `100,000` 次，但课件 p.5 写 erasings，p.38 写 repeated writes，两处口径并不完全相同；本模块只保留“反复写入/擦除会磨损”的共同结论。[需回听 L11 00:34:32，课件 p.5、p.38]

Intel SSD 730 的课堂规格为：[L11 00:35:00-00:36:36，课件 p.39]

| 指标 | 数值 |
|---|---:|
| Sequential read throughput | `550 MB/s` |
| Sequential write throughput | `470 MB/s` |
| Random read throughput | `365 MB/s` |
| Random write throughput | `303 MB/s` |
| Average sequential read time | `50 μs` |
| Average sequential write time | `60 μs` |
| Block erase time | 约 `1 ms` |

按课件数字直接展开：sequential read 比 sequential write 高 `80 MB/s`，比值为 $550/470\approx1.17$；random read 比 random write 高 `62 MB/s`，比值为 $365/303\approx1.20$。这些只是该表数字的算术比较，不构成新的 SSD 性能模型。

这些数字只属于课堂所用 Intel SSD 730。2015 年课堂还给出 SSD 每 byte 约比 rotating disk 贵 `30×`，以及 Intel `128 PB = 128×10^15 bytes` 的保证值；都不能无条件外推到其他型号或年份。[L11 00:36:36-00:37:39，课件 p.40]

复核边界：课件与转写均出现 `Pages: 512KB to 4KB`，范围顺序或首个单位可疑。本模块原样保留其不确定性，不以外部常识修正。[需回听 L11 00:33:04，课件 p.38]

### 2.6 Power wall 与 CPU-storage gap

1985-2003 年间，课堂趋势是频率约每 `18 个月-2 年` 翻倍、cycle time 减半：

$$
T_{cycle}=\frac1f.
$$

到 2003 年，继续提频受功耗和散热限制，老师用约 `800 W` 的处理器设想说明 power wall。此后主要通过增加 cores 提升可并行工作量。趋势图使用：

$$
T_{effective}=\frac{T_{cycle}}{N_{cores}}.
$$

这只是课堂的 effective-work 指标，不表示任意程序都随 core 数线性加速。[L11 00:37:39-00:42:06，课件 p.41、p.66]

SRAM 大体跟随 CPU 趋势，DRAM、SSD 与 disk 的访问时间却远高于 CPU cycle。程序必须取 data 和 instructions，所以执行速度最终可能受数据到达速度限制。[L11 00:42:15-00:44:05，课件 p.41]

## 三、Locality：层次结构能够工作的程序侧前提

### 3.1 两种局部性

- **Temporal locality**：最近访问的同一 item 很可能很快再次被访问。
- **Spatial locality**：访问某 item 后，很可能很快访问地址邻近的 items。

Locality 同时适用于 data 与 instructions。一维求和中，`sum` 在各次迭代间体现 data temporal locality，`a[i]` 的 stride-1 扫描体现 data spatial locality；顺序执行 loop body 体现 instruction spatial locality，反复回到 loop body 体现 instruction temporal locality。[L11 00:44:26-00:48:08，课件 p.44-p.45]

### 3.2 Row-major 与 stride

C 二维数组按 row-major 顺序存放。对 `a[M][N]`：

- Inner loop 改变 `j`：`a[i][0], a[i][1], ...`，是 stride-1。
- Inner loop 改变 `i`：`a[0][j], a[1][j], ...`，相邻引用跨一整行，是 stride-$N$。

对表达式 `a[k][i][j]`，最右侧 `j` 应变化最快，所以从 outer 到 inner 的课堂答案是 `k → i → j`。[L11 00:49:43-00:53:58，课件 p.46-p.48]

这里 stride 是元素下标步长。Lecture 11 未给元素 byte size，因此不能在该例中擅自把 stride-$N$ 改成某个固定字节差。

### 3.3 Locality、working set 与容量不是同一件事

程序在某一执行阶段反复使用的一组 blocks 是 working set。Working set 会随 loop 或 function 阶段改变；它不是程序从启动以来访问过的永久全集。[L11 01:08:23-01:08:54]

- 若 $|W|>C_{blocks}$，当前 working set 大于 cache 可容纳的 block 数，会产生 capacity misses。
- 即使 $|W|\le C_{blocks}$，受限 placement 仍可能让多个 active blocks 竞争同一位置，产生 conflict misses。

因此“程序有 locality”只提供缓存可利用的机会；缓存容量、组织和实际地址映射决定机会能否兑现。

## 四、Memory hierarchy：相邻层怎样依赖

### 4.1 层次方向

Lecture 11 的课堂示意为：

```text
L0 registers
L1 cache
L2 cache
L3 cache
L4 main memory
L5 local secondary storage
L6 remote secondary storage
```

编号越小越靠上；上层更快、更小、每 byte 更贵，下层更慢、更大、每 byte 更便宜。对任意相邻层：

$$
L_k\ \text{是}\ L_{k+1}\ \text{的 cache}.
$$

上层保存下层数据的一个 subset。Transfer unit 随层级变化，可以是 words、cache lines、disk blocks 或 files。[L11 00:55:02-01:03:28，课件 p.51-p.53]

### 4.2 通用 hit/miss 生命周期

1. 请求到达 $L_k$。
2. 若包含目标数据的 block 已在 $L_k$，发生 hit，由快层返回。
3. 若不在，发生 miss，向 $L_{k+1}$ 请求整个 block。
4. Placement policy 决定新 block 放在哪里。
5. 若候选位置没有空行，replacement policy 决定 victim。
6. Block 装入后，当前请求才能完成；后续复用才可能摊销这次慢访问。[L11 01:01:57-01:06:28，课件 p.53-p.55]

### 4.3 三类 miss

| 类型 | 根因 | 课堂判据或例子 |
|---|---|---|
| Cold / compulsory | Cache 初始为空，首次访问目标块 | warming up 前无法由已有内容命中 |
| Capacity | 当前 working set 确实装不下 | $|W|>C_{blocks}$ |
| Conflict | Placement 受限，多个 active blocks 争同一位置 | 总容量足够仍反复驱逐 |

Lecture 11 的 4-slot 直接放置模型为：

$$
\operatorname{slot}(i)=i\bmod4.
$$

Blocks 0、4、8 都映射 slot 0。此时 $|W|=3\le4$，总容量足够，却因三者只能进入同一 slot 而反复 miss，所以它是 conflict，不是 capacity。课件还给出最小交替序列 `0, 8, 0, 8, ...`。[L11 01:09:35-01:11:25，课件 p.56]

## 五、Cache organization：从 block 到 $S/E/B/C$

### 5.1 Set、line、block 与元数据

硬件 cache 由 SRAM 实现并由硬件管理。其通用组织是：[L12 00:03:46-00:06:38，课件 p.5-p.6]

1. Cache 有 $S=2^s$ 个 sets。
2. 每个 set 有 $E=2^e$ 条 lines，$E$ 也是 associativity。
3. 每条 line 包含一个 $B=2^b$ byte data block、一个 valid bit 和 tag bits。
4. Line 是带元数据的缓存容器；block 是层次间搬运的数据单位，二者不能完全等同。
5. 开机后数据位虽有 0/1 值，却没有有效语义；只有 valid bit 为 1 的 line 才能参与 hit。

本讲“cache capacity”只计 data bytes，不计 valid、tag、dirty 或 replacement metadata：

$$
C=SEB.
$$

利用幂次定义可写为：

$$
C=2^s2^e2^b=2^{s+e+b}\ \text{bytes}.
$$

### 5.2 地址拆分

对 $m$ 位 byte address：

$$
\underbrace{\text{tag}}_{t\text{ bits}}
\mid
\underbrace{\text{set index}}_{s\text{ bits}}
\mid
\underbrace{\text{block offset}}_{b\text{ bits}},
$$

$$
m=t+s+b,
\qquad
t=m-s-b.
$$

- 最低 $b$ 位在 $B=2^b$ byte block 内定位 byte。
- 接下来的 $s$ 位在 $S=2^s$ 个 sets 中选择唯一候选 set。
- 剩余高位作为 tag，区分映射到同一 set 的不同 memory blocks。[L12 00:07:03-00:10:30，课件 p.7]

对 byte address $A$，同一拆分可用整数运算表达：

$$
\operatorname{block}(A)=\left\lfloor\frac{A}{B}\right\rfloor,
$$

$$
\operatorname{offset}(A)=A\bmod B,
$$

$$
\operatorname{set}(A)=\operatorname{block}(A)\bmod S,
$$

$$
\operatorname{tag}(A)=
\left\lfloor\frac{\operatorname{block}(A)}{S}\right\rfloor.
$$

这些算术式是源笔记根据地址字段定义展开的等价写法。[L12 第 2 段，课件 p.7、p.11]

### 5.3 读命中的严格判定顺序

```text
set index 选择唯一候选 set
→ 并行或逐行检查该 set 内各 line
→ 至少一行满足 valid = 1 且 line.tag = address.tag
→ hit
→ block offset 选择块内起始 byte 并返回所需宽度的数据
```

只匹配 tag 而 valid 为 0，仍是 miss；offset 只选择块内位置，不负责选 set。Hit time 包含 set/tag/valid 查找、确认命中和返回数据，不是仅指最后的数据传送。[L12 00:08:54-00:10:30；00:43:14-00:45:13，课件 p.7、p.18]

复核边界：课堂没有确定“请求的数据宽度具体通过何种硬件接口告诉 cache”，老师明确表示不掌握该实现细节；本模块不补造机制。[L12 00:26:22-00:27:05]

## 六、Direct-mapped、set associative 与 fully associative

### 6.1 三种放置范围

| 组织 | 参数特征 | 一个 memory block 可放的位置 | Hit 时比较范围 |
|---|---|---|---|
| Direct-mapped | $E=1$ | Index 指定 set 的唯一 line | 1 line |
| $E$-way set associative | $E>1$ | Index 指定 set 的任一 line | 该 set 的 $E$ lines |
| Fully associative | $S=1,s=0$ | Cache 中任一 line | 全部 lines |

提高 $E$ 可减少某些 conflict misses，但不会取消 index；block 仍只能进入 index 指定的 set。更高 associativity 还要求比较更多 tags，并维护 victim-selection 状态，所以不是无代价增加。[L12 00:20:58-00:25:17，课件 p.12-p.15]

全相联没有 set-index 字段：

$$
\text{address}=\underbrace{\text{tag}}_{m-b}\mid
\underbrace{\text{block offset}}_b.
$$

课堂说硬件 fully associative cache 很少见，并用 virtual memory 的高 miss cost 说明：只有 miss 足够昂贵时，更复杂的放置和搜索成本才可能值得。[L12 00:23:19-00:24:51]

### 6.2 关键例子 A：直接映射轨迹 `0, 1, 7, 8, 0`

给定：

$$
M=16\ \text{bytes},\quad m=4,\quad B=2,\quad S=4,\quad E=1.
$$

于是：

$$
b=1,\quad s=2,\quad t=1,\quad C=4\times1\times2=8\ \text{bytes}.
$$

地址格式：

$$
\boxed{\text{tag}(1)\mid\text{set}(2)\mid\text{offset}(1)}.
$$

初始所有 valid 为 0，每次读 1 byte：[L12 00:14:40-00:20:08，课件 p.11]

| 次序 | 地址拆分 | 所在 block | 结果 | 原因/动作 |
|---:|---|---|---|---|
| 1 | $0=0\mid00\mid0$ | `[0,1]` | miss | Set 0 无效，装入 tag 0 |
| 2 | $1=0\mid00\mid1$ | `[0,1]` | hit | 同 tag/set，只改变 offset |
| 3 | $7=0\mid11\mid1$ | `[6,7]` | miss | Set 3 无效，装入 `[6,7]` |
| 4 | $8=1\mid00\mid0$ | `[8,9]` | miss + eviction | Set 0 的唯一 line 由 tag 0 改为 tag 1 |
| 5 | $0=0\mid00\mid0$ | `[0,1]` | miss + eviction | `[0,1]` 已被 `[8,9]` 驱逐 |

最后一次是 conflict miss：set 1、set 2 仍空，但 blocks `[0,1]` 与 `[8,9]` 都只能进入 set 0。地址 7 所在 block 从偶数边界 6 开始，不是从 7 开始。

### 6.3 关键例子 B：容量不变，改为 two-way

保持 $M=16,B=2,C=8$，改为：

$$
S=2,\quad E=2,\quad B=2.
$$

于是：

$$
b=1,\quad s=1,\quad t=2,
$$

$$
\boxed{\text{tag}(2)\mid\text{set}(1)\mid\text{offset}(1)}.
$$

同一轨迹变为：[L12 00:33:30-00:35:21，课件 p.15]

| 次序 | 地址拆分 | 结果 | Set 状态要点 |
|---:|---|---|---|
| 1 | $0=00\mid0\mid0$ | miss | Set 0 第一条空 line 装 `[0,1]` |
| 2 | $1=00\mid0\mid1$ | hit | `[0,1]` 仍在 set 0 |
| 3 | $7=01\mid1\mid1$ | miss | Set 1 空 line 装 `[6,7]` |
| 4 | $8=10\mid0\mid0$ | miss，无 eviction | Set 0 第二条空 line 装 `[8,9]` |
| 5 | $0=00\mid0\mid0$ | hit | `[0,1]` 未被驱逐 |

结论只针对该轨迹：two-way 消除了这一次 0/8 conflict；它不表示 two-way cache 不会 miss。

## 七、Replacement 与 block-size 权衡

### 7.1 Replacement policy

Read miss 时，若候选 set 有 invalid line，先使用空 line；只有该 set 所有 lines 都有效时才需要选择 victim。[L12 00:34:44-00:35:03，课件 p.15]

- **LRU**：倾向驱逐最长时间未访问的 line，依据是对 locality 的启发式反推；实现需要额外状态。
- **Random**：课件列出的另一种策略，说明 LRU 不是唯一策略。

LRU 不是对未来的保证，也不应被理解为课件已经规定真实处理器采用精确 LRU。[L12 00:27:09-00:30:29，课件 p.14]

### 7.2 Block size 不是越大越好

- 较大 block 可在一次慢访问中带回更多邻近 bytes，利用 spatial locality 并摊销 miss。
- Block 太小，很快会跨边界再次 miss。
- Block 太大，传输时间更长；在固定 $C$ 下，可同时驻留的其他 blocks 更少。

因此 block size 在空间局部性收益、传输延迟和 cache 占用之间权衡。[L12 00:30:44-00:32:42]

## 八、Write policies：两个独立决策轴

同一数据可同时存在于多个层级，写入必须回答两个不同问题。[L12 00:35:25-00:39:26，课件 p.16]

### 8.1 Write hit：何时更新较低层

| 策略 | 动作 | 代价/所需状态 |
|---|---|---|
| Write-through | 更新 cache 后立即更新较低层 | 每次写 hit 都触发较低层访问 |
| Write-back | 只更新 cache，victim 被替换前才写回 | 需要 dirty bit |

Write-back 中：

1. Cache line 被写后，dirty 置 1。
2. 替换时检查 dirty。
3. Dirty 为 1，先写回较低层再覆盖。
4. Dirty 为 0，较低层已有同样内容，无须写回。

Write-back 不是“永不更新较低层”，而是延迟更新。

### 8.2 Write miss：是否把 block 装入 cache

| 策略 | 动作 | 后续效果 |
|---|---|---|
| Write-allocate | 从较低层取入包含目标 word 的 block，再在 cache 写 | 后续对该 block 的读写可能 hit |
| No-write-allocate | 不创建 cache line，直接写较低层 | 当前 miss 后目标 block 不因该写而驻留 |

Lecture 12 建议后续分析默认采用：

$$
\boxed{\text{write-back}+\text{write-allocate}}.
$$

课件还列出常见配对 `write-through + no-write-allocate`。这只是典型组合，不是本讲证明其他组合在逻辑上不可能。[L12 00:38:52-00:39:26，课件 p.16]

## 九、多级 cache 与性能计算

### 9.1 课堂 Core i7 层次示例

| 层次 | 作用域/类型 | 容量 | 相联度 | 访问时间 |
|---|---|---:|---:|---:|
| L1 d-cache | 每 core 私有，data | 32 KB | 8-way | 4 cycles |
| L1 i-cache | 每 core 私有，instructions | 32 KB | 8-way | 4 cycles |
| L2 unified | 每 core 私有，data + instructions | 256 KB | 8-way | 10 cycles |
| L3 unified | 所有 cores 共享 | 8 MB | 16-way | 40-75 cycles |

三层 block size 都是 `64 B`。`Unified` 表示同时缓存 data 与 instructions，不自动表示跨 core 共享；L2 unified 仍是每 core 私有，L3 才共享。[L12 00:39:45-00:42:34，课件 p.17]

这些是 2015 年课件中的 Core i7 示例，不是所有机器的固定配置。一次请求依次查 L1、L2、L3，最后才可能访问 DRAM；L1 miss 不等于直接访问主存。

### 9.2 Miss rate、hit time、miss penalty

$$
r_{miss}=\frac{\text{misses}}{\text{accesses}}
=1-\text{hit rate}.
$$

$$
T_{miss\ access}=T_{hit}+P_{miss}.
$$

$$
T_{avg}=T_{hit}+r_{miss}P_{miss}.
$$

- $T_{hit}$ 包含本级查找、valid/tag 判定和返回数据。
- $P_{miss}$ 是 miss 后额外支付的下层取数时间，不能再次包含 $T_{hit}$。
- Lecture 12 给出的典型范围是 L1 miss rate 约 `3%-10%`，L2 可低于 `1%`；主存 miss penalty 约 `50-200 cycles`。这些是课堂范围，不是通用常数。[L12 00:42:34-00:46:06，课件 p.18]

### 9.3 97% 与 99% hit-rate 例题

给定：

$$
T_{hit}=1\ \text{cycle},\qquad P_{miss}=100\ \text{cycles}.
$$

97% hit 表示 $r_{miss}=0.03$：

$$
T_{avg}=1+0.03\times100=4\ \text{cycles}.
$$

99% hit 表示 $r_{miss}=0.01$：

$$
T_{avg}=1+0.01\times100=2\ \text{cycles}.
$$

Hit rate 只增加 2 个百分点，平均访问时间却减半；应观察的是昂贵事件的 miss rate 从 3% 降到 1%。[L12 00:46:06-00:46:43，课件 p.19]

## 十、从性能模型回到代码

### 10.1 Cache-friendly 工作顺序

1. 先找执行最频繁的函数和路径。
2. 聚焦 inner loops，因为它们重复次数最多。
3. 让数组尽可能 stride-1 访问，充分使用已取入 block。
4. 让刚取入的数据在仍驻留时尽快复用。
5. 不要把“local variable”自动等同于 register；课堂只说 compiler 可以把某些局部值放入寄存器。[L12 00:46:43-00:49:43，课件 p.20]

课堂在简单顺序扫描中说 stride 2 的 miss 频率约为 stride 1 的两倍。该比例依赖相同元素大小、块利用、访问范围、对齐和 cache 状态，不能推广成任意 stride-2 程序的定律。[L12 00:48:51-00:50:18]

### 10.2 Memory Mountain：同时观察 size 与 stride

Read throughput 定义为：

$$
\text{read throughput}=
\frac{\text{bytes read}}{\text{elapsed time}}\quad(\text{MB/s}).
$$

Memory Mountain 测量：

$$
\text{throughput}=f(\text{working-set size},\text{stride}).
$$

- 每组 `elems/stride` 先运行一次 `test()` warm up，再测第二次。
- Size 增大后，越来越少 cache levels 能容纳整个 working set，形成 L1/L2/L3/main-memory 的 temporal-locality ridges。
- Stride 增大，取入 block 中实际使用的数据减少，形成 spatial-locality slopes。
- 图中小幅不规则可能是 measurement artifact，不应都解释为新层级。[L12 00:50:22-01:01:14，课件 p.21-p.24]

被测系统是 `2.1 GHz Core i7 Haswell`，配置为 `32 KB L1 d-cache / 256 KB L2 / 8 MB L3 / 64 B block`。课堂按 `8 B/element` 解释，所以：

$$
8\ \text{elements}\times8\ \text{B/element}=64\ \text{B/block}.
$$

Stride 达到 8 个元素时，每次引用进入不同 block，继续增大 stride 已不会再损失块内复用。[L12 01:00:05-01:01:14，课件 p.24]

老师把局部性良好的山顶口述为约 `14 GB/s`，把主要从主存读取且局部性较差的低处口述为约 `100 MB/s`。这两者是对当堂图形的近似读数；尤其后者与先前口述的纵轴约 `2,000-16,000 MB/s` 不完全一致，因此不能据此构造精确倍率。[L12 00:56:22-00:58:26]

复核边界：老师把大 working set 下 stride-1 仍维持高吞吐解释为 aggressive prefetching，但明确不确定逻辑位于 L1 还是 L2。这是对该图的推测，不是已证明的固定实现。[L12 01:01:20-01:03:29]

该图的低端读数仍需结合原图和原音复核。[需回听 L12 00:58:08]

### 10.3 矩阵循环排列：空间局部性的定量例子

分析前提必须全部保留：[L12 01:03:56-01:09:59，课件 p.26-p.36]

- $N\times N$ row-major matrices。
- 元素为 `8-byte double`。
- Hardware block 为 `32 B`，即 4 个 doubles。
- $N$ 很大，可把 $1/N$ 近似为 0。
- Cache 不能同时容纳多行。
- 只按 inner-loop access pattern 近似计数。

于是按行连续访问：

$$
r_{row}=\frac{8\ \text{B}}{32\ \text{B}}=\frac14=0.25,
$$

按列跨行访问在该模型下：

$$
r_{column}=1.0.
$$

六种排列的 misses/inner iteration 为：

$$
M_{ijk}=M_{jik}=0.25+1.0+0=1.25,
$$

$$
M_{kij}=M_{ikj}=0+0.25+0.25=0.5,
$$

$$
M_{jki}=M_{kji}=1.0+0+1.0=2.0.
$$

| 排列 | Inner-loop 模式 | Loads | Stores | Misses/iteration |
|---|---|---:|---:|---:|
| `ijk`, `jik` | $A$ 行、$B$ 列，$C$ 在 inner loop 外写 | 2 | 0 | `1.25` |
| `kij`, `ikj` | $A$ 固定、$B$ 行、$C$ 行 | 2 | 1 | `0.5` |
| `jki`, `kji` | $A$ 列、$B$ 固定、$C$ 列 | 2 | 1 | `2.0` |

课堂实测排序与 miss 分析一致：`kij/ikj` 最好，`ijk/jik` 居中，`jki/kji` 最差。但 misses/iteration 不是 cycles/iteration；这里只验证排序趋势。额外 store 没有在该例中推翻较低 read-miss 数的优势，也不表示 store 免费。[L12 01:08:18-01:09:59，课件 p.35-p.36]

### 10.4 Blocking：把潜在复用变成驻留期间的复用

未分块分析另用“一块容纳 8 doubles”的前提，并按课件口径省略 matrix $C$ 的流量。[L12 01:11:24-01:13:23，课件 p.38-p.40]

对一个输出 $c_{ij}$：

$$
M_{one\ output}=\frac n8+n=\frac{9n}{8}.
$$

共有 $n^2$ 个输出：

$$
M_{unblocked}=\frac{9n}{8}n^2=\frac98n^3.
$$

Blocking 把矩阵分成 $B\times B$ tiles。注意此处 $B$ 是 tile 边长，不是前文 $C=SEB$ 中 hardware block 的 byte 数。

一个 input tile 含 $B^2$ doubles，按 8 doubles/cache block：

$$
M_{one\ input\ tile}=\frac{B^2}{8}.
$$

一个 output tile 沿内积方向处理 $n/B$ 对 input tiles：

$$
M_{one\ output\ tile}
=2\times\frac nB\times\frac{B^2}{8}
=\frac{nB}{4}.
$$

Output tiles 数为：

$$
\left(\frac nB\right)^2.
$$

所以：

$$
M_{blocked}
=\frac{nB}{4}\left(\frac nB\right)^2
=\frac{n^3}{4B}.
$$

三个活动 tiles 必须同时驻留：

$$
3B^2<C.
$$

这里 $C$ 必须与 $B^2$ 使用一致容量单位。两个版本仍都是 $\Theta(n^3)$，但 miss 常数从 $9/8$ 变为 $1/(4B)$；tile 应在满足驻留约束时尽可能大，不能直接令 $B=n$。[L12 01:13:23-01:17:30，课件 p.41-p.44]

复核边界：课件 p.39-p.40 写 `Cache size C << n`，若 $C$ 与 $n$ 单位不同则不能直接作量纲比较；源笔记只确认其意图是“行太大，不能留在 cache 供下一次复用”。

## 十一、关键结论的适用边界

1. **总线图边界**：它表示信息流，不是现代系统的字面布线；PCI 与 PCI Express 的连接结构也不同。[L11 00:27:07-00:28:20]
2. **设备数字边界**：disk、SSD、Core i7 容量/延迟/吞吐均是课堂型号与 2015 年语境。
3. **Disk 比值边界**：课件称 disk 约比 SRAM 慢 `40,000×`、比 DRAM 慢 `2,500×`，却未展开单位归一化；不可直接用 `13.02 ms/sector` 除以 `ns/doubleword` 重造该比值。[L11 00:24:26-00:25:08，课件 p.32]
4. **Cache 容量边界**：$C=SEB$ 只计 data bytes，不计 tag、valid、dirty 或 replacement bits。
5. **地址边界**：$S/B$ 是数量，$s/b$ 是位数；$B=2^b$，不是“地址低 $B$ 位”。
6. **相联度边界**：提高 $E$ 只放宽指定 set 内的位置，不允许 block 去任意 set。
7. **Replacement 边界**：LRU 是启发式且需要状态；课件还列出 random。
8. **Write 边界**：through/back 处理 hit 后何时传播；allocate/no-allocate 处理 miss 后是否装入，不能混成一条轴。
9. **Average-time 边界**：miss penalty 是 hit-time 之外的额外成本；不能在 $T_{avg}$ 中重复计入 hit time。
10. **Stride 边界**：stride-2 两倍 miss、row `0.25`、column `1.0` 都依赖各自课堂的元素、block、布局、对齐和 working-set 假设。
11. **Memory Mountain 边界**：它是特定 Haswell 系统、warm-up 后的 read-throughput 测量；ridge/slope 可解释层次与局部性，但具体高度不能迁移到其他机器。
12. **Prefetch 边界**：老师以推测解释 stride-1 平台，且未确定预取逻辑层级。
13. **矩阵边界**：misses/iteration 与 cycles/iteration 是不同量；实测只支持排序趋势一致。
14. **Blocking 边界**：后半讲的 $B$ 是 tile 边长；公式省略 $C$ 流量，且要求 $3B^2<C$。

## 十二、常见误解与纠正

1. **误解：内存就是一种均匀、随机访问速度相同的硬件。**  
   纠正：线性 byte array 是抽象，真实设备跨越 register、SRAM、DRAM、SSD、disk 与 remote storage。

2. **误解：Locality 就等于“数组访问连续”。**  
   纠正：还包括同一 item 的 temporal reuse，且 data 与 instructions 都要检查。

3. **误解：取回 CPU 请求的那个 word 就够了。**  
   纠正：层次间按 block 搬运，以一次慢访问换取对邻近数据的后续 hits。

4. **误解：Tag 一样就 hit。**  
   纠正：必须在 index 指定 set 中同时满足 `valid=1` 与 tag match。

5. **误解：Offset 决定 block 去哪个 set。**  
   纠正：Index 选 set，tag 识别 block，offset 选 block 内 byte。

6. **误解：Direct-mapped miss 说明整个 cache 已满。**  
   纠正：`0,1,7,8,0` 中仍有空 sets，0 与 8 只是冲突于 set 0。

7. **误解：Two-way 允许地址 8 改放 set 1。**  
   纠正：地址 8 仍进 set 0，只是 set 0 有第二条 line。

8. **误解：Set 有空 line 也要执行 LRU。**  
   纠正：先用 invalid line，组满才选择 victim。

9. **误解：Write-back 永远不写较低层。**  
   纠正：脏 line 被替换前必须写回。

10. **误解：L1 miss 就是访问 DRAM。**  
    纠正：请求继续检查 L2、L3，最后才可能到主存。

11. **误解：97% 与 99% hit 几乎一样。**  
    纠正：在课堂参数下，miss rate 从 3% 降至 1%，$T_{avg}$ 从 4 cycles 降至 2 cycles。

12. **误解：同为 $O(n^3)$，blocking 没有意义。**  
    纠正：它不改渐进运算阶，却把课堂模型中的 miss 常数从 $9/8$ 降到 $1/(4B)$。

## 十三、掌握清单

- [ ] 能从“设备约束 + speed gap + locality”独立推导 memory hierarchy，而不是只背层级名称。
- [ ] 能解释 SRAM/DRAM、disk、SSD 的速度、容量、成本与访问机制差异，并主动声明数字边界。
- [ ] 能重算 disk capacity 与 `7,200 RPM` 的 `13.02 ms` 课堂答案，说明早取整位置。
- [ ] 能画出 CPU 发起 disk read 后 controller、DMA、main memory、interrupt 的路径。
- [ ] 能分别从 data 和 instructions 判断 temporal/spatial locality。
- [ ] 能根据 row-major layout 判断 stride-1、stride-$N$ 与 `k → i → j`。
- [ ] 能区分 cold、capacity、conflict misses，并用 $|W|$ 与 placement rule 解释原因。
- [ ] 给定 $m,S,E,B$，能求 $s,b,t,C$ 并画出 tag/index/offset。
- [ ] 能按“index → valid/tag → offset”说明一次读 hit。
- [ ] 能完整手算 direct-mapped 与 two-way 的 `0,1,7,8,0` 轨迹。
- [ ] 能比较 direct-mapped、set associative、fully associative 的放置范围与比较成本。
- [ ] 能说明空 line、LRU/random、victim 与 dirty write-back 的先后关系。
- [ ] 能把 write-through/write-back 与 write-allocate/no-write-allocate 放在两个独立决策轴上。
- [ ] 能用 $T_{avg}=T_{hit}+r_{miss}P_{miss}$ 重算 97%/99% 例题。
- [ ] 能解释 Memory Mountain 的 size、stride、throughput、ridge、slope 与 warm-up 前提。
- [ ] 能在全部前提下重算六种矩阵循环排列的 `1.25/0.5/2.0`。
- [ ] 能从 $n/8+n$ 推到 $(9/8)n^3$，再从 $B^2/8$ 推到 $n^3/(4B)$。
- [ ] 能解释为什么 $3B^2<C$ 限制 tile 不能无限增大，并识别两个 $B$ 的不同含义。

## 十四、12 道累计练习与答案

### 题 1：因果链

**题目：** 不使用“因为现代 CPU 都有 cache”这种循环解释，写出 memory hierarchy 成立所依赖的三组事实，并说明 locality 在其中的作用。

**答案：** 第一，快存储每 byte 更贵、容量较小且课件还列出功耗/热约束，慢存储更大、更便宜；第二，CPU 与 DRAM/SSD/disk 存在很大且可能扩大的 speed gap；第三，程序表现出 temporal 与 spatial locality。Locality 使从 $L_{k+1}$ 搬到 $L_k$ 的 block 很可能很快再次被访问，从而让一次慢搬运可被多次快访问摊销。[L11 00:53:58-01:01:37]

### 题 2：Disk capacity

**题目：** 使用 `512 bytes/sector`、`300 sectors/track`、`20,000 tracks/surface`、`2 surfaces/platter`、`5 platters/disk` 计算容量，并使用课堂 GB 定义。

**答案：**

$$
512\times300\times20{,}000\times2\times5
=30{,}720{,}000{,}000\ \text{bytes}.
$$

按 $1\ \text{GB}=10^9\ \text{bytes}$：

$$
\frac{30{,}720{,}000{,}000}{10^9}=30.72\ \text{GB}.
$$

### 题 3：Disk access time

**题目：** 对 `7,200 RPM`、`9 ms` average seek、`400 sectors/track`，按课件取整顺序求平均 access time。

**答案：** 一圈 $60/7200=8.333\ldots$ ms；平均半圈 $4.166\ldots$ ms，课件先取 `4 ms`；sector transfer 为 $8.333\ldots/400=0.020833\ldots$ ms，课件取 `0.02 ms`。所以：

$$
T_{access}=9+4+0.02=13.02\ \text{ms}.
$$

保留小数到最后约为 `13.19 ms`，差异来自取整时点。

### 题 4：Locality 与 loop order

**题目：** 对 row-major `a[M][N]`，说明 inner `j` 与 inner `i` 的 stride。对访问式 `a[k][i][j]`，给出从 outer 到 inner 的最佳课堂顺序。

**答案：** Inner `j` 沿同一行连续访问，是 stride-1；inner `i` 每次跨一整行，是 stride-$N$。对 `a[k][i][j]`，最右下标变化最快，因此 outer-to-inner 为 `k → i → j`。[L11 00:49:43-00:53:58]

### 题 5：Miss 分类

**题目：** 一个 4-slot cache 使用 $slot(i)=i\bmod4$，程序反复访问 blocks `0,4,8`。这是 capacity miss 还是 conflict miss？

**答案：** $|W|=3\le4$，总容量足够，不是 capacity。三个 blocks 都满足余数 0，只能进入 slot 0，互相驱逐，所以是 conflict miss。[L11 01:09:35-01:11:19]

### 题 6：$S/E/B/C$ 与地址字段

**题目：** 给定 $m=4,S=4,E=1,B=2$，求 $s,b,t,C$。

**答案：**

$$
s=\log_2 4=2,\qquad b=\log_2 2=1,
$$

$$
t=m-s-b=4-2-1=1,
$$

$$
C=SEB=4\times1\times2=8\ \text{bytes}.
$$

地址格式为 `tag(1)|set(2)|offset(1)`，$C$ 不含元数据。

### 题 7：Direct-mapped 轨迹

**题目：** 在题 6 的初始空 cache 中，判断 `0,1,7,8,0`。

**答案：** `0` miss，装 `[0,1]` 到 set 0；`1` hit，因为同 block 只改 offset；`7` miss，装 `[6,7]` 到 set 3；`8` miss 并以 `[8,9]` 驱逐 set 0 的 `[0,1]`；最后 `0` 再 miss 并驱逐 `[8,9]`。最后一次是 0/8 映射冲突，不是 cache 总体已满。

### 题 8：同容量 two-way

**题目：** 改为 $S=2,E=2,B=2,m=4$。求地址字段，并判断同一轨迹最后一次访问 0。

**答案：** $b=1,s=1,t=2$，容量仍为 $2\times2\times2=8$ bytes，地址格式为 `tag(2)|set(1)|offset(1)`。地址 0 与 8 仍都进 set 0，但可占两条 lines，因此 `[8,9]` 使用第二条空 line；最后访问 0 hit。

### 题 9：写策略

**题目：** 在默认 `write-back + write-allocate` 模型中，分别描述 write hit、write miss，以及脏 victim 被替换时的动作。

**答案：** Write hit 只更新 cache line 并置 dirty，不立即更新较低层。Write miss 先为目标 block 分配 line、从较低层取入，再在 cache 中写。若以后该 line 成为 dirty victim，必须先写回较低层，再由新 block 覆盖。

### 题 10：平均访问时间

**题目：** $T_{hit}=1$ cycle、$P_{miss}=100$ cycles。分别计算 97% 与 99% hit rate 的 $T_{avg}$。

**答案：**

$$
T_{97\%}=1+(1-0.97)100=4\ \text{cycles},
$$

$$
T_{99\%}=1+(1-0.99)100=2\ \text{cycles}.
$$

差异来自 miss rate 由 3% 降为 1%，不是只看 hit rate 增加 2 个百分点。

### 题 11：矩阵循环排列

**题目：** 在 row-major、8-byte double、32 B block、大 $N$、cache 容不下多行的前提下，给出六种排列的 misses/inner iteration，并指出最好的一组。

**答案：** 按行是 $8/32=0.25$，按列是 $1.0$。因此：

$$
M_{ijk/jik}=1.25,\qquad
M_{kij/ikj}=0.5,\qquad
M_{jki/kji}=2.0.
$$

`kij/ikj` 最好，因为 inner loop 中 $B$ 与 $C$ 都按行访问。这里是 misses/iteration，不是 cycles/iteration。

### 题 12：Blocking

**题目：** 在“一块容纳 8 doubles”、省略 matrix $C$ 流量的课堂模型中，推导 unblocked 与 blocked miss 总数，并写出 tile 驻留约束。

**答案：** Unblocked 每个输出为 $n/8+n=9n/8$ misses，乘 $n^2$：

$$
M_{unblocked}=\frac98n^3.
$$

Blocked 中，一个 input tile 为 $B^2/8$ misses；一个 output tile 处理 $n/B$ 对 input tiles：

$$
2\frac nB\frac{B^2}{8}=\frac{nB}{4}.
$$

再乘 $(n/B)^2$ 个 output tiles：

$$
M_{blocked}=\frac{n^3}{4B}.
$$

要求三个活动 tiles 同时驻留：

$$
3B^2<C.
$$

此处 $B$ 是 tile 边长，$C$ 与 $B^2$ 必须使用一致容量单位。

## 十五、建议复习顺序

1. **先建因果链**：读“总依赖链”“设备约束”“Locality”，能够从三组事实重新推出 hierarchy。
2. **再练慢层计算**：闭卷重算 disk capacity、`13.02 ms`、DMA path，确认理解为什么下层访问昂贵。
3. **建立通用缓存模型**：复述 $L_k$ 缓存 $L_{k+1}$、block transfer、hit/miss、cold/capacity/conflict。
4. **固定组织符号**：集中练 $S/E/B/C$ 与 $t/s/b$，每题都写单位，并声明 $C$ 不含元数据。
5. **手算状态变化**：先做 direct-mapped `0,1,7,8,0`，再做同容量 two-way，对比唯一变化是 associativity。
6. **补齐策略**：按“空 line → victim → dirty write-back”的顺序复习 replacement，再用二维表复习两条 write-policy 轴。
7. **进入成本模型**：重算 97%/99%，口述 L1 → L2 → L3 → DRAM，避免把 miss penalty 与 hit time 重复相加。
8. **把模型映射到代码**：先复习 stride 与 Memory Mountain，再重算六种矩阵循环排列。
9. **最后做 blocking**：特别标出两个 $B$ 的含义、公式省略 $C$ 流量、$3B^2<C$ 的单位和前提。
10. **集中处理未决项**：回到两份源笔记的“待核对项”，按时间戳回听。不要用外部资料静默替换课堂的不确定内容。

## 十六、双源审计记录

### 16.1 覆盖审计

| 用户要求 | Lecture 11 证据 | Lecture 12 证据 | 本模块位置 |
|---|---|---|---|
| Memory Hierarchy → Cache Memories progression | p.1-p.58 教学主线 | p.1-p.45 教学主线 | 一至十 |
| Device constraints | SRAM/DRAM、disk、SSD、power wall | Cache SRAM 与多级示例 | 二 |
| Locality/hierarchy dependency chain | p.41-p.58 | p.2-p.5、p.20-p.45 | 一、三、四、十 |
| $S,E,B,C$ 与地址字段 | 通用 block/placement 前置 | p.6-p.7 | 五 |
| Hit/miss/replacement/write policies | p.53-p.57 | p.7-p.16 | 四、六至八 |
| Performance calculations | Disk 与有效周期趋势 | p.18-p.19、p.24、p.27-p.44 | 二、九、十 |
| Key examples and boundaries | Disk、locality、0/4/8 conflict | 0/1/7/8/0、Memory Mountain、matrix/blocking | 全文及十一 |
| Misconceptions | 两讲易错点 | 两讲易错点 | 十二 |
| Mastery checklist | Lecture 11 掌握标准 | Lecture 12 掌握标准 | 十三 |
| 12 cumulative problems with answers | 前 5 题基础 | 后 7 题组织与性能 | 十四 |
| Review order | Lecture 11 复习顺序 | Lecture 12 复习顺序 | 十五 |

### 16.2 不确定性审计

本模块审计的是两份 `NOTES.md`，没有声称重新回听录像或重新解析 PPTX。以下与模块结论相关的未决项被保留：

1. Lecture 11 SRAM/DRAM refresh 口述冲突，正文采用课件 p.4，保留 `[需回听 00:03:21]`。
2. Lecture 11 flash page-size 范围 `512KB to 4KB` 可疑，未外部修正。
3. Lecture 11 flash endurance 在 p.5 写 erasings、p.38 写 repeated writes，只保留共同的磨损结论。
4. Lecture 11 disk `40,000×/2,500×` 没有课件归一化推导，未重新计算。
5. Lecture 11 supplemental p.59-p.66 不冒充课堂逐页口述；本模块只沿源笔记使用其趋势边界。
6. Lecture 12 请求数据宽度的具体 cache interface，老师明确不知道，本模块不推断。
7. Lecture 12 Memory Mountain 的低端口述读数与纵轴口述不一致，未据此计算倍率。
8. Lecture 12 stride-1 平台的 prefetch 层级是老师推测，未写成确定实现。
9. Lecture 12 `C << n` 存在量纲疑问，只保留“行太大、不能驻留”的意图。
10. Lecture 12 blocking 公式中的 $B$ 与 cache-organization 的 $B$ 不同，且公式省略 matrix $C$ 流量；全文均明确标注。

任何需要消除这些不确定性的复习，都应回到两份链接中的精确 `[需回听 ...]` 时间戳，而不是把外部常识写回课堂证据。
{% endraw %}
