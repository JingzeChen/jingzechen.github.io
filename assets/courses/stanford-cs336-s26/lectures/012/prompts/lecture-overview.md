# 整理任务

- 课程：Stanford CS336 Language Modeling from Scratch (Spring 2026)
- 本讲：Lecture 12: Evaluation
- 输出文件：NOTES.md
- 材料范围：仅使用本讲 transcript、各 section prompt 中附带的材料摘录，以及 materials/lecture_12.py 的页码信息

请按下面结构输出 Markdown：

## 00:00:06-00:10:04 课程位置、评估定义与“好模型”的多种标准
概括老师如何把本讲放到课程主线中，如何提出 evaluation 的核心问题，以及“抽象构想 -> 具体指标”的总框架。需要点出 benchmark、成本、偏好、真实使用四种“好”的视角，并在涉及课件时引用 Python 页码，例如 `[代码: lecture_12.py p.2]`。

## 00:10:04-00:20:03 困惑度的理论吸引力、局限与变体
概括老师如何用真实分布 $t$ 与模型分布 $p$ 解释 perplexity 的地位，如何讨论 conditional perplexity、LAMBADA、HellaSwag，以及为什么 perplexity leaderboard 需要额外信任。涉及课件处只用 Python 页码引用。

## 00:20:03-00:29:59 考试型 benchmark 的升级循环与污染担忧
概括 MMLU、MMLU-Pro、GPQA、HLE 的演化逻辑：旧 benchmark 饱和后如何加难、为什么人工构题成本越来越高、污染问题如何在课堂问答中被指出。

## 00:29:59-00:39:57 从多选题到开放式对话评估
概括老师如何说明 exam benchmark 的现实性不足，如何解释多选题答案提取，再总结 Chatbot Arena 与 AlpacaEval 的核心机制、优势和偏差来源。涉及课件处只用 Python 页码引用。

## 00:39:57-00:49:56 指标校验与 agent 评估的起点
概括老师如何讨论“metric 怎么评估 metric”，WildBench 为什么引入 checklist，以及为什么 agent benchmark 把评估对象从“说什么”扩展到“做什么”。本段是 transcript-only，不得虚构代码页码。

## 00:49:56-00:59:52 agent scaffold 的决定性作用与纯推理 benchmark
概括 CyBench、MLEBench、agent scaffold 四要素，以及 ARC-AGI 系列如何尝试把 reasoning 与 knowledge 分离。涉及课件处只用 Python 页码引用。

## 00:59:52-01:09:51 安全性与现实性的双重扩展
概括 HarmBench、AIR-Bench、jailbreaking、dual-use，以及 GDPVal、MedHELM、Clio 如何把评估拉向更真实的职业与用户场景。涉及课件处只用 Python 页码引用。

## 01:09:51-01:18:31 有效性、数据集质量与评估方法论收束
概括 contamination 的四条应对路线、数据集质量审计、Docent、评估目的四分法，以及 methods 与 models/systems 的区别。涉及课件处只用 Python 页码引用。

## 逐段详细课堂笔记
在本节下按以下精确时间范围依次嵌入完整分段笔记，必须覆盖各 section notes 的完整正文，不得摘要替换，不得改写为要点提纲，不得省略“本段掌握检查”与“待核对项”。为避免标题层级冲突，每段请使用如下结构：

```markdown
### 00:00:06-00:10:04
```markdown
...完整嵌入 notes/sections/001.md ...
```

### 00:10:04-00:20:03
```markdown
...完整嵌入 notes/sections/002.md ...
```

### 00:20:03-00:29:59
```markdown
...完整嵌入 notes/sections/003.md ...
```

### 00:29:59-00:39:57
```markdown
...完整嵌入 notes/sections/004.md ...
```

### 00:39:57-00:49:56
```markdown
...完整嵌入 notes/sections/005.md ...
```

### 00:49:56-00:59:52
```markdown
...完整嵌入 notes/sections/006.md ...
```

### 00:59:52-01:09:51
```markdown
...完整嵌入 notes/sections/007.md ...
```

### 01:09:51-01:18:31
```markdown
...完整嵌入 notes/sections/008.md ...
```
```

额外要求：

- 全文中文。
- 严格按老师讲解顺序组织内容。
- 只用 transcript 与已给材料，不得补充外部知识或编造结论。
- 只能用 `[代码: lecture_12.py p.N]` 这种格式引用 Python 材料，禁止写 slide 页码。
- 对 transcript-only 片段不得补代码引用。
- 遇到明显字幕歧义时用 `[需回听]` 标记。
- NOTES.md 的八个 overview H2 必须与本文件完全一致。
- NOTES.md 必须包含且只包含一个 `## 逐段详细课堂笔记` 总节。
- 详细笔记嵌入应覆盖各 section note 内容的 90% 以上；最佳做法是全文嵌入。
- 文件最后应在最后一个分段笔记结束，不追加额外说明。