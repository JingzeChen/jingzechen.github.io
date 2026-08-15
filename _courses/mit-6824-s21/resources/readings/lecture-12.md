---
uid: mit-6824-s21-resource-reading-12
type: course
document_type: resource
resource_kind: reading
resource_order: 112
course: mit-6824-s21
title: Lecture 12 阅读指南：Frangipani
description: Lecture 12 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 12 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-12/"
toc: true
official_lecture_number: 12
math: true
---

## 1. 来源、指定范围与证据边界

- 指定论文：**Frangipani: A Scalable Distributed File System**（Thekkath, Mann, Lee，SOSP 1997）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- 本讲另有官方 FAQ 与 Paper Question。
- 课堂 NOTES 只用于“课堂连接”；paper 的 disk layout、logging details、backup 与完整 performance results 不反向写成课堂逐项讲过。
- FAQ 中的 “guess/probably” 与对后续 state of the art 的讨论不能升级成论文机制；不从 Petal 外部论文或现代 distributed file systems 补事实。

资源：

- [Lecture 12 reading input](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-12.md)
- [Frangipani 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/thekkath-frangipani.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/frangipani-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/12-q-frangipani.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-12-cache-consistency---frangipani)
- [Lecture 12 NOTES](/courses/mit-6824-s21/lectures/012/)
- [Lecture 12 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=12)

## 2. 阅读任务与章节地图

1. **§1–§2：** 从目标 workload、trust domain 与 Petal abstraction 推导 two-layer architecture。
2. **§3：** 64-bit sparse virtual disk 如何简化 layout，又带来哪些固定粒度与容量选择？
3. **§4：** Per-server redo logs、write-ahead order、version numbers 与 recovery 如何协作？
4. **§5–§6：** Lock service 如何同时提供 cache coherence 与 file-system operation atomicity？
5. **§7：** Server failure、lease、recovery daemon 与 late write 有什么边界？
6. **§8：** Petal snapshot 如何支持 consistent online backup？
7. **§9：** Evaluation 分别测了 single-server、scaling、small-file 与 large-file 的什么性质？
8. **§10–§11：** Related work 与 conclusion 如何界定 Frangipani 的适用环境？

阅读时维护这条因果链：

```text
workstation-side write-back cache
  -> coherence problem
  -> distributed locks and lock transfer
  -> multi-block operation atomicity
  -> write-ahead log
  -> crashed lock holder recovery
  -> stale-log replay problem
  -> per-block version check
```

## 3. 问题、架构与信任模型

### 3.1 目标

Frangipani 希望把多机多盘表现为一个 coherent shared file system，并随着 servers 增加提升 capacity 与 throughput，同时支持 component failure、online consistent backup 和较低 administration cost。

### 3.2 Two-layer architecture

```text
ordinary applications / Unix system calls
                  |
multiple interchangeable Frangipani servers
file-system logic + local buffer cache + private redo log
                  |
       distributed lock service
                  |
Petal distributed virtual disk (shared block interface)
                  |
             physical disks
```

- **Petal：** 提供 large、sparse、incrementally scalable、highly available virtual disk；上层只看到 block device。
- **Frangipani：** 在多个 machines 上运行同一 file-system code，解释 directories/inodes/permissions，并缓存 data 与 metadata。
- **Lock service：** 提供 multiple-reader/single-writer locks，协调共享 disk 与各 server caches。

Frangipani servers 不需彼此直接通信，只需与 Petal 和 lock service 交互；每个 server 的 log 放在 Petal 的独立区域，使另一 server 能替 crashed server recovery。

### 3.3 Trust boundary

任何 Frangipani server 都能读写 shared virtual disk blocks，因此它们、Petal servers 与 lock servers 必须受信任，并位于共同 administrative/security domain。论文另画出 client/server configuration：untrusted remote clients 通过 NFS/DFS/SMB 等协议访问 trusted Frangipani servers，而不能直接接触 Petal。

这不是次要部署细节。把 file-system logic 下放到 workstation 获得 scaling/local caching，也扩大了 trusted computing base。

### 3.4 Workload model

目标是 program development/engineering workload：大多数访问由某 workstation 反复操作用户自己的 files，偶尔跨 machines 共享。因此设计优化 uncontended sticky lock + local cache，而不是持续 multi-writer sharing。

## 4. Disk Layout 与共享状态

Petal 暴露 $2^{64}$ byte sparse address space，物理空间按需分配。Frangipani 把它划为：

1. configuration/housekeeping；
2. 每 server 一个 private log 的区域；
3. allocation bitmaps；
4. fixed-size inodes；
5. small data blocks；
6. large data blocks。

论文当前参数包括：

- `256` 个 log slots；
- inode 为 `512 bytes`，避免不同 inode 共处一 block 的 false sharing；
- small block 为 `4 KB`；
- file 前 `64 KB` 使用 small blocks，其余放入 large block；
- 每个 large block 预留 `1 TB` virtual address range。

这些选择利用 sparse address space 换简单 mapping，但带来内部/外部 fragmentation、固定 server count 与 file-size limits。论文明确把它们视为可调 implementation choices，而非普遍 file-system constants。

## 5. Cache Coherence Mechanism

### 5.1 Lock ownership invariant

简化成 exclusive lock 时，规则是：

```text
server may cache file-system object only while holding its lock
old owner must flush dirty state before releasing the lock
new owner may read Petal only after the lock is granted
```

实际系统还有 shared read locks，使多个 servers 可同时 cache read-only state。

Lock 以 file/directory 对应的 inode/object 命名，lock service 不需要理解 file-system structure。

### 5.2 Busy、idle 与 sticky lock

- `busy`：本地 operation 正在使用 object；
- `idle`：本地暂时不用，但仍持有 lock 和 valid cache；
- external `release`：收到 revoke 后，flush 并把 ownership 交回 lock service。

`busy -> idle` 不是归还 lock。Sticky idle lock 让 uncontended repeated operations 无 RPC、无 Petal read。

### 5.3 Lock transfer timeline

```text
WS1 request(f) -> lock service grants
WS1 reads Petal and modifies local cache
WS2 request(f)
lock service revokes WS1
WS1 finishes current operation
WS1 forces log and flushes dirty blocks to Petal
WS1 releases lock
lock service grants WS2
WS2 reads current state from Petal
```

Coherence 依赖 flush-before-release 和 grant-after-release。若 WS1/WS2 频繁交替写同一 object，lock、cache 与 dirty data 会不断 bounce，性能很差。

## 6. Atomic File-System Operations

`create(d/f)`、delete、rename 等 system call 会修改多个 metadata objects，例如：

- allocate/initialize new inode；
- 修改 directory block；
- 修改 allocation bitmap；
- 更新其他 inode/metadata。

Frangipani 在 operation 开始前取得全部相关 locks，完成所有 local modifications 后才允许 pending revoke 生效。Locks 因而有两项职责：

1. **Coherence：** handoff 时 reveal dirty writes；
2. **Atomicity：** operation 期间 conceal partial updates。

Multiple-lock operations 按固定全局顺序 acquisition，避免 circular wait。课堂对具体是否按 inode number 使用保留语气；本指南只采用论文的 fixed-order requirement。

Locks 在无 crash 时阻止并发者看到 partial operation，但不能自己修复已写一半后 crash 的 metadata，因此还需要 WAL。

## 7. Logging、Recovery 与 Invariants

### 7.1 Per-server redo logs

每个 Frangipani server 有自己的 private log，存放在 shared Petal。Log 记录 metadata changes，不记录 ordinary file contents。

一条 log record 描述一个 atomic file-system operation，包含对多个 metadata blocks 的 redo updates。每项 update 包含目标 block、new bytes 和 version information。Sequence/checksum 用于识别连续完整 records；论文对 record atomicity implementation 的部分描述有限，不能把课堂介绍的 generic commit-record alternative 当成确定实现。

### 7.2 Write-ahead order

核心 invariant：

$$
durable(log(op))
\prec
install(metadata(op))
\prec
release(locks(op)).
$$

- Log-first：若 home-block install 中途 crash，recovery 可 redo 完整 operation。
- Install-before-release：下一 owner 获 lock 前，Petal 已包含前一 owner 的 metadata changes。

Server 可在持有 sticky locks 时积累多个 records，revoke 或其他 force point 到来后才把 log 与 dirty blocks送 Petal。这让 log 吸收多次对同一 metadata block 的更新，但也意味着 crash 可丢失 recent unforced operation suffix。

### 7.3 Metadata 与 user-data 边界

Frangipani log 只保护 file-system metadata。User file contents 不入 log，否则大 data 会先写 log、再写 home blocks，接近双倍 write traffic。

因此 crash 后：

- metadata structures 可恢复一致；
- recent file-content writes 可能 none/some/all 落盘；
- application 需要 durability 时使用 `fsync`/`sync`；
- application 需要 whole-file atomic replace 时可写 temporary file 再 atomic rename。

### 7.4 Crash recovery ordering

```text
lock owner unreachable
  -> lock service waits for its lease to expire
  -> surviving server runs recovery daemon
  -> read crashed server's log from Petal
  -> accept complete record prefix
  -> replay only still-newer metadata updates
  -> report recovery complete
  -> lock service may reassign locks
```

等待 lease expiry 是为了处理 partition：旧 owner 可能联系不到 lock service，却仍能访问 Petal。Recovery/reassignment 不能与仍被授权的 old owner writes 并发。

### 7.5 Complete-prefix invariant

若 crash during log force，Petal 可保存：

$$
r_1,r_2,\ldots,r_k,\operatorname{torn}(r_{k+1}).
$$

Recovery 只接纳 checksum/format 完整的 $r_1\ldots r_k$，在第一条 incomplete record 前停止。丢 suffix 是 durability loss，但不会执行半条 metadata operation。

### 7.6 Version-number replay rule

Per-server logs 使同一 metadata object 的 successive updates 分散在不同 logs。若 WS1 的旧 delete 已被 WS2 的 later create 超越，再 replay WS1 log 不能撤销新 state。

对 log update $u$ 与目标 metadata block：

$$
replay(u)
\iff
v_{log}(u)>v_{Petal}(block).
$$

- `<`：Petal 已有 newer update，旧 record stale；
- `=`：该 update 已安装，无需重复；
- `>`：record 描述的 update 尚未安装，应 redo。

Locks 让 conflicting metadata updates 有 order，versions 把该 order 编码进 Petal blocks/log items，recovery 据此跳过 completed/stale work。

## 8. Failure Boundary 与一致性

### 8.1 正常语义

Programs 看到近似 local Unix file system 的 coherent shared view：一台 server 的 changes 对其他 servers 立即可见；file content 先经过 local buffer cache，`fsync`/`sync` 定义 nonvolatile boundary；metadata 可配置为 system call 返回时 nonvolatile。

### 8.2 Partition 与 lease

Lease 到期后，遵守协议的 old owner 不再使用 lock。但 paper/课堂指出 late old write 仍是困难边界：已经发往 Petal、却延迟超过 lease margin 的 write，可能在 new owner write 之后到达并覆盖新 bytes。理想下层 support 是让 Petal 根据 timestamp/freshness 拒绝 stale write；归档材料没有给出完整 protocol/proof。

因此不要把 lease 写成绝对 fencing 所有 in-flight storage requests。

### 8.3 Security failure

恶意/被修改的 Frangipani workstation 可绕过 locks 与 permissions 直接写 Petal blocks。System correctness 建立在 trusted servers/software 上，不处理 Byzantine client。

### 8.4 Independent layer tradeoff

Petal/Frangipani layering 让实现简单、block layer 可复用，但也产生：

- 两层都可能 logging；
- Petal virtualizes placement，Frangipani无法利用 physical location；
- 跨层 lease/freshness 信息不足；
- file/inode 粒度 lock 可能引起 coarse contention。

## 9. Backup、扩缩容与管理

Petal snapshot 使用 virtual-to-physical mapping/epoch 实现 copy-on-write 式快照。Frangipani 可在系统运行时建立整个 file system 的 consistent backup，并让 snapshots 保持 online 以恢复误删文件。

Servers 共享同一 Petal disk、使用独立 logs 与 lock service，因此添加/删除 Frangipani server 不需要重新分配每个文件的 ownership；lock/cache ownership 按访问移动。Petal 与 lock service 自身也以 distributed implementation 提供 capacity/fault tolerance。

这一简洁性依赖 common shared storage 与 trust domain，不是所有 distributed file-system architecture 都能采用。

## 10. Evaluation 与证据边界

### 10.1 测量目标

论文实现运行在 DIGITAL Unix 4.0/Alpha machines。Evaluation 主要问：

- 单 server 是否能接近已有 local/network file-system performance；
- 增加 Frangipani workstations 时，每个 client completion time 是否保持稳定；
- 多 clients 的 aggregate read/write 是否扩展到 Petal/network limits；
- logging、cache coherence 与 Petal replication 的成本如何显现。

### 10.2 Archived results

- Small-file benchmark 中，各 workstations 使用不同 files/directories；Figure 5 的 per-workstation completion time 随 active workstations 增加大致保持平坦，支持“新增 client 同时带来 file-system CPU”的 scaling claim。
- Large-file setup 的 Petal raw disk bandwidth 由多 disks 提供，但 Petal observed aggregate 约 `100 MB/s`；论文/讲义给出的 single Frangipani workstation Table 3 数量级为 write `15 MB/s`、read `10 MB/s`，write 接近 network-link limit，read 受 prefetch 等因素影响。
- Multiple-workstation large-file reads 随 machines 增加而扩展；writes 最终触及 Petal hardware/replication limit，复制意味着写路径要承担额外 work。
- 论文把绝对数值限定在 1997 hardware 和 engineering workload；今天阅读重点是 scaling shape 与 bottleneck attribution。

### 10.3 不能推出的结论

- Different-file workload scaling 不证明 hot shared file 的 multi-writer performance；后者会 cache bounce。
- Aggregate throughput 上升不证明每个 operation latency 都下降。
- Metadata recovery 不证明 user file contents atomic/durable。
- Trusted cluster benchmark 不证明 untrusted workstation 安全。
- Petal/network saturation 表明系统到达下层 limit，不表示 Frangipani 的所有 overhead 为零。

## 11. 设计权衡

| 设计选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| File-system logic 在 workstations | 新 client 同时增加 CPU；local-cache fast path | Workstations 必须可信；client code 复杂 |
| Shared Petal virtual disk | Server addition/recovery 简单；统一 data access | Placement 信息被隐藏；跨层 fencing 困难 |
| Sticky inode/file locks | Uncontended repeated access 无 RPC | Shared write 会 revoke/flush/grant bouncing |
| Locks 同时做 coherence/atomicity | 一套 mechanism reveal writes、conceal partial ops | Multi-lock ordering 与 crash recovery 更复杂 |
| Per-server shared logs | 无中央 log bottleneck；任意 survivor 可 recovery | Same-object history 分散，需要 versions |
| Metadata-only redo | 保护全局 structure，避免大 data 双写 | File content recent writes 可部分丢失 |
| Per-block versions | Stale/already-installed replay 可跳过 | 依赖 locks 对 conflicting updates 排序 |
| Coarse file/directory locks | Lock count/metadata较少、符合 workload | Block-level parallel writers 不能并发 |
| Online Petal snapshots | 不停机 consistent backup | 依赖 lower-layer mapping/epoch machinery |

## 12. 官方 FAQ 精要

1. **为什么读这篇论文？** 主要看 cache coherence，也看 per-client shared logs、distributed recovery 与 decentralized smart participants。
2. **与 GFS 最大差异？** Frangipani 把 file-system logic/cache 放到 clients/workstations；GFS 的逻辑主要在 servers，且不使用同类 data cache coherence。
3. **为什么 Petal 是 block interface？** Petal 已解决 storage scaling/fault tolerance并允许上层自行构建 file semantics；代价是 file-system invariants 没有单一 server 负责。
4. **Workstation 能破坏 security 吗？** 能；它可直接读写 Petal，故必须 trusted，或改用 trusted Frangipani servers 对外提供 NFS 等协议。
5. **为什么较大 log 可能改善 create benchmark？** FAQ 推测可吸收多次对同一 directory block 的修改，减少反复 home write；这是 FAQ guess，不是论文已证实机制。
6. **为什么不 recovery user contents？** 与 ordinary Unix 类似；file system保护自己的 metadata invariants，应用用 `fsync` 选择更强 durability。
7. **Frangipani log 与 Petal log 有何区别？** 前者记录 file-system metadata operations；后者是 lower-layer block/mapping/replication machinery。FAQ 对 Petal log 细节使用推测语气。
8. **False sharing 是什么？** Unrelated items 共处一个 block，两个 servers 即使修改不同 items 也必须争同一 block/lock/cache unit。
9. **为什么旧 log 不撤销 newer state？** Metadata block 与 log update 都有 versions；record version `<=` current version 时跳过。
10. **为什么不对每个 file block 单独加锁？** FAQ 认为额外 lock acquisitions 成本高，而目标 workload 很少从不同 workstations 并发修改同一 file 的不同 blocks。

## 13. 官方 Paper Question

**Assigned Question（原文）**：

> Frangipani: A Scalable Distributed File System: Suppose a server modifies an i-node, appends the modification to its log, then another server modifies the same i-node, and then the first server crashes. The recovery system will see the i-node modification in the crashed server's log, but should not apply that log entry to the i-node, because that would un-do the second server's change. How does Frangipani avoid or cope with this situation?

### 推理脚手架（不是可直接提交的答案）

1. 为同一 inode/metadata block 画三个 actors：`S1` old update、`S2` later update、`R` recovery。
2. 说明为什么 `S2` 能在 `S1` 之后修改该 inode：需要先经过 lock handoff，而不是无序并发写。
3. 给 Petal metadata block 标一个 current version，给 S1/S2 的 log item 分别标 target version。
4. 写出 S1 update 已安装/未安装两种 crash point；不要假设“log 中有记录”就表示 home block 未写。
5. 让 S2 完成 later modification，并说明 current Petal version 应如何变化。
6. Recovery 读取 S1 log 时比较哪两个版本？列出 `<`、`=`、`>` 三种结果各代表什么。
7. 检查 old record 被跳过后，是否仍需扫描/合并 S2 log；解释 per-block current version提供了什么 evidence。
8. 最后指出该机制依赖 locks 已序列化 conflicting metadata writers；仅有 local log sequence number 不足以比较不同 servers 的 updates。

## 14. 课堂连接

[Lecture 12 NOTES](/courses/mit-6824-s21/lectures/012/) 把论文重排为三类挑战：

```text
write-back cache -> coherence
multi-block system call -> atomicity
crash during install -> recovery
```

课堂用完整 lock-transfer timeline 解释 coherence，再说明同一把 lock 如何 conceal partial operation，最后以 WAL、lease、recovery daemon 与 version comparison回答官方 Question。它特别强调：

- local `busy -> idle` 不等于向 lock service release；
- metadata consistency 与 user-data durability不同；
- lease expiry 不能自动 fence 所有超长延迟的 old writes；
- `01:06:17–01:12:22` 是 breakout gap，不是缺失机制。

论文独有的 disk-layout 参数、backup、完整 performance figures 与 related-work comparison 应继续留在本阅读指南。

## 15. 论文理解题（10 题）

1. **为什么 Frangipani/Petal 两层结构容易扩展 file-system CPU？**  
   答案点：每个新增 Frangipani server 运行 file-system logic/cache，共享 Petal 提供 blocks。
2. **为什么该架构要求 trusted servers？**  
   答案点：任何 Frangipani server 可直接读写共享 Petal blocks，能绕过上层 permissions/locks。
3. **Sticky idle lock 与真正 release 有何差异？**  
   答案点：idle 仍持 ownership/cache validity；revoke path flush 后才交回 lock service。
4. **Lock 如何同时实现 coherence 与 atomicity？**  
   答案点：handoff 前 reveal dirty writes；operation 期间 conceal multi-block partial updates。
5. **为什么 WAL 必须在 metadata install 前 durable？**  
   答案点：partial home writes 后可从完整 redo record 补齐 operation。
6. **为什么只 recovery complete log prefix 是安全的？**  
   答案点：每条 accepted record 是完整 atomic operation；lost suffix 是 durability loss而非 partial metadata corruption。
7. **为什么 user file contents 不进 log？**  
   答案点：避免大 data 近似双写；应用用 fsync/atomic rename选择更强保证。
8. **Per-block version 为什么比 per-log sequence 更适合 stale replay check？**  
   答案点：same-object updates 分散于不同 server logs；Petal current block version可比较是否已有 newer install。
9. **为什么 lease expiry 前不能 recovery/reassign？**  
   答案点：old owner 可能只与 lock service partition、仍能访问 Petal，立即重分配会有两个 writers。
10. **Figure 5 类 scaling 结果没有覆盖什么 workload？**  
    答案点：不同 files/directories 的 low-contention workload；不能推出 hot shared multi-writer file 性能。

## 16. 复习清单

- [ ] 能画出 Frangipani server、Petal、lock service 与 per-server shared logs。
- [ ] 能从 trust/workload model 推导 workstation caching 的收益与限制。
- [ ] 能逐事件复述 request/grant/revoke/flush/release/grant。
- [ ] 能区分 busy、idle sticky lock 与 external release。
- [ ] 能说明 locks 的 coherence 与 atomicity双重职责。
- [ ] 能写出 log-before-install-before-release invariant。
- [ ] 能区分 metadata recovery 与 user-data durability。
- [ ] 能复述 lease expiry、recovery daemon、complete-prefix 与 version replay rule。
- [ ] 能解释 online backup 与 Petal snapshot 的关系。
- [ ] 能准确陈述 evaluation 的 workload、趋势、bottleneck 与不能推出的结论。
- [ ] 能独立完成官方 Question 的 version comparison，而不是只写“使用版本号”。
