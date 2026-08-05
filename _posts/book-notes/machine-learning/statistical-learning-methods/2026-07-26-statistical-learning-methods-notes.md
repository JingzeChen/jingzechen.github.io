---
title: "《统计学习方法（第 2 版）》读书笔记"
date: 2026-07-26 00:00:00 +0800
updated: 2026-08-02
uid: statistical-learning-methods-notes
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning, books]
series: statistical-learning-methods
series_order: 1
featured: true
why_start_here: 用一张持续维护的知识索引串联监督学习、无监督学习与核心数学工具。
related:
  - statistical-learning-methods-ch01-introduction
  - statistical-learning-methods-ch02-perceptron
  - statistical-learning-methods-ch03-k-nearest-neighbors
  - statistical-learning-methods-ch04-naive-bayes
  - statistical-learning-methods-ch05-decision-tree
  - statistical-learning-methods-ch06-logistic-regression-maximum-entropy
  - statistical-learning-methods-ch07-support-vector-machines
  - statistical-learning-methods-ch08-boosting
  - statistical-learning-methods-ch09-em-algorithm
  - statistical-learning-methods-ch10-hidden-markov-models
  - statistical-learning-methods-ch11-conditional-random-fields
  - statistical-learning-methods-ch12-supervised-learning-summary
  - statistical-learning-methods-ch13-unsupervised-learning-introduction
  - statistical-learning-methods-ch14-clustering
  - statistical-learning-methods-ch15-singular-value-decomposition
  - statistical-learning-methods-ch16-principal-component-analysis
  - statistical-learning-methods-ch17-latent-semantic-analysis
  - statistical-learning-methods-ch18-probabilistic-latent-semantic-analysis
  - statistical-learning-methods-ch19-markov-chain-monte-carlo
  - statistical-learning-methods-ch20-latent-dirichlet-allocation
  - statistical-learning-methods-ch21-pagerank
  - statistical-learning-methods-ch22-unsupervised-learning-summary
  - statistical-learning-methods-appendices-math-tools
categories: [读书笔记, 机器学习, 统计学习方法]
tags: [statistical-learning, machine-learning, reading-notes]
description: 《统计学习方法（第 2 版）》的学习索引、章节进度与核心概念地图。
toc: true
math: true
---

> 目标：不仅记录“是什么”，还要说明“为什么这样定义、如何推导、各概念如何衔接”。
>
> 记号说明：本笔记统一使用标准数学记号，并对原始 Markdown 中因 OCR 造成的公式错位进行了校正。
>
> 章节正文按章存放在同名子目录中，本文件作为阅读进度和导航目录。

## 阅读进度

- [x] [第 1 章 统计学习及监督学习概论]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-07-26-statistical-learning-methods-ch01-introduction %})
- [x] [第 2 章 感知机]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-07-26-statistical-learning-methods-ch02-perceptron %})
- [x] [第 3 章 $k$ 近邻法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-07-26-statistical-learning-methods-ch03-k-nearest-neighbors %})
- [x] [第 4 章 朴素贝叶斯法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch04-naive-bayes %})
- [x] [第 5 章 决策树]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch05-decision-tree %})
- [x] [第 6 章 逻辑斯谛回归与最大熵模型]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch06-logistic-regression-maximum-entropy %})
- [x] [第 7 章 支持向量机]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch07-support-vector-machines %})
- [x] [第 8 章 提升方法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch08-boosting %})
- [x] [第 9 章 EM 算法及其推广]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch09-em-algorithm %})
- [x] [第 10 章 隐马尔可夫模型]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch10-hidden-markov-models %})
- [x] [第 11 章 条件随机场]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch11-conditional-random-fields %})
- [x] [第 12 章 监督学习方法总结]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch12-supervised-learning-summary %})
- [x] [第 13 章 无监督学习概论]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch13-unsupervised-learning-introduction %})
- [x] [第 14 章 聚类方法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch14-clustering %})
- [x] [第 15 章 奇异值分解]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch15-singular-value-decomposition %})
- [x] [第 16 章 主成分分析]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch16-principal-component-analysis %})
- [x] [第 17 章 潜在语义分析]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch17-latent-semantic-analysis %})
- [x] [第 18 章 概率潜在语义分析]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch18-probabilistic-latent-semantic-analysis %})
- [x] [第 19 章 马尔可夫链蒙特卡罗法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch19-markov-chain-monte-carlo %})
- [x] [第 20 章 潜在狄利克雷分配]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch20-latent-dirichlet-allocation %})
- [x] [第 21 章 PageRank 算法]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch21-pagerank %})
- [x] [第 22 章 无监督学习方法总结]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-ch22-unsupervised-learning-summary %})
- [x] [附录 A–E 基础数学工具]({% post_url book-notes/machine-learning/statistical-learning-methods/2026-08-02-statistical-learning-methods-appendices-math-tools %})
