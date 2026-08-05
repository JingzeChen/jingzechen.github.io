# Digital Garden 内容编写规范

本文档规定本仓库新增知识节点时应遵循的内容类型、目录、Front Matter、正文、链接和验证规范。

## 1. 快速开始

1. 在 `_posts/` 下按内容类型选择或创建目录。
2. 新建名为 `YYYY-MM-DD-slug.md` 的 Markdown 文件。
3. 添加符合本文规范的 Front Matter。
4. 使用 Markdown 编写正文；按需启用 MathJax 或 Mermaid。
5. 在本地执行生产构建和链接检查。
6. 提交并推送到 `master`，等待 GitHub Pages 部署完成。

最小可用示例：

```markdown
---
title: "文章标题"
date: 2026-07-26 08:00:00 +0800
updated: 2026-07-26
uid: consensus-basics
type: note
content_lang: zh-CN
status: seedling
topics: [distributed-systems]
categories: [技术, 后端]
tags: [distributed-systems, database]
description: "解释共识问题的基本模型与常见算法。"
toc: true
---

## 背景

正文从这里开始。
```

## 2. 文件位置

所有公开内容必须放在 `_posts/` 目录中，并优先按内容类型建立一级目录：

```text
_posts/
  notes/
  essays/
  journal/
  reading/
  projects/
  ideas/
```

普通文章示例：

```text
_posts/
  notes/
    distributed-systems/
      2026-07-26-consensus-basics.md
```

读书笔记示例：

```text
_posts/
  book-notes/
    machine-learning/
      hands-on-machine-learning/
        2026-07-26-homl-ch03-classification.md
```

现有读书笔记保留在 `_posts/book-notes/` 以维持路径稳定；新增阅读内容优先放入 `_posts/reading/`。目录仅用于维护源文件，不直接决定网站分类。网站分类由 Front Matter 中的 `categories` 决定。

仓库根目录的 `book-notes/` 是本地源笔记副本，已被 Jekyll 排除。不要把它当作正式发布目录，也不要默认提交其中的文件。

## 3. 文件名规范

文件名必须使用以下格式：

```text
YYYY-MM-DD-slug.md
```

规则：

- 日期必须是四位年、两位月、两位日。
- `slug` 使用小写 ASCII 字母、数字和连字符 `-`。
- 单词之间使用连字符，不使用空格或下划线。
- 不在文件名中使用中文、括号或其他特殊字符。
- 文件扩展名统一使用 `.md`。
- 文件名中的日期原则上应与 Front Matter 的 `date` 日期一致。
- 发布后尽量不要修改文件名，因为文件名会影响文章 URL 和外部链接。

推荐：

```text
2026-07-26-homl-ch03-classification.md
2026-08-02-mysql-isolation-levels.md
2026-08-10-product-decision-framework.md
```

不推荐：

```text
机器学习第三章.md
2026_07_26_HOML Chapter 3.md
homl-ch03.md
```

## 4. Front Matter 规范

每篇文章必须以 YAML Front Matter 开头，并使用一对 `---` 包围。

推荐完整模板：

```yaml
---
title: "文章标题"
date: 2026-07-26 08:00:00 +0800
updated: 2026-07-26
uid: article-slug
type: note
content_lang: zh-CN
status: seedling
topics: [ai, software-engineering]
related: [evaluation-basics, reliable-ai-systems]
categories: [一级分类, 二级分类, 三级分类]
tags: [tag-one, tag-two]
description: "用于首页摘要和 SEO 的简短描述。"
references:
  - title: "资料标题"
    url: "https://example.com/"
    note: "这份资料与本文的关系。"
toc: true
math: true
mermaid: true
pin: false
image:
  path: /assets/img/posts/example/cover.png
  alt: "图片内容说明"
---
```

只保留文章实际需要的可选字段。例如，不含公式时不必写 `math: false`。

### 4.1 必填字段

#### `uid`

- 使用稳定且全站唯一的小写英文 slug。
- 发布后不随标题或文件路径变化。
- 用于后续 Related Notes、Backlinks 和知识图谱关系。

#### `type`

只允许以下值：

| 值 | 用途 |
| --- | --- |
| `note` | 可持续更新的知识节点 |
| `essay` | 结构完整、质量优先的长文章 |
| `journal` | 带日期语境的短日志 |
| `reading` | 读书笔记、章节笔记和阅读索引 |
| `project` | 项目动机、设计、实现与复盘 |
| `idea` | 尚未展开的想法、问题或灵感 |

#### `status`

使用成熟度而不是“是否完成”描述内容：

- `seedling`：刚记录，仍待验证或展开。
- `growing`：已有结构，仍在持续补充。
- `evergreen`：经过多次整理，当前相对稳定。

#### `content_lang`

- 表示正文内容语言，不改变全站英文界面语言。
- 当前允许 `zh-CN` 和 `en`。
- 中文内容使用 `zh-CN`，英文内容使用 `en`；不要根据代码块或引用语言判断。

#### `topics`

- 使用 YAML 数组和小写英文 slug。
- 表示稳定的知识领域，例如 `machine-learning`、`software-engineering`、`learning`。
- 通常使用 1 至 3 个，不把临时关键词都放进 topics。
- `_config.yml` 中 `garden.hidden_topics` 列出的公共值不得写入 Front Matter。

#### `description`

- 用一至两句话说明节点解决的问题或包含的核心内容。
- 用于首页、内容列表、搜索结果和 SEO，不重复标题。

#### `title`

- 使用清晰、具体、可检索的标题。
- 标题包含冒号、书名号等字符时，统一使用双引号包裹。
- 同一系列文章保持一致的命名方式。

示例：

```yaml
title: "《统计学习方法（第 2 版）》第 4 章：朴素贝叶斯法"
```

#### `date`

格式必须为：

```text
YYYY-MM-DD HH:MM:SS +0800
```

本站时区为 `Asia/Shanghai`，因此使用 `+0800`。

注意：

- 不要把发布时间设置为构建时刻之后，否则 Jekyll 会将文章视为 future post 并跳过。
- 如果索引文章通过 `{% post_url %}` 引用了尚未到发布时间的文章，整个构建会失败。
- 同日发布多篇系列文章时，可以使用较早且递增的分钟数保持顺序，例如 `00:10`、`00:11`、`00:12`。

#### `updated`

- 格式为 `YYYY-MM-DD`，表示内容层面的最后整理日期。
- 修改观点、结论或主要结构时更新；只修正错别字时可以不更新。
- Git 提交时间仍作为缺省补充，但不能替代作者维护的内容日期。

### 4.2 兼容字段

#### `categories`

- 使用 YAML 数组。
- 分类按从宽到窄的顺序排列。
- 本站分类页支持三级分类，读书笔记应使用“内容类型、领域、书名”三级结构。
- 同一分类名称的大小写和语言必须保持一致，避免生成重复分类。

读书笔记示例：

```yaml
categories: [读书笔记, 机器学习, Hands-On Machine Learning]
```

普通技术文章示例：

```yaml
categories: [技术, 分布式系统]
```

#### `tags`

- 使用 YAML 数组。
- 标签使用小写英文 slug。
- 多个单词使用连字符连接。
- 标签描述文章的技术、方法或主题，不重复堆砌标题词。
- 通常使用 2 至 5 个标签。

示例：

```yaml
tags: [machine-learning, naive-bayes, reading-notes]
```

`categories` 和 `tags` 继续用于兼容 Chirpy 的分类、标签与旧链接。新知识组织以 `type`、`topics` 和未来的显式关系字段为主。

### 4.3 常用可选字段

| 字段 | 类型 | 用途 |
| --- | --- | --- |
| `series` | 字符串 | 所属书籍、项目或专题的稳定 slug |
| `series_order` | 正整数 | Series 内的明确阅读顺序；新 Series 内容必须填写 |
| `featured` | 布尔值 | 是否进入首页精选内容 |
| `why_start_here` | 字符串 | Featured 内容的推荐理由；`featured: true` 时必填 |
| `related` | 字符串数组 | 通过目标文章的 `uid` 建立显式知识关系 |
| `references` | 对象数组 | 结构化来源，每项必须包含 `title` 和 `url` |
| `toc` | 布尔值 | 是否显示目录；本站默认开启 |
| `math` | 布尔值 | 文章包含 MathJax 公式时设为 `true` |
| `mermaid` | 布尔值 | 文章包含 Mermaid 图时设为 `true` |
| `pin` | 布尔值 | 是否置顶；只用于确实需要长期置顶的文章 |
| `image` | 字符串或对象 | 首页预览图和社交分享图 |
| `comments` | 布尔值 | 覆盖全局评论设置 |
| `author` | 字符串 | 从 `_data/authors.yml` 指定作者 |
| `media_subpath` | 字符串 | 为本文图片和媒体设置公共路径前缀 |

`topics` 的展示名、定义、相关主题和推荐入口统一维护在 `_data/topics.yml`；新增 Topic 前先补映射。Series 的正式名称、说明和兼容 URL 统一维护在 `_data/series.yml`。旧文章缺少 `series_order` 时构建仍按日期回退，但新增或维护中的 Series 内容必须使用显式顺序。

## 5. 正文结构规范

### 5.1 标题层级

文章标题由 Front Matter 的 `title` 生成，正文不要再写一级标题 `#`。

正文从二级标题开始：

```markdown
## 背景

### 问题定义

#### 特殊情况
```

规则：

- 不跳级使用标题，例如不要从 `##` 直接跳到 `####`。
- 标题应表达该节内容，不使用“其他”“补充”等含义模糊的名称。
- 长文应使用稳定的层级，避免目录过深。

### 5.2 开头内容

文章开头应尽快说明主题。技术文章建议包含背景、问题和结论；读书笔记可以包含原书、章节、定位和资料链接。

读书笔记示例：

```markdown
> 原书：*Hands-On Machine Learning with Scikit-Learn and PyTorch*  
> 章节：Chapter 3, Classification  
> 配套 Notebook：<https://example.com/notebook>

## 本章目标

学完本章后，应当能够：

1. 解释核心概念；
2. 完成关键推导；
3. 使用相关 API 解决问题。
```

### 5.3 段落、列表和表格

- 不使用空格模拟缩进。
- 段落之间保留一个空行。
- 有顺序的步骤使用有序列表，无顺序的并列项使用无序列表。
- 表格必须包含表头和分隔行。
- 同一列表中的标点风格保持一致。
- 避免超长段落；一个段落集中表达一个主要观点。

## 6. 公式规范

文章包含公式时，Front Matter 必须添加：

```yaml
math: true
```

行内公式使用单个美元符号：

```markdown
损失函数记为 $L(y, f(x))$。
```

块级公式使用独立的双美元符号，并在公式块前后保留空行：

```markdown
均方误差定义为：

$$
\operatorname{MSE}
= \frac{1}{n}\sum_{i=1}^{n}(y_i-\hat{y}_i)^2
$$

其中 $n$ 是样本数。
```

规则：

- LaTeX 命令中的反斜杠不要遗漏。
- 复杂公式优先使用 `aligned`、`cases` 等标准环境。
- 不使用截图代替可以由 MathJax 表达的公式。
- 发布前检查公式在窄屏下是否溢出或截断。

## 7. Mermaid 图规范

文章包含 Mermaid 图时，Front Matter 必须添加：

```yaml
mermaid: true
```

示例：

````markdown
```mermaid
flowchart LR
    A[输入] --> B[处理]
    B --> C[输出]
```
````

规则：

- 图节点文字保持简短。
- 使用稳定、易懂的方向，如 `LR` 或 `TD`。
- 节点 ID 使用 ASCII 字母和数字。
- Mermaid 代码块内不要混入 Markdown 语法。
- 本地预览时确认页面显示 SVG，而不是原始 Mermaid 源码。

## 8. 代码块规范

代码块必须声明语言：

````markdown
```python
model.fit(features, labels)
```
````

命令行示例使用 `console`、`shell` 或 `powershell`：

````markdown
```powershell
bundle exec jekyll serve
```
````

需要显示文件名时，使用 Chirpy 的 `file` 属性：

````markdown
```yaml
math: true
```
{: file="Front Matter" }
````

隐藏行号时添加：

```markdown
{: .nolineno }
```

## 9. 链接规范

### 9.1 外部链接

可直接使用标准 Markdown 链接：

```markdown
[Jekyll 文档](https://jekyllrb.com/docs/posts/)
```

纯 URL 可以使用尖括号：

```markdown
<https://jekyllrb.com/>
```

### 9.2 站内文章链接

站内文章优先使用 Jekyll 的 `post_url`，避免硬编码最终 URL。

同级文章示例：

```liquid
[下一章]({% post_url 2026-07-26-example-next-chapter %})
```

位于子目录中的文章必须包含 `_posts/` 之后的相对路径，且不要写 `.md`：

```liquid
[第 1 章]({% post_url book-notes/machine-learning/example-book/2026-07-26-example-ch01 %})
```

规则：

- `post_url` 中的名称必须与目标文件名完全一致，但省略 `.md`。
- 目标文章必须存在并且在构建时已经发布。
- 重命名文章后，要同步更新所有 `post_url` 引用。
- 发布前必须运行 Jekyll 构建，以发现不存在的文章链接。

### 9.3 知识关系

正文中的上下文链接继续使用 `post_url`。需要出现在文章底部 Related Notes 和目标文章 Backlinks 中的核心关系，使用 `related` 声明目标 `uid`：

```yaml
related:
  - prompt-evaluation
  - reliable-ai-systems
```

规则：

- 只能引用已存在文章的 `uid`，不能引用文件名或 URL。
- 不要引用当前文章自己的 `uid`，同一目标不要重复声明。
- 只连接确实有知识关系的节点，不把同标签下的所有文章都列入。
- Backlinks 由构建插件自动生成，不在 Front Matter 中手动维护。

### 9.4 References

文章引用书籍、论文、文档或外部资料时，使用结构化 `references`：

```yaml
references:
  - title: "资料标题"
    url: "https://example.com/"
    note: "可选：说明该资料提供了什么。"
```

`title` 和 `url` 必填，`note` 可选。只列出实际使用且来源明确的资料，不为填满版面添加未经核实的链接。

## 10. 图片和媒体规范

图片建议存放在：

```text
assets/img/posts/<article-slug>/
```

正文图片示例：

```markdown
![架构图说明](/assets/img/posts/consensus-basics/architecture.png){: width="1200" height="630" }
_图 1：系统整体架构_
```

规则：

- 文件名使用小写 ASCII slug。
- 提供准确的替代文本，不写无意义的 `image` 或 `图片`。
- 尽量填写 `width` 和 `height`，减少页面加载时的布局跳动。
- 大图片在提交前进行压缩。
- 图片只服务于当前文章时，按文章 slug 建立独立目录。
- 不引用仅存在于本机的绝对路径。

文章预览图示例：

```yaml
image:
  path: /assets/img/posts/consensus-basics/cover.png
  alt: "共识算法节点通信示意图"
```

## 11. 读书笔记专项规范

读书笔记推荐采用三级分类：

```yaml
categories: [读书笔记, 领域, 书名]
```

推荐目录：

```text
_posts/book-notes/<field>/<book-slug>/
```

推荐文件名：

```text
YYYY-MM-DD-<book-slug>-notes.md
YYYY-MM-DD-<book-slug>-ch01-<chapter-slug>.md
YYYY-MM-DD-<book-slug>-ch02-<chapter-slug>.md
```

一本书可以包含一篇索引文章和多篇章节文章。索引文章负责维护阅读进度，并使用 `post_url` 链接到各章节。

完整章节模板：

```markdown
---
title: "《书名》第 1 章：章节标题"
date: 2026-07-26 00:11:00 +0800
updated: 2026-07-26
uid: book-slug-ch01
type: reading
content_lang: zh-CN
status: growing
topics: [machine-learning]
series: book-slug
series_order: 2
categories: [读书笔记, 领域, 书名]
tags: [topic, reading-notes]
description: "本章内容的简短摘要。"
toc: true
math: true
mermaid: true
---

> 原书：*Book Title*  
> 章节：Chapter 1, Chapter Title  
> 资料：<https://example.com/>

## 本章目标

1. 目标一；
2. 目标二；
3. 目标三。

## 一句话概括

用一段话概括本章的核心结论。

## 1. 核心概念

正文。

## 2. 推导或案例

正文。

## 3. 常见误区

正文。

## 本章总结

总结关键结论。
```

不需要公式或 Mermaid 时，删除对应字段和示例内容。

## 12. 草稿规范

未准备发布的文章应放在 `_drafts/`，文件名不需要日期：

```text
_drafts/consensus-basics.md
```

预览草稿：

```powershell
bundle exec jekyll serve --drafts
```

准备发布时：

1. 将文件移入 `_posts/` 的目标目录。
2. 将文件名改为 `YYYY-MM-DD-slug.md`。
3. 添加或校正 Front Matter 的 `date`。
4. 执行完整验证。

## 13. 本地验证

### 13.1 本地预览

```powershell
bundle exec jekyll serve
```

浏览器访问：

```text
http://127.0.0.1:4000/
```

重点检查：

- 文章是否出现在首页、分类页和标签页。
- 标题、日期、摘要、分类和标签是否正确。
- 目录是否完整且标题层级正确。
- 公式是否由 MathJax 渲染。
- Mermaid 是否渲染为 SVG，原始代码是否隐藏。
- 图片、代码块、表格和站内链接是否正常。
- 浏览器控制台是否有脚本错误或失败请求。

### 13.2 生产构建

PowerShell：

```powershell
$env:JEKYLL_ENV = "production"
bundle exec jekyll build -d _site
```

构建必须以退出码 `0` 完成，且不能出现以下问题：

- `Liquid Exception`
- `Could not find post`
- 文章因 future date 被跳过
- 缺失布局、插件或资源

构建后运行数字花园验收：

```powershell
bundle exec ruby tools/validate-garden.rb _site
bundle exec ruby tools/content-quality.rb --check
```

该检查覆盖内容语言、Series 顺序、Topic 页面、Reading/Search 数据、Featured 入口和 Ultra-long 章节锚点。

### 13.3 链接检查

```powershell
bundle exec htmlproofer _site --disable-external --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

检查必须无内部链接和锚点错误。

## 14. 提交前检查清单

- [ ] 文件位于 `_posts/` 的正确目录。
- [ ] 文件名符合 `YYYY-MM-DD-slug.md`。
- [ ] 文件名日期与 Front Matter 日期一致。
- [ ] 发布时间不是未来时间。
- [ ] `uid` 全站唯一，发布后保持稳定。
- [ ] `type`、`status` 和 `topics` 使用允许的值。
- [ ] `content_lang` 与正文主要语言一致。
- [ ] `title`、`date`、`updated` 和 `description` 已填写。
- [ ] Series 内容具有连续且不重复的 `series_order`。
- [ ] 新 Topic 已在 `_data/topics.yml` 中定义。
- [ ] `featured: true` 时已填写 `why_start_here`。
- [ ] 兼容用的 `categories` 和 `tags` 已填写。
- [ ] 分类从宽到窄，名称与现有分类一致。
- [ ] 标签使用小写英文和连字符。
- [ ] 正文没有重复一级标题。
- [ ] 标题层级连续。
- [ ] 含公式时已设置 `math: true`。
- [ ] 含 Mermaid 时已设置 `mermaid: true`。
- [ ] `post_url` 路径与目标文件完全一致。
- [ ] `related` 中的 UID 存在、无重复且没有自引用。
- [ ] `references` 的标题和 URL 完整且经过核实。
- [ ] 图片路径、替代文本和尺寸正确。
- [ ] 生产构建成功。
- [ ] `tools/validate-garden.rb` 检查成功。
- [ ] HTMLProofer 检查成功。
- [ ] 没有误提交本地 `book-notes/` 源副本或 `_site/` 构建产物。

## 15. 发布流程

1. 只暂存需要发布的文章和资源。
2. 使用清晰的提交信息提交变更。
3. 推送到远端 `master` 分支。
4. 在 GitHub Actions 中确认 `Build and Deploy` 成功。
5. 打开公网文章，复查分类、链接、公式、图表和资源加载。

推荐提交信息：

```text
Add notes for <book or topic>
```

或：

```text
Publish <article title>
```
