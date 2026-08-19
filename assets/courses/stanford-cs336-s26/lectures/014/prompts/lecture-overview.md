# 本讲
Lecture 14: Data (filtering, deduplication, mixing, synthetic data)

请输出以下部分：

## 学习目标
## 需要的先修知识
## 老师的教学主线
## 核心概念与依赖关系
## 关键推导、例子与结论边界
## 易错点与待核对项
## 掌握标准
## 复习顺序

保留时间戳和代码页码引用。不要重复粘贴全部片段笔记，也不要省略重要推导。

# 逐段课堂笔记

--- 片段笔记 1 ---
## 本段在整讲中的作用
本段先把第 13 讲的数据来源问题接回到本讲的“数据管线”问题：老师先回顾数据不是自然掉下来的，而是要经过 live service -> dump/crawl -> processing 的链路，再说明本讲要进入四个预训练阶段环节：transformation、filtering、deduplication、mixing，最后再补 post-training data 的 synthetic data 用法。[00:00:13-00:01:12] 这一段还先把讨论范围限定在 pre-training，为后面所有技术细节定下语境。[00:01:12-00:01:15]

## 教学展开
老师先回顾上一讲：互联网数据来自在线服务，必须先抓取或导出，再经过处理，同时还要考虑 terms of service、copyright、license 或 fair use 等社会与法律约束。[00:00:13-00:00:46] 接着他给出本讲路线：数据转换、过滤、去重、混合，以及最后的 post-training synthetic data。[00:00:50-00:01:07]

随后老师转入 transformation 的复习。他强调 raw data 并不是天然文本；即便抓到了 Common Crawl，里面常见的原始形式也仍然是 HTML、PDF，或者 GitHub 这类目录结构。[00:01:18-00:01:39] 因为网页主体大多是 HTML，所以转换工作的重点通常是 HTML to text。[00:01:42-00:01:47]

在 HTML 转文本时，老师按问题顺序说明：先去除 boilerplate，例如导航栏、广告、页眉页脚、菜单，再尽量抽取页面主体内容。[00:01:51-00:02:20] 但他马上补充一个边界条件：什么算 content 并不总是清楚，因为某些导航元素也可能帮助模型学习网页结构。[00:02:20-00:02:31] 接着他提出图片与表格的处理难点，指出 HTML 线性化必然是有损过程；尤其表格常常只能近似处理，简单表格还能转成 markdown，嵌套表格则会很棘手，最后不得不放弃部分结构或做近似。[00:02:33-00:03:11]

老师再解释为什么工业上常见 rule-based HTML 处理：它速度快，而且此处任务并不要求太强的“智能”，所以经验规则通常够用。[00:03:11-00:03:31] 但他也保留一个开放判断：未来也许存在 model-based intervention 的空间，只是前提是足够快且能明显更智能。[00:03:34-00:03:41] 最后他提醒，任何 rule-based processing 都有失败率，因此数据里一定会留下瑕疵，而转换准确率会真实影响结果。[00:03:46-00:04:20]

后半段转到 PDF。老师先以 FinePDFs 为例说明：PDF 在互联网上也能从 Common Crawl 等来源拿到，但文件更大、常被截断，因此往往需要 recrawl。[00:04:20-00:05:20] 拿到 PDF 后，还要面对文本提取问题；有些 PDF 只是扫描件，本质上是图像，需要 OCR，通常还要借助 VLM，这比前面的纯文本处理昂贵得多。[00:05:20-00:05:47] 尽管 PDF 在整个互联网里占比小，老师仍强调它“值钱”，因为愿意做成 PDF 的内容平均质量往往高于普通 HTML 页面。[00:05:47-00:06:10] 最后他指出 PDF 清洗更难，因为它保留的是版面布局而不是 HTML 那样的语义标签，所以转换完成后虽然得到了 text，但距离可训练数据还“远未结束”，自然过渡到下一步 filtering。[00:06:15-00:06:57]

## 概念、符号与推导
本段无公式推导。

## 例子与课堂提示
- 老师用 Common Crawl 说明“抓到了网页”不等于“拿到了文本”，服务于 transformation 的问题设定。[00:01:24-00:01:34]
- 他用导航栏、广告、页眉页脚、菜单说明 boilerplate 的典型来源，同时提醒部分导航信息未必完全无用，服务于“content 边界不清晰”的判断。[00:01:57-00:02:31]
- 他用简单表格与嵌套表格的对比说明线性化损失，服务于“HTML to text inherently lossy”的结论。[00:02:52-00:03:11]
- 他提到 Resiliparse 和 Trafilatura 的准确率差异，提醒工具选择会影响数据质量，但本段没有展开具体数值。[00:03:57-00:04:20]
- 他用 FinePDFs 说明 PDF 不仅要抽取文本，还要处理截断、OCR、布局语义缺失，服务于“PDF 占比小但高价值”的判断。[00:04:20-00:06:34]

## 本段掌握检查
1. 老师为什么说本讲前半部分主要应该按 pre-training 来理解？
参考答案：因为他把 transformation、filtering、deduplication、mixing 都放在预训练数据管线里讨论，post-training synthetic data 是后面才补充的另一段主题。[00:00:50-00:01:15]

2. 为什么 HTML to text 是有损过程？
参考答案：因为 HTML 或渲染结果本来带有层级和视觉结构，转成 token 序列时必须线性化，表格、图片等信息无法完整保留。[00:02:40-00:03:11]

3. 为什么 PDF 麻烦但值得处理？
参考答案：因为它常被截断、扫描件要 OCR、语义结构缺失，但平均质量往往高于普通 HTML 页面。[00:05:09-00:06:34]

## 待核对项
- 老师提到上节课展示过不同 HTML 处理工具在 extended DCLM evals 上的准确率差异，但本段没有重复具体实验设置和数值，需要回看前一讲或原实验材料。[00:03:57-00:04:20]

--- 片段笔记 2 ---
## 本段在整讲中的作用
本段把 filtering 从抽象框架落到具体实例，完成“如何从 raw data 中筛出想要的数据”这件事的主要展开。它承接前一段“文本已经抽出来，但还远没结束”的结论，开始讲过滤器如何用目标数据定义“什么是好数据”，并给出 language identification、math filtering、GPT-3/LLaMA/phi-1、toxicity filtering 这些典型实现。[00:10:03-00:17:08] 最后又引入一个关键限制：过滤阈值是 scale-dependent 的，为后面关于训练时长与数据质量的讨论埋下伏笔。[00:17:26-00:20:00]

## 教学展开
老师先把抽象 filtering recipe 说完整：把目标集 T 当成正例、从 raw data R 中抽一些负例，训练一个足够快的分类器，最常用的是 fastText 这种 bag-of-words 线性分类器；然后对新文档打分，根据质量阈值决定保留，有时还会随机保留。[00:10:03-00:10:42] 他明确把这归为 model-based filtering，并说明近年趋势已从“担心偏差所以少用模型过滤”转向“算力紧张时必须聪明过滤，否则就是浪费 flops”。[00:10:42-00:11:21]

接着老师进入具体实例。第一类是 language identification：给定一段文本，判断它是不是某个目标语言。老师指出 Meta 的 fastText language ID 模型可直接拿来用，支持 176 种语言，训练源包括 Wikipedia 和多语翻译站点。[00:11:36-00:11:59] 他认为语言识别相对容易，但 code-switching、方言等边界复杂性仍然存在。[00:12:03-00:12:31]

第二类是按目标能力筛数据。老师以 OpenMathText 为例，目标是从大规模网页里提炼数学文本：先做规则过滤，再用 ProofPile 上训练的 KenLM 按 perplexity 过滤，再用 fastText 做数学写作分类，并按是否含 LaTeX 采用不同阈值。[00:12:47-00:13:48] 他用结果强调 curated filtering 的威力：约 15B 级别数学 token 足以训练出优于“20 倍大但未针对性过滤”的模型。[00:13:51-00:14:07]

然后老师把 GPT-3、LLaMA、phi-1 都纳入同一个 filtering 框架。GPT-3 用 Wikipedia、WebText、books 作正例、一般网页作负例；LLaMA 则用“被 Wikipedia 引用的页面”作正例。[00:14:27-00:15:03] phi-1 先让 GPT-4 用“教育价值”prompt 给 100K Python 样本打标签，再训练更便宜的分类器扩展到全量 The Stack Python 子集。[00:15:06-00:16:17] 最后老师说明 toxicity filtering 也只是同一套路：用带毒性标签的数据定义正负例并训练分类器。[00:16:33-00:17:08]

在讲完这些实例后，老师抽象出“quality is task-defined”的观点，并补充本段最重要的微妙点：不存在对所有训练方案都最优的固定阈值；训练更久时能接受更多较低质数据，训练更短时则应提高质量门槛。[00:14:13-00:14:27][00:17:26-00:18:10] 最后他用一个 157M 模型的小实验说明：高质量过滤数据在早期更好，但长程训练下也会进入多次 epoch 与过拟合区间。[00:18:24-00:20:00]

## 概念、符号与推导
- Filtering 的监督框架：目标集 T 是正例，raw data R 中抽样负例，训练分类器并以 score 决定是否保留。[00:10:03-00:10:42] [代码: lecture_14.py p.4]
- 两类打分函数：$score(x)=p_T(x)$ 与 $score(x)=p(T\mid x)$。[代码: lecture_14.py p.4]
- 过滤阈值没有全局最优常数；最优阈值依赖训练 token 预算与是否会进入多次 epoch 区间。[00:17:26-00:20:00]

## 例子与课堂提示
- fastText 被老师反复强调为“常用工具”，服务于 filtering 必须 extremely fast 的工程约束。[00:10:16-00:10:24]
- OpenMathText 例子服务于“quality 可以按目标能力自定义”。[00:12:47-00:14:07] [代码: lecture_14.py p.4]
- phi-1 例子服务于“昂贵教师 + 廉价学生过滤器”的两阶段思路。[00:15:28-00:16:17] [代码: lecture_14.py p.4]

## 本段掌握检查
1. 为什么近年的数据集更倾向采用 model-based filtering？
参考答案：因为多数团队算力有限，不过滤低质量内容就是浪费 flops。[00:10:42-00:11:21]

2. phi-1 的 target 数据是怎么来的？
参考答案：先用 GPT-4 按“教育价值”prompt 给 Python 子集打标签，再把正例当 target 去训练更便宜分类器。[00:15:28-00:16:17] [代码: lecture_14.py p.4]

3. 为什么老师说 filtering 没有单一最优 threshold？
参考答案：因为阈值效果依赖训练多少 token；长训练可容忍更低质量但更多的数据。[00:17:26-00:18:10]

## 待核对项
- 老师口头说 OpenMathText 得到“15 billion tokens”，而课件写的是 “14.7B tokens”，应并列保留差异。[00:13:51-00:13:55] [代码: lecture_14.py p.4]

--- 片段笔记 3 ---
## 本段在整讲中的作用
本段先收束 filtering，回答学生关于实验稳定性和高质量数据长训的问题，然后正式切到 deduplication：为什么高质量数据里依然有大量重复、为什么重复会伤害训练、以及去重问题的设计空间与算法约束。[00:20:00-00:29:57]

## 教学展开
老师先说 filtering 图上的点理想上应做多次训练取 confidence interval，但预训练运行昂贵，因此很多论文不会这么做；按他的经验，pre-training 往往比较稳定。[00:20:16-00:21:08] 对“高质量数据继续长训是否仍有效”的问题，他回答任何有限数据集最终都会出现 diminishing returns，只是高质量数据的收益曲线可能整体更低、更久一些。[00:21:10-00:21:46]

随后他总结 filtering：如果算力不是无限，就必须先定义 what good looks like，再训练轻量分类器，把标准外推到大规模网页。[00:21:56-00:22:50] 然后切入 deduplication：即便已经过滤过，数据里仍然充满 exact duplicates 与 near duplicates。[00:22:56-00:24:18]

老师用许可证、页眉页脚、标点差异文章、模板化广告解释 near duplicates 的常见来源，并特别举出 C4 中某个 gas mask 商品描述竟然重复 61,000 次的例子，提醒大家必须直接审查数据。[00:24:18-00:26:13] 在“为什么要 dedupe”上，他给出两条理由：减少无信息重复、避免 wasting flops，以及降低 memorization 带来的 copyright / privacy 风险。[00:26:17-00:26:55] 最后他把设计空间分成三问：item 粒度、match 规则、删除策略，并强调去重本质上是 item-to-item 比较，所以不能接受 $n^2$，必须追求线性时间算法。[00:27:15-00:29:57]

## 概念、符号与推导
本段无公式推导。

- Exact duplicates 与 near duplicates 的区分。[00:23:14-00:24:18] [代码: lecture_14.py p.5]
- 去重设计空间三问：item 粒度、match 规则、删除策略。[00:27:15-00:27:49] [代码: lecture_14.py p.5]

## 例子与课堂提示
- C4 中同一商品描述重复 61,000 次，是本段最强提醒：不看原始语料就会低估重复的极端程度。[00:25:48-00:26:13]

## 本段掌握检查
1. 为什么即便只保留高质量数据也仍然要做 deduplication？
参考答案：因为高质量数据里仍可能含大量重复，不去重会浪费算力并增加记忆化风险。[00:22:56-00:23:14][00:26:17-00:26:55]

2. 为什么 dedupe 比 filtering 更强调算法扩展性？
参考答案：因为 filtering 可以逐样本独立判断，而 dedupe 要比较样本之间的关系，朴素算法是 $n^2$。[00:27:50-00:28:29]

## 待核对项
- LM1B 中只差逗号的文章为何出现，老师没有给出原因，不应自行补充。[00:24:58-00:25:18]

--- 片段笔记 4 ---
## 本段在整讲中的作用
本段是 deduplication 的技术核心第一步：先讲 exact deduplication 的 hash 思路，再建立 near deduplication 所需的 Jaccard 相似度与 MinHash 性质，为下一段 LSH 做准备。[00:30:00-00:39:58]

## 教学展开
老师先指出 exact deduplication 语义清晰，但对 messy web data 不够，因为网页里大量重复只是 near duplicates。[00:30:00-00:30:14] 他说明示例代码写成 MapReduce 风格，是为了更容易并行化和扩展。[00:30:14-00:30:24] 接着他用 C4 的三句跨度 exact dedupe 说明：这种做法清晰但会破坏文档连贯性，因为删掉中间三句话后文本可能不再 coherent。[00:30:31-00:31:17] [代码: lecture_14.py p.7]

然后老师引入 Jaccard similarity，定义为交集大小除以并集大小，并用 $A=\{1,2,3,4\}$、$B=\{1,2,3,5\}$ 算出 Jaccard 为 0.6。[00:31:36-00:32:03] [代码: lecture_14.py p.8] 他据此把 near duplicate 定义为 “Jaccard 高于某个阈值，例如 0.99”。[00:32:19-00:32:29]

随后老师介绍 MinHash：随机哈希函数满足 $\Pr[h(A)=h(B)] = Jaccard(A,B)$。[00:32:50-00:33:01] 他把随机哈希解释成对行的随机排列，并说明如果共享行 1、2、3 先出现，A 与 B 的最小哈希就会相同；若 4 或 5 先出现，则不会碰撞，因此碰撞概率正好等于共享行占并集行的比例，也就是 Jaccard。[00:34:19-00:36:26] 最后他用 100 个 seed 验证经验碰撞率约为 0.6，并提醒 MinHash 还不是最终答案，因为它仍然太随机，不能直接完成阈值判别。[00:36:30-00:38:01]

## 概念、符号与推导
```text
Jaccard(A, B) = |A ∩ B| / |A ∪ B|
Pr[h(A) = h(B)] = Jaccard(A, B)
```

[代码: lecture_14.py p.8]

## 例子与课堂提示
- 三句跨度 exact dedupe 说明 exact 去重很容易破坏 coherence。[00:30:31-00:31:17] [代码: lecture_14.py p.7]
- 小集合例子是 MinHash 证明直觉的核心支架。[00:31:51-00:36:26] [代码: lecture_14.py p.8]

## 本段掌握检查
1. Jaccard similarity 在本讲里承担什么作用？
参考答案：它定义了“近似相同”的度量，把 near duplicate 判定转成“相似度是否高于阈值”。[00:31:27-00:32:29]

2. 为什么 MinHash 还不是最终答案？
参考答案：因为单次碰撞只给出与 Jaccard 相等的随机概率，不能稳定表达“是否高于阈值”。[00:37:29-00:38:01]

## 待核对项
- 口述中有几处停顿与自我修正，正式整理时应保留最终含义，不要把停顿误写成新概念。[00:38:49-00:39:08]

--- 片段笔记 5 ---
## 本段在整讲中的作用
本段完成 near deduplication 的第二步：在 MinHash 基础上引入 locality-sensitive hashing，把随机碰撞率改造成接近阈值相变的判别器，并顺势把话题接到 data mixing。[00:39:58-00:49:53]

## 教学展开
老师先给出 LSH 的碰撞定义：把哈希分成多个 band，只要存在某个 band 内所有 hash 都匹配，就说两个对象 collide。[00:39:58-00:40:57] 然后他推导，如果相似度是 $sim$，固定一个 band 匹配的概率是 $sim^r$，整体碰撞概率则是 $1-(1-sim^r)^b$。[00:41:19-00:42:32] [代码: lecture_14.py p.9]

他说明这个函数会形成 S 型曲线，这正是想要的 phase transition：低于阈值尽量不撞，高于阈值尽量撞。[00:42:46-00:43:45] 增大 $r$ 会让曲线更陡、右移；增大 $b$ 会让曲线左移，更容易匹配。[00:45:04-00:46:16] 最后他给出更真实的参数规模 $b=20,r=450$，以及阈值近似 $threshold=(1/b)^{1/r}$，并说明在阈值点附近碰撞概率约为 $1-1/e\approx0.64$。[00:46:39-00:47:59] [代码: lecture_14.py p.9]

老师最后强调，dedupe 应跨整个训练集做，而不是只在单个 source 内部做，因为不同数据集之间也会高度冗余。[00:48:55-00:49:15] 然后自然切到 data mixing。[00:49:21-00:49:53]

## 概念、符号与推导
```text
prob_match = sim^r
prob_collision = 1 - (1 - sim^r)^b
threshold = (1 / b)^(1 / r)
```

[代码: lecture_14.py p.9]

## 例子与课堂提示
- and-or 结构是 LSH 的本体，不是“多算几次哈希”这么简单。[00:40:42-00:40:57]
- 老师用 0.25 降到 0.008、0.72 升到 0.92 的口头对比提醒大家，调参就是在控制 false positive / false negative 权衡。[00:45:29-00:46:16]

## 本段掌握检查
1. 增大 $r$ 和增大 $b$ 各会带来什么效果？
参考答案：增大 $r$ 会让匹配更难、阈值更陡且右移；增大 $b$ 会让匹配更容易、曲线左移。[00:45:04-00:46:16]

2. 为什么 dedupe 应跨整个训练集做？
参考答案：因为不同数据源之间也可能高度冗余，只在单源内部去重会漏掉跨源重复。[00:48:55-00:49:15]

## 待核对项
- 例子里口头说碰撞概率约 0.4，若需精确复现应按公式直接计算而非只记近似值。[00:42:32-00:42:37]

--- 片段笔记 6 ---
## 本段在整讲中的作用
本段开启 data mixing，先定义多个数据源如何配权，再说明为什么简单直觉会失败，尤其指出“小而高质 source 会被过度 epoch”的风险。[00:49:53-00:59:51]

## 教学展开
老师先说明 language model 训练面对的是多 source 分布，所以 data mixture 本质上就是对 source 的分布。[00:50:53-00:51:11] 他列出三类 baseline：manual/vibes、uniform、proportional mixing。[00:51:21-00:52:22] [代码: lecture_14.py p.12]

然后他补两条现实约束：一是为了能力多样性，不能只给某一类 source 全部分布质量；二是每个 source 都是 finite 的，小而高质量的 source 一旦权重过高，就会被反复 epoch。[00:52:42-00:53:36] 为了说明第二点，他构造 10T low / 10B high / 1T train / 50-50 mixture 的例子，指出 high source 会被迫供给 500B token，平均约 50 epochs，而 low source 平均 epoch 数不到 1。[00:53:45-00:55:37] [代码: lecture_14.py p.12]

老师强调你未必“想要 50 epochs”，但只要先定义了错误 mixture，就会在不自觉中把同一 source 训练很多次；最好情况是浪费 compute，最坏情况是 overfitting。[00:56:29-00:57:07] 对“mixture 在训练里如何体现”的问题，他回答通常是在 batch 级别按 source 抽样 sequence，而不是按 token 粒度交错。[00:57:27-00:58:20] 最后他用 UniMax 说明一个 safety net：继续采样 source，但给每个 source 的 epoch 数设置硬 cap，超过就不再取样。[00:58:26-00:59:47] [代码: lecture_14.py p.12]

## 概念、符号与推导
- Data mixture：对多个数据源的概率分布 $p(s)$。[00:50:53-00:51:11] [代码: lecture_14.py p.12]
- Epoch 直觉：分配给某 source 的训练 token 除以该 source 自身 token 总数。[00:54:23-00:55:37] [代码: lecture_14.py p.12]

## 例子与课堂提示
- “Vibes-based” 一词说明很多实际配权仍高度依赖人工直觉。[00:51:26-00:51:44]
- 10T vs 10B 的例子是本段核心提醒：只看质量不看 source size，会让小源被训练到 50 epochs。[00:53:45-00:55:37]

## 本段掌握检查
1. 为什么 proportional mixing 并不总是合理？
参考答案：因为它可能让大而低质 source 吃掉过多权重，而手动抬高小而高质 source 的权重又会导致过度 epoch。[00:52:09-00:53:36]

2. mixture 在训练中通常怎样实现？
参考答案：通常按 mixture 在 batch 级别采样 sequence 所属 source，而不是按 token 级别混合。[00:57:27-00:58:20]

## 待核对项
- 学生在 00:56:16 左右的问题有明显听不清片段，应标 `[需回听 00:56:16]`，只能确定核心是在追问为什么会出现 50 epochs。

--- 片段笔记 7 ---
## 本段在整讲中的作用
本段系统引入 regression-based mixing / RegMix，解释怎样在小规模上试 mixture、拟合 surrogate、再优化得到大规模训练用的 data mixture，是 data mixing 部分的理论主线。[00:59:51-01:09:47]

## 教学展开
老师先说明：如果有 50 个 source，就有 50 个 weight 要定，仅靠 proportional mixing 或质量启发式都不够 principled，因此需要 RegMix / Olmix 这类方法。[00:59:51-01:00:40] [代码: lecture_14.py p.12]

流程上，老师先在小规模模型上试多组 mixtures，再训练一批 proxy models 拿到对应 loss，用这些点拟合一个“mixture weights -> loss”的回归器，最后直接优化这个 surrogate，把最优 mixture 用到大模型上。[01:00:46-01:02:03] 他把这类比 scaling laws：先做便宜计算，再外推到昂贵训练。[01:02:03-01:02:14]

随后他列出几个设计点：mixture 的采样分布可用 Dirichlet，回归器可用线性模型或 boosted trees，target 常来自 downstream evals，但如果 target 偏 code eval，就会把 code data 权重推得过高，损害一般性预训练目标。[01:02:17-01:03:19] 另一个核心问题是 small-to-large discrepancy：代理模型太小不可靠，太大又太贵。[01:03:27-01:03:54]

最后老师点明两个 leaps of faith：一是 surrogate 在 minimizer 附近仍然准确；二是小规模最优 mixture 能迁移到大规模训练。这两个条件都不能想当然成立。[01:04:50-01:09:47] [代码: lecture_14.py p.12]

## 概念、符号与推导
- RegMix：小规模多组 mixture 实验 + surrogate 回归 + surrogate 优化。[01:00:46-01:02:03] [代码: lecture_14.py p.12]
- 两个 leaps of faith：surrogate 在最优点附近的准确性；small-to-large transfer 的可靠性。[01:04:50-01:09:47]

## 例子与课堂提示
- 代码评测会把 code data 权重推高、导致生成诗歌时过拟合，是老师用来说明“优化错对象”的反例。[01:03:03-01:03:19]

## 本段掌握检查
1. RegMix 的核心流程是什么？
参考答案：小规模试 mixture、训练一批小模型、拟合 mixture 到 loss 的回归器、再优化回归器得到大规模训练用的 mixture。[01:00:46-01:02:03]

2. 两个 leaps of faith 分别是什么？
参考答案：surrogate 在 minimizer 附近仍准确，以及小规模最优 mixture 能转移到大规模训练。[01:04:50-01:09:47]

## 待核对项
- 01:04:21 左右老师对 `m` 的含义有一次自我更正，正式稿应保留最终定义，不要把前一句误写成正式表述。

--- 片段笔记 8 ---
## 本段在整讲中的作用
本段完成 data mixing 的补充问答，并转入 post-training data：先给出 synthetic data 的通用 recipe，再以 OpenThoughts 为第一个案例展开。[01:09:47-01:19:42]

## 教学展开
老师先再次强调 data mixing 虽然可在小规模拟合最优 mixture，但必须小心 epoching 与 overfitting，并提醒任何优化都可能在优化错目标。[01:09:47-01:10:31] 对“downsampling 后数据太小怎么办”的问题，他承认可能会小到几乎没法泛化，甚至因 rounding error 一次都没训练到，所以工程上至少应保证“训练一次”。[01:10:44-01:11:36]

对“能否在单个大数据集内部做 mixing”的问题，老师回答可以，并以 Nemotron 为例说明：可先按 domain/topic 分组，再叠加 quality filtering，形成 domain x quality 的二维 mixture component 网格。[01:11:59-01:12:53] 然后他把话题切到 post-training：此前主要在讨论 task-agnostic 的 pre-training / mid-training 数据，而 post-training data 会更 task-dependent。[01:12:57-01:13:28]

老师给出 synthetic post-training data 的统一 recipe：定义 environments、定义 tasks/prompts、从强 teacher 收集 responses。[01:13:48-01:14:10] 接着用 OpenThoughts 说明这一思路：项目在 o1 reasoning 热潮下构建 1.2M examples，来源包含人类与合成题源，而且实验表明少量高质量 source 更好，多次采样有帮助，更强模型不一定更适合作 teacher，简单 answer filtering 也未必有用。[01:14:53-01:17:08] [代码: lecture_14.py p.13]

## 概念、符号与推导
本段无公式推导。

- Post-training synthetic data 通用 recipe：environment、task/prompt、teacher response。[01:13:48-01:14:10] [代码: lecture_14.py p.13]

## 例子与课堂提示
- domain x quality 网格说明 mixture component 可以从单一大语料内部自动切出。[01:12:11-01:12:53]
- QwQ-32B 优于 DeepSeek-R1 的 teacher 现象提醒学生，teacher 质量不能只按模型绝对强弱排。[01:16:46-01:17:04]

## 本段掌握检查
1. post-training synthetic data 的统一 recipe 是什么？
参考答案：定义 environments、定义 tasks/prompts、从强 teacher 收集 responses。[01:13:48-01:14:10]

2. OpenThoughts 给出的关键经验有哪些？
参考答案：少量高质量源更好，多次采样有帮助，更强模型不一定更适合当 teacher，简单 answer filtering 未必有效。[01:16:26-01:17:08]

## 待核对项
- 01:12:15 左右 Nemotron 相关专有名词有听不清处，应标 `[需回听 01:12:15]`。

--- 片段笔记 9 ---
## 本段在整讲中的作用
本段继续 post-training coding 数据案例，讲 SWE-Zero、SWE-rebench 与 12M trajectories 的扩展，并在最后回收整讲四条主线，是实例收尾与总总结。[01:19:42-01:24:40]

## 教学展开
老师先指出 SWE-Zero 的关键观察：强模型即便没有 execution feedback，也能解决大量真实 SWE 任务，因此不必为每个仓库维护 repo-specific Docker image。[01:19:49-01:20:19] 他用“allow execution 约 80，不 allow 也接近 70”的口头比较说明模型已具备一定 code semantics/world model。[01:20:01-01:20:19]

随后老师解释 no-exec scaffold：沿用 OpenHands 风格的 explore / test / implement 指令，但禁止运行 Python，只允许做文本级基本操作，以减少环境负担并防止 agent hacking。[01:20:38-01:21:05] 之后再从更大 teacher 蒸馏并过滤，外加 13K 条需要 execution feedback 的 trajectories 做第二阶段微调。[01:21:06-01:21:37]

接着他快速带过 SWE-rebench，再提当天刚出的 12M trajectories 扩展，强调 no-exec 的轻量化好处是可以把大量不可执行任务也纳入数据集。[01:21:45-01:22:50] 最后老师把 prompt/data 来源归纳为 fully synthetic、semi-synthetic、real 三类，把 response 端归纳为 capable 且 good teachers 的模型，并用几句话总结 filtering、deduplication、mixing、post-training data 四条主线。[01:23:13-01:24:10] 结尾他特别提醒，真实 data work 往往 very grungy、domain-specific，需要反复看具体样本，本讲只是一个 landscape。[01:24:14-01:24:34]

## 概念、符号与推导
本段无公式推导。

## 例子与课堂提示
- no-exec 也接近 allow-exec 的成绩，是本段最重要的经验信号。[01:20:01-01:20:19]
- 老师最后说 data work 很 grungy，是对整讲抽象程度的边界说明。[01:24:14-01:24:34]

## 本段掌握检查
1. SWE-Zero 相比依赖执行环境的方法，关键优势是什么？
参考答案：即使没有 execution feedback，强模型仍能解决大量真实 SWE 任务，从而减少环境搭建成本。[01:19:49-01:20:19]

2. 老师如何概括 coding post-training 数据的来源？
参考答案：prompt/data 可以是 fully synthetic、semi-synthetic 或 real，responses 来自 capable 且能当 teacher 的模型。[01:23:13-01:23:38]

## 待核对项
- 01:19:42 开头句子承接上一段时不完整，应标 `[需回听 01:19:42]`。