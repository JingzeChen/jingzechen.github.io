## 学习目标

- 理解本讲如何从上一讲的 GPU 性能概览，推进到 benchmarking、profiling 与 Triton kernel 编写。
- 建立统一心智模型：grid -> thread block -> thread，以及 HBM / shared memory / registers 的层级关系。
- 能解释为什么同一语义的 PyTorch 表达式会因 kernel fusion、HBM 读写次数与 tile 设计不同而产生巨大性能差异。
- 能按老师给出的顺序复述四类 Triton 例子：GeLU element-wise、softmax 行内归约、row-sum 的 baby tiling、matmul 的 shared-memory tiling。
- 理解 benchmark / profile 在 kernel 优化中的地位：先测量，再修改，再复测。

## 需要的先修知识

- 矩阵乘法维度规则：$A \in \mathbb{R}^{M \times K}$、$B \in \mathbb{R}^{K \times N}$、$C \in \mathbb{R}^{M \times N}$。
- softmax 的基本步骤：逐行做数值稳定化、指数化与归一化。
- element-wise 与 reduction 的区别。
- 上一讲已经介绍过的 GPU 基本部件、HBM 与 SM 的概念。

## 老师的教学主线

- 先回顾 GPU 硬件和编程模型，说明 correctness 的抽象和 performance 的硬件现实是两层不同问题。
- 再给出 benchmark/profile 的方法论，强调在写 kernel 之前必须先量化瓶颈。
- 然后用 GeLU 展示多 kernel 与单 kernel 的性能差别，把 kernel fusion 讲清楚。
- 接着切到 Triton，把“每个 thread 做什么”的 CUDA 视角换成“每个 block 做什么”的 Triton 视角。
- 最后按复杂度递增，依次讲 element-wise、row-wise reduction、row 不 fit in block 的 tiling、matmul tiling，并在结尾把 PyTorch / Triton / PTX 与硬件约束重新串起来。

## 核心概念与依赖关系

- GPU 存储层级：HBM 最远最慢但大；shared memory / L1 与 registers 更近更快但小。
- 编程模型层级：grid 管很多 thread blocks，block 管一组 threads；block 是 Triton 的核心思考单位。
- 性能敏感细节：warps、control divergence、warp occupancy、bank conflicts、memory coalescing、block occupancy。
- 性能分析工具链：benchmark 负责“多久”，profile 负责“花在哪、实际跑了什么 kernel”。
- Triton 抽象依赖前面的 block 与 memory hierarchy 直觉；softmax 依赖 row-wise reduction；row-sum 依赖 tile 内循环；matmul 再把 tile 复用推广到二维 output tiles。

## 关键推导、例子与结论边界

- occupancy 例子：128 threads、每线程 160 registers、SM 共约 65536 registers、最多 64 warps，推出并发约 3 blocks、12 warps、occupancy 约 18.75%。
- benchmark 例子：小矩阵 matmul 在较小维度上近似常数时间，维度足够大后才显出近似立方增长。
- GeLU 例子：naive PyTorch 会拆成多个 kernels，多次往返 HBM；built-in 与 compiled 版本把操作融合到单 kernel 中。
- softmax 例子：若整行 fit in block，则可把“一行”直接交给一个 block 处理；若不 fit，就要引入 tiles 与循环归约。
- matmul 例子：naive 按单元素算会造成冗余读；理想是整体装入 shared memory，但通常做不到，所以采用 output tiling 与局部子块复用。
- 结论边界：老师多次强调很多性能结果都硬件相关，课堂例子主要传达方法与形状，不承诺已是最优实现。

## 易错点与待核对项

- 不要把 Triton 当作 GPU 上逐句解释执行的“Python 库”；它是会编译到 PTX 的 DSL。
- 不要把高 occupancy 简单等同于高性能；thread coarsening 之类策略会改变这一判断。
- 不要混淆 bank conflicts 与 memory coalescing：前者是 shared memory 冲突，后者是 HBM 事务合并。
- 不要把 GeLU / row-sum 里的“切片”都叫成 blocks；有时是独立 blocks，有时只是同一 block 内循环处理的 tiles。
- 多处问答字幕残缺，尤其专有名词与个别公式口述处，若后续需要实现级精度，应回听原音频核对。[需回听]

## 掌握标准

- 能不用看代码，口头复述老师为什么坚持“先 benchmark/profile，再谈写 kernel”。
- 能说明 Triton kernel 的标准骨架：识别当前 block、算地址、load、compute、store。
- 能区分 softmax 行 fit / 不 fit in block 时的两种处理思路。
- 能解释 matmul 为什么需要 tiling，以及它怎样减少 HBM 冗余读取、提升 arithmetic intensity。
- 能把整讲结论压缩成一句话：编程模型给 correctness，硬件约束决定 performance，benchmark/profiling 负责把两者接起来。

## 复习顺序

1. 先复习开头的 GPU 层级、thread/block/grid、warp 与 occupancy 概念。
2. 再复习 benchmark/profile 的流程与 GeLU 的三种实现对比。
3. 然后看第一个 Triton GeLU kernel，记住 pointer、pid、offsets、mask、load/store 模板。
4. 接着复习 softmax：先是一行 fit in block，再是 row-sum 式的 tile 循环。
5. 最后复习 matmul：从 naive、idealized 到 tiling，再回看总结部分把全讲闭环。
