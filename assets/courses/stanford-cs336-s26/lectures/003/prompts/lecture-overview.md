## 学习目标
- 通过横向比较现代大语言模型，分清哪些架构与超参数选择已形成强共识，哪些仍在快速变化。[课件: lecture_03.pdf p.2][课件: lecture_03.pdf p.7]
- 理解现代 Transformer 相比原版最关键的默认变化：non-residual norm、RMSNorm、GLU、RoPE、推理友好的 attention 头压缩。[课件: lecture_03.pdf p.3][课件: lecture_03.pdf p.4][课件: lecture_03.pdf p.29][课件: lecture_03.pdf p.55][课件: lecture_03.pdf p.63]
- 建立一套务实判断框架：先用行业默认值起步，再把精力集中在真正仍有不确定性的长上下文与稳定性问题上。[课件: lecture_03.pdf p.8][课件: lecture_03.pdf p.51][课件: lecture_03.pdf p.67]

## 需要的先修知识
- 需要知道原版 Transformer 的基本部件：残差流、LayerNorm、FFN、multi-head attention、位置编码。[课件: lecture_03.pdf p.3]
- 需要知道 attention 是基于内积的，并理解自回归生成与训练/prefill 在计算模式上的差异。[00:31:28-00:31:39][00:17:00-01:18:22]
- 需要能跟上常见模型训练术语：warmup、gradient spikes、KV cache、dropout、weight decay、arithmetic intensity。[00:09:54-00:10:18][00:15:00-00:16:14][01:00:35-01:03:19][01:17:23-01:18:22]

## 老师的教学主线
- 先从“看很多模型报告”而不是“背一个标准答案”出发，把本讲定位成经验综述。[00:00:38-00:01:29][课件: lecture_03.pdf p.2]
- 再沿着原版 Transformer 到现代默认的演化线，依次讨论 norm、激活、位置编码，说明主干其实改得不多，但几处改动高度稳定。[00:01:55-00:39:03][课件: lecture_03.pdf p.10][课件: lecture_03.pdf p.29][课件: lecture_03.pdf p.35]
- 接着切到超参数，强调很多量都有安全默认范围，真正重要的是理解这些默认值背后的系统与经验依据。[00:43:40-01:04:04][课件: lecture_03.pdf p.37][课件: lecture_03.pdf p.51]
- 最后把重点转到稳定训练和推理成本：softmax 是危险区，QK norm / z-loss / soft-capping 是稳态技巧；GQA 与混合 attention 是面向部署和长上下文的当代主线。[01:05:02-01:29:08][课件: lecture_03.pdf p.54][课件: lecture_03.pdf p.55][课件: lecture_03.pdf p.63][课件: lecture_03.pdf p.65]

## 核心概念与依赖关系
- `norm 放置 -> 稳定性 -> 深层训练能力`：把 LayerNorm 移出残差主干，可以保住残差流和梯度传播，再进一步自然过渡到 QK norm 等更细稳定技巧。[课件: lecture_03.pdf p.10][课件: lecture_03.pdf p.12][课件: lecture_03.pdf p.55]
- `RMSNorm / 去 bias -> 更少数据搬运 -> 更高 wall-clock 效率`：老师把这条线直接绑到 arithmetic intensity，而不是只谈 FLOPs。[课件: lecture_03.pdf p.15][课件: lecture_03.pdf p.16][课件: lecture_03.pdf p.18]
- `GLU -> 额外矩阵 -> d_ff 需做 2/3 修正`：架构选择会反向约束超参数默认值。[课件: lecture_03.pdf p.23][课件: lecture_03.pdf p.38]
- `RoPE -> 相对位置目标 -> Q/K 旋转实现`：位置编码不只是“加一个位置向量”，而是决定注意力如何保留相对位移信息。[课件: lecture_03.pdf p.31][课件: lecture_03.pdf p.35]
- `训练/prefill 与生成推理差异 -> KV cache -> GQA/MQA`：只有先看到推理期的内存访问瓶颈，才会明白为什么要减少 K/V 头数。[课件: lecture_03.pdf p.58][课件: lecture_03.pdf p.60][课件: lecture_03.pdf p.61][课件: lecture_03.pdf p.62]
- `长上下文成本 -> full/local 交替 attention`：这是本讲结尾指出的最新活跃创新区。[课件: lecture_03.pdf p.64][课件: lecture_03.pdf p.65][课件: lecture_03.pdf p.66]

## 关键推导、例子与结论边界
- 关键经验式包括：`d_ff = 4 d_model`，GLU 常改成约 `8/3 d_model`，而 `num_heads * head_dim ≈ d_model` 与 `d_model / n_layers ≈ 100` 是另外两条常用默认。[课件: lecture_03.pdf p.37][课件: lecture_03.pdf p.38][课件: lecture_03.pdf p.42][课件: lecture_03.pdf p.44]
- RoPE 的关键目标式是 `<f(x,i), f(y,j)> = g(x,y,i-j)`；老师用 “we know that” / “of course we know” 的旋转例子解释它如何保住相对关系。[课件: lecture_03.pdf p.31][课件: lecture_03.pdf p.32]
- 输出 softmax 的 `z-loss`、attention softmax 的 QK norm 与 soft-capping，展示了稳定性技巧主要围绕 softmax 数值行为展开。[课件: lecture_03.pdf p.54][课件: lecture_03.pdf p.55][课件: lecture_03.pdf p.56]
- 结论边界上，老师反复强调：很多默认值只是“安全且够好”，不是数学定理。T5 的 `64x d_ff`、Gemma 4 的 p-RoPE、Google 系若干例外，都说明创新仍会出现。[课件: lecture_03.pdf p.39][课件: lecture_03.pdf p.41][课件: lecture_03.pdf p.43][00:37:16-00:37:32]

## 易错点与待核对项
- 不要把“现代模型普遍用 prenorm”误解成“只能 prenorm”；老师明确展示了 non-residual post-norm 和 double norm 变体。[课件: lecture_03.pdf p.13]
- 不要把 RMSNorm 的理由简化成“FLOPs 更少”，本讲更强调的是 runtime 与数据搬运。[课件: lecture_03.pdf p.15][课件: lecture_03.pdf p.16]
- 不要把 GLU 理解成绝对必要条件；老师明确说 GPT-3 等非 GLU 模型也能工作，只是主流经验更偏向门控。[课件: lecture_03.pdf p.26]
- 不要把 regularization 在 LM 里简单等同为“防过拟合”；weight decay 在这里常更像优化干预。[00:59:55-01:03:19]
- 需要回听确认的地方主要是字幕中的作者名、个别人名、Gemma 4 口头术语，以及少数 [INAUDIBLE] 问答细节。[需回听]

## 掌握标准
- 能用自己的话说清：为什么 non-residual norm、RMSNorm、GLU、RoPE 会成为现代默认项。
- 能写出并解释三条经验性超参数默认：`d_ff / d_model`、`num_heads * head_dim / d_model`、`d_model / n_layers`。
- 能说明为什么 softmax 是稳定性危险区，以及 `z-loss`、QK norm、soft-capping 分别在控制哪里。
- 能解释推理期 KV cache 带来的内存瓶颈，并说明为什么 GQA 比 MQA 更常成为现实选择。
- 能概括当下仍在快速演化的部分主要集中在长上下文与位置/注意力混合结构，而不是整个 Transformer 主干。

## 复习顺序
- 先复习整讲方法论与原版/现代 Transformer 对照，再看 norm、RMSNorm、bias 删除这些最稳定的共识项。[课件: lecture_03.pdf p.2][课件: lecture_03.pdf p.3][课件: lecture_03.pdf p.4][课件: lecture_03.pdf p.19]
- 再复习 GLU 与 RoPE，因为它们一头连着现代默认架构，一头连着超参数和实现细节。[课件: lecture_03.pdf p.23][课件: lecture_03.pdf p.35]
- 接着整理三组默认超参数和 regularization 的反直觉结论，把“可直接拿来当起点”的经验值记牢。[课件: lecture_03.pdf p.41][课件: lecture_03.pdf p.51]
- 最后集中复习稳定性与推理期 attention：QK norm、soft-capping、KV cache、GQA、滑窗/全局交替 attention，因为这些最容易跨到后续系统课与长上下文主题。[课件: lecture_03.pdf p.55][课件: lecture_03.pdf p.56][课件: lecture_03.pdf p.60][课件: lecture_03.pdf p.65]