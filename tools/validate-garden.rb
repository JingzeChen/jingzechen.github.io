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
podcast_posts = posts.select { |_, data| data["type"] == "podcast" }
course_documents = Dir.glob(File.join(source_dir, "_courses", "**", "*.md")).map do |path|
  front_matter = File.read(path, encoding: "UTF-8").split(/^---\s*$/, 3)[1]
  data = YAML.safe_load(front_matter, permitted_classes: [Date, Time], aliases: true) || {}
  [path, data]
end
course_overviews = course_documents.select { |_, data| data["document_type"] == "overview" }
status_by_uid = posts.to_h { |_, data| [data["uid"], data["status"]] }
series_registry = YAML.safe_load_file(File.join(source_dir, "_data", "series.yml"), aliases: true)
podcast_show_registry = YAML.safe_load_file(File.join(source_dir, "_data", "podcast_shows.yml"), aliases: true)
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
reading_guides_by_uid = Dir.glob(File.join(source_dir, "_data", "reading_guides", "*.yml")).to_h do |path|
  [File.basename(path, ".yml"), YAML.safe_load_file(path, aliases: true)]
end
reading_guide_uids = reading_guides_by_uid.keys
reading_post_uids = reading_posts.map { |_, data| data["uid"] }
assert.call(
  reading_guide_uids.sort == reading_post_uids.sort,
  "every Reading post must have exactly one reading guide"
)
assert.call(reading_data.size == reading_posts.size, "reading.json count must match reading posts")
assert.call(reading_data.all? { |item| !item["contentLang"].to_s.empty? }, "reading.json language mismatch")
assert.call(reading_data.all? { |item| !item["status"].to_s.empty? }, "reading.json status mismatch")
assert.call(
  reading_data.all? { |item| status_by_uid[item["uid"]] == item["status"] },
  "reading.json statuses must match source posts"
)
assert.call(reading_data.none? { |item| item["seriesOrder"].nil? }, "reading.json requires seriesOrder")
reading_source_by_uid = reading_posts.to_h { |_, data| [data["uid"], data] }
search_by_uid = search_data.to_h { |item| [item["uid"], item] }
reading_guide_uid_by_url = reading_data.filter_map do |item|
  [item["url"], item["uid"]] if reading_guide_uids.include?(item["uid"])
end.to_h
assert.call(
  reading_guide_uid_by_url.size == reading_guide_uids.size,
  "every reading guide filename must resolve to a published reading uid"
)
reading_data.each do |item|
  source = reading_source_by_uid[item["uid"]]
  assert.call(!source.nil?, "reading.json uid '#{item['uid']}' must resolve to a source post")
  next if source.nil?

  series = source["series"]
  expected_published = source["date"].strftime("%Y-%m-%d")
  expected_updated = (source["updated"] || source["date"]).strftime("%Y-%m-%d")
  assert.call(item["title"] == source["title"], "reading.json title mismatch for #{item['uid']}")
  assert.call(item["url"] == search_by_uid.dig(item["uid"], "url"), "reading.json url mismatch for #{item['uid']}")
  assert.call(item["series"] == series, "reading.json series mismatch for #{item['uid']}")
  assert.call(item["seriesTitle"] == series_registry.dig(series, "title"), "reading.json series title mismatch for #{item['uid']}")
  assert.call(item["seriesOrder"] == source["series_order"], "reading.json series order mismatch for #{item['uid']}")
  assert.call(item["topics"] == Array(source["topics"]), "reading.json topics mismatch for #{item['uid']}")
  assert.call(item["contentLang"] == source["content_lang"], "reading.json language mismatch for #{item['uid']}")
  assert.call(item["status"] == source["status"], "reading.json status mismatch for #{item['uid']}")
  assert.call(item["description"] == source["description"], "reading.json description mismatch for #{item['uid']}")
  assert.call(item["published"] == expected_published, "reading.json published date mismatch for #{item['uid']}")
  assert.call(item["updated"] == expected_updated, "reading.json updated date mismatch for #{item['uid']}")
end
assert.call(search_data.size == posts.size + course_documents.size, "search.json count must match posts and courses")
assert.call(search_data.all? { |item| !item["contentLang"].to_s.empty? }, "search.json language mismatch")
assert.call(
  search_data.reject { |item| item["type"] == "course" }.all? { |item| status_by_uid[item["uid"]] == item["status"] },
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
podcasts = parse.call("podcasts/index.html")
archives = parse.call("archives/index.html")
sidebar_labels = home.css("#sidebar .nav-item span").map(&:text)
type_labels = {
  "note" => "Notes",
  "essay" => "Essays",
  "journal" => "Journal",
  "reading" => "Reading",
  "course" => "Courses",
  "podcast" => "Listening",
  "project" => "Projects",
  "idea" => "Ideas"
}
expected_sidebar = ["Garden"] + type_labels.filter_map do |type, label|
  label if type == "course" ? course_documents.any? : posts.any? { |_, data| data["type"] == type }
end + ["About"]
assert.call(sidebar_labels == expected_sidebar, "sidebar routes do not match published content types")
assert.call(home.css(".garden-topic-map > a[href^='/topics/']").size == topic_registry.size, "homepage must link all mapped topics")
assert.call(home.css("[data-home-channel]").size == 3, "homepage must feature Reading, Courses, and Listening")
assert.call(home.css("[data-home-course]").size == course_overviews.size, "homepage course links must match course overviews")
home_archive_links = home.css("[data-home-archive-link]").map { |link| link["data-home-archive-link"] }
assert.call(home_archive_links == %w[reading courses listening], "homepage archive links must match archive tabs")
expected_entry_count = posts.size + course_documents.size
actual_entry_count = home.at_css("[data-home-entry-count]")&.[]("data-home-entry-count")&.to_i
assert.call(actual_entry_count == expected_entry_count, "homepage entry count must include posts and course documents")
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
archive_tabs = archives.css("[data-archive-tab]").map { |tab| tab["data-archive-tab"] }
archive_panels = archives.css("[data-archive-panel]").map { |panel| panel["data-archive-panel"] }
expected_archive_collections = %w[reading courses listening]
assert.call(archive_tabs == expected_archive_collections, "Archives tabs must follow sidebar content order")
assert.call(archive_panels == expected_archive_collections, "Archives panels must match archive tabs")
expected_archive_collections.each do |collection|
  tab = archives.at_css(%([data-archive-tab="#{collection}"]))
  assert.call(!archives.at_css("#archive-#{collection}").nil?, "Archives requires public ##{collection} hash target")
  assert.call(
    tab&.[]("aria-controls") == "archive-panel-#{collection}" &&
      !archives.at_css("#archive-panel-#{collection}").nil?,
    "Archives #{collection} tab must control its panel"
  )
end
reading_subject_count = reading_posts.map { |_, data| Array(data["categories"])[1] || "Standalone Notes" }.uniq.size
assert.call(
  archives.css("[data-archive-reading-subject]").size == reading_subject_count,
  "Archives Reading subjects must match source categories"
)
assert.call(
  archives.css("[data-archive-reading-entry]").size == reading_posts.size,
  "Archives must index every reading post"
)
assert.call(
  archives.css("[data-archive-course-entry]").size == course_documents.size,
  "Archives must index every course document"
)
assert.call(
  archives.css("[data-archive-listening-entry]").size == podcast_posts.size,
  "Archives must index every podcast post"
)
assert.call(reading.css(".reading-series-item").size == series_registry.size, "Reading must render every mapped series")
assert.call(reading.css(".reading-note-row").empty?, "Reading initial HTML must not render all notes")
active_topics = topic_registry.keys.select do |topic|
  reading_posts.any? { |_, data| Array(data["topics"]).include?(topic) }
end
expected_topic_series = active_topics.sum do |topic|
  reading_posts.filter_map do |_, data|
    data["series"] if Array(data["topics"]).include?(topic)
  end.uniq.size
end
expected_topic_note_links = reading_posts.sum do |_, data|
  Array(data["topics"]).count { |topic| topic_registry.key?(topic) }
end
assert.call(
  reading.css("[data-reading-topic-card]").size == active_topics.size,
  "Reading Topics must render every active topic"
)
assert.call(
  reading.css("[data-reading-topic-series]").size == expected_topic_series,
  "Reading Topics must group notes by series"
)
assert.call(
  reading.css("[data-reading-topic-series] ol li").size == expected_topic_note_links,
  "Reading Topic series groups must include every matching note"
)
assert.call(
  reading.css("[data-reading-topic-series] .reading-series-link").size == expected_topic_series,
  "Reading Topic series groups must link their series pages"
)
language_count = reading_posts.map { |_, data| data["content_lang"] }.uniq.size
language_filter_present = !reading.at_css('[data-reading-filter="language"]').nil?
assert.call(language_filter_present == (language_count > 1), "language filter activation gate mismatch")
reading_status_count = reading_posts.map { |_, data| data["status"] }.uniq.size
status_filter_present = !reading.at_css('[data-reading-filter="status"]').nil?
assert.call(status_filter_present == (reading_status_count > 1), "status filter activation gate mismatch")
assert.call(
  podcasts.css(".podcast-list-item").size == podcast_posts.size,
  "Podcast Notes must render every podcast post"
)
assert.call(
  podcasts.css(".podcast-source-link[target='_blank'][rel~='noopener'][rel~='noreferrer']").size == podcast_posts.size,
  "Podcast Notes source links must open safely"
)
assert.call(
  podcasts.css("[data-podcast-show-filter] option").size == podcast_show_registry.size + 1,
  "Podcast Notes show filter must match the show registry"
)

podcast_posts.each do |path, data|
  %w[podcast_cover transcript_jsonl transcript_txt study_cards].each do |field|
    asset_path = data.fetch(field).delete_prefix("/")
    assert.call(File.file?(File.join(source_dir, asset_path)), "#{path}: missing #{field} asset")
  end

  transcript_path = File.join(source_dir, data.fetch("transcript_jsonl").delete_prefix("/"))
  next unless File.file?(transcript_path)

  begin
    rows = File.foreach(transcript_path, encoding: "UTF-8").filter_map do |line|
      JSON.parse(line) unless line.strip.empty?
    end
    valid_rows = rows.any? && rows.each_with_index.all? do |row, index|
      row["start"].is_a?(Numeric) && row["end"].is_a?(Numeric) && row["text"].is_a?(String) &&
        row["end"] >= row["start"] && (index.zero? || row["start"] >= rows[index - 1]["start"])
    end
    assert.call(valid_rows, "#{path}: transcript rows must be valid and chronologically ordered")
    if valid_rows
      duration_delta = (rows.last["end"] - data.fetch("episode_duration_seconds")).abs
      assert.call(duration_delta <= 60, "#{path}: transcript duration differs by more than 60 seconds")
    end
  rescue JSON::ParserError => e
    failures << "#{path}: transcript JSONL is invalid (#{e.message})"
  end
end

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

category_page = parse.call("categories/ai-engineering/index.html")
assert.call(
  category_page.at_css("#topbar-title")&.text&.strip == "AI Engineering",
  "category topbar must show the current taxonomy title"
)
ai_system_category = parse.call("categories/ai-系统/index.html")
ai_system_podcasts = podcast_posts.count { |_, data| Array(data["categories"])[1] == "AI 系统" }
assert.call(
  ai_system_category.css('[data-taxonomy-direct-group="podcast"] li').size == ai_system_podcasts,
  "cross-type category pages must label direct Listening entries"
)

core_files = %w[index.html reading/index.html archives/index.html categories/ai-engineering/index.html]
core_files.each do |path|
  document = parse.call(path)
  assert.call(document.css("h1").size == 1, "#{path} must contain one h1")
  assert.call(!document.at_css("main#main-content").nil?, "#{path} is missing main landmark")
  assert.call(!document.at_css('a.skip-link[href="#main-content"]').nil?, "#{path} is missing skip link")
end

overview_count = 0
reading_guide_count = 0
Dir.glob(File.join(site_dir, "posts", "*", "index.html")).each do |path|
  document = Nokogiri::HTML(File.read(path, encoding: "UTF-8"))
  normalized_path = path.tr("\\", "/")
  public_url = "/#{normalized_path.delete_prefix("#{site_dir}/").delete_suffix("index.html")}"
  expected_guide_uid = reading_guide_uid_by_url[public_url]
  guided_article = document.at_css('article[data-learning-guide="true"]')
  if expected_guide_uid
    reading_guide_count += 1
    assert.call(!guided_article.nil?, "#{path} must enable its reading guide")
    guide = reading_guides_by_uid.fetch(expected_guide_uid)
    tabs = document.css(".learning-mode-tabs [data-learning-mode]")
    panels = document.css("[data-learning-panel]")
    expected_modes = %w[overview detail check]
    assert.call(tabs.map { |tab| tab["data-learning-mode"] } == expected_modes, "#{path} learning tabs mismatch")
    assert.call(panels.map { |panel| panel["data-learning-panel"] } == expected_modes, "#{path} learning panels mismatch")
    tabs.zip(panels).each do |tab, panel|
      assert.call(tab["aria-controls"] == panel["id"], "#{path} learning tab controls mismatch")
      assert.call(panel["aria-labelledby"] == tab["id"], "#{path} learning panel label mismatch")
    end
    assert.call(tabs.first["aria-selected"] == "true", "#{path} overview tab must be selected initially")
    assert.call(panels.first["hidden"].nil?, "#{path} overview panel must be visible initially")
    assert.call(panels.drop(1).all? { |panel| panel.key?("hidden") }, "#{path} inactive learning panels must be hidden")
    guide_kind = guide.dig("overview", "kind") || "summary"
    expected_sections = guide.dig("overview", "sections")
    summary_sections = document.css(".learning-summary-section")
    assert.call(summary_sections.size == expected_sections.size, "#{path} learning summary section count mismatch")
    summary_sections.zip(expected_sections).each do |section, expected_section|
      assert.call(section.at_css("h4")&.text&.strip == expected_section["title"], "#{path} learning summary title mismatch")
      assert.call(
        section.css("p").map { |paragraph| paragraph.text.strip } == expected_section["paragraphs"],
        "#{path} learning summary paragraphs mismatch"
      )
    end
    check_range = guide_kind == "index" ? (2..5) : (3..8)
    assert.call(check_range.cover?(document.css(".learning-check-list > li").size), "#{path} learning checks mismatch")
    if guide_kind == "index"
      assert.call(document.at_css("#learning-summary-title")&.text&.strip == "页面摘要", "#{path} index summary label mismatch")
      assert.call(document.at_css(".learning-concepts").nil?, "#{path} index guide must not invent concepts")
      assert.call(document.at_css(".learning-logic").nil?, "#{path} index guide must not invent a logic outline")
      assert.call(document.at_css(".learning-takeaways").nil?, "#{path} index guide must not invent takeaways")
    end
  else
    assert.call(guided_article.nil?, "#{path} enables a reading guide without sidecar data")
    assert.call(document.at_css(".learning-mode-picker").nil?, "#{path} must keep the standard reading layout")
  end

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
assert.call(reading_guide_count == reading_guide_uids.size, "rendered reading guide count mismatch")

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

puts "Garden validation passed: #{posts.size} posts, #{series_registry.size} series, #{topic_registry.size} topics, #{overview_count} chapter overviews, #{reading_guide_count} reading guides, #{inline_scripts.size} inline scripts"