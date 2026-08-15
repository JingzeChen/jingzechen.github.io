---
uid: cmu-11785-s26-resource-practice-2
type: course
document_type: resource
resource_kind: practice
resource_order: 2
course: cmu-11785-s26
title: CMU 11-785 S26 Practice Route
description: 按 Recitation、Lab、Bootcamp、Hackathon 与 Assignment 组织完整实践路线。
excerpt: 按 Recitation、Lab、Bootcamp、Hackathon 与 Assignment 组织完整实践路线。
content_lang: zh-CN
permalink: "/courses/cmu-11785-s26/practice/"
toc: true
---

本路线只覆盖官方已公开的课前 Recitation、学期内 Lab、Bootcamp/Hackathon 和 Assignment 入口，目标是把实践材料按学习阶段串起来，而不是重写课程主页。

## 使用边界

- 本文件只依据 [课程材料索引](/courses/cmu-11785-s26/materials/)、[结构化材料索引](/assets/courses/cmu-11785-s26/metadata/materials-index.json)、[来源 Manifest](/assets/courses/cmu-11785-s26/metadata/source-manifest.json)、以及官方归档的 schedule 页面组织路线。
- Autolab、Piazza、YouTube、MediaService、Colab、Google Drive、GitHub 目录页等都属于外部资源；其中部分内容需要登录、课程权限或额外网络访问。本地仓库只保留公开入口，不镜像登录后内容。
- 本文件不提供作业答案，不推断隐藏测试，不补写教师未公开的作业要求，也不从 Piazza 讨论串反推 rubric。
- 只有在 schedule 顺序或资源标题已经明确支持时，才把 notebook、slides、dataset、video 连接到对应 lecture 主题；不能从时间上或文件名上合理支持的内容，只保留为工作流或项目辅助资源。

## 全局盘点

- 课前 Recitation：28 个，全部在 Lecture 01 之前，建议按 `0.1 -> 0.28` 完整走一遍。
- 学期内 Lab：15 个，覆盖 MLP、调试、autograd、CNN、RNN、CTC、Attention、Transformer、VAE、Diffusion、GAN、GNN。
- Bootcamp/Hackathon：15 个，含 4 次与 HW 配套的 Bootcamp、1 次 Guided Project Bootcamp、4 次 HW debrief/deployment、5 次一般 Hackathon、1 次取消场次。
- Assignment 组：14 个，分别是 HW1 4 组、HW2 4 组、HW3 4 组、HW4 2 组。

## 先修要求

- 编程先修：Python、面向对象、NumPy、PyTorch、notebook 与环境管理。
- 工具先修：GitHub、Colab、云算力、PSC、Kaggle、数据集处理、数据预处理、保存与加载模型。
- 理论先修：Lecture 01-08 后再进入早期 Lab；Lecture 09-12 后再进入 CNN 相关 Lab/HW2；Lecture 13-20 后再进入序列与 Transformer 相关 Lab/HW3；Lecture 21-28 后再进入生成模型与图模型相关 Lab/HW4。

## 建议顺序

1. 先完成全部 28 个课前 Recitation，确保环境、数据、调试和作业工作流不再成为阻塞。
2. 按 lecture 相邻阶段推进 Lab 和 Bootcamp，不跳阶段做后面的模型类实验。
3. Assignment 只把官方入口纳入清单；真正开做前，先回到对应 Bootcamp、Lab 和 lecture slides 复习。
4. 每一阶段先看 lecture slides，再跑 notebook，再看公开视频；只有需要登录的外部站点，放到最后处理。

## Phase 0: 课前基础与工作流打底

适用 lecture：为 [Lecture 01](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec1.intro.pdf) 到 [Lecture 08](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec8.optimizersandregularizers.pdf) 的全部早期训练内容做工程准备。

### A. Python / PyTorch 基础 6 个 Recitation

- Rec 0.1 Python Fundamentals: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.01/Python_basics_with_numpy.ipynb) | [Video](https://youtu.be/LxbiGktyNlk?si=xohXkkMQikG8_laH)。先修：无。用途：为后续所有 notebook 打基础。
- Rec 0.2 Object Oriented Programming (OOP) Fundamentals: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.02/OOP_Fundamentals.ipynb) | [Video](https://youtu.be/eZl2XPexRcY?si=BIZVfdxlPDr5BcAx)。先修：0.1。用途：读写课程代码结构。
- Rec 0.3 NumPy Fundamentals: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.03/Rec_0_3_NumPy_Fundamentals_S26.ipynb) | [Video](https://youtu.be/4MwcHkV0BN4?si=cAkGAkwWgjZoykE_)。先修：0.1。用途：支撑线性代数和张量操作。
- Rec 0.4 PyTorch: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.04/Recitation_0_4_PyTorch.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.04/Recitation 0.4 - PyTorch.pdf) | [Video](https://youtu.be/JodKOum4YrM?si=dA8gRiedAsZu9YkY)。先修：0.1-0.3。对应 lecture：01-08 的核心实现工具。
- Rec 0.5 Notebooks and Conda Environments: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.05/notebook_example.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.05/S2026_Rec0_Env_Ipynb_Slides.pptx) | [Video](https://youtu.be/IV88elV38qk?si=vwL2n-uWTKSShJuG)。先修：0.1。用途：减少环境问题。
- Rec 0.6 Tensordot & Einsum: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.06/0_6_Tensordot_&_Einsum.ipynb) | [Notes](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.06/0_6_Tensordot_&_Einsum.pdf) | [Video](https://youtu.be/ZArvnLcYwWM?si=lbWw2OtKKI2uEHjX)。先修：0.3-0.4。对应 lecture：03-08 的矩阵与梯度计算背景。

### B. 计算资源与协作工具 7 个 Recitation

- Rec 0.7 GitHub: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.07/Git_Github_CheatSheet.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.07/Recitation 0.7 Git_Github.pptx) | [Video](https://youtu.be/oNQ2YeWf86I?si=uwrUw4Zb11dzGq18)。先修：0.1。用途：作业和项目协作。
- Rec 0.8 Google Colab: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.08/Google_colab_recitation_0_8.ipynb) | [Video](https://youtu.be/CH4G-IodPMo?si=AnrtQyT9x-NDv_16)。先修：0.5。用途：外部算力备用。
- Rec 0.9 Google Cloud Platform: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.09/0_9_Google_Cloud_Platform_VM_Setup.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.09/0_9_Google_Cloud_Platform_Slides.pdf) | [Video](https://youtu.be/kBB2Q-9W3DY?si=J9KEaZiuAc-YCnnp)。先修：0.5。用途：云端环境。
- Rec 0.10 Amazon Web Services (AWS): [Video](https://youtu.be/0aLGh2GojX4?si=IJsPczvR32rT5jNl)。先修：0.5。用途：替代云资源路线。
- Rec 0.11 Kaggle: [Video](https://youtu.be/Fwbktrtw-PM?si=Xlr64H7lIwnGlQCc)。先修：0.5。用途：为后续 Lab 8 和 leaderboard 工作流做准备。
- Rec 0.12 PSC - I (How to connect): [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.12/S2026_Rec0_PSC_connection.pptx) | [Guide](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.12/PSC Usage Guide 2026spring.docx) | [Video](https://youtu.be/ZBnwDnvsW2o?si=8bRblSpOAveEU8tk)。先修：0.5。用途：课程提供算力接入。
- Rec 0.13 PSC - II (How to get project resources): [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.13/S2026_Rec0_PSC_project.pptx) | [Video](https://youtu.be/g8MxlZPLqTw?si=Rq0zyvEEUstnIfoM)。先修：0.12。用途：项目资源配置。

### C. 数据处理与实验卫生 10 个 Recitation

- Rec 0.14 Datasets: [Notebook Part 1](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.14/0_14_Datasets_Part_1.ipynb) | [Notebook Part 2](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.14/0_14_Datasets_Part_2.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.14/IDL Recitation - Datasets.pptx.pdf) | [Dataset](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.14/Recitation_0.14_data.zip) | [Video](https://youtu.be/wg7D_YRbsEg?si=iMmtNPAwl02ujW9h)。先修：0.3-0.5。对应 lecture：09-12 前的数据入口。
- Rec 0.15 Dataloaders: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.15/Dataloaders.ipynb) | [Video](https://youtu.be/vfV1XYyN92s?si=I4dxBYgqdfyCe3td)。先修：0.14。对应 lecture：09-12 与所有 mini-batch 训练。
- Rec 0.16 Data Preprocessing: [Notebook Part 1](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.16/0_16_Data_Preprocessing_Part_1.ipynb) | [Notebook Part 2](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.16/0_16_Data_Preprocessing_Part_2.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.16/Data Preprocessing Spring 26.pptx) | [Video 1](https://youtu.be/JJwzrEeHg_0?si=BiGorn5C6HpviXQz) | [Video 2](https://youtu.be/vz_6DfVvrqM?si=V-ehKsZHMlsvH3pG) | [Video 3](https://youtu.be/gJ_4r4edZV8?si=DEz_0qXTOBhmSGb7)。先修：0.14-0.15。对应 lecture：08、09-12。
- Rec 0.17 Weights and Biases (WandB): [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.17/0.17_WandB.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.17/Intro to Wandb.pdf) | [Video](https://youtu.be/-HziF0qn8-w?si=Pu-j16m8PgXvfwUq)。先修：0.4-0.5。对应 lecture：06-08 的实验追踪。
- Rec 0.18 Debugging: [Video](https://youtu.be/ukbTKEboqGc?si=6vxiFm8BLVRZtp0P)。先修：0.4-0.5。对应 lecture：03-08 和早期 HW。
- Rec 0.19 What to Do When Struggling: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.19/S26_Rec-0.19_Struggling.pptx.pdf) | [Video](https://youtu.be/d3xuVuzonEc?si=QA3QqfSvFPgfggbv)。先修：无。用途：作为排障流程。
- Rec 0.20 Losses Part 1: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.20/0_20_Losses_Part_1.ipynb) | [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.20/S26_Rec0.20_Losses_Part1.pptx.pdf) | [Video](https://youtu.be/HzIgt-rSdg0)。先修：Lecture 03-05。对应 lecture：03-08。
- Rec 0.21 Losses Part 2: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.21/Loss Functions 2.0-FINAL.pdf) | [Video](https://youtu.be/RCo1QhIZduI?si=lZrdUmaAg4dln5bP)。先修：0.20。对应 lecture：08。
- Rec 0.22 Block Processing: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.22/0_22_Block_Processing.ipynb) | [Video](https://youtu.be/89tXQLFRpfs?si=a8Kv1HN_mm2cjqGD)。先修：0.3-0.6。对应 lecture：09-18 需要张量重排的内容。
- Rec 0.23 Pipeline: [Video](https://youtu.be/TGEBH6H3om4?si=XHmZ6snlZFZ-NXnc)。先修：0.7、0.14-0.18。用途：模型训练流水线视角。

### D. 分布式、模型持久化与课程工作流 5 个 Recitation

- Rec 0.24 Distributed Training: [GitHub Notebook Directory](https://github.com/CMU-IDeeL/CMU-IDeeL.github.io/blob/master/S26/documents/recitation_0/0.24/) | [Video](https://youtu.be/U34Ce_5UCHw?si=v0xBKS0wg-qQ_P3s)。先修：0.4、0.12-0.13。对应 lecture：优化以后、项目以前的工程扩展。
- Rec 0.25 Saving & Loading Models: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.25/rec0_25_Saving_&_Loading_Model.ipynb) | [Slides](https://deeplearning.cs.cmu.edu/S26/documents/recitation_0/0.25/Saving%20and%20Loading%20Model.pptm) | [Video](https://youtu.be/LgSIsXCBZsc?si=w9iA2-g4EIkpKD1L)。先修：0.4。对应 lecture：所有阶段。
- Rec 0.26 Workflow of HWs - Part 1s: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.26/Recitation 0.26_Workflows of HW part 1s.pdf) | [Video](https://youtu.be/RkYj-K7ec1c?si=F5-TA2Hsa3vms7gx)。先修：0.7、0.17-0.19。用途：HW Part 1 工作流。
- Rec 0.27 Workflow of HWs - Part 2s: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.27/0.27 Workflow of HWP2s.pptx) | [Video](https://youtu.be/K8R8xQQf2Ro?si=LtWZAOGF2iOY6WrU)。先修：0.26。用途：HW Part 2 工作流。
- Rec 0.28 Workflow of Project: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/recitation_0/0.28/Flow-of-the-Project.pdf) | [Video](https://youtu.be/pkW_y2OV6gU)。先修：0.7、0.12-0.13。用途：课程 project 组织方式。

### Phase 0 Completion Checklist

- [ ] 28 个 Recitation 全部过一遍，至少打开并检查所有本地 notebook / slides / dataset 链接。
- [ ] 能独立配置本地或云端环境，并理解 GitHub、PSC、Colab 至少一条工作链。
- [ ] 能解释 dataloader、preprocessing、loss、debugging、WandB、checkpoint 的基本用途。
- [ ] 在进入 Lab 1 之前，PyTorch、环境、数据和作业工作流不再是主要阻塞。

## Phase 1: MLP 与优化基础

适用 lecture： [Lecture 01](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec1.intro.pdf)、[Lecture 02](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec2.universal.pdf)、[Lecture 03](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec3.learning.pdf)、[Lecture 04](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec4.learning.pdf)、[Lecture 05](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec5.BP.pdf)、[Lecture 06](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec6_convergence.pdf)、[Lecture 07](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec7.stochastic_gradient.pdf)、[Lecture 08](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec8.optimizersandregularizers.pdf)。

### Labs 4 个

- Lab 1 Your First MLP: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_1/S26_Lab1_Your_First_MLP.ipynb) | [YouTube](https://youtu.be/Lo4TuItUPv8) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+1/1_aojmzvt4/397642153)。建议顺序：Lecture 01-03 后。
- Lab 2 Debugging: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_2/S26_Lab_2_Student_Notebook.ipynb) | [Dataset](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_2/data.zip) | [YouTube](https://youtu.be/5UWYS1ePizk) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+2/1_bf3uib7c/397642153)。建议顺序：Lab 1 后，搭配 Rec 0.18-0.19。
- Lab 3 Ablations, Hyperparameter Tuning Methods, Normalizations: [Colab Notebook](https://colab.research.google.com/drive/1M9HnzB_xj-aAyoY2mNXsAVsScaUvYI-e?usp=sharing) | [Dataset](https://drive.google.com/uc?id=1pms9NiNlQhqzightGFHJ-LqN_RxhgWJk) | [YouTube](https://youtu.be/OtMVc_2od1s) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+3/1_sldnhszv/397642153)。建议顺序：Lecture 06-08 后。
- Lab 4 Computing Derivatives and Autograd: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_4/IDL_Lab4_Computing_Derivatives_Autograd_20250918.pptx) | [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_4/IDL_S26_Lab_4_Computing_Derivatives_&_Autograd(Students).ipynb) | [YouTube](https://youtu.be/OKz6iuta6u4) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+4/1_s3pmqt5n/397642153)。建议顺序：Lecture 04-05 后。

### Bootcamp / Hackathon 3 个

- Hackathon 1 + HW1 Bootcamp: [HW1 Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw1/Bootcamp_HW1.pdf) | [HW1P2 Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw1/S26_Bootcamp_HW1P2.pptx.pdf) | [YouTube](https://youtu.be/DBuCm2yO-nw) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+HW1P1+Bootcamp/1_ljbifejs/397642153)。按 schedule 与 HW1 同步推进。
- Hackathon 2: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；manifest 未归档额外 notebook/slides/video。
- Hackathon 3: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；manifest 未归档额外 notebook/slides/video。

### Assignment 4 组

- HW1P1: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW1P1) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/21)。外部-only，可能需要登录。
- HW1P2: [Autolab Checkpoint](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/hw1p2checkpoint) | [Autolab Final](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/hw1p2final) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/13)。外部-only，可能需要登录。
- HW1P1 Bonus: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW1P1-Bonus) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/18)。外部-only，可能需要登录。
- HW1P1 Autograd: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW1-Autograd) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/18)。外部-only，可能需要登录。

### Phase 1 Completion Checklist

- [ ] 按 Lecture 01-08 顺序完成 4 个早期 Lab。
- [ ] 在打开 HW1 前复习 Rec 0.17-0.27 和 Hackathon 1 的材料。
- [ ] 不从 Autolab 隐藏测试、Piazza 私有讨论或 checkpoint/final 差异推断未公开要求。

## Phase 2: CNN 与中期训练工程

适用 lecture： [Lecture 09](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec9.CNN1.pdf)、[Lecture 10](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec10.CNN2.pdf)、[Lecture 11](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec11.CNN3.pdf)、[Lecture 12](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec12.CNN4.pdf)。

### Labs 2 个

- Lab 5 CNN: Basics and Backprop: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_5/CNN_Basics_Student_Notebook.ipynb) | [YouTube](https://youtu.be/ND7yM2VnttM) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+5/1_ewvqr2v6/397642153)。建议顺序：Lecture 09-10 后。
- Lab 6 CNN: Classification and Verification: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_6/S26_CNN_lab06.ipynb) | [YouTube](https://youtu.be/2i_ecR9HoSc) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+CNN+Classification+and+Verification/1_we5vcvx5/397642153)。建议顺序：Lab 5 后。

### Bootcamp / Hackathon 3 个

- Hackathon 4 + HW2 Bootcamp: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw2/S26-HW2P2-BOOTCAMP.pdf) | [YouTube](https://youtu.be/l_uMjxkPJY0) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+HW2+Bootcamp/1_s4f6l42r/397642153)。按 schedule 与 HW2 同步推进。
- Hackathon 5 HW 1 Debrief & Deployment: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；更适合做复盘，而不是新增 CNN 先修。
- Hackathon 6 + Guided Project Bootcamp: [EEG Project Deck](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/guided_project/EEG_Presentation.pptx.pdf) | [Diffusion Project Deck](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/guided_project/Diffusion_presentation_S26.pptx.pdf) | [YouTube](https://youtu.be/kmCU56iUIdA) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Bootcamp+guided+Project+-+Latent+Denoising+Diffusion+Probablistic+Models/1_eb1do2rs/397642153)。由于 schedule 时间早于 Lecture 23，建议只把它当 project workflow 范例，不把其中 diffusion deck 强行绑定到生成模型阶段先修。

### Assignment 4 组

- HW2P1: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/hw2p1-test) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/273)。外部-only，可能需要登录。
- HW2P2: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/TEST-HW2P2-Code-Submission) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/247)。外部-only，可能需要登录。
- HW2P1 Bonus: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW2P1-Bonus) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/256)。外部-only，可能需要登录。
- HW2P1 Autograd: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW2-Autograd) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/256)。外部-only，可能需要登录。

### Phase 2 Completion Checklist

- [ ] 在 HW2 前完成 Lab 5 和 Lab 6，并回看 Rec 0.14-0.16、0.22、0.25。
- [ ] Guided Project Bootcamp 只作为项目范例，不把时间上不相邻的扩展主题当作课程硬先修。
- [ ] HW2 的所有 requirements 只以官方 slides、assignment page、公开 notebook 为准，不猜测隐藏 case。

## Phase 3: 序列建模、CTC、Attention 与 Transformer

适用 lecture： [Lecture 13](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec13.recurrent.pdf)、[Lecture 14](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec14.recurrent.pdf)、[Lecture 15](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec15.recurrent.pdf)、[Lecture 16](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec16.recurrent.pdf)、[Lecture 17](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec17.recurrent.pdf)、[Lecture 18](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec18.attention.pdf)、[Lecture 19](/assets/courses/cmu-11785-s26/materials/official-materials/slides/L19-Transformer.pdf)、[Lecture 20](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec20.llm.pdf)。

### Labs 5 个

- Lab 7 RNN Basics: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_7/S26_StudentNotebook_RNN_Lab_7.ipynb) | [YouTube](https://youtu.be/PtGjtSj9WBA) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+7/1_6ka3t91f/397642153)。建议顺序：Lecture 13-14 后。
- Lab 8 Kaggle Workshop and Pre-trained models: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_8/Lab8_Notebook.ipynb) | [YouTube](https://youtu.be/Hao43kDaorI) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab_8_Kaggleworkshop_and_pretrainedmodels/1_czp8tlui/397642153)。建议顺序：Lab 7 后；它更偏 workflow 与 pretrained usage。
- Lab 9 CTC and Beam Search: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_9/S26 Lab 9 CTC loss, Beam search.pdf) | [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_9/S26 lab9_student_notebook.ipynb) | [YouTube](https://youtu.be/DydSVuaphoI) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+9/1_bl74d0yu/397642153)。建议顺序：Lecture 15-16 后。
- Lab 10 Attention, MT, LAS: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_10/Student_Notebook_Lab_10.ipynb) | [YouTube](https://youtu.be/D-6wFYsk3Rs) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-Lab+10/1_c6jsiqqm/397642153)。建议顺序：Lecture 17-18 后。
- Lab 11 Transformers: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_11/Lab_11_Transformers_S26_Student_Version.ipynb) | [YouTube](https://youtu.be/PrMj5roH7VM) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-Lab+11/1_dwtxlrai/397642153)。建议顺序：Lecture 18-20 后。

### Bootcamp / Hackathon 4 个

- Hackathon 7 + HW3 Bootcamp: [HW3P1 Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw3/S26_HW3P1_Bootcamp.pdf) | [HW3P2 Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw3/S26_HW3P2_Bootcamp.pdf) | [YouTube](https://youtu.be/p5qrOKHwuW0) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+HW3P1+Bootcamp/1_7xufxy8b/397642153)。按 schedule 与序列模型阶段同步。
- Hackathon 8: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；manifest 未归档额外 notebook/slides/video。
- Hackathon 9 HW 2 Debrief & Deployment: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；用途是中期复盘。
- Hackathon 10: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；manifest 未归档额外 notebook/slides/video。

### Assignment 4 组

- HW3P1: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW3P1) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/484)。外部-only，可能需要登录。
- HW3P2: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/hw3p2codesubmission) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/516)。外部-only，可能需要登录。
- HW3P1 Bonus: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW3P1-Bonus) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/513)。外部-only，可能需要登录。
- HW3P1 Autograd: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW3-Autograd) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/513)。外部-only，可能需要登录。

### Phase 3 Completion Checklist

- [ ] 按 RNN -> CTC/Beam -> Attention/LAS -> Transformer 的顺序完成 Lab 7-11。
- [ ] 只在 lecture 标题和 lab 标题都明确支持时，才把实验当成该 lecture 的直接实践延伸。
- [ ] HW3 开始前回看 Rec 0.20-0.25、Lab 7-11 和 Hackathon 7。

## Phase 4: 表征学习、生成模型、图模型与课程收束

适用 lecture： [Lecture 21](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec21.representations.pdf)、[Lecture 22](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec22.VAE.pdf)、[Lecture 23](/assets/courses/cmu-11785-s26/materials/official-materials/slides/Diffusion_S26_MB_V2.pdf)、[Lecture 24](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lec24_GAN.pdf)、[Lecture 25](/assets/courses/cmu-11785-s26/materials/official-materials/slides/Lec25 - Graph Neural Networks.pdf)、[Lecture 26](/assets/courses/cmu-11785-s26/materials/official-materials/slides/Reinforcement_Learning_S26.pdf)、[Lecture 27](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lecture_25_Hopfield_S26.pdf)、[Lecture 28](/assets/courses/cmu-11785-s26/materials/official-materials/slides/lecture_26_BM_S26.pdf)。

### Labs 4 个

- Lab 12 Variational Autoencoders: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_12/IDL_Recitation_AE_and_VAE_2026.pdf) | [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_12/Lab12_AEs&VAEs.ipynb) | [YouTube](https://youtu.be/zYEcC3yFe-o) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+12/1_biljqmjc/397642153)。建议顺序：Lecture 21-22 后。
- Lab 13 NF and Stable Diffusion: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_13/Normalizing Flows.pdf) | [Diffusion Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_13/Diffusion_lab13_S26.ipynb) | [Stable Diffusion Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_13/Stable_diffusion S26.ipynb) | [NF Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_13/Student_NF_S26.ipynb) | [YouTube](https://youtu.be/zZlmC5hM_tw) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-Lab+13/1_cohv2wyp/397642153)。建议顺序：Lecture 23 后。
- Lab 14 GAN: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_14/S26_lab14_GANs_StudentNotebook.ipynb) | [Guide](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_14/GAN Lab 14.pdf) | [YouTube](https://youtu.be/OMKVfa6pndM) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-+Lab+14/1_19keerzp/397642153)。建议顺序：Lecture 24 后。
- Lab 15 Graph Neural Networks: [Notebook](/assets/courses/cmu-11785-s26/materials/official-materials/labs/lab_15/GNN_Recitation_student.ipynb) | [YouTube](https://youtu.be/mJKCnkD9FEM)。建议顺序：Lecture 25 后；schedule 中未归档 MediaService 备链。

### Bootcamp / Hackathon 5 个

- Hackathon 11 + HW4 Bootcamp: [Slides](/assets/courses/cmu-11785-s26/materials/official-materials/bootcamps/hw4/HW4_P1_Bootcamp.pdf) | [YouTube](https://youtu.be/VGHF9BVq7vc) | [MediaService](https://mediaservices.cmu.edu/media/Introduction+to+Deep+Learning+-+Spring+2026+-3_28_Bootcamp/1_3gi2bm4x/397642153)。按 schedule 与 HW4 同步推进。
- Hackathon 12 HW 3 Debrief & Deployment: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；用途是复盘，不是新增生成模型先修。
- Hackathon 13 Canceled due to Spring Carnival: 见 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html)；这是 schedule 中明确取消的场次，应计入总数但不安排额外实践。
- Hackathon 14: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；manifest 未归档额外 notebook/slides/video。
- Hackathon 15 HW 4 Debrief & Deployment: 仅有 [官方 recitation/lab 表](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html) 中的 schedule 记录；用于课程收尾复盘。

### Assignment 2 组

- HW4P1: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/HW4P1) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/676)。外部-only，可能需要登录。
- HW4P2: [Autolab](https://autolab.andrew.cmu.edu/courses/11485-s26/assessments/TEST-HW4P2-Code-Submission) | [Piazza](https://piazza.com/class/mjnqcfnm4ci4v1/post/671)。外部-only，可能需要登录。

### Phase 4 Completion Checklist

- [ ] 先做 Lab 12，再做 Lab 13 和 Lab 14，最后做 Lab 15。
- [ ] 不把 Lecture 26-28 强行绑定到现有 lab；manifest 中没有与 RL、Hopfield、Boltzmann 一一对应的单独 lab。
- [ ] HW4 只以官方 Bootcamp、Autolab、Piazza 和公开 slides 为依据，不扩写未公开要求。

## 最终完成标准

- [ ] 28 个 Recitation 已全部覆盖且只在本文件中登记一次。
- [ ] 15 个 Lab 已全部覆盖且只在本文件中登记一次。
- [ ] 15 个 Bootcamp/Hackathon 已全部覆盖且只在本文件中登记一次。
- [ ] 14 个 Assignment 组已全部覆盖且只在本文件中登记一次。
- [ ] 任何需要登录的资源都被清楚标注为 external-only。
- [ ] 全路线没有作业答案、没有隐藏要求推断、没有把不受 schedule 支持的材料硬绑到 lecture。

## 快速入口

- 课程总索引：[MATERIALS.md](/courses/cmu-11785-s26/materials/)
- 结构化索引：[materials-index.json](/assets/courses/cmu-11785-s26/metadata/materials-index.json)
- 来源清单：[source-manifest.json](/assets/courses/cmu-11785-s26/metadata/source-manifest.json)
- 讲次表：[official-materials/course-pages/lectures_table.html](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/lectures_table.html)
- Recitation / Lab / Hackathon 表：[official-materials/course-pages/recitations.html](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/recitations.html)
- Assignment 表：[official-materials/course-pages/assignments_table.html](/assets/courses/cmu-11785-s26/materials/official-materials/course-pages/assignments_table.html)
