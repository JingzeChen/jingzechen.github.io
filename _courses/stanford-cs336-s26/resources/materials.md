---
uid: stanford-cs336-s26-resource-materials-4
type: course
document_type: resource
resource_kind: materials
resource_order: 4
course: stanford-cs336-s26
title: Stanford CS336 Spring 2026 Materials
description: 按讲次索引课程讲义、论文、FAQ、Question、Labs 与公开视频。
excerpt: 按讲次索引课程讲义、论文、FAQ、Question、Labs 与公开视频。
content_lang: zh-CN
permalink: "/courses/stanford-cs336-s26/materials/"
toc: true
math: true
---

> 站点保留 428 项完整资源索引；讲义、作业 handout 与 transcript 提供站内归档，大体积论文和仓库快照通过官方来源访问。

> 本索引由官方 Spring 2026 schedule、YouTube playlist、lecture repository、compiled traces、PDF hyperlinks 与五个 assignment repositories 生成。
> `.py` 与 `.pdf` 是课堂对齐材料；papers/readings、assignment code 和外部工具保持独立用途。

## 归档状态

- 官方 schedule：`19` 讲；playlist 可处理媒体：`18` 讲。
- Lecture 1-17：均有录像和官方 `.py`/`.pdf` 材料。
- Lecture 18（Daniel Selsam）：当前 schedule 有记录，但 playlist、课程页与 lecture repo 均无录像/材料。
- Lecture 19（Dan Fu）：有 playlist 录像，但课程页与 lecture repo 没有配套材料，后续采用 transcript-only。
- 已知公开视频总时长：`24:09:56`。
- 唯一资源：`428`；本地归档：`225`；外部链接：`203`；错误：`0`。
- 分类：`{'assignment-guide': 5, 'assignment-policy': 5, 'assignment-repository': 5, 'code-archive': 6, 'code-reference': 19, 'course-page': 1, 'dataset-or-model': 11, 'homework': 6, 'image-reference': 28, 'lecture-code': 9, 'lecture-guide': 1, 'lecture-rendering': 10, 'lecture-repository': 1, 'lecture-trace': 10, 'official-video': 18, 'official-video-playlist': 1, 'paper': 182, 'reading': 99, 'reference-registry': 1, 'slides': 8, 'video-reference': 2}`。
- Papers 由 executable lecture imports/inline links 与 PDF hyperlink annotations 提取；它们不是默认必读清单。

## 课程级入口

- [Official Spring 2026 course page](https://cs336.stanford.edu/)：`course-page`，本地归档。
- [Official YouTube playlist](https://www.youtube.com/watch?v=JuoVZkPBiKk&list=PLoROMvodv4rMqXOcazWaTUHhq-yembLCV)：`official-video-playlist`，外部链接。
- [Official lecture repository](https://github.com/stanford-cs336/lectures)：`lecture-repository`，外部链接。
- [Official lecture repository README](/assets/courses/stanford-cs336-s26/materials/official-materials/lecture-repository/README.md)：`lecture-guide`，本地归档。
- [Official lecture reference registry](/assets/courses/stanford-cs336-s26/materials/official-materials/lecture-repository/references.py)：`reference-registry`，本地归档。
- [Official lecture repository snapshot](https://codeload.github.com/stanford-cs336/lectures/zip/refs/heads/main)：`code-archive`，本地归档。

## 按 Schedule 的 19 讲

### Lecture 01: Overview, tokenization

- 日期：`Mon March 30`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=JuoVZkPBiKk)；时长：`1:19:22`。
- 对齐材料：[lecture_01.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_01.py)。

**Executable lecture source**

- [Lecture 01 official lecture_01.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_01.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 01 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_01)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 01 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_01.json)：`lecture-trace`，本地归档。

**Papers**

- [adam 2014](https://arxiv.org/pdf/1412.6980.pdf)：`paper`，本地归档。
- [adamw 2017](https://arxiv.org/pdf/1711.05101.pdf)：`paper`，本地归档。
- [auxfree 2024](https://arxiv.org/pdf/2408.15664.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [bahdanau 2015 attention](https://arxiv.org/pdf/1409.0473.pdf)：`paper`，本地归档。
- [A Neural Probabilistic Language Model](https://www.jmlr.org/papers/volume3/bengio03a/bengio03a.pdf)（Yoshua Bengio, Réjean Ducharme, Pascal Vincent, Christian Jauvin · 2003-02-01）：`paper`，本地归档。
- [bert 2018](https://arxiv.org/pdf/1810.04805.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [bloom 2022](https://arxiv.org/pdf/2211.05100.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [blt 2024](https://arxiv.org/pdf/2412.09871.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Language Models in Machine Translation](https://aclanthology.org/D07-1090.pdf)（Thorsten Brants, Ashok C. Popat, Peng Xu, Franz J. Och, Jeffrey Dean · 2007）：`paper`，本地归档。
- [byt5 2021](https://arxiv.org/pdf/2105.13626.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [chinchilla 2022](https://arxiv.org/pdf/2203.15556.pdf)：`paper`，本地归档。
- [cosine learning rate 2017](https://arxiv.org/pdf/1608.03983.pdf)：`paper`，本地归档。
- [deepseek 67b 2024](https://arxiv.org/pdf/2401.02954.pdf)：`paper`，本地归档。
- [deepseek r1 2025](https://arxiv.org/pdf/2501.12948.pdf)：`paper`，本地归档。
- [deepseek v2 2024](https://arxiv.org/pdf/2405.04434.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [deepseek v3 2024](https://arxiv.org/pdf/2412.19437.pdf)：`paper`，本地归档。
- [deepseek v3 2 2025](https://arxiv.org/pdf/2512.02556.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [dpo 2023](https://arxiv.org/pdf/2305.18290.pdf)：`paper`，本地归档。
- [elmo 2018](https://arxiv.org/pdf/1802.05365.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [gdn 2024](https://arxiv.org/pdf/2412.06464.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [glm 4 5 2025](https://arxiv.org/pdf/2508.06471.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [glm 5 2026](https://arxiv.org/pdf/2602.15763.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Understanding the difficulty of training deep feedforward neural networks](https://proceedings.mlr.press/v9/glorot10a/glorot10a.pdf)（Xavier Glorot, Yoshua Bengio · 2010-03-01）：`paper`，本地归档。
- [gpipe 2018](https://arxiv.org/pdf/1811.06965.pdf)：`paper`，本地归档。
- [Language Models are Unsupervised Multitask Learners](https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)（Alec Radford, Jeffrey Wu, Rewon Child, David Luan, Dario Amodei, Ilya Sutskever · 2019-02-14）：`paper`，本地归档。
- [gpt 3 2020](https://arxiv.org/pdf/2005.14165.pdf)：`paper`，本地归档。
- [gpt 4 2023](https://arxiv.org/pdf/2303.08774.pdf)：`paper`，本地归档。
- [GPT-J](https://arankomatsuzaki.wordpress.com/2021/06/04/gpt-j/)（Ben Wang, Aran Komatsuzaki · 2021-06-04）：`paper`，外部链接。
- [gqa 2023](https://arxiv.org/pdf/2305.13245.pdf)：`paper`，本地归档。
- [grpo](https://arxiv.org/pdf/2402.03300.pdf)：`paper`，本地归档。
- [hnet 2025](https://arxiv.org/pdf/2507.07955.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [instruct gpt 2022](https://arxiv.org/pdf/2203.02155.pdf)：`paper`，本地归档。
- [kaplan scaling laws 2020](https://arxiv.org/pdf/2001.08361.pdf)：`paper`，本地归档。
- [kimi 1 5 2025](https://arxiv.org/pdf/2501.12599.pdf)：`paper`，本地归档。
- [kimi k2 5 2026](https://arxiv.org/pdf/2602.02276.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [large batch training 2018](https://arxiv.org/pdf/1812.06162.pdf)：`paper`，本地归档。
- [layernorm 2016](https://arxiv.org/pdf/1607.06450.pdf)：`paper`，本地归档。
- [linear attention 2020](https://arxiv.org/pdf/2006.16236.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [llama 2023](https://arxiv.org/pdf/2302.13971.pdf)：`paper`，本地归档。
- [llama 2 2023](https://arxiv.org/pdf/2307.09288.pdf)：`paper`，本地归档。
- [llama 3 2024](https://arxiv.org/pdf/2407.21783.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Long Short-Term Memory](https://www.bioinf.jku.at/publications/older/2604.pdf)（Sepp Hochreiter, Jürgen Schmidhuber · 1997）：`paper`，本地归档；保留原始失效/受限链接。
- [mamba 2 2024](https://arxiv.org/pdf/2405.21060.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [mamba 3 2026](https://arxiv.org/pdf/2603.15569.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [\[Marin 32B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-32b-retro/)（2025）：`paper`，外部链接。
- [\[Marin 8B retro\]](https://marin.readthedocs.io/en/latest/reports/marin-8b-retro/)（2025）：`paper`，外部链接。
- [megabyte 2023](https://arxiv.org/pdf/2305.07185.pdf)：`paper`，本地归档。
- [megatron lm 2019](https://arxiv.org/pdf/1909.08053.pdf)：`paper`，本地归档。
- [\[MiniMax M2.5\]](https://www.minimax.io/news/minimax-m25)（2026）：`paper`，外部链接。
- [mistral 7b 2023](https://arxiv.org/pdf/2310.06825.pdf)：`paper`，本地归档。
- [mixtral 2024](https://arxiv.org/pdf/2401.04088.pdf)：`paper`，本地归档。
- [moe 2017](https://arxiv.org/pdf/1701.06538.pdf)：`paper`，本地归档。
- [mtp 2024](https://arxiv.org/pdf/2404.19737.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Muon: An optimizer for hidden layers in neural networks](https://kellerjordan.github.io/posts/muon/)（Jordan Keller · 2024-12-08）：`paper`，外部链接。
- [mup 2022](https://arxiv.org/pdf/2203.03466.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [nemotron 15b 2024](https://arxiv.org/pdf/2402.16819.pdf)：`paper`，本地归档。
- [nemotron 3 2025](https://arxiv.org/pdf/2512.20856.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [olmix 2026](https://arxiv.org/pdf/2602.12237.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [olmo 2 2025](https://arxiv.org/pdf/2501.00656.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [olmo 3 2025](https://arxiv.org/pdf/2512.13961.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [olmo 7b 2024](https://arxiv.org/pdf/2402.00838.pdf)：`paper`，本地归档。
- [opt 175b 2022](https://arxiv.org/pdf/2205.01068.pdf)：`paper`，本地归档。
- [palm 2022](https://arxiv.org/pdf/2204.02311.pdf)：`paper`，本地归档。
- [ppo 2017](https://arxiv.org/pdf/1707.06347.pdf)：`paper`，本地归档。
- [pre post norm 2020](https://arxiv.org/pdf/2002.04745.pdf)：`paper`，本地归档。
- [qk norm 2023](https://arxiv.org/pdf/2302.05442.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [qwen 2 5 2024](https://arxiv.org/pdf/2412.15115.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [qwen 3 2025](https://arxiv.org/pdf/2505.09388.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [regmix 2025](https://arxiv.org/pdf/2407.01492.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [rms norm 2019](https://arxiv.org/pdf/1910.07467.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [rope 2021](https://arxiv.org/pdf/2104.09864.pdf)：`paper`，本地归档。
- [sennrich 2016](https://arxiv.org/pdf/1508.07909.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [seq2seq 2014](https://arxiv.org/pdf/1409.3215.pdf)：`paper`，本地归档。
- [Prediction and Entropy of Printed English](https://www.princeton.edu/~wbialek/rome/refs/shannon_51.pdf)（Claude Shannon · 1950-09-15）：`paper`，本地归档。
- [shazeer 2020](https://arxiv.org/pdf/2002.05202.pdf)：`paper`，本地归档。
- [soap 2024](https://arxiv.org/pdf/2409.11321.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [sparse transformer 2019](https://arxiv.org/pdf/1904.10509.pdf)：`paper`，本地归档。
- [switch transformers 2021](https://arxiv.org/pdf/2101.03961.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [t5 2019](https://arxiv.org/pdf/1910.10683.pdf)：`paper`，本地归档。
- [tfree 2024](https://arxiv.org/pdf/2406.19223.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [the pile 2020](https://arxiv.org/pdf/2101.00027.pdf)：`paper`，本地归档。
- [transformer 2017](https://arxiv.org/pdf/1706.03762.pdf)：`paper`，本地归档。
- [wrap 2024](https://arxiv.org/pdf/2401.16380.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [wsd 2024](https://arxiv.org/pdf/2404.06395.pdf)：`paper`，本地归档。
- [\[Xiaomi MIMO v2\]](https://mimo.xiaomi.com/mimo-v2-pro)（2026）：`paper`，外部链接。
- [zero 2019](https://arxiv.org/pdf/1910.02054.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2005.04305.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2403.07918.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2206.07682.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 01 paper: arxiv.org](https://arxiv.org/pdf/2303.15715.pdf)：`paper`，本地归档。

**Other readings**

- [Lecture 01 reading: www.pennelynn.com](https://www.pennelynn.com/Documents/CUJ/HTML/94HTML/19940045.HTM)：`reading`，外部链接。
- [Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/List_of_Unicode_characters)：`reading`，外部链接。
- [Lecture 01 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/UTF-8)：`reading`，外部链接。
- [Lecture 01 reading: pbs.twimg.com](https://pbs.twimg.com/media/HDuErvvbsAAQ5Yt?format=jpg&name=4096x4096)：`reading`，外部链接。
- [Lecture 01 reading: stanford-cs336.github.io](https://stanford-cs336.github.io/spring2026/)：`reading`，外部链接。
- [Lecture 01 reading: tiktokenizer.vercel.app](https://tiktokenizer.vercel.app/?encoder=gpt2)：`reading`，外部链接。
- [Lecture 01 reading: www.reuters.com](https://www.reuters.com/technology/reddit-ai-content-licensing-deal-with-google-sources-say-2024-02-22/)：`reading`，外部链接。
- [Lecture 01 reading: www.wired.com](https://www.wired.com/story/openai-ceo-sam-altman-the-age-of-giant-ai-models-is-already-over/)：`reading`，外部链接。
- [Lecture 01 reading: x.com](https://x.com/elonmusk/status/1947701807389515912)：`reading`，外部链接。
- [Lecture 01 reading: x.com](https://x.com/percyliang/status/2034367256277533100)：`reading`，外部链接。
- [Lecture 01 reading: x.com](https://x.com/stephenroller/status/1579993017234382849)：`reading`，外部链接。

**Code and tools**

- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment1-basics)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment1-basics/blob/main/cs336_spring2026_assignment1_basics.pdf)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment2-systems)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment2-systems/blob/spring2025/cs336_spring2025_assignment2_systems.pdf)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment3-scaling)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment3-scaling/blob/master/cs336_spring2025_assignment3_scaling.pdf)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment4-data)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment4-data/blob/spring2025/cs336_spring2025_assignment4_data.pdf)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment5-alignment)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/assignment5-alignment/blob/spring2025/cs336_spring2025_assignment5_alignment.pdf)：`code-reference`，外部链接。
- [Lecture 01 code-reference: github.com](https://github.com/stanford-cs336/spring2025-assignment1-basics-leaderboard)：`code-reference`，外部链接。

**Datasets and models**

- [Lecture 01 dataset-or-model: huggingface.co](https://huggingface.co/datasets/HuggingFaceTB/smoltalk/viewer/all/train?row=72&conversation-viewer=72)：`dataset-or-model`，外部链接。
- [Lecture 01 dataset-or-model: huggingface.co](https://huggingface.co/datasets/nebius/SWE-rebench-openhands-trajectories/viewer/default/train?conversation-viewer=1)：`dataset-or-model`，外部链接。

**Referenced videos**

- [Lecture 01 video-reference: www.youtube.com](https://www.youtube.com/watch?v=zduSFxRajkE)：`video-reference`，外部链接。

**Image sources**

- [Lecture 01 image-reference: ar5iv.labs.arxiv.org](https://ar5iv.labs.arxiv.org/html/2101.00027/assets/pile_chart2.png)：`image-reference`，外部链接。
- [Lecture 01 image-reference: docs.nvidia.com](https://docs.nvidia.com/dgx/dgxb200-user-guide/_images/dgx-b200-system-topology.png)：`image-reference`，外部链接。
- [Lecture 01 image-reference: upload.wikimedia.org](https://upload.wikimedia.org/wikipedia/commons/c/cc/Industrialisation.jpg)：`image-reference`，外部链接。

**official-video**

- [Lecture 01 official YouTube recording](https://www.youtube.com/watch?v=JuoVZkPBiKk)：`official-video`，外部链接。

### Lecture 02: PyTorch (einops), resource accounting (FLOPs, memory, arithmetic intensity)

- 日期：`Wed April 1`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=kuYAsz7zspQ)；时长：`1:17:25`。
- 对齐材料：[lecture_02.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_02.py)。

**Executable lecture source**

- [Lecture 02 official lecture_02.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_02.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 02 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_02)：`lecture-rendering`，外部链接。
- [Lecture 02 recording-version trace](https://cs336.stanford.edu/lectures/?trace=lecture_02_recording)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 02 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_02.json)：`lecture-trace`，本地归档。
- [Lecture 02 recording-version trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_02_recording.json)：`lecture-trace`，本地归档。

**Papers**

- [adagrad 2011](https://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)（John Duchi, Elad Hazan, Yoram Singer · 2011）：`paper`，本地归档。
- [deepseek v3 2 2025](https://arxiv.org/pdf/2512.02556.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Nemotron 3 Super: Open, Efficient Mixture-of-Experts Hybrid Mamba-Transformer Model for Agentic Reasoning](https://research.nvidia.com/labs/nemotron/files/NVIDIA-Nemotron-3-Super-Technical-Report.pdf)（2026-03-11）：`paper`，本地归档。
- [Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/1710.03740.pdf)：`paper`，本地归档。
- [Lecture 02 paper: arxiv.org](https://arxiv.org/pdf/2209.05433.pdf)：`paper`，本地归档。

**Other readings**

- [Lecture 02 reading: einops.rocks](https://einops.rocks/1-einops-basics/)：`reading`，外部链接。
- [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Bfloat16_floating-point_format)：`reading`，外部链接。
- [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)：`reading`，外部链接。
- [Lecture 02 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Single-precision_floating-point_format)：`reading`，外部链接。
- [Lecture 02 reading: erees.dev](https://erees.dev/transformer-memory/)：`reading`，外部链接。
- [Lecture 02 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/roofline/)：`reading`，外部链接。
- [Lecture 02 reading: lambdalabs.com](https://lambdalabs.com/blog/demystifying-gpt-3)：`reading`，外部链接。
- [Lecture 02 reading: patmcguinness.substack.com](https://patmcguinness.substack.com/p/gpt-4-details-revealed)：`reading`，外部链接。
- [Lecture 02 reading: pbs.twimg.com](https://pbs.twimg.com/media/HE1P1HmaUAAjLXF?format=jpg&name=medium)：`reading`，外部链接。
- [Lecture 02 reading: pytorch.org](https://pytorch.org/docs/stable/amp.html)：`reading`，外部链接。
- [Lecture 02 reading: resources.nvidia.com](https://resources.nvidia.com/en-us-gpu-resources/h100-datasheet-24306)：`reading`，外部链接。
- [Lecture 02 reading: resources.nvidia.com](https://resources.nvidia.com/en-us-tensor-core/nvidia-tensor-core-gpu-datasheet)：`reading`，外部链接。
- [Lecture 02 reading: www.adamcasson.com](https://www.adamcasson.com/posts/transformer-flops)：`reading`，外部链接。

**Datasets and models**

- [Lecture 02 dataset-or-model: huggingface.co](https://huggingface.co/deepseek-ai/DeepSeek-V3.2?show_file_info=model.safetensors.index.json)：`dataset-or-model`，外部链接。

**Image sources**

- [Lecture 02 image-reference: docs.nvidia.com](https://docs.nvidia.com/deeplearning/transformer-engine/user-guide/_images/fp8_formats.png)：`image-reference`，外部链接。
- [Lecture 02 image-reference: jax-ml.github.io](https://jax-ml.github.io/scaling-book/assets/img/roofline-improved-1400.webp)：`image-reference`，外部链接。

**official-video**

- [Lecture 02 official YouTube recording](https://www.youtube.com/watch?v=kuYAsz7zspQ)：`official-video`，外部链接。

### Lecture 03: Architectures, hyperparameters

- 日期：`Mon April 6`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=lVynu4bo1rY)；时长：`1:29:14`。
- 对齐材料：[lecture_03.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_03.pdf)。

**PDF lecture material**

- [Lecture 03 official lecture_03.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_03.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 03 official YouTube recording](https://www.youtube.com/watch?v=lVynu4bo1rY)：`official-video`，外部链接。

### Lecture 04: Attention alternatives and mixture of experts

- 日期：`Wed April 8`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=cKSwj_qZ8Jg)；时长：`1:26:21`。
- 对齐材料：[lecture_04.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_04.pdf)。

**PDF lecture material**

- [Lecture 04 official lecture_04.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_04.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 04 official YouTube recording](https://www.youtube.com/watch?v=cKSwj_qZ8Jg)：`official-video`，外部链接。

### Lecture 05: GPUs, TPUs

- 日期：`Mon April 13`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=izZba4UA7iY)；时长：`1:18:39`。
- 对齐材料：[lecture_05.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_05.pdf)。

**PDF lecture material**

- [Lecture 05 official lecture_05.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_05.pdf)：`slides`，本地归档。

**Papers**

- [Lecture 05 reference p.26: nvlabs.github.io](https://nvlabs.github.io/eccv2020-mixed-precision-tutorial/files/dusan_stosic-training-neural-networks-with-tensor-cores.pdf)：`paper`，本地归档。

**Other readings**

- [Lecture 05 reference p.3: nichijou.co](https://nichijou.co/)：`reading`，外部链接。
- [Lecture 05 reference p.32: towardsdatascience.com](https://towardsdatascience.com/how-pytorch-2-0-accelerates-deep-learning-with-operator-fusion-and-cpu-gpu-code-generation-35132a85bd26)：`reading`，外部链接。
- [Lecture 05 reference p.43: docs.nvidia.com](https://docs.nvidia.com/deeplearning/performance/dl-performance-matrix-multiplication/index.html#tile-quant)：`reading`，外部链接。
- [Lecture 05 reference p.44: www.thonking.ai](https://www.thonking.ai/p/what-shapes-do-matrix-multiplications)：`reading`，外部链接。

**official-video**

- [Lecture 05 official YouTube recording](https://www.youtube.com/watch?v=izZba4UA7iY)：`official-video`，外部链接。

### Lecture 06: Kernels, Triton

- 日期：`Wed April 15`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=xnDHaNUvHBg)；时长：`1:26:41`。
- 对齐材料：[lecture_06.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_06.py)。

**Executable lecture source**

- [Lecture 06 official lecture_06.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_06.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 06 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_06)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 06 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_06.json)：`lecture-trace`，本地归档。

**Other readings**

- [Lecture 06 reading: triton-lang.org](https://triton-lang.org/main/getting-started/tutorials/02-fused-softmax.html)：`reading`，外部链接。

**Image sources**

- [Lecture 06 image-reference: developer-blogs.nvidia.com](https://developer-blogs.nvidia.com/wp-content/uploads/2019/06/pasted-image-0.png)：`image-reference`，外部链接。
- [Lecture 06 image-reference: docs.nvidia.com](https://docs.nvidia.com/cuda/parallel-thread-execution/_images/grid-with-CTAs.png)：`image-reference`，外部链接。

**official-video**

- [Lecture 06 official YouTube recording](https://www.youtube.com/watch?v=xnDHaNUvHBg)：`official-video`，外部链接。

### Lecture 07: Parallelism

- 日期：`Mon April 20`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=SzpOcwdIL0Y)；时长：`1:21:03`。
- 对齐材料：[lecture_07.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_07.py)。

**Executable lecture source**

- [Lecture 07 official lecture_07.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_07.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 07 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_07)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 07 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_07.json)：`lecture-trace`，本地归档。

**Other readings**

- [Lecture 07 reading: crfm.stanford.edu](https://crfm.stanford.edu/2023/06/16/levanter-1_0-release.html)：`reading`，外部链接。
- [Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Collective_operation)：`reading`，外部链接。
- [Lecture 07 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/PCI_Express)：`reading`，外部链接。
- [Lecture 07 reading: pytorch.org](https://pytorch.org/docs/stable/distributed.html)：`reading`，外部链接。
- [Lecture 07 reading: www.nvidia.com](https://www.nvidia.com/en-us/on-demand/session/gtcspring21-s31880/)：`reading`，外部链接。

**Code and tools**

- [Lecture 07 code-reference: github.com](https://github.com/NVIDIA/nccl-tests/blob/master/doc/PERFORMANCE.md#allreduce)：`code-reference`，外部链接。
- [Lecture 07 code-reference: github.com](https://github.com/stas00/ml-engineering/blob/master/network/benchmarks/all_reduce_bench.py)：`code-reference`，外部链接。

**Image sources**

- [Lecture 07 image-reference: media.springernature.com](https://media.springernature.com/lw685/springer-static/image/art:10.1186/s42774-021-00098-3/MediaObjects/42774_2021_98_Fig1_HTML.png?as=webp)：`image-reference`，外部链接。

**official-video**

- [Lecture 07 official YouTube recording](https://www.youtube.com/watch?v=SzpOcwdIL0Y)：`official-video`，外部链接。

### Lecture 08: Parallelism

- 日期：`Wed April 22`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=6-cXp-aOmdg)；时长：`1:20:11`。
- 对齐材料：[lecture_08.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_08.pdf)。

**PDF lecture material**

- [Lecture 08 official lecture_08.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_08.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 08 official YouTube recording](https://www.youtube.com/watch?v=6-cXp-aOmdg)：`official-video`，外部链接。

### Lecture 09: Scaling laws

- 日期：`Mon April 27`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=Q15rhEWZPQ4)；时长：`1:17:57`。
- 对齐材料：[lecture_09.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_09.pdf)。

**PDF lecture material**

- [Lecture 09 official lecture_09.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_09.pdf)：`slides`，本地归档。

**Papers**

- [Lecture 09 reference p.6: www.cs.cmu.edu](https://www.cs.cmu.edu/~epxing/Class/10701/slides/lecture16-VC.pdf)：`paper`，本地归档。

**official-video**

- [Lecture 09 official YouTube recording](https://www.youtube.com/watch?v=Q15rhEWZPQ4)：`official-video`，外部链接。

### Lecture 10: Inference

- 日期：`Wed April 29`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=EfM546A79aM)；时长：`1:25:30`。
- 对齐材料：[lecture_10.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_10.py)。

**Executable lecture source**

- [Lecture 10 official lecture_10.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_10.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 10 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_10)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 10 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_10.json)：`lecture-trace`，本地归档。

**Papers**

- [DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence](https://arxiv.org/pdf/2606.19348.pdf)（2026-04）：`paper`，本地归档；保留原始失效/受限链接。
- [gqa 2023](https://arxiv.org/pdf/2305.13245.pdf)：`paper`，本地归档。
- [longformer 2020](https://arxiv.org/pdf/2004.05150.pdf)：`paper`，本地归档。
- [mistral 7b 2023](https://arxiv.org/pdf/2310.06825.pdf)：`paper`，本地归档。
- [mla 2024](https://arxiv.org/pdf/2405.04434.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [sparse transformer 2019](https://arxiv.org/pdf/1904.10509.pdf)：`paper`，本地归档。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2210.17323.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2211.17192.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2302.01318.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2306.00978.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2401.10774.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2405.12981.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2407.14679.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2303.17951.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2309.06180.pdf)：`paper`，本地归档。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2310.18313.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: arxiv.org](https://arxiv.org/pdf/2401.15077.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 10 paper: www.usenix.org](https://www.usenix.org/system/files/osdi22-yu.pdf)：`paper`，本地归档。

**Other readings**

- [Lecture 10 reading: apxml.com](https://apxml.com/posts/llm-quantization-techniques-explained)：`reading`，外部链接。
- [Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/inference/)：`reading`，外部链接。
- [Lecture 10 reading: jax-ml.github.io](https://jax-ml.github.io/scaling-book/transformers/)：`reading`，外部链接。
- [Lecture 10 reading: nvidia.github.io](https://nvidia.github.io/TensorRT-LLM/overview.html)：`reading`，外部链接。
- [Lecture 10 reading: research.google](https://research.google/blog/looking-back-at-speculative-decoding/)：`reading`，外部链接。
- [Lecture 10 reading: sgl-project.github.io](https://sgl-project.github.io/)：`reading`，外部链接。
- [Lecture 10 reading: storage.googleapis.com](https://storage.googleapis.com/gweb-research2023-media/media/SpeculativeDecoding-1-Illustration.mp4)：`reading`，外部链接。
- [Lecture 10 reading: www.baseten.co](https://www.baseten.co/blog/fp8-efficient-model-inference-with-8-bit-floating-point-numbers/)：`reading`，外部链接。
- [Lecture 10 reading: www.pymnts.com](https://www.pymnts.com/artificial-intelligence-2/2025/openai-bests-google-in-race-for-consumer-ai-token-consumption/)：`reading`，外部链接。

**Code and tools**

- [Lecture 10 code-reference: github.com](https://github.com/ggml-org/llama.cpp)：`code-reference`，外部链接。
- [Lecture 10 code-reference: github.com](https://github.com/vllm-project/vllm)：`code-reference`，外部链接。

**Referenced videos**

- [Lecture 10 video-reference: www.youtube.com](https://www.youtube.com/watch?v=Ob9PPLxETYU)：`video-reference`，外部链接。

**Image sources**

- [Lecture 10 image-reference: images.ctfassets.net](https://images.ctfassets.net/xjan103pcp94/1LJioEsEdQQpDCxYNWirU6/82b9fbfc5b78b10c1d4508b60e72fdcf/cb_02_diagram-static-batching.png)：`image-reference`，外部链接。
- [Lecture 10 image-reference: jax-ml.github.io](https://jax-ml.github.io/scaling-book/assets/img/cached-inference-1400.webp)：`image-reference`，外部链接。
- [Lecture 10 image-reference: jax-ml.github.io](https://jax-ml.github.io/scaling-book/assets/img/gmqa.png)：`image-reference`，外部链接。
- [Lecture 10 image-reference: jax-ml.github.io](https://jax-ml.github.io/scaling-book/assets/img/naive-inference-1400.webp)：`image-reference`，外部链接。
- [Lecture 10 image-reference: jax-ml.github.io](https://jax-ml.github.io/scaling-book/assets/img/transformer-diagram.png)：`image-reference`，外部链接。
- [Lecture 10 image-reference: www.datocms-assets.com](https://www.datocms-assets.com/104802/1709770809-twitter-post-20.png)：`image-reference`，外部链接。

**official-video**

- [Lecture 10 official YouTube recording](https://www.youtube.com/watch?v=EfM546A79aM)：`official-video`，外部链接。

### Lecture 11: Scaling laws

- 日期：`Mon May 4`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=vTfEyOyzV9E)；时长：`1:17:04`。
- 对齐材料：[lecture_11.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_11.pdf)。

**PDF lecture material**

- [Lecture 11 official lecture_11.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_11.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 11 official YouTube recording](https://www.youtube.com/watch?v=vTfEyOyzV9E)：`official-video`，外部链接。

### Lecture 12: Evaluation

- 日期：`Wed May 6`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=JpAxdTWQJxM)；时长：`1:18:34`。
- 对齐材料：[lecture_12.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_12.py)。

**Executable lecture source**

- [Lecture 12 official lecture_12.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_12.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 12 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_12)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 12 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_12.json)：`lecture-trace`，本地归档。

**Papers**

- [mmlu 2021](https://arxiv.org/pdf/2009.03300.pdf)：`paper`，本地归档。
- [Lecture 12 paper: arcprize.org](https://arcprize.org/media/ARC_AGI_3_Technical_Report.pdf)：`paper`，本地归档。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1602.02410.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1606.06031.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2310.06770.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2311.12022.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2402.04249.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2403.04132.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2406.01574.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2407.17436.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2408.08926.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2410.07095.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2410.08385.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2412.13678.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2501.14249.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2502.03461.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2505.23802.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2507.02825.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2601.11868.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/1905.07830.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2307.15043.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2310.17623.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2404.04475.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2406.04770.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 12 paper: arxiv.org](https://arxiv.org/pdf/2510.04374.pdf)：`paper`，本地归档；保留原始失效/受限链接。

**Other readings**

- [Lecture 12 reading: arcprize.org](https://arcprize.org/arc-agi)：`reading`，外部链接。
- [Lecture 12 reading: arena.ai](https://arena.ai/leaderboard)：`reading`，外部链接。
- [Lecture 12 reading: artificialanalysis.ai](https://artificialanalysis.ai/)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/air-bench/latest/#/leaderboard)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/gpqa)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/mmlu_pro)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/capabilities/latest/#/leaderboard/wildbench)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/medhelm/latest/#/leaderboard)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/mmlu/latest/)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/safety/latest/#/leaderboard/harm_bench)：`reading`，外部链接。
- [Lecture 12 reading: crfm.stanford.edu](https://crfm.stanford.edu/helm/safety/latest/#/runs/harm_bench:model=anthropic_claude-3-7-sonnet-20250219?instancesPage=4)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/cybench)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/gpqa)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/hle)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/mmlu)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/mmlu-pro)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/swe-bench-verified)：`reading`，外部链接。
- [Lecture 12 reading: llm-stats.com](https://llm-stats.com/benchmarks/terminal-bench)：`reading`，外部链接。
- [Lecture 12 reading: openai.com](https://openai.com/index/introducing-swe-bench-verified/)：`reading`，外部链接。
- [Lecture 12 reading: openrouter.ai](https://openrouter.ai/rankings)：`reading`，外部链接。
- [Lecture 12 reading: pbs.twimg.com](https://pbs.twimg.com/media/GjICXQlWkAAYnDS?format=jpg&name=4096x4096)：`reading`，外部链接。
- [Lecture 12 reading: pbs.twimg.com](https://pbs.twimg.com/media/GjICcGQXYAAM4o1?format=jpg&name=4096x4096)：`reading`，外部链接。
- [Lecture 12 reading: tatsu-lab.github.io](https://tatsu-lab.github.io/alpaca_eval/)：`reading`，外部链接。
- [Lecture 12 reading: transluce.org](https://transluce.org/introducing-docent)：`reading`，外部链接。
- [Lecture 12 reading: www.philschmid.de](https://www.philschmid.de/agents-2.0-deep-agents)：`reading`，外部链接。
- [Lecture 12 reading: www.tbench.ai](https://www.tbench.ai/)：`reading`，外部链接。
- [Lecture 12 reading: x.com](https://x.com/karpathy/status/1846790537262571739)：`reading`，外部链接。

**Code and tools**

- [Lecture 12 code-reference: github.com](https://github.com/tatsu-lab/alpaca_eval/raw/main/figures/chat_correlations_no_ae.png)：`code-reference`，外部链接。

**Image sources**

- [Lecture 12 image-reference: arcprize.org](https://arcprize.org/media/images/arc-task-grids.jpg)：`image-reference`，外部链接。
- [Lecture 12 image-reference: arcprize.org](https://arcprize.org/media/images/blog/arc-agi-2-unsolved-1.png)：`image-reference`，外部链接。
- [Lecture 12 image-reference: crfm.stanford.edu](https://crfm.stanford.edu/helm/assets/air-overview-DpBbyagA.png)：`image-reference`，外部链接。
- [Lecture 12 image-reference: crfm.stanford.edu](https://crfm.stanford.edu/helm/assets/medhelm-overview-CND0EIsy.png)：`image-reference`，外部链接。
- [Lecture 12 image-reference: www.philschmid.de](https://www.philschmid.de/static/blog/agents-2.0-deep-agents/overview.png)：`image-reference`，外部链接。
- [Lecture 12 image-reference: www.team-bhp.com](https://www.team-bhp.com/forum/attachments/road-safety/2173645d1625144681-will-crash-test-rating-change-if-higher-variant-chosen-images-30.jpeg)：`image-reference`，外部链接。

**official-video**

- [Lecture 12 official YouTube recording](https://www.youtube.com/watch?v=JpAxdTWQJxM)：`official-video`，外部链接。

### Lecture 13: Data (sources, datasets)

- 日期：`Mon May 11`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=-qm0ln33G24)；时长：`1:22:02`。
- 对齐材料：[lecture_13.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_13.py)。

**Executable lecture source**

- [Lecture 13 official lecture_13.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_13.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 13 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_13)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 13 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_13.json)：`lecture-trace`，本地归档。

**Papers**

- [Alpaca](https://crfm.stanford.edu/2023/03/13/alpaca.html)（Rohan Taori, Ishaan Gulrajani, Tianyi Zhang, Yann Dubois, Xuechen Li, Carlos Guestrin, Percy Liang, Tatsunori B. Hashimoto · 2023-03-13）：`paper`，外部链接。
- [dclm 2024](https://arxiv.org/pdf/2406.11794.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [gopher 2021](https://arxiv.org/pdf/2112.11446.pdf)：`paper`，本地归档。
- [Language Models are Unsupervised Multitask Learners](https://cdn.openai.com/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)（Alec Radford, Jeffrey Wu, Rewon Child, David Luan, Dario Amodei, Ilya Sutskever · 2019-02-14）：`paper`，本地归档。
- [llama 3 2024](https://arxiv.org/pdf/2407.21783.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [nemotron cc 2024](https://arxiv.org/pdf/2412.02595.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [olmo 2 2025](https://arxiv.org/pdf/2501.00656.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [OpenWebText](https://skylion007.github.io/OpenWebTextCorpus/)（Aaron Gokaslan, Vanya Cohen · 2019）：`paper`，外部链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1506.06724.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2402.19173.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2407.14933.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1810.04805.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1910.10683v4.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/1911.00359.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2005.14165.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2010.12563.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2101.00027.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2104.08758.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2211.15533.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2302.10149.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2302.13971.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2306.01116.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2402.00159.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2411.15124.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/pdf/2506.05209.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 13 paper: arxiv.org](https://arxiv.org/stats/monthly_submissions)：`paper`，外部链接。

**Other readings**

- [Lecture 13 reading: archive.org](https://archive.org/details/stackexchange)：`reading`，外部链接。
- [Lecture 13 reading: blog.commoncrawl.org](https://blog.commoncrawl.org/blog/common-crawl-move-to-nutch)：`reading`，外部链接。
- [Lecture 13 reading: commoncrawl.org](https://commoncrawl.org/blog/march-2018-crawl-archive-now-available)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/BookCorpus)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Copyright_Act_of_1976)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/GitHub)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Shadow_library)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Statute_of_Anne)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Steven_Pruitt)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Web_crawler)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Wikipedia:Notability)：`reading`，外部链接。
- [Lecture 13 reading: en.wikipedia.org](https://en.wikipedia.org/wiki/Wikipedia:What_Wikipedia_is_not)：`reading`，外部链接。
- [Lecture 13 reading: investor.shutterstock.com](https://investor.shutterstock.com/news-releases/news-release-details/shutterstock-expands-partnership-openai-signs-new-six-year)：`reading`，外部链接。
- [Lecture 13 reading: meta.wikimedia.org](https://meta.wikimedia.org/wiki/Wikipedia)：`reading`，外部链接。
- [Lecture 13 reading: paperswithcode.com](https://paperswithcode.com/dataset/books3)：`reading`，外部链接。
- [Lecture 13 reading: stackexchange.com](https://stackexchange.com/sites)：`reading`，外部链接。
- [Lecture 13 reading: stackoverflow.co](https://stackoverflow.co/company/press/archive/openai-partnership)：`reading`，外部链接。
- [Lecture 13 reading: techcrunch.com](https://techcrunch.com/2025/06/25/federal-judge-sides-with-meta-in-lawsuit-over-training-ai-models-on-copyrighted-books/)：`reading`，外部链接。
- [Lecture 13 reading: www.copyright.gov](https://www.copyright.gov/about/fees.html)：`reading`，外部链接。
- [Lecture 13 reading: www.cs.cmu.edu](https://www.cs.cmu.edu/~enron/)：`reading`，外部链接。
- [Lecture 13 reading: www.google.com](https://www.google.com/search/howsearchworks/how-search-works/organizing-information/)：`reading`，外部链接。
- [Lecture 13 reading: www.reuters.com](https://www.reuters.com/technology/reddit-ai-content-licensing-deal-with-google-sources-say-2024-02-22/)：`reading`，外部链接。
- [Lecture 13 reading: www.wired.com](https://www.wired.com/story/battle-over-books3/)：`reading`，外部链接。

**Code and tools**

- [Lecture 13 code-reference: github.com](https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/blob/master/en)：`code-reference`，外部链接。
- [Lecture 13 code-reference: github.com](https://github.com/google-deepmind/pg19)：`code-reference`，外部链接。

**Datasets and models**

- [Lecture 13 dataset-or-model: huggingface.co](https://huggingface.co/datasets/HuggingFaceFW/fineweb)：`dataset-or-model`，外部链接。
- [Lecture 13 dataset-or-model: huggingface.co](https://huggingface.co/datasets/the_pile_books3)：`dataset-or-model`，外部链接。
- [Lecture 13 dataset-or-model: huggingface.co](https://huggingface.co/datasets/togethercomputer/RedPajama-Data-1T)：`dataset-or-model`，外部链接。

**Image sources**

- [Lecture 13 image-reference: miro.medium.com](https://miro.medium.com/v2/resize:fit:1400/1*-0Qqhvu7JD6Y9JgsfKJdxw.png)：`image-reference`，外部链接。
- [Lecture 13 image-reference: stanford-cs324.github.io](https://stanford-cs324.github.io/winter2022/lectures/images/c4-domains.png)：`image-reference`，外部链接。
- [Lecture 13 image-reference: stanford-cs324.github.io](https://stanford-cs324.github.io/winter2022/lectures/images/the-pile.png)：`image-reference`，外部链接。
- [Lecture 13 image-reference: upload.wikimedia.org](https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/WebCrawlerArchitecture.svg/330px-WebCrawlerArchitecture.svg.png)：`image-reference`，外部链接。

**official-video**

- [Lecture 13 official YouTube recording](https://www.youtube.com/watch?v=-qm0ln33G24)：`official-video`，外部链接。

### Lecture 14: Data (filtering, deduplication, mixing, synthetic data)

- 日期：`Wed May 13`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=5sxHosTLPF8)；时长：`1:24:46`。
- 对齐材料：[lecture_14.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_14.py)。

**Executable lecture source**

- [Lecture 14 official lecture_14.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_14.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 14 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_14)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 14 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_14.json)：`lecture-trace`，本地归档。

**Papers**

- [dclm 2024](https://arxiv.org/pdf/2406.11794.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [dolma 2024](https://arxiv.org/pdf/2402.00159.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [the pile 2020](https://arxiv.org/pdf/2101.00027.pdf)：`paper`，本地归档。
- [Lecture 14 paper: infolab.stanford.edu](https://infolab.stanford.edu/~ullman/mmds/ch3n.pdf)：`paper`，本地归档。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2304.09151.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2402.16827.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2407.01492.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2504.21798.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2506.04178.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2604.01496.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/1910.10683v4.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2005.14165.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2107.06499.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2302.13971.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2306.11644.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2310.06786.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2501.11747.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2505.20411.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 14 paper: arxiv.org](https://arxiv.org/pdf/2602.12237.pdf)：`paper`，本地归档；保留原始失效/受限链接。

**Other readings**

- [Lecture 14 reading: fasttext.cc](https://fasttext.cc/docs/en/language-identification.html)：`reading`，外部链接。
- [Lecture 14 reading: opensource.org](https://opensource.org/license/mit)：`reading`，外部链接。
- [Lecture 14 reading: softwareengineering.stackexchange.com](https://softwareengineering.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed)：`reading`，外部链接。
- [Lecture 14 reading: spark.apache.org](https://spark.apache.org/docs/latest/ml-features#tokenizer)：`reading`，外部链接。
- [Lecture 14 reading: www.amazon.co.uk](https://www.amazon.co.uk/suryagede-100-Graffiti-Gas-Mask/dp/B07CRHT3RG)：`reading`，外部链接。
- [Lecture 14 reading: www.gutenberg.org](https://www.gutenberg.org/MIRRORS.ALL)：`reading`，外部链接。

**Datasets and models**

- [Lecture 14 dataset-or-model: huggingface.co](https://huggingface.co/datasets/AlienKevin/SWE-ZERO-12M-trajectories)：`dataset-or-model`，外部链接。
- [Lecture 14 dataset-or-model: huggingface.co](https://huggingface.co/spaces/HuggingFaceFW/FinePDFsBlog)：`dataset-or-model`，外部链接。
- [Lecture 14 dataset-or-model: huggingface.co](https://huggingface.co/spaces/marin-community/token-count-viewer)：`dataset-or-model`，外部链接。
- [Lecture 14 dataset-or-model: www.kaggle.com](https://www.kaggle.com/competitions/jigsaw-toxic-comment-classification-challenge/discussion/46064)：`dataset-or-model`，外部链接。
- [Lecture 14 dataset-or-model: www.kaggle.com](https://www.kaggle.com/datasets/julian3833/jigsaw-toxic-comment-classification-challenge)：`dataset-or-model`，外部链接。

**Image sources**

- [Lecture 14 image-reference: cdn.sanity.io](https://cdn.sanity.io/images/vr8gru94/production/aace49fa240778e8ecf6e85ad08a2de7f5385566-1280x720.png)：`image-reference`，外部链接。
- [Lecture 14 image-reference: cdn.sanity.io](https://cdn.sanity.io/images/vr8gru94/production/b470799575b8e77911bacb8500977afef06d6c85-1280x720.png)：`image-reference`，外部链接。
- [Lecture 14 image-reference: d3i71xaburhd42.cloudfront.net](https://d3i71xaburhd42.cloudfront.net/4566c0d22ebf3c31180066ab23b6c445aeec78d5/5-Table1-1.png)：`image-reference`，外部链接。
- [Lecture 14 image-reference: huggingfacefw-finepdfsblog.hf.space](https://huggingfacefw-finepdfsblog.hf.space/_astro/pdf-description.Cb49jXc6_Z17eX4E.webp)：`image-reference`，外部链接。
- [Lecture 14 image-reference: stanford-cs324.github.io](https://stanford-cs324.github.io/winter2022/lectures/images/the-pile.png)：`image-reference`，外部链接。

**official-video**

- [Lecture 14 official YouTube recording](https://www.youtube.com/watch?v=5sxHosTLPF8)：`official-video`，外部链接。

### Lecture 15: Mid/post-training (SFT/RLHF)

- 日期：`Mon May 18`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=2oH6PWPrYFo)；时长：`1:19:55`。
- 对齐材料：[lecture_15.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_15.pdf)。

**PDF lecture material**

- [Lecture 15 official lecture_15.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_15.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 15 official YouTube recording](https://www.youtube.com/watch?v=2oH6PWPrYFo)：`official-video`，外部链接。

### Lecture 16: Post-training - RLVR

- 日期：`Wed May 20`；讲者：`Tatsu`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=dIFAi87Ws4E)；时长：`1:15:51`。
- 对齐材料：[lecture_16.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_16.pdf)。

**PDF lecture material**

- [Lecture 16 official lecture_16.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_16.pdf)：`slides`，本地归档。

**official-video**

- [Lecture 16 official YouTube recording](https://www.youtube.com/watch?v=dIFAi87Ws4E)：`official-video`，外部链接。

### Lecture 17: Alignment - multimodality

- 日期：`Wed May 27`；讲者：`Percy`。
- 来源状态：`recorded-with-materials`。
- 录像：[YouTube](https://www.youtube.com/watch?v=26FtD08ZpOU)；时长：`1:17:40`。
- 对齐材料：[lecture_17.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_17.py)。

**Executable lecture source**

- [Lecture 17 official lecture_17.py](/assets/courses/stanford-cs336-s26/materials/official-materials/lectures/lecture_17.py)：`lecture-code`，本地归档。

**Rendered executable lecture**

- [Lecture 17 rendered trace](https://cs336.stanford.edu/lectures/?trace=lecture_17)：`lecture-rendering`，外部链接。

**Compiled trace**

- [Lecture 17 compiled trace JSON](/assets/courses/stanford-cs336-s26/materials/official-materials/traces/lecture_17.json)：`lecture-trace`，本地归档。

**Papers**

- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2103.00020.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2212.07143.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2303.15343.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2304.08485.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2308.12966.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2309.17425.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2406.04334.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2409.12191.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2511.21631.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/1711.00937.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2010.11929.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2203.13131.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2209.06794.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2405.09818.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2408.03326.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: arxiv.org](https://arxiv.org/pdf/2502.14786.pdf)：`paper`，本地归档；保留原始失效/受限链接。
- [Lecture 17 paper: static.hliu.cc](https://static.hliu.cc/files/llava/improved_llava.pdf)：`paper`，本地归档。

**Other readings**

- [Lecture 17 reading: www.lmsys.org](https://www.lmsys.org/blog/2023-03-30-vicuna/)：`reading`，外部链接。

**Code and tools**

- [Lecture 17 code-reference: github.com](https://github.com/openai/CLIP/blob/main/clip/clip.py#L79)：`code-reference`，外部链接。

**official-video**

- [Lecture 17 official YouTube recording](https://www.youtube.com/watch?v=26FtD08ZpOU)：`official-video`，外部链接。

### Lecture 18: Guest lecture: Daniel Selsam

- 日期：`Mon June 1`；讲者：`未注明`。
- 来源状态：`scheduled-source-missing`。
- 录像：当前官方 playlist 未提供。
- 对齐材料：课程页与 lecture repository 当前均未提供。
- 处理边界：保留为 schedule 缺口，不生成虚构 transcript 或课堂笔记。

### Lecture 19: Guest lecture: Dan Fu

- 日期：`Wed June 3`；讲者：`未注明`。
- 来源状态：`recorded-transcript-only`。
- 录像：[YouTube](https://www.youtube.com/watch?v=9EEm4iMAF5s)；时长：`1:11:41`。
- 对齐材料：无，后续明确按 transcript-only 处理。

**official-video**

- [Lecture 19 official YouTube recording](https://www.youtube.com/watch?v=9EEm4iMAF5s)：`official-video`，外部链接。


## Assignments

### Assignment 1: Basics

- 发布：`Mon March 30`（Lecture 1）。
- 截止：`Wed April 15`（Lecture 6）。
- [Assignment 1 official repository](https://github.com/stanford-cs336/assignment1-basics/tree/main)：`assignment-repository`，外部链接。
- [Assignment 1 repository snapshot](https://codeload.github.com/stanford-cs336/assignment1-basics/zip/refs/heads/main)：`code-archive`，本地归档。
- [Assignment 1 README](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/README.md)：`assignment-guide`，本地归档。
- [Assignment 1 AGENTS policy](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/AGENTS.md)：`assignment-policy`，本地归档。
- [Assignment 1 handout: cs336_assignment1_basics.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment1-basics/cs336_assignment1_basics.pdf)：`homework`，本地归档。

### Assignment 2: Systems

- 发布：`Wed April 15`（Lecture 6）。
- 截止：`Wed April 29`（Lecture 10）。
- [Assignment 2 official repository](https://github.com/stanford-cs336/assignment2-systems/tree/main)：`assignment-repository`，外部链接。
- [Assignment 2 repository snapshot](https://codeload.github.com/stanford-cs336/assignment2-systems/zip/refs/heads/main)：`code-archive`，本地归档。
- [Assignment 2 README](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/README.md)：`assignment-guide`，本地归档。
- [Assignment 2 AGENTS policy](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/AGENTS.md)：`assignment-policy`，本地归档。
- [Assignment 2 handout: cs336_assignment2_systems.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment2-systems/cs336_assignment2_systems.pdf)：`homework`，本地归档。

### Assignment 3: Scaling

- 发布：`Wed April 29`（Lecture 10）。
- 截止：`Wed May 6`（Lecture 12）。
- [Assignment 3 official repository](https://github.com/stanford-cs336/assignment3-scaling/tree/main)：`assignment-repository`，外部链接。
- [Assignment 3 repository snapshot](https://codeload.github.com/stanford-cs336/assignment3-scaling/zip/refs/heads/main)：`code-archive`，本地归档。
- [Assignment 3 README](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/README.md)：`assignment-guide`，本地归档。
- [Assignment 3 AGENTS policy](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/AGENTS.md)：`assignment-policy`，本地归档。
- [Assignment 3 handout: cs336_assignment3_scaling.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment3-scaling/cs336_assignment3_scaling.pdf)：`homework`，本地归档。

### Assignment 4: Data

- 发布：`Wed May 6`（Lecture 12）。
- 截止：`Wed May 20`（Lecture 16）。
- [Assignment 4 official repository](https://github.com/stanford-cs336/assignment4-data/tree/main)：`assignment-repository`，外部链接。
- [Assignment 4 repository snapshot](https://codeload.github.com/stanford-cs336/assignment4-data/zip/refs/heads/main)：`code-archive`，本地归档。
- [Assignment 4 README](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/README.md)：`assignment-guide`，本地归档。
- [Assignment 4 AGENTS policy](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/AGENTS.md)：`assignment-policy`，本地归档。
- [Assignment 4 handout: cs336_assignment4_data.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment4-data/cs336_assignment4_data.pdf)：`homework`，本地归档。

### Assignment 5: Alignment and Reasoning RL

- 发布：`Wed May 20`（Lecture 16）。
- 截止：`Wed June 3`（Lecture 19）。
- [Assignment 5 official repository](https://github.com/stanford-cs336/assignment5-alignment/tree/main)：`assignment-repository`，外部链接。
- [Assignment 5 repository snapshot](https://codeload.github.com/stanford-cs336/assignment5-alignment/zip/refs/heads/main)：`code-archive`，本地归档。
- [Assignment 5 README](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/README.md)：`assignment-guide`，本地归档。
- [Assignment 5 AGENTS policy](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/AGENTS.md)：`assignment-policy`，本地归档。
- [Assignment 5 handout: cs336_spring2026_assignment5_alignment.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/cs336_spring2026_assignment5_alignment.pdf)：`homework`，本地归档。
- [Assignment 5 handout: cs336_spring2026_assignment5_supplement_safety_rlhf.pdf](/assets/courses/stanford-cs336-s26/materials/official-materials/assignments/assignment5-alignment/cs336_spring2026_assignment5_supplement_safety_rlhf.pdf)：`homework`，本地归档；保留原始失效/受限链接。

## 使用边界

1. Executable lecture 的 `.py` 保留课堂文本、代码和引用；compiled trace JSON 用于核查实际渲染顺序，但当前对齐器只把 `.py` 作为文本材料。
2. PDF lecture 按页面提取文字与渲染图，并从 hyperlink annotations 建立 references 索引。
3. 论文列表表示课堂材料引用，不自动等于 assigned reading；阅读优先级应结合讲次 NOTES 再整理。
4. Assignment repository ZIP、handout、README、AGENTS 均用于个人学习与复现；本路线不提供作业答案，也不绕过课程 AI policy。
5. Lecture 18 的缺口与 Lecture 19 的 transcript-only 状态必须在最终课程总结中持续可见。
