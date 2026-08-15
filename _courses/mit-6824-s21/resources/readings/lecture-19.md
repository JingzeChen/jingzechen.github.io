---
uid: mit-6824-s21-resource-reading-19
type: course
document_type: resource
resource_kind: reading
resource_order: 119
course: mit-6824-s21
title: Lecture 19 阅读指南：Peer-to-Peer - Bitcoin
description: Lecture 19 的指定阅读、证据边界、机制推理与自测指南。
excerpt: Lecture 19 的指定阅读、证据边界、机制推理与自测指南。
content_lang: zh-CN
permalink: "/courses/mit-6824-s21/readings/lecture-19/"
toc: true
official_lecture_number: 19
math: true
---

## 1. 来源、精确范围与证据边界

- 指定 primary reading 是完整的 **Bitcoin: A Peer-to-Peer Electronic Cash System (2008)**：Abstract、§1-§12 和 References，论文没有缩小 section 范围。
- 另有完整 assigned external summary：Michael Nielsen 的 **How the Bitcoin protocol actually works**。阅读正文从开篇 “Many thousands of articles...” 开始，经过 Infocoin 的逐步构造、实际 Bitcoin transaction 解释、multiple inputs/outputs，到 Conclusion、loose ends 与 Footnote 结束。归档 HTML 中网页导航、样式、评论区和后续 pingbacks 不是作者的 assigned explanatory article，不作为本指南证据。
- 协议、安全假设、公式与论文作者主张以 Nakamoto paper 为 primary source；Nielsen summary 是 2013 年的 secondary explanation，用于从 first principles 建立直觉。两者不一致或时代状态变化时，以 paper 的原始设计边界为准，并明确标注 summary 的历史时点。
- 课堂连接以 Lecture 19 `NOTES.md` 和官方讲义为证据。课堂简化了 transaction format，也没有逐步推导 §11 的全部概率公式；不能把 paper/summary 内容冒充教师逐字讲授。
- 本指南解释 2008 paper 描述的系统，不把 2026 年 Bitcoin implementation、block reward、fee market、network rules 或后续协议升级反写进原文。FAQ 中某些“today/current”数字也属于 FAQ 编写时点，不当作永久事实。
- 论文的 security argument 依赖 honest nodes collectively control more CPU power than any cooperating attacker group、digital signatures 与 hash properties；它提供 probabilistic confirmation，不是 deterministic finality，也不解决 private-key theft、software bugs 或所有 network attacks。

资源：

- [Lecture 19 reading evidence bundle](/assets/courses/mit-6824-s21/evidence/reading-inputs/lecture-19.md)
- [Bitcoin 论文](/assets/courses/mit-6824-s21/materials/official-materials/papers/bitcoin.pdf)
- [Michael Nielsen 外部总结](/assets/courses/mit-6824-s21/materials/official-materials/readings/how-the-bitcoin-protocol-actually-works)
- [外部总结原始链接](https://michaelnielsen.org/ddi/how-the-bitcoin-protocol-actually-works/)
- [官方 FAQ](/assets/courses/mit-6824-s21/materials/official-materials/faqs/bitcoin-faq.txt)
- [官方 Paper Question](/assets/courses/mit-6824-s21/materials/official-materials/questions/19-q-bitcoin.html)
- [课堂讲义](/assets/courses/mit-6824-s21/materials/official-materials/lecture-notes/l-bitcoin.txt)
- [课程 MATERIALS 索引](/courses/mit-6824-s21/materials/#lecture-19-peer-to-peeer---bitcoin)
- [Lecture 19 NOTES](/courses/mit-6824-s21/lectures/020/)
- [Lecture 19 transcript](/assets/courses/mit-6824-s21/lectures/020/transcript.txt)
- [Lecture 19 视频分段](https://www.bilibili.com/video/BV16f4y1z7kn/?p=20)

## 2. 问题：签名为什么没有解决 double spending

论文把 electronic coin 定义为 digital signatures 的 chain。每位 owner 转移 coin 时，签署 previous transaction hash 和 next owner's public key；payee 可验证 ownership chain。

简化表示：

$$T_i=(H(T_{i-1}),PK_{new},Sig_{SK_{old}}(H(T_{i-1}),PK_{new})).$$

这证明 old owner 授权了当前 transfer，却不能证明 old owner 没有再签一笔引用同一 previous transaction 的冲突 transfer：

```text
T_prev -> T_pay_Bob
       -> T_pay_Charlie
```

两笔 signatures 都可能正确。判断哪笔有效需要知道 **哪笔先被共同历史接受**。论文因此把 double spending 转化为公开发布和全局排序问题：participants 必须能看到所有 transactions，并同意 first received/history order。

Central mint 可检查每笔 coin 是否已花，但让全部 transactions 和 currency fate 依赖单一机构。Bitcoin 的目标是在没有 trusted third party 的情况下建立一个 public timestamped transaction history。

### Nielsen summary 的教学路线

Summary 用虚构 **Infocoin** 分阶段暴露缺口：signed intent -> unique serial numbers -> everyone keeps a ledger -> double-spend race -> proof-of-work -> block chain -> 实际 Bitcoin transactions。这个顺序解释每个机制“为什么存在”，但 Infocoin 不是 paper protocol，示例 serial-number currency 也不是 Bitcoin data model。

## 3. Timestamp server、blocks 与 hash-chain invariant

Timestamp server 对一组 items 的 hash 进行广泛发布，证明这些 data 在 timestamp 时已经存在。每个 timestamp 把 previous timestamp 包入 hash，形成 chain；后续 timestamp 给此前记录叠加 commitment。

Bitcoin 把 transactions 集合放入 block：

```text
block header:
    previous block hash
    transaction commitment
    timestamp / difficulty-related fields
    nonce
```

论文图示的关键 invariant 是：

```text
valid block points to previous accepted block
    -> modifying an old block changes its hash
    -> every descendant's previous-hash reference breaks
    -> attacker must redo proof-of-work for changed block and descendants
```

Hash chain 让改写历史的成本向后累积，但它本身不决定两个同时有效 branches 中哪个是共同历史；branch selection 还需要 proof-of-work accumulation 和 network rule。

## 4. Proof-of-Work：开放成员中的 representation

Miner 寻找 nonce，使 block hash 满足 difficulty target；论文用 hash 前若干 zero bits 描述。若要求额外一位 zero，平均 work 约翻倍；生成需大量 trials，验证只需一次 hash。

### Sybil resistance

若按 one-IP-one-vote，攻击者可创建许多 addresses。Proof-of-work 把 representation 近似绑定到 CPU work，而不是 identity count：

$$Pr[\text{find next block}]\approx\frac{\text{participant hash power}}{\text{total hash power}}.$$

论文称 longest chain 代表 greatest proof-of-work effort。准确理解应是选择累计 work 最大的有效 chain；“longest”是论文在相同 difficulty 直觉下的说法，不能脱离 work 写成只数 block 个数。

### Difficulty adjustment

协议根据 moving average 调节 difficulty，目标是固定平均 blocks/hour；hardware 变快或参与算力增加时 difficulty 上升。具体现代 retarget implementation 不在论文细节中。

### Security assumption

若 honest nodes collectively 拥有更多 CPU power，honest chain 平均增长更快，较弱 attacker 从落后位置追上的概率随 confirmations 增加而下降。PoW 不证明 block producer 道德可信；full nodes 仍必须验证 transactions，不会因为 hash work 就接受 invalid spend 或凭空创造价值。

## 5. Network protocol、fork 与概率最终性

论文 §5 给出 network steps：

1. New transactions broadcast to all nodes。
2. Node 把 new transactions 收入 candidate block。
3. 各 node 为自己的 block 寻找 PoW。
4. 找到后 broadcast block。
5. Nodes 仅在 transactions valid 且未 double-spent 时接受 block。
6. Node 通过在其后继续工作表达 acceptance。

Messages 是 best effort；transaction 不必到达每一 node，只要到达足够多节点就可能入块。Missed block 可在看到其 successor 后请求补取。

### Benign fork

两个 nodes 可能近同时发布不同 next blocks。Peers 暂时沿 first-seen branch 工作，同时保存另一支；下一 block 使一支累计 work 领先后，另一支 miners 切换。Fork 因 network delay/并发成功自然出现，不自动表示攻击。

### Confirmation invariant

一笔 transaction 被某 block 接纳后，每个 descendant 增加改写它所需重做的 work。Recipient 等待 $z$ 个后续 blocks，是选择可接受 reversal probability；不是在第 6 个 confirmation 突然获得绝对 finality。

### Reorganization

Node 切换到更强 chain 时，旧 branch 独有 transactions 不再 confirmed；未与新 chain 冲突的 transaction 可能以后重新入块。Application 必须把“看到 transaction broadcast”“入某 block”“有若干 confirmations”视作不同状态。

## 6. Transactions、validity 与 value conservation

### 6.1 Paper 的 coin-chain abstraction

每个 owner signature 指定 previous transaction 和 next public key。Full node 验证 signature chain，并依 public history 判断 previous output 是否已花。Signatures 给 authorization；ledger order 给 uniqueness of spend。

### 6.2 Multiple inputs/outputs

论文 §9 说明 transaction 可有多个 inputs/outputs：

- 多 inputs 合并较小 values；
- 一个大 input 可分成 payment output 和 change output；
- Output total 小于 input total 的差额是 transaction fee。

这比“每个 coin 是固定 serial-number object”更接近 ledger of spendable outputs。Summary 的 raw-transaction walkthrough 进一步用实际 input 指向 prior output、output script/address 和 change 建立直觉，但它明确说展示数据经过反序列化和缩写，不是 wire-format specification。

### 6.3 Majority hash power 的能力边界

论文 §11 强调 attacker 即使追上 chain，也不能任意改变规则：

- Full nodes 不接受 invalid transactions；
- Attacker 不能在没有 victim signature 的情况下花 victim's outputs；
- 它主要能尝试改写自己的 recent payment，制造 double spend；
- Majority power 还可通过控制入块顺序/censorship 破坏 liveness，但 paper 的计算聚焦 double-spend catch-up。

Private-key theft 属于另一 failure：协议无法区分 thief 的 valid signature 与 owner 的 valid signature。

## 7. Incentive、经济闭环与安全 tradeoff

每个 block 的 first transaction 创建由 block creator 拥有的新 coin，作为支持 network 的 incentive。未来也可由 transaction fees 支付：

$$reward=block\ subsidy+\sum fees.$$

论文的激励论证是：拥有大量 CPU 的 greedy attacker 可能发现按规则 mining 比攻击并贬损自身 wealth 更有利。这是 incentive plausibility argument，不是形式化证明所有 rational miners 都诚实，也不覆盖 external motives、pool centralization 或 protocol bugs。

### Tradeoffs

- Subsidy 解决初始 money distribution 与 bootstrapping hash power，却引入货币发行规则。
- Fees 给长期 security budget，但 miners 可优先高-fee transactions，低费 transactions 的 inclusion latency 不确定。
- PoW 提供开放系统中昂贵、易验证的 Sybil resistance，却消耗 energy 和 specialized hardware，并可能推动 mining pools 集中。
- Currency 与 consensus incentive 绑定，使 security depends on economic value；使用 existing currency 还需外部 settlement/mint，不能仅靠 ledger entry 完成支付。

FAQ 的具体 reward/market/pool 数字属于编写时点；本指南不把它们当作 2008 paper 固定参数或当前事实。

## 8. Storage、SPV 与 privacy 边界

### 8.1 Merkle tree 与 disk reclaim

Transactions 组织成 Merkle tree，block header 只包含 root。已花的早期 transactions 足够深后，可 prune tree branches，只保留必要 hashes；论文估算每年 `4.2 MB` 的是 **80-byte block headers**，不是 full blocks。FAQ 专门澄清 full-block storage 远大于 header-only estimate。

Merkle tree 提供一笔 transaction 到 block root 的 compact inclusion proof；它不单独证明 transaction 未 double-spent或所在 chain 是最大-work chain。

### 8.2 Simplified Payment Verification (SPV)

SPV client 保存 longest-work chain 的 headers，并获取 linking transaction to block 的 Merkle branch。它能看到 network 接受了 transaction 以及后续 confirmations，却不自行验证全部 transaction history。

- Honest nodes control network 时较可靠；
- Attacker overpower network 时更易欺骗；
- Alert strategy 可触发下载 full block/transactions；
- Frequent-payment businesses 可能仍应运行 full node，以获得独立验证和更快检查。

因此 SPV 用较小 storage/verification cost 换更强 trust assumption。

### 8.3 Privacy

Public ledger 无法像 bank 一样只让交易双方看记录。论文建议用 unlinkable public keys/pseudonyms，并每笔 transaction 使用新 key pair；但 multi-input transactions 会暴露共同 ownership clues。Summary 更直接警告“anonymous”说法不可靠：公开历史可被 retrospective linkage/de-anonymization。这里保证的是 pseudonymity heuristic，不是 confidentiality 或 anonymity theorem。

## 9. §11 攻击者追赶模型与结论边界

设：

- $p$：honest network 找到 next block 的概率；
- $q$：attacker 找到 next block 的概率；
- $z$：attacker 落后 blocks 数。

Gambler's Ruin 类比给出 attacker 最终追平概率：

$$
q_z=
\begin{cases}
1,&p\le q\\
(q/p)^z,&p>q.
\end{cases}
$$

若 $p>q$，概率随 $z$ exponential decline；若 attacker 算力不小于 honest side，等待更多 confirmations 不会恢复同一安全结论。

Recipient 不知道 attacker 在等待期间偷偷挖了多少 blocks。论文假设 honest side 产生 $z$ blocks 的时间等于平均期望，以 Poisson distribution 估 attacker progress，求其已追上或未来能追上的总概率。Paper 给出的 table 显示 confirmations requirement 对 $q$ 高度敏感，例如同一 failure probability 下 attacker share 越接近 0.5，需要的 $z$ 急剧增大。

### 模型限制

- 这是 paper 自身的 stochastic model 与 assumptions，不是对实际 network delay、mining strategy、difficulty variation 和 software behavior 的完整 modern security proof。
- Summary 明确把自身 double-spend discussion 称作 informal plausibility argument，并指出原 paper 也没有 rigorous security analysis。
- Confirmations policy 必须结合 transaction value、goods reversibility、network condition 和 threat estimate；不能把一个固定数字当绝对标准。

## 10. Primary paper 与 external summary 对照

| 主题 | Nakamoto paper | Nielsen summary | 使用方式 |
| --- | --- | --- | --- |
| 起点 | Electronic cash、trusted third party、double spending | 从 signed intent 的 Infocoin 逐步加机制 | Summary 帮助理解设计动机；protocol claim 回 paper |
| Coin model | Chain of signatures，后文 multiple inputs/outputs | 先用 serial numbers，再转向 transaction hashes/outputs | 不把 Infocoin serial number 当 Bitcoin field |
| PoW | Timestamp chain、one-CPU-one-vote、attacker probability | 用 nonce/leading zeros 做详细直觉演示 | Summary example 不是 network parameter specification |
| Fork resolution | Longest/greatest-work chain、nodes extend accepted branch | 图示双 forks、miners 切换、6 confirmations example | 6 是 summary/pedagogical policy，不是 deterministic theorem |
| Transaction format | 高层 ownership/value model | 反序列化、缩写的 historical raw transactions | 用于解释 input/output/change，不作 wire spec |
| Security | Honest CPU majority、§11 probability | 明确承认只是 informal analysis | 保留 assumptions 与未覆盖 attacks |
| Privacy | Public keys anonymous、key rotation、multi-input linkage | 强调 public ledger 可被去匿名化 | 不宣称 Bitcoin anonymous |
| Historical numbers | 2008 design estimates | 2013 rewards/wallet/ecosystem examples | 只作为文献当时背景，不写成当前状态 |

## 11. FAQ 与课堂连接

- FAQ 的第一条与课堂主线一致：owner signature 不防 owner 自己签两笔冲突 spends；blockchain 是 publishing/ordering mechanism。
- 课堂先排除三类熟悉方案：trusted server 违背 decentralization；SUNDR 可检测 fork 但不选择共同 branch；Raft 依赖已知 membership/quorum。PoW 用真实资源代替可伪造身份。
- 课堂强调 P2P flooding：nodes 只连接少量 peers，transactions/blocks 逐跳传播；local transaction pools 不必相同，winning block 才决定本轮 ordered contents。
- FAQ 解释 10-minute interval 的结构性原因：应显著大于 flood 大 block 所需时间，减少 near-simultaneous blocks。缩短 interval 或增大 blocks 会提高 fork/stale-work、bandwidth 和 independent-validation cost。
- 课堂区分 ordinary temporary block fork 与 software-rule soft/hard fork；paper 重点是前者。不能把所有“fork”混为 attack 或 protocol upgrade。
- 课堂 NOTES 也区分完整 blockchain 与 current unspent state/index。Merkle pruning/SPV 可降低部分 storage/verification cost，但新 full node 独立验证历史仍有代价。
- Security boundary：Majority work 可重组/censor/double-spend attacker's own payment，但不能伪造他人 signature；wallet/private-key theft 是另一层问题。

## 12. Paper Question / Homework

**题目原文（逐字保留）：**

> Bitcoin Try to buy something with Bitcoin. It may help to cooperate with some 6.824 class-mates, and it may help to start a few days early. If you decide to give up, that's OK. Briefly describe your experience.

这是 experiential assignment，不存在由论文推导出的唯一“正确购买结果”。下面只给记录与推理脚手架，不替你虚构或提交一次交易经历：

1. 先记录你实际尝试的 date/time、jurisdiction、merchant/service 与目标商品；服务可用性和规则会随时间变化。
2. 区分步骤：取得 wallet/address、取得可支付 balance、merchant 生成 request、broadcast、看到 pending、入块/confirmations、merchant 最终接受或失败。
3. 每一步记录真实 observation：fee quote、等待时间、UI status、identity/KYC requirement、exchange-rate movement、error message。不要填没有亲自观察的数据。
4. 把 experience 映射到 paper mechanism：signature/ownership、transaction broadcast、miner inclusion、confirmation depth、fee incentive；只解释你实际碰到的部分。
5. 说明失败也有效：若因 merchant 不支持、on-ramp、fees、policy、latency 或 usability 放弃，写出停止在哪一步和直接证据。
6. 区分 protocol cost 与 service/UI/policy cost。例如 KYC 不由 Nakamoto consensus 定义；confirmation delay 才直接连接 block production。
7. 保护隐私：不要提交 private key、seed phrase、完整身份资料或不必要的可追踪 transaction metadata。

## 13. 理解检查：10 组问答

1. **问：为什么 digital signature 不能单独防 double spending？**  
   **答：** Owner 可对两个引用同一 prior output 的 transactions 都合法签名；必须由共同有序历史判断哪个 first spend 有效。（来源：论文 §2、FAQ）

2. **问：Previous-block hash 与 PoW 分别提供什么？**  
   **答：** Hash link 让改旧 block 破坏 descendants；PoW 让重建并超过公共 branch 需要累积真实计算工作，并给 competing histories 一个选择规则。（来源：论文 §3-§4）

3. **问：为什么 one-IP-one-vote 不适合开放 network？**  
   **答：** IP/identity 可低成本批量创建；PoW 把获胜概率绑定到更难伪造的计算资源投入。（来源：论文 §4、课堂 NOTES）

4. **问：两个 valid blocks 同时出现是否说明系统被攻击？**  
   **答：** 不一定。Network delay 或 miners 近同时找到 nonce 就会产生 temporary fork；后续累计 work 使 nodes 收敛到一支。（来源：论文 §5、FAQ）

5. **问：Six confirmations 是否给绝对不可逆保证？**  
   **答：** 否。确认增加 attacker 需追赶的 work，在 $q<p$ model 下使概率下降；风险仍依 attacker share 和 assumptions 而非固定阈值突然归零。（来源：论文 §11）

6. **问：拥有 majority hash power 能直接偷走别人的 coin 吗？**  
   **答：** 不能在没有 private key 时生成 victim signature；它能重组 recent history、double-spend 自己的 payment 或 censor transactions。（来源：论文 §11、课堂讲义）

7. **问：Merkle branch 证明了什么，没证明什么？**  
   **答：** 它证明 transaction 被承诺在某 block root 中；还需 header chain/work 与 validity checks 才能判断该 block 属于 accepted history且交易有效。（来源：论文 §7-§8）

8. **问：SPV 相比 full node 牺牲了什么？**  
   **答：** 它不自行验证全部 transactions，只用 headers、Merkle proof 与 network information，因此 storage 小但在 attacker overpower network 时更易受骗。（来源：论文 §8）

9. **问：为什么 public keys/pseudonyms 不等于 anonymity？**  
   **答：** 全部 transactions 公开，address reuse 和 multi-input linkage 可关联 activity；real-world identity 一旦映射到 key，历史可被追溯。（来源：论文 §10、external summary）

10. **问：External summary 与 paper 的证据优先级是什么？**  
    **答：** Summary 的 Infocoin/transaction examples 用于理解“为什么”；协议定义、原始 security assumption 与公式回到 Nakamoto paper，历史数字不当作当前事实。（来源：两份 assigned readings）
