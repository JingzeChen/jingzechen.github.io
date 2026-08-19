## 学习目标
- 建立 GPU 的基础心智模型：SM、warp、shared/global memory、SIMT。
- 理解为什么现代 GPU 优化首先是 memory movement 问题，而不是单纯增加 FLOPs。
- 掌握第二部分的六类技巧及其共同目标：减少全局读写、提高局部复用、避免空转。
- 能用这些概念解释 FlashAttention 为什么快，而不是只记住“它是一个更快的 attention kernel”。

## 需要的先修知识
- 基本矩阵乘法与 attention 计算流程。
- 反向传播中 activation 与 gradient 的关系。
- 对并行执行、线程、缓存/内存层级有初步直觉即可；老师在本讲从头搭建术语。

## 老师的教学主线
- 先说明 compute 对 LLM scaling 的重要性，以及 Dennard scaling 失效后为什么必须转向 GPU 并行扩展。
- 再建立 GPU/TPU 的硬件与执行模型，尤其强调 memory hierarchy 才是后续优化的根。
- 然后用 roofline model 把“为什么会慢”概括成 memory-bound 与 compute-bound 的区分。
- 接着依次讲 control divergence、low precision、fusion、recomputation、coalescing、tiling，把所有技巧都压回“少搬数据、把数据搬对地方”。
- 最后用 FlashAttention 证明这些技巧不是零散 trivia，而是能系统性地产生重要算法收益。

## 核心概念与依赖关系
- GPU 心智模型依赖三组对象：
  - 计算组织：SM、thread、block、warp。
  - 内存层级：register、shared/L1、L2、global/HBM、host memory。
  - 执行约束：SIMT 与 warp 级锁步执行。
- 性能分析依赖 roofline：先分清 memory-bound 还是 compute-bound，再决定该减少读写还是提升算子利用率。
- 六类技巧的依赖关系：
  - control divergence 解决 warp 空转。
  - low precision 减少 bytes 并借助专用低精度硬件。
  - fusion 减少 kernel 间往返。
  - recomputation 用 compute 换 memory。
  - coalescing 让 global memory 的 burst 被充分利用。
  - tiling 把复用从 global memory 挪到 shared memory。
- FlashAttention 则把 tiling、fusion、online softmax、recomputation 组合起来，系统性减少 HBM 访问。

## 关键推导、例子与结论边界
- ReLU 的 float32/float16 字节核算说明：减少位宽会直接减少 memory movement，但课件数字更准确地说是 `bytes/FLOP`，不是正向的 arithmetic intensity。
- 三层 sigmoid 例子给出 recomputation 的直观收益：memory access 从 8 次降到 5 次，说明“多算一点”在 GPU 上可能比“多存一点”更便宜。
- tiling 的关键定量结论：naive matmul 每个输入从 global memory 读 `N` 次；tile 大小为 `T` 时降到 `N/T` 次，global memory 读写量减少 `T` 倍。[课件: lecture_05.pdf p.42]
- `1792 -> 1793` 的 wave quantization 例子说明：性能断崖可能来自 tile 数跨过 SM 数量边界，而不是算法数学结构突变。[课件: lecture_05.pdf p.48]
- FlashAttention 的结论边界：这讲只讲 forward 的核心思路和 backward 的重算直觉，不展开完整 backward 推导。

## 易错点与待核对项
- 不要把 shared memory、L1 cache、global memory 混成“GPU memory”；它们在物理位置、可编程性和代价上都不同。
- 不要把“矩阵维度最好是 32 的倍数”记成无条件真理；本讲强调的是 burst、tile、alignment、SM 波次这些具体原因。
- 不要把“低精度更快”误解为“所有操作都应该尽量量化”；老师反复说收益最大的还是 matmul，别的地方可能不值得。
- 若要严格复原 DRAM burst 图的电路级解释、MXFP8 某些缩放实现细节、以及 FlashAttention 图来自第 2 版还是第 3 版，需要结合视频画面和原论文再核对。[需回听]

## 掌握标准
- 能不用课件原句，自行解释 thread、block、warp、shared memory、coalesced access、tiling、wave quantization。
- 看到某个 GPU 算子慢时，能先问“它是 memory-bound 还是 compute-bound”，而不是盲目调参。
- 能说明为什么 padding、alignment、tile size、SM 数量会共同影响 matmul 吞吐。
- 能口头重建 FlashAttention 的思路：tile 化 matmul、online softmax、尽量 fusion、backward 重算。

## 复习顺序
- 先复习第一部分的硬件模型，特别是 warp、shared memory、global memory 的边界。
- 再复习 roofline 与“memory 是主线”的总判断。
- 然后按“少分支 -> 少字节 -> 少往返 -> 少存储 -> 读对齐 -> 做 tiling”的顺序过六类技巧。
- 最后回看 FlashAttention，把每个技巧在 attention 里的落点一一对应起来。