---
uid: mit-6824-s21-resource-reading-20
type: course
document_type: resource
resource_kind: reading
resource_order: 120
course: mit-6824-s21
title: Lecture 20 阅读指南：Blockstack
description: Lecture 20 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 20 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-20/"
toc: true
official_lecture_number: 20
math: true
---

## 1. 来源、范围与证据边界

- 指定阅读是完整的 **Blockstack: A Global Naming and Storage System Secured by Blockchains (USENIX ATC 2016)**；官方 schedule 没有缩小 paper section 范围。
- 本指南以论文为 production experience、architecture、protocol、security dependencies、evaluation 和 migration tradeoffs 的主来源；FAQ 用于澄清 Certificate Transparency、privacy、developer experience、PKI 与 consistency hashes；课堂连接以官方 `l-blockstack.txt` 和 Lecture 20 transcript/summary-input 为证据。
- Lecture 20 目录没有生成聚合 `NOTES.md`，`notes/sections/` 也为空；不能虚构 NOTES chronology。本文只链接并使用实际存在的官方课堂讲义、9 段 summary input 和 transcript。
- 论文描述 2014-2016 年 Namecoin deployment、Blockstack v0.10 与 Bitcoin 当时的性能/容量。诸如 peers、block size、market cap、transaction rate、用户数和软件架构均是论文时点事实，不当作 2026 年产品状态。
- 论文的 naming system 提供 global state/ownership ordering，但 bulk data 放在 external stores。Blockchain security 不自动变成 data availability、confidentiality、freshness 或 application correctness；这些性质必须分别分析。
- FAQ 包含课程教师的经验判断和猜测，例如 CT-based design 或用户是否愿意牺牲 convenience；它们用于讨论，不冒充 paper proved result。

资源：

- [Lecture 20 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-20.md)
- [Blockstack 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/blockstack-atc16.pdf)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/blockstack-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/20-q-blockstack.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-blockstack.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-20-blockstack)
- [Lecture 20 summary input](/assets/courses/mit-6824-s21/lectures/021/summary-input.jsonl)
- [Lecture 20 transcript](/assets/courses/mit-6824-s21/lectures/021/transcript.txt)
- [Lecture 20 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=21)

## 2. 问题模型：去中心化 naming 为什么需要 global order

论文把 naming system 定义为同时追求：

1. **Human-readable**：names 可由人选择和记忆；
2. **Strong ownership**：name-value pair 由 cryptographic keypair 控制，只有 owner 可更新；
3. **Decentralized**：没有 central trusted party 或 single point of failure。

课堂用 Zooko's Triangle 组织三者：email address 可 unique+human-readable 但依赖 hierarchy；random public key 可 unique+decentralized 但不可读；local contact list 可 human-readable+decentralized 但 names 对不同人含义不同。

难点不是生成字符串或 key，而是开放系统中的 **conflict resolution**：两人都声称拥有同一 human-readable name 时，所有 replicas 必须按同一 total order 选择 winner。只发布冲突而不统一 order 不足以给 name 一个 global owner。

Blockchain 提供 public append-only log 和 consensus order；name operations 被编码成 blockchain transactions。于是 naming state 是 ordered operations 的 deterministic state-machine result：

```text
same accepted blockchain history
    + same virtualchain validation rules
    -> same sequence of valid name operations
    -> same name ownership/state database
```

这个 invariant 同时依赖 underlying blockchain history 和 Blockstack software rules；二者任一分叉都可能让 global state 分叉。

## 3. Namecoin production experience：设计为何改变

Blockstack 的设计来自一个运行在 Namecoin 上的 production PKI/identity system：注册超过 `33,000` entries，发送超过 `200,000` transactions。论文不是只提出 clean-slate architecture，而是先报告五类生产教训。

### 3.1 51% concentration

论文观察 F2Pool 长期控制 Namecoin 超过 `51%`、有时一周达到 `75%` 的 compute power。Majority miner 可重写 recent history、censor registrations 和 double spend；因此 name ownership security 直接受 underlying blockchain 的 attack cost 与 mining distribution 约束。

### 3.2 Network reliability/throughput

- 一个 transaction 含大量 data fields 导致 Namecoin miner daemons crash，block latency 数周飙升，registration complaints 增加。
- 随后出现许多 empty blocks，目标 transactions 连续多块不被接受，偶尔在其他 miner 获胜时批量入块。
- 论文只说该迹象类似 selfish mining，无法证明 miner intent；应保留 “potential/selfish-mining-like behavior” 的证据强度。

### 3.3 Consensus-breaking upgrades

Name pricing 等规则变化要求 hard fork；small cryptocurrency miners 缺少投入 engineering time 的 incentive，upgrade 后 compute power 波动且部分 miners 不再回来。Lesson 不只是 software deployment 难，而是参与者 incentive 与 consensus compatibility 绑定。

### 3.4 Merged mining failure

Merged mining 让 Bitcoin miners 不增加 hash work 即可支持 Namecoin，但并非所有 miners 都运行 Namecoin software。论文时点 F2Pool 在 Bitcoin 占约 `30%-35%`，却在 Namecoin 超过 `60%`；subset participation 使 alternate chain 仍受 single-majority 威胁，并制造 false sense of security。

### 3.5 推导出的设计方向

作者选择迁移到当时最大、最昂贵攻击、维护最活跃的 Bitcoin chain，同时避免为 naming 新开小 blockchain。问题变成：怎样在不修改 Bitcoin consensus rules 的情况下增加 naming state machine，并把 large/fast-changing data 移出 slow ledger。

## 4. Architecture：control plane 与 data plane

Blockstack 有四层，两层 control plane、两层 data plane：

| Plane | Layer | 责任 |
| --- | --- | --- |
| Control | Blockchain | 保存 Blockstack operation sequence，并对 order 达成 consensus |
| Control | Virtualchain | 解析 metadata、验证 operations、执行 naming state machine |
| Data | Routing | 保存 zone files，发现 data URI/hash；control plane 承诺其 hash |
| Data | Storage | S3、IPFS、Syndicate 等保存 bulk values；owner signatures/hashes 验证 integrity |

### Separation invariant

```text
blockchain stores minimal state transitions / hashes
    -> consensus protects name ownership and bindings
external stores hold bulk data
    -> capacity and write latency need not equal blockchain limits
client verifies route/data against control-plane commitment or owner key
```

Namecoin 把 control/data 都塞在 blockchain level；Blockstack 分离后获得 arbitrary-size values、多个 storage backends 和更快 mutable writes。代价是 availability 与 freshness 不再由 blockchain 单独决定：external store 可拒绝服务、返回旧 signed value，client 还需 version policy。

### Blockchain-agnostic claim 的边界

Architecture 可在不同 underlying chain 上运行，但 security/reliability 直接依赖所选 chain。Core developers 决定 software version 支持哪些 chains；applications 可选择不迁移。技术上可迁移不等于没有 governance/trust decision。

## 5. Virtualchain：在不改 Bitcoin 的情况下增加 state machine

Blockstack operations 被编码在 valid blockchain transactions 的 metadata 中。Bitcoin nodes 只验证 raw transactions，不理解 naming semantics；Blockstack nodes 按 virtualchain rules 接受/拒绝 operations，并更新 global naming database。

### Deterministic replay model

对每个 underlying block height $h$：

1. Extract candidate Blockstack operations $V_h$；
2. 按 blockchain order 处理；
3. 用 virtualchain validation rules 过滤 invalid operations；
4. 对 accepted operations 执行 state transitions；
5. 产生 height $h$ 的 naming state 与 consistency hash。

Blockchain 提供 order，不提供 application-specific validity。Virtualchain 提供 validity/state machine，却借用 blockchain 的 expensive fork resolution。这样增加新 functionality 不要求 Bitcoin miners/peers upgrade，避免 consensus-breaking change。

### Name state machine

论文 Figure 5 的主要 states/transitions：

```text
absent --PREORDER--> preordered --REGISTER--> registered
registered --UPDATE/RENEW/TRANSFER--> registered
registered --REVOKE--> revoked
preordered/registered/revoked --EXPIRE--> absent or policy-defined state
```

Ownership 绑定 underlying blockchain address/private key。Transfer 改变能签后续 operations 的 address；revoke 禁止进一步操作一段时期；namespace 定义 pricing/renewal policy。

### Preorder 防 front-running

直接广播 desired name 会让 observer/miner 抢先提交。User 先发布 name commitment，确认后再 reveal/register name-value pair。课堂指出 commitment 不能只是可字典枚举的裸 `hash(name)`；实际 preorder 还必须混入其他信息以隐藏低熵 name。精确 wire format 不由本论文完整展开，不能凭课堂口述虚构字段。

## 6. Routing/storage：authenticity、freshness 与 availability 分离

Virtualchain 绑定：

```text
name -> owner key/address + hash(zone file)
zone file -> URI and/or hash(data)
URI -> external storage value
```

Routing layer 可不可信：client fetch zone file 后，检查其 hash 是否等于 control-plane binding。论文实现用 DHT 存 zone files，并只接受 hash 已在 blockchain 宣布的 records；多数 production servers 因每个 zone file 约 `4 KB` 而保存完整 routing set。

### Mutable storage

Zone file 含 data URI，data 本身由 name owner's key 签名：

- Write 只需 sign 并上传 data，不改 zone file，因此无需 blockchain transaction，速度取决于 signature/storage backend。
- Read 验 zone-file hash，再用 owner public key 验 data signature。
- Signature 证明 authenticity，不证明 response 是 latest；readers/writers 必须采用 data versioning scheme 防 stale data。

### Immutable storage

Zone file 额外含 `hash(data)`：

- Client 可验证拿到的 exact data version；
- 更新 data 要更新 zone file hash，并发一笔 underlying blockchain transaction；
- Freshness assurance 更强，但 write 回到 minutes-level blockchain path。

### 三种性质不能混淆

| 性质 | 主要机制 | 未解决部分 |
| --- | --- | --- |
| Authenticity/integrity | Owner signature、zone/data hash | Stolen key、malicious app 可签坏数据 |
| Freshness/latest version | Immutable hash binding 或 mutable version policy | Mutable store 可 replay old signed value |
| Availability/durability | External storage replication/provider | Blockchain hash 无法迫使 provider 返回 bytes |

论文的 decentralization 不意味着 storage provider 无需信任任何事情；client 不必信其内容正确，但仍依赖其保存和提供数据。

## 7. Naming ownership、pricing 与 identity boundary

### 7.1 Unique global name

Underlying chain order 与 virtualchain first-valid-registration rule 让所有 conforming nodes 对 name owner 达成一致。Two-phase preorder/register 缓解 mempool front-running；previous preorders 在 successful registration 后 invalid。

### 7.2 Pricing/fees

Registration fee 抑制 land grab/spam；namespace creator 可定义 price 随 name length/characters 变化。`.id` namespace 的论文例子让 short alphabetic names 更贵，authors 创建 namespace 时也支付规则要求的 fee。

费用增加稀缺性，但没有证明价格函数能公平分配 names 或阻止 wealthy squatting；这是 policy/economic mechanism。

### 7.3 Name ownership 不等于 real-world identity

Blockstack 能证明“控制某 private key 的实体最先按规则注册了该 string”，不能证明 `rtm@mit.edu` 的注册者现实中就是对应的人。Human-readable 提高记忆/传递便利，却也让全球 namespace 出现同名、typosquatting、identity discovery 与 recovery 问题。

FAQ 把这归为 PKI 的深层难题：如何从“我想联系的那个人”可靠地到达 public key。Central registry 也可能验证错误或被强制改写；decentralized first-registration rule 则更不提供现实身份审查。

## 8. Consistency hash、SNV 与 endless ledger

### 8.1 Consensus/consistency hash

论文定义：

$$CH(h)=hash(V_h+P_h),$$

其中：

$$P_h=\{CH(h-2^i)\mid i\in\mathbb{N},\ h-2^i\ge h_0\}.$$

也就是每个 height 承诺本 block virtualchain operations 以及按 powers of two 采样的 previous consensus hashes，形成 skip-list-like history commitment。

用途有两个：

1. Nodes 对比同一 height 的 hash，检测其 global naming state/history 是否一致；
2. 给 Simplified Name Verification (SNV) 提供 logarithmic historical proof links。

FAQ 强调 Blockstack 自己也可能因 software versions/validation rules 不同而 fork。Consistency hash 不保证所有 peers 永不分叉；它使不一致 histories 留下可比较 commitment，并让 peer 后续只接受同 branch 的 references。

### 8.2 Fast bootstrap

New node 可取得 untrusted state database at height $h$ 和一个 **trusted authentic** $CH(h)$，reconstruct virtualchain 并验证最终 hash，之后只处理 later blocks。论文报告：Python implementation 上 SNV bootstrap 约 `1-2 hours`，从 genesis 审计约 `2-4 days`。

这里把 trust 从完整 genesis replay 移到 checkpoint hash authenticity：

```text
untrusted snapshot + trusted CH(h)
    -> verify snapshot/history commitment
    -> start from h
```

如果 trusted hash 本身错误，SNV 无法救济；paper 没有给 universal trustless distribution mechanism。

### 8.3 Thin client

Thin client 可用 later trusted hash 和 logarithmic queries 验证 prior name operation，不必保存 full blockchain。但它验证的是相对 trusted checkpoint 的 virtualchain history，不自动取得 storage data availability 或 real-world identity truth。

## 9. Failure、安全与迁移

### 9.1 Underlying blockchain failure

Namecoin 经验显示 chain 可因 majority concentration、software bug、DDoS/low peer count、miner transaction exclusion 或 upgrade fragmentation 失去安全/可靠性。Blockstack 因而设计 cross-chain migration，而非永久绑定一条 chain。

论文报告 2015 年把 `33,000` users 从 Namecoin `u/` namespace 迁到 Bitcoin 上 `.id` namespace。Migration 说明 production state 可转移，但决定 canonical destination/software 仍是 governance choice，且 bandwidth/fees 是实际限制。

### 9.2 Bitcoin throughput/fee incident

论文时点 Bitcoin 约 `3-7 transactions/s`、1 MB blocks。Migration throttled transactions 至 blocks 的 `20%-30%`，仍显著拉长完成时间。CoinWallet stress test 造成大量 unconfirmed transactions，Blockstack 为入块支付 `2-3x` fees。

这些数据支持“underlying public chain capacity/fee market 直接限制 control-plane changes”，不能外推为所有时期固定 throughput/fees。

### 9.3 Software-rule fork

不同 Blockstack nodes 若运行不兼容 virtualchain rules，可能对同一 raw Bitcoin transaction 接受结果不同。Bitcoin chain 一致不自动保证 application-layer state 一致；consistency hashes 用来暴露此类 split。

### 9.4 Key/application failures

- Private key 丢失：owner 可能无法更新/转移 name/data；paper architecture 没有神奇 recovery。
- Key 被盗：attacker 可提交 cryptographically valid owner operations。
- Malicious/buggy client app：即使在 user's device 上运行，也可读取或泄露它被授予的数据；client-side execution 不自动可信。
- Storage rollback/outage：mutable signed data 可 stale，provider 也可拒绝服务。

## 10. Evaluation 与 tradeoffs

### 10.1 Paper evaluation 支持什么

- Namecoin deployment：真实注册/交易数量和 production anomalies 支持“small chain 的 security/reliability 有操作风险”。
- Blockstack I/O：对 S3 上传/读取 `1`、`10`、`100 MB` files，每组 `25` trials；compressed file storage overhead 约 `5%`，100 MB write 的 CPU overhead 约 `2 s`。
- Figure 7 把 download time 排除以突出 signature verification/decryption CPU overhead；论文预期 wide-area 实际更多由 network 决定。
- SNV：当时 commodity hardware 上 bootstrap 从 days 降为 hours。

这些实验不证明完整 decentralized applications 与 centralized sites 同样快、可用或易开发，也没有评估复杂 multi-user sharing、key recovery、global indices 或 privacy attacks。

### 10.2 Tradeoff 总表

| 选择 | 收益 | 代价/边界 |
| --- | --- | --- |
| 复用 Bitcoin | 借最大 chain 的 work/security 与 global order | Slow/fee-limited writes；依赖 Bitcoin reliability/governance |
| Virtualchain | 不改 underlying consensus 即增加 state machine | Blockstack software rules 可分叉；所有 nodes 要 deterministic replay |
| Control/data split | Bulk data 大且可快写，多 storage providers | Availability/freshness 转由外部 stores/versioning 处理 |
| Mutable mode | Data update 不上 chain，低 latency | Signature 只证 authenticity，不证 latest |
| Immutable mode | Hash 绑定 exact version | 每次 update 需 blockchain transaction，慢且付费 |
| Global human-readable names | 可记忆、共享 ACL/key references | Scarcity、squatting、现实身份映射与 recovery 难 |
| Fees/pricing | 抑制 spam/land grab，形成 protocol incentive | 公平性与 affordability 是 policy 问题 |
| SNV/checkpoint | Bootstrap/历史查询更快 | 必须取得 trusted authentic consensus hash |
| User-owned encrypted storage | 降低 provider snooping，易换 app/provider | Sharing/revocation/key management/queries 更复杂 |
| Client-side apps | User 选择 code 与 data interface | 用户仍需信任 app；缺少 trusted server-side secret computation |

## 11. FAQ 与课堂连接

- 课堂先比较 centralized app+DB 与 decentralized user-app+general storage。后者让用户换 apps、跨 apps 使用数据并可 end-to-end encrypt；前者在 SQL queries、global indices、debugging、revenue 和 application-specific security 上更简单。
- 课堂用 shared to-do list 展示 per-user files 的组合，再用 auction bids 说明 client-side app 无法同时“看到秘密 bids 计算 winner”又“不让用户修改 app 偷看”。Decentralization 不是对所有 application semantics 的替代。
- 课堂 naming 主线与 homework 对应：names 映射 user、data location 和 public key；unique/human-readable/decentralized 各自有价值，但全球 name 并不证明真实 identity，也可能退化成难认的 suffix names。
- FAQ 比较 Certificate Transparency：CT 可公开 conflicting claims，却有多个 logs/不同 orders，不能像 Bitcoin mining 一样统一 first owner；它也缺少 naming fee 的天然 spam barrier。这是课程解释，不是 paper evaluation。
- FAQ 对 privacy 的限定很重要：storage encryption 可阻止 provider 直接读 bytes，但 app code、sharing key management、lost/stolen keys 和 access patterns 仍是风险。
- FAQ 列举 developer friction：key/value API 无 SQL；cross-user sharing/revocation；site-owned/public aggregate data；server-side secrets/auctions。这些与课堂 conclusion 一致，提醒不要把 architecture diagram 写成完整 app platform guarantee。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Why is it important that Blockstack names be unique, human-readable, and decentralized? Why is providing all three properties hard?

下面只给推理脚手架，不给可提交答案：

1. 分别定义三个属性，给每个属性写一个具体 decentralized-app operation：发现 data、验证 key、分享 ACL、口头传递 name 等。
2. 对每个属性写“缺失时会发生什么”，不要只重复“有它更好”。例如 local contacts 缺 global uniqueness 时，两人的 `John` 是否可互换。
3. 构造三组 two-of-three examples：email/DNS-style hierarchy、random public keys/content hashes、local contact list；准确指出各缺哪一项。
4. 把“hard”定位到开放 namespace conflict：两人同时申请同一 readable name 时，谁有权给出所有 replicas 都接受的 order/owner。
5. 说明 central registry 为什么容易给 order，却不 decentralized；random key 为什么避免争夺却不 human-readable；local aliases 为什么 readable/decentralized 却不 global unique。
6. 再映射 Blockstack mechanism：underlying blockchain order、virtualchain first-valid registration、preorder 与 fee 各解决哪一个子问题。
7. 加入边界反思：protocol ownership 是否等于 real-world identity；human-readable/global uniqueness 对所有 apps 是否同样重要。提出 tradeoff，但不要用它绕开题目。

## 13. 理解检查：10 组问答

1. **问：Blockchain 在 Blockstack naming 中直接提供什么？**  
   **答：** 它提供 public append-only operation channel 和 consensus order；Blockstack virtualchain 再解释 operations 并执行 naming validity/state transitions。（来源：论文 §1、§4.2-§4.3）

2. **问：为什么 Namecoin 的 51% concentration 会威胁 name ownership？**  
   **答：** Majority miner 可重写 recent chain、censor registration 或改变 first-accepted order；ownership security 依赖 underlying history 不被低成本改写。（来源：论文 §3.1）

3. **问：Virtualchain 为什么不要求 Bitcoin nodes upgrade？**  
   **答：** Bitcoin 只看 valid raw transactions；Blockstack nodes 在上层解析 metadata 和执行新 state machine，underlying consensus rules 不变。（来源：论文 §4.2-§4.3）

4. **问：Control/data plane separation 的主要收益是什么？**  
   **答：** Chain 只保存 name/hash/state transitions，bulk values 放 external storage，突破 on-chain size/throughput limits，并让 storage independently evolve。（来源：论文 §4.2）

5. **问：Mutable storage 的 signature 为什么不保证 freshness？**  
   **答：** Old value 仍有 owner valid signature；provider 可 replay。Reader/writer 必须另用 versioning，或使用 hash-bound immutable mode。（来源：论文 §4.3.4）

6. **问：Preorder/register 两阶段解决什么？**  
   **答：** 先提交隐藏 name 的 commitment，避免 observer 在 reveal 后抢先注册；之后再 reveal/register 并绑定 owner/zone data。（来源：论文 §2.2、§4.4）

7. **问：Consensus hash 能阻止所有 Blockstack fork 吗？**  
   **答：** 不能。它承诺 virtualchain history/state，使不同 rules/views 的 fork 可检测并支持 SNV；错误 software 或 incompatible peers 仍可能分叉。（来源：论文 §4.5、FAQ）

8. **问：SNV 快速启动为什么仍需要 trust anchor？**  
   **答：** Snapshot database 可不可信，但 node 必须已有 authentic trusted consensus hash；若该 hash 错误，验证会接受错误基准。（来源：论文 §4.5）

9. **问：Blockstack name 能证明现实身份吗？**  
   **答：** 它证明某 key 按 global rule 获得 string ownership；不证明该 key holder 就是该 email/person/organization。（来源：论文 §2、FAQ、课堂讲义）

10. **问：论文的 S3 performance experiment 没有证明什么？**  
    **答：** 它显示 file crypto/compression overhead 可与 backend I/O 相比，但没有证明完整 decentralized apps 的 consistency、availability、sharing、privacy 或 developer experience 等同 centralized sites。（来源：论文 §4.6、FAQ）
