# Lecture 17 Overview

## 学习目标

- 理解本讲把多模态问题拆成哪两问：非文本模态如何输入 Transformer，非文本模态如何生成出来。
- 掌握从 CLIP、SigLIP 到 LLaVA/Qwen/Chameleon 的主线：先学视觉语义表示，再接入 LLM，最后讨论更统一的离散 token 路线。[代码: lecture_17.py p.2] [代码: lecture_17.py p.10]
- 能区分“语义理解需要什么表示”与“高保真生成需要什么表示”这两类需求。

## 需要的先修知识

- Transformer、tokenization、embedding、cross-entropy、RoPE。
- ViT/patch 表示、基本对比学习概念、简单的自回归语言模型训练流程。
- 对上下文长度、batch size、数据 mixture 的基本训练直觉。

## 老师的教学主线

1. 先定义多模态目标：从 `text => text` 走向 omni model。[代码: lecture_17.py p.2]
2. 再解决输入侧：CLIP/SigLIP 如何把图像编码成带语义的向量。[代码: lecture_17.py p.3] [代码: lecture_17.py p.4]
3. 然后搭标准 VLM：视觉编码器、projector、语言模型三段式，以 LLaVA 和 Qwen 为代表。[代码: lecture_17.py p.5] [代码: lecture_17.py p.6] [代码: lecture_17.py p.7] [代码: lecture_17.py p.8] [代码: lecture_17.py p.9]
4. 最后讨论更接近统一生成的路线：Chameleon 把图像也离散化成 token，再总结为什么当前最佳实践仍更偏连续编码器 + Transformer + diffusion。[代码: lecture_17.py p.10]

## 核心概念与依赖关系

- `omni model` 是全讲目标概念；其前提是先解决多模态 token 化问题。
- CLIP 提供图像到语义向量的基础；SigLIP 改进其损失和并行效率。[代码: lecture_17.py p.3] [代码: lecture_17.py p.4]
- LLaVA/Qwen 把视觉向量通过 projector 接到 LLM，因此能做图像理解，但大多仍是文本输出。[代码: lecture_17.py p.5] [代码: lecture_17.py p.7]
- 动态分辨率、MRoPE、DeepStack 等是把这条 VLM recipe 做长、做细、做稳的工程增强。[代码: lecture_17.py p.6] [代码: lecture_17.py p.8] [代码: lecture_17.py p.9]
- Chameleon 通过 VQ-VAE 把图像转成离散 token，换来统一输入输出接口，但损失了部分细节保真。[代码: lecture_17.py p.10]

## 关键推导、例子与结论边界

- 关键目标函数变化：CLIP 的 batch 内双向对比目标，SigLIP 的逐对二分类目标。[代码: lecture_17.py p.3] [代码: lecture_17.py p.4]
- 关键结构变化：LLaVA 的线性投影、Qwen 的 cross-attention adapter、Qwen3 的 DeepStack 跨层融合。[代码: lecture_17.py p.5] [代码: lecture_17.py p.7] [代码: lecture_17.py p.9]
- 关键例子：OCR 说明需要高分辨率；多图/视频说明需要控制视觉 token 长度；Chameleon 的图文交错说明统一 token 接口的吸引力。
- 结论边界：本讲主要覆盖“理解侧如何接入图像”，对图像/视频生成只给出路线对比和老师推测，没有系统讲 diffusion 细节。[需回听]

## 易错点与待核对项

- 不要把“把图像变成 token”误解成“随便离散化就行”；老师反复强调 token 必须保住语义，而 OCR/生成还要求保住细节。
- 不要把当前 VLM 当成真正 omni model；大多数例子仍是多模态输入、文本输出。
- 不要把 Qwen2/Qwen3 的进步理解成换了全新范式；老师强调更多是规模、数据、上下文和局部结构细化。
- `连续编码器 + Transformer + diffusion` 是老师的经验性判断，不是本讲公开验证的闭源系统细节。[需回听]

## 掌握标准

- 能用自己的话解释为什么 CLIP 能学到图像语义，以及为什么它不适合 OCR 这类细节任务。
- 能画出或口述标准 VLM 模板，并说明 projector 在其中的作用。
- 能说清动态分辨率、MRoPE、显式时间戳、DeepStack 分别在解决什么问题。
- 能比较 Chameleon 与 LLaVA/Qwen 路线的优缺点。

## 复习顺序

1. 先复习多模态总目标与 token 化问题。[代码: lecture_17.py p.2]
2. 再复习 CLIP 和 SigLIP 的目标函数与数据效率差异。[代码: lecture_17.py p.3] [代码: lecture_17.py p.4]
3. 接着复习 LLaVA/Qwen 这条标准 VLM recipe 及其工程增强。[代码: lecture_17.py p.5] [代码: lecture_17.py p.6] [代码: lecture_17.py p.7] [代码: lecture_17.py p.8] [代码: lecture_17.py p.9]
4. 最后复习 Chameleon 和老师的课程总结，理解为什么“统一”不一定等于“当前最优”。[代码: lecture_17.py p.10]