---
uid: mit-6824-s21-resource-reading-13
type: course
document_type: resource
resource_kind: reading
resource_order: 113
course: mit-6824-s21
title: Lecture 13 阅读指南：Distributed Transactions
description: Lecture 13 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 13 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-13/"
toc: true
official_lecture_number: 13
math: true
---

## 1. 来源、指定范围与证据边界

- 指定阅读：**6.033 Chapter 9** 的 `§9.1.5`、`§9.1.6`、`§9.5.2`、`§9.5.3`、`§9.6.3`；课程特别指出最后两节 two-phase locking 与 distributed two-phase commit 最重要。
- Chapter 9 在本仓库是 external-only resource，没有归档正文；本指南只保存官方 URL、指定范围与阅读问题，不转述无法在本地核验的章节细节。
- 本讲另有归档的课堂讲义 `l-2pc.txt`、官方 FAQ 与 Paper Question。FAQ 是补充解释，不代表每一项都在 lecture transcript 中按时间顺序讲过。
- Lecture `NOTES.md` 的课堂 chronology 只依据本讲 transcript 与 `l-2pc.txt`；Chapter 9 和 FAQ 中未口述的 three-phase commit、two-generals、lock upgrade 等内容，不反向写成老师课堂上讲过。

资源：

- [Lecture 13 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-13.md)
- [6.033 Chapter 9 官方入口](https://ocw.mit.edu/resources/res-6-004-principles-of-computer-system-design-an-introduction-spring-2009/online-textbook/)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-2pc.txt)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/chapter9-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/13-q-chapter9.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-13-distributed-transactions)
- [Lecture 13 NOTES](/courses/mit-6824-s21/lectures/013/)
- [Lecture 13 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=13)

## 2. 阅读任务与问题地图

按课程指定范围阅读 Chapter 9 时，用下面问题约束摘录；遇到本仓库没有正文证据的细节，应回到官方页面核对，不能凭 FAQ 或课堂笔记代替原文。

1. **Transaction context：** 多 records、多 clients、sharded servers 时，application writer 面对哪些 interleaving 与 partial-failure 风险？
2. **ACID boundary：** Atomic、Consistent、Isolated、Durable 各自约束什么；哪些约束属于 application invariant，哪些由 transaction machinery 支撑？
3. **Serializable outcome：** 如何同时比较 database changes 与 outputs，证明 concurrent execution 等价于某个 serial order？
4. **Concurrency control：** Pessimistic locking 与 optimistic validation 分别在何时处理 conflict，conflict 的代价是等待还是 abort/retry？
5. **2PL rules：** Record 使用前 acquire、commit/abort 后 release 如何禁止 partial observation；为何 incremental acquisition 又会产生 deadlock？
6. **Homework focus：** 构造一个 transaction 的额外 record 只在 rare branch 中使用的例子，比较 2PL 与开始前锁住全部 records 的 Simple Locking。
7. **2PC normal path：** Coordinator、participants、TID、tentative updates、PREPARE/YES、COMMIT/ABORT、ACK 各位于哪个步骤？
8. **Crash recovery：** Participant 的 YES/NO 与 coordinator 的 COMMIT decision 分别必须在发送什么 message 前 durable；restart 后怎样恢复同一 decision？
9. **Blocking：** Participant 已 YES 但看不到 coordinator decision 时，为什么既不能自行 commit，也不能自行 abort；哪些 locks 因而继续阻塞其他 transactions？
10. **Availability composition：** Raft 复制同一 service，2PC 协调不同 services；怎样组合二者，而不把 majority replication 误写成 cross-shard atomic commit？

建议维护两条并列因果链：

```text
concurrent transactions
  -> define serializable outcomes
  -> forbid illegal schedules
  -> pessimistic concurrency control
  -> two-phase locking
  -> lock waiting / deadlock
  -> detect and abort one transaction
```

```text
one transaction spans participants
  -> tentative local work + locks
  -> PREPARE and durable votes
  -> one coordinator decision
  -> durable COMMIT before notification
  -> replay/re-send after crash
  -> prepared participant may block
  -> replicate services for availability, while retaining 2PC for atomic commit
```

## 3. 课堂讲义的最小协议骨架

`l-2pc.txt` 是单页 textual handout。它把本讲总纲写成：

```text
distributed transactions
  = concurrency control for isolation/serializability
  + atomic commit for atomicity despite failure
```

课堂使用同一 transfer/audit family of examples，但口述与讲义的 transfer 方向相反：

- Lecture transcript：`x -= 1, y += 1`，合法余额为 `9,11`。
- Handout：`x += 1, y -= 1`，合法余额为 `11,9`。

两者的 serializability argument 相同，但复习时必须先声明采用哪一组 signs，不能混出一个不存在的 outcome。

### 3.1 2PL 检查清单

- 每个 record 有 lock；本讲主体先用 exclusive locks 简化。
- Transaction 第一次使用 record 前 acquire lock。
- 已取得 locks 保持到 commit/abort；提前 release 可暴露 intermediate/tentative value。
- 按需取得提高部分 workloads 的 concurrency，但不同 access orders 可形成 deadlock。
- Timeout 是近似 detection；wait-for graph cycle 是课堂给出的系统化 detection。
- Abort victim 后撤销其 tentative effects、释放 locks，client 决定是否 retry。

### 3.2 2PC 检查清单

```text
TC                       participant A/B
 |-- tentative work ---> lock + log temporary update
 |-- PREPARE(TID) ----->
 |<-- YES / NO ---------
 |  all YES: durable COMMIT
 |-- COMMIT(TID) ------> install + unlock + ACK
 |  any NO: ABORT
 |-- ABORT(TID) -------> discard + unlock
```

关键恢复顺序：

$$
durable(prepared, TID, tentative\ data) \prec send(YES, TID),
$$

$$
durable(COMMIT, TID) \prec send(COMMIT, TID).
$$

前者保证 participant restart 后仍能履行 promise；后者保证 coordinator 只通知部分 participants 后 crash，恢复时仍会重发同一个 global decision。

## 4. Archived FAQ 的补充使用方式

归档 FAQ 可以用来复核概念，但要保留来源标签：

- 它再次区分 2PL 与 2PC，说明两者只是名称相似。
- 它说明 participant 可能因丢失 tentative state、constraint violation 或 deadlock 对 PREPARE 回复 NO。
- 它用 wait-for graph cycle 与 timeout 解释 deadlock detection，并以 abort 打破 cycle。
- 它强调 prepared worker 在 TC crash 时必须持锁等待；该 blocking 可扩散到其他 transactions。
- 它说明 TID 用于给 concurrent transactions 的 messages、tables、temporary records 与 locks 分组。
- 它把 Raft 的 “多数 replicas 做相同工作” 与 2PC 的 “所有 participants 做不同工作” 对照。

FAQ 还讨论 three-phase commit、two-generals、read/write lock upgrade、logging alternatives 等课堂 chronology 未展开内容。这些适合作为课后延伸问题，不应出现在带 lecture timestamp 的段落中。

## 5. Paper Question / Homework

**题目原文（逐字保留）：**

> 6.033 Book . Read just these parts of Chapter 9: 9.1.5, 9.1.6, 9.5.2, 9.5.3, 9.6.3. The last two sections (on two-phase locking and distributed two-phase commit) are the most important. The Question: describe a situation where Two-Phase Locking yields higher performance than Simple Locking.

下面只给推理脚手架，不给可直接提交的场景或结论：

1. 先从指定章节确认题目中 **Simple Locking** 与 **Two-Phase Locking** 的精确定义，尤其是 locks 在何时取得、何时释放。
2. 自己选择一种会并发运行、且访问集合或访问时机会变化的 transaction workload；明确 records、读写集合与可能的执行路径。
3. 分别画出两种方案的 lock timeline：每把 lock 从何时开始阻塞其他 transaction，到何时释放。
4. 指出具体竞争者以及具体被阻塞的 record，不能只写“并发性更高”。
5. 比较 common path 上的等待、持锁时间、可并行区间与额外协议成本；必要时给一个简单频率或比例假设。
6. 检查你的比较是否真的由 locking policy 引起，而不是由缓存、复制、网络或硬件差异引起。
7. 最后说明 2PL 的代价：incremental lock acquisition 可能形成 deadlock，并需要 detection、abort 与 retry。

提交前自检：你的论证应包含一个具体 schedule，并能回答“哪一个 transaction 在哪段时间因为哪把 lock 而等待”；本指南不提供该 schedule 的成品答案。

## 6. 与课堂 NOTES 的连接

| 阅读主题 | 课堂位置 |
| --- | --- |
| Transaction motivation / ACID | `00:00:01-00:12:36` |
| Serializability 与 transfer/audit | `00:12:44-00:19:58` |
| Pessimistic/OCC 与 2PL | `00:19:58-00:29:57` |
| Deadlock / wait-for graph / homework | `00:29:59-00:37:36`、`00:44:51-00:46:39` |
| 2PC roles 与 normal path | `00:46:40-00:54:38` |
| Participant/TC logging 与 recovery | `00:55:02-01:04:16` |
| Blocking、Raft composition | `01:04:24-01:13:33` |
| 2PL/2PC boundary 与 durable NO | `01:14:37-01:21:12` |

使用顺序建议：先读 [Lecture 13 NOTES](/courses/mit-6824-s21/lectures/013/) 重建老师的 argument order，再按指定 Chapter 9 sections 回到原文核对 formal details，最后用 FAQ 定位疑问。若三者表述不同，课堂 chronology、assigned reading 和 FAQ explanation 应分别注明，不合并成一个无来源的“标准版本”。

## 7. 理解检查：10 组问答

1. **问：本讲究竟指定 Chapter 9 的哪些范围？**  
  **答：** 只指定 `§9.1.5`、`§9.1.6`、`§9.5.2`、`§9.5.3`、`§9.6.3`，并特别强调最后两节。其他章节不能因为主题相关就算作 assigned reading。（来源：Question）

2. **问：为什么本指南不逐节概述 Chapter 9 的模型和算法？**  
  **答：** Chapter 9 在仓库中是 external-only，没有可本地核验的正文；指南只能保存范围、入口和由归档 FAQ/课堂材料明确支持的补充，章节原意必须回官方页面核对。（来源：reading input 的 Archive Boundary）

3. **问：transaction 的 atomicity 在 bank transfer 例子中排除了什么状态？**  
  **答：** 排除只扣 Alice 而未给 Bob 入账，或只入账而未扣款的 partial outcome；transaction 必须 all-or-none。（来源：FAQ）

4. **问：2PL 与 2PC 分别解决什么问题？**  
  **答：** 2PL 是 records 的 concurrency-control 方案，用于 isolation/serializability；2PC 协调多个 participants 对同一 distributed transaction 作一致的 commit/abort 收尾。二者只是都含“two-phase”，功能不同。（来源：FAQ、课堂讲义）

5. **问：为什么 strict 形式的 2PL 要把 locks 保持到 commit/abort？**  
  **答：** 若 tentative update 的 lock 提前释放，另一 transaction 可能据此提交；前者随后 abort 或 crash 时，就会留下不可串行化的依赖结果。（来源：FAQ）

6. **问：2PL 为什么仍可能 deadlock，系统怎样处理？**  
  **答：** 两个 transactions 若以相反顺序取得 `R1`、`R2`，可各持一把并等待另一把；系统可用 timeout 或 wait-for graph cycle 检测，再 abort 一个 victim。（来源：FAQ、Lecture 13 NOTES）

7. **问：participant 在发送 YES/PREPARED 前必须持久化什么？**  
  **答：** 必须留下足以在 crash/restart 后履行承诺的 prepared state，包括 transaction identity、tentative data 与相关恢复信息；否则重启后无法安全完成已承诺的 transaction。（来源：FAQ、课堂讲义）

8. **问：prepared participant 在 TC crash 后为什么不能自行 abort？**  
  **答：** TC 可能已在 crash 前通知其他 participants commit；自行改变决定会破坏 atomicity，因此它只能持锁等待可恢复的 global decision，造成 2PC blocking。（来源：FAQ）

9. **问：为什么 Raft 不能直接替代 2PC？**  
  **答：** Raft 让多数 replicas 执行同一状态机操作；2PC 让不同 participants 执行 transaction 的不同部分并 all-or-none。实际系统可以用 Raft/Paxos 复制 participant 或 coordinator，但 cross-shard atomic commit 仍是另一层问题。（来源：FAQ、Lecture 13 NOTES）

10. **问：serializability 与 linearizability 的关键区别是什么？**  
   **答：** FAQ 将前者通常用于多操作 transactions，将后者通常用于单次 reads/writes；二者都要求某种 serial explanation，但 linearizability 还要求该顺序遵守 real-time order。（来源：FAQ）
