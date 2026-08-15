---
uid: mit-6824-s21-resource-reading-3
type: course
document_type: resource
resource_kind: reading
resource_order: 103
course: mit-6824-s21
title: Lecture 3 阅读与作业指南：The Google File System
description: Lecture 3 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 3 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-03/"
toc: true
official_lecture_number: 3
---

## 1. 来源、指定范围与证据边界

- 指定论文：**The Google File System**（Ghemawat, Gobioff, and Leung, SOSP 2003）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- FAQ、Paper Question 均有本地归档；本指南不引入未出现在 paper/FAQ 的外部 GFS 事实。
- 课堂 `NOTES.md` 只用于“课堂连接”，尤其是 stale-read 讨论与 lecture emphasis。

资源：

- [GFS 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/gfs.pdf)
- [GFS FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/gfs-faq.txt)
- [官方 Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/03-q-gfs.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/)
- [Lecture 3 NOTES](/courses/mit-6824-s21/lectures/003/)

## 2. 阅读目的

GFS 的重点不是“把传统 file system 放到很多机器上”，而是根据 application workload 重新选择 design point。阅读时始终问：

1. 哪些 workload assumptions 允许 GFS 放松 POSIX-like behavior？
2. Single master 如何保留全局 control，又不进入 bulk data path？
3. Lease、primary、version number 和 operation log 分别解决哪一种 ordering/recovery 问题？
4. Record append 的 at-least-once semantics 为什么可被目标 application 接受，又要求 application library 做什么？
5. 论文 evaluation 是否验证了目标 workload，而不是证明它适合所有 storage workloads？

## 3. 问题、模型与假设

### 3.1 Workload assumptions

论文明确采用以下假设：

- 系统由大量 inexpensive commodity components 构成，failure 是常态；
- 文件数量相对 modest，但 files 通常很大，`100 MB` 以上常见，multi-GB 是 common case；
- 主要 read pattern 是 large streaming reads 和 small random reads；
- write 主要是 large sequential append，random overwrite 很少；
- 多 clients concurrent append 需要 efficient、well-defined semantics；
- high sustained bandwidth 比 low latency 更重要。

### 3.2 Interface boundary

GFS 提供 familiar hierarchical namespace，但不是 standard POSIX API。除 create/delete/open/close/read/write 外，还提供 `snapshot` 和 `record append`。它主要服务为 GFS 新写的 applications，而不是无修改迁移 existing POSIX applications。

### 3.3 Failure model

论文考虑 machine、disk、network、OS、application 与 human errors 所造成的 component failure 和 data corruption。系统通过 monitoring、replication、checksums、fast recovery 和 re-replication 应对；它不承诺所有 replicas 永远 bytewise identical。

## 4. Architecture 与核心机制

### 4.1 Components 与路径分离

```text
metadata/control:
client -> single master -> chunk handle + replica locations

data:
client <-> chunkservers
```

- **Master**：namespace、access control、file-to-chunk mapping、chunk locations；还管理 lease、garbage collection、migration 和 re-replication。
- **Chunkserver**：把 chunk 作为 local Linux file 保存，并按 handle/byte range 读写。
- **Client library**：向 master 取 metadata，缓存后直接访问 chunkserver。
- **Chunk**：固定 `64 MB`，由 immutable、globally unique 64-bit handle 标识；默认三份 replicas。

Data 不经过 master，因此 single master 可以集中做 placement/control，而不直接限制 aggregate data throughput。

### 4.2 Master metadata 与 recovery

- Namespace 与 file-to-chunk mapping 通过 operation log 持久化并复制到 remote machines。
- Log 同时提供 logical timeline；metadata mutation 在 log local/remote flush 后才对 client 可见。
- Checkpoint 缩短 recovery，只需加载最新 complete checkpoint 并 replay 后续 log。
- Chunk locations 不持久化；master startup 时询问 chunkservers，因为 chunkserver 对自己实际拥有哪些 chunks 有最终事实。
- Metadata 全在 memory 中，支持快速 lookup 与 background scans。

### 4.3 Read path

1. Client 用 fixed chunk size 把 filename/offset 转成 chunk index。
2. Master 返回 chunk handle 与 replica locations。
3. Client cache metadata，并向较近 replica 直接读取 byte range。
4. 同一 chunk 的后续 reads 在 cache expiry/file reopen 前无需再联系 master。

### 4.4 Mutation、lease 与 ordering

- Master 给某个 replica 授予 chunk lease，该 replica 成为 **primary**。
- Primary 为收到的 mutations 分配 serial order；secondaries 按相同 order 应用。
- Client 先把 data push 到所有 replicas，再向 primary 发送 mutation command。
- Data flow 与 control/order 分离：data 沿按 topology 选择的 chain pipeline；control 从 client 到 primary 再到 secondaries。
- Lease 初始 timeout 为 `60 seconds`；只要 chunk 持续 mutation，primary 可通过 HeartBeat piggyback 请求 extension。

### 4.5 Record append

Client 不指定 offset；primary 选择位置。成功时，一条 record 至少一次作为连续 bytes 写入某处，并返回 offset。若当前 chunk 放不下 record，primary padding 后要求 client 在 next chunk retry。Record append 最大为 chunk size 的四分之一，以限制 worst-case fragmentation。

Failure 后 client retry 可能制造 padding、record fragments 或 duplicate whole records，因此不是 exactly-once append。

### 4.6 Snapshot 与 background management

- Snapshot 使用 copy-on-write：先 revoke/等待相关 leases，再复制 metadata；第一次后续 write 时才复制共享 chunk。
- Replica placement 跨 machines 与 racks，兼顾 reliability、availability 与 network bandwidth。
- Master 按 under-replication urgency、live-file status 和 client blocking 排 re-replication priority。
- Lazy garbage collection 延迟 physical deletion，简化 lost messages/failure handling，并提供 accidental deletion 的 safety net。

## 5. Correctness、failure 与 consistency 推理

### 5.1 Region states

论文区分：

- **consistent**：所有 clients 无论读哪个 replica 都看到相同 data；
- **defined**：region consistent，且内容是某次 mutation 完整写入的内容；
- **inconsistent**：不同 replicas/reads 可能看到不同 data。

Successful mutation without concurrent writers 产生 defined region。Concurrent successful writes 可产生 consistent but undefined region。Failed mutation 可留下 inconsistent region。

### 5.2 Namespace 与 data mutation 的不同保证

- Namespace mutations 由 master exclusive handling、namespace locks 和 operation log global order 保证 atomic。
- Data mutations 依赖 lease primary 统一排序，并由 version number 排除 missed mutations 的 stale replica。
- Client cache 仍可能在刷新前联系 stale replica，因此 versioning 降低而不是绝对消除 stale read window。

### 5.3 Record append 的 application contract

Record append 提供 append-at-least-once，而不是 exactly once：

- Application record 放 checksum/magic 以识别 valid record 与 padding/fragments；
- 用 unique record ID 识别 duplicate；
- 对 duplicate sensitive 的 operation，reader/library 做 filtering。

FAQ 特别提醒：checksum 用于检测 corruption/validity，unique ID 用于 duplicate detection，两者职责不同。

### 5.4 Split brain 与 stale replicas

- Master 不会在旧 primary lease 过期前给另一 replica 新 lease；旧 primary 知道 lease 到期后停止 primary 行为，从而避免同一 chunk 的两个有效 primary。
- 每次授予新 lease，master 增加 chunk version；down replica 若错过更新，回来时因旧 version 被识别并排除。
- Client 已缓存旧 locations 时，可能在 cache timeout/file reopen 前访问 stale replica；这正是官方 homework 要求分析的空间。

### 5.5 Data integrity

Chunkserver 为每个 `64 KB` block 维护 `32-bit checksum`。Read 前验证；mismatch 时返回 error、报告 master，由其他 replica 提供 data 并触发 replacement。Replica 可能合法不一致，因此不能简单跨 replicas byte-for-byte 比较来检测 corruption。

## 6. Performance 与 evaluation

只使用论文归档中的历史 setup 和数字：

### 6.1 Micro-benchmark setup

- `1` master、`2` master replicas、`16` chunkservers、`16` clients；
- machines 使用 `100 Mbps` links，两组 switches 之间 `1 Gbps` link；
- 该 setup 为测试方便，不代表 typical production cluster。

### 6.2 Results

- `16` readers 的 aggregate read rate 为 `94 MB/s`，约为 `125 MB/s` link limit 的 `75%`。
- `16` clients 写不同 files 时 aggregate write rate 为 `35 MB/s`，约为 theoretical limit 的一半。
- 多 clients append 同一 file 时，由最后一个 chunk 的 replica network 限制；从单 client `6.0 MB/s` 降到 `16` clients 的 `4.8 MB/s`。
- Real cluster A 曾持续约一周保持约 `580 MB/s` read rate；论文同时提醒 workload 与 GFS 互相 tuned，不应过度 generalize。
- Single master 在所测 real workloads 中约接收 `200-500 operations/s`，不是当时 bottleneck。
- 一次单 chunkserver failure 后，约 `600 GB`、`15,000` chunks 在 `23.2 minutes` 内恢复；另一次 double failure 中，`266` 个只剩一份 replica 的 chunks 在 `2 minutes` 内至少恢复到两份。

评价时要注意：GFS 追求的是 many clients 的 aggregate throughput；single-client write latency/throughput 并非主要优化目标。

## 7. 设计权衡与限制

| 选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| Single master | 简化 placement、namespace 与 lease decisions | scalability/failover pressure；原论文 master cut-over 需 human intervention |
| `64 MB` chunks | 减少 metadata 与 master interaction，利于 large sequential I/O | small file hot spot；小文件并行度低 |
| No client data cache | 避免 cache coherence complexity | 不利用重复 small-read cache；依赖 Linux buffer cache at chunkserver |
| Relaxed consistency | 简化并提高 append-oriented workload 性能 | holes、duplicates、stale/inconsistent reads 需 application compensation |
| Record append | 多 producers 无需外部分布式 lock | at-least-once、GFS-chosen offset、padding/duplicates |
| Lazy deletion | simple/reliable cleanup，支持 undelete | storage tight 时空间不能立即复用 |
| Replication across racks | rack failure survival 与 read bandwidth | write traffic 跨 racks |

FAQ 的适用性结论很明确：GFS 可为 MapReduce large-file workload 提供“足够”的 consistency，但不适合存 bank account balances。

## 8. 官方 Paper Question / Homework

**Assigned Question（原文）**：

> Describe a sequence of events that would result in a client reading stale data from the Google File System .

### 推理脚手架（不是可直接提交的成稿）

1. 选定一个 chunk，并列出四种角色：master、old client、一个后来被 active group 排除的 replica、完成新 write 的 client/replicas。
2. 先让 old client cache 一组 `{chunk handle, replica locations, version}`；明确 cache 是题目成立的必要条件。
3. 引入 asymmetric connectivity：master/active group 不能联系某 replica，但 old client 仍能联系它。
4. 让 master 建立新的 primary epoch，并让 active replicas 完成一个更新；跟踪新旧 version。
5. 最后检查 old client 发出的 version 与 stale replica 自己的 version 是否仍相等，以及为什么这次 read 没有重新经过 master。
6. 自己写出严格时间顺序，并指出哪一步若删除，stale read 将不能发生。

课堂讨论给出了这一构造的方向，但请用自己的事件表、角色图和因果解释作答，不要把本节改写成一段无推理的结论。

## 9. FAQ 要点

- Record append 是 at-least-once，因为某个 secondary failure 后 retry 会让 non-failed replicas 再 append；exactly-once duplicate suppression 会增加 complexity/performance cost。
- Padding/valid records 可用 magic/checksum 区分；duplicates 用 unique IDs 识别；GFS 提供 application library 处理这些 cases。
- Record append offset 不可预测，但目标 applications 通常 sequentially scan whole files，不需提前知道每条 record 的位置。
- Snapshot reference counts 支持 copy-on-write，延迟真正复制 chunk。
- Existing POSIX applications 需要修改；GFS 为新写的 applications 设计。
- `64 MB` 是 metadata/sharding granularity，client 可做更小 reads/writes；大 chunk 减 metadata，却使小文件并行度有限。
- Lease 阻止 old primary 与 new primary 同时有效：master 等旧 lease expiry，旧 primary 到期停止。
- Master failure 有 full-state replicas，但论文方案由 human intervention 切换；后续课程用 Raft 学自动 cut-over。
- Strong consistency 通常需要更多 coordination；GFS 利用目标 application 对 relaxed consistency 的容忍换性能与简单性。
- Single master 后来面临 metadata、CPU 与 manual recovery 限制；FAQ 把 Colossus 描述为分割 master 并加强自动恢复的后继方向。
- FAQ 对“为何三副本”的可靠性计算使用了 `I imagine`，不应把其未给出的公式当作 paper fact。

## 10. 课堂讨论如何连接并改变重心

[Lecture 3 NOTES](/courses/mit-6824-s21/lectures/003/) 把论文机制重新组织成一条推理链：

```text
aggregate throughput -> sharding -> frequent failures -> replication
-> replica coordination -> primary/version/lease
-> client cache and direct reads -> stale-read window
```

课堂特别改变了三个阅读重点：

- 不把 architecture diagram 当静态组件图，而是反复区分 control path、data path 和 durable/reconstructed master state。
- 不只背 `record append` steps，而是从 partial success + retry 推导 duplicate，再区分 record ID 与 checksum。
- Homework 被课堂具体化为 cached old metadata + asymmetric reachability + new epoch 的事件序列；version check 不是无条件 stale-read barrier。

课堂还明确把某些 reconfiguration 细节标成老师的推测。阅读论文时也应保持这种证据强度，不把合理猜测写成已证实 protocol。

## 11. 论文理解题（10 题）

1. **GFS 的五类核心 workload assumptions 是什么？**  答案点：commodity failures、large files、streaming/small random reads、append-dominated writes、concurrent append、bandwidth over latency。
2. **为什么 master 不在 file data path？**  答案点：避免 single master 限制 aggregate throughput；只提供 metadata/control。
3. **哪些 master metadata 持久化，哪些从 chunkservers 重建？**  答案点：namespace/mapping/logical version 持久化；locations 重建。
4. **`64 MB` chunk 的主要收益和风险各是什么？**  答案点：少 metadata/少 master interaction/长连接；small-file hot spots 与低并行度。
5. **Lease primary 与 client data pipeline 分别解决什么？**  答案点：mutation ordering；network-efficient data distribution。
6. **`consistent` 与 `defined` region 有何差别？**  答案点：前者 replicas 所见相同；后者还完整对应某 mutation。
7. **为什么 record append 可以 duplicate 但仍称 atomic？**  答案点：至少一次有一个完整连续 record；retry 可在其他位置再出现。
8. **Chunk version number 如何识别 stale replica？**  答案点：新 lease 前 bump/persist；错过 bump 的 replica 回来时版本落后并被排除。
9. **为什么 checksums 不能靠比较 replicas 替代？**  答案点：legal divergent replicas；每份 copy 必须独立检测 disk corruption。
10. **Paper evaluation 证明了什么、没证明什么？**  答案点：目标历史 workload 的 aggregate throughput/recovery；不证明适合 low-latency、small-file 或 arbitrary applications。

## 12. 复习清单

- [ ] 能列出 workload assumptions，并用它们解释非 POSIX design。
- [ ] 能画出 client、master、chunkservers 的 control/data paths。
- [ ] 能区分 master durable metadata 与 reconstructed locations。
- [ ] 能逐步复述 read、write、record append 和 snapshot。
- [ ] 能解释 primary、lease、serial order、version number 的不同职责。
- [ ] 能区分 consistent、defined、undefined、inconsistent region。
- [ ] 能从 partial append + retry 推导 duplicate record。
- [ ] 能分别说明 unique ID 与 checksum 的用途。
- [ ] 能在不写成模板答案的情况下构造 stale-read event sequence。
- [ ] 能复述 evaluation 数字并注明 historical/workload boundary。
- [ ] 能说明 single master、small files、manual master recovery 和 relaxed consistency 的限制。
