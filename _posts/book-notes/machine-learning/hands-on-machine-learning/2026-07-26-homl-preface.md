---
title: "《Hands-On Machine Learning with Scikit-Learn and PyTorch》前言学习笔记"
date: 2026-07-26 08:00:00 +0800
updated: 2026-07-26
uid: homl-preface
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: hands-on-machine-learning
series_order: 1
related: [homl-ch01-ml-landscape]
references:
  - title: Hands-On Machine Learning companion repository
    url: https://github.com/ageron/handson-mlp
    note: Code and notebooks maintained for the PyTorch edition.
  - title: Installation guide
    url: https://homl.info/install-p
    note: Environment setup instructions for the book exercises.
categories: [读书笔记, 机器学习, Hands-On Machine Learning]
tags: [machine-learning, hands-on-ml, reading-notes]
description: 阅读《Hands-On Machine Learning》前言部分，理解新版内容结构、学习路径与实践方式。
toc: true
---

## 一句话概括

这是一本面向机器学习初学者的实践型教材：先用 Scikit-Learn 掌握机器学习基本概念和完整项目流程，再用 PyTorch 学习神经网络、Transformer、生成模型与强化学习；作者反复强调，应该先打牢传统机器学习基础，并通过运行和修改代码建立直觉。

## 核心摘要

1. 深度学习在 2006 年后重新受到重视，并随着算力和数据规模的增长取得突破；2022 年以来，AI 助手又进一步推动了人工智能在各行业的应用。
2. 机器学习不只是前沿研究，也可用于客户分群、推荐、欺诈检测、营收预测、人员配置和智能客服等实际业务。
3. 本书默认读者几乎没有机器学习基础，但需要具备 Python、NumPy、pandas 和 Matplotlib 的基本使用经验。
4. 本书采用“代码优先、少量理论、建立直觉”的方法，主要工具是 Scikit-Learn 和 PyTorch，也会使用 XGBoost、Hugging Face 与 Gymnasium。
5. 全书分成两部分：第一部分讲机器学习基础和经典算法，第二部分讲神经网络与深度学习。
6. 作者明确建议不要急于跳到深度学习。许多任务用随机森林、集成学习等传统方法就能很好地解决，而且成本更低。
7. 这一版从 TensorFlow/Keras 转向 PyTorch，并加入 NLP Transformer、视觉与多模态 Transformer、模型加速与扩展等新内容。
8. 最有效的阅读方式不是只看书，而是打开配套 Jupyter Notebook，运行、修改并观察每个示例。

---

## 前言分节意译

### 1. 前言：机器学习浪潮

2006 年，Geoffrey Hinton 等人发表论文，展示了如何训练一个识别手写数字准确率超过 98% 的深层神经网络，并将这项技术称为“深度学习”。深层神经网络是对大脑皮层高度简化的数学模型，由多层人工神经元组成。

当时，训练深层神经网络普遍被认为是不现实的，很多研究者在 20 世纪 90 年代末已经放弃了这条路线。这篇论文重新点燃了学术界的兴趣。此后，大量研究证明，在充足算力和海量数据的支持下，深度学习可以达到其他机器学习方法难以企及的效果，并带动了整个机器学习领域的发展。

十年后，机器学习已经深入许多行业：搜索结果排序、视频和商品推荐、生产线分拣，甚至自动驾驶。AlphaFold 解决长期困扰研究者的蛋白质折叠问题，是其中一个引人注目的里程碑。不过，更多时候机器学习只是在后台默默运行。

又一个十年中，AI 助手快速兴起：ChatGPT 于 2022 年出现，Gemini、Claude、Grok 等在 2023 年及以后陆续问世。人工智能从科幻概念变成现实，并开始快速改变几乎每个行业。

### 2. 在项目中使用机器学习

学习机器学习的动机可以很个人化，例如让自制机器人识别人脸或学会行走；也可以来自企业积累的大量数据，包括用户日志、财务数据、生产数据、机器传感器记录、客服统计和人力资源数据。

机器学习可以用于：

- 对客户进行分群，并为不同群体设计营销策略；
- 根据相似客户的购买记录推荐商品；
- 识别可能存在欺诈的交易；
- 预测下一年度营收；
- 预测业务高峰并建议合理的人员配置；
- 构建服务客户的聊天机器人。

不论具体动机是什么，本书的目标都是帮助读者把机器学习真正应用到自己的项目中。

### 3. 本书目标与教学方法

本书假设读者对机器学习几乎一无所知，目标是提供必要的概念、工具和直觉，使读者能够开发“从数据中学习”的程序。

内容从线性回归等简单常用的方法开始，逐步进入竞赛和复杂任务中常见的深度学习技术。全书使用 Python，并重点采用两个开源、可用于生产环境的框架：

- **Scikit-Learn**：接口简单、实现高效，覆盖大量经典机器学习算法，很适合作为入门工具。
- **PyTorch**：灵活而强大的深度学习库，能高效训练和运行各种神经网络，也支持在多块 GPU 上分布计算。

书中还会使用：

- **XGBoost**：在第 6 章实现梯度提升；
- **Hugging Face**：在第 13 章和第 15 章下载数据集、预训练模型及 Transformer 模型；
- **Gymnasium**：在第 19 章构建并训练强化学习智能体。

本书偏重动手实践：通过可以运行的具体示例建立直觉，只引入理解方法所需的理论。虽然不打开电脑也能阅读，但作者强烈建议亲自实验代码。

### 4. 配套代码

本书的全部示例代码以 Jupyter Notebook 的形式开源：

- GitHub：<https://github.com/ageron/handson-mlp>
- 安装说明：<https://homl.info/install-p>

最方便的起点是 Google Colab。它不要求本地安装环境，只需要浏览器和 Google 账号。Notebook 也经过 Kaggle 和 Binder 测试；读者还可以在本地安装依赖或使用本书提供的 Docker 镜像。

代码示例可以在项目中使用。若要销售、分发书中内容，或在产品文档中大量使用非代码内容，则可能超出合理使用范围，需要向 O'Reilly 申请许可。

### 5. 先修知识

#### 必需基础

- 具备一定的 Python 编程经验；
- 熟悉 NumPy；
- 熟悉 pandas；
- 熟悉 Matplotlib。

如果尚未学习 Python，可从 <https://learnpython.org/> 或 Python 官方教程 <https://docs.python.org/3/tutorial/> 开始。作者也在 <https://homl.info/tutorials-p> 提供了科学计算库教程。

#### 为理解算法原理建议补充的数学

- **线性代数**：向量、矩阵、向量相加、矩阵转置与矩阵乘法；
- **微积分**：理解导数和梯度，有助于理解神经网络训练，但不是掌握核心概念的绝对前提；
- **基础函数**：指数与对数；
- **概率论与统计学**：只需要基础概念。

数学要求并不高。需要查漏补缺时，可使用作者教程或 Khan Academy，而不必在开始本书之前完成一整套高等数学课程。

### 6. 全书路线图

全书分为两个部分。

#### 第一部分：机器学习基础

主要使用 Scikit-Learn，内容包括：

- 机器学习的定义、要解决的问题、主要类别和基本概念；
- 一个典型机器学习项目的完整步骤；
- 通过让模型拟合数据进行学习；
- 通过最小化代价函数降低预测误差；
- 数据处理、清洗和准备；
- 特征选择与特征工程；
- 使用交叉验证选择模型和调整超参数；
- 欠拟合、过拟合及偏差与方差的权衡；
- 线性回归、多项式回归、逻辑回归、$k$ 近邻、决策树、随机森林和集成方法；
- 降维与“维度灾难”；
- 聚类、密度估计、异常检测等无监督学习技术。

#### 第二部分：神经网络与深度学习

主要使用 PyTorch，内容包括：

- 神经网络是什么，以及适合解决哪些问题；
- 使用 PyTorch 构建和训练深层神经网络；
- 面向表格数据的前馈神经网络；
- 面向计算机视觉的卷积神经网络；
- 面向序列的循环神经网络和 LSTM；
- 用于自然语言、视觉等任务的编码器-解码器、Transformer、状态空间模型和混合架构；
- 用于生成式学习的自编码器、GAN 和扩散模型；
- 通过试错学习策略的强化学习智能体；
- 大规模数据的高效加载和预处理。

#### 作者的重要提醒

不要过早跳入深度学习。首先掌握机器学习基本原理和经典算法，因为：

- 随机森林和集成方法已经能很好地解决许多问题；
- 深度学习更适合图像、语音和自然语言等复杂任务；
- 从头训练深度模型通常需要更多数据、算力和耐心；
- 使用预训练模型可以显著降低这些成本，但仍需要理解基础概念。

### 7. 从 TensorFlow 版到 PyTorch 版的变化

作者曾在 2017、2019 和 2022 年出版三版基于 TensorFlow 的版本。TensorFlow 长期是深度学习的主流框架，并且适合 Google 规模的生产部署。但 PyTorch 凭借简单、灵活和开放逐步取得领先，目前在研究论文和开源项目中占据主导地位，许多新模型会首先提供 PyTorch 实现，产业界也随之迁移。

Google 近年减少了对 TensorFlow 的投入，把更多精力放在 JAX 上。JAX 同样兼顾研究与生产，但采用程度仍明显低于 PyTorch。因此，作者决定以 PyTorch 开启一个新的系列，而不是把本书称为 TensorFlow 系列的第 4 版。

主要改动如下：

- 全部代码更新到较新的库版本；
- 第二部分从 TensorFlow/Keras 全面迁移到 PyTorch；
- 删除 TensorFlow 专属内容；
- 第 10 章改为 PyTorch 入门；
- 新增第 15 章：NLP Transformer，包括聊天机器人的构建；
- 新增第 16 章：视觉 Transformer 和多模态 Transformer；
- 新增在线第 17 章：Transformer 加速与扩展，包括 FlashAttention、混合专家模型（MoE）和低秩适配（LoRA）等；
- 新增模型压缩、相对位置编码和状态空间模型相关附录；
- 为新内容腾出空间，支持向量机章节移至线上并改为附录 C，部署内容则部分并入第 10 章。

TensorFlow/Keras 的三个旧版本简称为 `homl1`、`homl2` 和 `homl3`；新的 PyTorch 版简称为 `homlp`。如果已经读过 `homl3`，最大的变化集中在第二部分，第一部分的机器学习基础没有发生太大改变。

### 8. 其他学习资源

#### 在线课程与文档

- Andrew Ng 的 Coursera 机器学习课程：质量很高，但需要投入较多时间；
- Scikit-Learn User Guide：非常优秀的官方参考资料；
- Dataquest：提供互动式教程；
- Kaggle：适合在真实问题和社区讨论中练习。

#### 书籍推荐

| 资源 | 侧重点 |
| --- | --- |
| *Data Science from Scratch*，Joel Grus | 用纯 Python 从头实现数据科学和机器学习基础 |
| *Machine Learning: An Algorithmic Perspective*，Stephen Marsland | 使用 NumPy 从算法角度深入介绍机器学习 |
| *Machine Learning with PyTorch and Scikit-Learn*，Sebastian Raschka | Scikit-Learn 与 PyTorch 实践入门 |
| *Deep Learning with Python*，François Chollet | 重实践、轻数学，清晰介绍广泛的深度学习主题 |
| *The Hundred-Page Machine Learning Book*，Andriy Burkov | 篇幅短，覆盖广，同时保留必要数学 |
| *Learning from Data* | 理论导向，尤其深入讨论偏差与方差 |
| *Artificial Intelligence: A Modern Approach* | 从更完整的人工智能体系理解机器学习的位置 |
| *Deep Learning for Coders with fastai and PyTorch* | 使用 fastai 和 PyTorch 的实践型深度学习入门 |
| *Machine Learning Yearning*，Andrew Ng | 数据质量、模型开发、部署和长期维护的工程思考 |
| *Natural Language Processing with Transformers* | 使用 Hugging Face 构建 Transformer 应用 |
| *Hands-On Large Language Models* | 通过图解理解、训练、微调和使用大语言模型 |

### 9. 排版约定

- *斜体*：新术语、URL、电子邮件、文件名和扩展名；
- `等宽字体`：代码、变量名、函数名、数据库、数据类型、环境变量、语句和关键字；
- **`等宽粗体`**：需要读者原样输入的命令或文本；
- *`等宽斜体`*：需要替换为读者输入或上下文值的占位内容；
- Tip 表示技巧或建议；
- Note 表示一般补充说明；
- Warning 表示警告或注意事项。

### 10. O'Reilly 平台与联系方式

O'Reilly 在线学习平台提供直播课程、学习路径、交互式编程环境，以及来自 O'Reilly 和其他两百多家出版社的图书与视频。

本书网页会发布勘误、示例和补充信息：

- 本书主页：<https://oreil.ly/hands-on-machine-learning>
- O'Reilly：<https://oreilly.com/>
- 联系页面：<https://oreilly.com/about/contact.html>
- 支持邮箱：<support@oreilly.com>

### 11. 致谢

作者感谢 TensorFlow 旧版以来的广大读者。读者的问题、勘误、鼓励以及“本书帮助自己找到工作或解决实际问题”的反馈，是作者继续写作的重要动力。代码问题可以在 GitHub 上提交 issue，文字问题可以提交勘误。

作者也感谢参与目录设计、范围讨论以及各章技术审阅的众多审稿人，尤其感谢审阅全部章节的 Haesun Park；感谢 O'Reilly 的编辑、项目负责人、制作、文字校对、插图和封面团队；最后感谢妻子 Emmanuelle 和三个孩子 Alexandre、Rémi、Gabrielle。向家人解释困难概念的过程，反过来帮助作者澄清思路并改进了本书。

---

## 提取出的学习路线

### 阶段 0：补齐最低先修基础

**目标**：能独立阅读和修改 Notebook，而不是把所有 Python 和数学都学完。

- Python：函数、类、列表与字典、推导式、迭代器、异常、包管理；
- NumPy：数组形状、索引、广播、向量化、矩阵运算；
- pandas：读取数据、缺失值、筛选、分组、连接；
- Matplotlib：折线图、散点图、直方图、坐标轴与图例；
- 数学：向量和矩阵、导数与梯度、均值与方差、条件概率、指数和对数。

**完成标准**：能够读取一个 CSV 文件，完成简单清洗和可视化，并解释矩阵乘法和梯度的直观含义。

### 阶段 1：建立端到端机器学习工作流

**目标**：先理解“如何把一个问题做完整”，再扩充算法数量。

1. 明确任务、目标指标和约束；
2. 获取并探索数据；
3. 划分训练集、验证集和测试集；
4. 清洗数据并建立预处理流水线；
5. 训练一个简单基线模型；
6. 使用交叉验证比较模型；
7. 调整超参数并分析误差；
8. 在测试集上进行一次最终评估；
9. 保存模型并设计推理流程。

**建议实践**：完整复现书中的端到端项目，然后换一个相似数据集独立重做。

### 阶段 2：掌握经典监督学习

按以下顺序学习：

1. 线性回归与多项式回归；
2. 逻辑回归与分类指标；
3. $k$ 近邻；
4. 决策树；
5. 随机森林；
6. 集成学习与梯度提升；
7. XGBoost。

学习每个模型时都回答五个问题：

- 它解决回归、分类还是两者都能解决？
- 模型做出了什么假设？
- 哪些超参数最重要？
- 怎样判断欠拟合或过拟合？
- 它与当前基线相比是否真的更好？

### 阶段 3：无监督学习与表示处理

依次学习：

- 降维及维度灾难；
- 聚类；
- 密度估计；
- 异常检测。

**完成标准**：能解释什么时候没有标签也能提取结构，以及降维对可视化、速度和模型效果的影响。

### 阶段 4：进入 PyTorch 与深度学习

先学习 PyTorch 基础，再进入网络架构：

1. Tensor、设备和自动微分；
2. `Dataset`、`DataLoader` 与数据批处理；
3. `nn.Module`、损失函数与优化器；
4. 标准训练循环和验证循环；
5. 保存、加载和推理；
6. 多层感知机与深层网络训练技巧；
7. 卷积神经网络；
8. 循环神经网络和 LSTM。

**完成标准**：不依赖复制整段代码，能够写出一个包含训练、验证、保存和加载的最小 PyTorch 项目。

### 阶段 5：按兴趣选择进阶方向

#### NLP 与大模型方向

编码器-解码器 → 注意力机制 → Transformer → Hugging Face → 预训练模型 → 微调 → LoRA → 推理与加速。

#### 计算机视觉方向

卷积网络 → 迁移学习 → Vision Transformer → 多模态 Transformer。

#### 生成式模型方向

自编码器 → GAN → 扩散模型。

#### 强化学习方向

马尔可夫决策过程基础 → Gymnasium 环境 → 价值学习/策略学习 → 训练智能体。

#### 模型系统方向

高效数据加载 → GPU 与混合精度 → 模型压缩 → FlashAttention → MoE → 分布式与规模化训练。

---

## 推荐的每章学习循环

每一章采用同一个闭环：

1. **预览**：先看章节目标、图表和小结，写下三个问题；
2. **阅读**：理解模型解决的问题、输入输出和关键假设；
3. **运行**：从头运行配套 Notebook，确认结果可以复现；
4. **修改**：改变数据、超参数或网络结构，预测结果后再执行；
5. **解释**：不用看书，用自己的话说明算法和实验现象；
6. **迁移**：在另一个小数据集上重新实现；
7. **复盘**：记录错误、结论和仍未解决的问题。

### 每章笔记模板

```markdown
# 章节名称

## 本章解决什么问题

## 核心概念

## 算法或模型直觉

## 关键 API

## 实验结果

## 欠拟合与过拟合信号

## 常见错误

## 我修改了什么

## 能否迁移到新数据集

## 尚未理解的问题
```

## 阅读策略建议

- **第一次阅读**：按顺序完成第一部分，优先建立完整工作流和模型评估能力。
- **第二次阅读**：进入 PyTorch 和深度学习基础，同时继续用传统模型建立基线。
- **第三次阅读**：根据项目方向选择 Transformer、视觉、生成模型或强化学习，不必平均用力。
- **数学学习**：遇到具体概念再补，不要因为试图预先学完所有数学而推迟实践。
- **工具选择**：表格类中小规模数据优先尝试经典方法；图像、语音、自然语言或高维复杂模式再重点考虑深度学习。
- **衡量进度**：以能否独立完成实验、解释错误并迁移到新数据为准，而不是以读完页数为准。

## 最终检查清单

- [ ] 能说明监督学习、无监督学习和强化学习的区别
- [ ] 能独立完成数据清洗、特征处理和数据集划分
- [ ] 能正确使用交叉验证，避免数据泄漏
- [ ] 能解释欠拟合、过拟合以及偏差与方差
- [ ] 能为任务建立简单可靠的基线模型
- [ ] 能比较线性模型、树模型和集成模型
- [ ] 能使用 Scikit-Learn Pipeline 组织预处理与训练
- [ ] 能编写基本的 PyTorch 训练和验证循环
- [ ] 能判断是否应该使用预训练模型
- [ ] 能在新数据集上独立复现完整流程

## 关键链接

- 配套代码：<https://github.com/ageron/handson-mlp>
- 本地或 Docker 安装：<https://homl.info/install-p>
- Python 教程：<https://docs.python.org/3/tutorial/>
- 作者的 NumPy、pandas、Matplotlib 和数学教程：<https://homl.info/tutorials-p>
- Scikit-Learn：<https://scikit-learn.org/>
- PyTorch：<https://pytorch.org/>
- Hugging Face：<https://huggingface.co/>
- Gymnasium：<https://gymnasium.farama.org/>
- Kaggle：<https://kaggle.com/>