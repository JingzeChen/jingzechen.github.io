# Lecture 10 Overview

整理模式：仅依据当前讲次目录下 prompts\sections\001-009.md 与其中提供的 transcript、代码材料整理；不引入外部资料，不补写未给出的课件页或论文细节。

## 学习目标

本讲目标是建立一套面向 inference 的完整分析框架。老师先解释为什么 inference 已经从“训练之后的附属环节”变成与产品、评测、强化学习和 agent 直接相关的核心工作负载；再用 arithmetic intensity、TTFT、latency、throughput 这些指标刻画“快”究竟是什么意思；最后系统梳理如何通过缩小 KV cache、量化、剪枝、推测采样以及动态工作负载调度来提升推理效率，同时尽量不伤害 accuracy。

## 需要的先修知识

本讲默认听众已经熟悉 Transformer 的基本构成、Q/K/V、MLP、head 和 model dimension 等术语，也默认大家能接受上一讲或前面系统课里对 arithmetic intensity、HBM、memory bandwidth、compute-bound 与 memory-bound 的分析框架。对于 GQA、RoPE、蒸馏、量化、状态空间模型等内容，老师会给出足够高层的说明，但不会从头建立全部背景。

## 老师的教学主线

整讲主线非常清楚。先从使用场景与成本结构说明 inference 为什么重要，再把“快”拆成 TTFT、latency、throughput 三种不同指标。随后老师用统一符号重新写 transformer block 和 matmul 成本，先分析 MLP，再分析 attention，最终锁定 generation attention 是 transformer inference 的根本瓶颈，因为它天然 memory-bound。接着围绕这个瓶颈展开所有优化：第一类是减少 KV cache 或参数/数值精度，如 GQA、MLA、CLA、局部注意力、量化、剪枝；第二类是不改变目标分布但改变生成流程，如 speculative sampling；第三类是面向在线服务的系统调度与内存管理，如 continuous batching、selective batching、paged attention。最后老师把所有技巧统一到一个更高层判断：真正的大机会可能来自更 inference-friendly 的新架构。

## 核心概念与依赖关系

整讲的依赖链是从工作负载差异开始的。training 能一次看到全部 token，因此可以沿序列维并行；inference 因自回归生成必须逐 token 推进。这个结构差异先导致 generation 阶段很难像 training 那样把计算单元吃满，再在定量分析中表现为 attention generation 的 arithmetic intensity 小于 1。既然瓶颈是 memory 而不是纯 FLOPs，后面的优化就自然围绕 memory 展开。KV cache 成为中心对象：它使 naive O(T^3) 生成降为可复用前缀的 cached generation，但又引入巨大的显存和内存搬运压力。于是 GQA、MLA、CLA、sliding window、DeepSeek 压缩注意力都在不同维度压缩 KV cache；quantization 与 pruning 则通过减少参数或数值精度降低 memory 压力；speculative sampling 则利用“检查比生成快”的不对称，把 compute-bound 的并行检查能力引回 memory-bound 的 sequential generation；continuous batching 与 paged attention 则把这些理论结论落到真实动态服务系统。

## 关键推导、例子与结论边界

本讲最关键的推导有三组。第一组是矩阵乘法与 MLP 的 arithmetic intensity：在 B 远小于 D、F 的近似下，简单 matmul 的强度约为 B，MLP 在 inference 中约为 B×T，因此 prefill 时若 B×T 足够大，MLP 可以 compute-bound。第二组是 attention 的强度公式 S×T/(S+T)：代入 prefill 得 S/2，代入 generation 得 S/(S+1)<1，这直接说明 generation attention 是根本瓶颈。第三组是基于 memory-bound 假设的性能统计：memory 由参数加上 B 倍 KV cache 组成，latency 近似由 memory/bandwidth 决定，throughput 近似是 B/latency，因此 batch 增大必然拉高 latency、提升 throughput，但受显存与收益递减限制。例子上，老师多次用 Llama 2 13B on H100 演示这些结论，也用 OpenAI 每天 8.6T token 对比 DeepSeek-V4 训练 32T token 来强调 inference 规模。结论边界同样被清楚说明：任何精度对比图都不能脱离模型和设定泛化；很多压缩手段是经验上有效而非数学保证；真正 lossless 的只有类似 speculative sampling 这类带严格分布修正的方法。

## 易错点与待核对项

最容易误解的地方有五个。第一，不要把“inference is memory-bound”理解成所有部分都同样 memory-bound，真正拖垮系统的是 generation attention。第二，不要把 batch 增大简单理解成“更快”，它改善 throughput 的同时也会恶化 latency，并可能直接撞上显存上限。第三，不要把 GQA、MLA、局部注意力这类方法都当作可无脑套用的免费午餐，老师反复提醒要检查 accuracy，并对论文中的经验结论保持保留态度。第四，不要把 speculative sampling 当作近似 hack，它的卖点恰恰是 exact sample。第五，不要以为 paged attention 只是工程细节，它实际上把操作系统里的分页、共享前缀、copy-on-write 思路系统化地引入了推理服务。待核对的内容主要是若干字幕疑点，例如 K/G 的口头勘误、零散 [INAUDIBLE] 段落，以及部分量化和 DeepSeek 注意力缩写的识别噪声。

## 掌握标准

学完本讲，至少应能解释：为什么 inference 的现实重要性与 agent 崛起一起上升；TTFT、latency、throughput 三个指标各自衡量什么；training 与 inference 在并行结构上为何根本不同；为什么 generation attention 的 arithmetic intensity 小于 1；KV cache 如何把 naive 生成变成可复用前缀的两阶段推理；为什么 batch 会造成 latency 与 throughput 的系统性张力；GQA、MLA、CLA、sliding window、量化、剪枝分别在压缩什么；speculative sampling 为什么既快又保持 exactness；continuous batching、selective batching、paged attention 分别解决真实在线服务中的什么问题；以及为什么老师最后认为新架构仍有巨大潜力。

## 复习顺序

建议按“先瓶颈、后优化、再系统化”的顺序复习。先看开场部分，明确 inference 与 training 的区别以及三个速度指标。然后复习 arithmetic intensity 的三步链条：普通 matmul/MLP、attention、Llama 2 13B on H100 的性能统计，把 generation attention < 1 这个结论吃透。接着按“缩 KV cache -> 降低数值/参数成本 -> 不改分布的生成技巧”复习 GQA、MLA、CLA、local attention、quantization、pruning、speculative sampling。最后再回到动态服务系统，把 continuous batching、selective batching 与 paged attention 串起来，理解它们如何把前面的理论真正落地到 live inference server。