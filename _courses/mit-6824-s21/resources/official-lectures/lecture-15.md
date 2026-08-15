---
uid: mit-6824-s21-resource-official-lecture-15
type: course
document_type: resource
resource_kind: official-lecture
resource_order: 315
course: mit-6824-s21
title: MIT 6.824 Spring 2021 官方 Lecture 15：Optimistic Concurrency Control（FaRM）
description: Lecture 15 跨媒体分段聚合后的官方讲次学习笔记。
excerpt: Lecture 15 跨媒体分段聚合后的官方讲次学习笔记。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/official-lectures/lecture-15/"
toc: true
official_lecture_number: 15
math: true
---

> **讲次身份**：这是一个官方讲次、两个连续媒体分段。课程视频 **Part 15** 与 **Part 16** 共同构成 Lecture 15；Part 16 是 “Lecture 15 continued”，不是 Lecture 16。真正的 Lecture 16 是后续 Spark 讲次。
>
> **聚合范围**：本文综合两个分段的完整课堂笔记、Lecture 15 阅读指南与课程 MATERIALS 条目，按教师的统一讲授进程重组，不复制各 section 的完整正文。课堂只建立部分正确性与恢复直觉；论文层面的完整机制、评估数字和课堂未决问题会明确分开。

## 入口与证据范围

- [Lecture 15 Part 1 完整 NOTES](/courses/mit-6824-s21/lectures/015/)
- [Lecture 15 Part 2 完整 NOTES](/courses/mit-6824-s21/lectures/016/)
- [Lecture 15 阅读指南](/courses/mit-6824-s21/readings/lecture-15/)
- [MATERIALS：Lecture 15](/courses/mit-6824-s21/materials/#lecture-15-optimistic-concurrency-control-farm)

证据使用规则：

1. **教师进程与时间范围**以两份 NOTES 的 transcript 整理为准。
2. **论文协议、完整 recovery 结构和 evaluation**以阅读指南对指定 FaRM 论文、FAQ 与 Question 的整理为准。
3. MATERIALS 确认两个视频共享同一 paper、FAQ、Question 和 lecture notes。
4. 对课堂没有完成的证明、问答或 transcript 缺词，只保留可确认的最小结论，不用外部知识补齐。

## 双媒体与时间范围图

| 官方讲次 | 媒体分段 | 时间范围 | 在统一讲授中的作用 |
| --- | --- | --- | --- |
| Lecture 15 | Part 15 | 00:00:00-00:19:57 | 从 Spanner 对照进入 FaRM 的单数据中心目标、region 主备、UPS-backed NVRAM、对象 header 与 transaction API。 |
| Lecture 15 | Part 15 | 00:20:01-00:39:58 | Kernel bypass、polling、one-sided RDMA、RDMA log/message queue，以及传统 server-side locking 与 one-sided read 的矛盾。 |
| Lecture 15 | Part 15 | 00:39:58-01:09:52 | 从硬件约束推出 OCC，逐步讲 Figure 4 的 Execute、LOCK、VALIDATE、COMMIT-BACKUP、COMMIT-PRIMARY 与 TRUNCATE。 |
| Lecture 15 | Part 15 | 01:09:52-01:18:32 | 用两个并发 `x=x+1` 事务建立 strict serializability 直觉，并把 validation 的第二个例子与 fault tolerance 留到续段。 |
| Lecture 15 | Part 15 | 01:18:41-01:34:34 | 课后问答：read-only fast path、冲突与长事务、logical version、per-pair ordering、locality，以及重叠事务的实时顺序。 |
| Lecture 15 continued | Part 16 | 00:00:04-00:07:26 | 明确续讲身份，快速复盘 Part 1 的 Figure 4 正常路径。 |
| Lecture 15 continued | Part 16 | 00:07:34-00:12:35 | 用交叉条件写解释 VALIDATE 为什么必须同时检查 version 与 lock bit。 |
| Lecture 15 continued | Part 16 | 00:12:40-00:19:01 | Read-only fast path 问答、validation 必要性的证据边界，以及对 strict serializability 示例强度的再次限定。 |
| Lecture 15 continued | Part 16 | 00:19:01-00:23:30 | 从“已经回复 committed 就不能丢 writes”出发，盘点恢复所需的 write-content evidence 与 commit-decision evidence。 |
| Lecture 15 continued | Part 16 | 00:23:32-00:26:35 | 总结低冲突、全内存、单数据中心复制和特殊硬件四类适用边界。 |
| Lecture 15 continued | Part 16 | 00:26:35-00:27:57 | 结束 FaRM 与 transaction 单元，只引出 Spark；不包含 Spark 的实质教学。 |

总时长按 MATERIALS 约为 `94.6 + 28.0` 分钟。逐段笔记采用 transcript 的更精确时间边界；两种写法不是两个不同讲次。

## 先修概念

开始本讲前，应能解释：

- Sharding、region、primary/backup replication，以及 $f+1$ replicas 容忍至多 $f$ 个副本丢失时“每个 region 至少仍有一份”的前提。
- Distributed transaction、atomic commit、Transaction Coordinator（TC）、commit/abort，以及 2PC 的基本角色划分。
- Serializability 与 strict serializability；尤其是非重叠事务的 real-time order。
- Lock、logical version、atomic test-and-set / compare-and-swap 的用途。
- RAM、SSD、NIC、kernel network stack、RPC、interrupt 与 polling 的基本数据路径。
- ZooKeeper 管理配置/成员关系与对象级 transaction lock 是两个不同层次的问题。
- Lecture 14 对 Spanner geographic replication 与 TrueTime 的讨论只作为目标对照；FaRM 不使用 TrueTime 排序对象更新。

## 教师跨 Part 的统一推进

### 1. 先限定比较口径，再提出性能问题

教师从 Spanner 转入 FaRM，不是宣称后者在相同条件下全面更快。Spanner 为跨地域同步复制和数据中心级容灾付出网络时延；FaRM 是单数据中心 research prototype，集中研究怎样降低存储、网络和 server CPU 成本。两者都涉及 sharding、replication 与 distributed transactions，但故障地理范围和优化目标不同。

因此，FaRM 的高吞吐必须与以下条件一起阅读：数据可放入 aggregate RAM、workload 冲突较少、使用 RDMA/NVRAM 相关硬件、复制位于一个 data center 内。性能数字不能脱离这些条件与 Spanner 直接排名。

### 2. 先移除存储路径，再移除网络软件路径

FaRM 把 address space 切成约 `2 GB` 的 regions。每个 region 有 primary 和 backups，Configuration Manager（CM）维护 region 到 replicas 的映射，ZooKeeper 持久化并协调 configuration changes。Application 与 FaRM storage 运行在同一批机器上；执行 transaction 的 application thread 同时承担 unreplicated coordinator 的角色。

对象由 OID 标识，课堂把它解释为 `region number + region 内 offset`。OID 不是固定机器物理地址；region 搬迁后由当前 configuration 重新解析。每个对象有一个 64-bit header：最高位是 lock bit，其余 63 位是 logical version。

正常 transaction 不等待 SSD。课堂所谓 NVRAM 是普通 DRAM 加供电保护和 SSD 的系统组合：相关断电发生时，UPS/Local Energy Storage 提供短时电力，让系统停止事务并把 memory image 写入 SSD；普通 machine crash 仍依赖 replication 与 recovery。多份 DRAM 副本本身不能处理整个数据中心同时断电。

在网络侧，kernel bypass 让 application 在 setup 后直接访问 NIC queues，polling 避免逐包 interrupt。One-sided RDMA read 由源端 software 发起，目标 NIC 直接读取 RAM，不运行目标 CPU 代码。Write RDMA 可追加 per sender-receiver pair 的 transaction log，也可向 message queue 写请求；后一种路径仍需要目标 polling thread 执行 RPC handler。

RDMA hardware ACK 的语义必须严格限定：它证明 bytes 已写入远端授权的 memory/NVRAM log，不证明目标 application 已处理 record，也不证明 object in-place value 已更新。访问权限由 OS、application 与 NIC 在 connection setup 时建立；kernel bypass 不等于没有隔离。

### 3. 从 one-sided read 的约束推出 OCC

传统 pessimistic locking 会在 read 前要求 server-side code 取得锁，并可能等待锁释放；这会破坏 one-sided RDMA read 的 fast path。FaRM 因此在 Execute 阶段乐观地读取：coordinator 取回 object 与 version，在本地记录 read/write sets，并把 new values 暂存在本地 buffer，不立即覆盖远端对象。

到 commit 时再检查：

$$
lock=0 \land v_{current}=v_{read}.
$$

对 write set，这个条件在 primary 上由原子锁操作检查，成功后设置 lock bit；对 read-but-not-written set，coordinator 重读 header 做 VALIDATE，不设置 read lock。任一对象已锁或 version 改变，整个 transaction abort，应用通常从新状态 retry。

OCC 的 tradeoff 因而很清楚：读路径少了 server participation 与长期 read locks，但冲突越多、事务越长，越可能在 commit 前丢弃已经完成的工作。等待已有 write lock 并不能挽救旧计算，因为 buffered new value 已基于过期输入。

论文/FAQ 还强调一个容易忽略的 contract：单对象 read 返回 committed data，但 Execute 期间跨对象读取不保证已经组成 atomic snapshot。只有成功 committed transactions 获得 strict serializability；不能验证的组合必须 abort，application 也要能承受 commit/abort 前的暂时不一致。

### 4. Figure 4 正常事务协议

统一顺序是：

```text
EXECUTE
  -> LOCK(write set at primaries)
  -> VALIDATE(read-but-not-written set)
  -> COMMIT-BACKUP(all relevant backups ACK)
  -> COMMIT-PRIMARY(at least one primary ACK before client success)
  -> TRUNCATE(lazy cleanup)
```

#### Execute

Coordinator 对 primaries 做本地 load 或 one-sided RDMA reads，保存 OID/address、version 和 read set；updates 只进入 coordinator 的本地 buffer。此时其他 transactions 看不到这些 tentative writes。

#### LOCK

Coordinator 向 write-set 对应 primaries 的 incoming logs 追加 LOCK records。课堂与阅读指南支持的核心字段包括 transaction identity、object/OID、读取时的 version 和 new value。Primary polling thread 处理 record，对 64-bit header 原子检查“未锁且 version 未变”，成功则置 lock bit 并回复；失败则 coordinator abort，不等待。

LOCK 通过后，write set 不再能被另一个成功提交的 writer 同时改动。但包含只读依赖的 transaction 仍必须完成 VALIDATE。

#### VALIDATE

Coordinator 对 read-but-not-written objects 重读 lock/version。默认路径是 one-sided RDMA；阅读指南根据论文指出，同一 primary 上对象数超过阈值时可以改用 RPC，以权衡多次 RDMA read 与一次 server RPC 的成本。课堂没有把这个阈值作为主线展开。

VALIDATE 必须同时检查 lock bit 与 version：并发 writer 可能已经置锁，但尚未安装 new value 或增加 version；只比较 version 会漏掉这个窗口。

#### COMMIT-BACKUP

LOCK 与 VALIDATE 全部通过后，coordinator 已作出正常路径上的 commit decision，但还不能向 application 报 success。它先把包含完整 update payload 的 COMMIT-BACKUP records 写到所有相关 backups 的 non-volatile logs，并等待所有 hardware ACKs。此时 backup CPU 不在 critical path。

#### COMMIT-PRIMARY

所有 backup writes 被确认后，coordinator 向 primaries 写 COMMIT-PRIMARY record。至少一个 primary 的 NIC ACK 该 commit record 后，系统有 transaction-level commit evidence，coordinator 才可向 application 返回 success。Primary 后台处理相应 record 时安装 new values、增加 versions 并清除 locks，使更新可见。

这里要区分四个事件：

1. LOCK/VALIDATE 允许 transaction 进入 commit；
2. Update payload 已进入所有相关 primary/backup logs；
3. 至少一条 COMMIT-PRIMARY 保存最终 decision；
4. Object values 最终安装并对其他 transactions 可见。

它们不是同一个时刻，NIC ACK 也不能把第 2 或第 3 项自动变成第 4 项。

#### TRUNCATE

Primaries/backups 在安全前保留 records，之后 lazy truncate。Log 回收不在 client-visible commit 的关键路径上，可与后续工作重叠。正常路径由 coordinator fan out 到 primaries 和 backups，不是 primary 收到 write 后自动同步转发 backup。

## 跨 Part 边界的两个正确性例子

### 同一对象的两个并发增量

Part 1 令 $T_1,T_2$ 都读取初始 `x=0, version=0`，各自缓冲 `x=1`。若两者同时竞争 LOCK，64-bit header 的原子更新只允许一个成功：

- Loser 在 winner 持锁时尝试，会看到 `lock=1` 并 abort。
- Loser 在 winner 安装值、增加 version、解锁后尝试，会看到 $v_{current}\ne v_{read}$ 并 abort。

因此不能出现“两个 transaction 都报告 success，但最终只有 `x=1`”。Loser retry 后必须重新读取新值和新 version。

### 交叉条件写：Part 2 补上 VALIDATE 的作用

Part 2 从 Part 1 留下的 validation 问题继续，使用：

$$
T_1: R(x=0);\ \text{if }x=0\text{ then }W(y=1),
$$

$$
T_2: R(y=0);\ \text{if }y=0\text{ then }W(x=1).
$$

初始 $(x,y)=(0,0)$ 时，任一串行次序只能得到 $(0,1)$ 或 $(1,0)$，不能得到 $(1,1)$。课堂排程让 $T_1$ 先 LOCK $y$、再 VALIDATE $x$；随后 $T_2$ LOCK $x$、VALIDATE $y$。即使 $y$ 的 version 尚未增加，$T_2$ 也会看见 $T_1$ 设置的 lock bit，于是 abort。

这个例子解释了 lock bit 对 read/write conflict detection 的必要性，也完成了两个视频的概念接力；教师两次强调，它是正确性直觉，不是对所有 interleavings 的形式化证明。

### Strict serializability 的实时边界

若 $end(T_1)<start(T_2)$，strict serializability 强制 $T_1$ 排在 $T_2$ 前。若两个 transaction intervals 重叠，则谁先开始或先返回并不唯一决定 serial order；只要读写结果允许，可以选择一个等价串行顺序。

阅读指南从论文总结：committed read-write transaction 的 serialization point 是取得全部 write locks 的时刻，committed read-only transaction 的 serialization point 是最后一次 read。Serialization point 位于 transaction start 与 completion 之间，因此还能尊重非重叠事务的 real-time order。课堂本身只通过上述例子和问答建立这一方向，没有给出完整证明。

## Read-only fast path

没有 write set 的 transaction 不执行 LOCK、不追加 update/commit logs，也不写 object。其路径是：

```text
one-sided RDMA execution reads
  -> one-sided RDMA validation reads
```

课堂所说 “two one-sided RDMAs” 指读取和验证两轮协议阶段，不代表读取多个 objects 时总共只有两个 packets。账户余额汇总是教师给出的 read-only transaction 用途示例。

教师确认：若系统中所有并发 transactions 都只读，第二轮 validation 不必要。对 mixed workload 中某些具体排程，尤其现场提出的 blind-write 变体，教师没有完成推导；本文不替课堂补结论。

## Replication、failure 与 recovery

### 课堂建立的最小恢复不变量

Part 2 从一条安全底线开始：

$$
\text{reported committed} \Rightarrow \text{writes survive allowed failures}.
$$

向 application 返回 success 前，课堂确认三类事实：

1. 相关 primaries 的 LOCK records 保存待写内容；
2. 所有相关 backups 的 COMMIT-BACKUP records 保存 update payload；
3. 至少一个 primary 已 ACK COMMIT-PRIMARY，保存 commit decision。

LOCK/COMMIT-BACKUP 说明“写什么”，COMMIT-PRIMARY 说明“是否已经决定 commit”。只有 LOCK record 不能推出 commit，因为它产生在 validation 和最终 decision 之前。

课堂随后构造 commit point 后立即 crash、某个 backup 丢失的排程。在每个 shard 只有 primary/backup 两份、每个 shard 最多丢一份 replica 的例子假设下，surviving COMMIT-PRIMARY 证明 decision，其他 surviving records 仍描述各 shard 的 writes，因此 recovery process 有足够 pieces 完成已确认事务。

这只是 evidence sufficiency 的直觉。教师明确没有讲完整 recovery algorithm，也没有穷尽全部 crash combinations。

### 论文层面的恢复结构

阅读指南对指定论文补充了课堂没有展开的层次：

- Failure model 允许 machines crash；在每个 object 至多 $f$ 个 replicas 丢失 NVRAM 内容时，committed state 仍应 durable。
- One-sided RDMA 的目标 NIC 不运行 application lease checks，因此 FaRM 需要 precise membership。新 configuration 开始 mutation 前，surviving members 要对 membership 一致；clients 不再向已移除机器发 RDMA，并忽略其 read results 或 write ACKs。
- Configuration change 由 CM 探测多数、借 ZooKeeper 更新 configuration、remap regions，并等待旧资格安全失效。
- 论文把 recovery 分为 failure detection、reconfiguration、transaction state recovery、bulk data recovery 和 allocator state recovery。
- Transaction-state recovery 要收集/补齐 logs、恢复 locks、汇总各 regions 的信息并保留已经决定的 outcome：已公开或已报告 committed 的 transaction 必须继续 commit，已 abort 的不能复活。
- Lock recovery 后可先恢复 foreground service；补齐完整 replica count 的 bulk recovery 可在后台 pacing。

这些内容来自论文阅读整理，不应倒写成 Part 2 已逐步讲过的课堂算法。

## Evaluation：数字、条件与解释边界

以下数字来自阅读指南对论文实验的整理，不是教师在两个视频中逐项演示的测量：

| 场景 | 论文整理结果 | 必须同时保留的条件 |
| --- | --- | --- |
| TATP | 90 machines 上约 `140 million transactions/s`；median `58 us`，99th percentile `645 us` | Read-dominated mix、RDMA/NVRAM assumptions、数据布局和较低冲突共同作用。 |
| TPC-C new-order | 约 `4.5 million transactions/s`；median `808 us`，99th percentile `1.9 ms` | Transaction 更复杂；论文使用 locality-aware partitioning，约 `10%` transactions 访问 remote data。 |
| Read-only lookup | 约 `790 million lookups/s`；median `23 us` | 该实验已 CPU-bound，增加 NIC 数量并未让吞吐翻倍。 |
| Typical TATP single-machine failure | 约 `40 ms` 回到 peak throughput，约 `39 ms` 时所有 regions active | Foreground 恢复与完整后台 re-replication 是不同指标。 |
| TPC-C failure | 少于约 `50 ms` 恢复大部分 throughput；完整 re-replication 可能超过 4 分钟 | Locality placement 会降低 data-recovery parallelism。 |

阅读指南还记录：40 次 TATP recovery experiments 的 median 约 `50 ms`，超过 70% 少于 `100 ms`，全部少于 `200 ms`；CM failure recovery 约 `110 ms`；同时 failure 18/90 machines 的实验约 `400 ms` 恢复 peak throughput。摘要式 “less than 50 ms” 必须与具体 failure scope、前台指标和实验分布一起读。

课堂开场口述约 `1.4 亿` TATP transactions/s，而共享 notes 另有约 `1 亿` 的概述数字。阅读指南把 `1.4 亿` 对应到论文 Figure 7 的 90-machine 配置；不能把不同配置或概述口径强行合成一个无条件常数。

## 官方 Paper Question 的关键连接

官方题目要求分析两个同时开始、读取同一初值并都递增同一对象的 FaRM transactions；第一笔已经**完全提交结束**，第二笔才开始 commit，且没有 failure。需要指出 evidence 和 Figure 4 phase。

沿本讲协议可得到精确连接：

1. 两笔 transaction 在 Execute 时都保存相同的 `v_read` 和各自的 buffered new value。
2. 第一笔完全提交后，primary 已安装新值、增加 object version 并清除 lock。
3. 第二笔进入 **LOCK phase**，其 LOCK record 带着旧的 `v_read`。
4. Primary 原子比较当前 header 时发现 $v_{current}\ne v_{read}$，拒绝取锁；这就是题目指定排程中的 evidence、观察组件和首次 abort 点。

题目特意说第一笔“completely finishes committing”，所以提交主体应回答 **version mismatch at LOCK**，而不是 lock bit。Lock bit 是另一种更早交错的证据：若第二笔在第一笔仍持锁时开始 LOCK，它会因 `lock=1` abort。两种情况都在课堂出现，但不能混淆题目给定的时间线。

## 易错点、证据边界与未决项

1. **两个媒体不是两讲。** Part 16 仍是 Lecture 15；它在 00:26:35 后收束 FaRM，最后只引出 Spark。
2. **FaRM 与 Spanner 目标不同。** 单数据中心吞吐不能直接否定 geographic replication 的成本与价值。
3. **NVRAM 不是普通 DRAM 天生不挥发。** 本讲语境是供电保护、SSD flush、replication 与 recovery 的组合。
4. **OID 不是固定机器地址。** 它由 region identity 与 region 内位置组成，当前 replicas 由 configuration 解析。
5. **ZooKeeper lock 不是 object lock。** ZooKeeper/CM 管配置；transaction lock 位于对象的 64-bit header。
6. **RDMA write 不等于 server 已执行。** NIC ACK 只证明远端 memory write 完成。
7. **LOCK 也不是纯 one-sided 事务逻辑。** Record 可用 RDMA 追加，但 primary CPU 仍要 poll、检查 version/lock 并原子置锁。
8. **Version 不是 TrueTime。** 它是 per-object logical version；FaRM 不依赖全局物理时间给并发事务排序。
9. **LOCK record 不是 commit decision。** 它包含 update information，但 transaction 之后仍可能 abort。
10. **Strict serializability 保证 successful commits。** Execute 期间跨对象 temporary inconsistency 不自动违反该保证。
11. **课堂例子不是完整 proof。** 并发增量与交叉条件写只展示关键冲突路径；Part 2 的 crash 排程也不是完整 recovery protocol。
12. **Read-only validation 问答保留未决。** 教师确认全只读环境可省，但没有完成 mixed workload/blind-write 变体的现场推导。
13. **Part 2 transcript 在约 00:12:23 缺少否定语义。** 前后“validation fails”“T2 aborts”一致支持“两者不能都 commit”，但原句仍应回听。
14. **原子指令措辞未完全统一。** 课堂说 test-and-set，共享材料也用 compare-and-swap；可靠结论仅是 version/lock 的检查与设置必须原子。
15. **Crash 例子的具体 record 指代有口语歧义。** 可确认的是 surviving decision 加各 write 的 surviving information；更精确位置要对照原视频 Figure 4。
16. **Locality hint 只得到高层解释。** 教师当场没有核对具体 API；不能把“共置相关 objects 可少联系 primaries”扩展成确定实现细节。

## 推荐学习顺序

1. 先看本文件的“双媒体与时间范围图”，确认一个 Lecture 15 被拆成两个媒体，并划清 Part 2 末尾 Spark 过渡的边界。
2. 复习 prerequisites：2PC、primary/backup、serializability、lock/version 和基本网络路径。
3. 阅读 Part 1 的 00:00:00-00:39:58，画出 regions、primaries/backups、CM/ZooKeeper、UPS/SSD、NIC queues、one-sided RDMA 与 message queues。
4. 阅读 Part 1 的 00:39:58-01:09:52，闭卷重画 Figure 4，并为每个 phase 标注谁执行 CPU code、record 写到哪里、等待哪类 ACK。
5. 用 Part 1 的并发增量例子回答官方 Paper Question，特别区分“仍持锁”和“已完全提交”两种 evidence。
6. 紧接着阅读 Part 2 的 00:07:34-00:12:35，用交叉条件写验证 lock bit 对 VALIDATE 的必要性；这是跨 part 最关键的概念接点。
7. 阅读 Part 2 的 read-only 问答，记住 fast path，同时保留教师没有解决的 mixed/blind-write 排程问题。
8. 把 LOCK/COMMIT-BACKUP 与 COMMIT-PRIMARY 分成“写什么”和“决定什么”两列，再走 Part 2 的 commit-point crash 例子。
9. 最后读阅读指南的 recovery 与 evaluation，严格标注哪些是论文层面的完整机制，哪些只是课堂直觉。
10. 用低冲突、全内存、单数据中心复制、特殊硬件四项重新解释所有性能数字，避免只背峰值。

## 掌握清单

- [ ] 能准确说明为什么 Part 15 与 Part 16 属于同一官方 Lecture 15。
- [ ] 能画出 region、primary/backups、CM/ZooKeeper、application/TC 和 per-pair logs/queues。
- [ ] 能解释 UPS-backed NVRAM 能处理什么，以及它为何不取代 replication。
- [ ] 能区分 kernel bypass、one-sided RDMA、RDMA-based RPC 和 hardware ACK。
- [ ] 能从“one-sided read 不运行远端 CPU”推导 FaRM 为什么采用 OCC。
- [ ] 能写出 LOCK 与 VALIDATE 的共同条件，并说明两者对象范围和执行成本不同。
- [ ] 能完整复述 Execute 到 TRUNCATE 的顺序、参与者、record、ACK 与可见性变化。
- [ ] 能在同对象增量例子中分别定位 lock-bit conflict 与 version mismatch。
- [ ] 能推演交叉条件写，说明为何只看 version 会错误地允许非法状态。
- [ ] 能解释 strict serializability 对重叠与非重叠 transactions 的不同实时约束。
- [ ] 能区分 write-content evidence、commit-decision evidence、object installation 和 client success。
- [ ] 能明确课堂 recovery 直觉与论文完整 recovery protocol 的证据层级。
- [ ] 能解释 read-only fast path，并复述 validation 问答中仍未解决的边界。
- [ ] 能在引用 evaluation 数字时同时说出 machines、workload、hardware、conflicts 和 failure metric。
- [ ] 能用四类部署限制判断一个 workload 是否适合 FaRM，而不是只引用峰值吞吐。

## 12 组累积问答

### 1. 为什么一个官方 Lecture 15 会有两个媒体分段？

课程源把 FaRM 讲授拆成 Part 15 和 Part 16。Part 1 从系统目标讲到正常事务协议与第一个并发例子；Part 2 明确以 “finish off FaRM” 续接 validation、fault tolerance 和限制。MATERIALS 让二者共享同一 paper、FAQ、Question 和 lecture notes，所以 Part 16 不是 Lecture 16。

### 2. 为什么不能只凭吞吐数字说 FaRM 胜过 Spanner？

FaRM 优化单数据中心、全内存、RDMA 环境中的 server CPU 与网络路径；Spanner 承担跨地域同步复制和数据中心故障范围。目标、failure geography、workload 与指标不同，数字没有同条件可比性。

### 3. FaRM 的基本 architecture 是什么？

Global address space 被切成 regions，每个 region 有一个 primary 和若干 backups。CM/ZooKeeper 管 region-to-replica configuration。Application 与 storage 共用机器，执行 transaction 的 thread 充当 coordinator；对象通过 region+offset 的 OID 定位，并用 lock bit/version header 支持 OCC。

### 4. 为什么有多个 RAM replicas 仍需要 UPS 与 SSD？

Machine crash 可以由其他 replicas 承担，但整个 data center 断电是相关故障，所有 DRAM 可能同时丢失。供电保护让系统在断电路径把 memory image 写到 SSD；正常 transaction 不同步等待 SSD。Replication 与 power-failure persistence 解决的是不同 failure 情形。

### 5. One-sided RDMA 与 RDMA-based RPC 有什么区别？

One-sided RDMA 由目标 NIC 直接读写授权 memory，不运行目标 CPU 代码。RDMA-based RPC 只是用 write RDMA 把 request 放进 queue，目标 polling thread 仍要处理并回复。Hardware ACK 只证明 memory write 完成，不证明 RPC handler 或 transaction record 已执行。

### 6. 为什么 FaRM 选择 OCC，而不是 read 时先锁？

Read 时先锁需要远端 server code 和等待，会失去 one-sided RDMA 的主要收益。FaRM 先无锁读取并本地缓冲 updates，commit 时集中 LOCK write set、VALIDATE read-only set。代价是冲突在后期才暴露，transaction 可能 abort/retry。

### 7. LOCK 与 VALIDATE 分别检查什么？

两者都要求当前 version 等于 execute 时保存的 version 且 lock bit 未设置。LOCK 面向 write set，由 primary 原子检查后置锁，需要 server participation；VALIDATE 面向 read-but-not-written set，默认由 coordinator one-sided 重读 header，不设置读锁。任一失败都 abort 整个 transaction。

### 8. 为什么提交顺序必须是 COMMIT-BACKUP 后再 COMMIT-PRIMARY？

在公开 commit decision 前，所有相关 backups 必须先保存完整 update payload 并 ACK，否则 primary 随后 failure 可能让已确认的 write 丢失。COMMIT-PRIMARY 再保存 transaction-level decision；至少一个 primary ACK 后才可回复 client。Update evidence 与 decision evidence 缺一不可。

### 9. 官方 Paper Question 的精确答案落在哪个 phase？

题目规定第一笔已经完全提交，故对象已解锁且 version 已增加。第二笔在 LOCK phase 把旧 `v_read` 交给 primary；primary 发现 current version mismatch，拒绝 lock，第二笔在此 abort。若第一笔尚持锁，则 evidence 会是 lock bit，但那不是题目指定的排程。

### 10. 交叉条件写为什么证明 VALIDATE 必须看 lock bit？

$T_1$ 锁住 $y$ 后，可能还没安装 `y=1`，所以 version 仍是旧值。此时 $T_2$ 验证自己读过的 $y$；若只比较 version 会漏检，检查 lock bit 才会发现并发 writer 并 abort，从而阻止不可串行化的 $(1,1)$。该例提供机制直觉，不是完整证明。

### 11. Client success 后 crash，系统凭什么保留已提交事务？

回复前，primaries 的 LOCK records 和 backups 的 COMMIT-BACKUP records保存各 writes，至少一个 COMMIT-PRIMARY 保存 commit decision。在课堂允许的 replica failure 示例中，surviving decision 与各 write 的 surviving information 足以让 recovery 完成事务。完整的 reconfiguration、state recovery 与 replica rebuild 来自论文，不是课堂逐步讲授的算法。

### 12. 怎样正确解读 FaRM 的 evaluation？

把每个数字和条件一起说出：90-machine RDMA/NVRAM research cluster、TATP/TPC-C 的具体 mix、数据布局、较低 conflict，以及 measurement 是正常吞吐、foreground recovery 还是完整 re-replication。`140 million TATP transactions/s` 或几十毫秒恢复都不是任意 workload、任意 failure scope、普通硬件或跨地域部署的保证。
