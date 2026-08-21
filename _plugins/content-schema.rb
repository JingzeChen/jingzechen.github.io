# frozen_string_literal: true

require "digest"
require "kramdown"
require "kramdown-parser-gfm"
require "nokogiri"
require "uri"

module Garden
  class ContentSchemaGenerator < Jekyll::Generator
    safe true
    priority :highest

    REQUIRED_FIELDS = %w[uid type status topics description content_lang].freeze
    PODCAST_REQUIRED_FIELDS = %w[
      podcast_show episode_number episode_date episode_duration episode_duration_seconds
      guests source_platform source_url podcast_cover transcript_jsonl transcript_txt study_cards
    ].freeze
    COURSE_REQUIRED_FIELDS = %w[uid type document_type course title description content_lang permalink].freeze
    COURSE_DOCUMENT_TYPES = %w[overview module lecture resource].freeze
    TEMPLATE_DESCRIPTION = /梳理核心概念、论证结构、适用边\s*界与实践要点/.freeze
    INLINE_MATH = /(?<!\\)(?<!\$)\$(?!\$)(?=\S)[^$\n]+?(?<=\S)\$(?!\$)/.freeze
    DISPLAY_MATH = /(?<!\\)\$\$|\\\[|\\\(/.freeze
    READING_GUIDE_RESIDUAL_TEX = /\\(?:[A-Za-z]+|\(|\)|\[|\])|\$(?=(?:[A-Za-z]|\\|\s))/.freeze
    UNSAFE_STAR_SUPERSCRIPT = /\^\*/.freeze
    UNSAFE_ABSOLUTE_VALUE = /(?<!\$)\$(?!\$)\|[^$\n]+\|\$(?!\$)/.freeze
    UNSAFE_INLINE_DELIMITER = /\\\(|\\\)/.freeze
    UNSAFE_DISPLAY_DELIMITER = /^\s*\\[\[\]]\s*$/.freeze
    CORRUPTED_TEX_COMMAND = /\t(?:heta|ext|au|imes|op|ilde|o|anh|riangle|ag)(?=[^A-Za-z]|$)/.freeze
    MISSING_TEX_BACKSLASH = /^\s+(?:heta|ext)(?=[_{(])/.freeze
    READING_GUIDE_OVERVIEW_RANGES = {
      "concepts" => (3..8),
      "logic" => (3..7),
      "takeaways" => (3..6)
    }.freeze
    READING_GUIDE_SUMMARY_SECTION_RANGE = (4..10).freeze
    READING_GUIDE_SUMMARY_PARAGRAPH_RANGE = (2..4).freeze
    READING_GUIDE_INDEX_SECTION_RANGE = (1..3).freeze
    READING_GUIDE_INDEX_PARAGRAPH_RANGE = (1..4).freeze
    READING_GUIDE_CHECK_RANGE = (3..8).freeze
    READING_GUIDE_INDEX_CHECK_RANGE = (2..5).freeze

    def generate(site)
      content_types = site.config.dig("garden", "content_types") || []
      statuses = site.config.dig("garden", "statuses") || []
      content_languages = site.config.dig("garden", "content_languages") || []
      hidden_topics = site.config.dig("garden", "hidden_topics") || []
      series_registry = site.data["series"] || {}
      podcast_show_registry = site.data["podcast_shows"] || {}
      course_registry = site.data["courses"] || {}
      seen_uids = {}
      seen_episodes = {}
      seen_lectures = {}
      reading_series_by_category = {}
      errors = []

      site.posts.docs.each do |post|
        enable_math(post)
        validate_math_source(post, errors)
        post.data["garden_description_valid"] = !post.data["description"].to_s.match?(TEMPLATE_DESCRIPTION)
        unless post.data["garden_description_valid"]
          errors << "#{post.relative_path}: replace the template description with a specific summary"
        end

        REQUIRED_FIELDS.each do |field|
          errors << "#{post.relative_path}: missing '#{field}'" if blank?(post.data[field])
        end

        validate_value(post, "type", content_types, errors)
        validate_value(post, "status", statuses, errors)
        validate_value(post, "content_lang", content_languages, errors)
        validate_topics(post, hidden_topics, errors)
        validate_series_order(post, errors)
        validate_series(post, series_registry, errors)
        validate_reading_taxonomy(post, reading_series_by_category, errors)
        validate_podcast(post, podcast_show_registry, seen_episodes, errors)
        validate_featured(post, errors)

        uid = post.data["uid"]
        next if blank?(uid)

        unless uid.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
          errors << "#{post.relative_path}: uid '#{uid}' must be a lowercase ASCII slug"
        end

        if seen_uids.key?(uid)
          errors << "#{post.relative_path}: duplicate uid '#{uid}' also used by #{seen_uids[uid]}"
        else
          seen_uids[uid] = post.relative_path
        end
      end

      validate_reading_guides(site.data["reading_guides"] || {}, site.posts.docs, errors)

      site.collections.fetch("courses").docs.each do |document|
        enable_math(document)
        validate_math_source(document, errors)
        COURSE_REQUIRED_FIELDS.each do |field|
          errors << "#{document.relative_path}: missing '#{field}'" if blank?(document.data[field])
        end

        errors << "#{document.relative_path}: type must be 'course'" unless document.data["type"] == "course"
        validate_value(document, "content_lang", content_languages, errors)
        validate_value(document, "document_type", COURSE_DOCUMENT_TYPES, errors)

        course_slug = document.data["course"]
        unless blank?(course_slug) || course_registry.key?(course_slug)
          errors << "#{document.relative_path}: course '#{course_slug}' has no _data/courses.yml entry"
        end

        uid = document.data["uid"]
        unless blank?(uid)
          unless uid.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
            errors << "#{document.relative_path}: uid '#{uid}' must be a lowercase ASCII slug"
          end
          if seen_uids.key?(uid)
            errors << "#{document.relative_path}: duplicate uid '#{uid}' also used by #{seen_uids[uid]}"
          else
            seen_uids[uid] = document.relative_path
          end
        end

        next unless document.data["document_type"] == "lecture"

        %w[module_number lecture_number duration_seconds timeline media_sources].each do |field|
          errors << "#{document.relative_path}: lecture missing '#{field}'" if blank?(document.data[field])
        end
        %w[module_number lecture_number duration_seconds].each do |field|
          value = document.data[field]
          unless value.nil? || value.is_a?(Numeric) && value.positive?
            errors << "#{document.relative_path}: '#{field}' must be positive"
          end
        end

        sources = document.data["media_sources"]
        unless sources.nil? || sources.is_a?(Array) && !sources.empty?
          errors << "#{document.relative_path}: 'media_sources' must be a non-empty YAML array"
          next
        end
        Array(sources).each do |source|
          unless source.is_a?(Hash) && !blank?(source["provider"]) && !blank?(source["label"])
            errors << "#{document.relative_path}: each media source requires provider and label"
          end
          unless source.is_a?(Hash) && valid_https_url?(source["url"])
            errors << "#{document.relative_path}: each media source requires a valid HTTPS url"
          end
        end

        lecture_key = [course_slug, document.data["lecture_number"]]
        if seen_lectures.key?(lecture_key)
          errors << "#{document.relative_path}: duplicate lecture also used by #{seen_lectures[lecture_key]}"
        else
          seen_lectures[lecture_key] = document.relative_path
        end
      end

      featured_count = site.posts.docs.count { |post| post.data["featured"] == true }
      unless featured_count.between?(2, 5)
        errors << "featured content count must be between 2 and 5 (found #{featured_count})"
      end

      series_registry.each do |slug, metadata|
        %w[title description url topics].each do |field|
          errors << "series '#{slug}' requires '#{field}'" if blank?(metadata[field])
        end
      end

      podcast_show_registry.each do |slug, metadata|
        %w[title platform url cover].each do |field|
          errors << "podcast show '#{slug}' requires '#{field}'" if blank?(metadata[field])
        end
        unless blank?(metadata["url"]) || valid_https_url?(metadata["url"])
          errors << "podcast show '#{slug}' requires a valid HTTPS 'url'"
        end
      end

      course_registry.each do |slug, metadata|
        %w[title short_title institution term language notes_language description course_url source_url].each do |field|
          errors << "course '#{slug}' requires '#{field}'" if blank?(metadata[field])
        end
        %w[course_url source_url].each do |field|
          unless blank?(metadata[field]) || valid_https_url?(metadata[field])
            errors << "course '#{slug}' requires a valid HTTPS '#{field}'"
          end
        end
      end

      return if errors.empty?

      raise Jekyll::Errors::FatalException,
            "Garden content schema validation failed:\n- #{errors.join("\n- ")}"
    end

    private

    def enable_math(document)
      content = document.content.to_s
      document.data["math"] = true if content.match?(INLINE_MATH) || content.match?(DISPLAY_MATH)
    end

    def validate_math_source(document, errors)
      content = prose_content(document.content.to_s)
      path = document.relative_path
      if content.match?(UNSAFE_STAR_SUPERSCRIPT)
        errors << "#{path}: use '^{\\ast}' instead of '^*' in math"
      end
      if content.match?(UNSAFE_ABSOLUTE_VALUE)
        errors << "#{path}: use '\\lvert ... \\rvert' instead of '$|...|$'"
      end
      if content.match?(UNSAFE_INLINE_DELIMITER) || content.match?(UNSAFE_DISPLAY_DELIMITER)
        errors << "#{path}: use '$...$' or '$$...$$' math delimiters"
      end
      if content.match?(CORRUPTED_TEX_COMMAND)
        errors << "#{path}: restore the leading backslash in a tab-corrupted TeX command"
      end
      if content.match?(MISSING_TEX_BACKSLASH)
        errors << "#{path}: restore the leading backslash in a TeX command"
      end
    end

    def prose_content(content)
      content
        .gsub(/```.*?```/m, "")
        .gsub(/~~~.*?~~~/m, "")
        .gsub(/`[^`\n]*`/, "")
    end

    def blank?(value)
      value.nil? || value.respond_to?(:empty?) && value.empty?
    end

    def validate_value(post, field, allowed_values, errors)
      value = post.data[field]
      return if blank?(value) || allowed_values.include?(value)

      errors << "#{post.relative_path}: invalid #{field} '#{value}' (allowed: #{allowed_values.join(", ")})"
    end

    def validate_topics(post, hidden_topics, errors)
      topics = post.data["topics"]
      return if blank?(topics)

      unless topics.is_a?(Array)
        errors << "#{post.relative_path}: 'topics' must be a YAML array"
        return
      end

      hidden = topics & hidden_topics
      errors << "#{post.relative_path}: remove hidden topics #{hidden.join(', ')}" unless hidden.empty?
    end

    def validate_series_order(post, errors)
      order = post.data["series_order"]
      return if order.nil? || order.is_a?(Integer) && order.positive?

      errors << "#{post.relative_path}: 'series_order' must be a positive integer"
    end

    def validate_series(post, registry, errors)
      series = post.data["series"]
      return if blank?(series) || registry.key?(series)

      errors << "#{post.relative_path}: series '#{series}' has no _data/series.yml entry"
    end

    def validate_reading_taxonomy(post, series_by_category, errors)
      return unless post.data["type"] == "reading"

      categories = post.data["categories"]
      unless categories.is_a?(Array) && categories.size >= 3
        errors << "#{post.relative_path}: reading content requires root, subject, and series categories"
        return
      end

      subject = categories[1]
      leaf = categories[2]
      series = post.data["series"]
      if blank?(subject) || blank?(leaf)
        errors << "#{post.relative_path}: reading subject and series categories cannot be blank"
        return
      end
      return if blank?(series)

      category_key = [subject, leaf]
      existing_series = series_by_category[category_key]
      if existing_series && existing_series != series
        errors << "#{post.relative_path}: category '#{subject} / #{leaf}' maps to both '#{existing_series}' and '#{series}'"
      else
        series_by_category[category_key] = series
      end
    end

    def validate_reading_guides(guides, posts, errors)
      unless guides.is_a?(Hash)
        errors << "_data/reading_guides must contain YAML files keyed by reading uid"
        return
      end

      posts_by_uid = posts.to_h { |post| [post.data["uid"], post] }
      guides.each do |uid, guide|
        path = "_data/reading_guides/#{uid}.yml"
        post = posts_by_uid[uid]
        unless post&.data&.fetch("type", nil) == "reading"
          errors << "#{path}: filename must match the uid of a reading post"
        end
        unless guide.is_a?(Hash)
          errors << "#{path}: guide must be a YAML object"
          next
        end

        source = guide["source"]
        unless source.is_a?(Hash)
          errors << "#{path}: missing source provenance"
        else
          errors << "#{path}: source post does not match reading uid" unless source["post"] == post&.relative_path
          raw_post = post&.path && File.read(post.path, encoding: "UTF-8")
          source_body = raw_post&.split(/^---\s*$/, 3)&.fetch(2, "").to_s
          expected_sha = Digest::SHA256.hexdigest(source_body)
          errors << "#{path}: source body changed; regenerate or review the guide" unless source["body_sha256"] == expected_sha
          errors << "#{path}: source extraction must be non-empty text" unless guide_text?(source["extraction"])
          unless %w[extractive curated-source-checked].include?(source["fidelity"])
            errors << "#{path}: source fidelity must be extractive or curated-source-checked"
          end
        end

        overview = guide["overview"]
        unless overview.is_a?(Hash)
          errors << "#{path}: missing 'overview' object"
          next
        end

        source_headings = reading_guide_source_headings(post&.content.to_s)
        referenced_headings = []
        %w[question_source thesis_source].each do |field|
          value = overview[field]
          if guide_text?(value)
            referenced_headings << value
          else
            errors << "#{path}: overview '#{field}' must be non-empty text"
          end
        end

        guide_kind = overview["kind"] || "summary"
        unless %w[summary index].include?(guide_kind)
          errors << "#{path}: overview kind must be 'summary' or 'index'"
        end

        minutes = overview["minutes"]
        minutes_range = guide_kind == "index" ? (1..10) : (8..30)
        unless minutes.is_a?(Integer) && minutes_range.cover?(minutes)
          errors << "#{path}: overview minutes must be an integer between #{minutes_range.begin} and #{minutes_range.end}"
        end

        overview_text = []
        %w[question thesis].each do |field|
          value = overview[field]
          if guide_text?(value)
            overview_text << value
          else
            errors << "#{path}: overview '#{field}' must be non-empty text"
          end
        end

        concepts = overview["concepts"]
        if guide_kind == "index"
          errors << "#{path}: index overview concepts must be empty" unless concepts == []
        else
          validate_guide_list_size(concepts, READING_GUIDE_OVERVIEW_RANGES["concepts"], "overview concepts", path, errors)
        end
        if concepts.is_a?(Array)
          concepts.each_with_index do |concept, index|
            unless concept.is_a?(Hash)
              errors << "#{path}: concept #{index + 1} must contain term and meaning"
              next
            end
            %w[term meaning].each do |field|
              value = concept[field]
              if guide_text?(value)
                overview_text << value
              else
                errors << "#{path}: concept #{index + 1} requires non-empty '#{field}'"
              end
            end
            if guide_text?(concept["source_heading"])
              referenced_headings << concept["source_heading"]
            else
              errors << "#{path}: concept #{index + 1} requires non-empty 'source_heading'"
            end
          end
        end

        %w[logic takeaways].each do |field|
          values = overview[field]
          if guide_kind == "index"
            errors << "#{path}: index overview #{field} must be empty" unless values == []
          else
            validate_guide_list_size(values, READING_GUIDE_OVERVIEW_RANGES[field], "overview #{field}", path, errors)
          end
          next unless values.is_a?(Array)

          if values.all? { |value| guide_text?(value) }
            overview_text.concat(values)
          else
            errors << "#{path}: overview '#{field}' entries must be non-empty text"
          end
        end

        sections = overview["sections"]
        section_range = guide_kind == "index" ? READING_GUIDE_INDEX_SECTION_RANGE : READING_GUIDE_SUMMARY_SECTION_RANGE
        validate_guide_list_size(
          sections,
          section_range,
          "overview sections",
          path,
          errors
        )
        if sections.is_a?(Array)
          sections.each_with_index do |section, index|
            unless section.is_a?(Hash)
              errors << "#{path}: overview section #{index + 1} must contain title and paragraphs"
              next
            end

            title = section["title"]
            if guide_text?(title)
              overview_text << title
            else
              errors << "#{path}: overview section #{index + 1} requires non-empty 'title'"
            end
            if guide_text?(section["source_heading"])
              referenced_headings << section["source_heading"]
            else
              errors << "#{path}: overview section #{index + 1} requires non-empty 'source_heading'"
            end

            paragraphs = section["paragraphs"]
            paragraph_range = guide_kind == "index" ? READING_GUIDE_INDEX_PARAGRAPH_RANGE : READING_GUIDE_SUMMARY_PARAGRAPH_RANGE
            validate_guide_list_size(
              paragraphs,
              paragraph_range,
              "overview section #{index + 1} paragraphs",
              path,
              errors
            )
            if paragraphs.is_a?(Array) && paragraphs.all? { |paragraph| guide_text?(paragraph) }
              overview_text.concat(paragraphs)
            elsif paragraphs.is_a?(Array)
              errors << "#{path}: overview section #{index + 1} paragraphs must be non-empty text"
            end
          end
        end

        if overview_text.any? { |text| reading_guide_technical_text?(text) }
          errors << "#{path}: overview must not contain code or math"
        end

        check_intro = guide["check_intro"]
        errors << "#{path}: 'check_intro' must be non-empty text" unless guide_text?(check_intro)
        check_text = guide_text?(check_intro) ? [check_intro] : []
        checks = guide["checks"]
        check_range = guide_kind == "index" ? READING_GUIDE_INDEX_CHECK_RANGE : READING_GUIDE_CHECK_RANGE
        validate_guide_list_size(checks, check_range, "checks", path, errors)
        next unless checks.is_a?(Array)

        questions = []
        checks.each_with_index do |check, index|
          unless check.is_a?(Hash)
            errors << "#{path}: check #{index + 1} must be a YAML object"
            next
          end
          %w[level question answer].each do |field|
            value = check[field]
            if guide_text?(value)
              check_text << value
            else
              errors << "#{path}: check #{index + 1} requires non-empty '#{field}'"
            end
          end
          if guide_text?(check["source_heading"])
            referenced_headings << check["source_heading"]
          else
            errors << "#{path}: check #{index + 1} requires non-empty 'source_heading'"
          end
          if check.key?("hint")
            if guide_text?(check["hint"])
              check_text << check["hint"]
            else
              errors << "#{path}: check #{index + 1} hint must be non-empty text when present"
            end
          end
          questions << check["question"] if guide_text?(check["question"])
        end
        errors << "#{path}: check questions must be unique" unless questions.uniq.size == questions.size
        if check_text.any? { |text| reading_guide_technical_text?(text) }
          errors << "#{path}: checks must not contain code or math"
        end
        missing_headings = referenced_headings.uniq - source_headings
        unless missing_headings.empty?
          errors << "#{path}: source headings do not exist in the post: #{missing_headings.join(', ')}"
        end
      end
    end

    def validate_guide_list_size(value, range, label, path, errors)
      return if value.is_a?(Array) && range.cover?(value.size)

      errors << "#{path}: #{label} must contain #{range.begin} to #{range.end} entries"
    end

    def guide_text?(value)
      value.is_a?(String) && !value.strip.empty?
    end

    def reading_guide_technical_text?(text)
      text.include?("`") || text.match?(INLINE_MATH) || text.match?(DISPLAY_MATH) ||
        text.match?(READING_GUIDE_RESIDUAL_TEX)
    end

    def reading_guide_source_headings(content)
      html = Kramdown::Document.new(content, input: "GFM").to_html
      headings = Nokogiri::HTML.fragment(html).css("h2, h3, h4").map do |heading|
        heading.text
          .gsub(/[[:space:]]+/, " ")
          .gsub(/(?<=[\u3400-\u9FFF\uF900-\uFAFF]) (?=[\u3400-\u9FFF\uF900-\uFAFF])/, "")
          .gsub(/ (?=[，。！？；：])/, "")
          .strip
      end
      ["导言", *headings]
    end

    def validate_featured(post, errors)
      return unless post.data["featured"] == true
      return unless blank?(post.data["why_start_here"])

      errors << "#{post.relative_path}: featured content requires 'why_start_here'"
    end

    def validate_podcast(post, registry, seen_episodes, errors)
      return unless post.data["type"] == "podcast"

      PODCAST_REQUIRED_FIELDS.each do |field|
        errors << "#{post.relative_path}: missing '#{field}'" if blank?(post.data[field])
      end

      show = post.data["podcast_show"]
      unless blank?(show) || registry.key?(show)
        errors << "#{post.relative_path}: podcast show '#{show}' has no _data/podcast_shows.yml entry"
      end

      episode = post.data["episode_number"]
      unless episode.nil? || episode.is_a?(Integer) && episode.positive?
        errors << "#{post.relative_path}: 'episode_number' must be a positive integer"
      end

      duration = post.data["episode_duration_seconds"]
      unless duration.nil? || duration.is_a?(Numeric) && duration.positive?
        errors << "#{post.relative_path}: 'episode_duration_seconds' must be positive"
      end

      guests = post.data["guests"]
      unless guests.nil? || guests.is_a?(Array) && !guests.empty?
        errors << "#{post.relative_path}: 'guests' must be a non-empty YAML array"
      end

      source_url = post.data["source_url"]
      unless blank?(source_url) || valid_https_url?(source_url)
        errors << "#{post.relative_path}: 'source_url' must be a valid HTTPS URL"
      end

      key = [show, episode]
      return if blank?(show) || episode.nil?

      if seen_episodes.key?(key)
        errors << "#{post.relative_path}: duplicate episode #{episode} also used by #{seen_episodes[key]}"
      else
        seen_episodes[key] = post.relative_path
      end
    end

    def valid_https_url?(value)
      uri = URI.parse(value.to_s)
      uri.is_a?(URI::HTTPS) && !blank?(uri.host)
    rescue URI::InvalidURIError
      false
    end
  end
end
