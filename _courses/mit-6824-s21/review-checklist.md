---
uid: mit-6824-s21-review-checklist
type: course
document_type: resource
resource_kind: review
resource_order: 3
course: mit-6824-s21
title: MIT 6.824 Spring 2021 字幕与证据复核清单
description: 按风险回查自动 transcript、课件与视频中的未决证据。
excerpt: 按风险回查自动 transcript、课件与视频中的未决证据。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/review-checklist/"
toc: true
math: true
---

> 本清单已检查 `lectures/` 下全部 22 个媒体 part 的根 `NOTES.md`，并在根笔记压缩信息时回看相应 section notes。22 个 part 对应官方 Lecture 1-21；官方 Lecture 15 分为 Part 1、Part 2。
>
> **重要说明：** 已经人工整理、交叉阅读过的字幕仍可能含有术语、数字、否定词、指代或画面依赖问题。以下 marker 是下一轮核验队列，不是“已确认错误”列表；“当前证据”只描述仓库内现有 transcript、讲义、paper 或课堂上下文支持到哪里，不用外部知识替源笔记下结论。

## 计数与口径

- 唯一项总数：**273**。
- 受影响官方讲次：**21 / 21**；已检查媒体 part：**22 / 22**。
- 高优先级：**244**。凡影响 protocol condition、failure model、invariant、paper experiment number、code/API 或 lab concept 的项目均标为 `H`。
- 分类计数：`T` 字幕术语/名称 **46**；`N` 数字/公式/实验歧义 **29**；`P` 协议/代码/API 语义 **133**；`C` 讲义/paper/课堂口述冲突 **25**；`E` 证据边界/缺失画面 **40**。
- 唯一键即首列 ID：`P<媒体 part>-<首个时间戳或 NA>-<topic>`。同一根笔记摘要与其内嵌 section 重复出现的 marker 只保留一次；同 topic 的连续自我纠正可合并为一个时间范围。
- 可复现计数：只统计满足 `| P... | H-X |` 或 `| P... | M-X |` 的表格行；按优先级列汇总 `H/M`，按末位汇总 `T/N/P/C/E`，按 ID 检查重复。
- 不计入：纯课堂噪声、breakout 无声区间、分段边界提醒、告别/考试行政字幕、已经由下一 section 完整续接且不再留有技术歧义的句子。

优先级/分类写作 `H-P`、`M-T` 等；`H` 为高优先级，`M` 为普通复核。每一项均给出时间、根笔记链接、问题、当前证据和核验目标。

## Lecture 1 - Introduction

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P01-000154-network-diagram | M-E | 00:01:54 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 网络示意图主语/节点缺失。**当前证据：** 口述只确认 clients、servers、data centers、networks。**核验：** 回看画面确认箭头和节点，不补未口述组件。 |
| P01-000919-datacenter-era | M-C | 00:09:19；00:11:18 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** data-center/cloud 年代口述宽泛。**当前证据：** 讲义写 late 1990s/early 2000s，课堂未给单一年份。**核验：** 分别记录口述范围与讲义文字。 |
| P01-001604-mapreduce-era | M-C | 00:16:04 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 字幕出现 “early 90s”，与课程其他证据不协调。**当前证据：** 可靠课堂论点仅是约 2000 machines 共同工作。**核验：** 回听年代词，不据此确定论文年份。 |
| P01-001707-failure-suspicion | H-P | 00:17:07；01:09:01-01:10:43 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** “assume crashed” 易被读成 failure proof。**当前证据：** split brain/network partition 表明 timeout 只能 suspect，worker 可能仍运行。**核验：** 确认 failure model 与 duplicate execution 推导。 |
| P01-002342-replication-sharding | H-P | 00:23:42 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** replication 与 sharding 容易混同。**当前证据：** Lab 2/3 用复制容错，Lab 4 用分片提高并行吞吐。**核验：** 回听老师是否限定为课程 lab 语境。 |
| P01-003429-rpc-semantics-name | H-T | 00:34:29 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 字幕为 `utmost once`。**当前证据：** 上下文在预告 at-most-once/exactly-once/at-least-once。**核验：** 确认原词及是否只作预告。 |
| P01-003701-reliability-number | M-N | 00:37:01 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** `0.999 reliability` 无统计窗口。**当前证据：** 课堂未换算 downtime/SLA。**核验：** 只确认口述数字和限定语。 |
| P01-004829-mapreduce-generality | H-P | 00:48:29-00:49:55 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 末句疑漏否定词。**当前证据：** 前文明说 MapReduce 不是 general-purpose，KV service 不适合直接套用。**核验：** 回听否定语义。 |
| P01-005317-wordcount-c | H-C | 00:53:17 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 字幕 `(c,2)` 与前后及讲义 `(c,1)` 冲突。**当前证据：** 前文说 `c` 一次，后文/讲义输出 `(c,1)`。**核验：** 原音与画面确认该 tuple。 |
| P01-005321-shuffle-boundary | H-P | 00:53:21 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** “second step/shuffle” 可能混合 grouping/data movement 与 Reduce。**当前证据：** 后续另讲 programmer-defined Reduce。**核验：** 确认课堂阶段边界。 |
| P01-010303-reduce-output-file | H-P | 01:03:03-01:04:25 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** “one output file per reduce function”及“no network”范围易误读。**当前证据：** 指每个 Reduce task 文件；无网络仅限 local Map read/write。**核验：** 对照板书确认 task/function 和网络范围。 |
| P01-011240-atomic-rename | H-P | 01:12:40 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** atomic rename 是否足以处理 duplicate execution。**当前证据：** rename 只原子发布 Reduce temporary output，结果等价仍依赖 determinism。**核验：** 确认 GFS/local intermediate 的对象边界。 |
| P01-011418-local-data-recovery | H-C | 01:14:18 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 口述 local data “maybe” survives 与讲义按丢失后重算的提纲有张力。**当前证据：** 可能对应不同 failure 情境。**核验：** 回听并标出 machine/storage failure 假设。 |
| P01-011519-coordinator-failure | H-P | 01:15:19 | [NOTES](/courses/mit-6824-s21/lectures/001/) | **问题：** 回答开头字幕破碎。**当前证据：** 完整上下文支持 coordinator crash 未处理、whole job 重跑。**核验：** 确认这是实现边界而非所有 MapReduce 系统断言。 |

## Lecture 2 - RPC and Threads

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P02-001553-unlocked-run | H-P | 00:15:53-00:16:01 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** 字幕破碎。**当前证据：** 未正确加锁的程序某次仍可能看似正常。**核验：** 确认 race 例子的 observable behavior。 |
| P02-002327-majority-five | H-N | 00:23:27-00:23:37 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** 10 votes 场景中 `count < 5`/`count >= 5` 与 majority 术语冲突。**当前证据：** transcript 无法判定 `5`、`>5` 或漏词。**核验：** 回看屏幕源码和比较符。 |
| P02-002625-defer-scope | H-P | 00:26:25-00:26:42 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** `defer` 被口述为离开 basic block/function。**当前证据：** 本例只确定 function return 执行 deferred `Unlock()`。**核验：** 确认课堂是否口误及代码作用域。 |
| P02-003042-stack-variable | H-P | 00:30:42-00:31:49 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** stack variable/segmentation fault 初答随后撤回。**当前证据：** 根笔记采用后续修正。**核验：** 保留问答修正顺序，不引用初答为结论。 |
| P02-003430-cond-wait | H-P | 00:34:30-00:35:30 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** `Wait`/`Signal`/`Broadcast` 字幕损坏。**当前证据：** `Wait()` 原子 release lock 并 sleep，Signal/Broadcast wake one/all。**核验：** 回听原词与锁原子性。 |
| P02-004743-waitgroup-return | H-P | 00:47:43-00:47:49 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** 字幕写 “will return until”。**当前证据：** 所有 `Add` 由 `Done` 平衡后 `Wait` 才返回。**核验：** 确认否定/时序词。 |
| P02-005035-channel-handoff | H-P | 00:50:35-00:51:48 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** URLs、worker、channel 主语混乱且“一次只有一个 request”含混。**当前证据：** worker 发送 URL 组，coordinator 接收并更新 outstanding；unbuffered channel 是 value handoff。**核验：** 对照代码确认角色和 channel 语义。 |
| P02-005546-rpc-unmarshal | H-T | 00:55:46-00:55:51 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** server 端 marshal/unmarshal 连说。**当前证据：** server 收 request 应执行 unmarshal。**核验：** 回听术语。 |
| P02-005650-stub-generation | H-P | 00:56:50-00:57:06 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** 口述 automatic generated stubs，示例却用 generic `client.Call()`。**当前证据：** 可能混合 code generation 与 library dispatch。**核验：** 以课堂所示 Go RPC framework 确认。 |
| P02-010035-rpc-register | H-P | 01:00:35-01:01:25 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** exported-method 和 TCP create/listen/accept 口述不精确。**当前证据：** 大写方法由 `Register` 暴露；代码是 `Listen` 后 `Accept`。**核验：** 对照 `kv.go` 屏幕。 |
| P02-010355-rpc-semantics | H-P | 01:03:55-01:05:58 | [NOTES](/courses/mit-6824-s21/lectures/002/) | **问题：** at-least-once/exactly-once 与 TCP/no duplicate 的边界含混。**当前证据：** Go RPC 单次 call 不 resend；application retry 可重复，永久 failure 也破坏 liveness。**核验：** 区分 library call、logical operation、Lab 3 durable dedup。 |

## Lecture 3 - GFS

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P03-000551-consistency-protocol | H-T | 00:05:51 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** `persistency protocol` 疑为 consistency protocol。**当前证据：** 上下文是副本协调且可能含 durable I/O。**核验：** 回听原词。 |
| P03-001657-single-master | H-P | 00:16:57-00:17:02 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** “single master is not replicated” 可能过度概括。**当前证据：** 只可靠支持单一 active coordinator。**核验：** 确认是否谈 backup/shadow master。 |
| P03-001823-s3-name | M-T | 00:18:23-00:18:27 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** `S3` 很可能是 Amazon S3。**当前证据：** 语境说其 consistency 变强。**核验：** 回听系统名。 |
| P03-002023-throughput | H-N | 00:20:23-00:21:27 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** “over a thousand or 10,000” 与 “well over 10,000 MB/s” 不一致。**当前证据：** 后一句较清楚。**核验：** 回看图轴和精确峰值。 |
| P03-002340-auto-ft | H-P | 00:23:40-00:23:42 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** “not completely automatic” 未说明人工边界。**当前证据：** 本讲未完成哪些 recovery 需人工的解释。**核验：** 仅用本地 lecture evidence 确认范围。 |
| P03-002955-replica-three | H-P | 00:29:55 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** 典型副本数三的原因被预告但后续未完成。**当前证据：** 无课堂结论。**核验：** 标为未讲，不用 paper 补成口述。 |
| P03-003152-checkpoint-fields | H-E | 00:31:52 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** checkpoint 字段字幕缺词。**当前证据：** 至少含 filename-to-chunk-handle mapping。**核验：** 回听/画面确认是否列举其他字段。 |
| P03-003349-lease-volatile | H-P | 00:33:49-00:34:02 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** current primary/secondaries 与 lease time 被 “presumably” 归为 volatile。**当前证据：** 是课堂推测语气，不是完整规范。**核验：** 保留限定词并核对 paper/讲义冲突。 |
| P03-004325-new-epoch-scope | H-P | 00:43:25-00:45:15 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** epoch scope 与 version durable ordering 口述含混。**当前证据：** 操作对象是当前 chunk；回复 client 前 replicas/master 均持久化。**核验：** 回看写入图确认范围和 ack 顺序。 |
| P03-004953-duplicate-offset | H-E | 00:49:53-00:52:32 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** replica/offset 板书丢失，学生关于 actual offset/undefined 区域未被逐句确认。**当前证据：** 只确定 partial success + retry 可产生 duplicates，library record ID 是重点。**核验：** 回看板书和回答。 |
| P03-005643-version-reconfig | H-E | 00:56:43-01:00:38 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** P/S 标签不稳，reconfiguration 又被老师标为 “I imagine”。**当前证据：** 可确认 version `10->11`、旧 S2、不对称可达及 heartbeat 猜想。**核验：** 恢复原图但保留推测性质。 |
| P03-010306-split-brain-primary | H-P | 01:03:06-01:04:50 | [NOTES](/courses/mit-6824-s21/lectures/003/) | **问题：** 字幕称 split brain 为 two masters，画面/上下文似为同 chunk two primaries；all-or-none 句又不构成具体原子协议。**当前证据：** 只可靠支持避免 partial visibility 的目标。**核验：** 回看图和原音。 |

## Lecture 4 - Primary/Backup Replication

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P04-000012-replication-word | M-T | 00:00:12 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** 字幕将 replication 写成 application。**当前证据：** 主题和上下文明确为 primary/backup replication。**核验：** 回听术语。 |
| P04-001124-latest-state | H-P | 00:11:24-00:14:38 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** `latest state` 缺词且 state-change/operation 两种复制方式混句。**当前证据：** 共同要求是副本执行相同 state transition。**核验：** 分开恢复两种方式。 |
| P04-002257-hardware-name | M-T | 00:22:57-00:26:03 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** 传统硬件名称不可辨；后续产品用 state transfer 又是推测。**当前证据：** 只确认 duplex/triple replication + voting。**核验：** 回听名称与推测限定词。 |
| P04-003150-same-instruction | H-P | 00:31:50-00:32:00 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** “same time” 易被理解为 wall-clock 同时。**当前证据：** 后文限定 same instruction point。**核验：** 确认 deterministic replay invariant。 |
| P04-004032-network-arrow | H-E | 00:40:32-00:40:47 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** transcript 无法恢复箭头几何。**当前证据：** 老师说箭头不应指向 C，而应走 network。**核验：** 回看画面确认 failure scenario。 |
| P04-005246-vmotion | M-T | 00:52:34-00:53:27 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** `VMware motion` 应为 VMotion clone；暂停 processing 的口述错序。**当前证据：** clone/reset 完成前不处理请求。**核验：** 回听产品名和顺序。 |
| P04-010108-uniprocessor | H-P | 01:01:08-01:07:49 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** `single instruction` 疑为 uniprocessor；non-deterministic instruction 改写/trap 细节不足。**当前证据：** 只确定记录结果并复制到相应 register。**核验：** 回看代码/slide，不固定 `a0` 名称。 |
| P04-011449-go-live-order | H-P | 01:14:49-01:19:59 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** backup replay/go-live 叙述被现场修正。**当前证据：** 根笔记采用修正顺序并连接 Output Rule。**核验：** 逐步确认 replay、external output、go-live 条件。 |
| P04-012238-performance-table | H-N | 01:22:38-01:23:19 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** transcript 未保存表格列名/数值。**当前证据：** 只听到“接近”和约 30% reduction。**核验：** 回看画面，不从 paper 擅自填整表。 |
| P04-013135-timeout | H-N | 01:31:35-01:32:59 | [NOTES](/courses/mit-6824-s21/lectures/004/) | **问题：** “every ten milliseconds or something”及学生记忆不足以确定 timeout。**当前证据：** 课堂只给近似/猜测。**核验：** 区分课堂口述与 paper-only 参数。 |

## Lecture 5 - Fault Tolerance: Raft (1)

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P05-000043-log-compaction | M-T | 00:00:43-00:00:50 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** `log compassion` 疑为 log compaction。**当前证据：** 课程安排/讲义支持 compaction。**核验：** 回听原词。 |
| P05-000205-vmft-single-point | H-C | 00:02:05-00:02:15 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** storage server 与 FT test-and-set server 被字幕混在一起。**当前证据：** 讲义写 FT's test-and-set server。**核验：** 确认课堂如何连接两者。 |
| P05-001028-majority-membership | H-P | 00:10:28-00:14:18 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** “majority of followers” 是否含 leader 不清。**当前证据：** 后文明确 leader 自计数。**核验：** 确认 majority replication 条件。 |
| P05-002103-commit-threshold | H-C | 00:21:03-00:21:12 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** overview 说 replicated on 3 servers，后续 2/3 即 commit。**当前证据：** 精确时间线支持 leader + one follower。**核验：** 判断前句是泛称还是冲突。 |
| P05-002538-client-redirect | H-P | 00:25:38-00:25:47 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** non-leader “redirect” 是协议动作还是 client retry 泛称。**当前证据：** 无 RPC 字段证据。**核验：** 回听并对照 Figure 2/API。 |
| P05-003218-election-restriction | H-P | 00:32:18-00:32:32 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** 持 entry 的 follower “will become leader” 可能被过度推广。**当前证据：** 只是 election restriction 预告，未证明必然当选。**核验：** 确认条件语气。 |
| P05-004815-election-timeout | H-N | 00:48:15；00:51:36 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** `150-300 ms` 与 `250-300 ms` 冲突。**当前证据：** 两处字幕不一致。**核验：** 原音、slide/paper experiment 区间。 |
| P05-005147-recovery-second | H-N | 00:51:47-00:51:54 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** “recover within a second” 是否是 tester constant。**当前证据：** 老师是宽松口述。**核验：** 不把它转成 Lab 参数。 |
| P05-010011-figure7-index | H-E | 01:00:11-01:00:20 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** divergence 图混合 index 12 与 index 4。**当前证据：** transcript 无法恢复格子。**核验：** 回看 Figure 7 画面。 |
| P05-010240-figure-number | M-T | 01:02:16-01:02:40 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** 老师先说 Figure 6 后改 Figure 7。**当前证据：** 根笔记按最终修正。**核验：** 确认画面。 |
| P05-011321-top-server | H-E | 01:02:40-01:13:46 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** top server 是否当选、格子 term/index 口述有张力。**当前证据：** 教学目的只确认下一 leader 不固定。**核验：** 对照 Figure 7 caption 和课堂图。 |
| P05-011730-voter-set | H-E | 01:17:30-01:25:11 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** `a/c/d/e/f` voter sets 在多人抢话中不完整。**当前证据：** `a` 无需 `d` 也可能 majority；其余不确定。**核验：** 回看投票图，不从 homework 反填。 |
| P05-012252-current-term-reply | H-P | 01:22:52-01:23:40 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** same current term 的 RequestVote reply 是否令 `a` step down 叙述矛盾。**当前证据：** 需结合 `d.currentTerm`；log replacement 尚未展开。**核验：** 确认 term transition 条件。 |
| P05-012915-committed-grid | H-E | 01:29:15-01:30:04 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** terms 4/5/6 committed 状态字幕残缺。**当前证据：** 只可靠支持 committed prefix + tentative term 7。**核验：** 回看 Figure 7 精确格子。 |
| P05-013321-commit-index-field | H-P | 01:33:21-01:33:29 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** `lastApplied`/`commitIndex` 混为 “last applied committed index”。**当前证据：** 不能静默合并 Figure 2 字段。**核验：** 原音/板书确认变量。 |
| P05-013416-majority-accepted | H-P | 01:34:16-01:34:33 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** “majority accepted” 后 entry “can/may not” committed 有张力。**当前证据：** 可能混合 accepted、known committed、different-term rule。**核验：** 与 Lecture 7 课堂澄清对读。 |
| P05-013658-batching | H-P | 01:36:58-01:37:24 | [NOTES](/courses/mit-6824-s21/lectures/005/) | **问题：** 先说 Raft 不 batching，后认可实现可等待批量发送。**当前证据：** 可能是 protocol requirement 与 implementation choice 区别。**核验：** 确认两层边界。 |

## Lecture 6 - Lab 1 Q&A

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P06-000712-atomic-rename-code | H-E | 00:07:12-00:07:18 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** atomic rename 的文件名/调用参数只在屏幕。**当前证据：** 口述目的为避免并发 Map 写冲突。**核验：** 回看代码，区分 Map/Reduce 输出路径。 |
| P06-001157-poll-period | H-N | 00:11:57-00:12:05 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** 周期是一秒还是十秒，老师表示不记得。**当前证据：** 不可固定参数。**核验：** 仅依据 handout/code（若本地存在）核对，不改源笔记。 |
| P06-002208-defer-code | H-E | 00:22:08-00:22:25 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** 临时添加的另一条 `defer` 语句无法从 transcript 恢复。**当前证据：** 只有口述作用。**核验：** 回看屏幕代码。 |
| P06-002907-channel-role | H-P | 00:29:07 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** 字幕说 worker sends tasks。**当前证据：** 完整链条支持 coordinator 将 tasks 放入 channel。**核验：** 确认角色与 channel direction。 |
| P06-005223-work-size | H-N | 00:52:23-00:55:50 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** matrix operation 省略且合理 work size 句尾缺词。**当前证据：** 无固定大小可记录。**核验：** 只恢复示例，不制造 Lab 常量。 |
| P06-010122-interface-timeout | H-P | 01:01:22-01:05:50 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** interface 写法及 timeout 可行范围多次“不确定/不记得”。**当前证据：** 十秒 task timeout 与检查间隔可自选仍清楚。**核验：** 对照本地 handout/API。 |
| P06-011102-atomic-api | H-P | 01:11:02-01:11:10；01:22:43-01:22:52 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** atomic primitive 名称两次被省略。**当前证据：** 只确定建议使用 atomic primitive。**核验：** 回听/屏幕确认 API，不猜函数名。 |
| P06-012451-channel-fairness | H-P | 01:24:51-01:25:24 | [NOTES](/courses/mit-6824-s21/lectures/006/) | **问题：** channel ordering/fairness 未得到确定答复。**当前证据：** 课堂不能证明 FIFO 保证与否。**核验：** 保持为未决 lab/runtime 语义。 |

## Lecture 7 - Fault Tolerance: Raft (2)

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P07-000208-figure-switch | M-E | 00:02:08-00:02:32 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** Figure 6/7 切换不清。**当前证据：** 后续是 Figure 7 election discussion。**核验：** 回看画面。 |
| P07-000439-up-to-date-rule | H-P | 00:04:39-00:04:52 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** last-log term/index 比较句残缺。**当前证据：** 后续应用及讲义支持 election restriction。**核验：** 精确恢复比较条件。 |
| P07-001150-log-grid | H-E | 00:11:50-00:12:36 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** S3/S4 与 index 数量字幕错乱。**当前证据：** S1 较短，S2/S3 在共同前缀后以 term 5/4 分叉。**核验：** 回看板书。 |
| P07-001452-next-match-index | H-P | 00:14:52-00:18:04 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** `nextIndex=13`、`matchIndex=13`、“through 13”混用。**当前证据：** 变量语义清楚，板书数值有 off-by-one 歧义。**核验：** 以 Figure 2/Lab convention 对照画面。 |
| P07-002016-figure8-state | H-E | 00:20:16-00:24:04 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** Figure 8 节点名与 committed 状态串词。**当前证据：** term-2/3 index-2 entries 当时未 commit，Figure 8(e) 是 term-4 leader commit current-term entry。**核验：** 回看各 panel。 |
| P07-003143-backtrack-index | H-P | 00:31:43-00:36:27 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** `nextIndex` “back to 2”、`5 5 5`/`6 6 6`、term/index reply 理由含混。**当前证据：** 后缀已自纠为 6；具体 next/prev position 和 fast backup 算法未完整。**核验：** 对照实现约定和画面。 |
| P07-004113-commit-apply-order | H-P | 00:41:13-00:42:16 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** accepted/committed/delivered 串在一起。**当前证据：** majority accepted -> leader commit -> apply channel -> service。**核验：** 确认 client reply 时点。 |
| P07-005108-snapshot-prefix | H-P | 00:51:08-00:58:58 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** snapshot index `i`、删除 prefix/保留 suffix 的口述混乱。**当前证据：** operations through `i` 被 snapshot 覆盖，`i` 后 tail 保留。**核验：** 精确核对 boundary/dummy entry。 |
| P07-005630-condinstall-api | H-P | 00:56:30-00:56:49 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** API 被识别为 “conditional install”。**当前证据：** 很可能是 `CondInstallSnapshot`，但 2021 签名未核。**核验：** 本地 Lab 2D handout/code。 |
| P07-011003-reject-old-snapshot | H-P | 01:10:03-01:10:22 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** “reject all snapshots” 与协议冲突；suffix 保留条件也未完整。**当前证据：** 语境应为 reject old snapshots，保留仍需 boundary index/term match。**核验：** 回听否定/形容词。 |
| P07-011145-figure13-step6 | H-E | 01:11:45-01:12:14 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** Figure 13 step 6 问题自我中止。**当前证据：** 本讲无完整回答。**核验：** 标记未决，不用 paper 代替课堂回答。 |
| P07-011555-request-id | H-P | 01:15:55-01:16:05 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** request ID/last ID 口述混乱。**当前证据：** 只确定 logical request 需 stable ID，具体 client/sequence structure 留给 Lab 3。**核验：** 对照 Lab 3 contract。 |
| P07-012151-linearizability-diagram | H-E | 01:21:41-01:28:19 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** interval 端点与 `Rx1/Rx2` 指代缺词。**当前证据：** 最终 total-order 约束及 stale later read 的 cycle 结论清楚。**核验：** 回看白板 lanes。 |
| P07-013132-minority-leader | H-P | 01:31:32-01:33:15 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** “doesn't commit with a client” 字幕不清。**当前证据：** minority leader 不能 commit，service 不应完成 client reply。**核验：** 区分 commit/apply/reply。 |
| P07-013742-match-next-offbyone | H-P | 01:37:42-01:39:24 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** `matchIndex=13`、`nextIndex=14` 与 “both 13” 冲突。**当前证据：** 不可用口述数值写实现。**核验：** Figure 2/Lab 定义与画面。 |
| P07-014022-log-matching-name | H-T | 01:40:22-01:40:32 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** invariant 名称缺失。**当前证据：** 含义与 Log Matching property 一致。**核验：** 回听正式命名。 |
| P07-014657-snapshot-index0 | H-P | 01:46:57-01:47:18 | [NOTES](/courses/mit-6824-s21/lectures/007/) | **问题：** “start of 0 might be 10” 不清。**当前证据：** physical slice position 与 logical log index 分离。**核验：** 对照 Lab code 的 dummy/boundary layout。 |

## Lecture 8 - Lab 2A/2B Q&A

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P08-005528-backoff-fallback | H-P | 00:55:28-01:05:27 | [NOTES](/courses/mit-6824-s21/lectures/008/) | **问题：** AppendEntries conflict fallback 逐一 decrement 是否仍必要，讲者明确不完全确定；多个 outstanding reply 还可能重排 progress。**当前证据：** fast backtracking 有 conflict metadata，fallback 只确定可能多发 entries。**核验：** Figure 2 与测试证据，避免把课堂代码历史当规范。 |
| P08-012502-killed-race | H-P | 01:25:02-01:32:59 | [NOTES](/courses/mit-6824-s21/lectures/008/) | **问题：** `rf.killed` 并发访问是否 race 未得结论。**当前证据：** 静态 `peers` 多 reader 无 writer 的论证不能转移到 lifecycle state。**核验：** 以代码读写点和 race detector 证据判断。 |

## Lecture 9 - ZooKeeper

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P09-001359-throughput-graph | H-N | 00:13:59-00:14:38 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** `60-70 reads region` 疑为 60K-70K ops/s；3x/5x scaling 也只属直觉。**当前证据：** transcript 未保存纵轴。**核验：** 回看图刻度和端点。 |
| P09-002003-follower-read | H-E | 00:20:03-00:20:08；00:28:53-00:29:03 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** 否定词及 client lanes 缺失。**当前证据：** read 可返回 0 或 1，反例为先读 1 后读 0。**核验：** 回看白板进度点。 |
| P09-003553-fifo-order | H-P | 00:35:53-00:36:09 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** “result observes first operation” 含混。**当前证据：** FIFO client order 表示后发 operation 不越过先发。**核验：** 明确是 request order、completion 还是 state visibility。 |
| P09-003905-linearizable-writes | H-P | 00:39:05-00:39:51 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** linearizable writes 是否独立有意义被明确延期。**当前证据：** 本段无答案。**核验：** 只用后续课堂段落衔接，不用论文定义代答。 |
| P09-004137-zxid-client-state | H-P | 00:41:37-00:48:13 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** client `zxid` 从 “last write” 扩展到 highest observed progress，更新时点未完整。**当前证据：** 只确定 non-decreasing lower bound，可漏 other-client later writes。**核验：** 对照讲义 signature/algorithm。 |
| P09-005233-exists-watch | H-E | 00:52:33-00:54:02 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** `exists` 所见 create 的主语/zxid 依赖白板。**当前证据：** 后续 total-order 解释支持观察到成功 create。**核验：** 回看 lanes 和 zxid。 |
| P09-005835-watch-order | H-P | 00:58:35-01:01:41 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** notification 的白板位置及 “watches are local” 实现类比不完整。**当前证据：** 保证是先通知，再观察 triggering change 后的 state；wire protocol 未讲。**核验：** 精确恢复 order guarantee，保留实现推测。 |
| P09-010629-test-and-set | H-E | 01:06:29-01:06:51 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** naive test-and-set interleaving 丢失。**当前证据：** 两方都可能得到各自 IP 的结论明确。**核验：** 回看白板 schedule。 |
| P09-010932-session-timeout | H-P | 01:09:32-01:09:48 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** partition/heartbeat loss 到 session expiration 的 timeout 未给。**当前证据：** 不能写成即时 crash detector。**核验：** 保留 failure-detector 边界。 |
| P09-011058-getdata-api | H-C | 01:10:58-01:11:18 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** 口述第二参数为 version，讲义为 `getData(path, watch)` 并返回 version。**当前证据：** 根笔记按讲义和后续例子处理为口误。**核验：** 回听/画面确认 API。 |
| P09-012205-herd-effect | H-T | 01:22:05-01:22:13 | [NOTES](/courses/mit-6824-s21/lectures/009/) | **问题：** “without [hurting]” 疑为 without herd effect。**当前证据：** 讲义标题支持，但课堂未展开算法。**核验：** 只确认术语，不补步骤。 |

## Lecture 10 - Guest Lecture on Go

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P10-001113-readstring-exit | H-C | 00:11:13-00:12:35 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** slide 缺结束路径且口述混函数名。**当前证据：** p.16 `Success`/`BadInput` 与现场修正支持退出结论。**核验：** 对照 slide/音频。 |
| P10-001235-rune-type | H-C | 00:12:35 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** p.17 文本提取为 `int`，前后代码为 `char chan rune`。**当前证据：** 可能是 PDF extraction/layout 问题。**核验：** 检查 slide 图像，不改官方 PDF。 |
| P10-002212-profiler-symbol | M-T | 00:22:12 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** profiler synthetic function 名不清。**当前证据：** 只确定其用于明确计入 lost samples。**核验：** 回听 symbol spelling。 |
| P10-003847-queue-condition | H-C | 00:38:47-00:39:20 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** slide p.34 确写 `in != nil && len(q) > 0`，与口述 drain 意图冲突。**当前证据：** 可运行意图应为 `||`，根笔记保留官方 slide 错误。**核验：** 复核 slide 与现场修正。 |
| P10-005317-readtag-name | H-C | 00:53:17 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** p.74 `Tag(reply)` 与 p.71 `ReadTag` 命名不一致。**当前证据：** 口述是 pull tag out，笔记按 interface 统一。**核验：** 确认是否为重命名遗留。 |
| P10-011837-slices-api | M-P | 01:18:37 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** `slices` package 是 2021 预测而非当时 API。**当前证据：** 课堂上下文明确未来时。**核验：** 保持历史 API 边界。 |
| P10-013237-sort-name | M-T | 01:32:37 | [NOTES](/courses/mit-6824-s21/lectures/010/) | **问题：** 排序算法名称字幕不清。**当前证据：** 只确认研究 sorting algorithm。**核验：** 回听，不猜名称。 |

## Lecture 11 - Chain Replication

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P11-000502-zk-read | H-P | 00:05:02 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** ZooKeeper non-linearizable read 句缺词。**当前证据：** 任意 peer 可能未见 latest update。**核验：** 确认是前讲 recap，不扩展 guarantee。 |
| P11-001017-session-failure | H-P | 00:10:17-00:17:35 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** ZooKeeper 如何 decide client down、网络恢复动作未讲清。**当前证据：** old session 不存在，client retry/restart session。**核验：** 保留 session timeout 边界。 |
| P11-002309-ephemeral-deadlock | H-P | 00:23:09-00:25:26 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** EPHEMERAL 防死锁句缺词，Ready trick 被延期。**当前证据：** 只确认 abandoned lock 需随 session 清理。**核验：** 不用外部资料补 Ready trick。 |
| P11-004915-early-reply | H-P | 00:49:15-00:50:17 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** S1 early reply/update propagation 字幕不流畅。**当前证据：** update 继续向 S2/S3，随后 read 形成反例。**核验：** 连读下一 section 确认 linearizability failure。 |
| P11-005322-splitbrain-fifo | H-P | 00:53:32-00:58:20 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** split brain 破坏 total order 及 tail failure update 句缺词；TCP 仅 “probably”。**当前证据：** 需求是 reliable FIFO link、不丢 committed updates、client retry。**核验：** 区分 requirement 与实现猜测。 |
| P11-010419-new-tail | H-P | 01:04:19-01:04:34 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** S3 何时成为 tail 口述摇摆。**当前证据：** 追平前不能 serve client requests。**核验：** 确认 state transfer/barrier 条件。 |
| P11-011207-client-routing | H-P | 01:12:07 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** paper 对 routing 不 explicit；proxy 与 Lab 4 config download 是不同方案。**当前证据：** 无唯一实现。**核验：** 保留 classroom speculation。 |
| P11-011848-join-barrier | H-P | 01:18:48-01:19:52 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** 新 S3 按需读取还是 barrier 后服务未定。**当前证据：** 老师承认多种做法。**核验：** 不把学生首案写成 paper protocol。 |
| P11-012247-tree-propagation | H-P | 01:22:47 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** logarithmic delay 是学生提案动机。**当前证据：** 未获完整 correctness 验证。**核验：** 标为 proposal，不是 chain protocol 性质。 |
| P11-012442-cross-object | H-P | 01:24:42-01:31:51 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** 跨 objects/chains ordering、transaction/linearizability 保证未解决。**当前证据：** 老师明确留作未决。**核验：** 不擅自回答。 |
| P11-012928-config-number | H-T | 01:29:28-01:30:05 | [NOTES](/courses/mit-6824-s21/lectures/011/) | **问题：** configuration number 正式术语缺失。**当前证据：** 只确认 version/epoch-like number。**核验：** 回听术语。 |

## Lecture 12 - Cache Consistency: Frangipani

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P12-000046-deployment-name | M-T | 00:00:46-00:07:51 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** 未广泛使用的机构名、research lab 名称/人数缺失。**当前证据：** 只确认作者实验室及约数十至一百人场景。**核验：** 回听专名和数量限定。 |
| P12-001250-posix-boundary | H-P | 00:12:50-00:13:03 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** GFS “not straight POSIX/Unix compatible” 语法破碎。**当前证据：** 只支持非完整 Unix-compatible 对照。**核验：** 确认兼容性强度。 |
| P12-002207-lock-server | H-P | 00:22:07-00:22:28 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** fault-tolerant Paxos lock server 的机器布局被字幕打乱。**当前证据：** 只确定性质，不确定 arrangement。**核验：** 回看图/讲义。 |
| P12-002753-lease-expiry | H-P | 00:27:53-00:28:08 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** has/hasn't expired 疑漏否定。**当前证据：** lease 需 refresh；有效期内无需 reload。**核验：** 回听否定词。 |
| P12-003044-read-lock-release | H-P | 00:30:44-00:31:09 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** 老师忽略 read/write distinction，未给 clean read-lock release 的精确 I/O。**当前证据：** 无完整规则。**核验：** 保持未决，不从 paper 静默补入。 |
| P12-003328-revoke-state | H-P | 00:33:28-00:38:21 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** pending revoke state 名与 lock ordering key 含混。**当前证据：** operation 后 flush/release；固定顺序明确，按 inode number 仅 “I think”。**核验：** 回听状态名和 ordering key。 |
| P12-003959-wal-owner | H-P | 00:39:59-00:40:47 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** 字幕多次把 WAL 主体写成 Petal。**当前证据：** Frangipani log 放在 Petal 并更新 Petal blocks；Petal 自身日志属另一证据层。**核验：** 区分两层日志。 |
| P12-004513-log-atomicity | H-P | 00:45:13-00:45:21 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** paper 对 log-record atomicity 老师称非 100% 清楚。**当前证据：** checksum/commit-record 组合不能写成确定实现。**核验：** 保留 paper uncertainty。 |
| P12-004651-log-per-server | H-T | 00:46:51-00:48:36 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** `lock per server` 应为 `log per server`；block/inode number 又交叠。**当前证据：** many logs 对应 workstation/server，record 指 metadata block。**核验：** 回听术语和编号空间。 |
| P12-005038-block-size | H-N | 00:50:38-00:50:52 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** 学生称 512-byte block。**当前证据：** 老师只确认每个 affected block 有 record/update。**核验：** 不据此断言全系统统一 block size。 |
| P12-005542-data-write-order | H-P | 00:55:42-00:56:35 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** data blocks 发送时序为 “probably”，log capacity 数字损坏。**当前证据：** 不是精确 paper protocol/容量。**核验：** 分开核对时序与数字。 |
| P12-011408-replay-version | H-P | 01:14:08-01:15:59 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** log/version number 口误及 replay 比较边界。**当前证据：** 仅 block version `>` logged version 才 replay，`<=` 跳过。**核验：** 回看板书比较符。 |
| P12-012623-timing-margin | H-P | 01:26:23-01:27:27 | [NOTES](/courses/mit-6824-s21/lectures/012/) | **问题：** 学生“无解”被老师纠正；无 Petal timestamp support 时 margin 算法词缺失，late old write 会破坏 consistency。**当前证据：** 只确定 timing margin 方向。**核验：** 回听 margin 操作，不补算法。 |

## Lecture 13 - Distributed Transactions

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P13-000356-shard-failure | H-P | 00:03:56-00:04:04 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** failure 主语缺失。**当前证据：** transfer 中途某 shard failure，目标 both-or-neither。**核验：** 确认 failure point。 |
| P13-001423-transfer-numbers | H-N | 00:14:23-00:15:15 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** 板书先说 `9,10` 后改 `9,11`。**当前证据：** `9,11` 是 final state，`10,10` 是另一 serial order 的 audit output。**核验：** 回看数字与 output/state 区别。 |
| P13-001721-interleaving-board | H-E | 00:17:21-00:18:05 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** operation names 在字幕中省略。**当前证据：** output `10,11` 混合 transfer 前后 reads。**核验：** 回看 schedule，不补未见操作。 |
| P13-002124-occ-target | H-T | 00:21:24-00:21:40 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** 先说 linearizable 后改 serializable。**当前证据：** 本讲 isolation target 是 serializability。**核验：** 保留现场纠正。 |
| P13-003431-waitfor-edge | H-P | 00:34:31-00:34:38 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** 字幕第二条 edge 为 `T2 -> T2' -> T1`。**当前证据：** wait-for logic 支持 `T2' -> T1`。**核验：** 回看 graph 箭头。 |
| P13-004513-lock-point | H-P | 00:45:13-00:45:25 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** lock point “similar to commit/abort” 非形式等价。**当前证据：** read/write early-release restrictions 未展开。**核验：** 限定课堂 claim。 |
| P13-005530-prepared-abort | H-P | 00:55:30-00:58:37 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** YES 后不能 unilateral abort 的关键词缺失，restart 如何恢复 `Ly` 未展开。**当前证据：** durable prepared obligation 明确。**核验：** 区分 protocol invariant 与 lock-table implementation。 |
| P13-010244-abort-diagram | H-E | 01:02:44-01:03:19 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** PREPARE/ABORT 图中 A/B 指向含混。**当前证据：** 未收齐 YES 时 TC 可 abort，participant query 得 abort。**核验：** 回看图。 |
| P13-010936-lab4-analogy | H-P | 01:09:36-01:11:05 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** Lab 4/Raft group/2PC shard movement 句错位。**当前证据：** 只确认表面类比，不足以写 lab protocol。**核验：** 限定 lab concept。 |
| P13-011557-lock-y | H-E | 01:15:57-01:16:02 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** “lock on B required” 指代不清。**当前证据：** 根笔记按 B 上 `y` 的 `Ly`。**核验：** 回看板书/手势。 |
| P13-011916-presumed-commit | H-T | 01:19:16-01:20:35 | [NOTES](/courses/mit-6824-s21/lectures/013/) | **问题：** `presume commit` 可能是 presumed commit，但老师明确未讲该 variation；另有 “the injury is” 误识别。**当前证据：** recovery 必须 durable 区分 YES/NO。**核验：** 只确认名称和核心回答，不加入机制。 |

## Lecture 14 - Spanner

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P14-000718-raft-paxos | H-T | 00:07:18 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** 字幕为 “Raft writes”。**当前证据：** 此处以 Lab 3/Raft 类比 Spanner Paxos group。**核验：** 确认老师是否只说类比。 |
| P14-001202-external-consistency | H-P | 00:12:02 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** external consistency 被称为比 linearizability “stronger”。**当前证据：** 后文定义 transaction-level real-time order、称很相似。**核验：** 不创建未经定义的 hierarchy。 |
| P14-001536-transfer-direction | H-N | 00:15:36 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** `x +=1`/`x -=1` 口述冲突。**当前证据：** 完整例子为 x 减 1、y 加 1。**核验：** 回听/板书。 |
| P14-001659-read-path | H-P | 00:16:59-00:17:33 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** 字幕说 read-only，却把请求送 Paxos leader；“all locks replicated”也易误读。**当前证据：** 是 read-write transaction read phase，普通 lock table leader-local。**核验：** 确认 path 与 replicated prepared state 边界。 |
| P14-001904-replicated-tc | H-P | 00:19:04 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** replicated TC 是否消灭 2PC blocking。**当前证据：** 只提高 coordinator availability，不移除 locks/WAN/所有 partitions。**核验：** failure model 条件。 |
| P14-001950-shard-arrows | H-E | 00:19:50-00:23:10 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** x/y updates 似都发两 shards，commit/unlock 顺序被压缩。**当前证据：** 各 record 发相关 shard；decision 传播后收尾释放。**核验：** 回看箭头与解锁时点。 |
| P14-003125-snapshot-lanes | H-E | 00:31:25-00:37:11 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** T1/T2/T3 编号和 read 来源错乱；SI 被称 linearizability/serializability。**当前证据：** T3 read-only 跨 T2，从 T1/T2 各读一次；本段只证明 single snapshot serial order。**核验：** 回看时间线。 |
| P14-004001-safe-time | H-P | 00:40:01-00:43:47 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** “看到 timestamp >15 write” 是 safe-time 简化，clocks “only matter read-only” 又过宽。**当前证据：** Paxos/transaction-manager safe time 和 read-write TrueTime rules 未在此完整。**核验：** 保持课堂简化边界。 |
| P14-005501-wrong-ts-example | H-P | 00:55:01-00:59:04 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** transaction 编号修正且 future/past 说法交错。**当前证据：** commit 后开始的 read-only transaction 错拿 `@9`，即使 replica 有 `@10` 仍按自身 timestamp 选 version。**核验：** 确认 external-consistency counterexample。 |
| P14-010143-truetime-implementation | H-E | 01:01:43-01:03:39 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** TrueTime master/server/outlier implementation 多为 “maybe/guess”，paper table 编号未核。**当前证据：** 只确定 interval guarantee。**核验：** 不升级课堂推测。 |
| P14-010704-epsilon | H-N | 01:07:04 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** interval 宽度是 epsilon 还是 2 epsilon 未定。**当前证据：** 只保留 `[earliest, latest]` containment。**核验：** 回听/讲义符号。 |
| P14-010950-commit-wait-rule | H-C | 01:09:50-01:10:26 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** 老师明确说 notes 写错。**当前证据：** 修正规则为 `TS < now.earliest`。**核验：** 保留纠正前后及比较符。 |
| P14-011356-proof-numbering | H-E | 01:13:56-01:14:45 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** T2/T3 编号与 `[10,12]` 端点关系易误读。**当前证据：** 证明只依赖 finish-before-start 与 start rule 取 latest 12。**核验：** 回看板书，不推额外 tie rule。 |
| P14-011954-si-claim | H-P | 01:19:54-01:21:30 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** “SI gives serializability” 及 `100ms -> 10 tx/s` 可能过度推广。**当前证据：** 限于本讲 read-only snapshot/read-write timestamp order；数字仅单串流直觉。**核验：** 限定 workload 和 benchmark scope。 |
| P14-012419-lease-proof | H-P | 01:24:19-01:30:52 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** partitioned leader/lease 回答先不清后修正，TrueTime 与 data completeness 又混合。**当前证据：** `earliest>TS` 只证明时间过去；completeness 还需 safe time。**核验：** 分离 failure proof、commit wait、Paxos visibility。 |
| P14-013355-schema-change | H-C | 01:33:55-01:35:23 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** schema change 是 paper-only Q&A，future TS/stop impact 仅高层概括。**当前证据：** 教师明确主讲未覆盖 Section 4.2.3。**核验：** 不并入主讲，精确规则回到本地 paper。 |
| P14-013611-schema-reads | H-E | 01:36:11-01:36:33 | [NOTES](/courses/mit-6824-s21/lectures/014/) | **问题：** old reads routing 与 future point margin 句损坏。**当前证据：** earlier timestamp reads 可继续用 current/old versions；算法未知。**核验：** 不补 replica routing/margin。 |

## Lecture 15 - Optimistic Concurrency Control (FaRM)

### Part 1

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P15-000040-throughput | H-C | 00:00:40 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** 课堂约 1.4 亿 tx/s，讲义约 1 亿。**当前证据：** 配置可能不同。**核验：** 本地 FaRM paper Figure 7 的 benchmark/config，不能合并数字。 |
| P15-002841-rdma-queues | M-N | 00:28:41 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** “16 or 32 queues” 是示意。**当前证据：** 不是所有 NIC 固定规格。**核验：** 保留课堂 approximation。 |
| P15-003419-rdma-atomicity | H-P | 00:34:19 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** arbitrary-size one-sided write/atomic cache-line read-write 范围未清。**当前证据：** 后续 object lock 由 primary CPU atomic primitive。**核验：** 论文/NIC 规格与课堂边界。 |
| P15-003708-packet-rate | H-N | 00:37:08 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** packets/s 与时间单位损坏。**当前证据：** 约 5 microseconds latency 较可靠。**核验：** 回听吞吐换算。 |
| P15-004156-validate-reads | H-T | 00:41:56 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** read objects 被字幕写近似 write。**当前证据：** VALIDATE 检查此前 read objects 是否修改。**核验：** 原词。 |
| P15-005245-atomic-instruction | H-C | 00:52:45 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** 口述 test-and-set，讲义 compare-and-swap。**当前证据：** 共同 requirement 是对 version+lock 原子检查/设置。**核验：** paper 实际指令。 |
| P15-010106-failure-bound | H-P | 01:01:06 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** “handle f+1 failures” 疑错。**当前证据：** 紧接的一主一备支持 `$f+1$ replicas tolerate $f$ failures`。**核验：** 回听并核对 fault model。 |
| P15-011052-crash-role | H-P | 01:10:52 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** machine disappears 未区分 TC crash/primary crash。**当前证据：** 只统一指向 recovery protocol。**核验：** 与 Part 2 recovery 分支对读。 |
| P15-012227-workload | H-N | 01:22:27 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** TPC-C/TATP conflict 特征仅定性。**当前证据：** 无精确 benchmark 参数。**核验：** 本地 paper experiment。 |
| P15-012533-locality-api | H-P | 01:25:33-01:30:14 | [NOTES](/courses/mit-6824-s21/lectures/015/) | **问题：** locality hints API 老师未核；validation interleaving 回答不完整且字幕缺词。**当前证据：** 完整例子留到 Part 2。**核验：** paper API + Part 2，不把即时回答当最终结论。 |

### Part 2

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P16-000555-lock-record | H-P | 00:05:55 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** transcript 缺词。**当前证据：** primary 有 update 信息，但 LOCK record 不足以证明 committed。**核验：** 确认 LOCK 与 COMMIT-PRIMARY decision boundary。 |
| P16-001223-double-commit | H-P | 00:12:23-00:12:35 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** 关键否定词缺失。**当前证据：** 上下文结论为 T1/T2 不会都 commit。**核验：** 回听否定语义。 |
| P16-001532-blind-write | H-P | 00:15:32-00:17:56 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** blind-write schedule 多处缺词/重叠，教师未完成回答。**当前证据：** 问题保持未决。**核验：** 不用论文补成课堂结论。 |
| P16-002159-recovery-figure | H-E | 00:21:59-00:22:25 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** B2/P1/B1 指代与 record 位置需 Figure 4。**当前证据：** 至少一份 COMMIT-PRIMARY decision 加 surviving writes 可驱动允许每 shard 一副本失败的 recovery。**核验：** 回看图位置。 |
| P16-002240-commit-record-schema | H-P | 00:22:40 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** commit record 只听清 committed TID，schema 未展开。**当前证据：** 不足以补字段。**核验：** 限定 API/storage claim。 |
| P16-002615-ups | H-E | 00:26:15-00:26:23 | [NOTES](/courses/mit-6824-s21/lectures/016/) | **问题：** UPS 句缺词。**当前证据：** 只确认供电保护/NVRAM 是 hardware condition。**核验：** 回听原句，不扩展 guarantee。 |

## Lecture 16 - Big Data: Spark

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P17-000410-dataframe-rdd | M-P | 00:04:10-00:04:19 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** “DataFrame is RDD with explicit columns” 句不完整。**当前证据：** 只是课堂简化类比。**核验：** 不扩写内部实现。 |
| P17-000904-lineage-term | M-T | 00:09:04-00:09:08 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** `iterative graph` 疑为 lineage/dataflow graph。**当前证据：** 后续用语支持后者。**核验：** 回听术语。 |
| P17-001531-example-code | H-E | 00:15:31-00:16:27 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** 示例源码未归档，`collect`/count 混用。**当前证据：** 后文自纠为 `count`。**核验：** 回看屏幕代码与 action。 |
| P17-002128-narrow-definition | H-C | 00:21:28-00:23:26；01:05:28-01:10:51 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** paper parent-fan-out 定义、many-to-one、课堂“一对一”简写未统一。**当前证据：** co-partitioned join 提供反例方向。**核验：** 并列 paper 字面和无通信直觉，不擅自裁决。 |
| P17-002511-reliable-api | H-P | 00:25:11-00:25:23；00:33:21-00:34:06 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** `persist` 的 `RELIABLE` flag 带 “I think”。**当前证据：** 历史 API 名未核。**核验：** 指定 paper/对应版本 API。 |
| P17-003430-eviction | H-P | 00:34:30-00:34:48 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** unpersist/spill/eviction 回答为 “presume/might”。**当前证据：** 是现场推测。**核验：** 不写成确定 strategy。 |
| P17-003834-pagerank-graph | H-E | 00:38:34-00:41:14 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** 漏链接和 U1 tuple 自我纠正。**当前证据：** 最终边为 U1->{U1,U3}、U2->{U2,U3}、U3->{U1}。**核验：** 回看图。 |
| P17-004200-contribution-record | H-T | 00:42:00 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** 口述称 `triples`。**当前证据：** 示意实际是 `(URL, contribution)` records。**核验：** 确认数据 shape。 |
| P17-005017-persist-checkpoint | H-P | 00:50:17-00:50:34 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** persist/no-persist 快速自纠。**当前证据：** `links` 普通 persist，intermediate ranks 可周期 checkpoint。**核验：** 确认对象和频率只是示例。 |
| P17-005725-driver-failure | H-P | 00:57:25-00:57:37 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** scheduler 持有什么缺词。**当前证据：** 老师明确不知道 driver fault tolerance。**核验：** 保持未知边界。 |
| P17-011120-stage-term | H-P | 01:11:20-01:12:36 | [NOTES](/courses/mit-6824-s21/lectures/017/) | **问题：** partition/pipeline parallelism 与 stage 用语口语化。**当前证据：** 不支持每个 transformation 单独为 stage。**核验：** 回听术语范围。 |

## Lecture 17 - Memcached at Facebook

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P18-000045-request-scale | H-N | 00:00:45；00:08:03 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** billion/multiple billion 和 MySQL throughput 均是课堂数量级/估算。**当前证据：** 不可作精确 benchmark。**核验：** paper table/讲义与口述分层。 |
| P18-001436-cache-lock | H-P | 00:14:36-00:17:50 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** cache locking 缺词，eventual consistency 又被称 vague。**当前证据：** 无具体 lock strategy/形式模型。**核验：** 不扩写 guarantee。 |
| P18-002140-mcsqueal-name | H-T | 00:21:40；00:32:43 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** 字幕 `squeal`，讲义/paper 为 McSqueal。**当前证据：** 是同一组件。**核验：** 回听正式名称。 |
| P18-002719-async-invalidation | H-P | 00:27:19-00:29:50 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** 字幕似 writer waits invalidation，后文说明异步；update scheme 又有 stale overwrite race。**当前证据：** durable write DB、local delete、writer 不等 McSqueal。**核验：** 确认 write path 和 race。 |
| P18-003638-mcsqueal-process | H-C | 00:36:38 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** log transfer/apply 与 invalidation 都被称 Squeal。**当前证据：** process decomposition 不清。**核验：** 本地 paper Figure 6。 |
| P18-004036-ryw-failure | H-P | 00:40:36 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** server failure 下 read-your-own-writes 仅获推测回答。**当前证据：** 未有确定 path。**核验：** 保持 failure-model 未决。 |
| P18-004419-cluster-copies | H-N | 00:44:19-00:48:16 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** server 数量、cluster 图定义含混。**当前证据：** 只需“每 cluster hot-key copies 有限”。**核验：** 回看图并对照 paper Section 4。 |
| P18-005025-region-cluster | H-P | 00:50:25-00:51:46 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** “multiple regions” 疑口误；capacity 回答先否后限。**当前证据：** 讨论一个 region 内 multiple clusters；replication 不增 distinct capacity，regional pool 去重可释放容量。**核验：** 确认层级。 |
| P18-005839-backoff | H-T | 00:58:39 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** `binary backup` 疑为某种 backoff。**当前证据：** 算法未确认。**核验：** 回听，不写成 binary exponential backoff。 |
| P18-010230-gutter-delete | H-P | 01:02:30 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** “do not delete from Gutter” 的 protocol scope 不清。**当前证据：** 是课堂陈述。**核验：** 本地 paper Section 4.4。 |
| P18-011150-race-delete | H-P | 01:11:50-01:15:21 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** C2 `put` 后自纠为 `delete`；“go back in time”也被修正。**当前证据：** 正确 failure 是 v2 可长期不被观察。**核验：** 回看 Race 1/2 时序。 |
| P18-012053-cold-path | H-P | 01:20:53-01:24:06 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** `cold database`、仍去 primary、remote marker 清除路径均含混。**当前证据：** primary write 已完成，secondary propagation 未完成；追上后 marker 可清。**核验：** 确认组件和消息角色。 |
| P18-013137-remapping | H-E | 01:31:37 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** replacement/remapping 细节 paper 未充分描述。**当前证据：** consistent hashing 是老师推测。**核验：** 不升级为正式 protocol。 |
| P18-013350-gutter-lease | H-P | 01:33:46-01:34:20 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** lease 是否解决 Gutter concurrent fill corner case。**当前证据：** 老师明确不知道/推测。**核验：** 保持未决。 |
| P18-014034-write-scaling | H-E | 01:40:34 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** 按 shards 分配 regional primaries 是老师 speculation。**当前证据：** 不是 paper 已给方案。**核验：** 标清 evidence boundary。 |
| P18-014155-spanner-tps | H-N | 01:41:40-01:41:55 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** Spanner TPS 100/10 相互修正。**当前证据：** 即席回忆。**核验：** 不作为 paper fact。 |
| P18-014309-permanent-staleness | H-T | 01:43:09 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** `permanent business`。**当前证据：** 上下文明确 permanent staleness。**核验：** 回听术语。 |
| P18-NA-lecture-note-numbers | H-C | 未单独口述 | [NOTES](/courses/mit-6824-s21/lectures/018/) | **问题：** 1% miss、50x DB spike、百万级 cache throughput/10x speed 来自讲义而非对应课堂段落。**当前证据：** 已隔离材料层。**核验：** 任何数字引用必须标 lecture-note/paper，不冒充 speech measurement。 |

## Lecture 18 - Fork Consistency: SUNDR

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P19-001026-client-trust | H-P | 00:10:26-00:10:30 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** “clients are not trusted” 易过度推广。**当前证据：** server 可与 compromised users 串通，但 honest users' signatures 不可伪造。**核验：** 明确 adversary/failure model。 |
| P19-001321-event-year | M-N | 00:13:21-00:13:29 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** Ubuntu/Canonical event 是 2018 或 2019，老师不确定。**当前证据：** 无确定年份。**核验：** 保持口述不确定，不外查解决。 |
| P19-002133-signature-role | H-T | 00:21:33-00:21:43 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** signature/public key 措辞混合。**当前证据：** A private key 签、A public key 验。**核验：** 回听课堂角色。 |
| P19-003024-screen-gap | M-E | 00:30:24-00:34:38 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** 网络/屏幕共享中断造成重复。**当前证据：** 恢复后重讲，不能假设中断处有缺失机制。**核验：** 对齐重复段。 |
| P19-003829-own-last-op | H-P | 00:38:29-00:38:36 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** 主语混乱。**当前证据：** C 检查自己的 previous/last operation，不是 A。**核验：** 回听 client identity。 |
| P19-004941-readonly-client | H-T | 00:49:41-00:50:14 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** read-only client 被说成 server。**当前证据：** 语境是只 fetch 的 client。**核验：** 回听角色。 |
| P19-005543-fetch-overload | H-P | 00:55:43-00:57:36 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** `fetch` 同时指 file read 与 log download。**当前证据：** 老师承认一词两用。**核验：** 在每个 protocol step 明确对象。 |
| P19-010413-old-filesystem | H-P | 01:04:13-01:06:14 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** 字幕说 constructs using A/B，与 server 返回 old prefix 冲突。**当前证据：** own-last-entry/hash-prefix check 可拒绝插入。**核验：** 回看 fork schedule。 |
| P19-011317-zoobar | M-T | 01:13:17-01:13:21 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** Zoobar 被识别为 ZooKeeper。**当前证据：** `auth.py`/`bank.py` 场景支持 Zoobar。**核验：** 回听名称。 |
| P19-012025-version-structure | H-C | 01:20:25-01:20:33 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** version handle/vector/structure 混用。**当前证据：** 本地 paper 结构为 signed version structure 含 i-handle 与 version vector。**核验：** 区分 speech shorthand 与 paper data structure。 |
| P19-012124-total-order | H-C | 01:21:24-01:22:12 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** “B contains A” 只是口语直觉。**当前证据：** total-order 判据来自 assigned paper Section 3.3。**核验：** 不冒充课堂形式定义。 |
| P19-012336-merkle-btree | H-C | 01:23:36-01:24:11 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** 课堂称 Merkle tree，paper 为 child-hash B+-tree i-table。**当前证据：** 形状与完整性机制层级不同。**核验：** 保留材料差异。 |
| P19-012808-cannot-merge | H-P | 01:28:08-01:28:50 | [NOTES](/courses/mit-6824-s21/lectures/019/) | **问题：** transcript 漏 `cannot`。**当前证据：** 全文结论为 divergent forks cannot merge undetectably。**核验：** 回听否定语义/invariant。 |

## Lecture 19 - Peer-to-Peer: Bitcoin

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P20-000204-pseudonymous | M-T | 00:02:04 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** `pseudo-anonymous`。**当前证据：** 语境指作者 Satoshi 使用化名，不是交易匿名性。**核验：** 回听 pseudonymous。 |
| P20-000829-hash-name | H-C | 00:08:29 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** 字幕 `sha1`，讲义只写 `hash`。**当前证据：** 本讲不依赖具体算法。**核验：** 不用外部知识替课堂定算法。 |
| P20-001349-double-spender | H-T | 00:13:49 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** Z/Y 主体自我纠正。**当前证据：** double spender 是 Y。**核验：** 回看板书。 |
| P20-002533-open-majority | H-P | 00:25:33 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** `undefined` 识别不清。**当前证据：** 开放系统中 membership/majority 无法直接定义。**核验：** 回听 protocol motivation。 |
| P20-002753-cpu-month | H-N | 00:27:53 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** “约一个 CPU 月”与全网约十分钟混用。**当前证据：** 是直觉简化，不是每块固定成本。**核验：** 限定单位和并行语境。 |
| P20-003544-block-size | H-N | 00:35:44-00:38:25 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** 1 MB、node/miner counts 均为课堂近似。**当前证据：** 非协议常量/安全条件。**核验：** 不作精确上限或 invariant。 |
| P20-004222-timestamp-rule | H-P | 00:42:22 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** timestamp acceptance window 口述不完整，老师不记得。**当前证据：** 不支持“十分钟窗口”。**核验：** 保持未知。 |
| P20-004750-difficulty-period | H-N | 00:47:50 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** difficulty adjustment period 数字损坏。**当前证据：** 只支持周期性、共同历史决定、非每块。**核验：** 回听数字。 |
| P20-004916-node-majority | H-P | 00:49:16 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** “多数节点正确”可能被误作安全条件。**当前证据：** 本讲安全权重主要按算力；此句只属 compatibility 高层回答。**核验：** 区分 node count 与 work。 |
| P20-005631-probabilistic-finality | H-P | 00:56:31 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** impossible/unlikely 摇摆。**当前证据：** 随 confirmation depth 概率降低，不是绝对不可能。**核验：** 回听概率措辞。 |
| P20-010933-throughput | H-N | 01:09:33 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** “thousands/s” 与讲义区块大小限制主旨冲突。**当前证据：** 根笔记只保留结构公式。**核验：** 回听数字/单位，不采纳未核量级。 |
| P20-011100-soft-fork | H-T | 01:11:00 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** `soft work` 应为 soft fork，但兼容性定义不严。**当前证据：** 只有高层说明。**核验：** 术语与课堂 claim 强度。 |
| P20-011321-hard-fork | H-P | 01:13:21 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** “double spend” 混合链内有效性与跨链资产复制。**当前证据：** 只确定共同前缀后形成两套 state。**核验：** 分离两种语义。 |
| P20-011759-pos-randomness | H-P | 01:17:59 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** 字幕称随机化让 attacker win。**当前证据：** 语义应为降低操纵/预测选择的能力。**核验：** 回听否定/目的。 |
| P20-012047-utxo-term | H-T | 01:20:47 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** `last one` 指代含混。**当前证据：** 对应 current unspent/latest valid state，但课堂未说 UTXO set。**核验：** 不把概念标签冒充引语。 |
| P20-012211-pruning | H-E | 01:22:11 | [NOTES](/courses/mit-6824-s21/lectures/020/) | **问题：** “不足以验证交易”所指数据结构不清。**当前证据：** 可能区分 hash commitment 与 verifiable history。**核验：** 回看 paper-question context，不补 Merkle pruning 算法。 |

## Lecture 20 - Blockstack

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P21-000118-signed-logs | M-T | 00:01:18 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `logs and signing/sign log`。**当前证据：** 课程顺序支持 SUNDR signed logs。**核验：** 回听，不补协议性质。 |
| P21-000220-project-names | M-T | 00:02:20 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** 项目名不稳。**当前证据：** transcript+讲义共同支持 Keybase、Solid、early P2P apps。**核验：** 回听专名。 |
| P21-001904-key-loss | H-P | 00:19:04 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** key-management 句不完整。**当前证据：** 丢 private key 无法恢复数据；key 被盗则攻击者获访问。**核验：** 确认 failure/threat model。 |
| P21-002508-pki-examples | M-C | 00:25:08-00:25:23 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** DNSSEC/Web cert/Kerberos 被并列为 PKI。**当前证据：** 根笔记只保留宽泛 infrastructure 对照。**核验：** 不升级为严格分类。 |
| P21-003044-blockchain-name | M-T | 00:30:44 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `Bitcoin blockstack`。**当前证据：** 上下文明确 Bitcoin blockchain。**核验：** 回听。 |
| P21-003716-namecoin-fees | H-P | 00:37:16-00:37:39 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** Namecoin fee/rules 口述不完整。**当前证据：** 只确定独立 naming chain、存在费用/额外规则。**核验：** 不补 wire/economic details。 |
| P21-003932-fork-finality | H-P | 00:39:32 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `cannot be forked off anymore` 过强。**当前证据：** 更多 confirmations 只降低 rollback 概率。**核验：** 回听概率措辞。 |
| P21-004355-op-return | H-T | 00:43:55 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `OP_RETRUN`。**当前证据：** 下一段及根笔记用 `OP_RETURN`。**核验：** 字段名，不补 byte limit。 |
| P21-004544-virtualchain | H-T | 00:45:44 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `virtual chain layer` 与系统名 `virtualchain`。**当前证据：** 一个是概念口述、一个是正式拼写。**核验：** 保留两层。 |
| P21-004857-zonefile-size | H-N | 00:48:57 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** zonefile 几 KB 数字不稳。**当前证据：** 只支持 small/widely replicated。**核验：** 回听数字。 |
| P21-005017-hash-latest | H-P | 00:50:17-00:50:45 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** immutable hash 被说成保证 latest。**当前证据：** hash 只验证当前 consensus record 承诺的具体 version，freshness 来自 naming state。**核验：** 明确 integrity/freshness boundary。 |
| P21-005538-signing-key | H-T | 00:55:38 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** 字幕称 public key 签名。**当前证据：** private key 签、public key 验。**核验：** 回听角色。 |
| P21-005618-zonefile-uri | H-P | 00:56:18-00:59:29 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** URI count 老师不知道，registration fields 断裂。**当前证据：** 只听清 actual name + zonefile hash，owner key 来自讲义补充。**核验：** 分离 speech/API fields。 |
| P21-010002-front-running | H-T | 01:00:02-01:01:22 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** `go from front problem` 与 `burn` 易混。**当前证据：** 术语是 front-running；burn into chain 指 commitment 稳定，不等同 burn-address fee。**核验：** 回听术语/动作。 |
| P21-010936-group-keys | H-P | 01:09:36-01:09:47 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** group key/name 句破碎。**当前证据：** 只确定 group representation/membership complex。**核验：** 不补 protocol。 |
| P21-011151-access-control | H-E | 01:11:51-01:13:24 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** 实际 access-control implementation 老师多次不确定。**当前证据：** per-recipient encryption/lockbox 只是可行设计。**核验：** 不标为系统已实现。 |
| P21-011934-chain-migration | H-P | 01:19:34-01:20:45 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** “easy migration” 及 name history 是否含 zonefile 内容均不确定。**当前证据：** 不能排除 coordination/fork/state-transfer 风险；history 可能仅 metadata。**核验：** 保持 paper-claim/implementation 边界。 |
| P21-012412-miner-concentration | H-C | 01:24:12-01:24:25 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** 字幕泛称 miner pools，reading evidence 是 Namecoin 单一 miner 曾超 51%。**当前证据：** 只可保留集中算力风险。**核验：** 区分课堂主语与 reading。 |
| P21-012844-pruning-spv | H-E | 01:28:44-01:29:07 | [NOTES](/courses/mit-6824-s21/lectures/021/) | **问题：** last transaction/current state/block headers 连续混用。**当前证据：** 不支持 header-only node 完整验证/重建 state。**核验：** 回看问答，不补 pruning/SPV。 |

## Lecture 21 - Project Presentations

| ID | 级别 | 时间 | 来源 | 复核内容 |
| --- | --- | --- | --- | --- |
| P22-000403-voting-shares | H-N | 00:04:03-00:05:55 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** `n part`/share-sum 句损坏。**当前证据：** 随后 k-1/k 支持 n shares；模型只处理 well-behaved/fail-stop。**核验：** 回听公式和 failure assumption，不补 Shamir。 |
| P22-001044-sys-name | M-T | 00:10:44 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** 系统名仅字幕 `Sys`。**当前证据：** 无 slides 核拼写。**核验：** 保留 provisional name。 |
| P22-001220-share-proxies | H-T | 00:12:20-00:13:43 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** signature/share、properties/proxies 误识别。**当前证据：** secret sharing/proxies 语境明确。**核验：** 回听术语。 |
| P22-001947-sys-throughput | H-N | 00:19:47-00:20:03 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** 4-core throughput 和 20-way extrapolation 带 “I think/probably”。**当前证据：** 近似且同 data-center。**核验：** 不作实测 benchmark。 |
| P22-002031-finite-field | H-T | 00:20:31-00:20:35 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** finite/file library。**当前证据：** 上下文支持 finite-field library，具体库未知。**核验：** 回听名称。 |
| P22-002134-bukadocs-name | M-T | 00:21:34 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** `BukaDocs` 大小写仅来自字幕。**当前证据：** 无 slide。**核验：** 保留 provisional spelling。 |
| P22-002406-lseq-key | H-E | 00:24:06-00:24:15 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** `7 2` 的 LSEQ key notation 未展示。**当前证据：** `(7,2)` 仅可读重述。**核验：** 不声称逐字符还原。 |
| P22-003430-eggscrambler-crypto | H-P | 00:34:30-00:36:57 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** decryption order、encrypt phase、malicious detection、agreed state 多处缺词。**当前证据：** 每消息被所有 participants 各加密一次；不支持具体 detection 或 linearizability。**核验：** 回听机制边界。 |
| P22-004221-byzantine-answer | H-P | 00:42:21-00:43:49 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** Byzantine participant/detection 回答严重损坏。**当前证据：** 团队假设 honest clients，对 malicious failure 是否显式可检出无把握。**核验：** 明确 threat model，不补 guarantee。 |
| P22-005110-9p-interface | H-T | 00:51:10 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** `[slice] this 9P interface` 可能是 splice/interpose。**当前证据：** 含义是截获并复制 uniform-interface operations。**核验：** 回听 verb/API。 |
| P22-005140-named-service | H-T | 00:51:40 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** config service 名仅字幕 `named`。**当前证据：** 无 slide 核验。**核验：** 名称/来源保持 provisional。 |
| P22-005349-reconfig-demo | H-E | 00:53:49-00:54:06 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** crash 后第二次 write terminal output 不完整。**当前证据：** 只有 presenter 的 successful reconfiguration 总结。**核验：** 不把缺失 output 当实验数据。 |
| P22-010235-proof-notation | H-E | 01:02:35-01:02:59 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** separation-logic slide notation 未归档。**当前证据：** 公式仅按口述重建。**核验：** 不声称逐字符恢复。 |
| P22-010410-paxos-relation | H-P | 01:04:10 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** Single-decree/Multi-Paxos 关系词缺失。**当前证据：** 只支持 one decision vs replicated log。**核验：** 回听关系强度。 |
| P22-011055-dfs-name | M-T | 01:10:55-01:11:00 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** team/system name 漏失。**当前证据：** 不从 `PP2` 猜，暂称 simple distributed file system。**核验：** 若无本地 slide 则保持缺失。 |
| P22-011229-posix-consistency | H-C | 01:12:29-01:14:18 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** team 称 POSIX consistency，观众说性质略强；`Write` buffer/append semantics 又自纠。**当前证据：** 可确认 whole-file-copy flush。**核验：** 明确 consistency target/API，不用标准外推。 |
| P22-012231-replica-count | H-N | 01:22:31-01:27:00 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** “two replicas/copies” 是否计 primary 有歧义。**当前证据：** demo 是 worker 0 到 worker 1/2 copies。**核验：** 统一副本计数口径前先回看 demo。 |
| P22-013005-pinguino-partition | H-P | 01:30:05-01:32:02 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** 缺否定词；room ownership、replica movement、newer replica 回答互有张力。**当前证据：** coordinator changes 暂不能处理，partition safety 未闭合。**核验：** 不整理成确定 failover/merge algorithm。 |
| P22-013312-voting-validation | H-P | 01:33:12-01:34:56 | [NOTES](/courses/mit-6824-s21/lectures/022/) | **问题：** inconsistent counters attack 与 public-ledger/ZK statement 损坏。**当前证据：** 问题是不同 counters 收到不一致内容且缺 validation；方案仅指向 well-formedness。**核验：** 不补 proof protocol。 |

## 完成条件

- [ ] 22 个媒体 part 均至少有一条来源审计记录，或明确记录为“无实质未决项”；本版应覆盖 `P01` 至 `P22`。
- [ ] 21 个官方 Lecture 标题均存在，Lecture 15 同时含 Part 1 与 Part 2。
- [ ] 所有表格项都有唯一 ID、优先级/分类、时间、可解析的本地 `NOTES.md` 链接、问题、当前证据、核验目标。
- [ ] 所有 `H` 项覆盖 protocol conditions、failure model、invariants、paper experiment numbers、code/API、lab concepts。
- [ ] 本地链接全部解析到现存文件；没有链接到未归档画面或外部网页冒充证据。
- [ ] 唯一 ID 无重复；顶部总数、优先级数、分类数与表格行一致。
- [ ] 文件可用 strict UTF-8 解码，且未修改任何 source notes。
