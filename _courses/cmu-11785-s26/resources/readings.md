---
uid: cmu-11785-s26-resource-readings-3
type: course
document_type: resource
resource_kind: readings
resource_order: 3
course: cmu-11785-s26
title: CMU 11-785 S26 阅读路线（Lecture 0-28）
description: 按 Lecture 对齐官方论文、补充阅读、复用关系与证据边界。
excerpt: 按 Lecture 对齐官方论文、补充阅读、复用关系与证据边界。
content_lang: zh-CN
permalink: "/courses/cmu-11785-s26/readings/"
toc: true
---

本文件只整理官方课表中 `paper` 与 `reading` 两类资源，来源限定为 `source-manifest.json`、`materials-index.json`、`MATERIALS.md` 与课表标题本身。

## 使用边界

- 课堂关联只写到课表标题或已有课堂笔记能够直接支持的程度；没有额外证据时，不推断论文结论、教学意图或讲内具体使用方式。
- 资源若有本地归档，使用相对本文件可直接打开的本地链接；没有归档时，保留官方外链。
- `paper` 视为课程论文条目；`reading` 视为其他阅读或工具入口，和论文分开展示。
- 版权与许可边界：本地归档只是课程材料副本入口，不改变原始版权、访问条件或站点许可；外链资源仍以原站点条款为准。
- 计数边界：最终应为 `17` 个唯一 `paper` 加 `11` 个唯一 `reading`。课程索引里 Lecture 03 与 Lecture 04 复用了同一份 `c1992artificialneural.pdf`，本路线只在首次出现的 Lecture 03 计数一次，Lecture 04 仅保留复用说明。

## 建议阅读顺序

1. 按讲次顺序读，先完成 Lecture 01-08 的历史、表示能力、训练与优化，再进入后续专题。
2. 每讲先看本讲标题与 Slides，再读本页列出的 `paper`，最后看 `reading` 类网页或工具。
3. 遇到“复用说明”的条目，回到首次列出的讲次读取，不在后续讲次重复计数。
4. Lecture 09-12、15-28 若本页标注“无”，表示官方清单没有把 `paper` 或 `reading` 归到该讲，不代表该讲没有 Slides 或视频。

## 阅读检查清单

- [ ] 我已按讲次浏览完 Lecture 00-28 的整张路线表。
- [ ] 我已区分 `paper` 与“其他阅读/工具”两类入口。
- [ ] 我已优先打开所有有本地归档的资源，再决定是否访问外链。
- [ ] 我已注意 Lecture 03 与 Lecture 04 的复用条目不重复计数。
- [ ] 我已完成总数自检：`17` 个 `paper`，`11` 个 `reading`。

## Lecture 00: Course Logistics Learning Objectives Grading Deadlines

- 课堂关联：课表标题只支持把本讲视为课程组织、学习目标、评分与截止日期说明。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 01: Introduction

- 课堂关联：课表标题只支持把以下材料归到“Introduction”导入讲次。

### 已布置论文

- [The New Connectionism (1988)](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Perceptrons-Epilogue-r.pdf)
- [On Alan Turing's Anticipation of Connectionism](/assets/courses/cmu-11785-s26/materials/official-materials/readings/turing3.pdf)
- [McCullogh and Pitts paper](/assets/courses/cmu-11785-s26/materials/official-materials/readings/McCulloch.and.Pitts.pdf)
- [Rosenblatt: The perceptron](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Rosenblatt_1959-09865-001.pdf)
- [Bain: Mind and body](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Alexander_Bain_Mind_and_Body_009178a0.pdf)

### 其他阅读/工具

- [Hebb: The Organization Of Behaviour](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Hebb_1949_The_Organization_of_Behavior.pdf)

## Lecture 02: Neural Nets As Universal Approximators

- 课堂关联：课表标题只支持把以下材料归到“Neural Nets As Universal Approximators”这一讲。

### 已布置论文

- [Size and Depth complexity of Boolean Circuits](/assets/courses/cmu-11785-s26/materials/official-materials/readings/booleancircuits_shannonproof.pdf)
- [The Synthesis of Two-Terminal Switching Circuits](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Shannon49.pdf)

### 其他阅读/工具

- 无。

## Lecture 03: Training Part I The Problem of Learning Empirical Risk Minimization

- 课堂关联：课表标题只支持把以下材料归到“Training Part I / Empirical Risk Minimization”这一讲。

### 已布置论文

- [Artificial Neural Networks of the Perceptron, Madaline, and Backpropagation Family](/assets/courses/cmu-11785-s26/materials/official-materials/readings/c1992artificialneural.pdf)
- [The Perceptron Learning Algorithm and its Convergence](/assets/courses/cmu-11785-s26/materials/official-materials/readings/Perceptron_Learning_Algorithm_and_Convergence.pdf)

### 其他阅读/工具

- 无。

## Lecture 04: Training Part II Gradient Descent Training the Network

- 课堂关联：课表标题只支持把以下材料归到“Training Part II / Gradient Descent / Training the Network”这一讲。

### 已布置论文

- 复用说明：课程清单在本讲再次引用 [Artificial Neural Networks of the Perceptron, Madaline, and Backpropagation Family](/assets/courses/cmu-11785-s26/materials/official-materials/readings/c1992artificialneural.pdf)，显示名为 “Widrow and Lehr (1992)”。为保持唯一资源总数，此文件已在 Lecture 03 计入，这里不重复列为新增资源。
- [Adaline and Madaline](/assets/courses/cmu-11785-s26/materials/official-materials/readings/04Adaline.pdf)
- [Convergence of perceptron algorithm](/assets/courses/cmu-11785-s26/materials/official-materials/readings/perc.converge.pdf)

### 其他阅读/工具

- [Threshold Logic](https://www.tutorialspoint.com/digital_circuits/digital_circuits_threshold_logic.htm)
- [TC (Complexity)](https://en.wikipedia.org/wiki/TC_(complexity))
- [AC (Complexity)](https://en.wikipedia.org/wiki/AC_(complexity))

## Lecture 05: Training Part III Backpropagation Calculus of Backpropagation

- 课堂关联：课表标题只支持把以下材料归到“Training Part III / Backpropagation / Calculus of Backpropagation”这一讲。

### 已布置论文

- [Rumelhart, Hinton and Williams (1986)](/assets/courses/cmu-11785-s26/materials/official-materials/readings/naturebp.pdf)

### 其他阅读/工具

- [Werbos (1990)](https://ieeexplore.ieee.org/document/58337)

## Lecture 06: Training Part IV Convergence issues Loss Surfaces Momentum

- 课堂关联：课表标题只支持把以下材料归到“Training Part IV / Convergence issues / Loss Surfaces / Momentum”这一讲。

### 已布置论文

- 无。

### 其他阅读/工具

- [Backpropagation Fails to Separate, Where Perceptrons Succeed, Brady et al. (1989)](https://ieeexplore.ieee.org/document/31314)
- [Why Momentum Really Works](https://distill.pub/2017/momentum/)

## Lecture 07: Training Part V Optimization Batch Size, SGD, Mini-batch, Second-order Methods

- 课堂关联：课表标题只支持把以下材料归到“Training Part V / Optimization / Batch Size / SGD / Mini-batch / Second-order Methods”这一讲。

### 已布置论文

- [Derivatives and Influences](/assets/courses/cmu-11785-s26/materials/official-materials/readings/derivatives_and_influences.pdf)

### 其他阅读/工具

- [Momentum and Polyak (1964)](https://www.sciencedirect.com/science/article/abs/pii/0041555364901375)
- [Nesterov (1983)](https://www.mathnet.ru/php/archive.phtml?wshow=paper&jrnid=dan&paperid=46009&option_lang=eng)

## Lecture 08: Training Part VI Optimizers and Regularizers Choosing a Divergence (Loss) Function Batch Normalization Dropout

- 课堂关联：课表标题只支持把以下材料归到“Training Part VI / Optimizers and Regularizers / Divergence or Loss / Batch Normalization / Dropout”这一讲。

### 已布置论文

- [Derivatives and Influence Diagrams](/assets/courses/cmu-11785-s26/materials/official-materials/readings/derivatives and influences.pdf)
- [ADAGRAD, Duchi, Hazan and Singer (2011)](/assets/courses/cmu-11785-s26/materials/official-materials/readings/duchi11a.pdf)

### 其他阅读/工具

- [Adam: A method for stochastic optimization, Kingma and Ba (2014)](https://arxiv.org/abs/1412.6980)

## Lecture 09: Convolutional Neural Networks (CNNs) I

- 课堂关联：课表标题只支持把本讲视为 CNNs I。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 10: CNNs II

- 课堂关联：课表标题只支持把本讲视为 CNNs II。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 11: CNNs III

- 课堂关联：课表标题只支持把以下资源归到 CNNs III；由于官方类别是 `reading`，这里只按“其他阅读/工具”展示，不额外推断其课堂作用。

### 已布置论文

- 无。

### 其他阅读/工具

- [CNN Explainer](https://poloclub.github.io/cnn-explainer/)

## Lecture 12: CNNs IV

- 课堂关联：课表标题只支持把本讲视为 CNNs IV。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 13: Recurrent Neural Networks (RNNs) I

- 课堂关联：课表标题只支持把以下材料归到 RNNs I；没有更多笔记证据时，不再推断该论文在讲内的具体论证位置。

### 已布置论文

- [Fahlman and Lebiere (1990)](/assets/courses/cmu-11785-s26/materials/official-materials/readings/69adc1e107f7f7d035d7baf04342e1ca-Paper.pdf)

### 其他阅读/工具

- 无。

## Lecture 14: RNNs II

- 课堂关联：课表标题只支持把以下材料归到 RNNs II。

### 已布置论文

- [How to compute a derivative](/assets/courses/cmu-11785-s26/materials/official-materials/readings/How to compute a derivative.pdf)

### 其他阅读/工具

- 无。

## Lecture 15: Sequence to Sequence Models Connectionist Temporal Classification (CTC)

- 课堂关联：课表标题只支持把本讲视为 Seq2Seq 与 CTC 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 16: Connectionist Temporal Classification Blanks Beam Search

- 课堂关联：课表标题只支持把本讲视为 CTC、Blank 与 Beam Search 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 17: Language Models Translation

- 课堂关联：课表标题只支持把本讲视为 Language Models 与 Translation 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 18: Attention Models Transformers

- 课堂关联：课表标题只支持把本讲视为 Attention Models 与 Transformers 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 19: Transformers and Newer Architectures

- 课堂关联：课表标题只支持把本讲视为 Transformers 与更新架构主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 20: Large Language Models

- 课堂关联：课表标题只支持把本讲视为 Large Language Models 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 21: Representation and Autoencoders

- 课堂关联：课表标题只支持把本讲视为 Representation 与 Autoencoders 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 22: Variational Auto Encoders

- 课堂关联：课表标题只支持把本讲视为 Variational Auto Encoders 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 23: Diffusion

- 课堂关联：课表标题只支持把本讲视为 Diffusion 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 24: Generative Adversarial Networks

- 课堂关联：课表标题只支持把本讲视为 Generative Adversarial Networks 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 25: Graph Neural Networks (GNNs)

- 课堂关联：课表标题只支持把本讲视为 Graph Neural Networks 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 26: Reinforcement Learning

- 课堂关联：课表标题只支持把本讲视为 Reinforcement Learning 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 27: Hopfield Networks

- 课堂关联：课表标题与现有 [lectures/028-Lecture-27-Hopfield-Networks-XmyIj53Ysmk/NOTES.md](/courses/cmu-11785-s26/lectures/028/) 都只支持把本讲视为 Hopfield Networks 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## Lecture 28: Boltzmann Machines

- 课堂关联：课表标题只支持把本讲视为 Boltzmann Machines 主题讲。
- 已布置论文：无。
- 其他阅读/工具：无。

## 计数校对

- 已列唯一 `paper`：`17`
- 已列唯一 `reading`：`11`
- Lecture 03 / Lecture 04 之间的复用条目：`1`
- 课表覆盖：Lecture `00-28` 共 `29` 讲
