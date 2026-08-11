# 术语表与复习卡

## 自动转写术语提示

| 规范词 | 自动转写常见变体 | 说明 | 置信度 |
| --- | --- | --- | --- |
| 谢赛宁 / Saining Xie | 赛宁、三宁 | 嘉宾 | 高 |
| Yann LeCun | Young、Lacoon、杨乐空 | AMI 联合创始相关人物 | 高 |
| Ilya Sutskever | Elia、伊莉亚 | OpenAI/SSI 研究者 | 高 |
| 何恺明 / Kaiming He | 凯明 | Vision 研究者 | 高 |
| 李飞飞 / Fei-Fei Li | 飞飞 | Vision 研究者 | 高 |
| 屠卓文 / Zhuowen Tu | 涂文、涂志文 | 博士导师 | 高 |
| Piotr Dollár | Peter | FAIR 研究者 | 中高 |
| Ross Girshick | Ross | FAIR 研究者 | 高 |
| AMI Labs | NeoLab AMI | Advanced Machine Intelligence Labs | 高 |
| FAIR | Fair | Facebook AI Research | 高 |
| Google DeepMind | Dmine、GDM | AI 实验室 | 高 |
| SSI | SSI | Safe Superintelligence | 高 |
| Deeply-Supervised Nets | Deeply Suplex Nets | 中间层辅助监督 | 高 |
| HED | Holistic Edge Detection | Holistically-Nested Edge Detection | 高 |
| ResNeXt | Rest Next | Vision 架构 | 高 |
| MoCo | Moco | Momentum Contrast | 高 |
| MAE | MAE | Masked Autoencoders | 高 |
| ConvNeXt | Conf Next | ConvNet 架构 | 高 |
| DiT | DiT | Diffusion Transformer | 高 |
| JEPA | JAPA | Joint Embedding Predictive Architecture | 高 |
| Representation Learning | 表征学习 | 学习任务有用的表示 | 高 |
| Structural Priors | 结构先验 | 模型中的诱导结构 | 高 |
| World Model | Word Model | 世界模型 | 高 |
| Model Predictive Control | MPC | 模型预测控制 | 高 |
| Dyna | Dyna | Model-Based RL 架构 | 高 |
| Reactive Policy | Reactive Policy | 反应式策略 | 高 |
| Model-Based Policy | Model-Based Policy | 基于模型的策略 | 高 |
| Latent Representation | Latent Representation | 潜在表征 | 高 |
| Minimal Description Length | MDL | 最小描述长度 | 高 |
| Bitter Lesson | Bitter Lesson | 苦涩的教训 | 高 |
| VLA | VLA | 视觉-语言-动作模型 | 高 |
| WAM | WAM | 世界-动作模型 | 高 |
| World Simulator | World Simulator | 生成式世界模拟器 | 高 |
| Predictive Brain | Predictive Brain | AMI 技术愿景 | 高 |
| Test-Time Scaling | Test-Time Scaling | 测试时扩展 | 高 |

## 仍需回听确认

- Cambrian-S、V*、Thinking Space、Solaris 等具体论文名与版本。
- AMI CEO Alex LeBrun 和其他联合创始人/高管的正式职务。
- 人物薪酬、Offer、持股和内部组织传闻。
- AMI 融资、团队和办公室的公告时点与口径。
- 未公开 ByteDance 世界模型传闻及参数量。

## 15 张复习卡

### 1. “The normal one”是什么意思？

**时间：** `00:01:19`

**问：** 为什么不是否认自己的成就？

**答：** 它拒绝天选叙事，强调路径由兴趣、行动、人与环境共同形成，而非命中注定。

### 2. 为什么坚持做 Vision？

**时间：** `00:35:40`

**问：** Vision 对谢赛宁意味着什么？

**答：** 它连接感知、意识和真实世界理解；当默认路径不允许做 Vision 时，他会主动寻找其他导师和环境。

### 3. 与何恺明合作学到什么？

**时间：** `00:57:43`

**问：** 他怎样描述何恺明的 Research Taste？

**答：** 能把看似普通的念头提炼为简单、清晰且有力量的问题，并通过强实验验证。

### 4. 为什么两次拒绝 Ilya？

**时间：** `01:21:05`

**问：** 两次选择分别反映什么？

**答：** 2018 年更想在 FAIR 做顶尖 Vision；2024 年已开始 NYU 工作，且对感知/多模态优先级有不同判断。

### 5. 表征学习是什么？

**时间：** `01:58:30`

**问：** 它为何贯穿不同任务？

**答：** 学习从原始数据到有利于下游任务空间的映射；分类、边缘、视频、3D 和世界模型共享这一根问题。

### 6. 好 Research Idea 从哪里来？

**时间：** `02:43:55`

**问：** 为什么不应一开始就锁死 Idea？

**答：** 真正 Idea 往往来自复现、代码、失败实验和梯度信号；探索过程应允许 Pivot。

### 7. 强 Baseline 为什么重要？

**时间：** `03:00:00`

**问：** 弱 Baseline 有什么危害？

**答：** 它会制造虚假增益，让研究者把实现缺陷误认为新方法突破。

### 8. 世界模型的最小定义是什么？

**时间：** `04:11:07`

**问：** 状态和动作怎样关联？

**答：** 学习 $s_{t+1}=f(s_t,a_t)$，预测动作对环境的后果，并服务规划和决策。

### 9. MPC 怎样使用世界模型？

**时间：** `04:13:41`

**问：** 为什么只执行最优序列第一步？

**答：** 真实环境不断变化，系统执行一步后重新观察并滚动规划，减少模型误差累积。

### 10. 为什么说 State 是任务相关压缩？

**时间：** `04:18:00`

**问：** 为什么不重建世界全部细节？

**答：** 决策只需要保留预测与目标相关的信息；无关纹理和分子细节会增加成本而不帮助行动。

### 11. LLM 为什么不是完整世界模型？

**时间：** `04:25:00`

**问：** 谢赛宁的核心批评是什么？

**答：** 语言是人类压缩后的离散交流接口，难以直接高效表达连续、高维、带噪声的物理信号与行动后果。

### 12. “下载人类”是什么意思？

**时间：** `04:29:47`

**问：** 为什么互联网数据不够？

**答：** 真实能力需要人的观察、行动、传感器与产业过程数据，而这些通常不会公开上传到互联网。

### 13. AMI 的数据闭环是什么？

**时间：** `05:15:57`

**问：** 产业伙伴如何参与？

**答：** 伙伴提供真实问题和数据，模型创造业务价值，部署产生更多数据，再反哺基础世界模型。

### 14. 世界模型路线有哪些差异？

**时间：** `05:45:53`

**问：** Simulator、空间表征和 Predictive Brain 如何区分？

**答：** 视频公司偏生成一致性，World Labs 偏显式 3D/空间接口，AMI 偏预测、规划和智能本身；路线可能互补。

### 15. 为什么用“42”收尾？

**时间：** `06:44:28`

**问：** 它表达什么限制？

**答：** 完整预测生命、宇宙和命运可能需要宇宙规模的计算；42 是对终极答案不可得性的幽默回应。

## 引用注意事项

- 自动转写不是嘉宾确认的逐字稿；官方文章也只是编辑后的节选。
- 私人电话、薪酬、情绪和人员动机必须写成谢赛宁回忆。
- AMI 融资、人数、办公室和职位需查公司与投资方公告。
- LLM、AGI、Bitter Lesson 和世界模型关系是谢赛宁的理论立场。
- 本节目不构成投资建议。