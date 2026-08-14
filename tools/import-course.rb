# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require "uri"
require "yaml"

SOURCE_DIR = Pathname.new(ARGV.fetch(0) do
  abort "Usage: ruby tools/import-course.rb SOURCE_DIR COURSE_SLUG"
end).expand_path
COURSE_SLUG = ARGV.fetch(1) do
  abort "Usage: ruby tools/import-course.rb SOURCE_DIR COURSE_SLUG"
end
REPO_DIR = Pathname.new(__dir__).join("..").expand_path
COURSE_OUTPUT_DIR = REPO_DIR.join("_courses", COURSE_SLUG)
ASSET_OUTPUT_DIR = REPO_DIR.join("assets", "courses", COURSE_SLUG)

abort "Missing source directory: #{SOURCE_DIR}" unless SOURCE_DIR.directory?

def read_json(path)
  JSON.parse(path.read(encoding: "UTF-8"))
end

def write_text(path, content)
  FileUtils.mkdir_p(path.dirname)
  path.write(content, encoding: "UTF-8")
end

def front_matter(data)
  YAML.dump(data, line_width: -1).sub(/\A---\s*\n/, "---\n") + "---\n\n"
end

def imported_document(data, body)
  front_matter(data) + "{% raw %}\n" + body.rstrip + "\n{% endraw %}\n"
end

def strip_document_title(markdown)
  markdown.sub(/\A#\s+.+?\r?\n+/, "")
end

def seconds_from_timestamp(value)
  parts = value.split(":").map(&:to_f)
  parts.unshift(0) until parts.length == 3
  parts[0] * 3600 + parts[1] * 60 + parts[2]
end

def display_duration(total_seconds)
  seconds = total_seconds.to_i
  hours = seconds / 3600
  minutes = seconds % 3600 / 60
  format("%d:%02d", hours, minutes)
end

def slugify(value)
  value.downcase
       .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-|\z-/, "")
end

def provider_for(url)
  host = URI.parse(url).host.to_s.downcase
  return "youtube" if host.include?("youtube.com") || host == "youtu.be"
  return "bilibili" if host.include?("bilibili.com") || host == "b23.tv"
  return "panopto" if host.include?("panopto.com")

  host.sub(/\Awww\./, "").split(".").first.to_s.then { |name| name.empty? ? "video" : name }
rescue URI::InvalidURIError
  "video"
end

def source_for(url)
  provider = provider_for(url)
  source = {
    "provider" => provider,
    "label" => provider == "video" ? "Original video" : provider.capitalize,
    "url" => url
  }

  if provider == "youtube"
    uri = URI.parse(url)
    video_id = uri.host == "youtu.be" ? uri.path.delete_prefix("/") : URI.decode_www_form(uri.query.to_s).to_h["v"]
    if video_id && !video_id.empty?
      source["label"] = "YouTube"
      source["embed_url"] = "https://www.youtube-nocookie.com/embed/#{video_id}?enablejsapi=1"
      source["seek_template"] = "https://www.youtube.com/watch?v=#{video_id}&t={seconds}s"
    end
  elsif provider == "bilibili"
    video_id = url[%r{(?:video/)?(BV[a-zA-Z0-9]+)}, 1]
    if video_id
      source["label"] = "Bilibili"
      source["embed_url"] = "https://player.bilibili.com/player.html?bvid=#{video_id}"
    end
  elsif provider == "panopto"
    source["label"] = "Panopto"
  end

  source
rescue URI::InvalidURIError
  source
end

def local_asset_url(*parts)
  "/" + ["assets", "courses", COURSE_SLUG, *parts].join("/")
end

course = read_json(SOURCE_DIR.join("course.json"))
manifest_path = SOURCE_DIR.join("source-manifest.json")
source_manifest = manifest_path.file? ? read_json(manifest_path) : course
registry = YAML.safe_load_file(REPO_DIR.join("_data", "courses.yml"), aliases: true)
course_meta = registry.fetch(COURSE_SLUG)

lectures = course.fetch("lectures").sort_by { |lecture| lecture.fetch("index") }
lectures_by_number = lectures.to_h { |lecture| [lecture.fetch("index"), lecture] }
manifest_lectures = Array(source_manifest["lectures"]).to_h { |lecture| [lecture.fetch("index"), lecture] }

module_sources = SOURCE_DIR.join("modules").glob("*.md").sort
module_ranges = []

module_sources.each do |path|
  markdown = path.read(encoding: "UTF-8")
  module_number = path.basename.to_s[/\A(\d+)/, 1].to_i
  title = markdown[/\A#\s+(.+)$/, 1].to_s.strip
  range_match = markdown.match(/Lectures?\s+(\d+)\s*[-–]\s*(\d+)/i)
  referenced_lectures = markdown.scan(/Lecture\s+(\d{1,2})\b/i).flatten.map(&:to_i).uniq.sort
  first_lecture = range_match ? range_match[1].to_i : referenced_lectures.first
  last_lecture = range_match ? range_match[2].to_i : referenced_lectures.last
  abort "Cannot infer lecture range from #{path}" unless first_lecture && last_lecture
  description = markdown[/^>\s*目标：(.+?)(?:\s{2,})?$/, 1]&.strip
  description ||= markdown[/^##\s+模块(?:目的|用途)\s*$\s+\n+([^\n]+)/, 1]&.strip
  description ||= "连接 Lecture #{first_lecture}–#{last_lecture} 的概念、证据与掌握路径。"
  module_ranges << (first_lecture..last_lecture).to_a.to_h { |number| [number, module_number] }

  data = {
    "uid" => "#{COURSE_SLUG}-module-#{format('%02d', module_number)}",
    "type" => "course",
    "document_type" => "module",
    "course" => COURSE_SLUG,
    "module_number" => module_number,
    "title" => title,
    "description" => description,
    "excerpt" => description,
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "permalink" => "/courses/#{COURSE_SLUG}/modules/#{format('%02d', module_number)}/",
    "toc" => true
  }

  body = strip_document_title(markdown)
  body.gsub!(%r{\]\(\.\./lectures/(\d{3})-[^)]*/NOTES\.md\)}) do
    "](/courses/#{COURSE_SLUG}/lectures/#{Regexp.last_match(1)}/)"
  end
  write_text(
    COURSE_OUTPUT_DIR.join("modules", "#{format('%02d', module_number)}-#{path.basename.to_s.sub(/\A\d+-/, '')}"),
    imported_document(data, body)
  )
end

lecture_modules = module_ranges.reduce({}) { |combined, mapping| combined.merge(mapping) }

def lecture_directory(source_dir, lecture)
  configured = lecture["directory"]
  return source_dir.join(configured.tr("\\", "/")) if configured

  match = source_dir.join("lectures").glob("#{format('%03d', lecture.fetch('index'))}-*").first
  abort "Missing directory for lecture #{lecture.fetch('index')}" unless match

  match
end

def rewrite_links(markdown, lectures_by_number, course_slug)
  markdown.gsub!(%r{\]\((?:\./)?modules/(\d{2})-[^)]+\.md\)}) do
    "](/courses/#{course_slug}/modules/#{Regexp.last_match(1)}/)"
  end
  markdown.gsub!(%r{\]\((?:\.\./)?lectures/(\d{3})-[^)]*/NOTES\.md(?:#L\d+)?\)}) do
    "](/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/)"
  end
  markdown.gsub!(%r{\]\((?:\.\./)?lectures/(\d{3})-[^)]*/transcript\.(jsonl|txt|srt)\)}) do
    number = Regexp.last_match(1)
    extension = Regexp.last_match(2)
    "](/assets/courses/#{course_slug}/lectures/#{number}/transcript.#{extension})"
  end
  markdown.gsub!(%r{\]\((?:\.\./)?lectures/(\d{3})-[^)]*/source\.mp4\)}) do
    lecture = lectures_by_number[Regexp.last_match(1).to_i]
    url = lecture["original_url"] || lecture["url"]
    "](#{url})"
  end
  markdown.gsub!(%r{\]\((?:\.\./)?official-materials/([^)]+\.pptx)\)}) do
    "](/assets/courses/#{course_slug}/slides/#{Regexp.last_match(1)})"
  end
  markdown.gsub!(%r{\]\(notes/sections/(\d{3})\.md\)}) do
    "](#section-#{format('%02d', Regexp.last_match(1).to_i)})"
  end
  markdown.gsub!(%r{\]\(REVIEW_CHECKLIST\.md\)}, "](/courses/#{course_slug}/review-checklist/)")
  markdown.gsub!(%r{\]\((?:README\.md|COURSE_SUMMARY\.md|course\.json|source-manifest\.json|official-materials/)\)}, "](/courses/#{course_slug}/)")
  markdown
end

lecture_count = 0
transcript_count = 0
timeline_count = 0
pptx_files = {}

lectures.each do |lecture|
  number = lecture.fetch("index")
  number_label = format("%03d", number)
  source_lecture = manifest_lectures.fetch(number, lecture)
  directory = lecture_directory(SOURCE_DIR, lecture)
  notes_path = directory.join("NOTES.md")
  abort "Missing NOTES.md for Lecture #{number}" unless notes_path.file?

  notes = notes_path.read(encoding: "UTF-8")
  description = notes[/^>\s*本讲实际覆盖：(.+?)\s*(?:\[课件:|$)/, 1]&.strip
  description ||= "按课堂推进顺序整理视频、课件与 transcript，并保留可回查的时间和页码。"

  media_urls = [source_lecture["original_url"], source_lecture["url"], lecture["original_url"], lecture["url"]]
               .compact
               .reject(&:empty?)
               .uniq
  media_sources = media_urls.map { |url| source_for(url) }

  lecture_asset_dir = ASSET_OUTPUT_DIR.join("lectures", number_label)
  FileUtils.mkdir_p(lecture_asset_dir)
  transcript = {}
  %w[jsonl txt srt].each do |extension|
    source = directory.join("transcript.#{extension}")
    next unless source.file?

    FileUtils.cp(source, lecture_asset_dir.join(source.basename))
    transcript[extension] = local_asset_url("lectures", number_label, source.basename.to_s)
    transcript_count += 1
  end
  transcript["status"] = "auto-generated" unless transcript.empty?

  material_paths = Array(source_lecture["materials"] || lecture["materials"])
  material_names = material_paths.map { |material| Pathname.new(material.tr("\\", "/")).basename.to_s }.uniq
  material_names.each do |filename|
    source = SOURCE_DIR.join("official-materials", filename)
    source = directory.join("materials", filename) unless source.file?
    next unless source.file?

    destination = ASSET_OUTPUT_DIR.join("slides", filename)
    FileUtils.mkdir_p(destination.dirname)
    FileUtils.cp(source, destination)
    pptx_files[filename] = destination
  end

  slide_titles = {}
  materials_jsonl = directory.join("materials.jsonl")
  if materials_jsonl.file?
    materials_jsonl.each_line do |line|
      next if line.strip.empty?

      row = JSON.parse(line)
      slide_titles[row.fetch("page_number").to_i] = row["title"].to_s.strip
    end
  end

  summary_sections = {}
  summary_input = directory.join("summary-input.jsonl")
  if summary_input.file?
    summary_input.each_line do |line|
      next if line.strip.empty?

      row = JSON.parse(line)
      summary_sections[row.fetch("index").to_i] = row
    end
  end

  section_headings = {}
  sections = directory.join("notes", "sections").glob("*.md").sort.filter_map do |section_path|
    section_markdown = section_path.read(encoding: "UTF-8")
    section_number = section_path.basename(".md").to_s.to_i
    section_heading = section_markdown.lines.first.to_s.strip
    section_headings[section_number] = section_heading
    title = section_markdown[/\A#\s+(.+)$/, 1].to_s.sub(/\A第\s*\d+\s*节[：:]\s*/, "").strip
    title = title.sub(/\A第\s*\d+\s*段[：:]\s*/, "").sub(/\s*[（(]\d{2}:\d{2}:\d{2}.*\z/, "").strip
    summary_section = summary_sections[section_number]
    time_match = section_markdown.lines.first(12).join.match(
      /(\d{2}:\d{2}:\d{2}(?:\.\d+)?)\s*[-–]\s*(\d{2}:\d{2}:\d{2}(?:\.\d+)?)/
    )
    start_time = summary_section && summary_section["start"] || time_match && seconds_from_timestamp(time_match[1])
    end_time = summary_section && summary_section["end"] || time_match && seconds_from_timestamp(time_match[2])
    next unless start_time && end_time

    slides = section_markdown.scan(/\[课件:\s*[^\]]+?\s+p\.(\d+)\]/).flatten.map(&:to_i).uniq.sort
    {
      "id" => "section-#{format('%02d', section_number)}",
      "title" => title,
      "start" => start_time,
      "end" => end_time,
      "note_anchor" => "section-#{format('%02d', section_number)}",
      "slides" => slides
    }
  end

  timeline_path = lecture_asset_dir.join("timeline.json")
  write_text(timeline_path, JSON.pretty_generate({ "sections" => sections }) + "\n")
  timeline_count += sections.length

  slide_manifest_url = nil
  unless material_names.empty?
    rendered_dir = ASSET_OUTPUT_DIR.join("slides", "rendered", File.basename(material_names.first, ".pptx"))
    pages = rendered_dir.glob("slide-*.jpg").sort.map.with_index(1) do |image, index|
      page = image.basename(".jpg").to_s[/\d+/, 0].to_i
      page = index if page.zero?
      {
        "page" => page,
        "title" => slide_titles[page].to_s,
        "src" => local_asset_url("slides", "rendered", rendered_dir.basename.to_s, image.basename.to_s)
      }
    end
    unless pages.empty?
      slide_manifest_path = lecture_asset_dir.join("slides.json")
      write_text(slide_manifest_path, JSON.pretty_generate({ "pages" => pages }) + "\n")
      slide_manifest_url = local_asset_url("lectures", number_label, "slides.json")
    end
  end

  slides = nil
  unless material_names.empty?
    slides = {
      "download" => local_asset_url("slides", material_names.first)
    }
    slides["manifest"] = slide_manifest_url if slide_manifest_url
  end

  data = {
    "uid" => "#{COURSE_SLUG}-lecture-#{number_label}",
    "type" => "course",
    "document_type" => "lecture",
    "course" => COURSE_SLUG,
    "module_number" => lecture_modules.fetch(number),
    "lecture_number" => number,
    "title" => lecture.fetch("title"),
    "description" => description,
    "excerpt" => description,
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "duration" => display_duration(lecture.fetch("duration_seconds")),
    "duration_seconds" => lecture.fetch("duration_seconds").to_i,
    "media_sources" => media_sources,
    "transcript" => transcript,
    "timeline" => local_asset_url("lectures", number_label, "timeline.json"),
    "permalink" => "/courses/#{COURSE_SLUG}/lectures/#{number_label}/",
    "toc" => true
  }
  data["slides"] = slides if slides

  body = strip_document_title(notes)
  section_headings.each do |section_number, heading|
    anchor = "section-#{format('%02d', section_number)}"
    anchor_markup = "<div id=\"#{anchor}\" class=\"course-note-section-anchor\" aria-hidden=\"true\">&nbsp;</div>"
    heading_text = heading.sub(/\A\#{1,6}\s+/, "")
    replaced = body.sub!(/^\#{1,6}\s+#{Regexp.escape(heading_text)}$/) do |matched_heading|
      "#{anchor_markup}\n\n#{matched_heading}"
    end
    next if replaced

    embed_marker = "<!-- BEGIN EMBED notes/sections/#{format('%03d', section_number)}.md -->"
    replaced = body.sub!(embed_marker, "#{embed_marker}\n#{anchor_markup}")
    next if replaced

    section_link = "[notes/sections/#{format('%03d', section_number)}.md](notes/sections/#{format('%03d', section_number)}.md)"
    replaced = body.sub!(/^.*#{Regexp.escape(section_link)}.*$/) do |line|
      "#{anchor_markup}\n\n#{line}"
    end
    next if replaced

    body.sub!(/^###\s+#{section_number}[.、]\s+.*\d{2}:\d{2}:\d{2}.*$/) do |timestamp_heading|
      "#{anchor_markup}\n\n#{timestamp_heading}"
    end
  end

  missing_anchors = sections.reject { |section| body.include?("id=\"#{section['note_anchor']}\"") }
  unless missing_anchors.empty?
    abort "Cannot place note anchors for Lecture #{number}: #{missing_anchors.map { |section| section['id'] }.join(', ')}"
  end
  rewrite_links(body, lectures_by_number, COURSE_SLUG)
  write_text(COURSE_OUTPUT_DIR.join("lectures", "#{number_label}.md"), imported_document(data, body))
  lecture_count += 1
end

overview_path = SOURCE_DIR.join("COURSE_SUMMARY.md")
if overview_path.file?
  overview = strip_document_title(overview_path.read(encoding: "UTF-8"))
  rewrite_links(overview, lectures_by_number, COURSE_SLUG)
  overview_data = {
    "uid" => "#{COURSE_SLUG}-overview",
    "type" => "course",
    "document_type" => "overview",
    "course" => COURSE_SLUG,
    "title" => course_meta.fetch("title"),
    "description" => course_meta.fetch("description"),
    "excerpt" => course_meta.fetch("description"),
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "permalink" => "/courses/#{COURSE_SLUG}/",
    "toc" => true
  }
  write_text(REPO_DIR.join("_courses", "#{COURSE_SLUG}.md"), imported_document(overview_data, overview))
end

review_path = SOURCE_DIR.join("REVIEW_CHECKLIST.md")
if review_path.file?
  review = review_path.read(encoding: "UTF-8")
  review_title = review[/\A#\s+(.+)$/, 1].to_s.strip
  review = strip_document_title(review)
  rewrite_links(review, lectures_by_number, COURSE_SLUG)
  review_data = {
    "uid" => "#{COURSE_SLUG}-review-checklist",
    "type" => "course",
    "document_type" => "resource",
    "course" => COURSE_SLUG,
    "title" => review_title,
    "description" => "按风险回查自动 transcript、课件与视频中的未决证据。",
    "excerpt" => "按风险回查自动 transcript、课件与视频中的未决证据。",
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "permalink" => "/courses/#{COURSE_SLUG}/review-checklist/",
    "toc" => true
  }
  write_text(COURSE_OUTPUT_DIR.join("review-checklist.md"), imported_document(review_data, review))
end

puts "Imported #{COURSE_SLUG}:"
puts "  #{module_sources.length} modules"
puts "  #{lecture_count} lectures"
puts "  #{timeline_count} aligned sections"
puts "  #{transcript_count} transcript assets"
puts "  #{pptx_files.length} PPTX files"