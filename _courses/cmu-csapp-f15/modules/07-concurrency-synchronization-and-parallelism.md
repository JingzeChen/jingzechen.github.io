---
uid: cmu-csapp-f15-module-07
type: course
document_type: module
course: cmu-csapp-f15
module_number: 7
title: 模块 07：并发、同步与线程级并行
description: 本模块回答一条连续的问题链：
excerpt: 本模块回答一条连续的问题链：
content_lang: zh-CN
permalink: "/courses/cmu-csapp-f15/modules/07/"
toc: true
---

{% raw %}
> 本模块严格按 **Concurrent Programming → Synchronization: Basics → Synchronization: Advanced → Thread-Level Parallelism** 的课堂顺序组织。内容只综合 Lecture 23–26 的 `NOTES.md`；自动字幕、课件抽取或老师口述存在冲突时，保留 `[需回听]`，不使用课外知识补齐。

## 证据来源

1. [Lecture 23: Concurrent Programming](/courses/cmu-csapp-f15/lectures/023/)
2. [Lecture 24: Synchronization: Basics](/courses/cmu-csapp-f15/lectures/024/)
3. [Lecture 25: Synchronization: Advanced](/courses/cmu-csapp-f15/lectures/025/)
4. [Lecture 26: Thread-Level Parallelism](/courses/cmu-csapp-f15/lectures/026/)

引用中的时间戳和课件页码沿用原讲笔记。需要逐字引用、确认图形细节或采用性能数字时，应回到对应 `NOTES.md` 的 `[需回听]` 项，再核对原录像和课件。

## 模块用途

本模块回答一条连续的问题链：

1. 一个程序为什么需要多个逻辑流，process、event 和 thread 三种结构分别把调度与共享交给谁？
2. 多个线程共享同一地址空间后，怎样从变量实例、机器指令和合法交错判断 race？
3. 怎样用 semaphore 的原子语义和不变量约束交错，并把它扩展到有界缓冲区、读者—写者、线程池和多锁程序？
4. 当目标从“并发地处理多个外部事件”变为“更快完成一个计算任务”时，怎样分解工作、测量收益，并解释 cache coherence 对正确性和性能的双重影响？

完成模块后，应能从一段并发代码中找出共享对象、所有权、临界区和阻塞点，写出可能的交错或等待环，选择课堂讲过的同步结构，并用实测时间、speedup、efficiency 与 Amdahl 上限评价线程级并行。

## 先修知识

- **异常控制流与进程：** `fork`、`waitpid`、zombie、signal handler、内核调度和进程层级。
- **Unix I/O 与网络：** descriptor table、open-file/socket 引用、`listenfd`、`connfd`、`Accept`、RIO、EOF 和 TCP listen backlog。
- **虚拟内存与 C 存储：** code/data/heap/stack、全局变量、普通局部变量、函数内 `static`、对象地址与生命周期。
- **机器级程序：** load、register update、store，PC、SP、condition codes、寄存器上下文和 cache line。
- **Pthreads 基础：** `pthread_create`、`pthread_join`、`pthread_detach`、thread routine 的 `void * -> void *` 接口。
- **性能优化与递归：** register accumulation、associativity、multiple accumulators、quicksort 的 pivot/partition/递归。

## 学习路线

```text
阻塞 I/O + 多个逻辑流
  -> process / event / thread 三种并发模型
  -> thread 共享地址空间与不可控 interleaving
  -> 变量实例、L/U/S、progress graph、unsafe region
  -> semaphore P/V 与 s >= 0
  -> mutex、producer-consumer、readers-writers、thread pool
  -> 多锁次序与 deadlock region
  -> 工作分解、粒度、speedup、efficiency、Amdahl
  -> sequential consistency 与 snoopy cache coherence
  -> 正确性机制自身的性能成本
```

不要跳过 Lecture 24 直接背 Lecture 25 的 P/V 模板。高级同步代码的每一个信号量都依赖前一讲建立的三个问题：它表示什么状态、哪一次 P 可以阻塞、哪一个不变量禁止错误状态。

---

## 第一篇：Concurrent Programming

### 1. 从交错空间而不是源码顺序理解并发

并发程序包含多个在时间上重叠的 logical flow。即使只有一个 core，内核也可以在指令之间切换 flow；真正多核只是允许某些 flow 同时执行。程序正确性因此不能只验证一次运行，而要覆盖所有允许的 interleaving。[Lecture 23, 00:01:03–00:07:20]

课堂用四类问题建立词汇：

- **Race：** 结果依赖内核未承诺的事件次序。例如 child 先结束还是 parent 先把它加入 jobs list。
- **Deadlock：** 多个 flow 等待永远不会发生的事件。例如主程序持有 `printf` 内部资源时被 signal 打断，handler 又等待同一资源，而主程序必须等 handler 返回才能释放。
- **Starvation：** 某个 flow 长期得不到前进机会，但系统中的其他 flow 仍可能前进。
- **Fairness：** 调度或服务策略应让参与者得到合理份额。本模块只保留课堂定性解释，没有形式化公平公式。

这里的关键边界是：race 不要求两条指令物理上“同时”执行；deadlock 也不等于“等待很久”。前者关注未规定的次序，后者要求形成无法解除的等待条件。

### 2. 迭代式服务器为何在功能上需要并发

迭代式 echo server 一次只处理一个 client。课堂的两客户端轨迹是：

```text
client 1: connect -> write/read -> 保持连接但不再输入
server:   accept client 1 -> read client 1，并在这里长期阻塞
client 2: connect 返回 -> rio_writen 返回 -> rio_readlineb 等响应时阻塞
```

`connect` request 可以进入 server-side listen backlog，写入数据也可以先由内核缓冲；这不表示 server application 已 `accept` 或读取。真正缺少的是 server 为 client 2 产生的 response，所以课堂轨迹中 client 2 阻塞在 `rio_readlineb`。[Lecture 23, 00:09:58–00:13:29]

因此 backlog 只能排队，不能把一个应用 flow 变成多个 flow。只要 client 1 永久沉默，所有后续 client 就可能永久得不到服务。这里的并发首先是可用性要求，而不只是吞吐优化。

> `[需回听]` 老师把 `connect` 描述为立即返回，只能限定为课堂所画的 backlog 场景，不能外推为所有平台、错误和网络状态下的无条件行为。

### 3. Process、event、thread 三模型比较

课堂用两个主轴定义三种结构：谁负责交错 flow，以及 flow 是否共享 address space。

| 维度 | Process-based | Event-based | Thread-based |
| --- | --- | --- | --- |
| 逻辑 flow 的交错者 | Kernel | Programmer / event loop | Kernel |
| Address space | 每个 process 私有 | 单一共享 address space | 同一 process address space |
| 普通全局状态共享 | 不直接共享，需 IPC 等机制 | 直接共享显式状态 | 直接共享，也容易意外共享 |
| 控制开销 | 高 | 很低 | 中等，通常低于 process |
| 应用级调度控制 | 少 | 高，可选择 ready descriptor 次序 | 少 |
| 本讲模型中的多核利用 | 可以 | 单 event loop 本身不可以 | 可以 |
| 主要实现风险 | process control、IPC、资源回收 | partial state machine 与粒度 | race、thread safety、难复现次序 |

三种结构没有普遍最佳者。隔离、共享、控制开销、调度控制、多核与可调试性是不同维度，不能用单一性能数字替代设计判断。[Lecture 23, 01:09:49–01:11:20.980]

### 4. Process server：资源所有权与引用计数

进程版 echo server 的角色分工为：

```text
parent: Accept -> Fork -> Close(parent connfd) -> next Accept
child:  Close(listenfd) -> echo(connfd) -> Close(connfd) -> exit
SIGCHLD handler: while (waitpid(-1, 0, WNOHANG) > 0) ;
```

`fork` 后 parent 与 child 各有 descriptor table 副本，但两个 `connfd` 条目引用同一内核 open-file/socket 状态。课堂以

$$
refcnt(connfd)=2
$$

表示 fork 后状态。parent 关闭自己不负责的 `connfd` 后降到 1，child 服务结束再关闭后才降到 0。若 parent 遗漏 close，child 的 close 不能让底层连接引用归零。`SIGCHLD` handler 则必须实际调用 `waitpid`，并用循环回收当前所有 zombie child。[Lecture 23, 00:19:57–00:29:26]

这说明“进程不共享普通 global variable”不等于“所有内核状态完全独立”。共享边界必须分层描述：descriptor table 是副本，open-file/socket state 可被共同引用。

### 5. Event server：readiness 不等于完整消息

单一 event loop 保存 `{listenfd, active connfd...}`，用 `select`、`epoll` 或同类机制取得 ready set：

```text
if listenfd ready:
    accept connection and add connfd

for each ready connfd:
    read a nonblocking-safe work unit
    update this connection's saved state
    produce any available response
```

`listenfd` ready 表示可以接受新连接；`connfd` ready 表示有输入可读。它不保证已有完整 HTTP request，甚至不保证已有完整一行。课堂按以下顺序收紧事件粒度：[Lecture 23, 00:35:29–00:38:45]

1. 每次读完整 request：client 只发半个 request 时，唯一 event loop 被阻塞。
2. 每次读完整 line：client 只发半行时，仍可阻塞全体。
3. 只读当前 available bytes：不等待消息边界，但必须保存每个 connection 的 partial buffer 和 parser state。

Event-based concurrency 仍是 concurrency，因为多个 client 的逻辑 flow 被手工交错推进；但这里只有一个内核调度的应用控制流。其低开销与易单步调试，换来了显式状态机和单 event loop 不使用多个 core 的边界。

### 6. Thread model：共享与独立的准确边界

课堂从传统 process view 中抽出一组可独立恢复的执行状态：

```text
thread = stack region + PC + SP + registers + condition codes + TID
process shared state = code + data + virtual address space + kernel context
```

每条 thread 有独立 logical flow 和正常使用的 stack region，但所有 stack region 都位于同一 virtual address space。一个 thread 若拿到另一个 stack object 的地址，硬件不会提供进程级访问保护。[Lecture 23, 00:39:55–00:48:30]

两个 flow 的生命周期 overlap 就是 concurrent；只有在不同 core 上同时执行才是 true parallelism。课堂 A/B/C 单核轨迹 `A -> B -> C -> A` 中，A-B 与 A-C concurrent，B-C sequential。

课堂测量给出 process 创建/回收约 20K cycles、thread 约 10K cycles 或更少，只用于说明相对量级，不是跨机器常数，也不能推出 thread 永远恰好快两倍。[Lecture 23, 00:48:38–00:49:16]

### 7. Thread server：参数所有权与 `&connfd` race

正确课堂版本为每个连接分配独立参数对象：

```text
main: Malloc(int) -> Accept into *connfdp -> pthread_create(peer, connfdp)
peer: copy *connfdp -> detach self -> Free(connfdp)
      -> echo(local connfd) -> Close(connfd) -> return
```

错误简化把同一个 main-stack slot 地址传给所有 peers：

```c
Pthread_create(&tid, NULL, thread, (void *)&connfd);
```

一个合法错误交错是：

```text
main:   Accept(client 1) -> connfd = fd1
main:   create(peer 1, &connfd)
main:   继续运行，Accept(client 2) -> connfd = fd2
peer 1: 此时才 dereference(&connfd) -> fd2
peer 2: 也可能读到 fd2
```

错误的根源不是 `Accept`，而是程序偷偷假设 peer 1 会先运行。每连接独立 heap object 取消了“后续 Accept 覆盖同一 slot”这条共享依赖；peer 必须先复制值，再释放参数块。`Free(vargp)` 与 `Close(connfd)` 分别释放参数存储和 socket descriptor，不能混同。[Lecture 23, 00:56:17–01:08:16]

---

## 第二篇：Synchronization: Basics

### 8. 同步从共享变量判定开始

课堂定义：变量 `x` 是共享变量，当且仅当多个线程引用 `x` 的某一个实例。判断步骤不是“global 共享、stack 私有”，而是：

1. 枚举变量实例。
2. 列出每个实例被哪些线程直接或间接引用。
3. 只要某个实例被多个线程引用，就把该变量视为共享。

实例规则如下：[Lecture 24, 00:09:57–00:17:55]

| 声明类别 | 实例数规则 | 共享结论的附加条件 |
| --- | --- | --- |
| 函数外全局变量 | 虚拟内存中一个实例 | 仍要有多个线程实际引用 |
| 函数内普通局部变量 | 每个相关 activation/stack 有实例 | 地址传出后仍可被其他线程引用 |
| 函数内 `static` | 虚拟内存中一个实例 | 名字作用域局部不等于线程私有 |

`sharing.c` 中，main stack 上的 `msgs` 经全局 `ptr` 被两个 peers 间接访问，所以共享；两个 peer 各自的 `myid` 是不同实例，所以不共享；函数内静态 `cnt` 只有一个实例并被两个 peers 引用，所以共享。

把地址传给线程也不自动构成 race。Lecture 23 的 `&connfd` 有并发写入和覆盖；Lecture 24 的 `&niters` 在 worker 中只读，main 创建线程后不再修改。必须分析实际读写与生命周期，不能靠代码形状做 pattern matching。

### 9. `cnt++`、丢失更新与 interleaving

`badcnt` 让两个线程各执行 `niters` 次 `cnt++`，预期为

$$
cnt_{expected}=2\times niters.
$$

课堂所示 x86-64 实现把一次递增拆成：

```asm
movq cnt(%rip), %rdx   # L_i: load shared cnt
addq $1, %rdx          # U_i: update private register
movq %rdx, cnt(%rip)   # S_i: store shared cnt
```

对 thread $i$，相对于 `cnt` 的 critical section 是

$$
C_i=(L_i,U_i,S_i).
$$

正确轨迹可以让一个临界区完整先于另一个：

$$
H_1,L_1,U_1,S_1,H_2,L_2,U_2,S_2,T_2,T_1,
$$

最终 `cnt=2`。课堂给出两条错误轨迹：

$$
H_1,L_1,U_1,H_2,L_2,S_1,T_1,U_2,S_2,T_2,
$$

以及

$$
H_1,L_1,H_2,L_2,U_2,S_2,U_1,S_1,T_1,T_2.
$$

两者都让两个 load 在能观察到对方的新值前读到 0，所以两个 register 都只算出 1，后一条 store 用 1 覆盖 1，最终 `cnt=1`。[Lecture 24, 00:19:55–00:33:37]

`volatile` 只约束课堂所述的编译器存取行为，没有把 `L/U/S` 合成不可分割操作，也不提供 mutual exclusion。

### 10. Progress graph：把所有合法交错几何化

两个线程的 progress graph 是二维离散网格。横轴和纵轴分别表示两线程已经完成到哪一条指令；一次只执行一条指令的课堂模型下，轨迹只能向右或向上，不能后退或走对角线。[Lecture 24, 00:33:37–00:39:43]

- **Trajectory：** 一次合法执行对应的一串状态转移。
- **Critical section：** 相对于同一共享状态、不能与另一对应区域交错的指令序列。
- **Unsafe region：** 两个相对于 `cnt` 的临界区发生交错的联合状态集合。
- **Safe trajectory：** 不进入任何 unsafe region 的轨迹。

本例中课堂结论为：

$$
trajectory\ is\ correct\ (w.r.t.\ cnt)
\iff trajectory\ is\ safe.
$$

轨迹贴着 unsafe region 边缘不等于进入，必须根据状态点表示“哪些指令已经完成”来判断。一次演示运行走安全轨迹，也不能证明程序对所有合法调度正确。

### 11. Semaphore 的 P/V 语义与不变量

Semaphore `s` 是非负整数同步变量，只通过 P/V 操作改变。课堂抽象语义为：[Lecture 24, 00:43:36–00:48:38]

```text
P(s):
    if s > 0:
        atomically test and decrement; return
    else:
        suspend until a V restarts this thread
        then complete the decrement; return

V(s):
    atomically increment
    if threads are blocked in P(s):
        restart exactly one; selection order is unspecified
```

由初始化非负、V 只加一、P 在 0 时阻塞，可得课堂核心不变量：

$$
s\ge0.
$$

不能把“被 V 唤醒”误解为 P 已经完成；被选中的线程还要完成自己的 decrement。也不能假定一次 V 广播唤醒全部等待者，或假定具体哪一个等待者被选中。

### 12. Mutex 正确性：从代数不变量到 forbidden region

用于 mutual exclusion 的 binary semaphore 初值为 1：

```text
P(mutex)
    critical section
V(mutex)
```

证明链不是“因为这是标准模板”，而是：[Lecture 24, 00:49:36–00:55:33]

1. 初始 $s=1$。
2. Thread 1 成功执行 P，原子地完成 $1\to0$，随后进入临界区。
3. 在 Thread 1 执行 V 前，$s=0$。
4. Thread 2 的 P 不能执行 $0\to-1$，只能阻塞。
5. Progress graph 中所有要求 $s=-1$ 的状态不可达，构成 forbidden region。
6. Forbidden region 包围原 unsafe region，所以任何合法轨迹都不能让两个临界区交错。

即

$$
s\ge0
\Longrightarrow \text{forbidden region unreachable}
\Longrightarrow \text{unsafe region unreachable}
\Longrightarrow \text{mutual exclusion}.
$$

`goodcnt` 每次递增前 P、完成后 V，结果正确但比错误版慢若干数量级。Lecture 24 在这里建立正确性，没有优化锁粒度。

> **证据边界：** Lecture 24 只一句说明 counting semaphore 可计数事件或资源，并预告高级同步。它没有教授 producer–consumer 的 buffer、`slots/items` 初值或操作次序；这些内容只能归入 Lecture 25。

---

## 第三篇：Synchronization: Advanced

### 13. Counting semaphore：有界 producer–consumer

容量为 $n$ 的循环缓冲区使用三个 semaphore：[Lecture 25, 00:03:21–00:13:55]

| 对象 | 初值 | 课堂职责 |
| --- | ---: | --- |
| `mutex` | 1 | 互斥保护 `buf/front/rear` 的结构更新 |
| `slots` | $n$ | 记录当前可占用空槽，满时使 producer 等待 |
| `items` | 0 | 记录当前可取得项目，空时使 consumer 等待 |

插入的精确次序：

```text
P(slots)
P(mutex)
buf[(++rear) % n] = item
V(mutex)
V(items)
```

移除的精确次序：

```text
P(items)
P(mutex)
item = buf[(++front) % n]
V(mutex)
V(slots)
return item
```

推理要分清三层：

1. `P(slots)` / `P(items)` 取得一个资源资格，并可在条件不满足时阻塞。
2. `P(mutex)` 保护共享数组和索引，避免多个 producers 或 consumers 同时破坏结构。
3. 最后的 `V(items)` / `V(slots)` 在结构更新完成后才通知另一类线程条件已经成立。

若先 `V(items)` 再写数组，consumer 可能收到一个尚未真正写好的“可用项目”。若认为 `P(items)` 已经保护 `front`，则混淆了资源计数与结构互斥。课堂没有把 `slots + items = n` 明确写成代数不变量，因此本模块只使用其操作含义和初值，不把该等式冒充老师给出的证明。

### 14. Readers–writers：首读者、末读者与优先级

普通 mutex 会把所有读取串行化，过于保守。Readers–writers 允许任意多个 readers 同时访问，但 writer 必须对 readers 和其他 writers 独占。[Lecture 25, 00:14:00–00:25:37]

课堂先区分两种经典变体：

- **第一类，读者优先：** 等待中的 writer 不能阻止后来 reader 加入；持续 reader 流可能使 writer starvation。
- **第二类，写者优先：** writer 就绪后，后到 reader 等待；持续 writer 流可能使 reader starvation。

本讲只实现第一类。初始 `readcnt=0`、`mutex=1`、`w=1`：

```text
reader entry:
    P(mutex)
    readcnt++
    if readcnt == 1:
        P(w)
    V(mutex)

    read shared object

reader exit:
    P(mutex)
    readcnt--
    if readcnt == 0:
        V(w)
    V(mutex)

writer:
    P(w)
    write shared object
    V(w)
```

`mutex` 只保护 `readcnt` 的短更新，不包围实际 read。首读者在 `0→1` 时代表读者群体取得 `w`，后续 readers 因 `readcnt>1` 不重复 P(w)，所以可并发读取；末读者在 `1→0` 时释放 `w`。持续到达的新 reader 可以延长“读者群体不为空”的时间，这正是 writer starvation 的来源。

> **证据边界：** Writer-priority 版本只被定义并留作思考题，Lecture 25 没有给出实现；不能自行补一套算法并称为课堂方案。

### 15. Producer–consumer 到预线程化服务器

课堂把通用模型直接映射到 server：[Lecture 25, 00:26:55–00:43:29]

```text
master producer:
    Open_listenfd
    initialize sbuf
    create fixed NTHREADS worker pool
    loop: Accept -> sbuf_insert(connfd)

worker consumer:
    detach self
    loop: sbuf_remove -> echo_cnt(connfd) -> Close(connfd)
```

项目不是客户正文，而是 connected descriptor 这个小整数。Threads 共享 process descriptor table，所以 worker 可用 master 投递的 `connfd`。固定 worker pool 把 thread creation 成本移到启动阶段，并通过缓冲区吸收短时到达速率与服务速率差异。

`echo_cnt` 又引入共享 `byte_cnt`，用 mutex 把“加上本次字节数并打印累计值”放在同一临界区。初始化可以由 master 显式完成，也可以让每个 caller 执行：

```c
Pthread_once(&once, init_echo_cnt);
```

课堂可确认的契约是：多个 threads 都可调用，但给定 `once` 控制对象上的初始化函数只实际执行一次。

> `[需回听]` 老师在 `pthread_once` 内部如何记忆状态的问题上明确表示不清楚实现；本模块只保留 API 行为，不推测内部 flag 或函数局部静态初始化机制。

### 16. Thread safety 与 reentrancy

课堂定义：一个函数被多个 concurrent threads 反复调用时始终产生正确结果，它才是 thread-safe。Lecture 25 列出四类不安全来源：[00:43:37–01:03:39]

| 类别 | 风险 | 课堂修复方向 |
| --- | --- | --- |
| 1. 不保护共享变量 | 如 `badcnt` 的共享 `cnt` | 用 P/V 互斥，承担同步成本 |
| 2. 跨调用保存状态 | `rand` 使用共享静态 `next` | 把状态参数化，如 caller 维护 `rand_r` 的 seed |
| 3. 返回静态对象地址 | `ctime` 每次覆盖同一字符串 | lock-and-copy 到 caller 私有缓冲区 |
| 4. 调用不安全函数 | 不安全性沿调用链传播 | 改为只调用安全函数或安全包装 |

`ctime_ts` 的 mutex 必须同时覆盖原始 `ctime` 调用与 `strcpy(privatep, sharedp)`。如果取得共享地址后立即解锁，另一 thread 仍可在复制前覆盖对象。复杂嵌套结构可能需要 deep copy，成本远高于字符串复制。

课堂把“不访问任何共享变量”的函数称为 reentrant。它无需同步，因此所有 reentrant functions 都 thread-safe；反向不成立，因为一个正确加锁访问共享变量的函数可以 thread-safe，却仍非 reentrant。

> `[需回听]` 课件对 `ctime_ts` 写有“caller must free memory”，口述又像是 caller 准备字符数组；具体分配方式未展示完整，不能断言每次都必须 `free`。课堂关于所有标准 C 库函数和多数 Unix system calls 的安全性说明也限定于当时课堂语境，老师明确说例外表可能不完整。

### 17. Race 的事件表达与独立存储修复

Lecture 25 再次用 `&i` 说明 race。Race 应写成两个具体竞争事件，而不是“两个线程同时运行”：[01:03:39–01:09:51]

```text
x = peer dereferences &i
y = main increments i
```

Thread 0 要得到预期 ID 0，需要 $x<y$，但调度器没有提供这个顺序。100-thread 实验中，正确结果应为 0–99 各一次；重复值与缺失值共同暴露竞态。单核抢占也足以触发，多核只可能让错误更频繁。

修复与 Lecture 23 的 `connfd` 完全同构：为每个 thread 分配独立 heap block，写入本轮 ID，传唯一地址；peer 复制到 local `myid` 后释放 block。修复取消了共享可变 slot，而不是试图让调度器“更快地运行新 thread”。

### 18. Deadlock：循环等待与统一锁获取顺序

课堂双锁程序让两个 threads 都需要 `s0` 和 `s1`，但获取顺序相反：[Lecture 25, 01:09:51–01:20:13]

| Thread | 获取顺序 | 临界操作 | 释放顺序 |
| --- | --- | --- | --- |
| 0 | `P(s0) -> P(s1)` | `cnt++` | `V(s0) -> V(s1)` |
| 1 | `P(s1) -> P(s0)` | `cnt++` | `V(s1) -> V(s0)` |

错误交错为：Thread 0 持有 `s0` 等 `s1`；Thread 1 持有 `s1` 等 `s0`。两个 V 都位于各自尚未完成的第二个 P 之后，所以等待条件永远不会成立。

Progress graph 中要区分：

- **Forbidden region：** 二元 semaphore 不允许两个 threads 同时持有同一锁的状态，合法轨迹不能进入。
- **Deadlock region：** 合法轨迹可以进入，但进入后只能走向被 forbidden regions 夹住的 deadlock state。
- **Deadlock state：** 每个 thread 持有一个锁并等待另一个锁，均不能前进。
- **Unreachable states：** 根本不存在合法单调轨迹可到达，不等同于“已经死锁”。

课堂避免规则是给所有共享资源规定同一全序，并让所有 threads 按该顺序获取。本例统一为：

```text
P(s0) -> P(s1)
```

这会消除潜在 deadlock region，而不是只降低概率。老师明确说释放顺序无关；不同释放次序会改变 unreachable region 的形状，但不会重新引入该 deadlock region。

---

## 第四篇：Thread-Level Parallelism

### 19. 从外部并发转向一个任务的内部并行

前面用 threads 隔离多个 clients 的 I/O delay；本讲改问能否把一个大任务拆成多个 sub-task，在多个 cores 上缩短单个任务的 elapsed time。硬件提供潜在资源，但不保证应用自动加速。[Lecture 26, 00:00:00–00:04:26]

- **Multicore：** 多个独立 cores，各有 private cache 部分，并通过共享层次和主存协同。
- **Hyperthreading / SMT：** 同一 core 复制多个 instruction-control / register contexts，却共享 functional units 和 cache/execution resources。

SMT 只在一个 thread 无法持续占满资源时可能让另一个 thread 利用空档。8-core、two-way SMT 的 Shark 暴露 16 hardware-thread contexts，但 `psum-local` 和 quicksort 都显示 8→16 没有额外收益。结论只针对该机器与工作负载，不是一般定律。

### 20. Parallel summation：三次状态重构

目标为

$$
\sum_{i=0}^{n-1}i=\frac{(n-1)n}{2}.
$$

在课堂简化前提 $t\mid n$ 下，thread $j$ 处理半开区间

$$
start=j\frac{n}{t},\qquad
end=start+\frac{n}{t}.
$$

三版程序保持数学分区不变，只改变 hot update 的存放位置：[Lecture 26, 00:11:55–00:20:40]

| 版本 | Inner loop 更新 | 消除的成本 | 仍有的成本/边界 |
| --- | --- | --- | --- |
| `psum-mutex` | 每次 P、更新单一 `gsum`、V | 保证正确性 | 所有更新串行、锁开销、同一 cache line ownership bounce |
| `psum-array` | 每线程更新 `psum[j]` | 去掉 mutex 与同一标量竞争 | 相邻 slots 可能在同一 cache line，仍反复访问 memory |
| `psum-local` | local/register `sum += i`，末尾写一次 | 把高频累加移出 memory | reduction、线程管理、硬件资源上限仍存在 |

课堂实测中，`psum-mutex` 增加第二 thread 反而约慢 9 倍；`psum-local` 在 8 cores 上最好约 6×、约 75% efficiency，16 threads 退化。这里最重要的推理是：正确性机制有性能成本；不同数组元素也可能因 cache line 粒度相互干扰；单线程优化仍是可信并行基线的前提。

> `[需回听]` `psum-mutex` 单线程时间先口述约 51 秒，后回顾成 58 秒；不合并为一个精确测量。课件文本抽取的 `n=231` 应结合指数排版核对为 $2^{31}$，正式引用图中数字前需看原页。

### 21. Speedup、efficiency 与基线

若 $T_p$ 是使用 $p$ 个 cores 的 elapsed runtime：

$$
S_p=\frac{T_1}{T_p},\qquad
E_p=\frac{S_p}{p}=\frac{T_1}{pT_p}.
$$

- **Relative speedup：** $T_1$ 来自 parallel code 的 one-thread version。
- **Absolute speedup：** $T_1$ 来自同一任务的最佳 sequential algorithm/implementation。老师认为它更真实，因为不会用弱单线程实现夸大并行收益。
- **Efficiency：** 实际 speedup 相对 $p$ 倍理想线性加速的比例。8 cores 上 6× 对应 $6/8=75\%$。

有 SMT 时，$p$ 按 physical core 还是 hardware-thread context 计数存在课堂所说的口径争议；报告必须声明分母。并行程序应测用户可见的 elapsed time，而不是把多个 cores 的 CPU time 累加后当作完成时间。[Lecture 26, 00:21:26–00:24:48; 00:42:37–00:43:09]

### 22. Amdahl's Law：串行部分限定上限

原运行时间为 $T$，比例 $p$ 可被加速 $k$ 倍，则

$$
T_k=\frac{pT}{k}+(1-p)T.
$$

令 $k\to\infty$：

$$
T_\infty=(1-p)T,
\qquad
S_\infty=\frac{T}{T_\infty}=\frac{1}{1-p}.
$$

课堂例子 $T=10,p=0.9,k=9$：

$$
T_9=\frac{0.9\times10}{9}+0.1\times10=2,
\qquad
S_9=\frac{10}{2}=5.
$$

极限时间为 1，极限 speedup 为 10。要严格区分“$1-p$ 是极限时间比例”和“$1/(1-p)$ 是极限 speedup”。[Lecture 26, 00:24:48–00:28:28]

> `[需回听]` 老师口述一度把 $T_9=2$ 称为“2x improvement”，并把 $1-p$ 称为 best speedup；课件公式与随后 10% 串行部分的例子支持上述修正。保留冲突，不把口述滑误写成公式结论。

### 23. Parallel quicksort：动态任务、固定 workers 与粒度

Sequential quicksort 先 partition，再递归处理互不重叠的左右区间。Partition 完成后，左右排序天然独立；但顶层 partition 本身先串行执行，所以 parallelism 只能逐层增长。[Lecture 26, 00:29:50–00:47:20]

课堂实现把 task 与 worker 分开：

```text
fixed worker pool
    -> workers repeatedly take (base, nele) tasks from a queue

large task
    -> partition
    -> spawn left task and right task

small task
    -> run serial quicksort directly
```

递归树中的 logical tasks 可以很多，但 OS threads 不按每个节点新建。Serial threshold 太大时过早转串行，parallelism 不足；太小时任务过细，queue、thread 和 control overhead 超过小块工作。课堂在固定 $2^{27}=134{,}217{,}728$ 个随机值上扫描参数，best speedup 为 6.84×，并观察到一个较宽的近最佳区间。

顶层只有 1 路 partition，下一层最多 2 路，再下一层最多 4 路。课件把第 $k$ 层上限写为

$$
2^{k-1}.
$$

这只是 task-count 上界；partition 不平衡、overhead 和 core 数都会进一步降低实际并行度。

> `[需回听]` 老师先把输入误读为 $2^{37}$，随即用数量级发现错误；课件数值精确对应 $2^{27}$。Serial-fraction 图的文本抽取与连续口述在两端标签上冲突；近似阈值范围 $2^5$ 到 $2^{12}$ 也应看原图后再作精确引用。

### 24. 局部加速不等于端到端加速

为消除顶层串行 partition，课堂尝试把输入切成四段，让四个 threads 对同一 pivot 做 local partition，再统计大小并把 $L_i/R_i$ 复制、重组为最终左右区间。Local scan 接近理想加速，但 overall program 没有变快：[Lecture 26, 00:47:20–00:51:50]

- 原 sequential partition 是 in-place。
- Parallel version 需要 temporary space。
- 它增加了统计、同步、copying 和 reassembly。
- 新增总工作抵消了 local kernel 的并行收益。

因此评价标准必须是包含全部步骤的 elapsed runtime。实现投入、局部 speedup 或“方案看起来很并行”都不是整体收益证据。课堂把 trial-and-error、testing、tuning、parameter sweep 和记录失败看作并行编程方法的一部分。

### 25. Sequential consistency：合法交错与不可能输出

初值 `a=1,b=100`。Thread 1 先写 `a=2` 再读 `b`，Thread 2 先写 `b=200` 再读 `a`：

$$
W_a<R_b,\qquad W_b<R_a.
$$

Sequential consistency 允许跨 threads 任意 interleave，但全局顺序投影到每个 thread 后必须保持其 program order。两条二事件有序序列共有 6 种合法 event ordering；多个 ordering 可能产生相同 value sequence，所以“6 种顺序”不等于“6 种 distinct outputs”。[Lecture 26, 00:52:37–00:56:18]

若两个 reads 都得到旧值，还需

$$
R_b<W_b,\qquad R_a<W_a.
$$

合并得到

$$
W_a<R_b<W_b<R_a<W_a,
$$

形成有向环，不存在满足它的 total order。因此 `100,1` 与 `1,100` 不可能来自 sequentially consistent execution。

### 26. Snoopy cache coherence：E/S/I 状态模型

朴素、互不协调的 write-back private caches 会让 `a=2` 只留在 Thread 1 cache、`b=200` 只留在 Thread 2 cache，而 main memory 仍是旧值。若对方直接读 memory，就会产生 sequential consistency 禁止的“双旧值”。[Lecture 26, 00:56:18–01:01:16]

课堂用简化 snoopy 状态解释硬件如何避免它：

| 状态 | 课堂含义 |
| --- | --- |
| Invalid (I) | 该 cache line 副本不可使用 |
| Shared (S) | 可有多个只读副本 |
| Exclusive (E) | 当前 cache 持有可写的独占最新副本 |

关键转换为：

1. Writer 写前取得 line 的 Exclusive copy。
2. 另一 core read miss，在共享通信介质上发出 request。
3. 持有 E-tagged 最新值的 peer cache supply value，不能让 stale main memory 回答。
4. 原持有者 $E\to S$，请求者也得到 S。
5. 任一 core 再写时，必须重新取得 Exclusive，并 invalidate 其他 Shared copies。

这套机制把正确性与性能连起来：`psum-mutex` 中所有 threads 高频更新同一 `gsum`，同一 cache line 的 Exclusive ownership 在 cores 间反复转移；再叠加更新串行化、lock protocol 和 semaphore 进入 kernel 的成本，最终比计算本身昂贵。[Lecture 26, 01:03:29–01:04:43]

> **模型边界：** E/S/I 是本讲的简化 snoopy 模型，老师明确说真实 coherence protocol 更复杂。本模块不把它扩写成未讲授的完整协议，也不补强/弱内存模型细节。

---

## 例子与证据边界总表

| 课堂例子 | 用来证明什么 | 不应外推为什么 |
| --- | --- | --- |
| Iterative echo server | 内核排队不等于应用并发；慢 client 可阻断全体 | 所有 `connect` 在所有条件下立即返回 |
| Process echo server | Descriptor ownership、zombie 回收、底层引用计数 | 进程间绝对不能共享任何状态 |
| Partial HTTP request | Readiness 不提供 message framing | `select`/`epoll` 的完整 API 教程 |
| `&connfd` / `&i` | Race 是两个未排序事件对同一可变 slot 的竞争 | 把任何地址传给 thread 都错误 |
| `badcnt` / `goodcnt` | `cnt++` 可拆分；mutex 用 $s\ge0$ 排除 unsafe region | `volatile` 或一次成功运行可证明正确 |
| `sbuf` | 资源计数、结构互斥和跨线程通知是不同职责 | Lecture 24 已经讲过 producer–consumer |
| Readers–writers | 首/末 reader 代表群体操作 `w`，并展示 priority/starvation | 课堂给出了 writer-priority 或无饥饿实现 |
| Prethreaded server | 固定 workers 消费 `connfd`，摊销创建成本 | Worker 数、buffer 大小已有普适最优值 |
| 双锁 progress graph | 相反获取顺序形成 deadlock region | 释放顺序也必须统一 |
| 三版 `psum` | 同步位置、cache-line 争用和 memory traffic 决定性能 | Shark 的 8/16-thread 结果适用于所有机器 |
| Parallel quicksort | 动态 tasks、固定 workers、阈值和 Amdahl bottleneck | Task 越细越快，或局部 kernel 加速保证整体加速 |
| E/S/I snoopy model | Peer cache 供给最新值并维护只读/独占状态 | 真实协议只有三个状态或没有其他 memory model |

### 明确未教授或尚未确认的内容

- Lecture 24 没有 producer–consumer；该内容从 Lecture 25 开始。
- Lecture 25 只实现 reader-priority readers–writers；writer-priority 代码和公平、无饥饿版本未给出。
- `pthread_once` 内部实现没有被确认。
- Lecture 26 没有定义 strong scaling 或 weak scaling。虽然实验固定输入并改变 core count，老师只使用 speedup、efficiency、serial fraction、overhead 与 Amdahl's Law；不得补写外部定义。
- Lecture 26 的性能数字属于 Shark 与具体输入；51/58 秒、serial-fraction 图轴等冲突必须回看。
- Lecture 26 的 E/S/I 只是一套课堂简图，不是完整硬件规范。

## 常见误解

1. **“Concurrency 就是多个 cores 同时执行。”** 单核时间切片也能产生 concurrent flows、race 和 deadlock；多核同时执行才是 true parallelism。
2. **“Backlog 大就让 iterative server 并发了。”** Backlog 只保存等待工作；唯一 server flow 仍不能为其他 clients 产生 response。
3. **“每个 thread 有 stack，所以 stack 对其他 threads 私有。”** 它只是正常使用上分区，仍位于共享 virtual address space，地址传出后可跨 thread 访问。
4. **“Ready descriptor 已收到完整 request。”** Readiness 只说明当前有 bytes 可读，完整 request/line 都需要显式 parser state。
5. **“Race 等于两条写指令同时发生。”** Race 的更一般表述是正确性依赖两个未规定事件的先后；单核抢占也足够。
6. **“`volatile` 能修复共享计数器。”** 它没有使 `L/U/S` 原子，也不提供互斥。
7. **“P 在 0 时先减到 -1 再睡眠。”** 课堂语义是不允许负值；P 在 0 时阻塞，维持 $s\ge0$。
8. **“`items` 已经锁住 buffer。”** `items` 表示可消费资格，`mutex` 才保护 `front/rear/buf` 更新。
9. **“Readers–writers 的 `mutex` 允许多个 holders。”** 它仍是普通 mutex，只因实际读取位于锁外，readers 才能并发。
10. **“Reader-priority 也保证 writer 最终运行。”** 持续到达的 readers 可能让 writer starvation；课堂没有给公平证明。
11. **“加更多锁总比一个锁安全。”** 多锁引入获取顺序和循环等待；相反顺序可以 deadlock。
12. **“Mutex 保证正确，所以放在 inner loop 也合理。”** 正确性与性能是不同维度；`psum-mutex` 展示同步和 coherence 成本可压倒工作。
13. **“写不同数组元素就没有 cache 竞争。”** 相邻元素可共享 cache line，硬件以 line 粒度转移和失效状态。
14. **“线程数翻倍，speedup 理应翻倍。”** 硬件资源共享、串行部分、任务粒度、同步、load imbalance 和额外工作都会限制收益。
15. **“局部并行阶段很快就证明程序更快。”** 必须测包含 copying、queue、synchronization 和收尾工作的 overall elapsed runtime。
16. **“Shared cache state 表示多个 writers 可共享写。”** Shared 只允许读；写者必须先获得 Exclusive 并失效其他副本。

## 掌握清单

- [ ] 能画出两个 clients 下 iterative server 的 `connect/write/read` 与 server `accept/read/write` 轨迹，指出真正阻塞点。
- [ ] 能按“交错者、address space、开销、调度控制、多核、调试”比较 process/event/thread。
- [ ] 能从 `refcnt(connfd)=2` 追踪 parent/child close，并解释 `SIGCHLD` 回收。
- [ ] 能设计 event loop 的 per-connection partial-input state，而不把 readiness 当完整消息。
- [ ] 能区分 per-thread execution context 与 process-shared state，并解释 stack address 跨 thread 可达。
- [ ] 能把 `&connfd` race 写成具体事件顺序，并用独立对象所有权解释修复。
- [ ] 能画“变量实例 × 引用线程”表，而不按声明位置猜共享性。
- [ ] 能逐状态手算 `L_i/U_i/S_i` 的一条安全与一条丢失更新轨迹。
- [ ] 能解释 progress graph、unsafe region、forbidden region、deadlock region 和 unreachable states 的区别。
- [ ] 能准确复述 P/V 的原子、阻塞、唤醒语义，并从中推出 $s\ge0$。
- [ ] 能不看代码写出 `sbuf_insert` 与 `sbuf_remove` 的五步次序，并说明每个 semaphore 的单独职责。
- [ ] 能推导 reader-priority 算法中首读者、末读者、`readcnt`、`mutex`、`w` 和 writer starvation。
- [ ] 能画 prethreaded server 的 master/buffer/worker 数据流，并解释 `pthread_once` 的契约边界。
- [ ] 能识别四类 thread-unsafe functions，区分 thread-safe 与 reentrant。
- [ ] 能从多锁 P/V 次序构造循环等待，并应用统一获取全序。
- [ ] 能写出 parallel summation 的区间公式，并从 mutex → array → local 解释每步减少的 overhead。
- [ ] 能计算 $S_p$、$E_p$、$T_k$ 与 $S_\infty$，并说明 relative/absolute baseline。
- [ ] 能把 parallel quicksort 画成 dynamic task tree + fixed worker pool，并解释 serial threshold 两端。
- [ ] 能用 overall elapsed time说明 parallel partition 的局部加速为何失败。
- [ ] 能枚举 sequential consistency 的合法交错，写出“双旧值”的约束环。
- [ ] 能沿 E→S、read supply、invalidation 解释 snoopy coherence，并回扣 `psum-mutex` 的性能。
- [ ] 能主动指出 strong/weak scaling、writer-priority 实现和完整 coherence protocol不在本模块证据范围内。

## 15 道累计问题与答案要点

### 问题 1：迭代式服务器的阻塞轨迹

Client 1 建连、完成一次 echo 后不再输入也不关闭；Client 2 随后连接、发送一行并等待 echo。画出课堂轨迹，指出 client 2 的 `connect`、`rio_writen`、`rio_readlineb` 哪一步阻塞，并说明 backlog 为什么不是并发。

**答案要点：**

- 课堂场景中 connection request 可进入 listen backlog，`connect` 返回。
- Client 2 的 data 可由 kernel buffer，`rio_writen` 返回。
- Server 唯一 flow 阻塞在 client 1 的 read，没有为 client 2 write response。
- Client 2 在 `rio_readlineb` 等不存在的 response。
- Backlog 只排队，不创建可同时服务 client 2 的应用 flow。
- “立即返回”仅限课堂场景，保留网络条件边界。

### 问题 2：并发模型选择

三个服务分别要求：(a) 强隔离且几乎不共享业务状态；(b) 单 core 上处理大量 mostly-I/O connections，并要精确控制 ready clients 的服务次序；(c) 共享 in-memory cache，并能利用多个 cores。分别选择课堂最直接的模型，并列出一项主要代价。

**答案要点：**

- (a) Process-based：private address spaces，代价是 process control 与 IPC/shared cache 麻烦。
- (b) Event-based：programmer 控制 event order、开销低，代价是 partial-state machine 复杂，单 loop 不利用多核。
- (c) Thread-based：共享 address space 且可多核，代价是 unintended sharing、race、thread safety 与调试困难。
- 选择是按需求的 trade-off，不是宣布模型的普遍排名。

### 问题 3：进程服务器的 descriptor 生命周期

Parent `accept` 后 fork child。假设 fork 后底层 connected socket 的引用计数为 2。写出 parent 与 child 应关闭的 descriptor、child 回收方式，以及 parent 漏关 `connfd` 的后果。

**答案要点：**

- Child 关闭不负责的 `listenfd`，服务后关闭 `connfd` 并退出。
- Parent 立即关闭自己的 `connfd`，保留 `listenfd` 继续 accept。
- Handler 用 `while (waitpid(-1, 0, WNOHANG) > 0)` 回收当前 zombies。
- Parent close 后 refcount 2→1，child close 后 1→0。
- Parent 漏关会保留底层 socket/open-file 引用，child close 不足以归零。
- Descriptor tables 是副本，但条目可引用同一 kernel object。

### 问题 4：Event state 与 thread argument race

设计一个可处理 partial HTTP line 的 event handler 状态，并同时解释为什么 thread server 不能把同一个 main-local `connfd` 地址传给每个 peer。两部分共同依赖哪一个更一般的原则？

**答案要点：**

- 每个 active `connfd` 保存 buffer、已读长度和 parser progress。
- Ready 时只读 available bytes，拼接并处理已完整的边界，未完整部分留到未来 event。
- `&connfd` 指向循环反复覆盖的同一 stack slot；peer 解引用前 main 可写入下一个 fd。
- 正确版本使用 per-connection heap object，peer 复制后释放。
- 一般原则：不能假定未被 API 保证的事件顺序；共享 mutable state 必须有明确的状态/所有权协议。

### 问题 5：共享变量实例分析

Main stack 上有数组 `msgs`，其地址存入全局 `ptr`；两个 peers 通过 `ptr` 读取。每个 peer routine 有普通局部 `myid`，并共同递增函数内静态 `cnt`。判断 `ptr`、`msgs`、`myid`、`cnt` 是否共享，并给出实例理由。

**答案要点：**

- `ptr`：一个 global instance，被多个 threads 引用，共享。
- `msgs`：虽在 main stack，仍经 `ptr` 被 peers 间接引用同一 instance，共享。
- `myid`：每个 routine activation/thread stack 有独立 instance，各自单线程引用，不共享。
- `cnt`：函数内 `static` 只有一个 instance，被两个 peers 引用，共享。
- 判断依据是“多个 threads 是否引用同一 instance”，不是名称作用域或 stack/data segment 二分。

### 问题 6：手算丢失更新

初始 `cnt=0`。按轨迹

$$
H_1,L_1,U_1,H_2,L_2,S_1,T_1,U_2,S_2,T_2
$$

维护 `%rdx_1`、`%rdx_2` 与 `cnt`，并指出轨迹何时进入 unsafe region。

**答案要点：**

- `L_1` 得 `%rdx_1=0`，`U_1` 得 1，但尚未写回。
- `L_2` 仍从 memory 读 0，得 `%rdx_2=0`。
- `S_1` 使 `cnt=1`。
- `U_2` 使 `%rdx_2=1`，`S_2` 再写 1，最终 `cnt=1`。
- 两个 `L/U/S` critical sections 发生交错，联合状态进入 unsafe region。
- 每条局部算术都正确，错误来自基于旧快照的覆盖。

### 问题 7：从 P/V 语义证明 mutex

不能只写“临界区前 P、后 V”。请从初值 1 和 $s\ge0$ 证明两个 threads 不能同时进入同一受保护临界区，并说明一次 V 对等待者做什么。

**答案要点：**

- 第一个 P 原子地完成 1→0 后进入。
- 在其 V 前，第二个 P 面对 0，阻塞而不能产生 -1。
- 所有要求 $s=-1$ 的 states 构成不可达 forbidden region。
- Forbidden region 包围 unsafe region，所以临界区不能交错。
- V 原子加一；有等待者时 restart exactly one，选择次序未规定。
- 被 restart 的 thread 仍要完成自己的 decrement 后 P 才返回。

### 问题 8：`goodcnt` 的正确性与代价

为 `cnt++` 加 mutex 后，程序结果正确但显著变慢。分别从 progress graph、调用频率和后续 cache coherence 解释“正确”和“慢”，并说明为什么不能删锁后用测试成功替代证明。

**答案要点：**

- Mutex 让轨迹不能进入 unsafe region，因此消除丢失更新。
- 每次 increment 都执行 P/V，属于高频同步。
- 多 cores 高频写同一 line，会反复取得 Exclusive ownership并失效其他副本。
- Semaphore 还带有课堂所述 kernel transition 成本。
- 删锁后一次运行只是恰好走 safe trajectory，未覆盖所有合法 interleavings。
- 正确性机制与锁粒度/性能优化是两项不同任务。

### 问题 9：有界缓冲区协议审计

某 producer 写成 `P(mutex) -> P(slots) -> write -> V(items) -> V(mutex)`，consumer 写成 `P(items) -> read/update front -> V(slots)`。指出与课堂协议的差异和风险，并给出正确序列。

**答案要点：**

- Producer 在持有 mutex 时等待 `slots`，会把结构锁带入可能长期阻塞的资源等待；课堂先 `P(slots)` 再 `P(mutex)`。
- Producer 在释放结构锁前 V(items)，会先宣布 item 可用；正确顺序先完成写和 `V(mutex)`，再 `V(items)`。
- Consumer 缺少 `P(mutex)/V(mutex)`，多个 consumers 可竞争 `front/buf` 更新。
- 正确插入：`P(slots) -> P(mutex) -> write -> V(mutex) -> V(items)`。
- 正确移除：`P(items) -> P(mutex) -> read -> V(mutex) -> V(slots)`。
- `slots/items` 是资源资格和通知，`mutex` 是结构互斥。

### 问题 10：读者优先算法轨迹

两个 readers R1、R2 和一个 writer W 到达。R1 是首读者，R2 在 R1 读取期间到达，W 在两者之间开始等待。写出 `readcnt`、`mutex`、`w` 的关键变化，并解释为何后来 readers 可导致 W starvation。

**答案要点：**

- 初始 `readcnt=0,w=1`。
- R1 在 `mutex` 内把 count 0→1，作为首读者 P(w)，使 w=0，然后释放 mutex 并读取。
- W 的 P(w) 阻塞。
- R2 只在 mutex 内把 count 1→2，不再 P(w)，随后与 R1 并发读取。
- Readers 退出时在 mutex 内 decrement；只有末读者让 count 1→0 并 V(w)。
- 若新 readers 持续在 count 归零前加入，读者群体一直持有 w，W 可无限等待。
- 本讲没有 writer-priority 实现或无饥饿证明。

### 问题 11：预线程化服务器与 thread safety

画出 `Accept -> sbuf_insert -> sbuf_remove -> echo_cnt -> Close` 的数据流。若 `echo_cnt` 还更新全局 `byte_cnt` 并调用返回静态字符串地址的函数，分别需要什么课堂机制？

**答案要点：**

- Master 是 producer，投递共享 descriptor table 中的 `connfd`。
- Fixed workers 是 consumers，取 fd、服务、关闭，再回队列。
- `sbuf` 用 producer–consumer 的三 semaphore 协议。
- `byte_cnt` 的 read-modify-use 应由同一 mutex critical section 保护。
- 一次性包初始化可用共享 `pthread_once_t` 与 `Pthread_once`，只保留 API contract。
- 静态返回对象可经同一 mutex 做 lock-and-copy 到 caller-private buffer；锁覆盖调用和复制。
- 若能改接口，把状态/结果移到 caller-private storage 可形成 reentrant 方向。

### 问题 12：双锁死锁证明与修复

Thread 0 获取 `s0 -> s1`，Thread 1 获取 `s1 -> s0`。构造一个 deadlock trajectory，区分 forbidden region 与 deadlock region，并给出课堂修复。释放顺序是否必须统一？

**答案要点：**

- T0 先成功 P(s0)，T1 再成功 P(s1)。
- T0 的 P(s1) 阻塞，T1 的 P(s0) 阻塞；各自 V 在第二个 P 后，永远到不了。
- Forbidden region 是同时持有同一 binary semaphore 的非法 states，轨迹不能进入。
- Deadlock region 可合法进入，但所有前进路径最终被 forbidden regions 挡住。
- 统一全序，让所有 threads 都 `P(s0) -> P(s1)`，消除 deadlock region。
- 课堂明确说释放顺序无关，只会改变 unreachable region 的形状。

### 问题 13：Parallel summation 逐版诊断

对 `psum-mutex`、`psum-array`、`psum-local`，写出共享更新位置、预计的主要 overhead，以及为什么 8→16 hardware threads 在 local 版本中可能退化。不要只回答“锁慢”。

**答案要点：**

- `psum-mutex` 每次 loop 更新同一 `gsum`：P/V、高度串行、同一 cache line Exclusive ownership bounce、kernel cost。
- `psum-array` 每 thread 更新自己的 slot：无 mutex，但相邻 slots 可共享 cache line，且每次 loop 有 memory reference。
- `psum-local` 在 register/local 累加，末尾写一次 slot：显著减少 memory traffic。
- Two-way SMT 不增加完整 functional units；local add loop 已较充分使用所需资源时，第二 context 只增加竞争。
- 结论依赖 Shark 和该 workload，不外推为所有 SMT。
- 可信比较还需强 sequential/absolute baseline。

### 问题 14：性能公式与 quicksort 粒度

某 8-core quicksort 的最佳 sequential time 为 80 s，并行 elapsed time 为 12 s；parallel code 自己的 one-thread time 为 96 s。计算 absolute/relative speedup 和 absolute efficiency。若 10% 时间永远串行，给出无限资源上限。再解释 serial threshold 太大、太小各有什么问题。

**答案要点：**

- Absolute speedup $=80/12\approx6.67$。
- Relative speedup $=96/12=8$；它比 absolute 数字漂亮，因为 one-thread parallel baseline 较弱。
- Absolute efficiency $\approx6.67/8\approx83.3\%$。
- 串行比例 0.1 时 $S_\infty=1/0.1=10$。
- Threshold 太大：过早 serial sort，parallelism 不足。
- Threshold 太小：tasks 过细，queue/thread/control overhead 超过小块工作。
- 顶层 partition 仍串行，parallelism 逐层从 1、2、4 扩展。
- 应以 overall elapsed time 扫描参数，而不是只测 partition kernel。

### 问题 15：从一致性到性能的综合题

初值 `a=1,b=100`；T1 执行 `W(a=2); R(b)`，T2 执行 `W(b=200); R(a)`。证明两个 reads 都看到旧值不符合 sequential consistency，再用课堂 E/S/I snoopy 模型说明 coherent hardware 如何让 reader 得到最新值。最后把同一机制联系到 `psum-mutex` 的坏性能。

**答案要点：**

- Program order 给出 $W_a<R_b$ 与 $W_b<R_a$。
- 双旧值另需 $R_b<W_b$ 与 $R_a<W_a$。
- 合并成 $W_a<R_b<W_b<R_a<W_a$，形成 cycle，不存在 total order。
- Write-back memory 可暂时 stale；read miss 不能盲目由 memory 返回。
- 持有 E-tagged 最新 line 的 peer cache snoop request 并 supply value。
- 原持有者 E→S，请求者取得 S；后续 writer 必须获取 E 并 invalidate 其他 S copies。
- `psum-mutex` 每次写同一 line 都触发 ownership transfer/serialization，再叠加 semaphore/kernel cost。
- E/S/I 是课堂简化模型，不应扩写为完整协议；strong/weak scaling 也不在本讲证据内。

## 推荐复习顺序

1. **先重建 Lecture 23 的动机链。** 从 iterative server failure 开始，画出 process/event/thread 的二维分类，再分别追 descriptor ownership、partial input state 和 `&connfd` race。
2. **再做 Lecture 24 的手算。** 先画变量实例表，再从 `cnt=0` 手算一条安全和两条错误 `L/U/S` 轨迹；随后画 progress graph，不看笔记重建 $s\ge0$ 到 mutual exclusion 的证明。
3. **进入 Lecture 25 时先写协议，不先背名词。** 默写 `sbuf_insert/remove`，再推首读者/末读者算法；把 `connfd` 放进同一 producer–consumer 图，最后复习 thread safety 四类、`&i` 和双锁 deadlock。
4. **学习 Lecture 26 时先做性能基线。** 按 `psum-mutex -> psum-array -> psum-local` 解释每次状态迁移，再计算 speedup、efficiency 与 Amdahl；确认 elapsed time 和 absolute baseline 后再看 parallel quicksort。
5. **最后把正确性与硬件成本闭环。** 枚举 sequential consistency ordering，写出双旧值约束环，沿 E→S 和 invalidation 走一遍 snoopy trace，再回头解释为何同一共享热变量会拖垮并行性能。
6. **以证据审计收尾。** 回查所有 `[需回听]`，尤其是 `connect` 条件、51/58 秒、Amdahl 口误、$2^{27}$ 输入、serial-fraction 图轴和 E/S/I 模型边界；明确不补 strong/weak scaling、writer-priority 实现或完整 coherence protocol。
{% endraw %}
