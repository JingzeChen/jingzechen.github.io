# 本讲
Lecture 11: Scaling laws

请输出以下部分：

## 学习目标
## 需要的先修知识
## 老师的教学主线
## 核心概念与依赖关系
## 关键推导、例子与结论边界
## 易错点与待核对项
## 掌握标准
## 复习顺序

保留时间戳和课件页码引用。不要重复粘贴全部片段笔记，也不要省略重要推导。

# 逐段课堂笔记

--- 片段笔记 1 ---
## 本段在整讲中的作用
- 本段是整讲的开场与路线图。老师先把本讲放回前两讲讨论过的经典 scaling laws 脉络里，再说明今天要补上的，是“真正把语言模型往上做大时”的实践细节。[00:00:05-00:03:05]
- 随后他把第一部分的材料范围定下来：先看近两年公开模型里的 scaling recipe，再把讲义后半部分落到 optimizer、initialization、learning rate、batch size 这些随规模漂移的敏感量上。[00:03:05-00:10:03]

## 教学展开
- 00:00:05-00:01:15，老师先说今天是一个“grab bag”，但主题并不散：核心是 scaling laws 的更细节版本，以及“实践里怎样把模型做大”。他把问题直接落在四件事上：LM 的 scaling 与 hparam tuning 最佳实践、Chinchilla 是否真的在现实开源模型尺度上成立、能否减少拟合 scaling law 的算力，以及是否该挑某些更容易扩展的 architecture / parametrization。[课件: lecture_11.pdf p.2]
- 00:01:15-00:02:16，他补充今天的第一部分会回到 2022 之后的新论文，尤其是“真正训练大模型的人”写的 scaling paper。老师明确说，这类论文近年变少了，而且大量来自中国开源社区；他今天选这些论文，是为了让大家看到“开放前沿”里的人到底关心哪些 scaling 问题。[00:01:37-00:02:16][课件: lecture_11.pdf p.3]
- 00:02:16-00:03:05，老师把第一部分的目标总结成一条实践路线：如果要从 Chinchilla 一路 speedrun 到 Kimi K2 这类较新的公开模型，你需要知道哪些 recipe 与判断框架。[00:02:06-00:02:16]
- 00:02:18-00:03:05，他再把整讲拆成两部分：第一部分过公开 scaling recipe；第二部分谈 optimizers 和 initializations。这里他特别回扣两讲前讲过的 batch size 选择问题，说明 learning rate、batch size、initialization 都会随规模变化，必须一并想清楚。[00:02:18-00:03:05][课件: lecture_11.pdf p.4]
- 00:03:05-00:04:28，老师说明自己重点讲两篇论文：MiniCPM 和 DeepSeek。理由不是“最新”，而是它们都由认真做模型的人完成，而且对今天的关键问题给了两种明显不同的处理路线，适合当后续讨论的骨架。[课件: lecture_11.pdf p.5]
- 00:03:36-00:04:59，他先介绍 MiniCPM：2024 年的高性能小模型，当年在 1B 到 2.5B 档里非常强。老师强调它即便不是 2026 视角下的最强模型，也仍然是一个有代表性的 scaling case study，因为很多后来论文把这些套路默认掉了，不再细讲。[00:03:36-00:04:59][课件: lecture_11.pdf p.6-p.7]
- 00:05:00-00:06:31，话题转向 MiniCPM 的第一项关键技术：muP。老师先给目标，不先给推导：它想让“最优学习率在模型放大或缩小时尽量不变”。接着他按论文列出 MiniCPM 做的几件事，包括 embedding output 的缩放、残差按层数平方根缩放、矩阵形 tensor 按 fan-in / fan-out 调整初始化、按 tensor 设置学习率、再处理 LM head。[00:05:00-00:06:31][课件: lecture_11.pdf p.8]
- 00:06:31-00:07:13，老师提醒其中“按参数张量设置学习率”是比较异质的做法，如果之前没见过 per-parameter learning rate，这一点值得特别注意。这里他不急着推导，只先把配方摊开。[00:06:06-00:06:31]
- 00:06:32-00:07:13，他把 MiniCPM 的总体 scaling strategy 说清楚：不是直接暴力试很多个 1.5B 模型，而是先训练更小的一串模型，构建一条 scaling ladder，再往目标尺寸 extrapolate；最大 ladder 模型与最终发布模型之间约有 5 倍差距。[课件: lecture_11.pdf p.9]
- 00:07:13-00:10:03，本段最后落在 MiniCPM 想用 scaling analysis 拟合的三个敏感量：最优 batch size、最优 learning rate、以及 token-to-size ratio，也就是 Chinchilla 型的数据量与模型大小权衡。老师把这三个问题挂起来，作为下一段继续展开的入口。[00:07:01-00:10:03][课件: lecture_11.pdf p.9]

## 概念、符号与推导
- Chinchilla 式 token-to-size ratio：指数据量与模型大小之间的配比问题，本段只点出它是要被重新拟合的对象，还没有展开方法。[00:07:10-00:07:16]
- muP 在本段中的目标表述：希望最优学习率在模型宽度或总体规模变化时保持大致稳定；这是后面详细推导的出发点。[00:05:21-00:05:48]
- MiniCPM 的 recipe 组件在本段先以“操作列表”出现：embedding scale、depth / residual scale、矩阵初始化、per-parameter learning rate、LM head scaling。[00:05:50-00:06:31][课件: lecture_11.pdf p.8]
- Scaling ladder：先在小模型上做系统实验，再把拟合结果外推到目标模型；其意义是用较低成本锁定敏感超参数，而不是在目标模型尺寸上盲试。[00:06:32-00:07:01][课件: lecture_11.pdf p.9]
- 本段无公式推导。

## 例子与课堂提示
- [课件: lecture_11.pdf p.2] 把整讲的四个问题并排写出，服务于知识点：今天不是再证明一遍经典 scaling law，而是检查它在真实训练 recipe 里的可用性与成本问题。
- [课件: lecture_11.pdf p.3] 用 2024、2025、2026 的时间点提示“公开 scaling 细节的模型时间线”，服务于知识点：把课堂从 Kaplan / Chinchilla 的 2022 视野推进到近年的开源前沿。
- 老师把 MiniCPM 形容为“older papers 反而更适合教学”，服务于知识点：越新的 release paper 越可能把关键 recipe 当默认常识略过，所以学习者要回看较早但写得细的论文。[00:04:07-00:04:28]
- “不要 brute force 一堆 1.5B 模型，而是先建小模型 ladder”这一提醒，服务于知识点：scaling law 的价值首先在节省大模型调参成本，而不是生成漂亮图。[00:06:32-00:07:01]

## 本段掌握检查
1. 老师认为本讲要回答的四类实践问题是什么？
答案：LM scaling 与 hparam tuning 的最佳实践、Chinchilla 在真实开源模型上是否成立、能否减少拟合 scaling law 的算力、以及是否该选更易扩展的 architecture / parametrization。[00:00:27-00:01:15][课件: lecture_11.pdf p.2]
2. 本讲为什么重点挑 MiniCPM 和 DeepSeek 两篇论文？
答案：因为它们都来自认真做高性能模型的团队，而且对关键 scaling 问题采取了不同路线，适合用来搭建整讲的比较框架。[00:03:05-00:03:30]
3. MiniCPM 在本段里被当成哪类案例？
答案：它是 2024 年高性能小语言模型的公开 scaling case study，用来展示 muP、scaling ladder 和超参数外推这套做法。[00:03:36-00:04:59][课件: lecture_11.pdf p.6-p.7]
4. MiniCPM 想靠 scaling analysis 锁定哪三个敏感量？
答案：最优 batch size、最优 learning rate、以及 token-to-size ratio，也就是 Chinchilla 式数据与模型配比。[00:07:01-00:10:03][课件: lecture_11.pdf p.9]
5. muP 在本段里最核心的承诺是什么？
答案：希望在模型放大或缩小时，让最优学习率尽量保持稳定，而不是每放大一次模型就完全重调一遍。[00:05:21-00:05:48]

## 待核对项
- 00:04:47 附近 transcript 把 Gemma 识别成 “Jemma” 一类读音，中文笔记按模型名 Gemma 理解，但若需逐字引文应回听。[需回听 00:04:47]
- 00:05:54-00:06:14 老师口头列举 muP recipe 时并未在 transcript 中把每个 scale 的符号写完整；对应精确常数应以 [课件: lecture_11.pdf p.8] 为准。

--- 片段笔记 2 ---
## 本段在整讲中的作用
- 本段承接上一段抛出的三个敏感问题，先集中处理 MiniCPM 如何把 Chinchilla 型实验做得更便宜，核心对象是学习率 schedule 而不是模型结构本身。[00:10:03-00:10:57]
- 同时它也完成了老师想让学生记住的两个 MiniCPM 关键词：muP 用于稳定学习率，WSD 用于便宜地做数据维度 sweep。到了段末，这两点构成 MiniCPM 的主要 takeaway。[00:15:33-00:15:55]

## 教学展开
- 00:10:03-00:10:57，老师先回顾为什么 Chinchilla 实验昂贵：如果做 IsoFLOPs sweep，你会固定一个 FLOPs 预算，再在模型大小与 token 数之间换配比；但一旦增加训练序列数，cosine learning rate 的整体形状就跟训练总步数绑定，不能直接从较短 run 续训到较长 run。[00:10:05-00:10:57]
- 00:10:57-00:11:17，他把这个问题定性成“近似二次成本”：想试更多数据长度时，总得从头再训练，因为终止预算一变，整条 cosine schedule 都变了。[00:10:56-00:11:17][课件: lecture_11.pdf p.13]
- 00:11:09-00:12:04，老师引入 MiniCPM 给出的解决思路 WSD。它把学习率拆成 warmup、stable、decay 三段；warmup 常按固定步数定义，不依赖总训练长度；stable 段保持常数学习率；最后用较短的 decay 段快速降到接近 0，典型 decay 只占总训练的 10% 到 20%。[00:11:09-00:12:04][课件: lecture_11.pdf p.14]
- 00:12:04-00:12:38，他说明 WSD 的关键收益：只要把 checkpoint 回退到 stable 末尾，就可以延长训练并重新做一次 decay。这样重复使用前面的大部分训练，只需要重复最后约 10% 的代价，而不用把整个 pre-training run 重跑。[00:12:04-00:12:38][课件: lecture_11.pdf p.14]
- 00:12:49-00:14:06，老师接着比较 WSD 与 cosine 的性能。经验图像是：WSD 在 stable phase 看起来经常落后，但一进入 decay phase 就迅速把收益拿回来，最后通常能追平、接近甚至偶尔超过 well-tuned cosine。老师口头经验是 cosine 在很多情形里也许略好，但 WSD 足够接近，而且可续训这个性质太有用了。[00:12:49-00:14:06][课件: lecture_11.pdf p.15]
- 00:13:56-00:14:06，他还特别强调 decay 本身的重要性：如果没亲手调过，很容易低估最后这段 learning rate annealing 对终盘 loss 的影响。[00:13:50-00:14:06]
- 00:14:09-00:14:32，完成 WSD 之后，老师重新回到 Chinchilla analysis：现在可以先做一个长 run，再多次回滚 stable checkpoint 并重复 decay，从而廉价地得到数据维度上的 sweep；模型维度则另行 sweep，再做标准的 trade-off 分析。[00:14:09-00:14:32][课件: lecture_11.pdf p.16]
- 00:14:32-00:15:08，他评价 MiniCPM 作者选了 Chinchilla 的 method 1 和 method 3。老师个人并不认为这是最可靠的两种方法，但承认他们画出来的曲线相当平滑：method 1 的 lower envelope 基本像线，method 3 的 compute 与 non-embedding parameter trade-off 也还算顺。[00:14:32-00:15:08][课件: lecture_11.pdf p.17-p.18]
- 00:15:08-00:15:33，老师指出 MiniCPM 的 joint fit 指数与原始 Chinchilla 差别较大，因此论文才声称自己应当用“比 Chinchilla 多得多”的文本训练；不过老师本人不确定这是新的真实规律，还是拟合本身有些古怪。[00:15:08-00:15:33][课件: lecture_11.pdf p.18]
- 00:15:33-00:15:58，本段最后老师停下来总结：MiniCPM 主要记住两件事，一是 muP 作为稳定不同尺度学习率的技巧；二是 WSD 作为现在很常见、应该人人都知道的学习率 trick。[00:15:33-00:15:58]

## 概念、符号与推导
- IsoFLOPs 分析：固定总 FLOPs 预算，在模型大小与 token 数之间改变配比，观察最终 loss 或最佳配比如何变化。[00:10:05-00:10:19]
- cosine schedule 的限制：它必须事先知道训练的总 horizon，因此长度一改，整条 schedule 就不同，不能简单从旧 run 接着训。[00:10:24-00:10:56]
- WSD（warmup-stable-decay）学习率：
  - warmup：固定步数，不依赖总训练长度；
  - stable：长时间恒定学习率；
  - decay：末尾快速下降到接近 0，通常约占总训练的 10%-20%。[00:11:20-00:12:04][课件: lecture_11.pdf p.14-p.15]
- WSD 让数据维度 sweep 便宜的因果链：stable 之前的大部分训练可复用，只需从 stable 末尾重新展开并做新的末端 decay，因此重复成本接近总训练的最后一小段，而不是整段重训。[00:12:06-00:12:38]
- Chinchilla method 1 / method 3：本段只说 MiniCPM 采用 lower envelope 与 joint fit 两种方法，并未重新逐式推导；重点是它们在 WSD 支持下可以更便宜地采样。[00:14:32-00:15:08][课件: lecture_11.pdf p.16-p.18]
- 本段无新的正式公式推导，重点是训练计划与实验成本结构。

## 例子与课堂提示
- “8 million sequences 的 run 不能从 4-million sequence 的 run 末尾直接接着训练”是本段最具体的反例，服务于知识点：为什么 cosine schedule 会把 Chinchilla sweep 变成重复训练的大坑。[00:10:44-00:10:56]
- [课件: lecture_11.pdf p.15] 中 WSD 曲线“前面看着差，进入 decay 突然追回来”的现象，服务于知识点：不要只看 stable phase 的 loss，就断言 schedule 不行。
- 老师引用 ETH 的 WSD 研究与多篇相似图，服务于知识点：WSD 不是单一论文的偶然技巧，而是被多个实验反复观察到的可复用 recipe。[00:12:54-00:13:06][需回听 00:12:59]
- 老师对 MiniCPM 的 Chinchilla 指数保持怀疑，服务于知识点：漂亮曲线不等于物理真理，拟合本身也可能因方法选择而偏移。[00:15:08-00:15:33]

## 本段掌握检查
1. 为什么 cosine learning rate 会让 Chinchilla sweep 昂贵？
答案：因为 cosine schedule 依赖总训练长度，训练 horizon 一变，整条 schedule 都不同，所以较短 run 不能直接续成较长 run，只能重训。[00:10:24-00:10:56]
2. WSD 学习率由哪三个阶段组成？
答案：warmup、stable、decay；warmup 通常是固定步数，stable 保持常数学习率，decay 在末尾快速下降。[00:11:20-00:12:04][课件: lecture_11.pdf p.14]
3. WSD 为什么能显著降低 Chinchilla 式数据 sweep 的成本？
答案：因为可以在 stable phase 末尾回滚 checkpoint，再只重复 stable 之后的部分和末尾 decay；通常只需重付大约 10% 的代价，而不是整段重训。[00:12:06-00:12:38]
4. 老师如何评价 WSD 与 cosine 的效果差异？
答案：cosine 在许多场景可能略好，但 WSD 往往能在末端追回来，整体接近得多，而且续训便利使它成为非常实用的默认选择。[00:13:09-00:14:06]
5. MiniCPM 作者在 Chinchilla 分析里主要采用了哪两种方法？
答案：method 1 的 lower envelope 和 method 3 的 joint fit；老师承认曲线好看，但不完全信它们最可靠。[00:14:32-00:15:33][课件: lecture_11.pdf p.16-p.18]

## 待核对项
- 00:12:59 附近老师提到 ETH 的研究者名字，transcript 未稳定识别；这里只保留“ETH 的 WSD 研究”，如需精确作者名应回听。[需回听 00:12:59]
- 00:15:17-00:15:29 老师对 MiniCPM joint fit 的怀疑是口头判断，不是 slide 上的正式结论；若需论文级表述，应区分“论文主张”与“老师课堂评价”。

--- 片段笔记 3 ---
## 本段在整讲中的作用
- 本段完成从 MiniCPM 向 DeepSeek 的切换，并把“敏感超参数该如何处理”明确拆成两条路线：一条是像 muP 那样尽量稳定它们，另一条是像 DeepSeek 那样直接拟合它们的 scaling law。[00:20:03-00:22:30]
- 在此之后，老师又快速扫过 Qwen、Kimi K2、Hunyuan、LLaMA 3、MiniMax-01，说明 2024 以后很多 open release 已把这套 scaling 思路内化，只是各自把重点转向 MoE sparsity、architecture choice 或下游映射。[00:22:35-00:29:59]

## 教学展开
- 00:20:03-00:20:43，老师先说 2024 年仍处在“开源模型几乎都在复刻整套 scaling law stack”的阶段，因此 DeepSeek 也像 MiniCPM 一样做了 Chinchilla replication，并同样使用 WSD 风格学习率，只是它采用了两个 10% decay step 这种小变体。[课件: lecture_11.pdf p.19-p.22]
- 00:20:39-00:21:14，他认为 DeepSeek 的曲线比 MiniCPM 更干净，原因在于 DeepSeek 用了 IsoFLOPs sweep，因此在固定 FLOPs 上得到更整齐的数据曲线和更清楚的数据-模型 trade-off。老师用这个例子说明：Chinchilla laws 不只是原论文成立，后来其他大算力开源团队也复制出了类似现象。[00:20:46-00:21:18][课件: lecture_11.pdf p.23-p.24]
- 00:21:25-00:22:03，老师指出 scaling law 工作的“终极 punchline”并不是曲线本身，而是：先训练一串 carefully curated 的小模型，拟合 power law，再去预测真正的大模型。DeepSeek 论文里两颗星是实际训练的大模型，灰点是 scaling fit，预测已经相当接近真实结果。[00:21:25-00:22:03][课件: lecture_11.pdf p.24]
- 00:22:14-00:22:30，本段第一个小结是：面对学习率和 batch size 这些敏感量，一种办法是稳定它们，另一种办法是直接拟合它们的 scaling。DeepSeek代表后者。[00:22:14-00:22:30]
- 00:22:35-00:23:27，老师说再新的论文一般不再大篇幅重讲这些基础套路，因为行业里已把它们当成共识。例如 Qwen 2.5 直接说会做一批 scaling experiment 去找 batch 和 learning rate 的 optimum，再拟合规律；Qwen 3 则说“我们就沿用 Qwen 2.5 的做法”。[课件: lecture_11.pdf p.25]
- 00:23:34-00:24:04，话题转到 Kimi K2。老师说这类更近的论文，把焦点从“会不会做 Chinchilla / LR scaling”转向“MoE 特有的 scaling 问题”，尤其是激活参数规模与 sparsity 应该怎么选。[课件: lecture_11.pdf p.26]
- 00:24:04-00:24:58，他解释 Kimi K2 类 MoE scaling 的逻辑：在不同 sparsity 下看 FLOPs 与 loss 的关系，稀疏度越高，给定 FLOPs 的验证损失通常越好；因此团队可以用曲线判断在哪个稀疏度点出现 diminishing returns，再据此做结构决策。Kimi K2 在课堂口述里选择 sparsity 48 就是这样来的。[00:24:04-00:24:58]
- 00:25:04-00:25:38，老师再给 Hunyuan 一个并行例子：同样是 MoE scaling，但它固定 sparsity，主要拟合的是 data-to-active-parameter ratio，最终给出 96:1 的比例。[课件: lecture_11.pdf p.27]
- 00:25:38-00:26:40，LLaMA 3 的部分，老师认为“最有意思的”不是左边常见的 IsoFLOPs token-to-model ratio，而是右图把预训练 log loss 映射到下游 accuracy：他们用一条 sigmoid 去拟合“loss 变好时 benchmark accuracy 如何上升”。老师提醒这些点并不完美落在线上，所以别把它当唯一真理，但它至少说明 log loss 与下游正确率在不少场景下确实紧耦合。[课件: lecture_11.pdf p.28]
- 00:26:59-00:28:02，最后是 MiniMax-01。老师特别喜欢它的理由是：它把 scaling law 用到了 architecture selection 上。论文比较 lightning attention、softmax attention 与 hybrid architecture 在不同 FLOPs 下的学习曲线与所需参数规模，结论是三者大体可比，因此这些图被用来为最终 deployed system 采用 hybrid architecture 辩护。[课件: lecture_11.pdf p.29]
- 00:28:09-00:29:59，本段最后老师把 recent scaling recipes 收束成一张总表：
  - DeepSeek 路线：默认大多数 transformer hparam 对规模稳定，再用小规模实验拟合最优 batch / LR，配合 IsoFLOPs 选模型尺寸，并用 piecewise-linear / WSD schedule 降低 Chinchilla 成本；
  - MiniCPM 路线：用 muP 主动稳定 transformer 与 learning rate，再用分段 schedule 为 Chinchilla method 3 提供廉价样本；
  - 更晚近的论文则常只披露一小部分，如 Qwen 的 LR/batch、Kimi K2 的 MoE scaling、LLaMA 3 / Hunyuan 的 isoflops、MiniMax 的 architecture scaling。[课件: lecture_11.pdf p.30]

## 概念、符号与推导
- DeepSeek 路线的核心假设：不主动使用 muP 去让超参数不变，而是承认最优 batch size 和 learning rate 会随规模变，再通过小规模实验拟合出变化规律。[00:22:14-00:22:30]
- IsoFLOPs curve 在这里再次承担两个角色：
  - 用于数据量与模型大小的 trade-off；
  - 让真实大模型的 loss 能被小模型 power-law 拟合预测。[00:20:46-00:22:03][课件: lecture_11.pdf p.23-p.24]
- MoE scaling 本段的关键变量是 sparsity 与 active parameters：给定 FLOPs，看不同稀疏度下 loss 如何变化，再从 diminishing returns 找部署用的 sparsity 或 active-parameter ratio。[00:24:04-00:25:38][课件: lecture_11.pdf p.26-p.27]
- LLaMA 3 的“loss 到 accuracy 映射”概念：在常规 scaling law 的左图之外，再用 sigmoid 近似预训练 log loss 与下游准确率的关系，作为预测模型最终效能的辅助桥梁。[00:25:51-00:26:40][课件: lecture_11.pdf p.28]
- Architecture scaling：比较不同注意力架构在 FLOPs 轴上的学习曲线与参数需求，进而用 scaling law 为架构选择背书。[00:26:59-00:28:02][课件: lecture_11.pdf p.29]
- 本段无公式推导。

## 例子与课堂提示
- DeepSeek 的“两颗星 vs 一堆灰点”是非常经典的 scaling law 终局图像，服务于知识点：真正有用的不是小模型本身，而是它们能否把大模型预测准。[00:21:25-00:22:03][课件: lecture_11.pdf p.24]
- Qwen 2.5 / 3 的例子说明：一旦一个 recipe 成熟，它往往会在后续论文里被一句话带过，服务于知识点：读最新论文时不要误以为大家突然不做 scaling 了，而是默认你已经懂了这套基本功。[00:22:55-00:23:27][课件: lecture_11.pdf p.25]
- Kimi K2 的 sparsity 48 例子服务于知识点：scaling law 不只决定 tokens 和参数，也能直接决定“结构应该多稀疏”。[00:24:47-00:24:58]
- LLaMA 3 的 sigmoid 映射与老师的保留意见，服务于知识点：从预训练 loss 推下游能力虽然实用，但不能把拟合曲线当成唯一机制解释。[00:26:13-00:26:40]
- MiniMax-01 的 lightning / softmax / hybrid 对比，服务于知识点：scaling law 还可以用来做 architecture selection，而不只是做算力预算和 token 配比。[00:26:59-00:28:02]

## 本段掌握检查
1. DeepSeek 代表的是哪一种处理敏感超参数的思路？
答案：不是用 muP 去稳定它们，而是通过小规模实验直接拟合最优 batch size 和 learning rate 的 scaling law，再把规律外推到大模型。[00:22:14-00:22:30]
2. 老师为什么认为 DeepSeek 的 scaling 曲线比 MiniCPM 更“干净”？
答案：因为它使用了 IsoFLOPs sweep，所以在固定 FLOPs 上的数据曲线更整齐，trade-off 也更清楚。[00:20:46-00:21:14]
3. Kimi K2 这类较新的论文把 scaling law 重点转向了什么？
答案：转向 MoE 的 sparsity / active-parameter scaling，用来决定稀疏度与激活参数规模的结构选择。[00:23:54-00:24:58][课件: lecture_11.pdf p.26]
4. LLaMA 3 的 scaling 图里哪一部分最让老师觉得有意思？
答案：右图把预训练 log loss 映射到下游 accuracy，用 sigmoid 近似这种关系。[00:25:51-00:26:40][课件: lecture_11.pdf p.28]
5. MiniMax-01 用 scaling law 支持了哪类决策？
答案：支持 architecture choice；通过比较 lightning、softmax、hybrid 三类架构在不同 FLOPs 下的表现，最后为 hybrid 架构背书。[00:26:59-00:28:02][课件: lecture_11.pdf p.29]

## 待核对项
- 00:24:47 “sparsity of 48” 是老师口述的选点结果，若需与原论文中的具体 sparsity 定义完全对齐，建议回查论文图例与单位。
- 00:25:28 transcript 中把 “96 data point per active parameter ratio” 写法较口语化，这里按老师原意理解为 data-to-active-parameter ratio 为 96:1。[课件: lecture_11.pdf p.27]

--- 片段笔记 4 ---
## 本段在整讲中的作用
- 本段是整讲从“公开 recipe 巡礼”进入“DeepSeek 风格方法学”的桥段。老师把后半讲明确拆成两件事：先讨论学习率、batch size 与 optimizer 的 scaling law；再讨论 muP 这种试图直接消除规模漂移的方法。[00:30:27-00:31:04]
- 这一段内部又先完成前一半中的“StepFun 超参数研究”，给出一个较新的、纯经验 grid-search 路线，作为后面 optimizer 讨论和对 DeepSeek 方法的扩展基础。[00:31:11-00:39:23]

## 教学展开
- 00:29:59-00:30:26，老师先回答一个过渡问题：pre-training scaling law 与 post-training 的协同目前并没有好答案，最多只有一些关于 coverage / diversity 的早期工作，因此本讲基本仍聚焦 pre-training 侧的 scaling。[00:29:59-00:30:26]
- 00:30:27-00:31:04，他明确宣布后半讲的结构：先讲 DeepSeek 路线，也就是 learning rate、batch size、optimizer 的 scaling law；再讲 MiniCPM 路线，也就是 muP 这种“重新参数化模型，让规模变化不那么烦”的方法。[00:30:27-00:31:04]
- 00:31:04-00:31:48，老师引入 StepFun 的一篇较新的预印本，评价是“也许还谈不上最终可靠真理，但已经相当接近”，因为它来自会训练可信大模型的团队，而且烧了很多算力去系统 grid search 超参数空间。[00:31:11-00:31:48][课件: lecture_11.pdf p.31-p.32]
- 00:31:51-00:33:15，他先从一张表开始，概括已有不同 scaling 公式的分歧。OpenAI / Kaplan 用 critical batch，把 batch 视作 terminal loss 的函数；DeepSeek 把 learning rate 与 batch 都看成 compute 的幂函数；MiniCPM 还有另一套思路。老师强调连“到底该把什么当自变量”都没有共识，这意味着不要把任一条经验公式当终极真理。[00:31:51-00:33:15][课件: lecture_11.pdf p.33]
- 00:33:31-00:34:10，回到 StepFun 的实验设计：做法很像 DeepSeek，只是更大规模、更高分辨率。它在不同模型大小与数据规模下，对 learning rate 与 batch size 做大量 grid search，试图把最优区域“填满”。[00:33:31-00:34:10][课件: lecture_11.pdf p.34]
- 00:34:10-00:35:05，老师解释高分辨率 contour plot 的意义。这里固定了模型与总数据量，例如约 1B 参数和 100B tokens 的切片后，把 batch 与 learning rate 作为两个轴，loss 作为高度或颜色。因为等高面看起来平滑而近似凸，所以在这种空间里寻找最优点是可行的。[00:34:10-00:35:05][课件: lecture_11.pdf p.35]
- 00:35:20-00:36:02，他说这篇工作的第一条有趣结论是：最优 batch size 基本只主要依赖数据量 $D$，而与模型大小关系不大。不同颜色代表不同模型，但在 log-log 图里都大体落在同一条趋势线上。[00:35:20-00:36:02][课件: lecture_11.pdf p.36]
- 00:36:08-00:36:40，第二个观察是 learning rate 的依赖更复杂：模型更大时，最优 learning rate 更小；数据更多时，最优 learning rate 反而更高。老师承认这点有些反直觉，也提到若换到 WSD 或别的设定，关于 $D$ 的依赖可能更脆弱。[00:36:08-00:36:40][课件: lecture_11.pdf p.36]
- 00:36:45-00:37:39，第三个观察是这些 scaling 关系在一定程度上能泛化到 MoE。黄星是 scaling law 的预测，红叉是直接在 MoE 上重新找出来的 optima；只要大致按 active parameters 对齐，两者没有出现完全不同的规律。[00:36:45-00:37:39][课件: lecture_11.pdf p.37]
- 00:37:44-00:38:04，老师马上加一个边界条件：如果换训练数据分布，最优 learning rate 与 batch size 还是会漂移，因此这类公式本质上对数据有条件性，不是脱离数据就能永远通用的物理常数。[00:37:44-00:38:04]
- 00:38:08-00:39:03，他把 StepFun 结论重写成直觉版：batch size 大体像数据量的平方根，learning rate 随数据增大而上升、随模型增大而下降；如果再把 Chinchilla 假设加回去，随着总 compute 变大，你最后会重新得到一种“batch 随 compute 上升，learning rate 随 compute 下降”的规律，只是具体指数未必与 DeepSeek 相同。[00:38:08-00:39:03]
- 00:39:03-00:39:58，本段最后老师把 StepFun 定位为“目前较新且较大规模的 DeepSeek 式分析版本”，即：如果你选择 scaling-law fit 这条路，它大致展示了一个严肃团队会怎样做。[00:39:03-00:39:58]

## 概念、符号与推导
- critical batch（Kaplan/OpenAI）：把最优 batch size 表达成最终 loss 的函数，而不是 compute 或数据量的函数。[00:32:13-00:32:30][课件: lecture_11.pdf p.33]
- DeepSeek 型公式：把 batch 与 learning rate 看成 compute 的幂函数，通过小模型实验拟合参数，再外推到大模型。[00:32:33-00:32:44]
- StepFun 方法的主要自变量：模型大小、数据量 $D$、batch size、learning rate。它通过高分辨率 grid search 观察 loss surface 的形状，再从最小值提取 scaling trend。[00:33:31-00:35:05]
- 本段的经验结论：
  - 最优 batch size 主要由数据量 $D$ 驱动；
  - 最优 learning rate 随模型增大而减小，随数据量增大而增大；
  - 在 MoE 上若控制 active parameters，这些规律在一阶上还能转移。[00:35:20-00:37:39]
- Chinchilla 约束下的口头推导：如果 $N$ 与 $D$ 都随 compute 同步变大，那么“learning rate 随 $D$ 增加”和“learning rate 随 $N$ 减少”会部分相互抵消，最终在 compute 维上表现成 learning rate 下降、batch 上升的趋势。[00:38:19-00:38:58]
- 本段无逐式数学证明，主要是把经验观察转写成口头 scaling 关系。

## 例子与课堂提示
- [课件: lecture_11.pdf p.35] 上平滑、近凸的 loss contour，服务于知识点：如果超参数空间高度锯齿化，就很难相信“靠 grid search 拟合规律”这套程序本身是可靠的。
- 老师对不同公式“连输入变量都不一样”的吐槽，服务于知识点：不要把任何一条 hparam scaling law 当成自然定律，它更多是条件性的经验规律。[00:32:44-00:33:15]
- MoE 上“黄星预测 vs 红叉真最优”的例子，服务于知识点：已有 scaling law 能不能 transfer，关键往往不是模型类别名义上变了没，而是你有没有用 active parameters 把它们大致对齐。[00:37:17-00:37:39]
- 老师反复提醒数据分布会改变最优 learning rate / batch，服务于知识点：超参数 scaling 与数据不是解耦的，因此他后面才会说 scaling law 里仍然有很多“vibes”。[00:37:44-00:38:04]

## 本段掌握检查
1. 老师为什么说现有学习率 / batch scaling 公式之间分歧很大？
答案：因为它们连自变量都不统一；有的用 terminal loss，有的用 compute，有的更强调数据量，因此不应把任一条公式当成唯一真理。[00:31:51-00:33:15][课件: lecture_11.pdf p.33]
2. StepFun 的实验设计与 DeepSeek 有什么相似之处？
答案：两者都通过大量小规模训练，对 learning rate 和 batch size 做 grid search，寻找最优点，再从这些最优点拟合 scaling 规律。[00:33:31-00:34:10][课件: lecture_11.pdf p.34]
3. StepFun 的主要经验结论之一是什么？
答案：最优 batch size 主要由训练数据量 $D$ 决定，不同模型大小的点在同一条 log-log 趋势线上大体对齐。[00:35:20-00:36:02]
4. 老师如何描述最优 learning rate 与模型大小、数据量的关系？
答案：模型更大时最优 learning rate 更小；数据更多时最优 learning rate 更高，不过后者可能更脆弱、依赖设定。[00:36:08-00:36:40]
5. 为什么这类 scaling law 仍然不能脱离数据集直接套用？
答案：因为一旦训练数据变了，最优 learning rate 和 batch size 也会发生漂移，所以公式本身对数据条件敏感。[00:37:44-00:38:04]

## 待核对项
- 00:34:26 老师口述“1B parameters and 100B tokens, I believe”，带有明显自我修正语气；若要给出精确实验切片，应回看原论文图注。[需回听 00:34:26]
- 00:36:33 老师引用 InternLM / Zhou+ 2026 作为反例线索，transcript 只保留了口头说明，没有完整书目信息；若需引用该论文应另查原文。[需回听 00:36:33]

--- 片段笔记 5 ---
## 本段在整讲中的作用
- 本段把 StepFun 式 hparam scaling 的讨论推进到一个更谨慎的位置：就算有现成 scaling law，也不能机械套用，仍然要看自己的 compute regime、regularization、架构与数据条件。[00:39:58-00:41:12]
- 接着老师正式进入 optimizer 部分，用 muon 这条故事线解释为什么“在小尺度 benchmark 上很强的东西，到大尺度不一定还强”，并由此总结两大必须警惕的 confounder：compute 轴与 Chinchilla ratio 轴。[00:41:40-00:49:56]

## 教学展开
- 00:39:58-00:41:12，老师先回答一个实际问题：已有 scaling law 能不能直接拿来用？他的回答是“看区间”。如果你的计算规模接近 StepFun 做 grid 的区间，它们大概是很好的默认值；但一旦你自己有不同的 weight decay、不同架构或其他 minor differences，很多团队还是会重做一遍 Chinchilla 与超参数分析，以确认这些差异不会把结论带偏。[00:39:58-00:41:12]
- 00:41:14-00:41:38，他进一步强调 scaling law 虽然看起来很“科学”，像是在拟合一条线再外推，但真正决定你敢不敢信它是否可迁移，仍然有大量经验判断，也就是他口中的 “vibes”。[00:41:14-00:41:38]
- 00:41:40-00:42:47，老师正式转入 optimizer。切入口是 NanoGPT speedrun：在这个很小的 benchmark 上，muon 相比 Adam 带来了非常显著的速度提升，看起来像是“只换一个 optimizer 就有大收益”。[00:41:40-00:42:47][课件: lecture_11.pdf p.38-p.39]
- 00:42:47-00:43:27，他马上提出研究困境：小尺度实验里很强的东西，放到大尺度会怎样？这不只是 muon 的故事，而是深度学习研究中最常见的问题：新方法在小模型上看起来很好，但扩展性如何并不自动清楚。[00:42:47-00:43:27]
- 00:43:39-00:44:50，接着老师引用一组大规模 optimizer 比较工作，先提醒最基础却最常被忽略的问题：不同优化器的最优超参数并不相同。学习率稍微没调准，就可能把 Adam 调得像一条表现很差的棕线；weight decay 没调对，也会让同一个优化器看起来被错误地打败。[00:43:59-00:44:50][课件: lecture_11.pdf p.39]
- 00:44:54-00:46:00，他说比“同算法不同超参数”更贴近本课主题的是 scale dependence。研究新算法时，至少要盯住两个轴。第一个轴是 compute：在固定模型-数据比例下，沿着 x 轴增加 compute，观察相对速度增益是否还存在。muon 在小尺度增益明显，但随着尺度增大，增益会下降。[00:44:54-00:46:00][课件: lecture_11.pdf p.40]
- 00:46:00-00:47:21，第二个轴是 Chinchilla ratio，即数据量与参数量的比例。老师解释为什么这是重要 confounder：有些算法可能在过参数化、小 ratio 区间靠隐式正则或 compute 效率占优；另一些算法可能在高 data-per-parameter 区间更好。因此只沿 compute 做 study、却不看 token-to-parameter ratio，是很常见也很危险的遗漏。[00:46:00-00:47:21]
- 00:47:21-00:47:59，他补一句：在当前举的这组 optimizer 例子里，Chinchilla ratio 并没有改变各条曲线之间的相对关系，所以这里它不是主要问题；但老师强调这只是“这次不是”，并不代表以后都不是。[00:47:03-00:47:21]
- 00:47:23-00:48:58，最后老师给出一个更尖锐的警示例子：Will Held 等人在开源训练项目里做 cautious AdamC 加平方根 batch-size LR scaling，看起来前面很多数量级都沿着漂亮直线走，到了更大规模却突然偏离再爆炸。修复方案包括更小心的 muP 风格参数化、scaling 调整和 optimizer 变化。这个例子说明：哪怕你已经看到“跨很多个数量级都很线性”的趋势，也不能保证再往上一定继续成立。[00:47:23-00:48:58][课件: lecture_11.pdf p.41]
- 00:49:01-00:49:56，本段最后老师再往回扣一次大主题：你当然应该做 scaling 实验，但也必须承认“建立某个方法真的能扩展”本身并不简单；好看的趋势线并不天然可靠。[00:49:01-00:49:56]

## 概念、符号与推导
- “直接套用现成 scaling law”与“重做自己的 grid search / Chinchilla 分析”之间的判断条件：看你是否处于相近 compute regime，以及你的 recipe 是否引入了足以改变规律的一阶因素，如较大 weight decay 或不同参数化。[00:39:58-00:41:12]
- optimizer 比较里的第一类混淆变量：不同算法往往有不同的最优 learning rate 与 weight decay；若不单独调优，就会把优化器比较与超参数失配混在一起。[00:43:59-00:44:50][课件: lecture_11.pdf p.39]
- 两个必须检查的 scaling 轴：
  - compute 轴：在固定 model/data ratio 下观察性能随规模变化；
  - Chinchilla ratio 轴：观察数据量与参数量配比变化时，算法相对优劣是否改变。[00:45:18-00:47:21][课件: lecture_11.pdf p.40]
- 本段的核心逻辑不是公式推导，而是实验设计原则：想证明某个 optimizer 或新算法“有效且可扩展”，至少要区分超参数失配、compute 变化和 token-to-parameter ratio 变化这几类混淆因素。
- 本段无公式推导。

## 例子与课堂提示
- NanoGPT speedrun 上 muon 的巨大收益，服务于知识点：小 benchmark 能提供好灵感，但不能自动推出大模型上也同样占优。[00:41:58-00:42:47][课件: lecture_11.pdf p.42-p.43]
- “调坏的 Adam 会看起来远差于别人；把 learning rate 稍微改对，收益就消失”这一对照，服务于知识点：optimizer 研究里最先要排除的是调参不公平，而不是先给算法下结论。[00:44:07-00:44:24]
- 老师把 Chinchilla ratio 解释成“每单位参数对应多少数据”，服务于知识点：很多算法并不是对所有数据/模型配比都一样有效，因此 ratio 本身就是实验轴，而不是附属变量。[00:46:05-00:46:47]
- cautious AdamC 那个“前面很好看，后面突然 blow up”的图，服务于知识点：建立 scaling 不是把一条线画得好看，而是要不断验证它是否在更大尺度仍站得住。[00:47:23-00:48:58][课件: lecture_11.pdf p.41]

## 本段掌握检查
1. 老师如何回答“已有 scaling law 是否能直接拿来用”的问题？
答案：要看你是否处在相近的 compute regime；若 recipe、regularization 或架构差异较大，通常仍值得重做自己的 hparam / Chinchilla 分析。[00:39:58-00:41:12]
2. 为什么老师说 scaling law 里仍然有很多 “vibes”？
答案：因为是否相信别人的实验能迁移到自己的设定，本质上仍含大量经验判断，不可能完全由一条拟合线自动保证。[00:41:14-00:41:38]
3. 研究 optimizer 扩展性时，老师要求至少看哪两个轴？
答案：compute 轴与 Chinchilla ratio 轴。[00:45:18-00:47:21]
4. 为什么 Chinchilla ratio 会成为 optimizer 研究里的重大 confounder？
答案：因为有些算法可能在低 data-per-parameter 区间靠隐式正则占优，另一些算法则在高 data-per-parameter 区间更好；如果不控制这个比例，就可能把配比效应误判成算法优劣。[00:46:05-00:46:47]
5. cautious AdamC 的例子告诉我们什么？
答案：即使一个新方法在许多数量级内表现出很好看的 scaling 直线，再继续放大也可能突然偏离甚至爆炸，所以“看起来能扩展”不等于“已经被证明能扩展”。[00:47:23-00:48:58][课件: lecture_11.pdf p.41]

## 待核对项
- 00:41:17 老师提到自己先前与一位同学或同事讨论过这件事，transcript 将名字静音处理；这里只保留讨论内容，不猜具体人名。[需回听 00:41:17]
- 00:47:36 相关开源项目与博客的精确名称以 [课件: lecture_11.pdf p.41] 中链接为准；transcript 只保留了口头叙述。

--- 片段笔记 6 ---
## 本段在整讲中的作用
- 本段先把 optimizer 话题从“怎么做公平的 scaling 比较”推进到一个具体对象 muon，给出它的算法直觉、矩阵参数视角与在小尺度/大尺度之间摇摆的经验故事。[00:49:56-00:54:45]
- 然后老师通过现场问答补上三个现实层面的提醒：它为什么不是 SVD、为什么它会带来分层或分参数优化的想法、以及为什么大家通常只格 learning rate 和 batch 而不格完整超参数空间。[00:54:45-00:59:56]

## 教学展开
- 00:49:56-00:50:24，老师先从标准 momentum optimizer 开始：梯度进来，累积成 $B_t$ 这类动量量，再用它更新参数。这一部分是为了给 muon 的“只改 update 形状、不改前面动量累积”的结构找参照物。[00:49:56-00:50:24]
- 00:50:24-00:50:57，他提出 muon 的出发点：传统梯度更新把所有参数都一视同仁，但语言模型里的参数并不相同。RMSNorm 那类 vector 参数与 attention / MLP 的 matrix 参数，本来就可能需要不同对待。[00:50:24-00:50:57]
- 00:50:57-00:52:41，接下来老师讲 muon 的核心步骤。对矩阵参数来说，可以看更新矩阵 $B_t$ 的谱；把它写成 $USV^\top$ 后，不直接用原始 $B_t$，而是把所有奇异值都改成 1，只留下方向，得到 $UV^\top$ 作为新更新。于是原来很大的奇异值被压回 1，很小的被拉回 1，本质上是在谱空间做规范化。[00:50:57-00:52:41][课件: lecture_11.pdf p.42]
- 00:51:55-00:52:41，老师给直觉对比：AdaGrad / Adam 是按坐标除以梯度大小，让每个 coordinate 量级类似；muon 则是在 spectral norm 意义上，把各个“方向”的尺度拉到单位量级。这也是为什么它只适用于矩阵，不适用于普通向量参数。[00:51:55-00:52:41]
- 00:52:27-00:52:49，他再说实现层面不是直接做 SVD，而是用 NewtonSchultz 的有限次矩阵乘近似正交化，所以系统上可行。[00:52:27-00:52:49][课件: lecture_11.pdf p.42]
- 00:52:52-00:54:11，随后老师回到 muon 的扩展性故事：它最初在 NanoGPT speedrun 这类很小的 benchmark 上非常亮眼；后来一些 scaling study 认为随着规模增大，muon 的收益会下降，似乎故事已经结束；但 Kimi K2 又把整个大模型都用 muon 训出来，并通过额外的稳定化技巧避免它爆炸。于是老师给出的结论不是“muon 已经证明比 Adam 更好”，而是“它至少在大规模上是可行的”。[00:52:52-00:54:11][课件: lecture_11.pdf p.43]
- 00:54:11-00:54:45，本段第一个总结是：判断一个新 optimizer 是否“在 scale 上成立”非常难；目前大家仍然只能靠小尺度实验启发，再慢慢迁移到大尺度做科学工作。[00:54:11-00:54:45]
- 00:54:57-00:55:31，在问答里老师回答“GPU 上 SVD 快吗”：muon 并不直接做 SVD，而是做 NewtonSchultz，这是一种只用矩阵乘法的有限步近似正交化算法。老师还强调 muon 的创新包含三层：把参数当矩阵看、做正交化、以及用系统友好的近似算法实现。[00:54:57-00:55:31]
- 00:55:35-00:56:14，第二个问题是“不同层超参数是不是也该不同”。老师回答是肯定的，并补充有些研究者甚至主张每层都应该有自己的 learning rate，进一步甚至每层自己的 optimizer。它的极端版本是：transformer 里的每种参数都不同，所以理论上都可能有自己的优化器与超参数；只是实践上非常不想调这么多。[00:55:35-00:56:14]
- 00:56:17-00:57:19，第三个问题问的是：大家只格 learning rate 和 batch，难道不怕它们和别的超参数交互吗？老师说当然怕，但完整格全空间维度指数爆炸，不现实。所以实际做法是：优先格最敏感、最关键的维度，通常是 learning rate 与 batch；然后像 weight decay 这类，再做一维 sweep 做局部补调。[00:56:17-00:57:19]
- 00:57:23-00:59:56，本段最后老师为下一段铺垫：接下来讲 muP。这里他先给目标而不展开推导，即“如果只增加模型宽度，理想中最优 learning rate 不该大幅漂移；为此我们愿意按层改初始化、按参数改 learning rate，甚至按模型规模缩放 residual 连接”。[00:57:23-00:59:56][课件: lecture_11.pdf p.44-p.45]

## 概念、符号与推导
- 标准 momentum 更新框架：先把梯度累积进 $B_t$ 之类的动量变量，再用该变量更新参数；muon 没改“先积累动量”这件事，改的是“把 $B_t$ 变成什么样再施加出去”。[00:49:56-00:50:24]
- muon 的矩阵更新思想：
  - 对矩阵参数的更新矩阵 $B_t$ 做奇异值分解 $B_t = USV^\top$；
  - 把奇异值矩阵 $S$ 归一成全 1；
  - 最终更新近似为 $UV^\top$。[00:51:15-00:51:54][课件: lecture_11.pdf p.42]
- 与 Adam / AdaGrad 的对比：Adam / AdaGrad 是 coordinate-wise 的尺度调整；muon 则是 spectral-direction-wise 的尺度调整。[00:51:55-00:52:19]
- 参数类型划分：矩阵值参数适合 muon；向量值参数（如 RMSNorm gain 等）通常仍用 AdamW，因为它们没有可用的矩阵正交化结构。[00:52:19-00:52:41]
- NewtonSchultz：对“把奇异值压成 1”的操作做矩阵乘法近似，因此比直接做 SVD 更系统友好。[00:52:41-00:52:49][00:55:04-00:55:14]
- 本段无新的数学证明，核心是算法步骤与实验判断。

## 例子与课堂提示
- NanoGPT speedrun 的大幅收益与随后大规模 study 的保留意见，服务于知识点：小尺度 benchmark 能提出候选算法，但无法独立完成大尺度结论。[00:52:52-00:54:11][课件: lecture_11.pdf p.43]
- Kimi K2“整模用 muon 训练”的案例，服务于知识点：至少说明 muon 不是只能在玩具任务上好看，而是能在严肃预训练里工作，只是“是否优于 AdamW”仍没有大规模 ablation 定论。[00:53:38-00:54:11]
- 老师对“每层一个学习率、甚至每层一个优化器”的描述，服务于知识点：优化器设计最终可能走向更细粒度的参数异质性建模，而不是默认全模型统一超参数。[00:55:43-00:56:14]
- “learning rate 和 batch 最先格，weight decay 之后单维补调”的经验，服务于知识点：现实里不是不担心超参数交互，而是在成本约束下优先处理最敏感维度。[00:56:47-00:57:19]

## 本段掌握检查
1. muon 与标准 momentum optimizer 的差别主要发生在哪一步？
答案：动量积累本身仍然类似，但在真正把更新施加到参数前，muon 会把更新矩阵做近似正交化，把奇异值归一后再应用。[00:49:56-00:50:24][00:51:15-00:51:54]
2. 为什么老师说 muon 是“矩阵优化器”？
答案：因为它依赖奇异值分解或其近似，只对矩阵值参数有意义；向量参数没有对应的谱结构，因此通常仍用 AdamW 一类优化器。[00:52:19-00:52:41]
3. muon 与 Adam / AdaGrad 的直觉差别是什么？
答案：Adam / AdaGrad 是按坐标缩放更新；muon 是在谱方向上把更新规范化到单位尺度。[00:51:55-00:52:19]
4. Kimi K2 对 muon 的故事意味着什么？
答案：它至少说明 muon 在大规模预训练中是可行的，但并不能单凭此断言它一定优于 AdamW，因为缺少完整的大规模 ablation。[00:53:38-00:54:11]
5. 为什么实际工作中大家通常只系统格 learning rate 与 batch？
答案：因为完整超参数空间交互维度太高，会指数爆炸；learning rate 与 batch 最敏感，所以先重点搜索它们，再对别的超参数做局部补调。[00:56:34-00:57:19]

## 待核对项
- 00:53:25 transcript 中有关“谁做了后续 scaling study”的名字不清，笔记只保留结论链条，不猜作者名。[需回听 00:53:25]
- 00:54:58 与 00:55:35 的学生提问中含有 [INAUDIBLE]，问题主旨可恢复，但精确措辞若需引用应回听。[需回听 00:54:58][需回听 00:55:35]

--- 片段笔记 7 ---
## 本段在整讲中的作用
- 本段是整讲最硬核的理论部分。老师不再停留在“muP 能让最优学习率更稳”的经验描述，而是开始给出一套简化但成体系的推导逻辑：先设不变量，再根据量级约束反解初始化与学习率该怎样随宽度变化。[00:59:56-01:00:44]
- 这一段只完成推导的前两步半：建立 A1 / A2 两个不变量、推导初始化的量级条件、再把 A2 的问题重写成“更新后的激活变化各项都要有合适量级”。真正解出学习率比例，会留到下一段开头完成。[01:08:34-01:09:54]

## 教学展开
- 00:59:56-01:00:40，老师先交代文献背景：Greg Yang 的 tensor programs 是这条研究路线的源头，但他个人觉得较难读；Jeremy Bernstein 的 review paper 更容易进入；Cerebras 也写过一些解释 muP 的文章。这里先把 muP 定位成一个仍在发展中的“program”，而不是一本定本教科书。[00:59:56-01:00:40]
- 01:00:40-01:02:03，随后他提出 muP 的两个核心不变量：
  - A1：网络初始化后，激活量级应保持 $\Theta(1)$；
  - A2：做一次梯度步之后，激活变化也应保持 $\Theta(1)$。
老师解释 A2 对应 feature learning：网络即使变宽，特征也应真正发生非消失的变化，而不是像某些 NTK 极限那样变化趋于 0。[课件: lecture_11.pdf p.46]
- 01:02:03-01:02:29，他补了一个尺度换算：如果单个 activation 是 $\Theta(1)$，那么整层向量的范数就应是 $\Theta(\sqrt{n_l})$。后面很多量级估计会在“单坐标 O(1)”与“整层范数 $\sqrt{n_l}$”之间切换。[00:02:12-00:02:29][课件: lecture_11.pdf p.46]
- 01:02:32-01:05:15，接着开始做 A1 的量级推导。老师考虑一个简单 deep linear net，设 $h_l = W_l h_{l-1}$，并用高斯初始化 $W_l \sim \mathcal{N}(0, \sigma^2 I)$。借随机高斯矩阵的 operator norm 量级，外加“输出范数近似等于 operator norm 乘输入范数”的近似，他反推：如果想让每层激活维持在应有尺度，就该选一个依赖 fan-in / fan-out 的 $\sigma$。验证方式是归纳：假设上一层范数是 $\Theta(\sqrt{n_{l-1}})$，把这个 $\sigma$ 代回去，就会得到本层范数是 $\sqrt{n_l}$ 加低阶项。[01:02:52-01:05:15][课件: lecture_11.pdf p.47]
- 01:05:15-01:05:18，老师明确承认这里用了近似和高维上界，不是严格逐项证明；但他认为这些假设总体仍“mostly legitimate”。[01:05:08-01:05:15]
- 01:05:19-01:06:35，A2 比 A1 更麻烦。老师限定在“单样本 SGD、deep linear network”的简化设定下讨论。对线性层来说，权重更新 $\Delta W_l$ 是损失梯度与前层激活的 rank-1 外积；然后他把新的激活写成旧权重、旧激活、权重变化、激活变化的展开式，得到“激活变化由三个量级项共同组成”的表达。[课件: lecture_11.pdf p.48]
- 01:06:35-01:07:21，他给出量级目标：若 A2 要成立，那么每个主项都最好达到 $\Theta(\sqrt{n_l})$ 的层范数量级。前一项靠归纳假设给出；后两项则都把问题压缩成“$\|\Delta W_l\|$ 应该有多大”。[01:06:35-01:07:21][课件: lecture_11.pdf p.48]
- 01:07:21-01:08:29，老师此时直说这是一种“physicists math”：不是形式化定理证明，而是不断追踪各个量的 order of magnitude，并且额外假设这些项不会在主阶上神奇抵消。按照这种估算，便能解出希望的 $\|\Delta W_l\|$ 应与 fan-out / fan-in 的平方根比例相匹配。[01:07:21-01:08:29][课件: lecture_11.pdf p.48]
- 01:08:29-01:09:54，本段最后一步是把“想要的更新量级”转成“想要的学习率量级”。老师引入另一条较强的假设：loss update 本身是 $O(1)$，也就是模型在不同宽度下都做出相近量级的有效进展。结合泰勒展开与 rank-1 梯度结构，就能把学习率应该满足的条件写成某个 fan-out / fan-in 比例；但具体把 $\eta_l$ 解出来，留到下一段开头。[01:08:51-01:09:54][课件: lecture_11.pdf p.49]

## 概念、符号与推导
- A1：初始化激活应保持 $\Theta(1)$；若单个激活为 $\Theta(1)$，整层范数应为 $\Theta(\sqrt{n_l})$。[01:00:56-01:02:29][课件: lecture_11.pdf p.46]
- A2：一次梯度更新后，激活变化仍应是 $\Theta(1)$；这正是老师口中的 feature learning，而与 NTK 中“变化趋零”的极限相对。[01:01:24-01:02:03][课件: lecture_11.pdf p.46]
- A1 的简化推导框架：
  - 设 $h_l = W_l h_{l-1}$；
  - 初始化 $W_l \sim \mathcal{N}(0, \sigma^2 I)$；
  - 用高斯矩阵 operator norm 的量级估计 $\|W_l\|_*$；
  - 近似令 $\|h_l\|_2 \approx \|W_l\|_* \|h_{l-1}\|_2$；
  - 通过归纳选取 $\sigma$，使输出层范数维持在 $\Theta(\sqrt{n_l})$。[01:02:52-01:05:15][课件: lecture_11.pdf p.47]
- A2 的简化推导框架：
  - 对单样本 SGD，线性层有 $\Delta W_l = -\eta_l \nabla_{h_l}\ell\, h_{l-1}^\top$，是 rank-1 外积；
  - 激活变化可展开成旧权重乘前层变化、权重变化乘旧激活、权重变化乘前层变化等项；
  - 希望这些主项都达到 $\Theta(\sqrt{n_l})$ 的层范数量级，从而倒推出 $\|\Delta W_l\|$ 的目标比例。[01:05:19-01:08:29][课件: lecture_11.pdf p.48]
- 额外强假设：loss update 为 $O(1)$。老师本人也说这是较不令人满意的假设，但它使后续学习率量级的代数关系能闭合起来。[01:08:51-01:09:54][课件: lecture_11.pdf p.49]

## 例子与课堂提示
- 老师把 NTK 拿来当对照，服务于知识点：muP 不是单纯让网络稳定，而是要保证宽网络仍然发生非消失的 feature learning。[01:01:41-01:02:03]
- “这不是严格数学，而是 physicists math” 这句提醒，服务于知识点：muP 的推导更像量级分析程序，重在抓住随宽度变化的主导项，而不是逐项给出无缝严证。[01:07:26-01:07:45]
- A1 中“输出范数近似等于 operator norm 乘输入范数”的近似，被老师点名说只是 certain high-dimensional regimes 下合理，服务于知识点：整套 derivation 有可讨论的经验性前提。[01:03:19-01:03:35]
- 老师明确把“无主阶抵消”当额外前提，服务于知识点：A2 的推导并不是自动成立的，它依赖对更新各项如何叠加的经验判断。[01:07:10-01:07:21]

## 本段掌握检查
1. muP 的两个核心不变量 A1 和 A2 分别是什么？
答案：A1 是初始化后激活量级保持 $\Theta(1)$；A2 是做一次梯度步后激活变化仍保持 $\Theta(1)$。[01:00:56-01:01:30][课件: lecture_11.pdf p.46]
2. 老师为什么把 A2 与 feature learning 联系起来？
答案：因为如果更新后的激活变化不消失，网络在变宽时仍真正改变特征；若变化趋于 0，就更像 NTK 那样缺少这种 feature learning。[01:01:24-01:02:03]
3. 在 A1 的推导里，为什么要把单坐标尺度和整层范数尺度区分开？
答案：因为单个 activation 为 $O(1)$ 时，整层向量的自然范数尺度就是 $\Theta(\sqrt{n_l})$，后面所有 operator-norm 估计都在用这个层范数尺度。[01:02:12-01:02:29]
4. A2 推导为什么会把问题归约成“$\|\Delta W_l\|$ 应有多大”？
答案：因为激活变化展开式中的关键项都含有权重更新大小，若要求这些项达到正确量级，就必须先约束更新矩阵的 operator norm。[01:06:35-01:08:29]
5. 老师为何说这套推导是 “physicists math”？
答案：因为它主要是追踪各量的量级、使用近似和额外假设，而不是严格的逐步定理证明。[01:07:26-01:07:45]

## 待核对项
- 01:00:03-01:00:31 老师提到的具体“较易读 muP 论文”在 transcript 中没有明确题名，这里只保留作者线索，不补猜论文标题。[需回听 01:00:03]
- 01:03:49-01:04:47 transcript 对若干 $n_l$、$n_{l-1}$、$\sigma$ 公式的排版存在自动字幕与 PDF 混排，精确公式应以 [课件: lecture_11.pdf p.47-p.49] 为准。

--- 片段笔记 8 ---
## 本段在整讲中的作用
- 本段完成 muP 推导的最后一步，并把“量级分析结论”重新翻译回实际 recipe：初始化怎么改、学习率怎么设、Adam 与 SGD 在这里有什么区别。[01:09:54-01:11:44]
- 随后老师补上实证层面的闭环：muP 在受控宽度扩展下确实能让最优学习率更稳定，但它也有边界条件，例如 RMSNorm gain、sign-based optimizer 与强 decoupled weight decay 可能破坏它。最后全讲收束为一个总判断：scaling in the wild 很有用，但没有银弹。[01:11:49-01:16:58]

## 教学展开
- 01:09:54-01:10:24，老师先把上一段留下的问题算完：在他设定的量级约束下，所需的层学习率 $\eta_l$ 比例会解成 fan-out / fan-in，也就是 $n_l / n_{l-1}$；对 Adam，则会进一步变成大致 $1 / n_{l-1}$ 的层特定 learning rate。[课件: lecture_11.pdf p.49]
- 01:10:24-01:11:21，接着他把推导结果翻译成可执行 recipe。muP 版本会把初始化设成“标准 $1/\sqrt{n_{l-1}}$”再乘一个反映 fan-out / fan-in 的修正项；如果这个比值为 1，就退化回常见初始化。学习率则不再是与模型大小无关的全局常数，而要按层依 fan-out / fan-in 调整；对 Adam，层 fan-in 越大，学习率越小。[01:10:37-01:11:21][课件: lecture_11.pdf p.50]
- 01:11:21-01:11:49，老师对这一长段推导做高层总结：muP 的有趣之处不仅是给出了一套可用技巧，还在于其方法论很不同。它先考虑网络放宽度极限时哪些量该保持不变，再根据这些 invariance 约束反推超参数必须怎样缩放。[01:11:49-01:12:20]
- 01:12:20-01:12:35，他把这件事上升成更一般的观点：这种“先设缩放极限不变量，再反解算法”的做法，可能是设计新算法或新超参数 rule 的通用原则。[01:12:20-01:12:35]
- 01:12:39-01:13:19，之后进入实证部分。老师提到有独立研究者对 muP 做了很多 stress test，把它理解成一种按网络部件分别缩放超参数的过程。embedding、attention、MLP 输入/输出、softmax linear，在 muP 与非 muP 下都会得到不同缩放规则。[课件: lecture_11.pdf p.51-p.53]
- 01:13:19-01:13:55，他说这些复现实验在受控宽度扩展下基本重现了 MiniCPM 的 headline：只要 muP 设对，最优学习率对宽度的迁移确实能维持得很好；加上某些对 attention projection bias 的修正版，迁移性也不错。[01:13:19-01:13:55][课件: lecture_11.pdf p.52]
- 01:13:55-01:15:07，接下来老师问真正关键的问题：现实模型里有很多偏离理论的东西，哪些会真的破坏 muP？答案是，多数偏离其实还能工作，例如某些激活函数或初始化变化；但学习型 RMSNorm gain 会破坏 muP，虽然这些 gain 往往可以拿掉而性能损失不大；另外，像 Lion 这种偏重梯度符号的 exotic optimizer 也会破坏它。[01:13:55-01:15:07][课件: lecture_11.pdf p.53-p.55]
- 01:15:01-01:15:11，老师补充一个“最让人担心”的失败点：大的 decoupled weight decay，尤其 0.1 这种强度，会让 muP 明显失效。[课件: lecture_11.pdf p.56]
- 01:15:11-01:15:47，尽管如此，他对 muP 的总体结论仍偏正面：如果目标就是控制 learning rate 随规模漂移，muP 很有用。很多实验都显示，不用 muP 时最优 learning rate 会随着宽度规律性但大幅偏移；用了 muP 后，这种漂移显著减弱，因此它是控制超参数漂移的一件实用工具。[01:15:11-01:15:47][课件: lecture_11.pdf p.57]
- 01:15:52-01:16:58，整讲最后的 recap 回到“scaling in the wild”。老师说：实践中的难点有三类，设模型结构超参数、设 optimizer 超参数、以及为大型 Chinchilla sweep 付出的算力成本。对应的解决思路包括：假设某些东西稳定或直接用 muP、在小尺度搜索最优 learning rate / batch 并保持或预测其 scaling、以及用 WSD 这类替代 schedule 降低 sweep 成本。但他最后强调，scaling law 看起来像科学，实际上仍很 messy、很有艺术性，还没有任何 silver bullet。[课件: lecture_11.pdf p.58]

## 概念、符号与推导
- 从上一段到本段收尾的关键式：在老师的量级假设下，层学习率应按 fan-out / fan-in 比例缩放；对 Adam，则近似改成按 fan-in 的倒数缩放。[01:09:54-01:10:24][课件: lecture_11.pdf p.49-p.50]
- muP 的 recipe 解释：
  - 初始化不再只看标准 fan-in，而要在标准初始化上叠加 fan-out / fan-in 的修正；
  - 学习率不再全层共享常数，而要做 layer-specific scaling；
  - 对 Adam，较大 fan-in 的层需要更小的学习率。[01:10:37-01:11:21][课件: lecture_11.pdf p.50]
- muP 的方法论抽象：先定义网络在宽度极限下应保持的 invariance，再用附加假设把这些 invariance 变成对初始化与学习率的约束。[01:11:49-01:12:35]
- 实证边界：
  - 在受控宽度扩展中，muP 能较好维持最优 learning rate 的不变性；
  - learned RMSNorm gain、sign-based / exotic optimizer、强 decoupled weight decay 是主要破坏项；
  - 其他若干理论外部件，如某些激活或初始化变化，并不一定立刻使它失效。[01:13:19-01:15:11][课件: lecture_11.pdf p.52-p.56]

## 例子与课堂提示
- [课件: lecture_11.pdf p.50] 中“蓝框是 muP，若比值为 1 就退回标准初始化”的对照，服务于知识点：muP 不是凭空重写一切，而是在标准参数化上做有方向的层级修正。
- 老师把 muP 的推导方法称作“先设不变量，再反解超参数”，服务于知识点：这套思路可能比记住单个公式更重要，因为它提供了一种构造新缩放规则的程序。[01:11:49-01:12:35]
- stress test 中“多数偏离还能工作，但 RMSNorm gain、Lion、强 weight decay 不行”的结论，服务于知识点：muP 不是 fragile 到一点偏离都不能碰，但也绝不是对现实模型全都鲁棒。[01:13:55-01:15:11][课件: lecture_11.pdf p.53-p.56]
- 结尾总表把 muP、small-scale hyperparameter search、WSD 放进一个工具箱，服务于知识点：老师不是在推单一答案，而是在给“控制超参数漂移与 sweep 成本”的多种可组合方案。[01:15:52-01:16:58][课件: lecture_11.pdf p.58]

## 本段掌握检查
1. 上一段推导在本段最终得到的层学习率缩放关系是什么？
答案：在老师的量级设定下，$\eta_l$ 应按 fan-out / fan-in 缩放；对 Adam，近似变成按 fan-in 的倒数缩放。[01:09:54-01:10:24][课件: lecture_11.pdf p.49-p.50]
2. muP 的高层方法论最值得记住的是什么？
答案：先规定网络在尺度极限下哪些量必须保持不变，再通过附加假设反推出初始化与学习率等超参数该如何缩放。[01:11:49-01:12:35]
3. 哪些现实成分被老师明确点名为会破坏 muP？
答案：learned RMSNorm gain、某些依赖梯度符号的 exotic optimizer（如 Lion）、以及较强的 decoupled weight decay。[01:14:24-01:15:11][课件: lecture_11.pdf p.54-p.56]
4. 老师对 muP 的总体态度是什么？
答案：它不是终极解，也仍是开放研究方向，但在抑制最优 learning rate 随规模漂移这件事上相当有用，值得放进工具箱。[01:15:11-01:15:47][课件: lecture_11.pdf p.57]
5. 整讲最后老师把 scaling in practice 的三类难点与三类解决方向分别概括成了什么？
答案：难点是模型结构超参数、optimizer 超参数、以及大规模 Chinchilla sweep 的算力成本；解决方向是用稳定假设或 muP、在小尺度搜索并预测 LR / batch scaling、以及采用 WSD 类学习率计划降低 sweep 成本。[01:15:52-01:16:58][课件: lecture_11.pdf p.58]

## 待核对项
- 01:13:43 附近老师提到“tracks projection biases for attention”的 muP 变体，transcript 语义可辨但未给出正式术语；若需准确引用应回看原论文或录音。[需回听 01:13:43]
- 01:16:47 老师说“Maybe next year, there will be a module that's like, we solved it”，这是明显口语化收尾，不应误写成领域已存在统一解法。