# Lecture 09: Convolutional Neural Networks (CNNs) I

模式：基于本 lecture 的 prompts/sections、transcript 与课件整理；不引入外部资料。

## 学习目标
- 理解为什么普通 MLP 对模式位置敏感，为什么本讲必须追求 shift invariance。
- 能把“扫描式检测”表述成“同一个局部 detector 在不同位置复用”的结构。
- 能说明扫描网络为什么等价于一个带共享参数子网的 giant MLP。
- 能复述共享参数训练时的核心规则：共享值的梯度等于所有对应边梯度之和。
- 能解释为什么把大模式分布到多层会带来更好的层级表示、更少参数和更少重复计算。
- 掌握本讲收尾术语：filter、receptive field、flattening、stride、pooling、TDNN/1D CNN、CNN。

## 需要的先修知识
- 多层感知机的前向传播与反向传播。
- 分类任务、softmax 和梯度下降。
- “层级组合模式”这一神经网络直觉，即高层模式由低层模式组合而来。

## 老师的教学主线
- 先用语音 welcome 和图像 flower 两个任务证明：只要目标位置变化，普通 MLP 就会把它们当成不同输入。
- 然后提出扫描：在每个局部窗口上运行同一个 detector，再把各位置输出聚合成全局判断。
- 再把扫描重述为共享参数的大网络，并补上共享参数下如何训练、如何合并梯度。
- 接着把“整窗口识别”改写为“逐层扫描 maps”，并进一步把大模式分布到多层，使低层学局部、高层学组合。
- 最后总结 distributed scanning 的三项收益，并引出 CNN 常用术语与修饰操作。

## 核心概念与依赖关系
- shift invariance：只关心模式是否存在，不关心其具体位置。
- scanning：用同一个局部 detector 沿输入移动并逐位置求响应。
- giant shared-parameter network：扫描可看成一个大网络，其中不同位置的子网完全相同。
- shared parameter learning：共享参数的梯度要把所有共享边上的贡献相加。
- maps：逐层扫描后，每层神经元在全输入上的响应排成图，成为后续层的新输入。
- distributed scanning：把原本由单层完成的大窗口分析拆到多层，让底层看小块、高层做组合。
- filter / receptive field / flattening / stride / pooling：是在 distributed scanning 结构上进一步描述权重、作用区域、末层重组、步长与抖动鲁棒性的术语。

## 关键推导、例子与结论边界
- 共享参数梯度推导的边界最明确：本讲只推到“共享值的梯度等于共享边梯度求和”，并未展开更复杂的卷积张量写法。
- 参数量比较只在老师给出的简化 1D 例子中定量展开：非分布式为 8D*N1 + N1*N2 + N2*N3，分布式为 2D*N1 + 4*N1*N2 + N2*N3。
- 计算节省的直觉来自相邻扫描窗口共享底层响应；老师强调 2D 情况完全同理，但没有在课堂上完整重算所有 2D 公式。
- pooling 在本讲只给了动机与 max 直觉，详细机制被明确留到下一讲。

## 易错点与待核对项
- 不要把“扫描网络更好”误解成“只是数据增强更多”；老师的重点是结构性共享，而不是数据层面补齐位置。
- 不要把 giant MLP 理解成普通全连接 MLP；它的关键差别是重复子网与共享参数。
- 不要把 distributed scanning 误解成缩小了目标窗口；窗口分析范围可以等效保持不变，只是拆给更多层完成。
- Poll 4 中“中间变量内存更少”不是老师认可的收益。
- 多处 ASR 把 affine、pooling、花朵部件名和历史专有名词识别错，引用时应保留谨慎。

## 掌握标准
- 能从语音和图像两个例子说明为什么位置变化会让普通 MLP 失败。
- 能口头写出扫描流程、局部 detector 与全局聚合器之间的关系。
- 能解释共享参数为什么需要“梯度求和再复制回各边”。
- 能比较 nondistributed 与 distributed 的参数量公式，并说出 distributed 的三项收益。
- 能正确使用 filter、receptive field、flattening、stride、pooling、CNN、TDNN 等术语。

## 复习顺序
1. 先复习第 1-2 段，抓住“为什么普通 MLP 不行”和“扫描式答案是什么”。
2. 再复习第 3-4 段，确认“扫描为何仍可用反向传播训练”和“为什么可以重排计算顺序”。
3. 接着复习第 5-7 段，理解 distributed scanning 如何把复杂模式拆层，以及参数为何减少。
4. 最后复习第 8-9 段，把收益、术语、stride、pooling 与完整 CNN 结构串起来。