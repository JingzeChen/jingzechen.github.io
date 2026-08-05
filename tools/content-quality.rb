# frozen_string_literal: true

require "date"
require "json"
require "kramdown"
require "optparse"
require "yaml"

options = { check: false }
OptionParser.new do |parser|
  parser.on("--check", "Fail when quality gates regress") { options[:check] = true }
  parser.on("--json PATH", "Write the report as JSON") { |path| options[:json] = path }
  parser.on("--markdown PATH", "Write the report as Markdown") { |path| options[:markdown] = path }
end.parse!

source_dir = File.expand_path("..", __dir__)
config = YAML.safe_load_file(File.join(source_dir, "_config.yml"), aliases: true)
hidden_topics = Array(config.dig("garden", "hidden_topics"))
template_description = /梳理核心概念、论证结构、适用边\s*界与实践要点/

posts = Dir.glob(File.join(source_dir, "_posts", "**", "*.md")).map do |path|
  text = File.read(path, encoding: "UTF-8")
  parts = text.split(/^---\s*$/, 3)
  data = YAML.safe_load(parts[1], permitted_classes: [Date, Time], aliases: true) || {}
  root = Kramdown::Document.new(parts[2].to_s, input: "GFM").root
  stack = [root]
  heading_counts = Hash.new(0)
  until stack.empty?
    element = stack.pop
    heading_counts[element.options[:level]] += 1 if element.type == :header
    stack.concat(element.children.reverse)
  end
  {
    "path" => path.delete_prefix("#{source_dir}/").tr("\\", "/"),
    "uid" => data["uid"],
    "type" => data["type"],
    "status" => data["status"],
    "language" => data["content_lang"],
    "series" => data["series"],
    "series_order" => data["series_order"],
    "topics" => Array(data["topics"]),
    "description" => data["description"].to_s,
    "updated" => data["updated"].to_s,
    "toc_items" => (2..4).sum { |level| heading_counts[level] },
    "h2_count" => heading_counts[2]
  }
end

visible_edges = Hash.new(0)
posts.each do |post|
  (post["topics"] - hidden_topics).combination(2) { |pair| visible_edges[pair.sort.join("|")] += 1 }
end

descriptions = posts.map { |post| post["description"] }
duplicate_descriptions = descriptions.tally.select { |_, count| count > 1 }
overlong_descriptions = posts.select do |post|
  post["description"].length > (post["language"] == "en" ? 180 : 100)
end
review_candidates = posts.select { |post| post["toc_items"] > 120 }
  .sort_by { |post| [-post["toc_items"], post["path"]] }

report = {
  "posts" => posts.size,
  "types" => posts.map { |post| post["type"] }.tally.sort.to_h,
  "statuses" => posts.map { |post| post["status"] }.tally.sort.to_h,
  "languages" => posts.map { |post| post["language"] }.tally.sort.to_h,
  "series_count" => posts.map { |post| post["series"] }.compact.uniq.size,
  "featured_count" => posts.count do |post|
    front = File.read(File.join(source_dir, post["path"]), encoding: "UTF-8").split(/^---\s*$/, 3)[1]
    YAML.safe_load(front, permitted_classes: [Date, Time], aliases: true)["featured"] == true
  end,
  "template_descriptions" => posts.count { |post| post["description"].match?(template_description) },
  "duplicate_descriptions" => duplicate_descriptions.size,
  "description_length" => {
    "min" => descriptions.map(&:length).min,
    "max" => descriptions.map(&:length).max
  },
  "descriptions_over_limit" => overlong_descriptions.size,
  "hidden_topic_assignments" => posts.sum { |post| (post["topics"] & hidden_topics).size },
  "topic_cooccurrence_edges" => visible_edges.size,
  "updated_dates" => posts.map { |post| post["updated"] }.tally.sort.to_h,
  "toc_over_80" => posts.count { |post| post["toc_items"] > 80 },
  "toc_over_120" => review_candidates.size,
  "h2_over_20" => posts.count { |post| post["h2_count"] > 20 },
  "max_toc_items" => posts.map { |post| post["toc_items"] }.max,
  "activation_gates" => {
    "status_filter" => posts.map { |post| post["status"] }.uniq.size > 1,
    "language_filter" => posts.map { |post| post["language"] }.uniq.size > 1,
    "cross_type_library" => posts.map { |post| post["type"] }.uniq.size > 1,
    "knowledge_map" => visible_edges.any?
  },
  "toc_review_candidates" => review_candidates.map do |post|
    post.slice("uid", "series", "toc_items", "h2_count", "path")
  end
}

if options[:json]
  File.write(options[:json], "#{JSON.pretty_generate(report)}\n", encoding: "UTF-8")
end

markdown = <<~MARKDOWN
    # Digital Garden Content Quality Report

    This report is generated from the current `_posts/` source with `tools/content-quality.rb`.

    ## Inventory

    | Metric | Value |
    | --- | ---: |
    | Posts | #{report["posts"]} |
    | Series | #{report["series_count"]} |
    | Featured entries | #{report["featured_count"]} |
    | Template descriptions | #{report["template_descriptions"]} |
    | Duplicate descriptions | #{report["duplicate_descriptions"]} |
    | Descriptions over language limit | #{report["descriptions_over_limit"]} |
    | Hidden Topic assignments | #{report["hidden_topic_assignments"]} |
    | Topic co-occurrence edges | #{report["topic_cooccurrence_edges"]} |
    | TOC over 80 items | #{report["toc_over_80"]} |
    | TOC over 120 items | #{report["toc_over_120"]} |
    | Maximum TOC items | #{report["max_toc_items"]} |

    ## Metadata Distribution

    - Types: `#{report["types"].map { |key, value| "#{key}=#{value}" }.join(", ")}`
    - Statuses: `#{report["statuses"].map { |key, value| "#{key}=#{value}" }.join(", ")}`
    - Languages: `#{report["languages"].map { |key, value| "#{key}=#{value}" }.join(", ")}`
    - Updated dates: `#{report["updated_dates"].map { |key, value| "#{key}=#{value}" }.join(", ")}`
    - Description length: `#{report.dig("description_length", "min")}–#{report.dig("description_length", "max")}` characters

    ## Activation Gates

    | Feature | Ready |
    | --- | --- |
    | Status filter | #{report.dig("activation_gates", "status_filter") ? "Yes" : "No"} |
    | Language filter | #{report.dig("activation_gates", "language_filter") ? "Yes" : "No"} |
    | Cross-type Library | #{report.dig("activation_gates", "cross_type_library") ? "Yes" : "No"} |
    | Knowledge Map | #{report.dig("activation_gates", "knowledge_map") ? "Yes" : "No"} |

    `Latest Changes` requires a separate editorial audit of `updated`; clustered migration dates do not qualify automatically.

    ## Mandatory TOC Review

    PRD review is required when a post contains more than 120 H2–H4 items.

    | TOC | H2 | Series | UID | Source |
    | ---: | ---: | --- | --- | --- |
    #{report["toc_review_candidates"].map { |post| "| #{post["toc_items"]} | #{post["h2_count"]} | #{post["series"]} | `#{post["uid"]}` | `#{post["path"]}` |" }.join("\n")}
MARKDOWN

if options[:markdown]
  File.write(options[:markdown], markdown, encoding: "UTF-8")
end

if options[:check]
  failures = []
  failures << "template descriptions remain" unless report["template_descriptions"].zero?
  failures << "duplicate descriptions remain" unless report["duplicate_descriptions"].zero?
  failures << "hidden topics remain assigned" unless report["hidden_topic_assignments"].zero?
  failures << "descriptions exceed language-specific limits" unless report["descriptions_over_limit"].zero?
  report_path = File.join(source_dir, "docs", "CONTENT_QUALITY_REPORT.md")
  stored_markdown = File.exist?(report_path) ? File.read(report_path, encoding: "UTF-8").gsub("\r\n", "\n") : nil
  failures << "docs/CONTENT_QUALITY_REPORT.md is stale" unless stored_markdown == markdown
  abort "Content quality check failed: #{failures.join('; ')}" unless failures.empty?
end

puts JSON.generate(report.reject { |key, _| key == "toc_review_candidates" })