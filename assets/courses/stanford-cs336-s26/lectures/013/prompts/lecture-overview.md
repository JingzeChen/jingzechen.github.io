# Lecture 13 总览

## 学习目标
理解老师为什么把数据视为语言模型训练里最关键的差异化因素；能说明训练数据从 live services 到可用语料之间经历的抓取、转换、过滤、去重与许可判断；能按时间顺序概括从 BERT、WebText、CCNet、C4 到 DCLM、Nemotron-CC、The Stack、CommonPile 的主要设计思路。

## 需要的先修知识
默认已经掌握前几讲关于语言模型训练、系统、扩展规律和评估的背景。尤其要知道“给定数据如何训练模型”和“如何判断模型是否好”这两层前提，因为本讲是在此基础上追问“究竟该训练什么数据”。

## 老师的教学主线
老师先用企业不公开数据来论证“数据最重要”，再拆解“训练在整个互联网上”这一误解，说明动态内容、认证、robots.txt、ToS 与版权会限制可获取数据。接着他建立版权、许可与 fair use 的法律框架，再从 Common Crawl、Wikipedia、GitHub、arXiv 等来源过渡到一系列代表性数据集，最后用 The Stack 与 CommonPile 讨论代码语料和只用宽松许可数据的上限。

## 核心概念与依赖关系
核心依赖链是：live service 不是语料，必须经过 crawler 或官方 dump 变成 raw data，再经过 transformation、filtering、deduplication 等步骤成为训练数据。法律层面还有 license、fair use、ToS 三层约束。数据集构造方法则大致分为三类：社区信号代理质量，如 WebText；参考分布过滤，如 CCNet；规则或模型评分过滤，如 C4、DCLM、Nemotron-CC。

## 关键推导、例子与结论边界
本讲没有公式推导，关键是论证链。代表性例子包括：Llama 3 几乎不公开数据；Wikipedia dump 可能被时间点攻击；GPT-2 用 Reddit 高 karma 外链做代理质量；CCNet 用 Wikipedia-like 得分筛语料；DCLM 用 OpenHermes 和 ELI5 定义高质量正例；CommonPile 说明只用宽松许可数据可以做到“还不错”，但要追平顶级模型仍困难。结论边界也很明确：训练在若干具体案件中得到 fair use 的有利判断，不等于所有训练都已合法定论。

## 易错点与待核对项
不要把“互联网”“公开网页”“合法可抓取语料”混为一谈。不要把 fair use 理解成一张通行证，也不要把数据集整体许可误认为内部每份作品都可宽松使用。阅读 token 数时要区分 unique token 与重复 epoch 后的训练消费 token。字幕中仍有少量需回听位置，如 00:01:59-00:02:11、00:11:45-00:11:51、00:30:52-00:31:18、01:09:41-01:09:45。

## 掌握标准
如果能够不看讲稿就解释清楚“为什么数据不是从天上掉下来”“为什么 Common Crawl 只是起点而不是终点”“为什么过滤和许可判断决定模型边界”，并能举出 5 个以上具体数据集说明其来源和过滤思路，就算掌握了本讲核心内容。

## 复习顺序
建议先复习开场论证与训练阶段，再复习数据来源和版权框架；之后按时间顺序复盘 BERT、GPT-2、CCNet、C4、GPT-3、The Pile、Gopher、LLaMA、RefinedWeb、Dolma、DCLM、Nemotron-CC；最后单独看 The Stack 与 CommonPile，把“代码数据”和“许可收紧下的数据工程”作为整讲收束。