---
uid: mit-6824-s21-resource-reading-4
type: course
document_type: resource
resource_kind: reading
resource_order: 104
course: mit-6824-s21
title: Lecture 4 阅读与作业指南：VMware Fault-Tolerant Virtual Machines
description: Lecture 4 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 4 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-04/"
toc: true
official_lecture_number: 4
---

## 1. 来源、指定范围与证据边界

- 指定论文：**The Design of a Practical System for Fault-Tolerant Virtual Machines**（Scales, Nelson, and Venkitachalam, 2010）。
- 指定范围：课程材料没有给出章节截断，按归档论文全文阅读。
- FAQ 与 Paper Question 均有本地归档；performance 数字只采用 paper/FAQ 中的 archived results。
- 课堂 `NOTES.md` 只用于“课堂连接”，不把 transcript speculation 写成 paper fact。

资源：

- [VMware FT 归档论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/vm-ft.pdf)
- [VMware FT FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/vm-ft-faq.txt)
- [官方 Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/04-q-vm-ft.html)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/)
- [Lecture 4 NOTES](/courses/mit-6824-s21/lectures/004/)

## 2. 阅读目的

本篇 paper 的核心不是“运行两个相同 VMs”，而是把 primary/backup replication 做成一个完整、可运营的 system。阅读要回答：

1. 怎样把 VM execution 视为 deterministic state machine，并只复制 non-deterministic inputs/outcomes？
2. 为什么相同执行仍不足以保证 failover 后的 external consistency？
3. `Output Rule` 如何把 backup state 与 primary 已产生的 external outputs 联系起来？
4. Failure detector 无法区分 crash/partition 时，shared storage 的 atomic test-and-set 如何避免 split brain？
5. 自动创建 replacement backup、logging flow control、disk/network I/O races 为什么属于 correctness 的一部分，而非外围运维？

## 3. 问题、模型与假设

### 3.1 目标

Primary VM 在一个 physical server 上对外服务，backup VM 在另一个 server 上以 small lag 执行相同 workload。Primary failure 后，backup 应接管，并保持与 primary 已对外发送 outputs 一致的 execution history。

### 3.2 Failure model

Paper 主要处理 **fail-stop failures**：failure 在产生 incorrect externally visible action 前可被检测。它不处理 compromised/malicious hypervisor；FAQ 把更一般的 arbitrary/malicious failure 归入 Byzantine 类别。

### 3.3 Platform assumptions

- VMware vSphere 4.0、fully virtualized x86 VMs；
- primary 与 backup 通常访问 shared virtual disks；
- normal design 是 one primary + one backup；
- production deterministic replay 当时只支持 uni-processor VMs；
- guest OS 和 applications 无需修改。

### 3.4 State-machine assumption

若两个 state machines 从相同 initial state 出发，并按相同顺序获得相同 inputs，它们会经过相同 states 并产生相同 outputs。VM 的 external inputs、interrupt delivery point、cycle counter/time 等 non-deterministic operations 必须被 capture/replay。

## 4. Architecture 与核心机制

### 4.1 Basic FT configuration

```text
client/network input -> primary VM
                         |
                         v
                 logging channel
                         |
                         v
                     backup VM

primary + backup -> shared disk
```

- 只有 primary advertise network presence；network/keyboard/mouse inputs 先到 primary。
- Hypervisor 把 inputs 和 non-deterministic execution information 经 logging channel 发给 backup。
- Backup replay 同一 execution，但其 external outputs 被 hypervisor discard。
- Primary/backup 通过 heartbeats 与 logging traffic/ACK monitoring 检测 peer failure。

### 4.2 Deterministic replay

- Interrupt 类 event 记录 exact instruction point，backup 在相同 instruction stream point 交付。
- Non-deterministic operation 记录足够的 result/state change，backup 重现相同 effect。
- Hypervisor 对 virtual hardware 有控制权，因此比 physical server 更容易约束 interrupt timing 等 non-determinism。
- FAQ 说明 CPU performance counters 可帮助 VMM 在执行指定数量 instructions 后重新取得控制。

### 4.3 Output Requirement 与 Output Rule

Paper 的 **Output Requirement**：若 backup 在 primary failure 后接管，它继续执行的方式必须与 primary 已发送到 external world 的所有 outputs 完全一致。

对应规则是：

> **Output Rule**: the primary VM may not send an output to the external world, until the backup VM has received and acknowledged the log entry associated with the operation producing the output.

重点：delay 的是 external output，不要求 primary VM 整体停止执行。Backup 只需已收到可 replay 到 output point 的 log，不必当时已经执行到该点。

### 4.4 Failure detection、go-live 与 split-brain arbitration

- Heartbeat/logging traffic 停止超过 timeout 只能产生 failure suspicion，不能区分 peer crash 与 network partition。
- 任一 VM 想 go live 时，对 shared storage 执行 atomic test-and-set。
- 成功者 go live；失败者知道另一方已获得权利并 halt。
- 若无法访问 shared storage，则等待而不冒险 go live；论文理由是 virtual disks 本来也在同一 shared storage 上，此时 VM 难以做有用工作。

### 4.5 Repair 与 replacement backup

Failure 后新的 primary 暂时没有 backup。VMware FT 使用 modified VMotion：clone 正在运行的 VM 到另一 host，建立 logging channel，让 source 进入 logging mode、destination 进入 replay mode。Paper 报告 primary pause 通常少于一秒，cluster service 选择 replacement host，redundancy 通常在数分钟内恢复。

### 4.6 Logging channel flow control

- Primary/backup hypervisors 各有 large log buffer。
- Backup 读到 log entries 后发送 ACK；ACK 决定哪些 delayed outputs 可以 release。
- Backup buffer empty 时 backup 等待；primary buffer full 时 primary 必须停止，这是 natural flow control，但会影响 clients。
- Backup lag 过大时，system 逐步减少 primary CPU allocation；目标是让 execution lag 保持很小，paper 说 typical 小于 `100 ms`，超过约 `1 s` 时开始 slow primary。

### 4.7 Disk/network I/O engineering

- Disk I/O races 通过 serialization 或 bounce buffers 控制。
- Primary failure 时 outstanding disk I/Os 可能已执行也可能未执行；new primary re-issue pending I/Os，因为 paper 使这些 I/Os idempotent。
- FT 禁用会异步修改 virtual network device state 的 optimizations，改用可记录的 trap path；再用 batching、fewer traps/interrupts 和 no-context-switch log ACK path 改善性能。

## 5. Correctness、failure 与 consistency 推理

### 5.1 为什么 deterministic replay 还不够

若 primary 已向 client 发 output，但 backup 尚未收到导致该 output 的 log，primary 此时 crash，backup 可能从一个与 client 已见 output 不一致的 state 接管。Determinism 只能保证“相同 inputs 产生相同 execution”，不能保证 backup 已拥有所有 externally observed inputs。

Output Rule 把 causal order 固定为：

```text
backup receives relevant log
  -> backup ACK
  -> primary releases external output
```

### 5.2 Exactly-once output 不被保证

Paper 明确说 failover 时无法仅凭 backup 判断 primary 是在最后 output 前还是后 crash，除非使用 transaction/two-phase commit。因此最后 output 可能丢失或 duplicate；network infrastructure/TCP 被设计为处理 lost/duplicate packets。

FAQ 进一步说明：network duplicate 可由 TCP discard；re-issued disk I/O 对同一 location 写同一 data，且没有 intervening I/O，因此 idempotent。

### 5.3 Partition 下的 safety argument

Failure detector 只产生 suspicion。真正的 exclusivity 来自 shared-storage test-and-set 的 single linearization point：无论 primary/backup 的消息时序如何，最多一方得到成功结果。不能访问 arbitrator 的一方不能自行假设对方失败。

### 5.4 Failover catch-up

Backup 可能已经 received/ACKed 但尚未 consumed 一些 logs。Primary failure 后，它先 replay 到最后 received log，再停止 replay mode、go live、开始 actual output。Network 切换时广播新 primary 的 MAC location；pending disk I/O 由 go-live process 重发。

### 5.5 Common-cause 与 scope boundary

- 相同 guest software bug 可在两边重现，replication 不修复 logic bug。
- Compromised hypervisor 不在 threat model 内。
- Shared storage/arbiter 是 system dependency；paper 另讨论 non-shared disks 时可用 third-party server 或 cluster majority 作 tiebreaker。
- Uni-processor restriction 避免 shared-memory races 所造成的高频 non-determinism。

## 6. Performance 与 evaluation

### 6.1 Basic application results

Paper setup 使用两台相同 servers，各有 eight Intel Xeon 2.8 GHz CPUs、8 GB RAM；shared disks 经 4 Gbit/s Fibre Channel，logging network 为 10 Gbit/s crossover。

| Workload | FT / non-FT performance | Logging bandwidth |
| --- | ---: | ---: |
| SPECJbb2005 | `0.98` | `1.5 Mbits/s` |
| Kernel Compile | `0.95` | `3.0 Mbits/s` |
| Oracle Swingbench | `0.99` | `12 Mbits/s` |
| MS-SQL DVD Store | `0.94` | `18 Mbits/s` |

因此这些 representative workloads 的 overhead 少于 `10%`，logging bandwidth 少于 `20 Mbits/s`。这不代表所有 workloads：high network receive 或 disk read rate 可使 logging channel 成为 bottleneck。

### 6.2 Disk-read alternative

让 backup 自己执行 disk reads 可减少 logging bandwidth，但需要额外 correctness handling，且吞吐略降：

- Oracle Swingbench throughput 低约 `4%`，logging 从 `12` 降到 `3 Mbits/s`；
- MS-SQL DVD Store throughput 低约 `1%`，logging 从 `18` 降到 `8 Mbits/s`。

### 6.3 Network benchmark

- Non-FT send/receive 接近 `940 Mbit/s`。
- `1 Gbit/s` logging channel 下，FT receive 为 `604 Mbit/s`，logging traffic `730 Mbit/s`；FT transmit 为 `855 Mbit/s`。
- `10 Gbit/s` logging channel 下，FT receive 为 `860 Mbit/s`，FT transmit 为 `935 Mbit/s`。

Receive path 要把 incoming packets 复制给 backup，压力更大；transmit data 本身不进入 log，但 Output Rule/interrupts 仍影响 latency/throughput。

## 7. 设计权衡与限制

| 选择 | 收益 | 代价/限制 |
| --- | --- | --- |
| Machine-level replay | OS/application transparent | 低层 event logging、I/O race handling、缺少 application semantics |
| RSM 而非 continuous state transfer | 通常较低 bandwidth | 必须捕获全部 non-determinism；uni-processor limitation |
| Output Rule | failover state 与已见 output 一致 | output latency 增加，logging ACK 进入 critical path |
| Shared disk | failover 时 disk content 已可用，也可仲裁 | shared storage 是 dependency；远距离/无共享环境受限 |
| One primary + one backup | protocol 与 management 相对简单 | failure 后短暂无 redundancy；不能直接容忍第二次 failure |
| Automatic replacement | 恢复保护而无需长时间人工介入 | clone/resource placement 需要 cluster management |
| Non-shared disk alternative | 可用于无 shared storage/long-distance | 初始与 repair 时必须同步 disk；另需 tiebreaker |

## 8. 官方 Paper Question / Homework

**Assigned Question（原文）**：

> How does VM FT handle network partitions? That is, is it possible that if the primary and the backup end up in different network partitions that the backup will become a primary too and the system will run with two primaries?

### 推理脚手架（不是可直接提交的成稿）

1. 画三条 connectivity：primary-backup logging channel、primary-shared storage、backup-shared storage；不要把“P 与 B 失联”自动扩成“都与 storage 失联”。
2. 分别枚举：只有 primary 能访问 storage、只有 backup 能访问、两者都能访问、两者都不能访问。
3. 对每个 case 写明谁会尝试 go live，以及 atomic test-and-set 的共享 flag 初值与一次成功后的状态。
4. 把 test-and-set 看作 linearization point，证明两个 calls 不可能都返回成功。
5. 对无法访问 storage 的节点，检查 protocol 是继续服务还是等待；说明该选择在 safety/availability 间的取舍。
6. 最后单独说明 failure detector/timeout 为什么不能完成上述证明，它只触发 suspicion。

请自行把 case analysis 组织成回答；不要只写“用了 test-and-set”而省略 network partition 下的 reachability 与 exclusivity 推理。

## 9. FAQ 要点

- Hypervisor/VMM 控制 virtual hardware 与 interrupt delivery，因此比 physical server 更容易保证 deterministic execution。
- VMware FT 复制 computation，可透明保护 existing network server；GFS 只复制 storage，专用化使它更高效。FT 本身仍依赖 fault-tolerant shared storage。
- Bounce buffer 先接收 DMA data，再在 VM stopped 的可记录 point 拷入 guest memory，避免 primary/backup 因 DMA race 看见不同内容。
- Atomic test-and-set 让 shared disk server 充当 tiebreaker；只有第一方获得 go-live 权利。
- Output Rule 会降低 transmit rate，但 Table 2 表明不是完全摧毁 throughput。
- Randomness 的 sources（time、cycle counter、interrupt timing）由 hypervisor 截获并在两边产生相同 values。
- FAQ 对“如何确定捕获所有 non-determinism”使用了 `My guess`/`I assume`，这部分是经验推测，不是形式证明。
- Primary 在 output 后立刻失败时，backup 可能重复 output；TCP 或 idempotent disk I/O 处理 duplicate。
- Pending disk I/O 由“有 start log、无 completion interrupt log”识别，go-live 时重发。
- Fail-stop 是主要 scope；compromised hypervisor/Byzantine failures 不在本系统保证内。

## 10. 课堂讨论如何连接并改变重心

[Lecture 4 NOTES](/courses/mit-6824-s21/lectures/004/) 把 paper 重新组织成“故障模型 -> replication method -> execution replay -> external output -> arbitration -> repair”的推导：

- 课堂先比较 state transfer 与 replicated state machine（RSM），突出 machine-level replication 的 transparency 与 granularity cost。
- 通过具体 counter `10 -> 11` 的反例推导 Output Rule，而不是把它当一条孤立定义。
- Homework 的 partition 问题被提升为 failure detector 与 safety proof 的区别：timeout 不能证明 peer dead，test-and-set 才提供单一 winner。
- 课堂强调 backup output suppression、one-log-entry lag、non-deterministic trap/replay，以及 failover 前 catch-up。
- Performance 重心从“平均 overhead 小于 10%”转到 per-packet input forwarding 与 ACK critical path；network-heavy workload 是主要边界。

课堂对后续 VMware 产品或某些 timeout 数字明确表示不确定；这些内容不应覆盖 paper/FAQ 的 archived claims。

## 11. 论文理解题（10 题）

1. **State transfer 与 replicated state machine 的主要差别是什么？**  答案点：复制 state changes/checkpoints；复制 ordered operations/inputs 并本地执行。
2. **为什么 VM 是实现 deterministic replay 的有利层级？**  答案点：hypervisor 控制 virtual inputs、interrupt delivery 和 non-deterministic operations。
3. **正常运行时 backup 为什么执行 output instruction 却不对外发送？**  答案点：保持 identical execution，同时由 hypervisor suppress duplicate external effect。
4. **Output Requirement 与 Output Rule 的关系是什么？**  答案点：前者定义 failover 后 external consistency；后者以 log receipt ACK 约束 output release 来实现。
5. **Output Rule 为什么不要求 primary VM 整体停止？**  答案点：只需 delay external output；guest 可继续 asynchronous execution。
6. **为什么 heartbeats 不能独自避免 split brain？**  答案点：无消息无法区分 crash/partition；需 external atomic arbitration。
7. **Backup go live 前为什么要 replay remaining acknowledged logs？**  答案点：它可能 execution lag；必须到达与 primary 已允许 outputs 一致的 prefix。
8. **为什么系统不能保证 outputs exactly once？**  答案点：无法判断 primary 在 last output 前/后 crash；没有 output transaction/two-phase commit。
9. **Uni-processor limitation 从哪里来？**  答案点：multi-core shared-memory races 是高频 non-determinism，efficient replay 尚未实现。
10. **Network receive workload 为什么比 transmit 更容易压满 logging channel？**  答案点：incoming packet data 必须复制给 backup；outgoing payload 不必作为 input log，但仍受 ACK/interrupt cost。

## 12. 复习清单

- [ ] 能写出 fail-stop scope，并说出不覆盖的 common-cause/Byzantine failures。
- [ ] 能比较 state transfer、RSM 与 machine-level replay。
- [ ] 能画 primary、backup、logging channel、shared disk 与 external clients。
- [ ] 能解释 external inputs、interrupt point 与 non-deterministic outcome 如何 replay。
- [ ] 能从反例推导 Output Requirement 和 Output Rule。
- [ ] 能解释 output suppression、backup lag 与 failover catch-up。
- [ ] 能枚举 partition reachability cases，并用 test-and-set 证明最多一个 go-live winner。
- [ ] 能解释 bounce buffer 与 pending disk I/O re-issue 的 correctness 目的。
- [ ] 能复述 application/network benchmark 数字及其 setup boundary。
- [ ] 能说明 shared storage、one backup、uni-processor 与 network-heavy workloads 的限制。
