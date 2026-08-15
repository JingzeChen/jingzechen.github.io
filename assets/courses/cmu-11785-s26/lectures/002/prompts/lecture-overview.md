# Lecture 01: Introduction 概览

本讲共 9 个片段，整体主线很清楚：先用课程 logistics 和课堂参与规则把学习场景固定下来，再用 2016 年前后的应用突破说明“为什么神经网络值得学”，随后从 cognition、associationism 和 connectionism 追问“神经网络究竟是什么”，最后落到 perceptron、MLP、分类边界、连续函数逼近与“神经网络就是函数近似器”这一统一视角。

从知识推进顺序看，老师先把神经网络放进历史与认知背景里，而不是直接给现代公式。先有 associationism 的“联想”观，再有 Bain 的“信息在连接里”的 connectionism；之后才进入单个 neuron 的计算模型、Hebbian learning 的局限、perceptron 的误差驱动学习，以及多层网络如何突破单个单元的 XOR 限制。这条线索把“为什么需要网络”说得比“如何调参”更早。

本讲真正的能力结论有三层。第一层，MLP 是 universal Boolean function machine：多层 perceptrons 可以表示任意复杂布尔函数。第二层，MLP 是 universal classifier：线性边界可以层层组合成复杂决策区域。第三层，MLP 还能通过脉冲叠加逼近连续值函数，因此从 AI 角度看，语音转写、图像描述、博弈决策等任务都可以被看成网络所近似的函数。

复习时可按四步走：先记课程要求与课堂规则，再记 2016 突破带来的现实动机，再记 associationism → connectionism → neuron model → Hebb → perceptron → MLP 这条历史-模型链，最后记住三条能力结论：能做布尔函数、能做分类、能逼近连续函数。需要特别留意的误区是：80 billion 指 neurons 数量，不是 connections；单个 perceptron 不能做 XOR；Hebb rule 不稳定；课件中未当堂展开的 hidden slides 和部分 polls 仍可能构成考查边界。
