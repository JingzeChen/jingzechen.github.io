## 学习目标
- 说清 Hopfield net 为什么要通过加入 hidden neurons 扩容，以及这些 hidden bits 为什么会把问题推向概率建模。
- 理解老师如何从热力学中的自由能、熵和温度出发，得到 Boltzmann distribution，并把它当成随机 Hopfield net 的平衡分布。
- 解释为什么单个神经元在固定其他位时的条件分布是 sigmoid，以及这如何导出 Gibbs sampling 式的随机更新。
- 掌握 Boltzmann machine 训练的两类期望：数据侧相关性和模型侧相关性，并理解为什么必须靠采样近似第二项。
- 区分完整 Boltzmann machine 与 Restricted Boltzmann Machine，知道 RBM、contrastive divergence 和无监督预训练在历史上的作用。

## 需要的先修知识
- 上一讲 Hopfield net 的基本定义：对称连接、二值状态、local field、能量下降与稳定态。
- 基本概率论与最大似然：条件概率、边缘化、期望、对数似然。
- 基本微积分：log-sum-exp 的求导、链式法则、带约束优化中的拉格朗日乘子。
- 对 sigmoid/logistic 的基本熟悉度，有助于看懂老师为何说它“不是从天上掉下来的”。
- 基本热力学直觉：绝对零度、温度、熵、自由能、退火。

## 老师的教学主线
老师先回顾 Hopfield net 作为 content-addressable memory 的确定性故事，指出它的容量只和网络宽度同阶，因此必须靠增加 hidden neurons 扩容。接着他说明，一旦 hidden bits 不要求被精确回忆、且同一 visible pattern 可以配多组 hidden completions，网络就更适合被理解为概率机器而不是确定性机器。

在这个转折后，老师回到热力学：真实系统在非零温度下不会停在某个状态，而会形成按 free energy 最小化得到的 Boltzmann distribution。随后他把这一分布搬到 Hopfield net 上，推导单个 bit 在固定其余位时的条件概率，从而得到 sigmoid 更新与 Gibbs sampling。

有了随机网络定义后，老师再把训练写成最大似然问题：观测模式的相关性要被抬高，模型自己自由游走时产生的相关性要被压低。再往后，他引入 hidden units 的边缘化训练、RBM 的结构约束、contrastive divergence 的近似，以及 RBM 预训练如何成为后续神经网络复兴的起点。

## 核心概念与依赖关系
- 容量瓶颈：Hopfield net 可刻意存储的模式数大致与神经元数 N 同阶。
- visible / hidden neurons：通过新增 hidden neurons 把模式宽度从 N 扩到 N+K，但 hidden bits 本身不是最终要读出的内容。
- 概率化动机：hidden bits 不必精确复原，同一 visible pattern 可对应多个 hidden completions，因此要改用分布而不是单个固定 completion。
- 热力学桥梁：固定温度下系统最小化 Helmholtz free energy，稳态分布是 Boltzmann distribution。
- 条件分布到 sigmoid：整体状态 obey Boltzmann distribution 时，单个 bit 的条件分布是 logistic，这给出随机更新规则。
- 训练到采样：最大似然梯度拆成数据期望减模型期望；模型期望不可穷举，只能靠运行网络采样。
- hidden units 训练：要最大化 visible 的边缘概率，因此要先 clamp visible 补 hidden，再 free-run 全网。
- RBM 加速：去掉层内连接后，clamped sampling 可以一步完成，从而引出 contrastive divergence 和预训练。

## 关键推导、例子与结论边界
- 关键推导 1：自由能最小化加上概率和为 1 的约束，导出 \(P(S) \propto e^{-E(S)/(kT)}\)。由于课件 OCR 缺字，记忆重点应放在“自由能 -> Boltzmann 分布”的链条，而不是模糊字符。
- 关键推导 2：比较只差一个 bit 的两个状态，在固定其余位的前提下把对数概率差化成 local field 的仿射项，从而得到 sigmoid 条件分布。
- 关键推导 3：最大似然梯度分成 \(\langle s_i s_j \rangle_{data} - \langle s_i s_j \rangle_{model}\)；加入 hidden units 后，第一项变成对 \(P(H\mid V)\) 的期望。
- 关键例子 1：给图像补上 K 个“不关心位”，说明扩容不是改变 Hopfield 数学容量定理，而是通过增加模式宽度和网络规模来提升可存储模式数。
- 关键例子 2：小 valley 与大 valley 的能量图说明随机上坡为何能逃离 parasitic memories。
- 关键例子 3：把类别编码成附加 bits，说明分类可以被改写成 pattern completion。
- 结论边界：完整 Boltzmann machine 的训练代价极高，老师明确说它对大问题“不太工作”；实用突破主要来自 RBM 与后续近似训练方法，而不是完整模型本身。

## 易错点与待核对项
- 不要把“hidden bits 不重要”误解成“hidden bits 可以完全忽略”；它们虽然不作为最终读出目标，却直接影响能量地形和训练采样。
- 不要把随机 Hopfield net 理解成“每一步都降能量”；随机系统可以上坡，只是整体分布偏向低能状态。
- 不要把数据分布和模型分布混为一谈：训练数据来自真实分布，而模型项来自当前参数下的 Boltzmann distribution。
- 不要把 RBM 的高效理解成“无需采样”；它仍然需要 Gibbs-style 交替采样，只是因结构受限而快得多。
- 课件第 25-30、38-44、50-55、91-99 页的若干公式在 OCR 中缺字；若后续需要逐字符公式，应回看原 PDF 或视频。[需回听]

## 掌握标准
- 能不用原课件复述：为什么 hidden neurons 让 Hopfield net 自然转向 Boltzmann machine。
- 能写出并解释 Boltzmann distribution、单 bit 的 sigmoid 条件分布，以及它们各自回答的建模问题。
- 能说明训练梯度为什么是“数据期望减模型期望”，以及两项分别如何通过 clamped/free sampling 估计。
- 能比较 full BM、RBM、contrastive divergence 三者在结构与训练代价上的差异。
- 能把 RBM 预训练与 2000 年代后期神经网络复兴的历史线索连接起来。

## 复习顺序
1. 先重看 00:00:00-00:19:56，把容量瓶颈、visible/hidden neurons 和“为什么必须概率化”弄清楚。
2. 再看 00:19:56-00:39:54，把自由能、Boltzmann 分布、sigmoid 条件分布和随机更新规则连成一条线。
3. 接着看 00:39:51-01:09:44，把 recall、温度、最大似然梯度、hidden 边缘化训练这几块拼起来。
4. 最后看 01:09:39-01:20:52，把 RBM、contrastive divergence、分类与预训练放回历史背景中总结。

## 逐段详细课堂笔记
### 001 00:00:00-00:09:59
老师先完整回顾上一讲的 Hopfield network：它是对称、带环、输出为 +1/-1 的二值网络；神经元不断和 local field 对齐，因此网络能量单调下降，并在有限步内收敛到稳定态。随后他重申 Hopfield net 作为 content-addressable memory 的作用，并回顾 Hebbian learning 能训练出有限数量的稳定记忆。接着他指出容量瓶颈：网络可刻意存储的模式数只和 N 同阶，于是提出工程化扩容方案，即给每个 N 位模式补上 K 个不关心位，把网络扩成 N+K 个神经元。前 N 个位置是 visible neurons，新增 K 个位置是 hidden neurons。本段最后把真正问题钉住：hidden bits 不能只是随手乱填，因为它们会参与能量地形，决定网络究竟能否更好地记忆。

### 002 00:09:57-00:19:56
老师说明，如果只是随机补 hidden bits 再按老 Hopfield 方式召回，就没有利用“不关心 hidden bits”这一关键自由度。投票题后的结论是：Hopfield net 容量是 O(N)，扩容方式是追加 K 个额外位，而召回 visible pattern 时并不需要把这些额外位精确回忆出来。由此老师提出两个可利用事实：第一，hidden bits 出错无所谓；第二，同一 visible pattern 完全可以对应许多不同的 hidden completions，于是能量地形里会出现多个共享相同 visible 输出的 valley，使召回更稳。也因此，简单随机填充虽然可行，却浪费了冗余。真正聪明的办法是把整个系统改看成概率机器，让 hidden bits 的多种 completion 被系统性利用起来。

### 003 00:19:56-00:29:56
老师回到热力学直觉，强调在非零温度下，系统不会停在单一状态，而会在多种状态之间随机跳动，所以真正被决定的是状态概率分布。每个状态有自己的能量，系统整体的 internal energy 是能量对状态分布的期望；但固定温度下系统自然演化时，下降的不是单纯的内能，而是“内能减去温度乘熵”的 Helmholtz free energy。对自由能在“概率和为 1”约束下做最小化，会得到 Boltzmann/Gibbs distribution：状态概率与 \(e^{-E/(kT)}\) 成正比，能量越低概率越高，T=0 时只剩最低能状态，T 越大时分布越平。老师明确说，这就是后面随机 Hopfield/Boltzmann machine 要去模拟的对象。

### 004 00:29:54-00:39:54
老师把随机 Hopfield net 定义成一个对二值状态分布建模的生成模型：平衡时它服从 Boltzmann distribution。随后他推导单个神经元的随机更新规则：取两个只在第 i 位不同、其余位 R 完全相同的状态 S 与 S'，把对数概率差写成条件对数几率，再利用 Boltzmann 形式把它化成 local field 加 bias 的仿射项。整理后得到单个 bit 在给定其余位时取 1 的条件概率就是 sigmoid。于是网络演化规则变成 Gibbs sampling：逐个神经元计算该概率，再按它采样，而不是做确定性阈值判断。达到平衡后，不能只看最后一步状态，而要对最后若干步样本求平均，把平均态当成 recall 结果。

### 005 00:39:51-00:49:50
这一段把随机 Hopfield net 的使用方式讲清楚。对 noisy pattern completion，整张带噪图像都可以自由演化；对 partial pattern completion，则要把已知部分固定，只让未知部分演化。随后老师显式加入温度项，说明高温会压平能量地形、让 bit 概率更接近 0.5；T=1 回到标准随机 Hopfield，T=0 则退化为确定性 Hopfield。由于系统达到平衡后仍会继续跳动，所以 recall 的“停止”应理解为分布稳定，再通过后期样本平均来读出预测配置。课件还用 Poll 3 强化两个判断：神经元按 logistic 概率翻转；随机系统确实可能以非零概率翻向更高能量状态。

### 006 00:49:48-00:59:46
老师开始讲没有 hidden units 时的玻尔兹曼机训练。他先把目标说成“让模型给观察到的状态更高概率”，并用“训练集中 2 比 9 常见得多”说明频率应反映在概率上。将 Boltzmann 概率取对数后，可分成能量项和 log partition 项。对平均 log likelihood 求导时，第一项变成训练数据上 \(s_i s_j\) 的平均，和 Hopfield 的 Hebbian 项同形；第二项则化成模型分布下 \(s_i s_j\) 的期望。因为这个模型期望无法穷举全部状态，所以必须让网络自由运行来采样，使用 simulated states 的平均进行近似。最终更新规则就是数据相关性减模型相关性。

### 007 00:59:44-01:09:44
老师把训练推广到真正含 hidden neurons 的玻尔兹曼机。完整状态可写成 \((V,H)\)，而训练数据只给出 V，所以学习目标是 visible 边缘概率 \(P(V)=\sum_H P(V,H)\)。对每个训练样本，不能挑唯一的 hidden completion，而要在当前模型下固定 visible bits、让 hidden bits 按条件 Boltzmann distribution 演化并采样，从而补出 completed pattern。然后再解除 visible 的固定，让整张网络自由演化，得到模型样本。梯度仍然是“数据侧期望减模型侧期望”，只是数据侧现在也需要经过 hidden 的采样补全。老师把这概括成一个两阶段循环：先 clamp visible 补 hidden，再 free-run 全网，然后用两种样本的 bit 乘积差来更新权重。

### 008 01:09:39-01:19:39
老师先用 Poll 4 复核：扩容时增加的 irrelevant bits 就是 hidden neurons，而训练玻尔兹曼机时确实要通过采样 hidden values 来补全完整模式。接着他指出，概率化还有第二重意义：允许系统偶尔上坡，从而跳出小的 parasitic valley，进入更大的目标 valley。随后他把分类也改写成 pattern completion：把 class bits 拼到特征后面，固定特征，让类位自己补全；100 个类别不需要 100 位，大约 7 位即可，还能额外留 buffer。再往后，老师说明完整 Boltzmann machine 太慢，于是引出 RBM 的二部图限制：visible 只连 hidden，hidden 只连 visible。这样 clamped phase 可以一步采样 hidden，自由运行阶段也只需交替采样两层。沿着 Hopfield “只需抬高邻域”的直觉，还得到 contrastive divergence，说明短链就足以给出好梯度估计。最后老师把 RBM、连续值 harmoniums、深层变体和无监督预训练串起来，并明确指出：先丢掉标签，用 RBM 预训练再初始化分类器，是 2000 年代后神经网络重新变得可训练的重要起点。

### 009 01:19:36-01:20:52
最后一段完全是收束。老师再次强调，用无监督方式先学到权重、再拿这些权重初始化最终分类器，会让以前“怎么都训不动”的网络突然开始工作；这正是后续神经网络革命的起点。他给出一个历史时间线：大约从 2004 年开始转折，2010 年前后神经网络全面复兴，到 2015 年世界已经不同。最后，老师把玻尔兹曼机、RBM 与无监督预训练如何重新打开神经网络训练这条线索收束起来，并用对整门课的致谢结束本讲。
