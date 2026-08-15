## 学习目标
- 理解老师为何从 simple seq2seq 出发，逐步引出 attention、self-attention、masked self-attention 与 transformer。
- 能区分 encoder、decoder、conditional language model、context vector、attention weights、query/key/value、positional encoding、mask 的职责。
- 能根据讲中给出的例子解释：为什么平均全部输入不够、为什么 decoder 端必须 mask、为什么 transformer 可以替代大量 recurrence。

## 需要的先修知识
- 已经听过上一讲的 sequence-to-sequence、beam search、language model / conditional language model、RNN 基本递归生成方式。
- 需要熟悉 softmax、加权平均、内积与“状态随时间递推”这些基础概念。
- 对 encoder/decoder、<sos>/<eos>、next-token prediction 的课堂语境要已有认识。

## 老师的教学主线
- 00:00:05-00:10:04：先回顾 simple seq2seq 与 delayed self-referencing seq2seq，把 decoder 明确解释成对输入条件化的 language model，并点出“单个最终 hidden state 过载”的起始问题。
- 00:10:02-00:20:00：再指出 simple 模型的两个根本缺陷：输入信息在 encoder 句末表示中过载，且在 decoder 递归中继续被冲淡；不同输出还需要直接对接不同输入位置。
- 00:19:56-00:29:56：然后提出 attention：对每个输出步动态计算一组权重，用 raw score、softmax 与加权平均形成 context vector。
- 00:29:54-00:39:53：接着细化成 Q/K/V：用 query-key 算关注权重，用 value 构造真正的上下文内容，并把整句输出目标重新连到 beam search。
- 00:39:51-00:59:49：再处理训练与扩展：teacher forcing、Gumbel trick、多头扩展、图像 captioning 与“encoder 不一定要 recurrence”的观察。
- 00:59:47-01:21:25：最后把“显式关注全部输入”推广成 self-attention 与 masked self-attention，并加入 positional encoding，得到 transformer；再用 GPT、BERT、Vision Transformer 与两个 caveat 收束整讲。

## 核心概念与依赖关系
- simple seq2seq 依赖最终 encoder state 启动 decoder；这是后续所有问题的起点。
- attention 依赖“每个输出词都可能需要不同输入部分”这一观察，因此 context vector 必须按输出步动态变化。
- raw attention score 先算，再 softmax 成 attention weight；只有后者满足非负且和为 1。
- query/key/value 是对“如何找相关位置”和“把什么内容传过去”两件事的职责拆分。
- self-attention 把这种动态加权机制搬到序列内部，用于更新每个词自己的上下文化表示。
- positional encoding 解决“只看内容不看位置会丢掉距离信息”的问题。
- masked self-attention 解决 decoder 因果性：当前位置不能偷看未来词。
- transformer 就是用 positional encoding 与多头 self-attention 大量替代 recurrence 的 seq2seq 架构；GPT 与 BERT 分别取其 decoder 半边与 encoder 半边。

## 关键推导、例子与结论边界
- 关键推导链条是：e_i^{(t)} = g(h_i, s_{t-1}) 先产生 raw score，再 softmax 得 w_i^{(t)}，再对 hidden states 或 values 做加权和得到 context。
- 老师的几何解释是：若权重全为正且和为 1，加权结果就落在 hidden states 张成的包内，因此像“平均”而不是任意外推。
- “I ate an apple” 的翻译例子支撑了从平均到动态权重、从单向量压缩到 attention 的整条动机链。
- “apple 是水果还是电脑” 与“远处的 ate 不该像近处的 ate 那样影响 apple” 这两个例子分别支撑 self-attention 的上下文化动机和 positional encoding 的距离动机。
- 结论边界：本讲把 GPT 说成 decoder、BERT 说成 encoder，是结构层面的课堂定位；没有展开它们全部训练细节与后续变体。

## 易错点与待核对项
- 不要把 raw attention score 当成最终 attention weight；softmax 之后才有正且和为 1 的权重。
- 不要把“平均全部输入”误认为 attention；attention 的关键是权重会随当前输出步变化。
- 不要把 key/value 的职责混淆：老师明确把“用于匹配的粗信息”和“用于传递的具体内容”分开讲。
- 不要把 encoder 的 full self-attention 与 decoder 的 masked self-attention 混为一谈；decoder 每层都要 mask。
- transcript 中多处德语词形与个别术语有 OCR 漂移，如 “ish”“off field”“onion”等，引用原词时宜保留 [需回听] 标记。
- 课件中若干公式页 OCR 损坏较重，特别是 p.128-p.130、p.138-p.143；当前整理只保留能从 supplied evidence 稳定确认的关系。

## 掌握标准
- 能口头复述老师从 simple seq2seq 到 attention 的问题链，而不是只背定义。
- 能写出“score -> softmax -> weighted sum”这条 attention 计算顺序，并说明 query/key/value 各管什么。
- 能解释为什么 self-attention 可以替代 encoder recurrence，为什么 decoder 还需要 mask。
- 能说明 transformer 相对 RNN 的至少两点优势：减少顺序依赖、缓解深展开问题并支持更多并行。
- 能准确回答本讲结尾定位：BERT 对应 encoder，GPT 对应 decoder。

## 复习顺序
- 先复习 00:00:05-00:10:04，确认 simple seq2seq、encoder-decoder 与 conditional language model 的起点定义。
- 再复习 00:10:02-00:20:00，抓住 simple seq2seq 的两个缺陷：最终单向量过载、递归导致信息稀释。
- 然后复习 00:19:56-00:39:53，把 attention 的三步计算和 Q/K/V 的职责拆分串起来。
- 接着复习 00:39:51-00:59:49，理解 teacher forcing、Gumbel trick、多头扩展、图像 captioning 与“encoder 不一定要 recurrence”的过渡。
- 再复习 00:59:47-01:19:41，掌握 self-attention、multi-head self-attention、MLP mixing、positional encoding、masked self-attention 与 transformer 主体。
- 最后复习 01:19:59-01:21:25，收束到 GPT/BERT、Vision Transformer、uniformization 与课件里的 caveats。

## 逐段详细课堂笔记
00:00:05-00:10:04（sections/001）
本段先把本讲放回上一讲已经开启的 sequence-to-sequence 主题中，重新界定“序列进、序列出且输入输出未必时间对齐”的问题，再回顾最简单的 delayed self-referencing seq2seq 结构。老师随后把 decoder 明确解释成对输入条件化的 language model，并用这一点说明后续为什么必须解决表示压缩与条件建模过于复杂的问题；片段结尾已经把矛盾落到“单个最终 hidden state 过载”。

00:10:02-00:20:00（sections/002）
这一段把 simple translation model 为什么不够用讲清楚：一方面最终输入表示在 decoder 递归中会被后续输出不断覆盖，另一方面所有输入被压成单个向量，无法让不同输出直接对接不同输入位置。老师依次试探“把 encoder 表示送到每个 decoder 时刻”和“平均全部 encoder hidden states”两种修补办法，再指出仍然不够，由此把问题精确导向“每个输出词都需要自己的一组动态加权平均”。

00:19:56-00:29:56（sections/003）
这里正式落到 attention 机制：第 t 个输出步对第 i 个输入位置的权重，必须由 encoder hidden state 和上一时刻 decoder state 共同决定。老师先给 raw attention score，再用 softmax 把它变成全正且和为 1 的 attention weight，最后对全部输入 hidden states 做加权和得到 context vector；同时补上 dot product 与双线性打分这些常见实现。

00:29:54-00:39:53（sections/004）
本段先把 attention-based decoding 的整条计算顺序闭合，再指出单个 hidden state 同时承担“决定该关注谁”和“真正传什么内容”两件事并不理想，于是引出 query、key、value 的职责拆分。片段后半把输出目标重新落回“找到直到 <eos> 为止概率乘积最大的整句”，从而把本讲的 attention decoder 与上一讲的 beam search 搜索框架接上。

00:39:51-00:49:51（sections/005）
这一段把 attention 模型从“会推理”推进到“怎么训练、为何有效”。老师先用 Bahdanau 对齐图说明 attention 确实学到了输入输出对齐，再解释训练仍然是在做 conditional language model 的最大似然学习；为避免模型早期错误把整条目标序列打乱，训练时要把真实目标前缀送入 decoder，也就是 teacher forcing。

00:49:49-00:59:49（sections/006）
老师先补充 Gumbel trick、多头扩展和图像 captioning 这些 attention 的训练与应用细节，然后把问题推向更根本的一步：既然 decoder 已经能显式访问全部输入，encoder 里的 recurrence 还是不是必须。接着他用 “apple” 在不同上下文中的歧义说明，去掉 recurrence 之后仍必须保留上下文化能力，于是正式把 attention 搬到序列内部，得到 self-attention 的动机与基本计算方式。

00:59:47-01:09:45（sections/007）
本段把 self-attention 从想法扩成可堆叠模块：对每个词，用自己的 query 去和所有词的 keys 比较，再用得到的权重对所有 values 做加权和；对句中每个位置都重复这一过程，就得到单头 self-attention。随后老师解释 multi-head 为什么不是简单“加参数”，而是让不同头学习不同方面的信息；再用后接 MLP 的必要性说明各头结果必须进一步混合，最后自然过渡到 positional encoding 的需求。

01:09:44-01:19:41（sections/008）
这一段完成 transformer 的主体叙事。老师先给 positional encoding 需要满足的性质和标准正弦余弦构造，再把 self-attention 从 encoder 推广到 decoder，并说明 decoder 端因为逐词生成所以必须 masked。随后他把多头 masked self-attention、MLP、residual framework 拼成 transformer，并用并行性、梯度传递和计算代价对比说明它为什么能大量替代 RNN；最后再用 GPT 和 BERT 分别钉住 decoder-only 与 encoder-only 两条主流发展线。

01:19:59-01:21:25（sections/009）
结尾片段先用最后一个 poll 的答案钉死 BERT 与 GPT 的结构定位，再用课件补出下一周继续讲 transformers 与 LLMs、Vision Transformer 的基本套路、transformer 对 DL 任务表述的 uniformization 作用，以及“并非所有 transformer 都一样”“并非任何部署约束下都优于 LSTM”这两个 caveat。最后，老师预告下周继续讲 transformers 和 LLMs，并把本讲收束到更现实的模型选型与部署边界上。
