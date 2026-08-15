## 学习目标
- 识别本讲的主问题是“无顺序同步的 sequence-to-sequence modeling”，并区分它与上周有顺序对应的情形。
- 明确 language model 在本讲中的作用：它不是旁支，而是 decoder 的概念基础。
- 说清 one-hot、projection、embedding、recurrent language model、encoder、decoder、conditional language model、greedy、random sampling、beam search 之间的连接。
- 能复述 simple translation model 的训练与推理流程，并知道它为什么会在下一讲被继续改进。

## 需要的先修知识
- recurrent neural network、LSTM、softmax、backpropagation 的基本概念。
- “条件概率连乘得到整句概率”的基本分解思想。
- one-hot 向量、词表、类别分布采样、beam search 的基本术语。
- 对上次课的 CTC / beam search 有最粗粒度印象即可：它属于“有顺序对应”的 seq2seq。

## 老师的教学主线
- 00:01:20-00:11:19：先把本讲放回 seq2seq 课程线里，强调本讲处理“输入输出不要求顺序对应”的任务；再用自动生成代码/论文/Wikipedia 页面把问题转到 language modeling。
- 00:11:17-00:31:10：从 next symbol prediction 讲起，建立 one-hot、固定历史模型、projection/embedding，再转入 recurrent language model。
- 00:31:09-00:51:04：讲生成如何终止，引入 `<sos>/<eos>`；给出最朴素 delayed seq2seq，发现其不能把已生成词反馈到后续分布，于是改成 self-referencing encoder-decoder。
- 00:51:01-01:10:57：把 decoder 的输出分布上升为“整句概率”的搜索问题，说明 greedy 不可靠、beam search 是可行近似；再讲训练时如何用目标前缀监督 decoder。
- 01:10:55-01:22:08：解释训练为什么像“给 cheat code”，展示翻译、对话、图像描述、视频描述的统一结构，并以“单一 hidden representation 过载”作为下一讲悬念。

## 核心概念与依赖关系
- seq2seq 是总问题；本讲聚焦无顺序对应的情形。
- language model 是 decoder 的前身：先学“给定前缀预测下一个词”，再学“在输入条件下预测下一个输出词”。
- one-hot 的作用是不引入词间先验关系；projection 把高维稀疏表示压到低维，得到 embedding。
- recurrent language model 让“基于全部过去预测下一个词”成为自然操作。
- encoder-decoder 把输入序列先编码成表示，再让 decoder 作为 conditional language model 逐词生成输出。
- inference 要找整句概率最高的输出，因此从 greedy 走向 beam search。
- training 之所以把目标前缀送入 decoder，是为了维持时间对齐，避免模型早期错误把后续监督打散。

## 关键推导、例子与结论边界
- one-hot 的关键性质是“等长、等距”，任意两不同 one-hot 向量距离都是 $\sqrt{2}$；这解释了为什么它虽然浪费空间，却不强加词间结构。
- embedding 的关键关系是 $P \times W$：对 one-hot 输入而言，等价于从投影矩阵中取出该词对应的一列。
- 输出序列概率的关键关系是“逐词条件概率连乘到 `<eos>`”；这直接定义了解码目标。
- “he nose / he knows” 例子给出的边界很清楚：局部最大概率不保证全局最优，所以 greedy 不是可靠解码准则。
- beam search 的边界也很清楚：它通过剪枝解决全树搜索的指数爆炸，但不是理论最优。
- simple translation model 的边界在最后被明确点出：整段输入被压到单一 hidden representation 中，可能过载。

## 易错点与待核对项
- 不要把“language model 只是在做 next token prediction”理解成它只关心局部；老师反复强调它真正建模的是整段序列概率，只是通常按增量方式计算。
- 不要把 one-hot 的高维浪费和“表示不好”混为一谈；老师肯定了它“不引先验”的价值。
- 不要把 decoder 误当成普通 LM；它是对输入条件化的 conditional LM。
- 不要把 greedy 当成“最可能句子”的保证；它只是在每一步取局部最大。
- 需回听项主要集中在德语/法语词串、人名与个别结束语截断处；这些不影响主线，但影响逐字引用精度。

## 掌握标准
- 能用自己的话解释为什么本讲先绕去讲 language model，再回到 translation model。
- 能从头描述 simple translation model 的推理流程：编码、`<sos>` 起步、逐步生成、把输出回馈、直到 `<eos>`。
- 能解释为什么 greedy 可能输给 beam search，并说出 beam search 仍非理论最优的原因。
- 能解释训练时为什么要把目标输出前缀送入 decoder，而不是完全按推理模式跑。
- 能指出 simple model 的下一讲问题：单一 hidden representation 负担过重。

## 复习顺序
- 先复习 00:01:20-00:11:19，确认本讲到底在解决哪类 seq2seq。
- 再复习 00:11:17-00:31:10，把 one-hot、projection、embedding、recurrent LM 串成一条线。
- 然后复习 00:31:09-00:51:04，重点记住为什么必须从 delayed model 变成 self-referencing encoder-decoder。
- 接着复习 00:51:01-01:10:57，抓住“整句概率乘积”和 “greedy 失败、beam search 近似”两件事。
- 最后复习 01:10:55-01:22:08，把训练、应用和“hidden representation 过载”的结尾问题合并成整体印象。

## 逐段详细课堂笔记
00:01:20-00:11:19（sections/001）
本段先把本讲放回“recurrent networks / sequence-to-sequence models”的连续教学线上，回顾上周讲过的 CTC/beam search 属于“有顺序对应”的 seq2seq，再说明本讲和下节课要处理的是“输入输出不必同步、也不必保持顺序对应”的 seq2seq。老师依次用 speech recognition、machine translation、dialog、question answering 说明“一个序列进去、另一个序列出来”的总问题，并用 “I ate an apple → Ich habe einen apfel gegessen” 与 “My screen is blank → 请检查电脑是否插电” 说明本讲关心的任务里，输入输出既可能不同长，也可能没有词位对应。随后插入 language modeling 的 detour：展示 Andre Karpati 的自动生成代码、数学论文样式文本、Wikipedia 样式文本，强调这些并非今天复杂的大模型，而是几层 LSTM 在生成模式下得到的结果，从而把问题转成“模型到底在做什么”。本段无公式推导；主要待核对的是德语转写与网页展示细节。

00:11:17-00:21:15（sections/002）
老师先给出答案：前面这些生成结果实际都建立在 next symbol prediction 上，模型通过不断预测下一个符号来构造语言的概率分布。为了让计算机处理词，先定义 one-hot：固定词表顺序后，每个词对应一个只有自身索引位置为 1 的向量；若单位是字符，也可同样处理。接着用 “four score and seven years ?” 和 “she sells sea shells at the seashore” 说明固定历史的 next-word prediction：把一句话滑动切成多个长度为 n+1 的训练样本，用前 n 个词预测最后一个词。然后指出 one-hot 的两个面向：一方面它不预设词的重要性和相互关系，因为所有向量等长、任意两个不同 one-hot 的距离都相同（老师口头给出为 $\sqrt{2}$）；另一方面它非常高维、极稀疏，只占据空间中的极少有效点。因此需要把 one-hot 映射到低维空间，为下一段的 embedding 做准备。待核对项主要是字幕中个别维度数字和学生姓名。

00:21:12-00:31:10（sections/003）
本段正式引入 projection 与 embedding：真正输入模型的不是 one-hot 本身，而是 $P \times W$；由于 $W$ 是 one-hot，这相当于从矩阵 $P$ 中取出对应的一列，该列就是词的低维 embedding。老师先把这种固定历史模型称为 TDNN：例如 five-gram 用前四词预测下一词，常见隐藏激活是 tanh，输出为 softmax。随后又提到 soft bag of words 与 skip-gram 这类替代机制，它们的共同目标仍是学习投影矩阵 $P$。Mikolov 2013 的国家-首都位移、man/woman/king/queen 例子被用来说明：如果投影学得好，低维空间中的距离和位移会承载语义。之后老师总结：language model 真正建模的是整个词序列概率，只是通常拆成 next token prediction；embedding 则是压缩后的低维词表示。最后从 TDNN 过渡到 recurrence，指出如果想基于“全部过去”预测下一词，LSTM/RNN 更自然。需注意老师在中途口误提到 LSTM 后立刻更正为“此处是 TDNN”。

00:31:09-00:41:07（sections/004）
这里老师把 recurrent language model 推到真正的生成过程：给一个初始前缀，模型输出下一个词的分布，抽一个词出来，再把它送回模型继续生成。问题在于何时停止。代码生成可能有自然终止，但音乐生成之类任务未必有，因此必须显式加入 `<sos>` 和 `<eos>`。老师用 “four score and eight” 的四种写法说明：没有边界标记时只知道是句中片段；前有 `<sos>` 是句首片段；后有 `<eos>` 是句尾片段；同时具备两者才是完整句子。随后他回到本讲问题，给出最朴素的 delayed seq2seq：先完整处理输入得到最终 hidden representation，再仅基于这个表示逐步生成输出，直到 `<eos>`。但老师马上指出该结构的缺陷：下一步 hidden state 只看前一步 hidden state，不知道上一词实际抽成了什么，因此无法体现像 “a/an” 这种会影响后继词分布的约束。

00:41:04-00:51:04（sections/005）
上一段的问题在这里被修复。老师继续用 “a / an” 例子说明：如果已生成词不反馈给模型，后面的分布就不会因为上一词不同而改变。解法是把输出词回馈成下一步输入，这就得到 delayed self-referencing sequence-to-sequence model，也就是本讲的 simple translation model。其前半部分读取输入直到输入端 `<eos>`，把整句压成最终 hidden representation；后半部分以该表示和 `<sos>` 为起点逐步生成输出，每一步从分布里抽词，再把该词送回模型，直到生成 `<eos>`。老师随后正式命名：前半部分是 encoder，后半部分是 decoder，并追问大家有没有见过类似结构，答案是 decoder 本质上就是前面讲过的 language model，只不过现在它被输入条件化，因此是 conditional language model。最后再补充真实实现并不是直接处理 one-hot，而是先经过输入侧或输出侧各自的 projection matrix 变成 embedding。

00:51:01-01:01:00（sections/006）
在已经有了 encoder-decoder 结构之后，老师把 attention 放到 inference 目标上。先说明“从分布里抽词”并不神秘：把词表概率累积成一条线段，再从均匀分布中取一点，落到哪段就选哪个词。接着指出，如果做机器翻译，真正的目标不是抽一个看起来合理的词串，而是在所有以 `<eos>` 结束的候选输出里，找条件概率最高的整句。这个整句概率可按 decoder 每一步给出的条件概率连乘得到。由此，局部 greedy 地每步取最高概率词并不可靠。老师用语音识别反例说明：第二词如果选局部稍高的 “nose”，会导致 “he nose ...” 让后续分布非常混乱；而选局部略低的 “knows”，形成 “he knows ...” 后，第三词分布反而更尖、更合理，于是整句乘积概率更高。这里建立了 beam search 的直接动机。

01:00:57-01:10:57（sections/007）
这一段继续回答“那到底怎么找更可能的整句”。随机采样虽然有时比 greedy 好，但仍不能保证最优；理论上更正确的办法是把每一步所有可能词都保留下来，让网络在所有词上同时分叉，任何完整路径的概率都能通过沿途概率相乘得到。然而这会指数爆炸：词表大小为 $V$，走到第 $t$ 步就有 $V^t$ 条路径。所以老师提出 beam search：每一步只保留当前总分最高的前 $K$ 条路径，比较的不是局部一步概率，而是整条前缀路径的乘积概率。老师同时提醒，beam search 仍然不是理论最优，因为剪枝可能把真正最佳路径删掉；而且简单分数还会偏向短句，所以常需附加启发式。随后话题转入训练：simple translation model 要同时学习 encoder 产出条件表示的能力，和 decoder 作为 conditional language model 的预测能力。训练时像 language model 一样，用目标序列的移位版本监督 decoder 各步输出。

01:10:55-01:20:54（sections/008）
老师在这一段把训练说透。他指出这与普通监督学习的根本不同在于：训练时 decoder 不是只看 encoder 的表示自由生成，而是还把目标输出前缀显式送进去，老师把它形容成“cheat code”。原因很实际：若按推理模式跑，模型一开始就可能生成错词，后面序列与目标全部错位，就很难比较和更新。因此训练的前向同时使用输入源句和目标前缀，反向则把每一步输出分布与目标词之间的 divergence 回传，联合更新 encoder 与 decoder。随后老师展示这一统一结构的应用：机器翻译、语音识别、对话、图像描述都可以写成“输入编码 + 条件语言模型解码”。翻译论文例子显示 encoder 最终 hidden representation 能把语义相近或结构对应的句子放在相近位置；对话例子说明 seq2seq 能生成接近人工客服的回复；图像描述例子说明只要把 encoder 换成 CNN，decoder 仍可作为 conditional language model 逐词出 caption。段末老师指出 simple model 的关键缺陷：整个输入只在解码起点注入一次，条件信息可能随后被稀释，所以可以考虑在每个解码时刻都重复输入 encoder 表示，这正是下节课要继续做的改进。

01:20:51-01:22:08（sections/009）
结尾一分钟是全讲压缩总结。老师先把 language model 定义再说一遍：它建模语言中词或符号序列的概率，通常借助 next-symbol prediction 来实现。然后把本讲的 simple seq2seq 重新概括成 encoder-decoder：encoder 抽取输入符号序列的表示，decoder 作为 conditional language model 在该表示条件下生成输出；inference 的目标是找到给定输入后最可能的完整输出序列，而这一整套机制也可直接迁移到 image captioning、video captioning 这类条件生成任务。最后，老师给出下一讲的唯一悬念：当前模型把全部输入都压到了一个单一 hidden representation 上，这个“家伙”承担得太多了，下一节课要讨论如何做得更好。
