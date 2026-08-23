# 为 Jingze's Garden 做贡献

Jingze's Garden 是个人网站和公开知识花园，不是通用 Jekyll 主题发行版。这里欢迎针对本站代码、
可访问性、文档、失效链接和事实性错误的反馈；文章观点、写作取舍和内容发布节奏由站点作者维护。

参与前请遵守 [行为准则](CODE_OF_CONDUCT.md)。安全问题不要提交公开 Issue，请按
[安全策略](SECURITY.md) 私下报告。

## 可以反馈什么

- 页面无法访问、布局溢出、键盘操作或屏幕阅读器问题；
- 站内链接、资源路径、课程时间点或来源链接失效；
- 文章中的拼写、数据、引用或技术事实错误；
- 构建、搜索、知识链接、Reading Library、Podcast 或 Course Workbench 的缺陷；
- 能够保持现有信息架构和视觉语言的小型代码或文档改进。

以下改动请先发起 Issue 讨论，不要直接提交大型 Pull Request：

- 新增内容类型、页面入口、外部服务或依赖；
- 批量改写文章、导入新的书籍或课程；
- 提交大体积媒体、官方课程镜像或自动生成资产；
- 改变 URL、front matter schema、Series/Topic 契约或部署流程。

未经讨论，请不要用生成内容批量替换作者文章，也不要把受版权保护的书籍、课程视频、付费资料或
播客音频复制到仓库。

## 报告问题

先搜索 [现有 Issues](https://github.com/JingzeChen/jingzechen.github.io/issues) 确认没有重复，再提供：

1. 出现问题的线上 URL 或仓库路径；
2. 预期行为和实际行为；
3. 可稳定复现的步骤；
4. 浏览器、操作系统和视口信息（若与界面有关）；
5. 控制台错误、截图或最小复现（若适用）。

课程和文章的事实修正请附上原始来源、章节、页码或时间点。若问题来自 Chirpy 的未修改上游功能，
也请指出这一点，便于判断应在本站修复还是向上游反馈。

## 提交改动

1. Fork 并克隆仓库，从当前默认分支创建范围明确的分支。
2. 按根目录 [README](../README.md#本地开发) 安装依赖并启动本地预览。
3. 普通文章遵循 [文章规范](POST_GUIDE.md) 和 [新文章工作流](NEW_POST_WORKFLOW.md)；课程内容遵循
	[课程维护指南](COURSES.md)。
4. 只修改解决当前问题所需的文件，不要提交 `_site/`、缓存、临时报告或无关格式化。
5. 根据改动范围执行下面的检查，并在 Pull Request 中写明实际运行结果。

基础检查：

```powershell
npm test
git diff --check
```

涉及页面、布局、插件或内容模型时，还应执行：

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

Pull Request 应说明问题背景、改动边界、验证结果和任何未覆盖风险。一个 Pull Request 尽量只解决
一个问题，提交信息使用清晰的祈使句或 Conventional Commit 风格。

## 内容与来源

文章和个人笔记的最终编辑权属于站点作者。课程、书籍和播客相关贡献必须保留来源链接，不得暗示本站
与学校、授课教师、出版社或节目制作方存在官方关系。第三方材料仍受其原始许可和使用条款约束。
