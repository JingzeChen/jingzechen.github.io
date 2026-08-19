# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require "set"
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
  content = body.rstrip
  content.gsub!(/\\\((.+?)\\\)/) { "$#{Regexp.last_match(1)}$" }
  data = data.merge("math" => true) if content.match?(/\$\$|\\\[|\\\(|\$[^$\n]+\$/)
  data = data.merge("mermaid" => true) if content.include?("```mermaid")
  content = "{% raw %}\n#{content}\n{% endraw %}" if content.match?(/\{[{%]/)
  front_matter(data) + content + "\n"
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
      source["thumbnail"] = local_asset_url("thumbnails", "#{video_id}.jpg")
    end
  elsif provider == "bilibili"
    video_id = url[%r{(?:video/)?(BV[a-zA-Z0-9]+)}, 1]
    if video_id
      uri = URI.parse(url)
      page = URI.decode_www_form(uri.query.to_s).to_h["p"]
      source["label"] = "Bilibili"
      source["embed_url"] = "https://player.bilibili.com/player.html?bvid=#{video_id}"
      source["embed_url"] += "&page=#{page}" if page && !page.empty?
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

def secure_url(url)
  url.to_s.sub(/\Ahttp:/, "https:")
end

def imported_resources(resources, include_video: false, local_material_paths: nil)
  Array(resources).filter_map do |resource|
    next if resource["category"] == "subtitle"
    next if resource["category"] == "official-video" && !include_video

    item = {
      "category" => resource["category"] || "reference",
      "title" => resource["title"] || "Course resource"
    }
    path = resource["path"].to_s.tr("\\", "/")
    if !path.empty? && SOURCE_DIR.join(path).file? && (!local_material_paths || local_material_paths.include?(path))
      item["url"] = local_asset_url("materials", path)
      item["source_url"] = secure_url(resource["url"]) if resource["url"]
    elsif resource["url"]
      item["url"] = secure_url(resource["url"])
    end
    item if item["url"]
  end
end

def rewrite_shared_links(markdown, course_slug, material_urls = {})
  markdown.gsub!(%r{\]\((?:\.\./|\./)*lectures/\d{3}-.+?/materials/([^)/]+)\)}) do
    filename = Regexp.last_match(1)
    path = "official-materials/lectures/#{filename}"
    target = material_urls[path] || "/assets/courses/#{course_slug}/materials/#{path}"
    "](#{target})"
  end
  markdown.gsub!(%r{\]\(<(?:\.\./|\./)*lectures/(\d{3})-[^>]+/NOTES\.md(?:#L\d+)?>\)}) do
    "](/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/)"
  end
  markdown.gsub!(%r{\]\(<([^>]+)>\)}, '](\1)')
  markdown.gsub!("http://", "https://")
  markdown.gsub!(%r{\]\((?:\.\./|\./)*readings/lecture-(\d{2})\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/readings/lecture-#{Regexp.last_match(1)}/#{Regexp.last_match(2)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*reading-inputs/lecture-(\d{2})\.md(#[^)]*)?\)}) do
    "](/assets/courses/#{course_slug}/evidence/reading-inputs/lecture-#{Regexp.last_match(1)}.md#{Regexp.last_match(2)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*official-lectures/lecture-(\d{2})\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/official-lectures/lecture-#{Regexp.last_match(1)}/#{Regexp.last_match(2)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*lectures/(\d{3})-[^)]*/notes/sections/(\d{3})\.md\)}) do
    "](/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/#section-#{format('%02d', Regexp.last_match(2).to_i)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*lectures/(\d{3})-.+?/NOTES\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/#{Regexp.last_match(2)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*lectures/(\d{3})-[^)]*/(transcript\.(?:jsonl|txt|srt)|summary-input\.jsonl)\)}) do
    "](/assets/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/#{Regexp.last_match(2)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*LABS\.md\)}, "](/courses/#{course_slug}/labs/)")
  markdown.gsub!(%r{\]\((?:\.\./|\./)*PRACTICE\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/practice/#{Regexp.last_match(1)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*ASSIGNMENTS\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/assignments/#{Regexp.last_match(1)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*READINGS\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/readings/#{Regexp.last_match(1)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*MATERIALS\.md(#[^)]*)?\)}) do
    "](/courses/#{course_slug}/materials/#{Regexp.last_match(1)})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*REVIEW_CHECKLIST\.md\)}, "](/courses/#{course_slug}/review-checklist/)")
  markdown.gsub!(%r{\]\((?:\.\./|\./)*(course|source-manifest|resources-lock|materials-index)\.json\)}) do
    "](/assets/courses/#{course_slug}/metadata/#{Regexp.last_match(1)}.json)"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*(official-materials/[^)#]+)(#[^)]*)?\)}) do
    path = Regexp.last_match(1)
    anchor = Regexp.last_match(2).to_s
    target = material_urls[path] || "/assets/courses/#{course_slug}/materials/#{path}"
    "](#{target}#{anchor})"
  end
  markdown.gsub!(%r{\]\((?:\.\./|\./)*(?:README\.md|COURSE_SUMMARY\.md)\)}, "](/courses/#{course_slug}/)")
  markdown.gsub!(%r{\]\((?:\./)?modules/?\)}, "](/courses/#{course_slug}/#course-outline-title)")
  markdown
end

course = read_json(SOURCE_DIR.join("course.json"))
manifest_path = SOURCE_DIR.join("source-manifest.json")
source_manifest = manifest_path.file? ? read_json(manifest_path) : course
registry = YAML.safe_load_file(REPO_DIR.join("_data", "courses.yml"), aliases: true)
course_meta = registry.fetch(COURSE_SLUG)
FileUtils.rm_rf(COURSE_OUTPUT_DIR)

official_materials_dir = SOURCE_DIR.join("official-materials")
local_material_paths = nil
if official_materials_dir.directory?
  archived_materials_dir = ASSET_OUTPUT_DIR.join("materials", "official-materials")
  FileUtils.rm_rf(archived_materials_dir)
  FileUtils.mkdir_p(archived_materials_dir.dirname)
  archive_patterns = Array(course_meta["archive_material_patterns"])
  if archive_patterns.empty?
    FileUtils.cp_r(official_materials_dir, archived_materials_dir)
  else
    local_material_paths = Set.new
    archive_patterns.each do |pattern|
      official_materials_dir.glob(pattern).select(&:file?).each do |source|
        relative = source.relative_path_from(SOURCE_DIR)
        destination = ASSET_OUTPUT_DIR.join("materials", relative)
        FileUtils.mkdir_p(destination.dirname)
        FileUtils.cp(source, destination)
        local_material_paths << relative.to_s.tr("\\", "/")
      end
    end
  end
end

shared_material_urls = {}
collect_material_urls = lambda do |value|
  case value
  when Hash
    path = value["path"].to_s.tr("\\", "/")
    if path.start_with?("official-materials/") && value["url"]
      shared_material_urls[path] = if !local_material_paths || local_material_paths.include?(path)
                                     local_asset_url("materials", path)
                                   else
                                     secure_url(value["url"])
                                   end
    end
    value.each_value { |child| collect_material_urls.call(child) }
  when Array
    value.each { |child| collect_material_urls.call(child) }
  end
end
collect_material_urls.call(course)
collect_material_urls.call(source_manifest)

course_resource_data_path = REPO_DIR.join("_data", "course_resources", "#{COURSE_SLUG}.yml")
resource_groups = Array(course["resource_groups"]).map do |group|
  group.reject { |key, _value| key == "resources" }.merge(
    "resources" => imported_resources(
      group["resources"],
      include_video: true,
      local_material_paths: local_material_paths
    )
  )
end
if resource_groups.empty?
  FileUtils.rm_f(course_resource_data_path)
else
  write_text(course_resource_data_path, YAML.dump(resource_groups, line_width: -1))
end

if course_meta["reuse_archived_materials"]
  ASSET_OUTPUT_DIR.join("slides").glob("*").select(&:file?).each { |path| FileUtils.rm_f(path) }
end

metadata_dir = ASSET_OUTPUT_DIR.join("metadata")
%w[
  course.json
  source-manifest.json
  resources-lock.json
  materials-index.json
  review-checklist.json
  youtube-captions-lock.json
  youtube-metadata.json
].each do |filename|
  source = SOURCE_DIR.join(filename)
  next unless source.file?

  FileUtils.mkdir_p(metadata_dir)
  FileUtils.cp(source, metadata_dir.join(filename))
end

reading_inputs_dir = SOURCE_DIR.join("reading-inputs")
if reading_inputs_dir.directory?
  archived_reading_inputs_dir = ASSET_OUTPUT_DIR.join("evidence", "reading-inputs")
  FileUtils.rm_rf(archived_reading_inputs_dir)
  FileUtils.mkdir_p(archived_reading_inputs_dir.dirname)
  FileUtils.cp_r(reading_inputs_dir, archived_reading_inputs_dir)
end

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
  configured_range = Array(course_meta["module_ranges"])[module_number - 1]
  first_lecture = configured_range ? configured_range[0].to_i : range_match ? range_match[1].to_i : referenced_lectures.first
  last_lecture = configured_range ? configured_range[1].to_i : range_match ? range_match[2].to_i : referenced_lectures.last
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
  body.gsub!(%r{\]\(\.\./lectures/(\d{3})-.+?/NOTES\.md\)}) do
    "](/courses/#{COURSE_SLUG}/lectures/#{Regexp.last_match(1)}/)"
  end
  rewrite_shared_links(body, COURSE_SLUG, shared_material_urls)
  write_text(
    COURSE_OUTPUT_DIR.join("modules", "#{format('%02d', module_number)}-#{path.basename.to_s.sub(/\A\d+-/, '')}"),
    imported_document(data, body)
  )
end

lecture_modules = module_ranges.reduce({}) { |combined, mapping| mapping.merge(combined) }

def lecture_directory(source_dir, lecture)
  configured = lecture["directory"]
  return source_dir.join(configured.tr("\\", "/")) if configured

  match = source_dir.join("lectures").glob("#{format('%03d', lecture.fetch('index'))}-*").first
  abort "Missing directory for lecture #{lecture.fetch('index')}" unless match

  match
end

def rewrite_links(markdown, lectures_by_number, course_slug, current_number = nil, lecture_material_urls = {}, material_urls = {})
  rewrite_shared_links(markdown, course_slug, material_urls)
  markdown.gsub!(%r{\]\((?:\./)?modules/(\d{2})-[^)]+\.md\)}) do
    "](/courses/#{course_slug}/modules/#{Regexp.last_match(1)}/)"
  end
  markdown.gsub!(%r{\]\((?:\.\./)*lectures/(\d{3})-.+?/NOTES\.md(?:#L\d+)?\)}) do
    "](/courses/#{course_slug}/lectures/#{Regexp.last_match(1)}/)"
  end
  markdown.gsub!(%r{\]\((?:\.\./)*lectures/(\d{3})-[^)]*/transcript\.(jsonl|txt|srt)\)}) do
    number = Regexp.last_match(1)
    extension = Regexp.last_match(2)
    "](/assets/courses/#{course_slug}/lectures/#{number}/transcript.#{extension})"
  end
  markdown.gsub!(%r{\]\((?:\.\./)*lectures/(\d{3})-[^)]*/source\.mp4\)}) do
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
  if current_number
    number_label = format("%03d", current_number)
    markdown.gsub!(%r{\]\((?:\.\./)*(transcript\.(?:jsonl|txt|srt)|captions\.[^/)]+\.srt|summary-input\.jsonl|metadata\.json|preparation\.json)\)}) do
      "](/assets/courses/#{course_slug}/lectures/#{number_label}/#{Regexp.last_match(1)})"
    end
    markdown.gsub!(%r{\]\((?:\.\./)*materials/([^)]+)\)}) do
      relative_path = Regexp.last_match(1)
      url = lecture_material_urls[relative_path] || "/assets/courses/#{course_slug}/lectures/#{number_label}/materials/#{relative_path}"
      "](#{url})"
    end
    markdown.gsub!(%r{\]\((?:\.\./)*notes/sections/(\d{3})\.md\)}) do
      "](#section-#{format('%02d', Regexp.last_match(1).to_i)})"
    end
    markdown.gsub!(%r{\]\((?:\.\./)*notes/sections/\)}) do
      "](#lecture-notes)"
    end
    markdown.gsub!(%r{\]\((?:\.\./)*prompts/sections/\)}) do
      "](#lecture-notes)"
    end
  end
  markdown.gsub!(%r{\]\((?:README\.md|COURSE_SUMMARY\.md|course\.json|source-manifest\.json|official-materials/)\)}, "](/courses/#{course_slug}/)")
  markdown
end

lecture_count = 0
transcript_count = 0
timeline_count = 0
slide_files = {}

lectures.each do |lecture|
  number = lecture.fetch("index")
  number_label = format("%03d", number)
  source_lecture = manifest_lectures.fetch(number, lecture)
  directory = lecture_directory(SOURCE_DIR, lecture)
  notes_path = directory.join("NOTES.md")
  abort "Missing NOTES.md for Lecture #{number}" unless notes_path.file?

  notes = notes_path.read(encoding: "UTF-8")
  description = notes[/^>\s*本讲实际覆盖：(.+?)\s*(?:\[课件:|$)/, 1]&.strip
  description ||= notes[/^1\.\s+(.+)$/, 1]&.strip
  description = description&.gsub(/\[([^\]]+)\]\([^)]+\)/, '\\1')
  description ||= "按课堂推进顺序整理视频、课件与 transcript，并保留可回查的时间和页码。"

  media_urls = [source_lecture["original_url"], source_lecture["url"], lecture["original_url"], lecture["url"]]
  official_video_urls = Array(source_lecture["resources"] || lecture["resources"])
                        .select { |resource| resource["category"] == "official-video" }
                        .filter_map { |resource| resource["url"] }
  media_urls.concat(official_video_urls)
  media_urls = media_urls
               .compact
               .reject(&:empty?)
               .map { |url| secure_url(url) }
               .uniq
  media_sources = media_urls.map { |url| source_for(url) }
  youtube_sources = media_sources.select { |source| source["provider"] == "youtube" }
  if youtube_sources.length > 1
    selected_youtube = lecture.fetch("title").downcase.include?("continued") ? youtube_sources.last : youtube_sources.first
    media_sources = media_sources.reject { |source| source["provider"] == "youtube" }
    media_sources.unshift(selected_youtube)
  end
  if course_meta["disable_bilibili_embed"]
    media_sources.each { |source| source.delete("embed_url") if source["provider"] == "bilibili" }
  end
  preferred_provider = course_meta["preferred_video_provider"]
  if preferred_provider
    preferred_sources, other_sources = media_sources.partition do |source|
      source["provider"] == preferred_provider
    end
    media_sources = preferred_sources + other_sources
  end
  bilibili_thumbnail_name = "bilibili-part-#{format('%03d', number)}.png"
  bilibili_thumbnail_path = ASSET_OUTPUT_DIR.join("thumbnails", bilibili_thumbnail_name)
  fallback_thumbnail = if bilibili_thumbnail_path.file?
                         local_asset_url("thumbnails", bilibili_thumbnail_name)
                       else
                         course_meta["cover"]
                       end
  thumbnail = media_sources.filter_map { |source| source["thumbnail"] }.first || fallback_thumbnail
  resources = imported_resources(
    source_lecture["resources"] || lecture["resources"],
    local_material_paths: local_material_paths
  )
  executable_notes = resources.find do |resource|
    resource["category"] == "lecture-code" && resource["url"].to_s.match?(/\.py\z/i)
  end&.dup

  lecture_asset_dir = ASSET_OUTPUT_DIR.join("lectures", number_label)
  FileUtils.rm_rf(lecture_asset_dir)
  FileUtils.mkdir_p(lecture_asset_dir)
  %w[metadata.json preparation.json summary-input.jsonl materials.jsonl].each do |filename|
    source = directory.join(filename)
    FileUtils.cp(source, lecture_asset_dir.join(filename)) if source.file?
  end
  %w[materials prompts].each do |dirname|
    next if dirname == "materials" && course_meta["reuse_archived_materials"]

    source = directory.join(dirname)
    next unless source.directory?

    destination = lecture_asset_dir.join(dirname)
    FileUtils.rm_rf(destination)
    FileUtils.cp_r(source, destination)
  end
  transcript = {}
  %w[jsonl txt srt].each do |extension|
    source = directory.join("transcript.#{extension}")
    next unless source.file?

    FileUtils.cp(source, lecture_asset_dir.join(source.basename))
    transcript[extension] = local_asset_url("lectures", number_label, source.basename.to_s)
    transcript_count += 1
  end
  captions = directory.glob("captions.*.srt").sort.map.with_index do |source, index|
    FileUtils.cp(source, lecture_asset_dir.join(source.basename))
    {
      "label" => source.basename.to_s.include?("source") ? "English captions" : "Chinese captions",
      "url" => local_asset_url("lectures", number_label, source.basename.to_s)
    }
  end
  transcript["captions"] = captions unless captions.empty?
  transcript["status"] = "auto-generated" unless transcript.empty?

  material_paths = Array(source_lecture["materials"] || lecture["materials"]).select do |material|
    material.match?(/\.(?:pptx|pdf)\z/i)
  end
  material_records = material_paths.filter_map do |material|
    normalized_path = material.tr("\\", "/")
    filename = Pathname.new(normalized_path).basename.to_s
    archived_source = SOURCE_DIR.join(normalized_path)
    source = archived_source.file? ? archived_source : SOURCE_DIR.join("official-materials", filename)
    source = directory.join("materials", filename) unless source.file?
    next unless source.file?

    if course_meta["reuse_archived_materials"] && archived_source.file? && normalized_path.start_with?("official-materials/")
      url = local_asset_url("materials", normalized_path)
      slide_files[url] = archived_source
    else
      destination = ASSET_OUTPUT_DIR.join("slides", filename)
      FileUtils.mkdir_p(destination.dirname)
      FileUtils.cp(source, destination)
      url = local_asset_url("slides", filename)
      slide_files[url] = destination
    end
    { "name" => filename, "url" => url }
  end
  material_names = material_records.map { |record| record.fetch("name") }.uniq
  material_urls = material_records.to_h { |record| [record.fetch("name"), record.fetch("url")] }
  rendered_dir = if material_names.empty?
                   nil
                 else
                   ASSET_OUTPUT_DIR.join("slides", "rendered", File.basename(material_names.first, File.extname(material_names.first)))
                 end
  rendered_slide_images = rendered_dir ? rendered_dir.glob("slide-*.{jpg,jpeg,png,webp}").sort : []
  has_rendered_slides = !rendered_slide_images.empty?

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
    if title.empty?
      purpose = section_markdown[/^##\s+本段在整讲中的作用\s*$\s+([^\n]+)/, 1].to_s.strip
      title = purpose.split(/[。；]/).first.to_s.strip
    end
    title = "Section #{format('%02d', section_number)}" if title.empty?
    summary_section = summary_sections[section_number]
    time_match = section_markdown.lines.first(12).join.match(
      /(\d{2}:\d{2}:\d{2}(?:\.\d+)?)\s*[-–]\s*(\d{2}:\d{2}:\d{2}(?:\.\d+)?)/
    )
    start_time = summary_section && summary_section["start"] || time_match && seconds_from_timestamp(time_match[1])
    end_time = summary_section && summary_section["end"] || time_match && seconds_from_timestamp(time_match[2])
    next unless start_time && end_time

    slides = if has_rendered_slides
               section_markdown.scan(/\[课件:\s*[^\]]+?\s+p\.(\d+)\]/).flatten.map(&:to_i).uniq.sort
             else
               []
             end
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
    pages = rendered_slide_images.map.with_index(1) do |image, index|
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
    slide_url = material_records.first.fetch("url")
    slides = {
      "download" => slide_url
    }
    slides["pdf"] = slide_url if File.extname(material_names.first).casecmp?(".pdf")
    if slide_manifest_url
      slides["manifest"] = slide_manifest_url
      slides["initial"] = pages.first.fetch("src")
    end
  end

  data = {
    "uid" => "#{COURSE_SLUG}-lecture-#{number_label}",
    "type" => "course",
    "document_type" => "lecture",
    "course" => COURSE_SLUG,
    "module_number" => lecture_modules.fetch(lecture.fetch("lecture_number", number)),
    "lecture_number" => number,
    "official_lecture_number" => lecture.fetch("lecture_number", number),
    "display_number" => course_meta["use_official_lecture_number"] ? lecture.fetch("lecture_number", number) : number,
    "title" => lecture.fetch("title"),
    "description" => description,
    "excerpt" => description,
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "duration" => display_duration(lecture.fetch("duration_seconds")),
    "duration_seconds" => lecture.fetch("duration_seconds").to_i,
    "media_sources" => media_sources,
    "thumbnail" => thumbnail,
    "resources" => resources,
    "transcript" => transcript,
    "timeline" => local_asset_url("lectures", number_label, "timeline.json"),
    "permalink" => "/courses/#{COURSE_SLUG}/lectures/#{number_label}/",
    "toc" => true
  }
  data["slides"] = slides if slides
  data["executable_notes"] = executable_notes if executable_notes

  body = strip_document_title(notes)
  timestamp_only_headings = body.scan(/^###\s+(?:\d+\s+)?\d{2}:\d{2}:\d{2}\s*[-–]\s*\d{2}:\d{2}:\d{2}.*$/)
  section_headings.each do |section_number, heading|
    anchor = "section-#{format('%02d', section_number)}"
    anchor_markup = "<div id=\"#{anchor}\" class=\"course-note-section-anchor\" aria-hidden=\"true\">&nbsp;</div>"
    timestamp_heading = timestamp_only_headings[section_number - 1]
    if timestamp_heading
      replaced = body.sub!(/^#{Regexp.escape(timestamp_heading)}$/) do |matched_heading|
        "#{anchor_markup}\n\n#{matched_heading}"
      end
      next if replaced
    end

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

    replaced = body.sub!(/^###\s+0*#{section_number}(?:[.、]\s*|\s+).*\d{2}:\d{2}:\d{2}.*$/) do |timestamp_heading|
      "#{anchor_markup}\n\n#{timestamp_heading}"
    end
    next if replaced

  end

  missing_anchors = sections.reject { |section| body.include?("id=\"#{section['note_anchor']}\"") }
  unless missing_anchors.empty?
    abort "Cannot place note anchors for Lecture #{number}: #{missing_anchors.map { |section| section['id'] }.join(', ')}"
  end
  rewrite_links(body, lectures_by_number, COURSE_SLUG, number, material_urls, shared_material_urls)
  write_text(COURSE_OUTPUT_DIR.join("lectures", "#{number_label}.md"), imported_document(data, body))
  lecture_count += 1
end

overview_path = SOURCE_DIR.join("COURSE_SUMMARY.md")
if overview_path.file?
  overview = strip_document_title(overview_path.read(encoding: "UTF-8"))
  overview = "> #{course_meta['archive_notice']}\n\n#{overview}" if course_meta["archive_notice"]
  rewrite_links(overview, lectures_by_number, COURSE_SLUG, nil, {}, shared_material_urls)
  overview_data = {
    "uid" => "#{COURSE_SLUG}-overview",
    "type" => "course",
    "document_type" => "overview",
    "course" => COURSE_SLUG,
    "title" => course_meta.fetch("title"),
    "description" => course_meta.fetch("description"),
    "excerpt" => course_meta.fetch("description"),
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "resources" => imported_resources(course["resources"], local_material_paths: local_material_paths),
    "permalink" => "/courses/#{COURSE_SLUG}/",
    "toc" => true
  }
  write_text(REPO_DIR.join("_courses", "#{COURSE_SLUG}.md"), imported_document(overview_data, overview))
end

course_resource_count = 0
review_path = SOURCE_DIR.join("REVIEW_CHECKLIST.md")
if review_path.file?
  review = review_path.read(encoding: "UTF-8")
  review_title = review[/\A#\s+(.+)$/, 1].to_s.strip
  review = strip_document_title(review)
  rewrite_links(review, lectures_by_number, COURSE_SLUG, nil, {}, shared_material_urls)
  review_data = {
    "uid" => "#{COURSE_SLUG}-review-checklist",
    "type" => "course",
    "document_type" => "resource",
    "resource_kind" => "review",
    "resource_order" => 3,
    "course" => COURSE_SLUG,
    "title" => review_title,
    "description" => "按风险回查自动 transcript、课件与视频中的未决证据。",
    "excerpt" => "按风险回查自动 transcript、课件与视频中的未决证据。",
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "permalink" => "/courses/#{COURSE_SLUG}/review-checklist/",
    "toc" => true
  }
  write_text(COURSE_OUTPUT_DIR.join("review-checklist.md"), imported_document(review_data, review))
  course_resource_count += 1
end

resource_sources = [
  {
    "path" => SOURCE_DIR.join("LABS.md"),
    "kind" => "labs",
    "order" => 1,
    "permalink" => "/courses/#{COURSE_SLUG}/labs/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "labs.md"),
    "description" => "按官方目标、接口、阶段和验证门槛组织课程 Labs 的实践路线。"
  },
  {
    "path" => SOURCE_DIR.join("PRACTICE.md"),
    "kind" => "practice",
    "order" => 2,
    "permalink" => "/courses/#{COURSE_SLUG}/practice/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "practice.md"),
    "description" => "按 Recitation、Lab、Bootcamp、Hackathon 与 Assignment 组织完整实践路线。"
  },
  {
    "path" => SOURCE_DIR.join("ASSIGNMENTS.md"),
    "kind" => "assignments",
    "order" => 2,
    "permalink" => "/courses/#{COURSE_SLUG}/assignments/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "assignments.md"),
    "description" => "按五个官方作业串联课程模块、handout、实现环境、学习边界与完成清单。"
  },
  {
    "path" => SOURCE_DIR.join("READINGS.md"),
    "kind" => "readings",
    "order" => 3,
    "permalink" => "/courses/#{COURSE_SLUG}/readings/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "readings.md"),
    "description" => "按 Lecture 对齐官方论文、补充阅读、复用关系与证据边界。"
  },
  {
    "path" => SOURCE_DIR.join("MATERIALS.md"),
    "kind" => "materials",
    "order" => 4,
    "permalink" => "/courses/#{COURSE_SLUG}/materials/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "materials.md"),
    "description" => "按讲次索引课程讲义、论文、FAQ、Question、Labs 与公开视频。"
  }
]

SOURCE_DIR.join("readings").glob("lecture-*.md").sort.each do |path|
  lecture_number = path.basename(".md").to_s[/\d+/, 0].to_i
  resource_sources << {
    "path" => path,
    "kind" => "reading",
    "order" => 100 + lecture_number,
    "lecture_number" => lecture_number,
    "permalink" => "/courses/#{COURSE_SLUG}/readings/lecture-#{format('%02d', lecture_number)}/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "readings", "lecture-#{format('%02d', lecture_number)}.md"),
    "description" => "Lecture #{lecture_number} 的指定阅读、证据边界、机制推理与自测指南。"
  }
end

SOURCE_DIR.join("official-lectures").glob("lecture-*.md").sort.each do |path|
  lecture_number = path.basename(".md").to_s[/\d+/, 0].to_i
  resource_sources << {
    "path" => path,
    "kind" => "official-lecture",
    "order" => 300 + lecture_number,
    "lecture_number" => lecture_number,
    "permalink" => "/courses/#{COURSE_SLUG}/official-lectures/lecture-#{format('%02d', lecture_number)}/",
    "output" => COURSE_OUTPUT_DIR.join("resources", "official-lectures", "lecture-#{format('%02d', lecture_number)}.md"),
    "description" => "Lecture #{lecture_number} 跨媒体分段聚合后的官方讲次学习笔记。"
  }
end

resource_sources.each do |resource|
  path = resource.fetch("path")
  next unless path.file?

  markdown = path.read(encoding: "UTF-8")
  title = markdown[/\A#\s+(.+)$/, 1].to_s.strip
  body = strip_document_title(markdown)
  if course_meta["archive_notice"] && %w[assignments readings materials].include?(resource.fetch("kind"))
    body = "> #{course_meta['archive_notice']}\n\n#{body}"
  end
  rewrite_links(body, lectures_by_number, COURSE_SLUG, nil, {}, shared_material_urls)
  data = {
    "uid" => "#{COURSE_SLUG}-resource-#{resource.fetch('kind')}-#{resource['lecture_number'] || resource.fetch('order')}",
    "type" => "course",
    "document_type" => "resource",
    "resource_kind" => resource.fetch("kind"),
    "resource_order" => resource.fetch("order"),
    "course" => COURSE_SLUG,
    "title" => title,
    "description" => resource.fetch("description"),
    "excerpt" => resource.fetch("description"),
    "content_lang" => course_meta["notes_language"] || "zh-CN",
    "permalink" => resource.fetch("permalink"),
    "toc" => true
  }
  data["official_lecture_number"] = resource["lecture_number"] if resource["lecture_number"]
  write_text(resource.fetch("output"), imported_document(data, body))
  course_resource_count += 1
end

puts "Imported #{COURSE_SLUG}:"
puts "  #{module_sources.length} modules"
puts "  #{lecture_count} lectures"
puts "  #{course_resource_count} course resources"
puts "  #{timeline_count} aligned sections"
puts "  #{transcript_count} transcript assets"
puts "  #{slide_files.length} slide documents"