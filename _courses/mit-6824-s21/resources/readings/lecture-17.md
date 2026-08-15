---
uid: mit-6824-s21-resource-reading-17
type: course
document_type: resource
resource_kind: reading
resource_order: 117
course: mit-6824-s21
title: Lecture 17 阅读指南：Cache Consistency - Memcached at Facebook
description: Lecture 17 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 17 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-17/"
toc: true
official_lecture_number: 17
---

## 1. 来源、范围与证据边界

- 指定阅读是完整的 **Scaling Memcache at Facebook (NSDI 2013)**；官方 schedule 没有缩小 paper section 范围。
- 本指南以论文为 architecture、mechanisms、production measurements 与 design tradeoffs 的主来源；FAQ 用于澄清 stale-data tolerance、leases、mcrouter、regional pools 与 look-aside caching；课堂连接以 Lecture 17 `NOTES.md` 和官方讲义为证据。
- 论文区分 **memcached**（单机软件/进程）与 **memcache**（Facebook 以 memcached 组成的分布式系统）。本文沿用该区分。
- 这是 production experience paper，不是 adversarial-security protocol。论文讨论 consistency、fault tolerance 与 operational safety，但没有把恶意 client/server、authorization、confidentiality 或 cryptographic integrity 作为 threat model；不能从本文推出这些安全保证。
- 论文明确把“读到 transient stale data 的概率”视作可调参数，并选择 best-effort eventual consistency、performance 与 availability。可接受的是通常很短、用户难察觉的 stale；FAQ 明确说无界或长时间 stale 不可接受。
- 所有性能数字都绑定论文的 2013 Facebook workload、hardware、pool 和 measurement window；不能外推成现代 memcached deployment 的固定指标。

资源：

- [Lecture 17 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-17.md)
- [Memcache 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/memcache-fb.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/memcache-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/17-q-memcached.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-memcached.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-17-cache-consistency---memcached-at-facebook)
- [Lecture 17 NOTES](/courses/mit-6824-s21/lectures/018/)
- [Lecture 17 transcript](/assets/courses/mit-6824-s21/lectures/018/transcript.txt)
- [Lecture 17 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=18)

## 2. 问题模型：为什么简单 cache 会变成分布式系统

Facebook workload 有两个直接驱动力：users 消费内容远多于创建内容，且一次页面请求会从 MySQL、HDFS 和 backend services 等多种来源聚合许多对象。单机 memcached 只提供内存 hash table 和 `get`、`set`、`delete`；它没有 server-to-server coordination、persistence 或自动 cache coherence。

Facebook 的基本选择是 **demand-filled look-aside cache**：

```text
read(k):
    v = memcache.get(k)
    if miss:
        v = application reads authoritative backend
        memcache.set(k, v)
    return v

write(k, new_state):
    commit new_state to authoritative database
    memcache.delete(k)
```

三个边界很重要：

1. Database/backend 是 authoritative source；cache entry 可被 eviction，memcache 不是 durable record。
2. Application 控制 miss 后读什么、怎样生成 cached value；cache 不理解 SQL schema 或 derived value。
3. Write 后 **delete** 而不是 update cache。Delete 是 idempotent，也避免多个 client cache updates 乱序后让旧值覆盖新值。

一旦扩展到 hundreds/thousands of servers、多个 frontend clusters 和多个 regions，简单 API 背后出现四类耦合问题：many-to-many network fan-out、cache miss 对 backend 的放大、多个 cache copies 的 invalidation、database replication lag。

## 3. 系统层级与核心不变量

### 3.1 层级

| 层级 | 组成与作用 |
| --- | --- |
| memcached server | 单机 RAM hash table；不与其他 memcached servers 协调 |
| pool | 按 workload/QoS 划分的一组 servers；key 在 pool 内 partition，某些小数据集可复制 |
| frontend cluster | Web servers、memcache pools 与 routing/configuration；把 fan-out 和 failure domain 控制在较小范围 |
| region | 多个 frontend clusters 加一个 storage cluster；同 region 的 DB commit log 驱动 invalidations |
| multi-region deployment | 一个 master region 持有 master databases，其他 regions 有 read-only replicas；MySQL replication 和 delete stream 传播更新 |

### 3.2 Authority invariant

```text
cache value is disposable
    -> durable write commits at backend first
    -> cache miss may always recover from backend
    -> eviction/delete affects load and latency, not durable truth
```

这个 invariant 解释了为什么 ordinary cached value 被删除是安全的：最坏结果是 miss 与额外 backend load。Remote marker 是一个重要例外，因为它不是普通 result cache；marker 丢失会改变读请求应去 local replica 还是 master，因此可能影响 consistency。

### 3.3 Bounded-staleness engineering goal

论文没有给 formal linearizability 或严格时间上界。实际目标是：

- DB transactions 谨慎处理 writes；
- Web reads 可偶尔看到短暂 stale data；
- 避免 stale set、lost/misrouted delete 或 replication lag 把旧值长期留在 cache；
- Writer local path 尽量提供 read-after-write/read-your-own-writes experience；
- 当更强语义代价过高时，以低概率 inconsistency 换 performance/availability。

因此这里的“不变量”是工程 path 上的目标和检查，不是可由论文形式化证明的时间一致性定理。

## 4. 单 cluster：latency、fan-out 与 network control

### 4.1 Client-side distribution

Keys 通过 consistent hashing 分配给 servers；每个 web server 上的 client 知道 server map，负责 serialization、compression、routing、error handling 和 batching。复杂逻辑放在 stateless client/mcrouter，而不是让 memcached servers 相互协调，收益是 server 简单、client 可快速演进；代价是 client correctness 和 configuration distribution 成为系统责任。

论文给出的 popular page 平均读取 `521` 个 distinct items，95th percentile 为 `1,740`；平均 batch 为 `24` keys，95th percentile 为 `95`。Application 用 data-dependency DAG 找出可并行 fetch 的 keys，以较少 round trips 换低 latency，但 all-to-all bursts 会制造 incast。

### 4.2 UDP、TCP 与 mcrouter

- `get` 使用 UDP direct path，避免每个 web thread 对每个 server 保存 TCP connection state。Sequence numbers 检测 dropped、late 或 out-of-order packets；client 把错误当作 miss，但网络/服务疑似 overloaded 时不回填 cache。
- `set`/`delete` 经本机 mcrouter 使用 TCP，因为这些 state-changing operations 需要可靠交付确认。
- mcrouter 合并 TCP connections，并给 application 暴露 memcached interface；这降低 network、CPU 和 memory overhead。
- 论文 Figure 3 中 UDP get latency 比经 mcrouter 的 TCP path 低约 `20%`。这只是在论文环境下的 path comparison，不表示 UDP 普遍优于 TCP。

### 4.3 Incast sliding window

Client 用一个跨 destinations 的 sliding window 限制 outstanding memcache requests：成功 response 后 window 缓慢增长，请求无响应时收缩。

- Window 太小：batch groups 被串行发送，web request duration 增大。
- Window 太大：大量 replies 同时进入 rack/cluster switches，incast、drops 和 backend fallbacks 增加。

Figure 4 用 runnable-but-not-scheduled time 和 Little's Law 解释系统中排队 requests；实验支持的是存在 workload-specific operating point，不是一个通用 window 常数。

## 5. Miss amplification：leases、pools 与 selective replication

### 5.1 Lease 同时解决 stale set 与 thundering herd

Cache miss 时，memcached 可返回与 key 绑定的 64-bit lease token；client 回填时必须带 token。

**Stale-set race：**

```text
C1: get(k) -> miss + lease L1
C1: DB read -> old v1, then pauses
C2: DB write -> v2
invalidation: delete(k), revoke L1
C1: set(k, v1, L1) -> rejected
```

Delete 即使当时没有 cached value，也会撤销 outstanding lease。这样迟到的旧 DB result 不能越过 invalidation 重新进入 cache。

**Thundering herd：** per key 默认每 `10` 秒只发一个 token；同一窗口中的其他 miss clients 收到 retry notification。通常持 lease 的 client 在几 milliseconds 内完成 fill，retry 时已经 hit。论文对一组 herd-prone keys 观察一周：没有 leases 时 peak DB query rate 为 `17K/s`，有 leases 时为 `1.3K/s`。

论文还允许 delete 后短期保留标为 stale 的旧值；能接受 stale snapshot 的 application 可继续前进而不等待 DB refresh。这是显式的 application-level tradeoff，不是对所有 keys 自动安全。

### 5.2 Pools 隔离 interference

不同 key families 的 item size、churn、miss cost 与 access rate 差异很大。一个 shared LRU-like population 会让 high-churn cheap-miss items 驱逐 low-churn expensive-miss items。Facebook 因而保留 default `wildcard` pool，并给问题 workload 单独 provision pools。

Pool partitioning 的目标不是 consistency，而是隔离 memory/QoS interference；代价是 capacity planning 与 placement policy 变复杂。

### 5.3 Pool 内 selective replication

当一个 key family 同时满足以下条件时，论文选择复制而不是进一步 partition：

1. Application 经常一次 fetch 许多该 family 的 keys；
2. 整个 dataset 可装入一两台 servers；
3. Request rate 超过单 server capacity。

若每次请求需要全部 100 keys，把 100 keys 平分到两台 server 后，两台仍各接到每个 logical request；复制完整 dataset 后，每个 logical request 可只去一个 replica，service load 才能分散。代价是 RAM duplication 和必须向所有 replicas 送 invalidations。

## 6. Failure model：Gutter 与 cold-cluster warmup

### 6.1 小规模 failure：Gutter

普通 server/network failure 会把 miss traffic 推向 backend，可能产生 cascading failure。约占 cluster `1%` 的 Gutter machines 在少数 servers 不可达时临时接管：

```text
ordinary get timeout
    -> retry in Gutter pool
    -> on Gutter miss, query DB and insert short-lived entry
```

Gutter entries 快速过期，因此系统不向 Gutter 发送 ordinary invalidations。论文明确说这以 slightly stale data 为代价保护 backend。相比把 failed server 的 keys rehash 到正常 servers，Gutter 使用原本 idle capacity，避免某个 hot key 把新的 ordinary server 一并压垮。

论文报告：Gutter 把 client-visible failures 降低 `99%`；每天把 `10%-25%` failures 转成 hits；完整 server failure 后约 4 分钟内 hit rate 通常超过 `35%`，并常接近 `50%`。这些数据说明 active working set 可迅速在 Gutter 聚集，但不证明 Gutter 拥有正常 cache 的 freshness。

### 6.2 大规模 failure

若整个 cluster 必须 offline，traffic 被转移到其他 clusters；这依赖 cluster-level replication/capacity，而不是 Gutter 承担整组 load。

### 6.3 Cold-cluster warmup

新建、恢复或维护后的 cluster cache 为空；直接让所有 misses 去 DB 会破坏 backend insulation。Cold cluster client 可先从一个 normal-hit-rate warm cluster 取数据，再填入 cold cluster，使恢复从 days 缩到 hours。

但 warm cluster 可能仍有旧值：cold cluster 中的 delete 带默认 `2` 秒 hold-off，在窗口内拒绝 `add`。若 warm-to-cold add 被拒，client 转而读 DB。论文承认 delete 延迟超过两秒仍理论可能，选择该机制是因为 operational benefit 大于 rare inconsistency cost；warm hit rate 稳定后会关闭 warmup。

## 7. Region 内 replication 与 invalidation pipeline

多个 frontend clusters 共享 storage cluster。User demand 让同一 data 在各 cluster 独立缓存；storage cluster 负责在 authoritative transaction commit 后 invalidation。

SQL statements 被附加需要删除的 memcache keys；每个 database 上的 **mcsqueal** 读取 commit log、提取 deletes，并发往每个 frontend cluster 的 dedicated mcrouters，再由 mcrouter route 到正确 server。关键 ordering 是：

```text
database transaction commits
    -> durable commit log contains invalidation metadata
    -> mcsqueal may batch/replay deletes
    -> frontend cache copies are deleted
```

把 invalidation 放入 durable DB log 有两项价值：只对 committed writes 发 delete；misrouting/failure 后可 replay。Dedicated mcrouters batching 让 median deletes per packet 改善 `18x`。论文也指出只有 `4%` deletes 真正找到 cached item；高冗余是避免追踪“哪个 cluster 当前缓存了什么”的代价。

### Regional pool

每个 frontend cluster 各自 demand-fill，热门 data 的多 copies 换来低 latency、cluster maintenance tolerance 和 serving capacity；large/rare items 在每 cluster 重复则浪费 RAM。Regional pool 让多个 clusters 共享一份 cache：

- 收益：每 region 一份而不是每 cluster 一份，节省 memory。
- 代价：cross-cluster latency，论文网络中 cluster boundaries 的平均 available bandwidth 少 `40%`，也失去 replica capacity/fault isolation。

Placement 依据 access rate、dataset size 和 unique users 等 manual heuristics，说明这不是自动 optimal partitioner。

## 8. 跨 regions：replication lag 与 consistency mechanisms

Master region 接受 writes，replica regions 的 MySQL databases 异步追赶。Local DB/cache 让 reads latency 低，但 replica lag 是跨 region consistency 的主问题。

### 8.1 Invalidation 必须跟随 replica stream

若 master-region writer 直接先删除 replica-region cache，而新的 DB state 尚未复制到该 region，下一次 miss 会从旧 replica DB 取值并重新长期缓存。让 replica databases 附近的 mcsqueal 在 replication apply/commit 后广播 deletes，可避免 invalidation 跑到 data 前面。

### 8.2 Non-master write 与 remote marker

Replica-region user 的 write 实际去 master；紧随其后的 local read 可能遇到尚未追上的 replica DB。Remote marker `r_k` 表示 local replica 对 `k` 可能 stale：

```text
set r_k in local regional pool
write master DB, embedding invalidation of k and r_k
delete k in local cluster

later local miss:
    if r_k exists: query master
    else: query local replica
```

Marker 用额外 latency 换较低 stale-read probability。它仍不是严格保证：marker 可能 eviction；concurrent modifications 可能让一个 operation 过早删除另一 operation 仍需要的 marker。论文称这些情况实践中 rare，而不是不可能。

### 8.3 Delete buffering

Database/mcrouter 在 downstream unavailable 时 buffer deletes，恢复后 replay。Failure/delay 增加 stale-read probability；替代方案是下线 cluster 或过度 invalidation，论文认为对其 workload disruption 更大。

## 9. 单机改进与 evaluation

### 9.1 Server throughput 与 memory efficiency

- Fine-grained locking：Figure 7 中 get-hit peak 从约 `600K` 增至 `1.8M items/s`，miss 从 `2.7M` 增至 `4.5M items/s`；实验要求 average response latency 小于 1 ms。
- UDP：单 get peak 比 TCP 高 `13%`，10-key multiget 高 `8%`；10-key multiget 因 packet amortization 约有 4 倍 item throughput。
- Adaptive slab allocator：在 slab classes 间移动 memory，目标是让各 classes oldest item age 更接近 global LRU，而不是只平衡 eviction rate。
- Transient Item Cache：按过期秒数组织 circular buckets，主动清理 short-lived items；一个 workload 的 memory share 从 `6%` 降到 `0.3%`，hit rate 不变。
- Shared memory upgrade：让 cached values/data structures 跨 memcached binary upgrade 保留，避免重新 warm 需要的数小时和 DB load。

### 9.2 Workload measurements

- 56% page requests 接触少于 20 个 servers，但 popular data-intensive page 多数请求访问超过 100 个，且访问数百个并不罕见。
- 七天统计中 request latency median 为 `333 us`，p75 `475 us`，p95 `1.135 ms`；idle web server 的 end-to-end median `178 us`。差异包含 large responses 与 runnable-thread scheduling。
- Pool table 展示不同 workload：replicated pool per-server get rate 最高、miss rate最低；regional pool request rate低而 values 较大。这支持 workload segregation，而非“一个 eviction/replication policy 适合全部 keys”。

### 9.3 Invalidation latency

Figure 11 的 30-day sample 显示 master-co-located delete 在 1 秒内达到 four nines、1 小时后 five nines；non-master source/destination 在 1 秒内约 three nines、10 分钟内 four nines。极低概率的 long delay 仍存在，FAQ 也警告它可能让 application programming 更难。

## 10. 设计权衡总表

| 选择 | 收益 | 代价/失败边界 |
| --- | --- | --- |
| Look-aside cache | Application 可缓存任意 derived value；DB/cache 独立扩展 | Application 承担 refill/invalidation races |
| Delete instead of update | Idempotent；避免 out-of-order sets；适配标准 APIs | 下次 read miss 要重算；lost delete 可长期 stale |
| Stateless client/mcrouter logic | memcached server 简单、部署迭代快 | Client/configuration correctness 更关键 |
| Parallel batching | 降 round trips，提高 throughput | Fan-out/incast 与 tail latency |
| Leases | 抑制 herd，拒绝 stale set | Token state、retry path；stale-value mode 需 application 判断 |
| Separate pools | 隔离 churn、size、miss-cost interference | Provisioning/placement 复杂，capacity 可能碎片化 |
| Replication | Hot-key throughput、低 latency、failure domains | RAM duplication、更多 invalidation targets |
| Regional pool | Rare/large data 每 region 一份 | Cross-cluster bandwidth/latency，较少 serving replicas |
| Gutter | Small failure 时保护 backend，避免 risky rehash | 不接 invalidation，短暂 stale；只覆盖小规模 failure |
| Cold warmup | 新 cluster 不冲击 DB | Warm-to-cold stale-copy race；2 秒 hold-off 非严格证明 |
| Async regions | Local reads、geographic resilience | Replica lag、RYOW complexity、跨区 write latency |
| Remote marker | Replica writer miss 可转向 master | Marker eviction/concurrent-delete race；额外 metadata/latency |

## 11. FAQ 与课堂连接

- FAQ 明确解决表面矛盾：系统既容忍 stale 又投入大量机制避免 stale，是因为“几分之一秒”与“数小时/无界”对用户和 application 的影响完全不同。
- 课堂 NOTES 以三条 race 统一论文：ordinary stale set 用 lease revocation；cold-cluster stale fill 用 delete hold-off；secondary-region read-your-own-writes 用 remote marker。它们都由新增 performance/failure path 引入。
- 课堂把 cache 的第一职责强调为 **保护 DB 和维持系统 throughput**，不只是缩短 latency。这解释了 leases、Gutter 和 warmup 的共同目标。
- 课堂对 Gutter Question 的具体答案明确标为 speculation：论文没有直接解释为何 writing clients 不删除 Gutter keys。完成 homework 时应从论文已给出的 Gutter size、purpose、expiry 和 invalidation policy 推理，并清楚标注假设。
- FAQ 对 mcrouter 的概括强调 TCP connection/packet aggregation；论文还说明 normal client gets 可 direct UDP bypass mcrouter。两者描述不同 path，不矛盾。
- Security boundary：MySQL 提供 transactions/durable writes，但论文不提供 malicious-operator protection。不要把 cache consistency 机制写成 access control 或 Byzantine integrity protocol。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Memcache at Facebook. Section 3.3 implies that a client that writes data does not delete the corresponding key from the Gutter servers, even though the client does try to delete the key from the ordinary Memcached servers (Figure 1). Explain why it would be a bad idea for writing clients to delete keys from Gutter servers.

下面只给推理脚手架，不给可提交答案：

1. 先画 ordinary write path：DB commit、ordinary memcache delete、mcsqueal invalidation；再单独画 server failure 后才启用的 Gutter fallback path。
2. 从 §3.3 摘出四个约束：Gutter 约占 cluster `1%`、接管少数 failed servers、entries 快速过期、目标是避免 backend cascading load。
3. 区分两个问题：删除 Gutter key 对 **freshness** 有什么好处；它对 **Gutter request/delete traffic、working-set reuse 和 backend load** 可能有什么代价。
4. 做一个 order-of-magnitude thought experiment：normal operation 的 write/delete rate 与只有 small-outage traffic 才访问 Gutter 的规模是否匹配。不要虚构论文没给的 exact capacity。
5. 检查“由谁发 invalidation”与“哪些 components 知道 key 在 Gutter 哪台 server”两个 routing 问题，并说明你的假设。
6. 用 quick expiration 解释系统选择的 stale window；再指出这只是 tradeoff，不意味着 stale 永远无害。
7. 最后明确证据等级：论文写明的机制、从机制推得的 consequence、课堂/你自己的 speculation 要分开。

## 13. 理解检查：10 组问答

1. **问：为什么 memcache 不是 authoritative storage？**  
   **答：** Durable writes 去 MySQL/other backends；cache items 可 eviction/delete，并能在 miss 后重建。Memcache 的职责是加速和保护 backend。（来源：论文 §2）

2. **问：为什么 write path 删除 cache，而不直接 set 新 value？**  
   **答：** 多 client updates 可能乱序到达 cache，使旧 value 覆盖新 value；delete 幂等且让下一次 read 从 authoritative backend refill。（来源：论文 §2、课堂 NOTES）

3. **问：Lease 如何同时解决 consistency 与 load？**  
   **答：** Delete 会撤销旧 miss 的 token，拒绝 stale set；per-key token rate 又只允许少数 client 回源，抑制 thundering herd。（来源：论文 §3.2.1、FAQ）

4. **问：为什么进一步 partition 一个小而热门的 multi-key dataset 可能不降 request rate？**  
   **答：** 每个 logical request 仍需访问每个 partition；完整复制后，一个 request 可只选一个 replica，才把 request processing 分摊。（来源：论文 §3.2.3）

5. **问：为什么 failed server 的 keys 不直接 rehash 到正常 servers？**  
   **答：** Key popularity 不均，新的 owner 可能因接到 hot key 而过载并级联失败；Gutter 用预留 idle capacity 隔离风险。（来源：论文 §3.3）

6. **问：Cold-cluster warmup 的 two-second hold-off 提供严格一致性吗？**  
   **答：** 不提供。它拒绝通常窗口内的 stale warm copy，但论文承认 deletes 可能延迟更久；这是 operational benefit 与 rare inconsistency 的选择。（来源：论文 §4.3）

7. **问：为什么跨 region invalidation 不能早于 DB replication apply？**  
   **答：** 过早 delete 会让 cache miss 读取仍旧的 replica DB，再把旧值长期填回 cache；让 replica-side log path 发 delete 可保持 data-before-invalidation 的实际顺序。（来源：论文 §5）

8. **问：Remote marker 与普通 cached result 的删除语义有何不同？**  
   **答：** 普通 result 被删只增加 miss/load；marker 丢失会让 query 错误地去可能 stale 的 local replica，因此可能影响 consistency。（来源：论文 §5）

9. **问：Regional pool 为什么省 RAM，却可能降低 performance/fault tolerance？**  
   **答：** 它把每 cluster 一份变为每 region 一份，但 requests 要跨 cluster boundary，且不再有 N 份 serving capacity/independent copies。（来源：论文 §4.2、FAQ）

10. **问：论文提供的 consistency 保证有多强？**  
    **答：** Best-effort eventual consistency，强调 performance/availability 与低概率短暂 stale；remote-marker eviction、delete delay 等仍可暴露旧数据，不是 linearizability 或严格 bounded staleness。（来源：论文 §5、§7.3、FAQ）
