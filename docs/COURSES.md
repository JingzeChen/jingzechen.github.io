# Course content model

课程内容使用独立的 `courses` collection，避免把课程、模块和讲次压成普通文章。公开页面有三层：

```text
/courses/
  -> /courses/<course>/
     -> /courses/<course>/modules/<number>/
     -> /courses/<course>/lectures/<number>/
```

## Registry

每门课程先在 `_data/courses.yml` 注册。`course_url` 指课程主页，`source_url` 指用户最初提供的课程入口；两者都不限定视频平台。

## Lecture contract

讲次 frontmatter 的核心字段如下：

```yaml
type: course
document_type: lecture
course: cmu-csapp-f15
module_number: 1
lecture_number: 1
duration_seconds: 4501
media_sources:
  - provider: youtube
    label: YouTube
    url: https://www.youtube.com/watch?v=...
    embed_url: https://www.youtube-nocookie.com/embed/...?enablejsapi=1
    seek_template: https://www.youtube.com/watch?v=...&t={seconds}s
  - provider: panopto
    label: Panopto
    url: https://...
transcript:
  jsonl: /assets/courses/<course>/lectures/001/transcript.jsonl
  txt: /assets/courses/<course>/lectures/001/transcript.txt
slides:
  download: /assets/courses/<course>/slides/deck.pptx
  manifest: /assets/courses/<course>/lectures/001/slides.json
timeline: /assets/courses/<course>/lectures/001/timeline.json
```

`media_sources` 是有序列表，不要求 Panopto 或 YouTube。已知平台可以提供 `embed_url`；Bilibili、其他视频站或未知 provider 若不能稳定嵌入，只保留 HTTPS `url` 也可正常显示。不要把 `source.mp4` 提交到网站仓库。

`transcript`、`slides` 都是可选能力。幻灯片优先级为静态 image manifest、PDF iframe、原 PPTX 下载；缺少其中一项不会影响 notes。当前 CSAPP 使用预渲染 JPEG 与原 PPTX。

## Section alignment

`timeline.json` 是 notes、transcript、slides 和视频之间唯一的对齐契约：

```json
{
  "sections": [
    {
      "id": "section-01",
      "title": "Course theme",
      "start": 313,
      "end": 454,
      "note_anchor": "section-01",
      "slides": [3, 4]
    }
  ]
}
```

不要在浏览器端从标题猜时间或页码。导入阶段应从结构化章节、section 时间范围和课件引用生成 timeline；transcript 仍保留逐句 JSONL，页面打开时再按 timeline 分组。

## Import and render

CSAPP 源资料可重复导入：

```powershell
bundle exec ruby tools\import-course.rb `
  <course-source-directory> cmu-csapp-f15
```

在 Windows + PowerPoint 环境中预渲染课件：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\tools\render-course-slides.ps1 `
  -SourceDirectory <course-source-directory>\official-materials `
  -OutputDirectory .\assets\courses\cmu-csapp-f15\slides\rendered
```

渲染完成后再次运行 importer，使讲次 manifest 发现新图片。其他环境可以自行生成同名的 `slide-001.jpg` 文件，或直接提供 PDF/外部资源 URL。

## Validation

```powershell
npm run build:course-js
bundle exec jekyll build --config _config.yml,tools/course-build.yml
bundle exec ruby tools/validate-courses.rb _site
```

完整站点发布前还要使用标准配置执行 Reading Guide、容量、Garden、Course、内容质量和链接检查；
命令以根目录 [README](../README.md#验证) 和 `.github/workflows/pages-deploy.yml` 为准。