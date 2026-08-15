---
uid: mit-6824-s21-resource-reading-18
type: course
document_type: resource
resource_kind: reading
resource_order: 118
course: mit-6824-s21
title: Lecture 18 阅读指南：Fork Consistency - SUNDR
description: Lecture 18 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 18 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-18/"
toc: true
official_lecture_number: 18
math: true
---

## 1. 来源、精确范围与证据边界

- 指定论文是 **Secure Untrusted Data Repository (SUNDR, 2004)**，阅读范围为 **Abstract、§1、§2、§3 至 §3.4 结束**。也就是读完 §3.4.3 Example，在 §4 Discussion 开始前停止。
- **不在指定范围内：** §4 Discussion、§5 File system implementation、§6 Block store implementation、§7 Performance、§8 Related work、§9 Conclusion。本文不引用这些部分的实现细节、性能数字或实验结论。
- 本指南以 assigned range 为 protocol、invariant、consistency 与 security claims 的主来源；FAQ 只用于澄清 integrity/confidentiality、i-handle cost、out-of-band communication 与现实影响；课堂连接以 Lecture 18 `NOTES.md` 和官方讲义为证据。
- 论文在 Abstract 提到 implementation 与 NFS performance，但支撑材料位于 assigned range 之外。因此本指南只把它标为摘要中的作者主张，不展开或验证 evaluation。
- §3.1 的完整 signed history 是故意低效的 **straw-man**，不是最终 SUNDR implementation；§3.3 先压缩 history，§3.4 再放松全局串行。
- SUNDR 的目标是 integrity/consistency violation detection，不是 confidentiality 或 availability。恶意 server 仍能拒绝服务、隐藏更新或让 clients 永久停留在不同 forks。

资源：

- [Lecture 18 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-18.md)
- [SUNDR 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/li-sundr.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/sundr-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/18-q-sundr.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-sundr.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-18-fork-consistency-sundr)
- [Lecture 18 NOTES](/courses/mit-6824-s21/lectures/019/)
- [Lecture 18 transcript](/assets/courses/mit-6824-s21/lectures/019/transcript.txt)
- [Lecture 18 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=19)

## 2. Setting、trust boundary 与目标

SUNDR 提供 remote network file system interface。Application system calls 被 client 转换为两种 high-level operations：

- **fetch**：读取文件内容，或验证 local cached copy；
- **modify**：让新的 filesystem state 对其他 users 可见。

每个 filesystem 有 superuser public/private signature key pair；server 只需 public key，private key 应保留在 trusted machine。每个 user 也有 signature key，`.sundr.users` 和 `.sundr.group` 由 superuser 管理 identities/groups。User 在 client 间迁移时除了 private key，还要带上其最后 operation/version；否则新 client 不知道该 user 已经承诺过什么 history。

### Threat model

假设 attacker 可完全控制 server，并可能与 compromised users 合谋：它可返回旧数据、漏掉数据、重排/分叉 views、拒绝 RPC。安全推理依赖：

1. Honest users 的 private keys 未泄露，digital signatures 不可伪造；
2. Hash function collision resistant；
3. Honest client implementation 按 protocol 验证 signatures、permissions、version/history relations；
4. User 知道自己最后一次 operation/version。

Compromised user 能合法修改其权限允许的 files；SUNDR 不会把一个有权限且正确签名的恶意 write 判成 unauthorized。它保护的是 server 无法伪造 honest authorization，以及 honest users 的 histories 仍满足 fork property。

### Security goal boundary

- **提供：** 检测 unauthorized modifications；诚实 server 下实现 fetch-modify consistency；恶意 server 下实现 fork consistency。
- **不提供：** Confidentiality；server availability；自动 fork resolution；对 stolen user key 的保护；不经通信就得知其他 offline user 是否已经更新。

## 3. 两种 consistency 定义与核心保证

### 3.1 Fetch-modify consistency

当 server honest 时，一次 fetch 应准确反映所有 happens-before 它的 authorized modifications。论文脚注允许的 happens-before 是保持以下关系的 irreflexive partial order：

- non-concurrent operations 的 real-time order；
- 同一 client 的 operations order；
- 同一 file 上 modify 与其他 operation 的 order。

这是 paper 定义的 filesystem-level consistency，不应直接改写成“所有 Unix system calls linearizable”；high-level system calls 如何映射到 fetch/modify 本身也是 security proof 的前提。

### 3.2 Fork consistency

恶意 server 可让 A 的 fetch 看不到 B 的 modify，但一旦 A 接受了 B 的某次 modification，至少到 B 做出该 modification 为止，两者必须共享同一 fetch-modify-consistent history。直观上：

```text
common signed prefix
       /          \
  A's future    B's future
```

Server 可以 fork，之后必须一直维护互不兼容的 worlds；它不能让两个 honest users 在不知道 attack 的情况下重新看到对方 fork 后的 operations。

### 3.3 No-undetectable-merge invariant

若 honest users 签下 incompatible histories/versions，则以后任何能同时容纳两边 last operation 的 state 都会暴露 inconsistency。保证不是“server 无法分叉”，而是：

```text
once honest histories diverge
    -> each user's next operation extends its own last commitment
    -> signatures prevent rewriting old commitments
    -> branches cannot merge without a failed consistency check
```

论文声称在 signatures 与 collision-resistant hash 假设下已形式化证明该 property；证明引用在其他工作中，assigned section 给的是 protocol 与直观论证。

## 4. §3.1 Straw-man：完整 signed operation history

Straw-man server 保存每一次 fetch/modify 的完整 ordered list。每条 operation 由执行 user 签名，signature 不只覆盖 operation，还覆盖所有 preceding history。所有 operations 通过 server 上一个 untrusted global lock 串行化。

### Client protocol

1. Acquire global lock。
2. Download entire operation history。
3. 验证每个 user 的 most recent signature，并确认自己的 previous operation 在 history 中。
4. Replay history，构造 local filesystem state。
5. 对每个 modify 按 user/group/owner 检查 authorization。
6. 执行当前 fetch/modify，append 新 record，签署新的完整 history commitment。
7. Upload history，release lock。

可把第 $i$ 个 signed record 抽象为：

$$e_i=(op_i,u_i,H(e_0\Vert\cdots\Vert e_{i-1}),Sig_{u_i}(op_i,H(prefix_{i-1}))).$$

Server 若删除或改写 prefix 中任何 entry，后续 signature 覆盖的 hash 就不再匹配。它仍可向某 client 隐藏整个 suffix，使该 client 在旧 prefix 上签新 operation；这会制造 fork，而不是伪造合法 single history。

### 为什么检查 own previous operation

只验证他人 signatures 不足以防 rollback。Client 必须确认自己上一次签过的 record 存在；否则 server 可反复给该 user 一条更旧、仍拥有有效 signatures 的 prefix。Own-last-operation check 让每个 user 的 accepted history 单调延伸。

### 代价

- 每个 operation 下载并上传不断增长的 full history；
- Replay 和 verification cost 随历史增长；
- Global lock 串行所有 users，包括不相干 files；
- State/operation data 全部进入历史，storage/bandwidth 不实际。

这些缺点正是 §3.3 和 §3.4 分别要解决的两个问题。

## 5. 为什么 fetch 也必须被签名和记录

假设真实 history 已经是：

```text
P -> A modifies auth.py -> B modifies bank.py
```

且 B 的新版依赖 A 的新版。若只记录 modify，不记录 fetch，server 可对同一 client C 做：

1. C fetch `auth.py` 时只给 prefix `P`，于是 C 接受旧认证代码；
2. C 随后 fetch `bank.py` 时给完整 A/B history，于是 C 接受新资金代码。

两次响应各自都是合法 signed prefix；由于第一次 fetch 没留下 record，第二条 history 不必包含“C 已在旧 prefix 上读过 auth.py”的证据。Server 因而可把早已完成的 A/B updates伪装成发生在两次 reads 之间，破坏 fetch-modify consistency。

若第一次 fetch 被记录：

```text
P -> C fetches auth.py
```

C 以后要求 history 包含该 last operation。原 A/B branch 不含 C fetch；也不能把 C fetch 插到 A/B signatures 前面，因为那会改变 preceding-history hashes。Server 只能维持：

```text
P -> C fetches auth.py -> ...
P -> A modifies auth.py -> B modifies bank.py -> ...
```

这两支不可无痕 merge。Fetch record 的作用不是改变 file contents，而是把“client 已观察哪个 history prefix”变成 signed security state。

## 6. §3.2 保证上限与加强方式

### 6.1 为什么 fork consistency 已是无在线可信方时的上限

设 A 上线修改 file 后离线，B 之后上线读取。若 B 不知道 A 是否访问过系统，server 丢弃 A update 与“A 从未更新”对 B 来说不可区分。Pure client-server protocol 无法强迫 server 展示 B 没有独立证据知道存在的 operation。

Fork consistency 把不可检测能力限制为这种 concealment/fork：A 与 B 一旦交换后续 operation evidence，就能检测 divergence。

### 6.2 Trusted consistency server

若把少量 consistency state 放到 trusted online machine，可直接得到 fetch-modify consistency，但 trusted machine 的 connectivity/availability 可能比 untrusted storage 差。这是 trust 与 availability 的交换。

### 6.3 Timestamp box

一个 trusted box 每 5 秒通过 SUNDR 更新它唯一可写的 file。看到该 update 的 users 知道自己与其他同样看到更新的 users 最多只在最近窗口内被隔离。多个 boxes 可用 Byzantine fault tolerance 复制。

它不是 trusted wall-clock field；关键是一个持有可信 signing key 的 participant 周期性制造共同 history evidence。看不到 update 时仍无法区分 box failure、network partition 与 malicious suppression。

### 6.4 Client-to-client communication

Online clients 可记录 network addresses 并交换 latest-operation information；若 server 不能同时破坏 direct communication，就不能在 clients 已相互知道后继续无声 fork。更保守的 client 可在 communication outage 时暂停 file access，但这用 availability 换 consistency。

## 7. §3.3 Serialized SUNDR：由历史转为 signed snapshots

Serialized SUNDR 保留 global lock，先只解决 full-history bandwidth/storage 问题。核心是让 user 签署一个能承诺完整 filesystem snapshot 及其跨-user dependencies 的小结构。

### 7.1 Content-addressed blocks

Persistent structures 由 20-byte SHA-1 hashes 命名。Client 按 hash 请求 block 并重新 hash 验证内容；相同 blocks 只需存一份。这里依赖的是论文当时采用的 collision-resistance 假设，不能把它写成无条件保证。

### 7.2 Principal、i-table 与 i-handle

File identity 是 `<principal, i-number>`：principal 是可写该 file 的 user/group。

- User i-table：`i-number -> i-hash`；i-hash 是 inode hash。
- Inode：包含 file data/indirect block hashes。
- Group i-table：`group i-number -> <user, user i-number>`，多一层 indirection，让同一 user 连续写 group-owned file 时不必每次更新 group i-handle。
- I-table 是 B+-tree，internal nodes 保存 children hashes；root hash 是 **i-handle**。

给定 i-handle，client 可逐层 fetch/hash-verify 某 principal 的任意 file block。一个 block 变化只需更新到 root 的 hash path，而不必重新发送所有 data。

### 7.3 Version structure 与 version vector

User $u$ 签署的 version structure 包含：

- $u$ 的 i-handle；
- 可选的、$u$ 所属 groups 的 i-handles；
- 每个 user/group principal 的 version number；
- $u$ 的 signature。

所有 principals 的 latest structures 构成 **version structure list (VSL)**。定义：

$$x\le y\iff\forall p,\ x[p]\le y[p].$$

Serialized protocol 要求 VSL entries 与即将提交的新 structure 在该偏序下 total ordered。若 $x\nleq y$ 且 $y\nleq x$，两 structures incompatible，是 fork evidence。

## 8. Serialized protocol 与安全不变量

User $u$ 执行 operation 时：

1. Acquire global lock，下载 current VSL。
2. Fetch 时复制 $u$ previous i-handle；modify 时计算 $u$ 及受影响 groups 的新 i-handles。
3. 对每个 principal $p$，从 VSL 中 $p$ 的 latest entry $y_p$ 设置新 structure $z[p]=y_p[p]$。
4. 因 $z$ 总包含 $u$ i-handle，令 $z[u]=z[u]+1$；包含某 group 新 i-handle 时也 increment 对应 group version。
5. 确认 VSL 包含 $u$ 的 previous version structure，且 VSL 加 $z$ 在 $\le$ 下 total ordered。
6. Sign $z$，COMMIT；server 更新 VSL，retire 被替代的 i-handles。

### Cross-principal dependency invariant

一个 user 的 version vector 记录其签名 snapshot 看见了其他 principals 的哪些 versions。若 B 的 structure 含 `A:1`，server 不能给 client B's state 却只给 A version 0 而仍通过 consistency checks。

Fork attack 会让 users 签出 incomparable structures，例如 A 新 structure 增加 `A` version 而 B 被隐藏该更新后增加 `B` version。由于以后各自必须包含 own previous structure，双方不能再产生一条同时兼容两边的 version chain。

### Change log optimization

I-handle 除 hash-tree root 外可带小 change log，把多次 operations 的 rehash cost amortize；其他 clients 验证未变 cached file 时可应用 changes，而不必 fetch 全部 i-table blocks。这是 §3.3 明确描述的 protocol optimization。

## 9. §3.4 Concurrent SUNDR：update certificate、VSL 与 PVL

Serialized SUNDR 的 global lock 让每个 client 等待前一 client 签完 version vector。Concurrent SUNDR 的目标是让 non-conflicting operations 并行；只有读正在被写的 file 等真实 conflict 才等待。

### 9.1 Update certificate

Client 在收到 VSL 前先签署 update certificate，预声明下一次 fetch/modify。它包含：

- User 的 next version number；
- Previous VSL entry 的 hash `H(y_u)`；
- 可能为空的 modification delta list。

Delta 可设置 user file 的 i-hash、设置 group file 的 user/i-number target、增删 directory entry、预分配 group i-number range。Fetch 也发送 UPDATE RPC，但 delta list 为空；RPC 名指更新 consistency metadata，不表示 fetch 改 file content。

### 9.2 Pending version list (PVL)

Server 回复 VSL 以及尚未进入 VSL 的 pending operations。每个 PVL entry 是：

```text
<signed update certificate, unsigned forthcoming version structure>
```

诚实 server 按 UPDATE RPC arrival order 建立 happens-before。Client 用 VSL 和 PVL 计算自己的新 vector，并检查 VSL、PVL 中 unsigned structures 与自己 structure 可 total order。恶意 server 若给不同 clients 不可兼容的 VSL/PVL，就形成可检测 fork。

### 9.3 Read-after-write conflict

若 client fetch 的 file 在 PVL 中有 pending modification，client 仍可先 commit 自己的 version structure，但必须等待相关 writer structure 进入 VSL，再把 fetch result 返回 application。这样 fetch 不会跳过协议已排在它之前的 pending write。

### 9.4 Write-after-write conflict

若 client 与 PVL 都修改同一 group i-table，client 必须把未反映在 latest group structure 中的 pending deltas 合入新 i-handle。仅合 data 不够：恶意 server 可能提前从 PVL 删除尚未 commit 的 entry，使后续 client 把该 update “洗白”为已合法合并。

因此新 version structure 还记录 current PVL references：每个 pending entry 的 user、version 与 expected structure hash（省略 i-handles）。其他 clients 若发现 referenced pending entry 消失，可检测 server misbehavior。

### 9.5 §3.4.3 example

Users $u_1$、$u_2$ 并发在 group-writable `/sundr/tmp` 创建 X、Y。若 server order 是 $u_1$ 后 $u_2$，$u_2$ 的 PVL 包含两者 updates；$u_2$ 应先把 X directory delta 合入，再应用自己的 Y delta，并在 signed structure 中承诺 $u_1$ forthcoming structure。最终 directory 同时含 X/Y；若 server 悄悄丢掉 $u_1$ pending certificate，reference 会迫使看到错误 PVL 的 client 与 $u_1/u_2$ 至少一方 fork。

## 10. Failure、安全、consistency 与 tradeoffs

| 机制/选择 | 得到什么 | 代价或边界 |
| --- | --- | --- |
| Digital signatures | Server 不能伪造 honest user's authorized operation | Stolen/compromised user key 的 writes 看起来合法 |
| Hash-linked history | 中间 operation 不能无痕删改 | Server 仍可返回旧 prefix 或分叉 suffix |
| Logged fetch | 观察过的 prefix 成为 commitment | 每次 read 也写 consistency metadata |
| Own-last-operation check | 防同一 user rollback | User 必须可靠保存最后 operation/version |
| Fork consistency | Divergence 后不能无痕 merge | 不阻止 fork、不保证 freshness/availability、不自动解决 forks |
| Full history straw-man | Security reasoning 简单 | 无限增长、全量 replay/transfer、global serialization |
| Hash trees/i-handles | 小修改只更新 path，snapshot 可验证 | Hash metadata 与 tree traversal；依赖 collision resistance |
| Version vectors | 承诺跨-principal snapshot dependencies | Vector/VSL 随 users/groups 增长；比较与传输 metadata |
| Global lock | 简单 total order | 无关 operations 也串行，server 可拖延/拒绝 lock |
| Update certificates/PVL | Non-conflicting operations 并行 | Pending-state validation、conflict merge、omission protection 更复杂 |
| Trusted box/direct communication | 更快检测或收紧 fork window | 引入 trusted online party/connectivity，failure 时牺牲 availability |

### Failure distinctions

- **Malicious omission/rollback：** cryptographic/version checks 可把很多篡改转成 detected failure 或 permanent fork。
- **Crash/network partition：** Client 看不到 updates 时，单凭协议常无法区分 benign outage 与 malicious suppression。
- **Denial of service：** Byzantine server 可不回复；SUNDR 没有 availability guarantee。
- **Client state loss：** 若 user 忘记 last operation/version，rollback defense 的关键前提丢失；§2 要求迁移时携带该 state。

### Confidentiality boundary

FAQ 明确说 assigned SUNDR 提供 integrity，不隐藏 files。Encryption 可作为独立扩展，但不在 §1-§3.4 protocol 中；不能把 content-addressed hashes 或 signatures 当作 encryption。

## 11. FAQ 与课堂连接

- 课堂用 Zoobar 的 `auth.py`/`bank.py` 依赖展示逐文件 authenticity 为什么不等于 filesystem integrity：每个 file 都可能由合法 owner 签过，server 仍可混搭不同时期的合法 versions。
- 课堂主线详细推演“fetch 不记 log”的 stale-prefix attack，与 Paper Question 直接对应；答案仍需学生自己组织，不能只写“因为 rollback”。
- 课堂最后用 per-user i-handle、hash tree 和 version structures 解释压缩 history；§3.4 的 update certificates/PVL 主要来自 assigned paper，NOTES 明确警告不能冒充课堂逐步讲授。
- FAQ 所谓 user communication 包括 email/chat 等 out-of-band evidence，例如 A 告诉 B 已创建 file X 而 B 看不到；这能暴露 fork，但若 A 本身恶意，B 还需判断是 server fork 还是 A lying。
- FAQ 对 i-handle 的解释支持 incremental hashing：改变一个 block 只重新计算该 block 到 root 的 path；signature 更昂贵。本文不引用 §5-§7 的具体 implementation/benchmark，因为超出阅读边界。
- Lecture 19 Bitcoin 会接续“如何 settle on a fork”；SUNDR 的 guarantee 是检测/隔离，不是 longest-chain resolution。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Secure Untrusted Data Repository (SUNDR) In the simple straw-man, both fetch and modify operations are placed in the log and signed. Suppose an alternate design that only signs and logs modify operations. Does this allow a malicious server to break fetch-modify consistency or fork consistency? Why or why not?

下面只给推理脚手架，不给可提交答案：

1. 先分别写出 fetch-modify consistency 与 fork consistency 要求，避免把两者当成同一问题。
2. 构造至少两个 users 和两个有 dependency 的 files；让 modifications 在真实时间上都先完成，再让第三个 client 分两次 fetch。
3. 对第一次 fetch，选择一个合法旧 prefix；对第二次 fetch，选择一个更长的合法 history。逐项检查 signatures、hashes 和 own-last-operation 为什么仍可能通过。
4. 明确第一次 fetch 没进 log 后，server 缺少哪一条不可抵赖 evidence；说明它如何把已完成 modifications 伪装成 concurrent。
5. 再加入 signed fetch record，画出 client branch 与 update branch；尝试 merge，并指出究竟是哪条 later signature/own-last-operation check 阻止 merge。
6. 分别下结论：alternate design 是否破坏 fetch-modify consistency；是否仍达到 paper 定义的 fork consistency。不要只给一个 yes/no 覆盖两个性质。
7. 检查你的 attack 是否要求伪造 signature 或 hash collision；若需要，就没有利用到题目想考的 protocol gap。

## 13. 理解检查：10 组问答

1. **问：SUNDR 的 server threat model 比 crash-only storage 多了什么？**  
   **答：** Server 可主动返回旧/不同数据、隐藏 operations、fork clients、与 compromised users 合谋或拒绝服务；协议不能假设它按规则执行。（来源：论文 §1-§3）

2. **问：Integrity 与 confidentiality 在 SUNDR 中如何区分？**  
   **答：** Assigned protocol 让 unauthorized modification/inconsistent histories 可检测，但不加密 file contents，server 仍可读数据。（来源：论文 §1、FAQ）

3. **问：为什么逐文件签名不能保证 filesystem integrity？**  
   **答：** 旧版本仍有合法 signature；server 可 replay、隐藏、改 filename binding 或混合 individually valid files，破坏 freshness、directory completeness 与跨文件 dependencies。（来源：论文 §3.1、课堂 NOTES）

4. **问：Straw-man 为什么检查 user 自己的 previous operation？**  
   **答：** 防止 server 把该 user 回滚到其已签 history 之前；每次新 operation 必须延伸 own last commitment。（来源：论文 §3.1）

5. **问：Fetch 不修改数据，为什么仍是 security-relevant operation？**  
   **答：** 它记录 client 已观察的 history prefix；若不记录，server 可让相继 reads 分别基于旧 prefix 和新 history，伪造 happens-before。（来源：论文 §3.1、Paper Question、课堂 NOTES）

6. **问：Fork consistency 是否禁止 malicious server 分叉？**  
   **答：** 否。它允许 fork，但保证 honest users 一旦进入 incompatible branches，就不能在不检测 attack 的情况下再看到对方 fork 后的 operations。（来源：论文 §3、§3.2）

7. **问：i-handle 承诺了什么？**  
   **答：** 它是 principal i-table hash tree 的 root；沿 inode/data hashes 间接承诺该 user/group 可写的 filesystem state。（来源：论文 §3.3.1）

8. **问：Version vector 的 partial order 怎样暴露 fork？**  
   **答：** 正常 serialized histories 的 structures 应按 component-wise $\le$ 可 total order；若两 vectors 互不小于对方，它们承诺了 incompatible snapshots。（来源：论文 §3.3.2）

9. **问：PVL 为什么同时包含 update certificate 和 unsigned forthcoming structure？**  
   **答：** Certificate 预声明 signed operation/deltas；server 根据已知 order 计算该 operation 应反映的 vector，使并发 client 能验证 ordering、计算新 structure 并发现 omission/incompatibility。（来源：论文 §3.4.1）

10. **问：Concurrent SUNDR 何时仍必须等待？**  
    **答：** Fetch 遇到 pending write 时要等相关 structure commit；shared group i-table 的 concurrent writes 要合并 deltas并承诺 PVL references。无冲突 operations 才能直接并行。（来源：论文 §3.4.2-§3.4.3）
