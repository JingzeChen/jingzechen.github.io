# Jingze's Garden

[![Build and Deploy](https://github.com/JingzeChen/jingzechen.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/JingzeChen/jingzechen.github.io/actions/workflows/pages-deploy.yml)

Jingze's Garden 是 Jingze Chen 的个人网站与公开知识花园，在线地址为
[https://jingzechen.github.io](https://jingzechen.github.io)。这里持续整理我在 AI、软件工程、
公开课程、阅读、播客、项目和生活中的学习过程，而不是只保存写完即归档的文章。

本站的重点是把长篇材料加工成可连续阅读、可回到原始来源核验、也可继续修订的知识：
一本书会形成按章节组织的 Reading Series，一门公开课会把视频、幻灯片、逐字稿、讲义和笔记
放在同一条学习路径里，一期长播客则会被整理成摘要、时间点目录和可检索的转写。

## 网站内容

根据自动生成的 [内容质量报告](docs/CONTENT_QUALITY_REPORT.md)，当前内容主要由以下部分组成：

- **Reading**：按书籍和主题组织的中文阅读笔记。每个 Series 包含前言、章节、附录和系列导航，
  适合顺序阅读，也可以从 Topic、搜索或关联笔记横向进入。
- **Courses**：对公开课程的系统化学习整理。课程页面聚合模块、单讲笔记、视频时间轴、幻灯片、
  transcript、reading guide、代码与原始资源入口。
- **Listening**：长篇播客和访谈笔记，包含内容摘要、分章时间点、关键观点和逐字稿，便于回到
  原节目核对语境。
- **Notes / Essays / Journal / Ideas / Projects**：知识花园为工作笔记、长文、日志、想法和项目记录
  保留的内容类型。当前公开内容以 Reading 和 Listening 为主，这些栏目会随实际写作逐步生长。
- **Topics / Series / Connections**：文章不仅按时间排列，还通过 Topic、Series、双向知识链接和
  相关文章形成可继续探索的关系网络。

截至 2026-08-23，报告收录 450 篇内容、28 个 Series，其中包括 439 篇 Reading 和 11 篇
Podcast Notes。该数字会随内容更新而变化，请以生成报告为准。

## 课程资料库

本站目前整理四门公开课程。课程笔记以中文为主，同时保留英文原始材料和官方课程入口。

| 课程 | 学期 | 内容重点 |
| --- | --- | --- |
| [CMU 15-213/15-513 Introduction to Computer Systems](https://jingzechen.github.io/courses/cmu-csapp-f15/) | Fall 2015 | 数据表示、机器代码、存储层次、链接、虚拟内存、网络与并发 |
| [MIT 6.824 Distributed Systems](https://jingzechen.github.io/courses/mit-6824-s21/) | Spring 2021 | 故障、复制、Raft、事务、分布式存储与去中心化系统 |
| [CMU 11-785 Introduction to Deep Learning](https://jingzechen.github.io/courses/cmu-11785-s26/) | Spring 2026 | 神经网络、CNN、序列模型、Transformer、生成模型、GNN 与强化学习 |
| [Stanford CS336 Language Modeling from Scratch](https://jingzechen.github.io/courses/stanford-cs336-s26/) | Spring 2026 | 分词、Transformer、Kernel、并行训练、Scaling Laws、评估、数据与后训练 |

课程内容的目录约定、资源模型、导入命令和验证方法见 [课程维护指南](docs/COURSES.md)。课程笔记是
对公开教学材料的个人学习整理，不代替官方课程、作业要求或原作者说明。

## 如何浏览网站

1. 从 [Reading](https://jingzechen.github.io/reading/) 选择一本书或一个 Topic，再通过章节导航连续阅读。
2. 从 [Courses](https://jingzechen.github.io/courses/) 选择课程和模块，在单讲页面切换笔记、视频、幻灯片、
   transcript、reading 和代码资源。
3. 从 [Listening](https://jingzechen.github.io/podcasts/) 阅读播客摘要，再用时间点跳转到原节目或转写位置。
4. 使用站内搜索查找标题、摘要和正文；也可以通过 Categories、Tags 和 Archives 浏览。
5. 在文章页使用目录、上一篇/下一篇、系列导航和关联内容继续探索。长文支持 Focus Mode，网站也支持
   PWA 安装和离线缓存。

内容状态使用 `seedling`、`growing` 和 `evergreen` 表示成熟度。这里的笔记会持续修订，旧文章的
`updated` 时间和内容变化通常比发布时间更值得关注。

## 技术实现

本站从 [Chirpy Jekyll Theme](https://github.com/cotes2020/jekyll-theme-chirpy) 7.6.0 演化而来，
但已经加入面向数字花园和课程资料库的定制数据模型、页面、组件、脚本与验证规则。

- **静态站点**：Jekyll、Liquid、Kramdown、Rouge 和 Sass。
- **前端资源**：原生 JavaScript、Rollup、Bootstrap，以及由 npm 管理的 lint/build 工具。
- **内容模型**：Jekyll posts、`courses` collection、YAML 数据文件和自定义 front matter schema。
- **站点能力**：全文搜索、Series/Topic 导航、知识链接、Reading Guide、课程 Workbench、Podcast
  transcript、MathJax、Mermaid、PWA 和 Atom Feed。
- **质量保障**：自定义 Ruby 校验器、ESLint、Stylelint、HTMLProofer 和站点体积预算。
- **部署与观测**：GitHub Actions 构建并发布到 GitHub Pages；GoatCounter 用于匿名聚合统计，
  定时健康检查负责探测线上可用性。

核心目录：

```text
_posts/                 Reading 与 Podcast 等文章源文件
_courses/               课程首页、模块页和单讲笔记
_data/                   Series、Topic、课程资源、阅读指南等结构化数据
_tabs/                   顶部与侧边栏入口页面
_layouts/、_includes/    页面布局和可复用组件
_plugins/                内容 schema、知识链接、搜索和 Topic 页面生成逻辑
_javascript/、_sass/     交互与样式源文件
assets/courses/          课程幻灯片、transcript、代码和其他站内资源
tools/                   导入、生成、校验和站点预算脚本
docs/                    写作、课程、运维和设计文档
```

`_site/` 是构建产物，不应作为内容源直接编辑。

## 本地开发

### 环境要求

- Ruby 3.4（与 GitHub Actions 保持一致）和 Bundler；
- Node.js 与 npm；
- Git。

在仓库根目录安装依赖：

```powershell
bundle install
npm install
```

构建 JavaScript/CSS 并启动本地站点：

```powershell
npm run build
bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

浏览器打开 <http://127.0.0.1:4000>。需要预览 `_drafts/` 时使用：

```powershell
bundle exec jekyll serve --drafts --host 127.0.0.1 --port 4000
```

开发 JavaScript 时可以在另一个终端持续监听：

```powershell
npm run watch:js
```

VS Code 中也可以直接运行 `Run Jekyll Server`、`Build JS & CSS`、`Build Course Pages` 等仓库任务。

## 内容维护

新增或修改普通文章前，先阅读 [文章规范](docs/POST_GUIDE.md) 和
[新文章工作流](docs/NEW_POST_WORKFLOW.md)。日常流程是：

1. 在 `_posts/` 下按 `YYYY-MM-DD-slug.md` 命名文件，并填写稳定的 `uid`、`content_type`、
   `status`、`content_lang`、`description`、`topics` 和 Series 元数据。
2. 将图片和附件放入 `assets/` 的对应目录，链接优先使用以 `/` 开头的站内路径。
3. Reading 内容同步维护 `_data/reading_guides/`；Series、Topic 和关联关系使用 `_data/` 中的
   结构化数据，不在模板中硬编码。
4. 本地构建并执行内容、链接和布局校验，通过后再提交。

课程内容涉及更多生成资产和来源追踪，不应套用普通文章流程。请按 [课程维护指南](docs/COURSES.md)
使用导入器、课程专用构建和验证命令。

## 验证

前端代码检查：

```powershell
npm test
```

与 Pages 工作流一致的主要生产检查：

```powershell
$env:JEKYLL_ENV = "production"
bundle exec ruby tools/generate-reading-guides.rb --check
bundle exec jekyll build --disable-disk-cache --destination _site
bundle exec ruby tools/check-site-budget.rb _site
bundle exec ruby tools/validate-garden.rb _site
bundle exec ruby tools/validate-courses.rb _site
bundle exec ruby tools/content-quality.rb --check
bundle exec htmlproofer _site --disable-external --ignore-files "/\/assets\/courses\/.*\/materials\/official-materials\/.*\.html$/" --ignore-urls "/^http:\/\/127.0.0.1/,/^http:\/\/0.0.0.0/,/^http:\/\/localhost/"
```

课程页面也可以独立构建和检查：

```powershell
npm run build:course-js
bundle exec jekyll build --config _config.yml,tools/course-build.yml
bundle exec ruby tools/validate-courses.rb _site
```

## 部署

推送到 `main` 或 `master` 会触发 `.github/workflows/pages-deploy.yml`：安装 Ruby 依赖、检查 Reading
Guide、执行生产构建和全部站点验证，随后把 `_site` 发布到 GitHub Pages。部署前至少确认：

```powershell
git status --short --branch
git diff --check
```

不要手工提交 `_site/` 来代替 Pages 构建。线上健康检查、站点体积阈值和统计隐私说明见
[站点可观测性手册](docs/SITE_OBSERVABILITY.md)。

## 项目文档

- [文章规范](docs/POST_GUIDE.md)：front matter、内容模型、Series/Topic、媒体和发布标准。
- [新文章工作流](docs/NEW_POST_WORKFLOW.md)：从创建文件到预览、验证和推送的逐步流程。
- [课程维护指南](docs/COURSES.md)：课程 manifest、资源目录、导入脚本、Workbench 与验证契约。
- [数字花园设计文档](docs/DIGITAL_GARDEN_REDESIGN_PRD.md)：信息架构、内容模型和体验决策。
- [内容质量报告](docs/CONTENT_QUALITY_REPORT.md)：由当前 `_posts/` 自动生成的库存与质量快照。
- [站点可观测性手册](docs/SITE_OBSERVABILITY.md)：容量预算、匿名统计、健康检查和故障处理。
- [贡献指南](docs/CONTRIBUTING.md)、[安全策略](docs/SECURITY.md) 和
  [行为准则](docs/CODE_OF_CONDUCT.md)：问题反馈、协作和安全报告方式。
- [变更记录](docs/CHANGELOG.md)：本站重要功能与内容系统的演进记录。

## 来源与许可

网站代码基于 MIT License 的 Chirpy 主题，并在此基础上持续定制。仓库许可见 [LICENSE](LICENSE)。
课程、书籍、播客及其引用材料的权利归各自作者和来源方所有；本站笔记用于个人学习、评论与知识整理，
引用时应同时核对并尊重原始来源的许可与使用条款。
