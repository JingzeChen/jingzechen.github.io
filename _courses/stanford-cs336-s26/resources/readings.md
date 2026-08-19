---
uid: stanford-cs336-s26-resource-readings-3
type: course
document_type: resource
resource_kind: readings
resource_order: 3
course: stanford-cs336-s26
title: Stanford CS336 Spring 2026 阅读与引用路线
description: 按 Lecture 对齐官方论文、补充阅读、复用关系与证据边界。
excerpt: 按 Lecture 对齐官方论文、补充阅读、复用关系与证据边界。
content_lang: zh-CN
permalink: "/courses/stanford-cs336-s26/readings/"
toc: true
math: true
---

> 站点保留 428 项完整资源索引；讲义、作业 handout 与 transcript 提供站内归档，大体积论文和仓库快照通过官方来源访问。

## 证据与使用边界

- 本索引直接由 `source-manifest.json` 与 `resources-lock.json` 生成。
- `paper` 表示 executable lecture import、Python 内联链接或 PDF hyperlink annotation 引用的论文/技术报告；它不自动等于课程布置的必读材料。
- 共 `182` 个唯一 paper 资源：`173` 份本地 PDF，`9` 个 external-only 官方页面。另有 `99` 个 `reading` 资源，包含文章、文档、项目页、博客和其他背景链接。
- 课堂连接只按 manifest 的讲次用途记录；不要仅凭标题推断论文结论。先读讲次 `NOTES.md`，再决定是否精读原文。
- 替代下载只采用同一作者、出版社、官方模型仓库或 arXiv 可验证来源，并保留 `original_url`。

## 建议阅读层级

1. **第一层：讲次主线。** 先读 lecture `NOTES.md`，明确当前问题、公式和工程决策。
2. **第二层：重复引用。** 被多个讲次引用的论文通常横跨架构、系统、数据或 post-training，可优先建立跨讲联系。
3. **第三层：单讲深入。** 根据作业、实验或复核项，再精读单讲引用。
4. **Other readings。** 用于工具、数据集、实现和背景上下文，不与 paper 混算。

## 按讲次浏览

### Lecture 01: Overview, tokenization

- Paper references：`90`；other readings：`11`。
- Paper 快速入口：[\[Marin 32B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-32b-retro/)、[\[Marin 8B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-8b-retro/)、[\[MiniMax M2.5\]](https://www.minimax.io/news/minimax-m25)、[\[Xiaomi MIMO v2\]](https://mimo.xiaomi.com/mimo-v2-pro)、[A Neural Probabilistic Language Model](https://www.jmlr.org/papers/volume3/bengio03a/bengio03a.pdf)、[adam 2014](https://arxiv.org/pdf/1412.6980.pdf)、[adamw 2017](https://arxiv.org/pdf/1711.05101.pdf)、[auxfree 2024](https://arxiv.org/pdf/2408.15664.pdf)；其余见完整附录。
- Reading 快速入口：[Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/List_of_Unicode_characters)、[Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/UTF-8)、[Lecture 01 reading: pbs.twimg.com](https://pbs.twimg.com/media/HDuErvvbsAAQ5Yt?format=jpg&name=4096x4096)、[Lecture 01 reading: stanford-cs336.github.io](https://stanford-cs336.github.io/spring2026/)、[Lecture 01 reading: tiktokenizer.vercel.app](https://tiktokenizer.vercel.app/?encoder=gpt2)、[Lecture 01 reading: www.pennelynn.com](https://www.pennelynn.com/Documents/CUJ/HTML/94HTML/19940045.HTM)；其余见完整附录。

### Lecture 02: PyTorch (einops), resource accounting (FLOPs, memory, arithmetic intensity)

- Paper references：`5`；other readings：`13`。
- Paper 快速入口：[deepseek v3 2 2025](https://arxiv.org/pdf/2512.02556.pdf)、[adagrad 2011](https://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)、[Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/1710.03740.pdf)、[Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/2209.05433.pdf)、[Nemotron 3 Super: Open, Efficient Mixture-of-Experts Hybrid Mamba-Transformer Model for Agentic Reasoning](https://research.nvidia.com/labs/nemotron/files/NVIDIA-Nemotron-3-Super-Technical-Report.pdf)。
- Reading 快速入口：[Lecture 02 reading: einops.rocks](https://einops.rocks/1-einops-basics/)、[Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Bfloat16_floating-point_format)、[Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)、[Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Single-precision_floating-point_format)、[Lecture 02 reading: erees.dev](https://erees.dev/transformer-memory/)、[Lecture 02 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/roofline/)；其余见完整附录。

### Lecture 03: Architectures, hyperparameters

- Paper references：`0`；other readings：`0`。

### Lecture 04: Attention alternatives and mixture of experts

- Paper references：`0`；other readings：`0`。

### Lecture 05: GPUs, TPUs

- Paper references：`1`；other readings：`4`。
- Paper 快速入口：[Lecture 05 reference p.26: nvlabs.github.io](https://nvlabs.github.io/eccv2020-mixed-precision-tutorial/files/dusan_stosic-training-neural-networks-with-tensor-cores.pdf)。
- Reading 快速入口：[Lecture 05 reference p.32: towardsdatascience.com](https://towardsdatascience.com/how-pytorch-2-0-accelerates-deep-learning-with-operator-fusion-and-cpu-gpu-code-generation-35132a85bd26)、[Lecture 05 reference p.3: nichijou.co](https://nichijou.co/)、[Lecture 05 reference p.43: docs.nvidia.com](https://docs.nvidia.com/deeplearning/performance/dl-performance-matrix-multiplication/index.html#tile-quant)、[Lecture 05 reference p.44: www.thonking.ai](https://www.thonking.ai/p/what-shapes-do-matrix-multiplications)。

### Lecture 06: Kernels, Triton

- Paper references：`0`；other readings：`1`。
- Reading 快速入口：[Lecture 06 reading: triton-lang.org](https://triton-lang.org/main/getting-started/tutorials/02-fused-softmax.html)。

### Lecture 07: Parallelism

- Paper references：`0`；other readings：`5`。
- Reading 快速入口：[Lecture 07 reading: crfm.stanford.edu](https://crfm.stanford.edu/2023/06/16/levanter-1_0-release.html)、[Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Collective_operation)、[Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/PCI_Express)、[Lecture 07 reading: pytorch.org](https://pytorch.org/docs/stable/distributed.html)、[Lecture 07 reading: www.nvidia.com](https://www.nvidia.com/en-us/on-demand/session/gtcspring21-s31880/)。

### Lecture 08: Parallelism

- Paper references：`0`；other readings：`0`。

### Lecture 09: Scaling laws

- Paper references：`1`；other readings：`0`。
- Paper 快速入口：[Lecture 09 reference p.6: www.cs.cmu.edu](https://www.cs.cmu.edu/~epxing/Class/10701/slides/lecture16-VC.pdf)。

### Lecture 10: Inference

- Paper references：`18`；other readings：`9`。
- Paper 快速入口：[deepseek v2 2024](https://arxiv.org/pdf/2405.04434.pdf)、[gqa 2023](https://arxiv.org/pdf/2305.13245.pdf)、[mistral 7b 2023](https://arxiv.org/pdf/2310.06825.pdf)、[sparse transformer 2019](https://arxiv.org/pdf/1904.10509.pdf)、[DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence](https://arxiv.org/pdf/2606.19348.pdf)、[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2210.17323.pdf)、[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2211.17192.pdf)、[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2302.01318.pdf)；其余见完整附录。
- Reading 快速入口：[Lecture 10 reading: apxml.com](https://apxml.com/posts/llm-quantization-techniques-explained)、[Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/inference/)、[Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/transformers/)、[Lecture 10 reading: nvidia.github.io](https://nvidia.github.io/TensorRT-LLM/overview.html)、[Lecture 10 reading: research.google](https://research.google/blog/looking-back-at-speculative-decoding/)、[Lecture 10 reading: sgl-project.github.io](https://sgl-project.github.io/)；其余见完整附录。

### Lecture 11: Scaling laws

- Paper references：`0`；other readings：`0`。

### Lecture 12: Evaluation

- Paper references：`25`；other readings：`27`。
- Paper 快速入口：[Lecture 12 paper: arcprize.org](https://arcprize.org/media/ARC_AGI_3_Technical_Report.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1602.02410.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1606.06031.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2310.06770.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2311.12022.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2402.04249.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2403.04132.pdf)、[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2406.01574.pdf)；其余见完整附录。
- Reading 快速入口：[Lecture 12 reading: arcprize.org](https://arcprize.org/arc-agi)、[Lecture 12 reading: arena.ai](https://arena.ai/leaderboard)、[Lecture 12 reading: artificialanalysis.ai](https://artificialanalysis.ai/)、[Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/air-bench/latest/#/leaderboard)、[Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/gpqa)、[Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/mmlu_pro)；其余见完整附录。

### Lecture 13: Data (sources, datasets)

- Paper references：`26`；other readings：`23`。
- Paper 快速入口：[bert 2018](https://arxiv.org/pdf/1810.04805.pdf)、[gpt 3 2020](https://arxiv.org/pdf/2005.14165.pdf)、[Language Models are Unsupervised Multitask Learners](https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)、[llama 2023](https://arxiv.org/pdf/2302.13971.pdf)、[llama 3 2024](https://arxiv.org/pdf/2407.21783.pdf)、[olmo 2 2025](https://arxiv.org/pdf/2501.00656.pdf)、[the pile 2020](https://arxiv.org/pdf/2101.00027.pdf)、[Alpaca](https://crfm.stanford.edu/2023/03/13/alpaca.html)；其余见完整附录。
- Reading 快速入口：[Lecture 01 reading: www.reuters.com](https://www.reuters.com/technology/reddit-ai-content-licensing-deal-with-google-sources-say-2024-02-22/)、[Lecture 13 reading: archive.org](https://archive.org/details/stackexchange)、[Lecture 13 reading: blog.commoncrawl.org](https://blog.commoncrawl.org/blog/common-crawl-move-to-nutch)、[Lecture 13 reading: commoncrawl.org](https://commoncrawl.org/blog/march-2018-crawl-archive-now-available)、[Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/BookCorpus)、[Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Copyright_Act_of_1976)；其余见完整附录。

### Lecture 14: Data (filtering, deduplication, mixing, synthetic data)

- Paper references：`19`；other readings：`6`。
- Paper 快速入口：[gpt 3 2020](https://arxiv.org/pdf/2005.14165.pdf)、[llama 2023](https://arxiv.org/pdf/2302.13971.pdf)、[olmix 2026](https://arxiv.org/pdf/2602.12237.pdf)、[regmix 2025](https://arxiv.org/pdf/2407.01492.pdf)、[the pile 2020](https://arxiv.org/pdf/2101.00027.pdf)、[dclm 2024](https://arxiv.org/pdf/2406.11794.pdf)、[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1910.10683v4.pdf)、[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2402.00159.pdf)；其余见完整附录。
- Reading 快速入口：[Lecture 14 reading: fasttext.cc](https://fasttext.cc/docs/en/language-identification.html)、[Lecture 14 reading: opensource.org](https://opensource.org/license/mit)、[Lecture 14 reading: softwareengineering.stackexchange.com](https://softwareengineering.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed)、[Lecture 14 reading: spark.apache.org](https://spark.apache.org/docs/latest/ml-features#tokenizer)、[Lecture 14 reading: www.amazon.co.uk](https://www.amazon.co.uk/suryagede-100-Graffiti-Gas-Mask/dp/B07CRHT3RG)、[Lecture 14 reading: www.gutenberg.org](https://www.gutenberg.org/MIRRORS.ALL)。

### Lecture 15: Mid/post-training (SFT/RLHF)

- Paper references：`0`；other readings：`0`。

### Lecture 16: Post-training - RLVR

- Paper references：`0`；other readings：`0`。

### Lecture 17: Alignment - multimodality

- Paper references：`17`；other readings：`1`。
- Paper 快速入口：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2103.00020.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2212.07143.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2303.15343.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2304.08485.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2308.12966.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2309.17425.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2406.04334.pdf)、[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2409.12191.pdf)；其余见完整附录。
- Reading 快速入口：[Lecture 17 reading: www.lmsys.org](https://www.lmsys.org/blog/2023-03-30-vicuna/)。

### Lecture 18: Guest lecture: Daniel Selsam

- 当前无官方录像或讲次材料，不能从本仓库归属 paper/reading。

### Lecture 19: Guest lecture: Dan Fu

- Paper references：`0`；other readings：`0`。

## 完整 Paper 附录（182 个唯一资源）

每项只出现一次；“用于讲次”来自 manifest 的实际引用关系。

### Paper 001: [Marin 32B retro]

- 资源：[\[Marin 32B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-32b-retro/)（外部链接）。
- 用于讲次：`L01`。
- 元数据：日期：2025；机构：Marin。

### Paper 002: [Marin 8B retro]

- 资源：[\[Marin 8B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-8b-retro/)（外部链接）。
- 用于讲次：`L01`。
- 元数据：日期：2025；机构：Marin。

### Paper 003: [MiniMax M2.5]

- 资源：[\[MiniMax M2.5\]](https://www.minimax.io/news/minimax-m25)（外部链接）。
- 用于讲次：`L01`。
- 元数据：日期：2026；机构：Minimax。

### Paper 004: [Xiaomi MIMO v2]

- 资源：[\[Xiaomi MIMO v2\]](https://mimo.xiaomi.com/mimo-v2-pro)（外部链接）。
- 用于讲次：`L01`。
- 元数据：日期：2026；机构：Xiaomi。

### Paper 005: A Neural Probabilistic Language Model

- 资源：[A Neural Probabilistic Language Model](https://www.jmlr.org/papers/volume3/bengio03a/bengio03a.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：作者：Yoshua Bengio / Réjean Ducharme / Pascal Vincent / Christian Jauvin；日期：2003-02-01。

### Paper 006: adam 2014

- 资源：[adam 2014](https://arxiv.org/pdf/1412.6980.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 007: adamw 2017

- 资源：[adamw 2017](https://arxiv.org/pdf/1711.05101.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 008: auxfree 2024

- 资源：[auxfree 2024](https://arxiv.org/pdf/2408.15664.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2408.15664](https://arxiv.org/abs/2408.15664)；当前下载使用已验证替代端点。

### Paper 009: bahdanau 2015 attention

- 资源：[bahdanau 2015 attention](https://arxiv.org/pdf/1409.0473.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 010: bert 2018

- 资源：[bert 2018](https://arxiv.org/pdf/1810.04805.pdf)（本地归档）。
- 用于讲次：`L01, L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1810.04805](https://arxiv.org/abs/1810.04805)；当前下载使用已验证替代端点。

### Paper 011: bloom 2022

- 资源：[bloom 2022](https://arxiv.org/pdf/2211.05100.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：BigScience。
- 原始来源：[https://arxiv.org/abs/2211.05100](https://arxiv.org/abs/2211.05100)；当前下载使用已验证替代端点。

### Paper 012: blt 2024

- 资源：[blt 2024](https://arxiv.org/pdf/2412.09871.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2412.09871](https://arxiv.org/abs/2412.09871)；当前下载使用已验证替代端点。

### Paper 013: byt5 2021

- 资源：[byt5 2021](https://arxiv.org/pdf/2105.13626.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2105.13626](https://arxiv.org/abs/2105.13626)；当前下载使用已验证替代端点。

### Paper 014: chinchilla 2022

- 资源：[chinchilla 2022](https://arxiv.org/pdf/2203.15556.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：DeepMind。

### Paper 015: cosine learning rate 2017

- 资源：[cosine learning rate 2017](https://arxiv.org/pdf/1608.03983.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 016: deepseek 67b 2024

- 资源：[deepseek 67b 2024](https://arxiv.org/pdf/2401.02954.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：DeepSeek。

### Paper 017: deepseek r1 2025

- 资源：[deepseek r1 2025](https://arxiv.org/pdf/2501.12948.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 018: deepseek v2 2024

- 资源：[deepseek v2 2024](https://arxiv.org/pdf/2405.04434.pdf)（本地归档）。
- 用于讲次：`L01, L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2405.04434](https://arxiv.org/abs/2405.04434)；当前下载使用已验证替代端点。

### Paper 019: deepseek v3 2 2025

- 资源：[deepseek v3 2 2025](https://arxiv.org/pdf/2512.02556.pdf)（本地归档）。
- 用于讲次：`L01, L02`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2512.02556](https://arxiv.org/abs/2512.02556)；当前下载使用已验证替代端点。

### Paper 020: deepseek v3 2024

- 资源：[deepseek v3 2024](https://arxiv.org/pdf/2412.19437.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 021: dpo 2023

- 资源：[dpo 2023](https://arxiv.org/pdf/2305.18290.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 022: elmo 2018

- 资源：[elmo 2018](https://arxiv.org/pdf/1802.05365.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1802.05365](https://arxiv.org/abs/1802.05365)；当前下载使用已验证替代端点。

### Paper 023: gdn 2024

- 资源：[gdn 2024](https://arxiv.org/pdf/2412.06464.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2412.06464](https://arxiv.org/abs/2412.06464)；当前下载使用已验证替代端点。

### Paper 024: glm 4 5 2025

- 资源：[glm 4 5 2025](https://arxiv.org/pdf/2508.06471.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Z.ai。
- 原始来源：[https://arxiv.org/abs/2508.06471](https://arxiv.org/abs/2508.06471)；当前下载使用已验证替代端点。

### Paper 025: glm 5 2026

- 资源：[glm 5 2026](https://arxiv.org/pdf/2602.15763.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Z.ai。
- 原始来源：[https://arxiv.org/abs/2602.15763](https://arxiv.org/abs/2602.15763)；当前下载使用已验证替代端点。

### Paper 026: gpipe 2018

- 资源：[gpipe 2018](https://arxiv.org/pdf/1811.06965.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 027: gpt 3 2020

- 资源：[gpt 3 2020](https://arxiv.org/pdf/2005.14165.pdf)（本地归档）。
- 用于讲次：`L01, L13, L14`。
- 元数据：机构：OpenAI。

### Paper 028: gpt 4 2023

- 资源：[gpt 4 2023](https://arxiv.org/pdf/2303.08774.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：OpenAI。

### Paper 029: GPT-J

- 资源：[GPT-J](https://arankomatsuzaki.wordpress.com/2021/06/04/gpt-j/)（外部链接）。
- 用于讲次：`L01`。
- 元数据：作者：Ben Wang / Aran Komatsuzaki；日期：2021-06-04；机构：EleutherAI。

### Paper 030: gqa 2023

- 资源：[gqa 2023](https://arxiv.org/pdf/2305.13245.pdf)（本地归档）。
- 用于讲次：`L01, L10`。
- 元数据：机构：Google。

### Paper 031: grpo

- 资源：[grpo](https://arxiv.org/pdf/2402.03300.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 032: hnet 2025

- 资源：[hnet 2025](https://arxiv.org/pdf/2507.07955.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2507.07955](https://arxiv.org/abs/2507.07955)；当前下载使用已验证替代端点。

### Paper 033: instruct gpt 2022

- 资源：[instruct gpt 2022](https://arxiv.org/pdf/2203.02155.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：OpenAI。

### Paper 034: kaplan scaling laws 2020

- 资源：[kaplan scaling laws 2020](https://arxiv.org/pdf/2001.08361.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：OpenAI。

### Paper 035: kimi 1 5 2025

- 资源：[kimi 1 5 2025](https://arxiv.org/pdf/2501.12599.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 036: kimi k2 5 2026

- 资源：[kimi k2 5 2026](https://arxiv.org/pdf/2602.02276.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Moonshot。
- 原始来源：[https://arxiv.org/abs/2602.02276](https://arxiv.org/abs/2602.02276)；当前下载使用已验证替代端点。

### Paper 037: Language Models are Unsupervised Multitask Learners

- 资源：[Language Models are Unsupervised Multitask Learners](https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)（本地归档）。
- 用于讲次：`L01, L13`。
- 元数据：作者：Alec Radford / Jeffrey Wu / Rewon Child / David Luan / Dario Amodei / Ilya Sutskever；日期：2019-02-14；机构：OpenAI。

### Paper 038: Language Models in Machine Translation

- 资源：[Language Models in Machine Translation](https://aclanthology.org/D07-1090.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：作者：Thorsten Brants / Ashok C. Popat / Peng Xu / Franz J. Och / Jeffrey Dean；日期：2007；机构：Google。

### Paper 039: large batch training 2018

- 资源：[large batch training 2018](https://arxiv.org/pdf/1812.06162.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 040: layernorm 2016

- 资源：[layernorm 2016](https://arxiv.org/pdf/1607.06450.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 041: Lecture 01 paper: arxiv.org

- 资源：[Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2005.04305.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2005.04305](https://arxiv.org/abs/2005.04305)；当前下载使用已验证替代端点。

### Paper 042: Lecture 01 paper: arxiv.org

- 资源：[Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2403.07918.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2403.07918](https://arxiv.org/abs/2403.07918)；当前下载使用已验证替代端点。

### Paper 043: Lecture 01 paper: arxiv.org

- 资源：[Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2206.07682.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2206.07682](https://arxiv.org/pdf/2206.07682)；当前下载使用已验证替代端点。

### Paper 044: Lecture 01 paper: arxiv.org

- 资源：[Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2303.15715.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 045: linear attention 2020

- 资源：[linear attention 2020](https://arxiv.org/pdf/2006.16236.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2006.16236](https://arxiv.org/abs/2006.16236)；当前下载使用已验证替代端点。

### Paper 046: llama 2 2023

- 资源：[llama 2 2023](https://arxiv.org/pdf/2307.09288.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Meta。

### Paper 047: llama 2023

- 资源：[llama 2023](https://arxiv.org/pdf/2302.13971.pdf)（本地归档）。
- 用于讲次：`L01, L13, L14`。
- 元数据：机构：Meta。

### Paper 048: llama 3 2024

- 资源：[llama 3 2024](https://arxiv.org/pdf/2407.21783.pdf)（本地归档）。
- 用于讲次：`L01, L13`。
- 元数据：机构：Meta。
- 原始来源：[https://arxiv.org/abs/2407.21783](https://arxiv.org/abs/2407.21783)；当前下载使用已验证替代端点。

### Paper 049: Long Short-Term Memory

- 资源：[Long Short-Term Memory](https://www.bioinf.jku.at/publications/older/2604.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：作者：Sepp Hochreiter / Jürgen Schmidhuber；日期：1997。
- 原始来源：[https://www.bioinf.jku.at/publications/older/2604.pdf](https://www.bioinf.jku.at/publications/older/2604.pdf)；当前下载使用已验证替代端点。

### Paper 050: mamba 2 2024

- 资源：[mamba 2 2024](https://arxiv.org/pdf/2405.21060.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2405.21060](https://arxiv.org/abs/2405.21060)；当前下载使用已验证替代端点。

### Paper 051: mamba 3 2026

- 资源：[mamba 3 2026](https://arxiv.org/pdf/2603.15569.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2603.15569](https://arxiv.org/abs/2603.15569)；当前下载使用已验证替代端点。

### Paper 052: megabyte 2023

- 资源：[megabyte 2023](https://arxiv.org/pdf/2305.07185.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 053: megatron lm 2019

- 资源：[megatron lm 2019](https://arxiv.org/pdf/1909.08053.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：NVIDIA。

### Paper 054: mistral 7b 2023

- 资源：[mistral 7b 2023](https://arxiv.org/pdf/2310.06825.pdf)（本地归档）。
- 用于讲次：`L01, L10`。
- 元数据：机构：Mistral。

### Paper 055: mixtral 2024

- 资源：[mixtral 2024](https://arxiv.org/pdf/2401.04088.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Mistral。

### Paper 056: moe 2017

- 资源：[moe 2017](https://arxiv.org/pdf/1701.06538.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 057: mtp 2024

- 资源：[mtp 2024](https://arxiv.org/pdf/2404.19737.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2404.19737](https://arxiv.org/abs/2404.19737)；当前下载使用已验证替代端点。

### Paper 058: Muon: An optimizer for hidden layers in neural networks

- 资源：[Muon: An optimizer for hidden layers in neural networks](https://kellerjordan.github.io/posts/muon/)（外部链接）。
- 用于讲次：`L01`。
- 元数据：作者：Jordan Keller；日期：2024-12-08。

### Paper 059: mup 2022

- 资源：[mup 2022](https://arxiv.org/pdf/2203.03466.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2203.03466](https://arxiv.org/abs/2203.03466)；当前下载使用已验证替代端点。

### Paper 060: nemotron 15b 2024

- 资源：[nemotron 15b 2024](https://arxiv.org/pdf/2402.16819.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：NVIDIA。

### Paper 061: nemotron 3 2025

- 资源：[nemotron 3 2025](https://arxiv.org/pdf/2512.20856.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2512.20856](https://arxiv.org/abs/2512.20856)；当前下载使用已验证替代端点。

### Paper 062: olmix 2026

- 资源：[olmix 2026](https://arxiv.org/pdf/2602.12237.pdf)（本地归档）。
- 用于讲次：`L01, L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2602.12237](https://arxiv.org/abs/2602.12237)；当前下载使用已验证替代端点。

### Paper 063: olmo 2 2025

- 资源：[olmo 2 2025](https://arxiv.org/pdf/2501.00656.pdf)（本地归档）。
- 用于讲次：`L01, L13`。
- 元数据：机构：AI2。
- 原始来源：[https://arxiv.org/abs/2501.00656](https://arxiv.org/abs/2501.00656)；当前下载使用已验证替代端点。

### Paper 064: olmo 3 2025

- 资源：[olmo 3 2025](https://arxiv.org/pdf/2512.13961.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2512.13961](https://arxiv.org/abs/2512.13961)；当前下载使用已验证替代端点。

### Paper 065: olmo 7b 2024

- 资源：[olmo 7b 2024](https://arxiv.org/pdf/2402.00838.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：AI2。

### Paper 066: opt 175b 2022

- 资源：[opt 175b 2022](https://arxiv.org/pdf/2205.01068.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Meta。

### Paper 067: palm 2022

- 资源：[palm 2022](https://arxiv.org/pdf/2204.02311.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 068: ppo 2017

- 资源：[ppo 2017](https://arxiv.org/pdf/1707.06347.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 069: pre post norm 2020

- 资源：[pre post norm 2020](https://arxiv.org/pdf/2002.04745.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 070: Prediction and Entropy of Printed English

- 资源：[Prediction and Entropy of Printed English](https://www.princeton.edu/~wbialek/rome/refs/shannon_51.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：作者：Claude Shannon；日期：1950-09-15。

### Paper 071: qk norm 2023

- 资源：[qk norm 2023](https://arxiv.org/pdf/2302.05442.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2302.05442](https://arxiv.org/abs/2302.05442)；当前下载使用已验证替代端点。

### Paper 072: qwen 2 5 2024

- 资源：[qwen 2 5 2024](https://arxiv.org/pdf/2412.15115.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Alibaba。
- 原始来源：[https://arxiv.org/abs/2412.15115](https://arxiv.org/abs/2412.15115)；当前下载使用已验证替代端点。

### Paper 073: qwen 3 2025

- 资源：[qwen 3 2025](https://arxiv.org/pdf/2505.09388.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2505.09388](https://arxiv.org/abs/2505.09388)；当前下载使用已验证替代端点。

### Paper 074: regmix 2025

- 资源：[regmix 2025](https://arxiv.org/pdf/2407.01492.pdf)（本地归档）。
- 用于讲次：`L01, L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2407.01492](https://arxiv.org/abs/2407.01492)；当前下载使用已验证替代端点。

### Paper 075: rms norm 2019

- 资源：[rms norm 2019](https://arxiv.org/pdf/1910.07467.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1910.07467](https://arxiv.org/abs/1910.07467)；当前下载使用已验证替代端点。

### Paper 076: rope 2021

- 资源：[rope 2021](https://arxiv.org/pdf/2104.09864.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。

### Paper 077: sennrich 2016

- 资源：[sennrich 2016](https://arxiv.org/pdf/1508.07909.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1508.07909](https://arxiv.org/abs/1508.07909)；当前下载使用已验证替代端点。

### Paper 078: seq2seq 2014

- 资源：[seq2seq 2014](https://arxiv.org/pdf/1409.3215.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 079: shazeer 2020

- 资源：[shazeer 2020](https://arxiv.org/pdf/2002.05202.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 080: soap 2024

- 资源：[soap 2024](https://arxiv.org/pdf/2409.11321.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2409.11321](https://arxiv.org/abs/2409.11321)；当前下载使用已验证替代端点。

### Paper 081: sparse transformer 2019

- 资源：[sparse transformer 2019](https://arxiv.org/pdf/1904.10509.pdf)（本地归档）。
- 用于讲次：`L01, L10`。
- 元数据：机构：OpenAI。

### Paper 082: switch transformers 2021

- 资源：[switch transformers 2021](https://arxiv.org/pdf/2101.03961.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。
- 原始来源：[https://arxiv.org/abs/2101.03961](https://arxiv.org/abs/2101.03961)；当前下载使用已验证替代端点。

### Paper 083: t5 2019

- 资源：[t5 2019](https://arxiv.org/pdf/1910.10683.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 084: tfree 2024

- 资源：[tfree 2024](https://arxiv.org/pdf/2406.19223.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2406.19223](https://arxiv.org/abs/2406.19223)；当前下载使用已验证替代端点。

### Paper 085: the pile 2020

- 资源：[the pile 2020](https://arxiv.org/pdf/2101.00027.pdf)（本地归档）。
- 用于讲次：`L01, L13, L14`。
- 元数据：机构：EleutherAI。

### Paper 086: transformer 2017

- 资源：[transformer 2017](https://arxiv.org/pdf/1706.03762.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Google。

### Paper 087: Understanding the difficulty of training deep feedforward neural networks

- 资源：[Understanding the difficulty of training deep feedforward neural networks](https://proceedings.mlr.press/v9/glorot10a/glorot10a.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：作者：Xavier Glorot / Yoshua Bengio；日期：2010-03-01。

### Paper 088: wrap 2024

- 资源：[wrap 2024](https://arxiv.org/pdf/2401.16380.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2401.16380](https://arxiv.org/abs/2401.16380)；当前下载使用已验证替代端点。

### Paper 089: wsd 2024

- 资源：[wsd 2024](https://arxiv.org/pdf/2404.06395.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Tsinghua。

### Paper 090: zero 2019

- 资源：[zero 2019](https://arxiv.org/pdf/1910.02054.pdf)（本地归档）。
- 用于讲次：`L01`。
- 元数据：机构：Microsoft。
- 原始来源：[https://arxiv.org/abs/1910.02054](https://arxiv.org/abs/1910.02054)；当前下载使用已验证替代端点。

### Paper 091: adagrad 2011

- 资源：[adagrad 2011](https://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)（本地归档）。
- 用于讲次：`L02`。
- 元数据：作者：John Duchi / Elad Hazan / Yoram Singer；日期：2011。

### Paper 092: Lecture 02 paper: arxiv.org

- 资源：[Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/1710.03740.pdf)（本地归档）。
- 用于讲次：`L02`。
- 元数据：registry 未提供额外书目信息。

### Paper 093: Lecture 02 paper: arxiv.org

- 资源：[Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/2209.05433.pdf)（本地归档）。
- 用于讲次：`L02`。
- 元数据：registry 未提供额外书目信息。

### Paper 094: Nemotron 3 Super: Open, Efficient Mixture-of-Experts Hybrid Mamba-Transformer Model for Agentic Reasoning

- 资源：[Nemotron 3 Super: Open, Efficient Mixture-of-Experts Hybrid Mamba-Transformer Model for Agentic Reasoning](https://research.nvidia.com/labs/nemotron/files/NVIDIA-Nemotron-3-Super-Technical-Report.pdf)（本地归档）。
- 用于讲次：`L02`。
- 元数据：日期：2026-03-11；机构：NVIDIA。

### Paper 095: Lecture 05 reference p.26: nvlabs.github.io

- 资源：[Lecture 05 reference p.26: nvlabs.github.io](https://nvlabs.github.io/eccv2020-mixed-precision-tutorial/files/dusan_stosic-training-neural-networks-with-tensor-cores.pdf)（本地归档）。
- 用于讲次：`L05`。
- 元数据：registry 未提供额外书目信息。

### Paper 096: Lecture 09 reference p.6: www.cs.cmu.edu

- 资源：[Lecture 09 reference p.6: www.cs.cmu.edu](https://www.cs.cmu.edu/~epxing/Class/10701/slides/lecture16-VC.pdf)（本地归档）。
- 用于讲次：`L09`。
- 元数据：registry 未提供额外书目信息。

### Paper 097: DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence

- 资源：[DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence](https://arxiv.org/pdf/2606.19348.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：日期：2026-04；机构：DeepSeek。
- 原始来源：[https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro/blob/main/DeepSeek_V4.pdf](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro/blob/main/DeepSeek_V4.pdf)；当前下载使用已验证替代端点。

### Paper 098: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2210.17323.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2210.17323](https://arxiv.org/abs/2210.17323)；当前下载使用已验证替代端点。

### Paper 099: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2211.17192.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2211.17192](https://arxiv.org/abs/2211.17192)；当前下载使用已验证替代端点。

### Paper 100: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2302.01318.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2302.01318](https://arxiv.org/abs/2302.01318)；当前下载使用已验证替代端点。

### Paper 101: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2306.00978.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2306.00978](https://arxiv.org/abs/2306.00978)；当前下载使用已验证替代端点。

### Paper 102: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2401.10774.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2401.10774](https://arxiv.org/abs/2401.10774)；当前下载使用已验证替代端点。

### Paper 103: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2405.12981.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2405.12981](https://arxiv.org/abs/2405.12981)；当前下载使用已验证替代端点。

### Paper 104: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2407.14679.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2407.14679](https://arxiv.org/abs/2407.14679)；当前下载使用已验证替代端点。

### Paper 105: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2303.17951.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2303.17951](https://arxiv.org/pdf/2303.17951)；当前下载使用已验证替代端点。

### Paper 106: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2309.06180.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。

### Paper 107: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2310.18313.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2310.18313](https://arxiv.org/pdf/2310.18313)；当前下载使用已验证替代端点。

### Paper 108: Lecture 10 paper: arxiv.org

- 资源：[Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2401.15077.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2401.15077](https://arxiv.org/pdf/2401.15077)；当前下载使用已验证替代端点。

### Paper 109: Lecture 10 paper: www.usenix.org

- 资源：[Lecture 10 paper: www.usenix.org](https://www.usenix.org/system/files/osdi22-yu.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：registry 未提供额外书目信息。

### Paper 110: longformer 2020

- 资源：[longformer 2020](https://arxiv.org/pdf/2004.05150.pdf)（本地归档）。
- 用于讲次：`L10`。
- 元数据：机构：AllenAI。

### Paper 111: Lecture 12 paper: arcprize.org

- 资源：[Lecture 12 paper: arcprize.org](https://arcprize.org/media/ARC_AGI_3_Technical_Report.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。

### Paper 112: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1602.02410.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1602.02410](https://arxiv.org/abs/1602.02410)；当前下载使用已验证替代端点。

### Paper 113: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1606.06031.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1606.06031](https://arxiv.org/abs/1606.06031)；当前下载使用已验证替代端点。

### Paper 114: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2310.06770.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2310.06770](https://arxiv.org/abs/2310.06770)；当前下载使用已验证替代端点。

### Paper 115: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2311.12022.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2311.12022](https://arxiv.org/abs/2311.12022)；当前下载使用已验证替代端点。

### Paper 116: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2402.04249.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2402.04249](https://arxiv.org/abs/2402.04249)；当前下载使用已验证替代端点。

### Paper 117: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2403.04132.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2403.04132](https://arxiv.org/abs/2403.04132)；当前下载使用已验证替代端点。

### Paper 118: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2406.01574.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2406.01574](https://arxiv.org/abs/2406.01574)；当前下载使用已验证替代端点。

### Paper 119: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2407.17436.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2407.17436](https://arxiv.org/abs/2407.17436)；当前下载使用已验证替代端点。

### Paper 120: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2408.08926.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2408.08926](https://arxiv.org/abs/2408.08926)；当前下载使用已验证替代端点。

### Paper 121: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2410.07095.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2410.07095](https://arxiv.org/abs/2410.07095)；当前下载使用已验证替代端点。

### Paper 122: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2410.08385.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2410.08385](https://arxiv.org/abs/2410.08385)；当前下载使用已验证替代端点。

### Paper 123: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2412.13678.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2412.13678](https://arxiv.org/abs/2412.13678)；当前下载使用已验证替代端点。

### Paper 124: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2501.14249.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2501.14249](https://arxiv.org/abs/2501.14249)；当前下载使用已验证替代端点。

### Paper 125: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2502.03461.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2502.03461](https://arxiv.org/abs/2502.03461)；当前下载使用已验证替代端点。

### Paper 126: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2505.23802.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2505.23802](https://arxiv.org/abs/2505.23802)；当前下载使用已验证替代端点。

### Paper 127: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2507.02825.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2507.02825](https://arxiv.org/abs/2507.02825)；当前下载使用已验证替代端点。

### Paper 128: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2601.11868.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2601.11868](https://arxiv.org/abs/2601.11868)；当前下载使用已验证替代端点。

### Paper 129: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1905.07830.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/1905.07830](https://arxiv.org/pdf/1905.07830)；当前下载使用已验证替代端点。

### Paper 130: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2307.15043.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2307.15043](https://arxiv.org/pdf/2307.15043)；当前下载使用已验证替代端点。

### Paper 131: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2310.17623.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2310.17623](https://arxiv.org/pdf/2310.17623)；当前下载使用已验证替代端点。

### Paper 132: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2404.04475.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2404.04475](https://arxiv.org/pdf/2404.04475)；当前下载使用已验证替代端点。

### Paper 133: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2406.04770.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2406.04770](https://arxiv.org/pdf/2406.04770)；当前下载使用已验证替代端点。

### Paper 134: Lecture 12 paper: arxiv.org

- 资源：[Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2510.04374.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2510.04374](https://arxiv.org/pdf/2510.04374)；当前下载使用已验证替代端点。

### Paper 135: mmlu 2021

- 资源：[mmlu 2021](https://arxiv.org/pdf/2009.03300.pdf)（本地归档）。
- 用于讲次：`L12`。
- 元数据：机构：Berkeley。

### Paper 136: Alpaca

- 资源：[Alpaca](https://crfm.stanford.edu/2023/03/13/alpaca.html)（外部链接）。
- 用于讲次：`L13`。
- 元数据：作者：Rohan Taori / Ishaan Gulrajani / Tianyi Zhang / Yann Dubois / Xuechen Li / Carlos Guestrin / Percy Liang / Tatsunori B. Hashimoto；日期：2023-03-13。

### Paper 137: dclm 2024

- 资源：[dclm 2024](https://arxiv.org/pdf/2406.11794.pdf)（本地归档）。
- 用于讲次：`L13, L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2406.11794](https://arxiv.org/abs/2406.11794)；当前下载使用已验证替代端点。

### Paper 138: gopher 2021

- 资源：[gopher 2021](https://arxiv.org/pdf/2112.11446.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：机构：DeepMind。

### Paper 139: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1506.06724.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/1506.06724](https://arxiv.org/abs/1506.06724)；当前下载使用已验证替代端点。

### Paper 140: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2402.19173.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2402.19173](https://arxiv.org/abs/2402.19173)；当前下载使用已验证替代端点。

### Paper 141: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2407.14933.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2407.14933](https://arxiv.org/abs/2407.14933)；当前下载使用已验证替代端点。

### Paper 142: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1910.10683v4.pdf)（本地归档）。
- 用于讲次：`L13, L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/1910.10683v4](https://arxiv.org/pdf/1910.10683v4)；当前下载使用已验证替代端点。

### Paper 143: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1911.00359.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/1911.00359](https://arxiv.org/pdf/1911.00359)；当前下载使用已验证替代端点。

### Paper 144: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2010.12563.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2010.12563](https://arxiv.org/pdf/2010.12563)；当前下载使用已验证替代端点。

### Paper 145: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2104.08758.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2104.08758](https://arxiv.org/pdf/2104.08758)；当前下载使用已验证替代端点。

### Paper 146: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2211.15533.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2211.15533](https://arxiv.org/pdf/2211.15533)；当前下载使用已验证替代端点。

### Paper 147: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2302.10149.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2302.10149](https://arxiv.org/pdf/2302.10149)；当前下载使用已验证替代端点。

### Paper 148: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2306.01116.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2306.01116](https://arxiv.org/pdf/2306.01116)；当前下载使用已验证替代端点。

### Paper 149: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2402.00159.pdf)（本地归档）。
- 用于讲次：`L13, L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2402.00159](https://arxiv.org/pdf/2402.00159)；当前下载使用已验证替代端点。

### Paper 150: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2411.15124.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2411.15124](https://arxiv.org/pdf/2411.15124)；当前下载使用已验证替代端点。

### Paper 151: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2506.05209.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2506.05209](https://arxiv.org/pdf/2506.05209)；当前下载使用已验证替代端点。

### Paper 152: Lecture 13 paper: arxiv.org

- 资源：[Lecture 13 paper: arxiv.org](https://arxiv.org/stats/monthly_submissions)（外部链接）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。

### Paper 153: nemotron cc 2024

- 资源：[nemotron cc 2024](https://arxiv.org/pdf/2412.02595.pdf)（本地归档）。
- 用于讲次：`L13`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2412.02595](https://arxiv.org/abs/2412.02595)；当前下载使用已验证替代端点。

### Paper 154: OpenWebText

- 资源：[OpenWebText](https://skylion007.github.io/OpenWebTextCorpus/)（外部链接）。
- 用于讲次：`L13`。
- 元数据：作者：Aaron Gokaslan / Vanya Cohen；日期：2019。

### Paper 155: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2304.09151.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2304.09151](https://arxiv.org/abs/2304.09151)；当前下载使用已验证替代端点。

### Paper 156: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2402.16827.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2402.16827](https://arxiv.org/abs/2402.16827)；当前下载使用已验证替代端点。

### Paper 157: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2504.21798.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2504.21798](https://arxiv.org/abs/2504.21798)；当前下载使用已验证替代端点。

### Paper 158: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2506.04178.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2506.04178](https://arxiv.org/abs/2506.04178)；当前下载使用已验证替代端点。

### Paper 159: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2604.01496.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2604.01496](https://arxiv.org/abs/2604.01496)；当前下载使用已验证替代端点。

### Paper 160: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2107.06499.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2107.06499](https://arxiv.org/pdf/2107.06499)；当前下载使用已验证替代端点。

### Paper 161: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2306.11644.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2306.11644](https://arxiv.org/pdf/2306.11644)；当前下载使用已验证替代端点。

### Paper 162: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2310.06786.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2310.06786](https://arxiv.org/pdf/2310.06786)；当前下载使用已验证替代端点。

### Paper 163: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2501.11747.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2501.11747](https://arxiv.org/pdf/2501.11747)；当前下载使用已验证替代端点。

### Paper 164: Lecture 14 paper: arxiv.org

- 资源：[Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2505.20411.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2505.20411](https://arxiv.org/pdf/2505.20411)；当前下载使用已验证替代端点。

### Paper 165: Lecture 14 paper: infolab.stanford.edu

- 资源：[Lecture 14 paper: infolab.stanford.edu](https://infolab.stanford.edu/~ullman/mmds/ch3n.pdf)（本地归档）。
- 用于讲次：`L14`。
- 元数据：registry 未提供额外书目信息。

### Paper 166: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2103.00020.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2103.00020](https://arxiv.org/abs/2103.00020)；当前下载使用已验证替代端点。

### Paper 167: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2212.07143.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2212.07143](https://arxiv.org/abs/2212.07143)；当前下载使用已验证替代端点。

### Paper 168: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2303.15343.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2303.15343](https://arxiv.org/abs/2303.15343)；当前下载使用已验证替代端点。

### Paper 169: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2304.08485.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2304.08485](https://arxiv.org/abs/2304.08485)；当前下载使用已验证替代端点。

### Paper 170: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2308.12966.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2308.12966](https://arxiv.org/abs/2308.12966)；当前下载使用已验证替代端点。

### Paper 171: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2309.17425.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2309.17425](https://arxiv.org/abs/2309.17425)；当前下载使用已验证替代端点。

### Paper 172: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2406.04334.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2406.04334](https://arxiv.org/abs/2406.04334)；当前下载使用已验证替代端点。

### Paper 173: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2409.12191.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2409.12191](https://arxiv.org/abs/2409.12191)；当前下载使用已验证替代端点。

### Paper 174: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2511.21631.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/abs/2511.21631](https://arxiv.org/abs/2511.21631)；当前下载使用已验证替代端点。

### Paper 175: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/1711.00937.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/1711.00937](https://arxiv.org/pdf/1711.00937)；当前下载使用已验证替代端点。

### Paper 176: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2010.11929.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2010.11929](https://arxiv.org/pdf/2010.11929)；当前下载使用已验证替代端点。

### Paper 177: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2203.13131.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2203.13131](https://arxiv.org/pdf/2203.13131)；当前下载使用已验证替代端点。

### Paper 178: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2209.06794.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2209.06794](https://arxiv.org/pdf/2209.06794)；当前下载使用已验证替代端点。

### Paper 179: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2405.09818.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2405.09818](https://arxiv.org/pdf/2405.09818)；当前下载使用已验证替代端点。

### Paper 180: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2408.03326.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2408.03326](https://arxiv.org/pdf/2408.03326)；当前下载使用已验证替代端点。

### Paper 181: Lecture 17 paper: arxiv.org

- 资源：[Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2502.14786.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。
- 原始来源：[https://arxiv.org/pdf/2502.14786](https://arxiv.org/pdf/2502.14786)；当前下载使用已验证替代端点。

### Paper 182: Lecture 17 paper: static.hliu.cc

- 资源：[Lecture 17 paper: static.hliu.cc](https://static.hliu.cc/files/llava/improved_llava.pdf)（本地归档）。
- 用于讲次：`L17`。
- 元数据：registry 未提供额外书目信息。

## 完整 Other Reading 附录（99 个唯一资源）

- **Reading 001** · [Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/List_of_Unicode_characters) · `外部链接` · 用于 `L01`。
- **Reading 002** · [Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/UTF-8) · `外部链接` · 用于 `L01`。
- **Reading 003** · [Lecture 01 reading: pbs.twimg.com](https://pbs.twimg.com/media/HDuErvvbsAAQ5Yt?format=jpg&name=4096x4096) · `外部链接` · 用于 `L01`。
- **Reading 004** · [Lecture 01 reading: stanford-cs336.github.io](https://stanford-cs336.github.io/spring2026/) · `外部链接` · 用于 `L01`。
- **Reading 005** · [Lecture 01 reading: tiktokenizer.vercel.app](https://tiktokenizer.vercel.app/?encoder=gpt2) · `外部链接` · 用于 `L01`。
- **Reading 006** · [Lecture 01 reading: www.pennelynn.com](https://www.pennelynn.com/Documents/CUJ/HTML/94HTML/19940045.HTM) · `外部链接` · 用于 `L01`。
- **Reading 007** · [Lecture 01 reading: www.reuters.com](https://www.reuters.com/technology/reddit-ai-content-licensing-deal-with-google-sources-say-2024-02-22/) · `外部链接` · 用于 `L01, L13`。
- **Reading 008** · [Lecture 01 reading: www.wired.com](https://www.wired.com/story/openai-ceo-sam-altman-the-age-of-giant-ai-models-is-already-over/) · `外部链接` · 用于 `L01`。
- **Reading 009** · [Lecture 01 reading: x.com](https://x.com/elonmusk/status/1947701807389515912) · `外部链接` · 用于 `L01`。
- **Reading 010** · [Lecture 01 reading: x.com](https://x.com/percyliang/status/2034367256277533100) · `外部链接` · 用于 `L01`。
- **Reading 011** · [Lecture 01 reading: x.com](https://x.com/stephenroller/status/1579993017234382849) · `外部链接` · 用于 `L01`。
- **Reading 012** · [Lecture 02 reading: einops.rocks](https://einops.rocks/1-einops-basics/) · `外部链接` · 用于 `L02`。
- **Reading 013** · [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Bfloat16_floating-point_format) · `外部链接` · 用于 `L02`。
- **Reading 014** · [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Half-precision_floating-point_format) · `外部链接` · 用于 `L02`。
- **Reading 015** · [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) · `外部链接` · 用于 `L02`。
- **Reading 016** · [Lecture 02 reading: erees.dev](https://erees.dev/transformer-memory/) · `外部链接` · 用于 `L02`。
- **Reading 017** · [Lecture 02 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/roofline/) · `外部链接` · 用于 `L02`。
- **Reading 018** · [Lecture 02 reading: lambdalabs.com](https://lambdalabs.com/blog/demystifying-gpt-3) · `外部链接` · 用于 `L02`。
- **Reading 019** · [Lecture 02 reading: patmcguinness.substack.com](https://patmcguinness.substack.com/p/gpt-4-details-revealed) · `外部链接` · 用于 `L02`。
- **Reading 020** · [Lecture 02 reading: pbs.twimg.com](https://pbs.twimg.com/media/HE1P1HmaUAAjLXF?format=jpg&name=medium) · `外部链接` · 用于 `L02`。
- **Reading 021** · [Lecture 02 reading: pytorch.org](https://pytorch.org/docs/stable/amp.html) · `外部链接` · 用于 `L02`。
- **Reading 022** · [Lecture 02 reading: resources.nvidia.com](https://resources.nvidia.com/en-us-gpu-resources/h100-datasheet-24306) · `外部链接` · 用于 `L02`。
- **Reading 023** · [Lecture 02 reading: resources.nvidia.com](https://resources.nvidia.com/en-us-tensor-core/nvidia-tensor-core-gpu-datasheet) · `外部链接` · 用于 `L02`。
- **Reading 024** · [Lecture 02 reading: www.adamcasson.com](https://www.adamcasson.com/posts/transformer-flops) · `外部链接` · 用于 `L02`。
- **Reading 025** · [Lecture 05 reference p.32: towardsdatascience.com](https://towardsdatascience.com/how-pytorch-2-0-accelerates-deep-learning-with-operator-fusion-and-cpu-gpu-code-generation-35132a85bd26) · `外部链接` · 用于 `L05`。
- **Reading 026** · [Lecture 05 reference p.3: nichijou.co](https://nichijou.co/) · `外部链接` · 用于 `L05`。
- **Reading 027** · [Lecture 05 reference p.43: docs.nvidia.com](https://docs.nvidia.com/deeplearning/performance/dl-performance-matrix-multiplication/index.html#tile-quant) · `外部链接` · 用于 `L05`。
- **Reading 028** · [Lecture 05 reference p.44: www.thonking.ai](https://www.thonking.ai/p/what-shapes-do-matrix-multiplications) · `外部链接` · 用于 `L05`。
- **Reading 029** · [Lecture 06 reading: triton-lang.org](https://triton-lang.org/main/getting-started/tutorials/02-fused-softmax.html) · `外部链接` · 用于 `L06`。
- **Reading 030** · [Lecture 07 reading: crfm.stanford.edu](https://crfm.stanford.edu/2023/06/16/levanter-1_0-release.html) · `外部链接` · 用于 `L07`。
- **Reading 031** · [Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Collective_operation) · `外部链接` · 用于 `L07`。
- **Reading 032** · [Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/PCI_Express) · `外部链接` · 用于 `L07`。
- **Reading 033** · [Lecture 07 reading: pytorch.org](https://pytorch.org/docs/stable/distributed.html) · `外部链接` · 用于 `L07`。
- **Reading 034** · [Lecture 07 reading: www.nvidia.com](https://www.nvidia.com/en-us/on-demand/session/gtcspring21-s31880/) · `外部链接` · 用于 `L07`。
- **Reading 035** · [Lecture 10 reading: apxml.com](https://apxml.com/posts/llm-quantization-techniques-explained) · `外部链接` · 用于 `L10`。
- **Reading 036** · [Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/inference/) · `外部链接` · 用于 `L10`。
- **Reading 037** · [Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/transformers/) · `外部链接` · 用于 `L10`。
- **Reading 038** · [Lecture 10 reading: nvidia.github.io](https://nvidia.github.io/TensorRT-LLM/overview.html) · `外部链接` · 用于 `L10`。
- **Reading 039** · [Lecture 10 reading: research.google](https://research.google/blog/looking-back-at-speculative-decoding/) · `外部链接` · 用于 `L10`。
- **Reading 040** · [Lecture 10 reading: sgl-project.github.io](https://sgl-project.github.io/) · `外部链接` · 用于 `L10`。
- **Reading 041** · [Lecture 10 reading: storage.googleapis.com](https://storage.googleapis.com/gweb-research2023-media/media/SpeculativeDecoding-1-Illustration.mp4) · `外部链接` · 用于 `L10`。
- **Reading 042** · [Lecture 10 reading: www.baseten.co](https://www.baseten.co/blog/fp8-efficient-model-inference-with-8-bit-floating-point-numbers/) · `外部链接` · 用于 `L10`。
- **Reading 043** · [Lecture 10 reading: www.pymnts.com](https://www.pymnts.com/artificial-intelligence-2/2025/openai-bests-google-in-race-for-consumer-ai-token-consumption/) · `外部链接` · 用于 `L10`。
- **Reading 044** · [Lecture 12 reading: arcprize.org](https://arcprize.org/arc-agi) · `外部链接` · 用于 `L12`。
- **Reading 045** · [Lecture 12 reading: arena.ai](https://arena.ai/leaderboard) · `外部链接` · 用于 `L12`。
- **Reading 046** · [Lecture 12 reading: artificialanalysis.ai](https://artificialanalysis.ai/) · `外部链接` · 用于 `L12`。
- **Reading 047** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/air-bench/latest/#/leaderboard) · `外部链接` · 用于 `L12`。
- **Reading 048** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/gpqa) · `外部链接` · 用于 `L12`。
- **Reading 049** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/mmlu_pro) · `外部链接` · 用于 `L12`。
- **Reading 050** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/wildbench) · `外部链接` · 用于 `L12`。
- **Reading 051** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/medhelm/latest/#/leaderboard) · `外部链接` · 用于 `L12`。
- **Reading 052** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/mmlu/latest/) · `外部链接` · 用于 `L12`。
- **Reading 053** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/safety/latest/#/leaderboard/harm_bench) · `外部链接` · 用于 `L12`。
- **Reading 054** · [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/safety/latest/#/runs/harm_bench:model=anthropic_claude-3-7-sonnet-20250219?instancesPage=4) · `外部链接` · 用于 `L12`。
- **Reading 055** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/cybench) · `外部链接` · 用于 `L12`。
- **Reading 056** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/gpqa) · `外部链接` · 用于 `L12`。
- **Reading 057** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/hle) · `外部链接` · 用于 `L12`。
- **Reading 058** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/mmlu) · `外部链接` · 用于 `L12`。
- **Reading 059** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/mmlu-pro) · `外部链接` · 用于 `L12`。
- **Reading 060** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/swe-bench-verified) · `外部链接` · 用于 `L12`。
- **Reading 061** · [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/terminal-bench) · `外部链接` · 用于 `L12`。
- **Reading 062** · [Lecture 12 reading: openai.com](https://openai.com/index/introducing-swe-bench-verified/) · `外部链接` · 用于 `L12`。
- **Reading 063** · [Lecture 12 reading: openrouter.ai](https://openrouter.ai/rankings) · `外部链接` · 用于 `L12`。
- **Reading 064** · [Lecture 12 reading: pbs.twimg.com](https://pbs.twimg.com/media/GjICXQlWkAAYnDS?format=jpg&name=4096x4096) · `外部链接` · 用于 `L12`。
- **Reading 065** · [Lecture 12 reading: pbs.twimg.com](https://pbs.twimg.com/media/GjICcGQXYAAM4o1?format=jpg&name=4096x4096) · `外部链接` · 用于 `L12`。
- **Reading 066** · [Lecture 12 reading: tatsu-lab.github.io](https://tatsu-lab.github.io/alpaca_eval/) · `外部链接` · 用于 `L12`。
- **Reading 067** · [Lecture 12 reading: transluce.org](https://transluce.org/introducing-docent) · `外部链接` · 用于 `L12`。
- **Reading 068** · [Lecture 12 reading: www.philschmid.de](https://www.philschmid.de/agents-2.0-deep-agents) · `外部链接` · 用于 `L12`。
- **Reading 069** · [Lecture 12 reading: www.tbench.ai](https://www.tbench.ai/) · `外部链接` · 用于 `L12`。
- **Reading 070** · [Lecture 12 reading: x.com](https://x.com/karpathy/status/1846790537262571739) · `外部链接` · 用于 `L12`。
- **Reading 071** · [Lecture 13 reading: archive.org](https://archive.org/details/stackexchange) · `外部链接` · 用于 `L13`。
- **Reading 072** · [Lecture 13 reading: blog.commoncrawl.org](https://blog.commoncrawl.org/blog/common-crawl-move-to-nutch) · `外部链接` · 用于 `L13`。
- **Reading 073** · [Lecture 13 reading: commoncrawl.org](https://commoncrawl.org/blog/march-2018-crawl-archive-now-available) · `外部链接` · 用于 `L13`。
- **Reading 074** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/BookCorpus) · `外部链接` · 用于 `L13`。
- **Reading 075** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Copyright_Act_of_1976) · `外部链接` · 用于 `L13`。
- **Reading 076** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/GitHub) · `外部链接` · 用于 `L13`。
- **Reading 077** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Shadow_library) · `外部链接` · 用于 `L13`。
- **Reading 078** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Statute_of_Anne) · `外部链接` · 用于 `L13`。
- **Reading 079** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Steven_Pruitt) · `外部链接` · 用于 `L13`。
- **Reading 080** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Web_crawler) · `外部链接` · 用于 `L13`。
- **Reading 081** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Wikipedia:Notability) · `外部链接` · 用于 `L13`。
- **Reading 082** · [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Wikipedia:What_Wikipedia_is_not) · `外部链接` · 用于 `L13`。
- **Reading 083** · [Lecture 13 reading: investor.shutterstock.com](https://investor.shutterstock.com/news-releases/news-release-details/shutterstock-expands-partnership-openai-signs-new-six-year) · `外部链接` · 用于 `L13`。
- **Reading 084** · [Lecture 13 reading: meta.wikimedia.org](https://meta.wikimedia.org/wiki/Wikipedia) · `外部链接` · 用于 `L13`。
- **Reading 085** · [Lecture 13 reading: paperswithcode.com](https://paperswithcode.com/dataset/books3) · `外部链接` · 用于 `L13`。
- **Reading 086** · [Lecture 13 reading: stackexchange.com](https://stackexchange.com/sites) · `外部链接` · 用于 `L13`。
- **Reading 087** · [Lecture 13 reading: stackoverflow.co](https://stackoverflow.co/company/press/archive/openai-partnership) · `外部链接` · 用于 `L13`。
- **Reading 088** · [Lecture 13 reading: techcrunch.com](https://techcrunch.com/2025/06/25/federal-judge-sides-with-meta-in-lawsuit-over-training-ai-models-on-copyrighted-books/) · `外部链接` · 用于 `L13`。
- **Reading 089** · [Lecture 13 reading: www.copyright.gov](https://www.copyright.gov/about/fees.html) · `外部链接` · 用于 `L13`。
- **Reading 090** · [Lecture 13 reading: www.cs.cmu.edu](https://www.cs.cmu.edu/~enron/) · `外部链接` · 用于 `L13`。
- **Reading 091** · [Lecture 13 reading: www.google.com](https://www.google.com/search/howsearchworks/how-search-works/organizing-information/) · `外部链接` · 用于 `L13`。
- **Reading 092** · [Lecture 13 reading: www.wired.com](https://www.wired.com/story/battle-over-books3/) · `外部链接` · 用于 `L13`。
- **Reading 093** · [Lecture 14 reading: fasttext.cc](https://fasttext.cc/docs/en/language-identification.html) · `外部链接` · 用于 `L14`。
- **Reading 094** · [Lecture 14 reading: opensource.org](https://opensource.org/license/mit) · `外部链接` · 用于 `L14`。
- **Reading 095** · [Lecture 14 reading: softwareengineering.stackexchange.com](https://softwareengineering.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed) · `外部链接` · 用于 `L14`。
- **Reading 096** · [Lecture 14 reading: spark.apache.org](https://spark.apache.org/docs/latest/ml-features#tokenizer) · `外部链接` · 用于 `L14`。
- **Reading 097** · [Lecture 14 reading: www.amazon.co.uk](https://www.amazon.co.uk/suryagede-100-Graffiti-Gas-Mask/dp/B07CRHT3RG) · `外部链接` · 用于 `L14`。
- **Reading 098** · [Lecture 14 reading: www.gutenberg.org](https://www.gutenberg.org/MIRRORS.ALL) · `外部链接` · 用于 `L14`。
- **Reading 099** · [Lecture 17 reading: www.lmsys.org](https://www.lmsys.org/blog/2023-03-30-vicuna/) · `外部链接` · 用于 `L17`。

## 许可与引用说明

- 本地归档仅用于个人学习、检索与证据核验；版权与许可仍归各作者和发布方。
- 阅读笔记或课程总结不能替代引用原论文。正式引用前应回到原文件核对版本、作者、公式和实验数字。
- External-only 资源可能变化或需要额外访问权限；本索引不绕过登录、付费墙或平台限制。
