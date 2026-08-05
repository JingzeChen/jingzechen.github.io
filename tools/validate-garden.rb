# frozen_string_literal: true

require "date"
require "digest"
require "json"
require "nokogiri"
require "open3"
require "tempfile"
require "yaml"

site_dir = File.expand_path(ARGV.fetch(0, "_site")).tr("\\", "/")
source_dir = File.expand_path("..", __dir__).tr("\\", "/")
failures = []

assert = lambda do |condition, message|
  failures << message unless condition
end

assert_status_markers = lambda do |markers, statuses, message|
  expected_statuses = statuses.uniq.size > 1 ? statuses : []
  assert.call(markers.size == expected_statuses.size, "#{message} count mismatch")
  markers.zip(expected_statuses).each do |marker, status|
    assert.call(marker.text.strip == status, "#{message} text mismatch")
    assert.call(
      marker["class"].to_s.split.include?("garden-status-#{status}"),
      "#{message} class mismatch"
    )
  end
end

read = ->(path) { File.read(File.join(site_dir, path), encoding: "UTF-8") }
parse = ->(path) { Nokogiri::HTML(read.call(path)) }

posts = Dir.glob(File.join(source_dir, "_posts", "**", "*.md")).map do |path|
  front_matter = File.read(path, encoding: "UTF-8").split(/^---\s*$/, 3)[1]
  data = YAML.safe_load(front_matter, permitted_classes: [Date, Time], aliases: true) || {}
  [path, data]
end

reading_posts = posts.select { |_, data| data["type"] == "reading" }
status_by_uid = posts.to_h { |_, data| [data["uid"], data["status"]] }
series_registry = YAML.safe_load_file(File.join(source_dir, "_data", "series.yml"), aliases: true)
topic_registry = YAML.safe_load_file(File.join(source_dir, "_data", "topics.yml"), aliases: true)
site_config = YAML.safe_load_file(File.join(source_dir, "_config.yml"), aliases: true)
hidden_topics = Array(site_config.dig("garden", "hidden_topics"))
assert.call(posts.any?, "expected at least one source post")
assert.call(posts.all? { |_, data| !data["content_lang"].to_s.empty? }, "all posts must declare content_lang")

posts.group_by { |_, data| data["series"] }.each do |series, members|
  next if series.nil?

  orders = members.filter_map { |_, data| data["series_order"] }
  if orders.size == members.size
    assert.call(orders.sort == (1..members.size).to_a, "#{series} must have contiguous series_order values")
  end
end

featured = posts.select { |_, data| data["featured"] == true }
assert.call(featured.size.between?(2, 5), "featured content count must be between 2 and 5")
assert.call(featured.all? { |_, data| !data["why_start_here"].to_s.empty? }, "featured content requires why_start_here")

reading_data = JSON.parse(read.call("assets/js/data/reading.json"))
search_data = JSON.parse(read.call("assets/js/data/search.json"))
assert.call(reading_data.size == reading_posts.size, "reading.json count must match reading posts")
assert.call(reading_data.all? { |item| !item["contentLang"].to_s.empty? }, "reading.json language mismatch")
assert.call(reading_data.all? { |item| !item["status"].to_s.empty? }, "reading.json status mismatch")
assert.call(
  reading_data.all? { |item| status_by_uid[item["uid"]] == item["status"] },
  "reading.json statuses must match source posts"
)
assert.call(reading_data.none? { |item| item["seriesOrder"].nil? }, "reading.json requires seriesOrder")
assert.call(search_data.size == posts.size, "search.json count must match source posts")
assert.call(search_data.all? { |item| !item["contentLang"].to_s.empty? }, "search.json language mismatch")
assert.call(
  search_data.all? { |item| status_by_uid[item["uid"]] == item["status"] },
  "search.json statuses must match source posts"
)
status_by_url = search_data.to_h { |item| [item["url"], item["status"]] }
assert.call(
  search_data.none? { |item| hidden_topics.any? { |topic| item["topics"].split(/,\s*/).include?(topic) } },
  "search.json exposes hidden topics"
)
assert.call(search_data.map { |item| item["excerpt"].length }.max <= 220, "search excerpts exceed 220 characters")
assert.call(
  search_data.none? { |item| "#{item["excerpt"]} #{item["content"]}".match?(/```|flowchart\s+(TD|LR)|sequenceDiagram|classDiagram|<table/) },
  "search index contains code, Mermaid, or table source"
)

home = parse.call("index.html")
reading = parse.call("reading/index.html")
sidebar_labels = home.css("#sidebar .nav-item span").map(&:text)
type_labels = {
  "note" => "Notes",
  "essay" => "Essays",
  "journal" => "Journal",
  "reading" => "Reading",
  "project" => "Projects",
  "idea" => "Ideas"
}
expected_sidebar = ["Garden"] + type_labels.filter_map do |type, label|
  label if posts.any? { |_, data| data["type"] == type }
end + ["About"]
assert.call(sidebar_labels == expected_sidebar, "sidebar routes do not match published content types")
assert.call(home.css(".garden-topic-map > a[href^='/topics/']").size == topic_registry.size, "homepage must link all mapped topics")
visible_featured_count = [featured.size, 3].min
assert.call(home.css(".garden-featured-link").size == visible_featured_count, "homepage featured-link count mismatch")
assert.call(home.css(".garden-featured-reason").size == visible_featured_count, "homepage featured-reason count mismatch")
featured_statuses = home.css(".garden-featured-link").filter_map { |link| status_by_url[link["href"]] }
assert.call(featured_statuses.size == visible_featured_count, "homepage featured links must resolve to source posts")
assert_status_markers.call(
  home.css(".garden-featured-grid .garden-entry-status"),
  featured_statuses,
  "homepage status markers"
)
assert.call(reading.css(".reading-series-item").size == series_registry.size, "Reading must render every mapped series")
assert.call(reading.css(".reading-note-row").empty?, "Reading initial HTML must not render all notes")
language_count = reading_posts.map { |_, data| data["content_lang"] }.uniq.size
language_filter_present = !reading.at_css('[data-reading-filter="language"]').nil?
assert.call(language_filter_present == (language_count > 1), "language filter activation gate mismatch")
reading_status_count = reading_posts.map { |_, data| data["status"] }.uniq.size
status_filter_present = !reading.at_css('[data-reading-filter="status"]').nil?
assert.call(status_filter_present == (reading_status_count > 1), "status filter activation gate mismatch")

type_routes = {
  "note" => "notes/index.html",
  "essay" => "essays/index.html",
  "journal" => "journal/index.html",
  "project" => "projects/index.html",
  "idea" => "ideas/index.html"
}
type_routes.each do |type, route|
  document = parse.call(route)
  links = document.css(".garden-entry-list .garden-entry h2 a")
  statuses = links.filter_map { |link| status_by_url[link["href"]] }
  assert.call(statuses.size == links.size, "#{type} index links must resolve to source posts")
  assert_status_markers.call(
    document.css(".garden-entry-list .garden-entry-status"),
    statuses,
    "#{type} index status markers"
  )
end

series_registry.each do |slug, metadata|
  route = metadata.fetch("url").delete_prefix("/").delete_suffix("/")
  document = parse.call("#{route}/index.html")
  series_posts = posts.select { |_, data| data["series"] == slug }
  explicit_orders = series_posts.filter_map { |_, data| data["series_order"] }
  series_posts = if explicit_orders.size == series_posts.size
                   series_posts.sort_by { |_, data| data["series_order"] }
                 else
                   series_posts.sort_by { |path, data| [data["date"], path] }
                 end
  chapter_items = document.css(".series-chapter-list > li[id]")
  rendered_author = document.at_css(".series-header .taxonomy-meta")&.text.to_s

  assert.call(document.at_css(".series-header h1")&.text&.strip == metadata["title"], "#{slug} title mismatch")
  unless metadata["author"].to_s.empty?
    assert.call(rendered_author.include?("By #{metadata["author"]}"), "#{slug} author mismatch")
  end
  assert.call(chapter_items.size == series_posts.size, "#{slug} chapter count mismatch")
  assert.call(
    chapter_items.all? { |item| item.at_css(".series-current-label")&.text&.strip == "Current chapter" },
    "#{slug} chapters require accessible current labels"
  )
  assert.call(
    chapter_items.map { |item| item["id"] } == series_posts.map { |_, data| data["uid"] },
    "#{slug} chapter anchors do not match series order"
  )
  assert_status_markers.call(
    document.css(".series-chapter-status"),
    series_posts.map { |_, data| data["status"] },
    "#{slug} status markers"
  )
end

topic_files = Dir.glob(File.join(site_dir, "topics", "*", "index.html"))
assert.call(topic_files.size == topic_registry.size, "generated topic-page count must match topic registry")
topic_files.each do |path|
  document = Nokogiri::HTML(File.read(path, encoding: "UTF-8"))
  topic_slug = File.basename(File.dirname(path))
  topic_metadata = topic_registry.fetch(topic_slug)
  assert.call(document.css("h1").size == 1, "#{path} must contain one h1")
  expected_start_count = Array(topic_metadata["start_here"]).size
  assert.call(document.css(".topic-start article").size == expected_start_count, "#{path} Start here count mismatch")
  assert.call(!document.at_css(".topic-notes .garden-entry").nil?, "#{path} is missing notes")
end

core_files = %w[index.html reading/index.html archives/index.html categories/ai-engineering/index.html]
core_files.each do |path|
  document = parse.call(path)
  assert.call(document.css("h1").size == 1, "#{path} must contain one h1")
  assert.call(!document.at_css("main#main-content").nil?, "#{path} is missing main landmark")
  assert.call(!document.at_css('a.skip-link[href="#main-content"]').nil?, "#{path} is missing skip link")
end

overview_count = 0
Dir.glob(File.join(site_dir, "posts", "*", "index.html")).each do |path|
  document = Nokogiri::HTML(File.read(path, encoding: "UTF-8"))
  %w[garden-related-title garden-backlinks-title].each do |heading_id|
    section = document.at_css("##{heading_id}")&.parent
    next if section.nil?

    links = section.css(".garden-connection-list > a")
    statuses = links.filter_map { |link| status_by_url[link["href"]] }
    assert.call(statuses.size == links.size, "#{path} connection links must resolve to source posts")
    assert_status_markers.call(
      section.css(".garden-connection-status"),
      statuses,
      "#{path} #{heading_id} status markers"
    )
  end
  overview = document.at_css(".chapter-overview")
  next if overview.nil?

  overview_count += 1
  content_ids = document.css("article > .content h2[id]").map { |heading| heading["id"] }
  overview_ids = overview.css('ol a[href^="#"]').map { |link| link["href"].delete_prefix("#") }
  assert.call(overview_ids == content_ids, "#{path} chapter overview anchors do not match H2 headings")
end
assert.call(overview_count.positive?, "expected at least one ultra-long chapter overview")

javascript_files = Dir.glob(File.join(source_dir, "_javascript", "**", "*.js")) +
  Dir.glob(File.join(source_dir, "*.js"))
inline_scripts = Dir.glob(File.join(site_dir, "**", "*.html")).flat_map do |path|
  document = Nokogiri::HTML(File.read(path, encoding: "UTF-8"))
  document.css("script:not([src])").filter_map do |script|
    code = script.text.strip
    code unless code.empty? || script["type"] == "application/ld+json"
  end
end
inline_scripts = inline_scripts.uniq { |code| Digest::SHA256.hexdigest(code) }

javascript_files.each do |path|
  _stdout, stderr, status = Open3.capture3("node", "--check", path)
  assert.call(status.success?, "#{path} JavaScript syntax failed: #{stderr.strip}")
end

inline_scripts.each_with_index do |code, index|
  Tempfile.create(["garden-inline-#{index}", ".js"]) do |file|
    file.write(code)
    file.flush
    _stdout, stderr, status = Open3.capture3("node", "--check", file.path)
    assert.call(status.success?, "rendered inline script #{index + 1} syntax failed: #{stderr.strip}")
  end
end

unless failures.empty?
  warn failures.map { |failure| "FAIL: #{failure}" }.join("\n")
  exit 1
end

puts "Garden validation passed: #{posts.size} posts, #{series_registry.size} series, #{topic_registry.size} topics, #{overview_count} chapter overviews, #{inline_scripts.size} inline scripts"