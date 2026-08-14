# frozen_string_literal: true

require "date"
require "json"
require "nokogiri"
require "yaml"

site_dir = File.expand_path(ARGV.fetch(0, "_site")).tr("\\", "/")
source_dir = File.expand_path("..", __dir__).tr("\\", "/")
failures = []

assert = lambda do |condition, message|
  failures << message unless condition
end

front_matter = lambda do |path|
  source = File.read(path, encoding: "UTF-8")
  yaml = source.split(/^---\s*$/, 3)[1]
  YAML.safe_load(yaml, permitted_classes: [Date, Time], aliases: true) || {}
end

source_file = lambda do |url|
  next nil if url.to_s.match?(%r{\Ahttps://})

  File.join(source_dir, url.to_s.delete_prefix("/"))
end

site_file = lambda do |url|
  route = url.to_s.delete_prefix("/").delete_suffix("/")
  File.join(site_dir, route, "index.html")
end

course_registry = YAML.safe_load_file(File.join(source_dir, "_data", "courses.yml"), aliases: true)
documents = Dir.glob(File.join(source_dir, "_courses", "**", "*.md")).map do |path|
  [path, front_matter.call(path)]
end
course_documents = documents.select { |_, data| data["type"] == "course" }
lectures = course_documents.select { |_, data| data["document_type"] == "lecture" }
modules = course_documents.select { |_, data| data["document_type"] == "module" }
overviews = course_documents.select { |_, data| data["document_type"] == "overview" }

assert.call(!course_registry.empty?, "course registry must not be empty")
assert.call(overviews.size == course_registry.size, "each registered course requires one overview")

catalog_path = File.join(site_dir, "courses", "index.html")
assert.call(File.file?(catalog_path), "courses catalog was not generated")
if File.file?(catalog_path)
  catalog = Nokogiri::HTML(File.read(catalog_path, encoding: "UTF-8"))
  assert.call(
    catalog.css("[data-course-item]").size == course_registry.size,
    "course catalog count must match registry"
  )
end

search_path = File.join(site_dir, "assets", "js", "data", "search.json")
if File.file?(search_path)
  search_data = JSON.parse(File.read(search_path, encoding: "UTF-8"))
  indexed_courses = search_data.select { |item| item["type"] == "course" }
  assert.call(indexed_courses.size == course_documents.size, "search must index every course document")
else
  failures << "search index was not generated"
end

course_registry.each_key do |course_slug|
  course_modules = modules.select { |_, data| data["course"] == course_slug }
  course_lectures = lectures.select { |_, data| data["course"] == course_slug }
  overview_path = File.join(site_dir, "courses", course_slug, "index.html")
  assert.call(File.file?(overview_path), "#{course_slug}: overview was not generated")
  next unless File.file?(overview_path)

  overview = Nokogiri::HTML(File.read(overview_path, encoding: "UTF-8"))
  assert.call(
    overview.css(".course-module-list > .course-module-item").size == course_modules.size,
    "#{course_slug}: overview module count mismatch"
  )
end

timeline_sections = 0
rendered_slides = {}

lectures.each do |path, data|
  label = "#{data['course']} lecture #{data['lecture_number']}"
  html_path = site_file.call(data["permalink"])
  assert.call(File.file?(html_path), "#{label}: page was not generated")

  timeline_path = source_file.call(data["timeline"])
  assert.call(timeline_path && File.file?(timeline_path), "#{label}: timeline asset is missing")
  next unless timeline_path && File.file?(timeline_path)

  timeline = JSON.parse(File.read(timeline_path, encoding: "UTF-8")).fetch("sections")
  timeline_sections += timeline.size
  assert.call(!timeline.empty?, "#{label}: timeline must not be empty")
  assert.call(timeline.map { |section| section["id"] }.uniq.size == timeline.size, "#{label}: duplicate section ids")
  assert.call(
    timeline.each_cons(2).all? { |left, right| left["start"] <= left["end"] && left["start"] <= right["start"] },
    "#{label}: timeline must be chronological"
  )
  assert.call(
    timeline.last["end"] <= data.fetch("duration_seconds") + 60,
    "#{label}: timeline exceeds lecture duration"
  )

  transcript = data["transcript"] || {}
  %w[jsonl txt srt].each do |format|
    next unless transcript[format]

    asset = source_file.call(transcript[format])
    assert.call(asset && File.file?(asset), "#{label}: transcript #{format} is missing")
  end
  jsonl_path = source_file.call(transcript["jsonl"])
  if jsonl_path && File.file?(jsonl_path)
    rows = File.foreach(jsonl_path, encoding: "UTF-8").filter_map do |line|
      JSON.parse(line) unless line.strip.empty?
    end
    assert.call(!rows.empty?, "#{label}: transcript JSONL must not be empty")
    assert.call(
      rows.each_cons(2).all? { |left, right| left["start"] <= left["end"] && left["start"] <= right["start"] },
      "#{label}: transcript must be chronological"
    )
  end

  available_pages = []
  slides = data["slides"] || {}
  if slides["download"]
    download = source_file.call(slides["download"])
    assert.call(download && File.file?(download), "#{label}: slide download is missing")
  end
  if slides["manifest"]
    manifest_path = source_file.call(slides["manifest"])
    assert.call(manifest_path && File.file?(manifest_path), "#{label}: slide manifest is missing")
    if manifest_path && File.file?(manifest_path)
      pages = JSON.parse(File.read(manifest_path, encoding: "UTF-8")).fetch("pages")
      available_pages = pages.map { |page| page.fetch("page") }
      pages.each do |page|
        image = source_file.call(page.fetch("src"))
        assert.call(image && File.file?(image), "#{label}: slide #{page['page']} image is missing")
        rendered_slides[page.fetch("src")] = true
      end
    end
  end
  referenced_pages = timeline.flat_map { |section| Array(section["slides"]) }.uniq
  assert.call(
    (referenced_pages - available_pages).empty?,
    "#{label}: timeline references unavailable slide pages #{(referenced_pages - available_pages).join(', ')}"
  )

  next unless File.file?(html_path)

  html = Nokogiri::HTML(File.read(html_path, encoding: "UTF-8"))
  assert.call(!html.at_css("[data-course-workbench]").nil?, "#{label}: workbench is missing")
  if html.at_css('main > article[data-toc="true"]')
    assert.call(!html.at_css("#toc-solo-trigger").nil?, "#{label}: mobile TOC trigger is missing")
    assert.call(!html.at_css("#toc-popup").nil?, "#{label}: mobile TOC popup is missing")
  end
  if slides["manifest"]
    slide_image = html.at_css("[data-course-slide-image]")
    assert.call(!slide_image.nil?, "#{label}: slide image is missing")
    assert.call(!slide_image&.[]("src").to_s.empty?, "#{label}: slide image source is missing")
  end
  timeline.each do |section|
    assert.call(
      !html.at_css("##{section.fetch('note_anchor')}").nil?,
      "#{label}: note anchor ##{section.fetch('note_anchor')} is missing"
    )
  end
end

assert.call(timeline_sections.positive?, "expected aligned course sections")
assert.call(rendered_slides.size.positive?, "expected rendered course slides")

unless failures.empty?
  warn "Course validation failed:\n- #{failures.join("\n- ")}"
  exit 1
end

puts "Validated #{course_registry.size} courses, #{lectures.size} lectures, " \
     "#{timeline_sections} aligned sections, and #{rendered_slides.size} rendered slides."
