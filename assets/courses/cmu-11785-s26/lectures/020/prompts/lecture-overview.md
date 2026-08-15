## 学习目标
理解老师为何从 RNN 的信息瓶颈、长程依赖和并行性问题出发引入 attention；能按顺序复述原始 transformer 的输入处理、位置编码、注意力、前馈层、残差归一化和输出投影；能区分 encoder-decoder、encoder-only、decoder-only 三类架构及其典型任务；知道现代改进集中在位置编码外推能力与注意力效率上。

## 需要的先修知识
默认已学过 RNN/encoder-decoder、hidden state、上下文向量、梯度消失与爆炸、embedding、softmax、矩阵乘法、teacher forcing、next-token prediction。作业背景还要求学生能看懂 attention map、beam search、top-k/top-p 等基本解码名词。

## 老师的教学主线
老师先给整讲地图，再回顾 RNN 的三类问题：固定长度 context vector 的信息瓶颈、O(n) 路径导致长程依赖难学、顺序依赖导致 GPU 并行受限。随后引入 attention 作为动态上下文机制，并借此提出“也许不需要 recurrence”。在此基础上，他按 tokenization、embedding、sinusoidal positional encoding、scaled dot-product attention、multi-head attention、masking、cross-attention、feed-forward、add & norm、output projection 的顺序完整走完原始 transformer。后半段转为现代综述：先讲三类架构代表 T5/BERT/GPT，再讲位置编码从 sinusoidal 走向 rotary/T5 bias/ALiBi，最后讲 attention 的效率问题、FlashAttention 和 KV caching。课堂末尾明确说明多模态、PEFT、量化等剩余主题只留在 slides 中。

## 核心概念与依赖关系
attention 的引入依赖前面对 RNN 信息瓶颈的识别；transformer 的输入端依赖 tokenization 把文本变成 ID，再由 embedding 变成向量；由于 attention 本身不含顺序，需要 positional encoding 注入位置信号；scaled dot-product attention 是核心算子，multi-head attention 是其并行多视角扩展；encoder 侧通常双向，decoder 侧需要 causal mask，自回归条件生成还要通过 cross-attention 把解码器 query 接到编码器表示上；feed-forward、residual、layer norm 负责提高表达能力和训练稳定性；最后输出投影把 `d_model` 映射回词表概率。现代部分的依赖关系则是：先有原始架构，再沿“架构类型”“位置编码”“高效实现”三条线演化。

## 关键推导、例子与结论边界
可明确复述的推导结论包括：RNN 的远距通信路径是 O(n)；scaled dot-product attention 要除以 `sqrt(d_k)`，因为点积方差随维度上升、softmax 易饱和；multi-head attention 通过 `D_k = h × D_h` 的拆分让多头并行建模不同关系；sinusoidal positional encoding 用多频率正余弦并通过相加注入位置信号。关键例子包括法译英 attention、语音到文本的对齐图、`the dog bit the man` 与 `the man bit the dog` 的顺序差异、以及视觉 cross-attention 中 “bear / watches / bird” 的焦点变化。结论边界也很清楚：WordPiece likelihood 细节、sinusoidal 公式逐项写法、GQA/MQA/MLA 原理、以及 ViT/Conformer/PEFT/量化的细节，课堂 transcript 都未完整展开，不能外推补讲。

## 易错点与待核对项
不要把 attention 误解成只看最后一个编码器状态；不要把 `sqrt(d_k)` 记成 `d_k`；不要把 self-attention 与 cross-attention 的 QKV 来源混淆；不要把 layer norm 当成 batch norm；不要把“课件列出某主题”误记成“老师已详细讲完该主题”。待核对的主要地方是若需要逐条公式或某些问答的严格技术细节，应回听 `[00:04:08]-[00:04:46]`、`[00:27:16]-[00:28:34]` 和位置编码公式处的原视频或对应 slides。

## 掌握标准
能说明 transformer 解决了 RNN 的哪三个主要问题；能写出从 tokenization 到输出投影的模块顺序；能用自己的话解释 Q、K、V、self-attention、cross-attention、causal mask、pre-norm、KV caching；能说清 BERT、T5、GPT 分别对应什么架构和训练目标；能指出 FlashAttention 的收益来自 IO-aware 实现而非更换数学目标。

## 复习顺序
先复习 RNN 局限与 attention 动机，再按“tokenization -> embedding -> position -> attention -> multi-head -> masking -> cross-attention -> FFN -> norm -> output”顺序梳理原始 transformer。之后再看现代综述：先三类架构，再位置编码改进，再高效注意力。最后把课堂没展开但 slides 留存的主题单独标为补充阅读，不与课堂主线混在一起。
