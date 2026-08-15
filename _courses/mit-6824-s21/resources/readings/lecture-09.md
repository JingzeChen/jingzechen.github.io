---
uid: mit-6824-s21-resource-reading-9
type: course
document_type: resource
resource_kind: reading
resource_order: 109
course: mit-6824-s21
title: Lecture 9 阅读指南：ZooKeeper
description: Lecture 9 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 9 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-09/"
toc: true
official_lecture_number: 9
math: true
---

## 1. 来源、指定范围与证据边界

- 指定论文：**ZooKeeper: Wait-free Coordination for Internet-scale Systems**（Hunt, Konar, Junqueira, Reed，2010）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- 本讲另有官方 FAQ 与 Paper Question。FAQ 中明确标成 “the paper doesn't say” 或 “probably/likely” 的内容只能作为疑问与实现推测，不能升级成论文事实。
- 课堂 NOTES 只用于“课堂连接”；论文的实现细节、recipes 与 evaluation 不反向写成课堂已讲内容。
- 不使用其他版本的 ZooKeeper 文档、Zab 论文、第三方 client 实现或后续 dynamic reconfiguration 事实补写本指南。

资源：

- [Lecture 9 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-09.md)
- [ZooKeeper 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/zookeeper.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/zookeeper-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/09-q-zookeeper.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-9-zookeeper)
- [Lecture 9 NOTES](/courses/mit-6824-s21/lectures/009/)
- [Lecture 9 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=9)

## 2. 阅读任务与章节地图

建议按以下问题阅读全文：

1. **§1 Introduction：** 为什么 coordination service 不直接内置 locks、leader election 等固定高级 primitive，而提供一个 wait-free kernel？
2. **§2 ZooKeeper Service：** znode、session、watch、versioned operation 和 ordering guarantees 如何组成 client-visible model？
3. **§2.4 Recipes：** configuration、group membership、simple lock、无 herd-effect lock、读写锁和 barrier 如何只用 client-side recipe 实现？
4. **§3 Implementation：** request processor、atomic broadcast、replicated database 与 response processor 如何让 writes 有序、reads 可本地执行？
5. **§4–§5：** production uses 与 evaluation 支持哪些性能结论，受哪些 workload 假设限制？
6. **§6–§7：** related work 和 conclusion 如何重新说明 ZooKeeper 的贡献边界？

阅读时始终分开三个层次：

```text
ZooKeeper API guarantees
  -> client recipes 组合出的 coordination primitive
  -> application 自己必须维护的跨系统 invariant
```

ZooKeeper 保证第一层；第二层需要正确 recipe；第三层不会因为“拿到了 ZooKeeper lock”自动成为 transaction。

## 3. 问题与系统模型

### 3.1 要解决的问题

大型 distributed applications 反复需要 configuration、group membership、leader election、locks、barriers 等 coordination。若每种需求都建一个 server-side service，会固定 primitive 集合，也会把 slow/faulty client 的等待行为带进服务核心。

ZooKeeper 选择另一条路线：

- server 只提供小而通用的数据与顺序 primitive；
- 高级 coordination recipe 在 client 端组合；
- API operation 本身不等待另一个 client 采取动作，因此保持 wait-free；
- 真正需要等待时，把等待拆成 one-shot watch notification。

### 3.2 数据模型

ZooKeeper 把 coordination metadata 放在 hierarchical namespace 中。每个 **znode**：

- 用完整 path 定位，不需要 `open` handle；
- 保存少量 data 与 metadata；
- 有 version counter，可做 conditional update；
- 可以是 regular 或 ephemeral；
- create 时可使用 sequential flag，让 parent 下的名字附加单调递增序号。

Znode 不是 general-purpose file storage。论文把它定位为 configuration、membership、leader identity 等 coordination metadata。

### 3.3 Session 与 failure model

Client 与 ensemble 建立 session；session 有 timeout，并可在不同 ZooKeeper servers 之间迁移。ZooKeeper 在超过 timeout 没收到 session 活动时把 client 视为 faulty，session 结束后删除该 session 创建的 ephemeral znodes。

这不是瞬时 crash detector：

- client crash 与 network partition 在 timeout 前不可区分；
- ephemeral lock 的释放发生在 session termination/expiration，而不是断线瞬间；
- 被判失效的旧 session 不能在网络恢复后继续沿用原 ownership。

服务的 liveness/durability 边界是：多数 servers active 且互通时服务可用；已成功响应的 change 在最终仍能恢复一个 quorum 的前提下保持持久。

## 4. API、机制与不变量

### 4.1 核心 API

| Operation | 关键语义 |
| --- | --- |
| `create(path, data, flags)` | 原子创建；可选 regular/ephemeral 与 sequential naming |
| `delete(path, version)` | 仅在 expected version 匹配时删除 |
| `exists(path, watch)` | 返回存在性，并可设置 watch |
| `getData(path, watch)` | 返回 data 与 metadata/version，并可设置 watch |
| `setData(path, data, version)` | 仅在 current version 匹配时写入 |
| `getChildren(path, watch)` | 返回 child names，并可设置 watch |
| `sync(path)` | 等待调用开始前 pending updates 传播到当前连接 server；path 在论文实现中被忽略 |

同步与异步版本都存在。异步 API 允许一个 client 同时保有多个 outstanding operations；对应 callbacks 按 client order 调用。

### 4.2 Watch invariant

Watch 是与 session 关联的 one-time trigger：

- read 正常返回，同时 server 承诺目标信息改变时通知；
- trigger 后即注销，client 若要继续观察必须重新 read 并重新注册；
- event 只说明“发生变化”，不携带全部 changes；
- 两次变化可能合并成一次 notification；
- session event 会提醒 client notification 可能延迟。

因此正确使用模式是：

```text
read current state + install watch
  -> wait for event
  -> discard stale assumption
  -> re-read current state + install next watch
```

Watch 不是 event log，也不是 multi-key snapshot。

### 4.3 Versioned conditional update

每个 update 带 expected version。若实际 version 不匹配，operation 失败；`-1` 表示不做 version check。典型 optimistic pattern 是：

```text
read value and version
compute candidate update
conditional setData(expected version)
on mismatch: re-read and retry
```

Stale read 可能增加 retry，却不会让旧值无条件覆盖新值。这是 ZooKeeper API 能组合 test-and-set、counter 等 primitive 的关键。

### 4.4 Wait-free 的准确含义

论文所说 wait-free 是：一个 client 的 API operation 不依赖另一个 client 采取步骤才能完成。它不表示：

- 每个调用在网络故障下都有固定 wall-clock latency；
- client recipe 从不阻塞；
- lock contender 不需要等待。

Blocking recipe 由 atomic operation 与 watch 组合：service core 不把某 client 的进度绑定到另一个 client，等待发生在 client 逻辑中。

## 5. 一致性与顺序保证

### 5.1 两项基本保证

论文列出：

1. **Linearizable writes / A-linearizable updates：** 所有修改 ZooKeeper state 的 requests 被排进尊重 precedence 的 total order。
2. **FIFO client order：** 同一 client 发出的 operations 按其发送顺序执行。

Reads 不经过 Zab total order，可由当前连接 replica 本地服务。因此 read 可能没有看到其他 clients 已完成的最新 write。

### 5.2 合法 stale read 的边界

设全局 write order 为：

$$
W=(w_1,w_2,\ldots,w_n).
$$

一次 local read 可观察某个 prefix $W[1..k]$。对同一 session 的 successive reads，观察位置不能倒退；client 自己此前的 writes 也必须位于后续 read 的已观察 prefix 中。

因此要区分：

- **允许：** Client A 已看到较新 state，而 Client B 在 lagging replica 读到较旧 state。
- **不允许：** 同一 client 先看到较长 prefix，换 server 后回到更短 prefix。
- **可加强：** 需要跨 client channel 的 freshness 时，先 `sync` 再 read。

### 5.3 `ready` publication invariant

论文示例让新 leader 按顺序执行：

```text
delete(ready)
write configuration znodes
create(ready)
```

若 reader 观察到本轮最后的 `create(ready)`，随后 reads 不能回到它之前的 write prefix，所以能看到 preceding configuration writes。若 reader 先观察到旧 `ready`，则 watch 会在 configuration boundary 改变时通知；reader 必须丢弃 partial result 并 restart。

该 recipe 不是 general multi-znode transaction。它依赖 marker、write order、watch order 与 application restart discipline。

## 6. Coordination Recipes

### 6.1 Configuration management

Configuration 存在一个已知 znode。Process 读取并设置 watch；收到 change notification 后重新读取并重新设置 watch。多次更新即使只产生一次 event 也没有问题，因为 event 的用途是宣告 cached value stale。

### 6.2 Group membership

每个 participant 在 application subtree 下创建自己的 ephemeral child。Session 存活时 child 存在；session 结束时 child 自动删除。`getChildren` 加 watch 让其他成员观察 membership change。

### 6.3 Simple lock

```text
acquire:
  try create(lock, ephemeral)
  if success: acquired
  otherwise exists(lock, watch=true), then wait and retry

release:
  delete(lock)
```

Mutual exclusion 依赖 `create` 是 linearizable update：同一路径从不存在到存在的竞争中，只有一个 create 能成功。Owner failure 通过 session expiration 删除 ephemeral znode。

Race 检查：若 lock 在失败者 `create` 与 `exists(..., watch=true)` 之间被释放，`exists` 会看到 node 已不存在，client 直接重试，而不是永远等待一个已经错过的 event。

### 6.4 避免 herd effect 的 lock

Contender 创建 ephemeral sequential child，读取 contenders，并只 watch 自己的直接 predecessor。最小 sequence number 持有 lock；predecessor 消失时只有下一位主要 contender 被唤醒。Watch 可能因更早 contender 退出而在“还没轮到自己”时触发，所以醒来后必须重新列 children、重新判断。

### 6.5 Barrier

Participants 创建 znodes 表示到达/离开，并通过 children watches 等待集合满足条件。FAQ 强调离开 barrier 时，每个 client 要观察其他 participants 的 znodes，直到它们都消失。

## 7. 实现、故障与恢复

### 7.1 Replicated pipeline

Client library 管理 session 与 server connection。Server 侧高层路径是：

```text
request processor
  -> write: leader + Zab atomic broadcast -> replicated database
  -> read: local replicated database
  -> response processor
```

- Writes 由 leader 排序并传播；
- Reads 不进入 Zab，可在 replica local state 上完成；
- Async requests 与 server pipeline 允许许多 outstanding operations；
- batching 把多个小 network/disk operations 合并，摊薄固定成本。

### 7.2 Fuzzy snapshot

精确 snapshot 若阻塞整个 in-memory database 的 writes，会显著损害性能。ZooKeeper 允许 snapshot 与 updates 并发，因此 snapshot 可能包含 concurrent writes 的一个非精确组合。恢复时从 snapshot 起点重放 ordered idempotent transactions，把 state 修正为一致结果。

FAQ 给出的关键边界是：leader 先把 conditional API operation 转成包含新 data/version/timestamps 的 idempotent transaction；重放的是这种 transaction，不是再次执行原始 conditional decision。

### 7.3 论文未充分说明的 client retry 细节

官方 FAQ 明确指出，论文没有完整解释：

- async request 如何编号并在 leader change 后保持 per-session order；
- request/reply 丢失后的 resend 与 duplicate suppression；
- client write 后立即 local read 时，server 如何精确等待到该 client 的 write progress。

阅读答案应把这些写成 open implementation questions，不能把 FAQ 的 “probably/likely” 当论文结论。

## 8. Evaluation 与证据边界

### 8.1 论文实际支持的结论

- 目标 workload 的 read:write ratio 从 `2:1` 到 `100:1`。
- Abstract 报告 tens to hundreds of thousands of transactions per second。
- 课堂 NOTES 对论文图的读取是：三台 servers 的纯 write workload 约 `21K ops/s`，纯 read 区域约 `60K–70K ops/s`；这些是对应实验图与课堂口述的数量级，不是所有部署的 SLA。
- Read throughput 随 servers 增加而上升，因为 reads 可本地服务；write throughput 随 ensemble 增大可能下降，因为一次 write 要与更多 replicas 协调。
- Pipeline/batching 解释了为何 aggregate write throughput 可以远高于“每 request 单独同步落盘”的倒数。

### 8.2 不能从 evaluation 推出的结论

- 高 read throughput 不等于 reads linearizable 或永远 fresh。
- 更多 replicas 不会让 write latency/throughput自动改善。
- 论文 benchmark 不证明 arbitrary data-store workload；znodes 面向小 coordination metadata。
- 吞吐随 read ratio 改变，不代表单次 operation latency 同比例变化。
- 成功 serving coordination workload 不表示 application 的外部 critical section 自动 atomic。

## 9. 设计权衡

| 设计选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| Client-side recipes | Kernel 小、可组合新 primitive | Programmer 必须正确处理 watch、retry、stale read |
| Local replica reads | Aggregate read capacity 可扩展 | Read 可能 stale，不是 full linearizability |
| Linearizable writes + FIFO order | Conditional update 与 publication 可推理 | 跨 client freshness 需 `sync` 或额外 protocol |
| One-shot watches | 避免 polling，slow client 不阻塞 writer | Event 可合并，client 必须 re-read/re-register |
| Ephemeral znodes | Session failure 后自动清理 membership/lock marker | Failure detection 延迟到 timeout；不是事务回滚 |
| Sequential predecessor watch | 避免 herd effect、形成队列 | 需要额外 znodes/listing/recheck；watch 可提前触发 |
| In-memory replicated database | Fast local reads | Data set 应适合 memory，非 general bulk storage |
| Async pipeline + batching | 高 aggregate throughput | 需要足够并发 workload；ordering/retry 更复杂 |
| Fuzzy snapshots | Snapshot 不长时间阻塞 writes | 依赖 ordered idempotent transaction replay |

## 10. 官方 FAQ 精要

1. **为什么只有 updates A-linearizable？** 为让 replicas 本地服务 reads；lagging replica 可返回 stale state。
2. **Linearizability 与 serializability 差异？** FAQ 强调 real-time order 是差异；论文还把 write order 与 FIFO client order 分开讨论。
3. **Pipelining 是什么？** Leader batching network/disk work，clients 又通过 async API 保持多个 outstanding requests。
4. **Wait-free 是什么？** 单个 API operation 的完成不依赖另一个 client 行动；等待由 watch recipe 承担。
5. **为什么 fuzzy snapshot 正确？** 恢复重放 snapshot 起点之后的 ordered idempotent transactions。
6. **为何 `ready` race 可解？** Preceding writes 在 write order 中早于 ready，watch 又暴露跨 configuration boundary 的变化。
7. **Watch 如何用于 barrier？** Client 观察参与者 nodes，直到它们全部消失。
8. **Page 6 read-lock recipe 的 jump？** FAQ 认为跳转行号是论文 bug；本指南不自行改写 assigned PDF。
9. **Leader election、duplicate retry 等实现细节？** FAQ 有推测，但论文没有完整说明，应保留为 open questions。
10. **Cluster membership 能否动态变化？** FAQ 提到后续系统支持；这属于论文之后的材料，不用于解释 2010 paper mechanism。

## 11. 官方 Paper Question

**Assigned Question（原文）**：

> One use of Zookeeper is as a fault-tolerant lock service (see the section "Simple locks" on page 6). Why isn't possible for two clients to acquire the same lock? In particular, how does Zookeeper decide if a client has failed and it can give the client's locks to other clients?

### 推理脚手架（不是可直接提交的答案）

1. 先写出 lock path 初始不存在，并让两个 clients 并发调用 `create(..., ephemeral)`。
2. 指出应引用哪项 update-order guarantee，说明为什么两个 create 不能都把同一路径从 absent 变成 present。
3. 对失败者分两种 interleaving：lock 仍存在时成功安装 watch；lock 在 create 失败与 exists/watch 之间已经删除。
4. 说明第二种 interleaving 为什么不会 lost wakeup：exists 的返回 state 会驱动立即 retry。
5. 再单独分析 owner crash/partition：ZooKeeper 观察的不是 OS process state，而是 session activity 与 timeout。
6. 把 “client failed” 精确写成 session termination/expiration，并说明 ephemeral node 何时被服务删除。
7. 检查 network 恢复后的旧 session 是否仍可主张 ownership。
8. 最后划边界：lock znode mutual exclusion 不会回滚 owner 已对其他 systems 做出的 partial side effects。

## 12. 课堂连接

[Lecture 9 NOTES](/courses/mit-6824-s21/lectures/009/) 把论文重心重新排序为：

```text
throughput baseline
  -> local-read stale/time-travel counterexample
  -> linearizable writes + FIFO client order
  -> zxid progress-floor intuition
  -> ready/watch/restart
  -> znode API + versioned mini-transaction
```

课堂最重要的补充是把 performance 与 consistency tradeoff 用 Lab 3-style read 路径具体化，并明确 `zxid` explanation 是 rough implementation intuition。反过来，论文中的完整 lock/barrier recipes、fuzzy snapshots、service uses 与 evaluation 应留在阅读指南，不能说成 Lecture 9 全部讲过。

Lecture 11 NOTES 后来补讲了 simple lock、herd effect、sequential predecessor watch 与 ZLock 的 failure boundary。它可以帮助复习 recipe，但不改变 Lecture 9 的证据边界。

## 13. 论文理解题（10 题）

1. **为什么 ZooKeeper 不直接提供 blocking lock API？**  
   答案点：保持 server-side operation wait-free；避免一个 slow/faulty client 阻塞 service core；高级 primitive 由 client recipe 组合。
2. **Regular、ephemeral 与 sequential 各解决什么问题？**  
   答案点：显式 lifetime；session-bound cleanup；同 parent 下建立可比较顺序。
3. **为什么 watch 不能当作 change log？**  
   答案点：one-shot、可合并，只说明 state changed；收到后必须 re-read/re-register。
4. **为什么 local reads 能扩展，却不 full-linearizable？**  
   答案点：replica 可落后于 write quorum/leader progress，read 不进入全局 write order。
5. **FIFO client order 给 stale reads 增加了什么约束？**  
   答案点：read-your-own-writes；successive reads 不退回更短 write prefix。
6. **Versioned `setData` 为什么能安全处理 stale read？**  
   答案点：stale version 导致 conditional write 失败和 retry，而非覆盖 newer value。
7. **Simple lock 如何避免 create/watch 之间的 lost wakeup？**  
   答案点：`exists(..., watch)` 原子返回当前存在性并设置 watch；若已不存在就直接 retry。
8. **为什么 predecessor-watch lock 比 simple lock 更可扩展？**  
   答案点：释放时主要唤醒下一位，不让全部 contenders 同时重试。
9. **Fuzzy snapshot 为什么需要 idempotent transactions？**  
   答案点：snapshot 与 writes 并发，恢复会从起点重放；重复 apply 必须得到相同 state。
10. **论文 evaluation 的 read scaling 结论依赖什么？**  
    答案点：read-heavy workload、replica local reads、足够 active clients/pipelining；不能推出 fresh reads 或 arbitrary workload 性能。

## 14. 复习清单

- [ ] 能画出 znode/session/watch/version model。
- [ ] 能区分 wait-free API 与 blocking client recipe。
- [ ] 能写出 linearizable writes、FIFO client order 与 local-read stale boundary。
- [ ] 能解释 `ready` marker 为什么还需要 watch/restart。
- [ ] 能逐步证明 simple lock mutual exclusion 与 owner-failure cleanup。
- [ ] 能说明 sequential predecessor watch 如何减少 herd effect。
- [ ] 能区分 API guarantee、client recipe 与 external side-effect atomicity。
- [ ] 能解释 async pipeline/batching、local reads 与 fuzzy snapshot 的性能作用。
- [ ] 能复述 evaluation 支持的趋势，并指出 workload/metric 边界。
- [ ] 能独立完成官方 Question 的事件序列，而不复制一段结论。
