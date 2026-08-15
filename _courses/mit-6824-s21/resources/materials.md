---
uid: mit-6824-s21-resource-materials-2
type: course
document_type: resource
resource_kind: materials
resource_order: 2
course: mit-6824-s21
title: MIT 6.824 Spring 2021 Materials
description: 按讲次索引课程讲义、论文、FAQ、Question、Labs 与公开视频。
excerpt: 按讲次索引课程讲义、论文、FAQ、Question、Labs 与公开视频。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/materials/"
toc: true
---

> 本索引由官方 Spring 2021 schedule、资源归档 lock 和 Bilibili 分 P元数据生成。
> Papers、Questions、FAQ 和 Labs 是学习资源，不作为 PPT 页面参与 transcript 时间对齐。

## 归档状态

- 官方讲次：`21`；视频分段：`22`。
- 唯一资源：`154`；已下载：`129`；错误：`0`。
- 分类：`{'code': 2, 'code-archive': 1, 'course-page': 3, 'exam': 1, 'faq': 17, 'homework': 20, 'lab': 7, 'lecture-note': 18, 'official-video': 20, 'paper': 15, 'project': 1, 'reading': 3, 'reference': 2, 'subtitle': 44}`。
- Lecture 1 的 schedule 没有 paper Question；Lecture 6/8 是 Lab Q&A。
- Lecture 15 被拆为两个视频分段，但共享同一 paper、FAQ、Question 和 lecture notes。

## 课程级材料

- [Course home](/assets/courses/mit-6824-s21/materials/official-materials/course-pages/index.html)：`course-page`
- [General information](/assets/courses/mit-6824-s21/materials/official-materials/course-pages/general.html)：`course-page`
- [Official schedule](/assets/courses/mit-6824-s21/materials/official-materials/course-pages/schedule.html)：`course-page`
- [Project](/assets/courses/mit-6824-s21/materials/official-materials/project/project.html)：`project`
- [Lab 1: MapReduce](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-mr.html)：`lab`
- [Lab 2: Raft](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)：`lab`
- [Lab 3: KV Raft](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-kvraft.html)：`lab`
- [Lab 4: Sharded KV](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-shard.html)：`lab`
- [Lab guidance](/assets/courses/mit-6824-s21/materials/official-materials/labs/guidance.html)：`lab`
- [Lab collaboration policy](/assets/courses/mit-6824-s21/materials/official-materials/labs/collab.html)：`lab`
- [Go setup](/assets/courses/mit-6824-s21/materials/official-materials/labs/go.html)：`lab`
- [Past exams](https://pdos.csail.mit.edu/6.824/quizzes.html)：`exam`（外部链接）
- [Subtitle repository README](https://github.com/mayf09/6.824-2021-video-subtitles)：`reference`（外部链接）

## 按讲次材料

### Lecture 1: Introduction

**视频分段**

- [Part 1: Lecture 1 - Introduction](https://www.bilibili.com/video/BV16f4y1z7kn/?p=1)，约 `79.2` 分钟。

**课堂讲义**

- [Introduction](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l01.txt)

**指定论文**

- [MapReduce (2004)](/assets/courses/mit-6824-s21/materials/official-materials/papers/mapreduce.pdf)

**MIT 官方视频**

- [video](https://youtu.be/WtZ7pcRSkOA)

**相关 Lab**

- [Lab 1: MapReduce](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-mr.html)

**Paper Question / Homework**

- 官方 schedule 未为本讲列出 paper Question。

### Lecture 2: RPC and Threads

**视频分段**

- [Part 2: Lecture 2 - RPC and Threads](https://www.bilibili.com/video/BV16f4y1z7kn/?p=2)，约 `67.1` 分钟。

**课堂讲义**

- [RPC and Threads](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-rpc.txt)

**课堂代码**

- [crawler.go](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/crawler.go)
- [kv.go](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/kv.go)

**代码归档**

- [vote examples](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/condvar.tar.gz)

**其他 Preparation**

- [Online Go tutorial](https://tour.golang.org/)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/tour-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/oZR76REwSyA)

**Paper Question / Homework**

- The assigned reading for today is not a paper, but the Online Go tutorial . The assigned "question" is the Crawler exercise in the tutorial. Also, take a look at Go's RPC package , which you will use in lab 1.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/02-q-gointro.html)

### Lecture 3: GFS

**视频分段**

- [Part 3: Lecture 3 - GFS](https://www.bilibili.com/video/BV16f4y1z7kn/?p=3)，约 `66.3` 分钟。

**课堂讲义**

- [GFS](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-gfs.txt)

**指定论文**

- [GFS (2003)](/assets/courses/mit-6824-s21/materials/official-materials/papers/gfs.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/gfs-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/6ETFk1-53qU)

**相关 Lab**

- [Lab 2: Raft](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-raft.html)

**Paper Question / Homework**

- Describe a sequence of events that would result in a client reading stale data from the Google File System .
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/03-q-gfs.html)

### Lecture 4: Primary-Backup Replication

**视频分段**

- [Part 4: Lecture 4 - Primary-Backup Replication](https://www.bilibili.com/video/BV16f4y1z7kn/?p=4)，约 `93.0` 分钟。

**课堂讲义**

- [Primary-Backup Replication](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-vm-ft.txt)

**指定论文**

- [Fault-Tolerant Virtual Machines (2010)](/assets/courses/mit-6824-s21/materials/official-materials/papers/vm-ft.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/vm-ft-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/gXiDmq1zDq4)

**Paper Question / Homework**

- How does VM FT handle network partitions? That is, is it possible that if the primary and the backup end up in different network partitions that the backup will become a primary too and the system will run with two primaries?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/04-q-vm-ft.html)

### Lecture 5: Fault Tolerance - Raft (1)

**视频分段**

- [Part 5: Lecture 5 - Fault Tolerance - Raft (1)](https://www.bilibili.com/video/BV16f4y1z7kn/?p=5)，约 `99.4` 分钟。

**课堂讲义**

- [Fault Tolerance: Raft (1)](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-raft.txt)

**指定论文**

- [Raft (extended) (2014), to end of Section 5](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/R2-9bsKmEbo)

**Paper Question / Homework**

- Suppose we have the scenario shown in the Raft paper's Figure 7: a cluster of seven servers, with the log contents shown. The first server crashes (the one at the top of the figure), and cannot be contacted. A leader election ensues. For each of the servers marked (a), (d), and (f), could that server be elected? If yes, which servers would vote for it? If no, what specific Raft mechanism(s) would prevent it from being elected?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/05-q-raft.html)

### Lecture 6: Lab 1 Q&A

**视频分段**

- [Part 6: Lecture 6 - Lab 1 Q&A](https://www.bilibili.com/video/BV16f4y1z7kn/?p=6)，约 `86.6` 分钟。

**Paper Question / Homework**

- The lecture today is an Q&A session about the last submitted lab (e.g., lab 1 or lab2A+B). Submit a question about the lab: for example, something you wondered about while doing the lab, something you didn't understand, or just anything.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/06-q-QAlab.html)

### Lecture 7: Fault Tolerance - Raft (2)

**视频分段**

- [Part 7: Lecture 7 - Fault Tolerance - Raft (2)](https://www.bilibili.com/video/BV16f4y1z7kn/?p=7)，约 `108.8` 分钟。

**课堂讲义**

- [Fault Tolerance: Raft (2)](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-raft2.txt)

**指定论文**

- [Raft (extended) (2014), Section 7 to end (but not Section 6)](/assets/courses/mit-6824-s21/materials/official-materials/papers/raft-extended.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/raft2-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/h3JiQ_lnkE8)

**Paper Question / Homework**

- Could a received InstallSnapshot RPC cause the state machine to go backwards in time? That is, could step 8 in Figure 13 cause the state machine to be reset so that it reflects fewer executed operations? If yes, explain how this could happen. If no, explain why it can't happen.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/07-q-raft2.html)

### Lecture 8: Lab 2A_2B Q&A

**视频分段**

- [Part 8: Lecture 8 - Lab 2A_2B Q&A](https://www.bilibili.com/video/BV16f4y1z7kn/?p=8)，约 `93.0` 分钟。

**Project**

- [Final Project](/assets/courses/mit-6824-s21/materials/official-materials/project/project.html)

**Paper Question / Homework**

- The lecture today is an Q&A session about the last submitted lab (e.g., lab 1 or lab2A+B). Submit a question about the lab: for example, something you wondered about while doing the lab, something you didn't understand, or just anything.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/08-q-QAlab.html)

### Lecture 9: Zookeeper

**视频分段**

- [Part 9: Lecture 9 - Zookeeper](https://www.bilibili.com/video/BV16f4y1z7kn/?p=9)，约 `82.8` 分钟。

**课堂讲义**

- [Zookeeper](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-zookeeper.txt)

**指定论文**

- [ZooKeeper (2010)](/assets/courses/mit-6824-s21/materials/official-materials/papers/zookeeper.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/zookeeper-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/HYTDDLo2vSE)

**Paper Question / Homework**

- One use of Zookeeper is as a fault-tolerant lock service (see the section "Simple locks" on page 6). Why isn't possible for two clients to acquire the same lock? In particular, how does Zookeeper decide if a client has failed and it can give the client's locks to other clients?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/09-q-zookeeper.html)

### Lecture 10: Guest Lecture on Go - Russ Cox

**视频分段**

- [Part 10: Lecture 10 - Guest Lecture on Go - Russ Cox](https://www.bilibili.com/video/BV16f4y1z7kn/?p=10)，约 `95.5` 分钟。

**课堂讲义**

- [Guest lecturer on Go](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/10-go-lecture.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/go-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/IdCbMO0Ey9I)

**Paper Question / Homework**

- Russ Cox is one of the leads on the Go project. What do you like best about Go? Why? Would you want to change anything in the language? If so, what and why?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/10-q-go.html)

### Lecture 11: Chain Replication

**视频分段**

- [Part 11: Lecture 11 - Chain Replication](https://www.bilibili.com/video/BV16f4y1z7kn/?p=11)，约 `94.3` 分钟。

**课堂讲义**

- [Chain Replication](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-cr.txt)

**指定论文**

- [CR (2004)](/assets/courses/mit-6824-s21/materials/official-materials/papers/cr-osdi04.pdf)

**MIT 官方视频**

- [video](https://youtu.be/1uUcW-Mqg5o)

**Paper Question / Homework**

- Give an example scenario where a client could observe incorrect results (i.e., non-linearizable) if the head of the chain would return a response to the client as soon as it received an acknowledgment from the next server in the chain (instead of the tail responding).
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/11-q-cr.html)

### Lecture 12: Cache Consistency - Frangipani

**视频分段**

- [Part 12: Lecture 12 - Cache Consistency - Frangipani](https://www.bilibili.com/video/BV16f4y1z7kn/?p=12)，约 `88.0` 分钟。

**课堂讲义**

- [Cache Consistency: Frangipani](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-frangipani.txt)

**指定论文**

- [Frangipani](/assets/courses/mit-6824-s21/materials/official-materials/papers/thekkath-frangipani.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/frangipani-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/jPrUxfIcWWs)

**相关 Lab**

- [Lab 4: Sharded KV](/assets/courses/mit-6824-s21/materials/official-materials/labs/lab-shard.html)

**Paper Question / Homework**

- Frangipani: A Scalable Distributed File System : Suppose a server modifies an i-node, appends the modification to its log, then another server modifies the same i-node, and then the first server crashes. The recovery system will see the i-node modification in the crashed server's log, but should not apply that log entry to the i-node, because that would un-do the second server's change. How does Frangipani avoid or cope with this situation?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/12-q-frangipani.html)

### Lecture 13: Distributed Transactions

**视频分段**

- [Part 13: Lecture 13 - Distributed Transactions](https://www.bilibili.com/video/BV16f4y1z7kn/?p=13)，约 `81.5` 分钟。

**课堂讲义**

- [Distributed Transactions](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-2pc.txt)

**整理产物**

- [Lecture 13 课堂笔记](/courses/mit-6824-s21/lectures/013/)
- [Lecture 13 阅读指南](/courses/mit-6824-s21/readings/lecture-13/)

**其他 Preparation**

- [6.033 Chapter 9](https://ocw.mit.edu/resources/res-6-004-principles-of-computer-system-design-an-introduction-spring-2009/online-textbook/)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/chapter9-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/B6btpukqHpM)

**Paper Question / Homework**

- 6.033 Book . Read just these parts of Chapter 9: 9.1.5, 9.1.6, 9.5.2, 9.5.3, 9.6.3. The last two sections (on two-phase locking and distributed two-phase commit) are the most important. The Question: describe a situation where Two-Phase Locking yields higher performance than Simple Locking.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/13-q-chapter9.html)

### Lecture 14: Spanner

**视频分段**

- [Part 14: Lecture 14 - Spanner](https://www.bilibili.com/video/BV16f4y1z7kn/?p=14)，约 `97.1` 分钟。

**课堂讲义**

- [Spanner](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-spanner.txt)

**指定论文**

- [Spanner (2012)](/assets/courses/mit-6824-s21/materials/official-materials/papers/spanner.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/spanner-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/ZulDvY429B8)

**Paper Question / Homework**

- Spanner Suppose a Spanner server's TT.now() returns correct information, but the uncertainty is large. For example, suppose the absolute time is 10:15:30, and TT.now() returns the interval [10:15:20,10:15:40]. That interval is correct in that it contains the absolute time, but the error bound is 10 seconds. See Section 3 for an explanation TT.now(). What bad effect will a large error bound have on Spanner's operation? Give a specific example.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/14-q-spanner.html)

### Lecture 15: Optimistic Concurrency Control (FaRM)

**视频分段**

- [Part 15: Lecture 15 - Optimistic Concurrency Control (FaRM)](https://www.bilibili.com/video/BV16f4y1z7kn/?p=15)，约 `94.6` 分钟。
- [Part 16: Lecture 15 continued - Optimistic Concurrency Control (FaRM) pt. 2](https://www.bilibili.com/video/BV16f4y1z7kn/?p=16)，约 `28.0` 分钟。

**课堂讲义**

- [Optimistic Concurrency Control](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-farm.txt)

**指定论文**

- [FaRM (2015)](/assets/courses/mit-6824-s21/materials/official-materials/papers/farm-2015.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/farm-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/07xsfL5E8Ck)
- [video cont.](https://youtu.be/XwU4jKhBxws)

**Paper Question / Homework**

- No compromises: distributed transactions with consistency, availability, and performance : Suppose there are two FaRM transactions that both increment the same object. They start at the same time and see the same initial value for the object. One transaction completely finishes committing (see Section 4 and Figure 4). Then the second transaction starts to commit. There are no failures. What is the evidence that FaRM will use to realize that it must abort the second transaction? At what point in the Section 4 / Figure 4 protocol will FaRM realize that it must abort?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/15-q-farm.html)

### Lecture 16: Big Data - Spark

**视频分段**

- [Part 17: Lecture 16 - Big Data - Spark](https://www.bilibili.com/video/BV16f4y1z7kn/?p=17)，约 `78.8` 分钟。

**课堂讲义**

- [Big Data: Spark](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-spark.txt)

**指定论文**

- [Spark (2012)](/assets/courses/mit-6824-s21/materials/official-materials/papers/zaharia-spark.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/spark-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/qXb5rDGqFdc)

**Paper Question / Homework**

- Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing What applications can Spark support well that MapReduce/Hadoop cannot support?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/16-q-spark.html)

### Lecture 17: Cache Consistency - Memcached at Facebook

**视频分段**

- [Part 18: Lecture 17 - Cache Consistency - Memcached at Facebook](https://www.bilibili.com/video/BV16f4y1z7kn/?p=18)，约 `104.3` 分钟。

**课堂讲义**

- [Cache Consistency: Memcached at Facebook](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-memcached.txt)

**指定论文**

- [Memcached at Facebook (2013)](/assets/courses/mit-6824-s21/materials/official-materials/papers/memcache-fb.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/memcache-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/eYZg0YJtFEE)

**Paper Question / Homework**

- Memcache at Facebook . Section 3.3 implies that a client that writes data does not delete the corresponding key from the Gutter servers, even though the client does try to delete the key from the ordinary Memcached servers (Figure 1). Explain why it would be a bad idea for writing clients to delete keys from Gutter servers.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/17-q-memcached.html)

### Lecture 18: Fork Consistency, SUNDR

**视频分段**

- [Part 19: Lecture 18 - Fork Consistency, SUNDR](https://www.bilibili.com/video/BV16f4y1z7kn/?p=19)，约 `91.1` 分钟。

**课堂讲义**

- [Fork Consistency, SUNDR](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-sundr.txt)

**指定论文**

- [SUNDR (2004)](/assets/courses/mit-6824-s21/materials/official-materials/papers/li-sundr.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/sundr-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/FxwjSs_xSBM)

**Paper Question / Homework**

- Secure Untrusted Data Repository (SUNDR) In the simple straw-man, both fetch and modify operations are placed in the log and signed. Suppose an alternate design that only signs and logs modify operations. Does this allow a malicious server to break fetch-modify consistency or fork consistency? Why or why not?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/18-q-sundr.html)

### Lecture 19: Peer-to-Peeer - Bitcoin

**视频分段**

- [Part 20: Lecture 19 - Peer-to-Peeer - Bitcoin](https://www.bilibili.com/video/BV16f4y1z7kn/?p=20)，约 `82.7` 分钟。

**课堂讲义**

- [Bitcoin](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-bitcoin.txt)

**指定论文**

- [Bitcoin (2008)](/assets/courses/mit-6824-s21/materials/official-materials/papers/bitcoin.pdf)

**其他 Preparation**

- [summary](/assets/courses/mit-6824-s21/materials/official-materials/readings/how-the-bitcoin-protocol-actually-works)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/bitcoin-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/yB6m8EjAqPU)

**Paper Question / Homework**

- Bitcoin Try to buy something with Bitcoin. It may help to cooperate with some 6.824 class-mates, and it may help to start a few days early. If you decide to give up, that's OK. Briefly describe your experience.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/19-q-bitcoin.html)

### Lecture 20: Blockstack

**视频分段**

- [Part 21: Lecture 20 - Blockstack](https://www.bilibili.com/video/BV16f4y1z7kn/?p=21)，约 `89.7` 分钟。

**课堂讲义**

- [Blockstack](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-blockstack.txt)

**指定论文**

- [BlockStack (2016)](/assets/courses/mit-6824-s21/materials/official-materials/papers/blockstack-atc16.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/blockstack-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/DnyBPxo3B6I)

**Paper Question / Homework**

- Why is it important that Blockstack names be unique, human-readable, and decentralized? Why is providing all three properties hard?
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/20-q-blockstack.html)

### Lecture 21: Project Presentations

**视频分段**

- [Part 22: Lecture 21 - Project Presentations](https://www.bilibili.com/video/BV16f4y1z7kn/?p=22)，约 `98.0` 分钟。

**指定论文**

- [AnalogicFS experience paper](/assets/courses/mit-6824-s21/materials/official-materials/papers/katabi-analogicfs.pdf)

**FAQ**

- [FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/analogicfs-faq.txt)

**MIT 官方视频**

- [video](https://youtu.be/bu41Qt9G5Qo)

**Paper Question / Homework**

- Experiences with a Distributed, Scalable, Methodological File System: AnalogicFS . In many ways, this experiences paper raises more questions than it answers. Please answer one of the following questions, taking into consideration the rich history of AnalogicFS and the spirit in which the paper was written: a) The analysis of A* search shown in Figure 1 claims to be an introspective visualization of the AnalogicFS methodology; however, not all decisions are depicted in the figure. In particular, if I <= P, what should be the next node explored such that all assumptions in Section 2 still hold? Show your work. b) Despite the authors' claims in the introduction that AnalogicFS was developed to study SCSI disks (and their interaction with lambda calculus), the experimental setup detailed in Section 4.1 involves decommissioned Gameboys instead, which use cartridge-based, Flash-like memory. If the authors had used actual SCSI disks during the experiments, how exactly might have their results changed quantitatively? c) AnalogicFS shows rather unstable multicast algorithm popularity (Figure 5), especially compared with some of the previous systems we've read about in 6.824. Give an example of another system that would have a more steady measurement of popularity pages, especially in the range of 0.1-0.4 decibels of bandwidth. d) For his 6.824 project, Ben Bitdiddle chose to build a variant of Lab 4 that faithfully emulates the constant expected seek time across LISP machines, as AnalogicFS does. Upon implementation, however, he immediately ran into the need to cap the value size to 400 nm, rather than 676 nm. Explain what assumptions made for the AnalogicFS implementation do not hold true for Lab 4, and why that changes the maximum value size.
  - 来源：[Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/21-q-analogic.html)

## 使用顺序

1. 先读 assigned paper，并回答本讲 Question。
2. 用 FAQ 标记阅读时的常见误区。
3. 阅读 lecture notes/code，再观看视频或阅读 transcript。
4. 对照讲次 `NOTES.md`，检查老师如何讨论论文设计、故障模型、权衡和实验。
5. Lab 相关讲次把论文机制映射到官方接口与测试，但不要在笔记中提供作业实现答案。
