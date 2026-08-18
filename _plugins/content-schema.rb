# frozen_string_literal: true

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
    UNSAFE_STAR_SUPERSCRIPT = /\^\*/.freeze
    UNSAFE_ABSOLUTE_VALUE = /(?<!\$)\$(?!\$)\|[^$\n]+\|\$(?!\$)/.freeze
    UNSAFE_INLINE_DELIMITER = /\\\(|\\\)/.freeze
    UNSAFE_DISPLAY_DELIMITER = /^\s*\\[\[\]]\s*$/.freeze
    CORRUPTED_TEX_COMMAND = /\t(?:heta|ext|au|imes|op|ilde|o|anh|riangle|ag)(?=[^A-Za-z]|$)/.freeze
    MISSING_TEX_BACKSLASH = /^\s+(?:heta|ext)(?=[_{(])/.freeze

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
