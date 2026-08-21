# frozen_string_literal: true

require "date"
require "digest"
require "fileutils"
require "json"
require "kramdown"
require "kramdown-parser-gfm"
require "nokogiri"
require "optparse"
require "pathname"
require "set"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
POST_GLOB = ROOT.join("_posts", "**", "*.md").to_s
GUIDE_DIR = ROOT.join("_data", "reading_guides")
EXTRACTION_VERSION = "deterministic-extractive-v4"

EXCLUDED_SECTION = /(?:参考文献|引用与来源|附录|代码索引|实现索引|术语表|勘误|目录|完整代码|练习题|习题|延伸阅读|进一步阅读)/i
CHECK_SECTION = /(?:容易混淆|易混|常见误区|常见误解|重点辨析|概念辨析)/i
SYNTHESIS_SECTION = /(?:核心结论|本章总结|全文总结|最终总结|原章总结|知识结构|知识图谱|结语|回顾)/i
QUESTION_HEADING = /(?:为什么|如何|什么|怎样|何时|是否|哪些|哪种|怎么|为何)/
INLINE_MATH = /(?<!\\)(?<!\$)\$(?!\$)(?=\S)[^$\n]+?(?<=\S)\$(?!\$)/
DISPLAY_MATH = /(?<!\\)\$\$|\\\[|\\\(/
RESIDUAL_TEX = /\\(?:[A-Za-z]+|\(|\)|\[|\])|\$(?=(?:[A-Za-z]|\\|\s))/
TECHNICAL_MARKER = "__READING_GUIDE_TECHNICAL__"

class GenerationError < StandardError; end

class ExtractiveGuideGenerator
  SUMMARY_SECTION_RANGE = (4..10)
  SUMMARY_PARAGRAPH_RANGE = (2..4)
  INDEX_SECTION_RANGE = (1..3)
  INDEX_PARAGRAPH_RANGE = (1..4)
  CONCEPT_RANGE = (3..8)
  LOGIC_RANGE = (3..7)
  TAKEAWAY_RANGE = (3..6)
  CHECK_RANGE = (3..8)
  INDEX_CHECK_RANGE = (2..5)

  def initialize(path, data, body)
    @path = path
    @data = data
    @body = body
    @fragment = markdown_fragment(body)
    @preamble, @sections = section_tree(@fragment)
  end

  def generate
    summary_sections = select_summary_sections
    guide_kind = "summary"
    if summary_sections.size < SUMMARY_SECTION_RANGE.begin && index_page?
      summary_sections = select_index_sections
      guide_kind = "index"
    end

    section_range = guide_kind == "index" ? INDEX_SECTION_RANGE : SUMMARY_SECTION_RANGE
    unless section_range.cover?(summary_sections.size)
      raise GenerationError, "requires #{section_range.begin}..#{section_range.end} source-backed #{guide_kind} sections"
    end

    concepts = guide_kind == "index" ? [] : build_concepts(summary_sections)
    logic = guide_kind == "index" ? [] : select_evenly(summary_sections.map { |section| section.fetch("title") }, LOGIC_RANGE.end)
    takeaways = guide_kind == "index" ? [] : build_takeaways(summary_sections)
    checks = guide_kind == "index" ? build_index_checks(summary_sections) : build_checks(summary_sections)
    thesis, thesis_source = opening_thesis(summary_sections)
    question, question_source = opening_question(summary_sections)
    summary_characters = summary_sections.sum do |section|
      section.fetch("paragraphs").sum(&:length)
    end

    unless guide_kind == "index"
      validate_cardinality!("concepts", concepts, CONCEPT_RANGE)
      validate_cardinality!("logic", logic, LOGIC_RANGE)
      validate_cardinality!("takeaways", takeaways, TAKEAWAY_RANGE)
    end
    validate_cardinality!("checks", checks, guide_kind == "index" ? INDEX_CHECK_RANGE : CHECK_RANGE)

    guide = {
      "source" => {
        "post" => relative_path,
        "body_sha256" => Digest::SHA256.hexdigest(@body),
        "extraction" => EXTRACTION_VERSION,
        "fidelity" => "extractive"
      },
      "overview" => {
        "kind" => guide_kind,
        "minutes" => guide_kind == "index" ? [[(summary_characters / 300.0).ceil, 1].max, 10].min : [[(summary_characters / 300.0).ceil, 8].max, 30].min,
        "question" => question,
        "question_source" => question_source,
        "thesis" => thesis,
        "thesis_source" => thesis_source,
        "concepts" => concepts,
        "logic" => logic,
        "sections" => summary_sections,
        "takeaways" => takeaways
      },
      "check_intro" => "以下问题只检验现有正文明确说明的内容。请先根据原文脉络作答，再展开参考答案核对。",
      "checks" => checks
    }

    validate_fidelity!(guide)
    [guide, audit_entry(guide, summary_characters)]
  end

  private

  def markdown_fragment(body)
    html = Kramdown::Document.new(body, input: "GFM").to_html
    Nokogiri::HTML.fragment(html)
  end

  def section_tree(fragment)
    preamble = { title: "导言", nodes: [], subsections: [] }
    sections = []
    current_section = nil
    current_subsection = nil
    heading_levels = fragment.css("h2, h3, h4").map { |heading| heading.name.delete_prefix("h").to_i }
    primary_level = heading_levels.min || 2

    fragment.children.each do |node|
      next if node.text? && node.text.strip.empty?

      heading_level = if node.element? && node.name.match?(/\Ah[2-4]\z/)
                        node.name.delete_prefix("h").to_i
                      end
      if heading_level == primary_level
        current_section = section_record(clean_node_text(node))
        sections << current_section
        current_subsection = nil
      elsif heading_level == primary_level + 1 && current_section
        current_subsection = section_record(clean_node_text(node))
        current_section[:subsections] << current_subsection
      elsif heading_level
        next
      else
        target = current_subsection || current_section || preamble
        target[:nodes] << node
      end
    end

    [preamble, sections]
  end

  def section_record(title)
    { title: title, nodes: [], subsections: [] }
  end

  def extract_units(section)
    extract_units_with_options(section)
  end

  def extract_units_with_options(section, minimum_length: 36, include_tables: false)
    nodes = section.fetch(:nodes)
    units = nodes.flat_map do |node|
      next [] unless node.element?
      next [] if node.css("pre, img, svg").any?

      case node.name
      when "p"
        text_units(node, minimum_length: minimum_length)
      when "ul", "ol"
        list_minimum = [minimum_length, 16].min
        node.xpath("./li").flat_map { |item| text_units(item, minimum_length: list_minimum) }
      when "blockquote", "div", "aside", "details"
        node.css("p").flat_map { |paragraph| text_units(paragraph, minimum_length: minimum_length) }
      when "table"
        include_tables ? table_units(node, minimum_length: minimum_length) : []
      else
        []
      end
    end

    units.flatten.compact.uniq
  end

  def section_units(section)
    section_units_with_options(section)
  end

  def section_units_with_options(section, minimum_length: 36, include_tables: false)
    direct = extract_units_with_options(section, minimum_length: minimum_length, include_tables: include_tables)
    nested = section.fetch(:subsections).flat_map do |subsection|
      extract_units_with_options(subsection, minimum_length: minimum_length, include_tables: include_tables)
    end
    (direct + nested).uniq
  end

  def text_units(node, minimum_length: 36)
    copy = node.dup
    copy.css("code, script, .katex, .kdmath, .math").each do |technical|
      plain_term = plain_math_term(technical)
      technical.replace(plain_term ? " #{plain_term} " : " #{TECHNICAL_MARKER} ")
    end
    text = normalize_plain_math_terms(clean_node_text(copy))
    candidates = if text.include?(TECHNICAL_MARKER) || forbidden_overview_text?(text)
                   text.split(/(?<=[。！？!?])\s*/)
                 else
                   [text]
                 end

    candidates.filter_map do |candidate|
      candidate = candidate.strip
      next if candidate.include?(TECHNICAL_MARKER)
      next unless prose_text?(candidate, minimum_length: minimum_length)

      candidate
    end
  end

  def table_units(node, minimum_length:)
    node.css("tr").filter_map do |row|
      next if row.css("td").empty?

      cells = row.css("th, td").filter_map do |cell|
        value = normalize_plain_math_terms(clean_node_text(cell))
        value unless value.empty? || forbidden_overview_text?(value)
      end
      value = cells.join(" · ")
      value if prose_text?(value, minimum_length: minimum_length)
    end
  end

  def plain_math_term(node)
    return unless node.matches?(".katex, .kdmath, .math")

    value = node.text.strip
      .sub(/\A\\\(/, "")
      .sub(/\\\)\z/, "")
      .sub(/\A\$/, "")
      .sub(/\$\z/, "")
      .strip
    value if value.match?(/\A[A-Za-z](?:_[A-Za-z0-9]+)?\z/)
  end

  def normalize_plain_math_terms(text)
    text.gsub(/(?<!\\)(?<!\$)\$([A-Za-z](?:_[A-Za-z0-9]+)?)\$(?!\$)/, '\\1')
  end

  def clean_node_text(node)
    copy = node.dup
    copy.css("sup.footnote, a.reversefootnote").remove
    copy.text
      .gsub(/[[:space:]]+/, " ")
      .gsub(/(?<=[\u3400-\u9FFF\uF900-\uFAFF]) (?=[\u3400-\u9FFF\uF900-\uFAFF])/, "")
      .gsub(/ (?=[，。！？；：])/, "")
      .strip
  end

  def prose_text?(text, minimum_length: 36)
    return false if text.length < minimum_length
    return false if text.start_with?("对应原文：", "原文：", "参考文献：")
    return false if text.match?(/(?:：|:|是|包括|如下|分为|例如|即|有|需要注意)\z/)
    return false if forbidden_overview_text?(text)

    true
  end

  def forbidden_overview_text?(text)
    text.include?("`") || text.match?(INLINE_MATH) || text.match?(DISPLAY_MATH) || text.match?(RESIDUAL_TEX)
  end

  def eligible_section?(section)
    title = section.fetch(:title)
    return false if title.empty? || title.match?(EXCLUDED_SECTION) || title.match?(CHECK_SECTION)
    return false if forbidden_overview_text?(title)

    section_units(section).any?
  end

  def summary_candidate(section)
    units = section_units(section).flat_map { |text| sentence_chunks(text) }.uniq
    return if units.size < SUMMARY_PARAGRAPH_RANGE.begin

    {
      "title" => section.fetch(:title),
      "source_heading" => section.fetch(:title),
      "paragraphs" => select_informative(units, [units.size, SUMMARY_PARAGRAPH_RANGE.end].min)
    }
  end

  def select_summary_sections
    candidates = @sections.flat_map do |section|
      parent = summary_candidate(section) if eligible_section?(section)
      nested = section.fetch(:subsections).filter_map do |subsection|
        summary_candidate(subsection) if eligible_section?(subsection)
      end
      parent_characters = parent&.fetch("paragraphs")&.sum(&:length).to_i

      if parent.nil? || parent_characters < 220 && nested.size >= 2
        nested
      else
        [parent]
      end
    end

    if candidates.size < SUMMARY_SECTION_RANGE.begin
      candidates = @sections.flat_map do |section|
        parent = summary_candidate(section) if eligible_section?(section)
        nested = section.fetch(:subsections).filter_map do |subsection|
          summary_candidate(subsection) if eligible_section?(subsection)
        end
        nested.empty? ? [parent].compact : nested
      end
    end

    select_evenly(candidates.uniq { |section| section.fetch("source_heading") }, SUMMARY_SECTION_RANGE.end)
  end

  def index_page?
    @body.match?(/本文件(?:作为|只维护).*(?:导航|目录|进度)/)
  end

  def select_index_sections
    candidates = [@preamble, *@sections].filter_map do |section|
      units = section_units_with_options(section, minimum_length: 8, include_tables: true)
      next if units.empty?

      {
        "title" => section.fetch(:title),
        "source_heading" => section.fetch(:title),
        "paragraphs" => select_evenly(units, [units.size, INDEX_PARAGRAPH_RANGE.end].min)
      }
    end
    select_evenly(candidates, INDEX_SECTION_RANGE.end)
  end

  def sentence_chunks(text)
    return [text] if text.length <= 320

    sentences = text.split(/(?<=[。！？!?])\s*/).reject(&:empty?)
    return [text] if sentences.size < 2

    chunks = []
    current = +""
    sentences.each do |sentence|
      separator = current.empty? || current.end_with?(" ") || sentence.start_with?(" ") ? "" : sentence.match?(/\A[\x00-\x7F]/) ? " " : ""
      candidate = "#{current}#{separator}#{sentence.strip}"
      if !current.empty? && candidate.length > 280
        chunks << current
        current = sentence.strip
      else
        current = candidate
      end
    end
    chunks << current unless current.empty?
    chunks
  end

  def build_concepts(summary_sections)
    candidates = summary_sections.map do |section|
      {
        "term" => section.fetch("title"),
        "meaning" => section.fetch("paragraphs").max_by { |paragraph| passage_score(paragraph) },
        "source_heading" => section.fetch("source_heading")
      }
    end
    select_evenly(candidates, [candidates.size, 6].min)
  end

  def build_takeaways(summary_sections)
    source_units = @sections.select { |section| section.fetch(:title).match?(SYNTHESIS_SECTION) }
      .flat_map { |section| section_units(section) }
      .flat_map { |text| sentence_chunks(text) }
      .uniq

    if source_units.size < TAKEAWAY_RANGE.begin
      source_units += summary_sections.map { |section| section.fetch("paragraphs").last }
      source_units.uniq!
    end

    select_evenly(source_units, [source_units.size, 5].min)
  end

  def build_checks(summary_sections)
    source_records = @sections.select { |section| section.fetch(:title).match?(CHECK_SECTION) }.flat_map do |section|
      nested = section.fetch(:subsections).filter_map { |subsection| check_source(subsection, "概念辨析") }
      nested.empty? ? [check_source(section, "概念辨析")].compact : nested
    end

    fallback_levels = %w[概念复述 关系解释 边界判断]
    if source_records.size < CHECK_RANGE.begin
      summary_sections.each_with_index do |section, index|
        source_records << {
          title: section.fetch("title"),
          source_heading: section.fetch("source_heading"),
          answer: section.fetch("paragraphs").max_by { |paragraph| passage_score(paragraph) },
          level: fallback_levels[index % fallback_levels.size]
        }
      end
    end

    records = source_records.uniq { |record| [record.fetch(:source_heading), record.fetch(:answer)] }
    records = select_evenly(records, [records.size, 5].min)
    records.map do |record|
      title = record.fetch(:title)
      {
        "level" => record.fetch(:level),
        "question" => check_question(title),
        "answer" => record.fetch(:answer),
        "source_heading" => record.fetch(:source_heading)
      }
    end.uniq { |check| check.fetch("question") }
  end

  def build_index_checks(summary_sections)
    summary_sections.map do |section|
      {
        "level" => "页面理解",
        "question" => check_question(section.fetch("title")),
        "answer" => section.fetch("paragraphs").join("；"),
        "source_heading" => section.fetch("source_heading")
      }
    end
  end

  def check_source(section, level)
    source_heading = section.fetch(:title)
    title = normalize_plain_math_terms(source_heading)
    return if forbidden_overview_text?(title)

    answer = section_units(section).flat_map { |text| sentence_chunks(text) }
      .max_by { |candidate| passage_score(candidate) }
    return if answer.nil?

    { title: title, source_heading: source_heading, answer: answer, level: level }
  end

  def check_question(title)
    return title if title.end_with?("？", "?")
    return "#{title}？" if title.match?(QUESTION_HEADING)

    "原文如何解释「#{title}」？"
  end

  def opening_thesis(summary_sections)
    synthesis = @sections.filter_map do |section|
      next unless section.fetch(:title).match?(SYNTHESIS_SECTION)

      passage = section_units(section).flat_map { |text| sentence_chunks(text) }.max_by do |candidate|
        thesis_priority = candidate.match?(/(?:核心|本质|原则)/) ? 2 : candidate.match?(/(?:总之|因此|最终)/) ? 1 : 0
        [thesis_priority, *passage_score(candidate)]
      end
      [passage, section.fetch(:title)] if passage
    end.max_by { |passage, _| passage.length }
    return synthesis if synthesis

    section = summary_sections.max_by { |candidate| candidate.fetch("paragraphs").map(&:length).max }
    [section.fetch("paragraphs").max_by { |paragraph| passage_score(paragraph) }, section.fetch("source_heading")]
  end

  def opening_question(summary_sections)
    title = summary_sections.first.fetch("title")
    question = if title.end_with?("？", "?")
                 title
               elsif title.match?(QUESTION_HEADING)
                 "#{title}？"
               else
                 "原文围绕「#{title}」建立了怎样的核心认识？"
               end
    [question, title]
  end

  def select_evenly(items, count)
    return items if items.size <= count
    return [items.first] if count == 1

    indexes = (0...count).map do |index|
      (index * (items.size - 1).to_f / (count - 1)).round
    end
    indexes.uniq.map { |index| items.fetch(index) }
  end

  def select_informative(items, count)
    indexes = items.each_index.sort_by { |index| [-items.fetch(index).length, index] }.first(count).sort
    indexes.map { |index| items.fetch(index) }
  end

  def passage_score(text)
    self_contained = text.match?(/\A(?:它|这|其|其中|因此|所以|由此|得到|可见|即|就会)/) ? 0 : 1
    complete = text.match?(/[。！？!?]\z/) ? 1 : 0
    [self_contained, complete, text.length]
  end

  def validate_cardinality!(label, value, range)
    return if range.cover?(value.size)

    raise GenerationError, "#{label} has #{value.size} entries; expected #{range.begin}..#{range.end}"
  end

  def validate_fidelity!(guide)
    overview = guide.fetch("overview")
    headings = [@preamble, *@sections, *@sections.flat_map { |section| section.fetch(:subsections) }]
      .map { |section| section.fetch(:title) }
      .to_set
    referenced_headings = [overview["question_source"], overview["thesis_source"]]
    referenced_headings.concat(overview.fetch("logic"))
    referenced_headings.concat(overview.fetch("concepts").map { |concept| concept.fetch("source_heading") })
    referenced_headings.concat(overview.fetch("sections").map { |section| section.fetch("source_heading") })
    referenced_headings.concat(guide.fetch("checks").map { |check| check.fetch("source_heading") })
    missing_headings = referenced_headings.compact.uniq.reject { |heading| headings.include?(heading) }
    unless missing_headings.empty?
      raise GenerationError, "source headings do not exist: #{missing_headings.join(', ')}"
    end

    source_passages = [@preamble, *@sections].flat_map do |section|
      section_units_with_options(section, minimum_length: 1, include_tables: true)
    end.flat_map { |text| sentence_chunks(text) }.uniq.to_set
    extracted_passages = [overview.fetch("thesis")]
    extracted_passages.concat(overview.fetch("concepts").map { |concept| concept.fetch("meaning") })
    extracted_passages.concat(overview.fetch("sections").flat_map { |section| section.fetch("paragraphs") })
    extracted_passages.concat(overview.fetch("takeaways"))
    unless overview.fetch("kind") == "index"
      extracted_passages.concat(guide.fetch("checks").map { |check| check.fetch("answer") })
    end
    unsupported = extracted_passages.uniq.reject { |passage| source_passages.include?(passage) }
    return if unsupported.empty?

    raise GenerationError, "generated passage is not present in normalized source: #{unsupported.first.inspect}"
  end

  def relative_path
    @path.relative_path_from(ROOT).to_s.encode("UTF-8").tr("\\", "/")
  end

  def audit_entry(guide, summary_characters)
    {
      "uid" => @data.fetch("uid"),
      "post" => relative_path,
      "status" => "generated",
      "extraction" => EXTRACTION_VERSION,
      "kind" => guide.dig("overview", "kind"),
      "summary_sections" => guide.dig("overview", "sections").size,
      "summary_paragraphs" => guide.dig("overview", "sections").sum { |section| section.fetch("paragraphs").size },
      "summary_characters" => summary_characters,
      "checks" => guide.fetch("checks").size,
      "source_sha256" => guide.dig("source", "body_sha256")
    }
  end
end

def first_difference(expected, actual, path = "$")
  return "#{path}: expected #{expected.class}, found #{actual.class}" unless expected.class == actual.class

  case expected
  when Hash
    missing = expected.keys - actual.keys
    extra = actual.keys - expected.keys
    return "#{path}: missing keys #{missing.inspect}" unless missing.empty?
    return "#{path}: unexpected keys #{extra.inspect}" unless extra.empty?

    expected.each do |key, value|
      difference = first_difference(value, actual.fetch(key), "#{path}.#{key}")
      return difference if difference
    end
    nil
  when Array
    return "#{path}: expected #{expected.size} items, found #{actual.size}" unless expected.size == actual.size

    expected.each_with_index do |value, index|
      difference = first_difference(value, actual.fetch(index), "#{path}[#{index}]")
      return difference if difference
    end
    nil
  else
    expected == actual ? nil : "#{path}: expected #{expected.inspect}, found #{actual.inspect}"
  end
end

options = {
  write: false,
  check: false,
  force: false,
  uids: [],
  audit: nil
}

OptionParser.new do |parser|
  parser.banner = "Usage: bundle exec ruby tools/generate-reading-guides.rb [options]"
  parser.on("--write", "Write generated sidecars") { options[:write] = true }
  parser.on("--check", "Fail if generated sidecars are missing or stale") { options[:check] = true }
  parser.on("--force", "Overwrite curated sidecars as well as generated ones") { options[:force] = true }
  parser.on("--uid UID", "Process only this uid; may be repeated") { |uid| options[:uids] << uid }
  parser.on("--audit PATH", "Write a JSON provenance and coverage report") { |path| options[:audit] = path }
end.parse!

raise OptionParser::InvalidOption, "--write and --check cannot be combined" if options[:write] && options[:check]

posts = Dir.glob(POST_GLOB).sort.filter_map do |raw_path|
  path = Pathname.new(raw_path)
  parts = File.read(path, encoding: "UTF-8").split(/^---\s*$/, 3)
  next unless parts.size == 3

  data = YAML.safe_load(parts[1], permitted_classes: [Date, Time], aliases: true) || {}
  next unless data["type"] == "reading"
  next if options[:uids].any? && !options[:uids].include?(data["uid"])

  [path, data, parts[2]]
end

results = []
errors = []
FileUtils.mkdir_p(GUIDE_DIR) if options[:write]

posts.each do |path, data, body|
  uid = data.fetch("uid")
  begin
    guide, audit = ExtractiveGuideGenerator.new(path, data, body).generate
    output_path = GUIDE_DIR.join("#{uid}.yml")
    existing = output_path.file? ? YAML.safe_load_file(output_path, aliases: true) : nil
    curated = existing && existing.dig("source", "fidelity") != "extractive"

    if options[:check] && existing.nil?
      raise GenerationError, "missing generated sidecar; run with --write"
    elsif options[:check] && !curated && existing != guide
      difference = first_difference(guide, existing)
      raise GenerationError, "generated sidecar is stale (#{difference}); run with --write and review the diff"
    elsif options[:write] && (!curated || options[:force])
      yaml = YAML.dump(guide).sub(/\A---\s*\n/, "")
      File.write(output_path, yaml, encoding: "UTF-8")
      audit["status"] = existing ? "updated" : "written"
    elsif curated
      audit["status"] = "curated-existing"
    elsif options[:check]
      audit["status"] = "verified"
    else
      audit["status"] = options[:write] ? "unchanged" : "dry-run"
    end
    results << audit
  rescue GenerationError, KeyError, Psych::SyntaxError => error
    errors << { "uid" => uid, "post" => path.relative_path_from(ROOT).to_s.tr("\\", "/"), "error" => error.message }
  end
end

report = {
  "extraction" => EXTRACTION_VERSION,
  "reading_posts" => posts.size,
  "successful" => results.size,
  "failed" => errors.size,
  "guides" => results,
  "errors" => errors
}

if options[:audit]
  audit_path = ROOT.join(options[:audit])
  FileUtils.mkdir_p(audit_path.dirname)
  File.write(audit_path, JSON.pretty_generate(report), encoding: "UTF-8")
end

puts "Reading guide extraction: #{results.size}/#{posts.size} successful, #{errors.size} failed"
results.group_by { |entry| entry.fetch("status") }.sort.each do |status, entries|
  puts "  #{status}: #{entries.size}"
end
errors.first(20).each { |error| warn "  #{error.fetch('uid')}: #{error.fetch('error')}" }
warn "  ... #{errors.size - 20} more failures" if errors.size > 20

exit 1 unless errors.empty?