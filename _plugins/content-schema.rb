# frozen_string_literal: true

module Garden
  class ContentSchemaGenerator < Jekyll::Generator
    safe true
    priority :highest

    REQUIRED_FIELDS = %w[uid type status topics description content_lang].freeze
    TEMPLATE_DESCRIPTION = /梳理核心概念、论证结构、适用边\s*界与实践要点/.freeze

    def generate(site)
      content_types = site.config.dig("garden", "content_types") || []
      statuses = site.config.dig("garden", "statuses") || []
      content_languages = site.config.dig("garden", "content_languages") || []
      hidden_topics = site.config.dig("garden", "hidden_topics") || []
      series_registry = site.data["series"] || {}
      seen_uids = {}
      errors = []

      site.posts.docs.each do |post|
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

      featured_count = site.posts.docs.count { |post| post.data["featured"] == true }
      unless featured_count.between?(2, 5)
        errors << "featured content count must be between 2 and 5 (found #{featured_count})"
      end

      series_registry.each do |slug, metadata|
        %w[title description url topics].each do |field|
          errors << "series '#{slug}' requires '#{field}'" if blank?(metadata[field])
        end
      end

      return if errors.empty?

      raise Jekyll::Errors::FatalException,
            "Garden content schema validation failed:\n- #{errors.join("\n- ")}"
    end

    private

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

    def validate_featured(post, errors)
      return unless post.data["featured"] == true
      return unless blank?(post.data["why_start_here"])

      errors << "#{post.relative_path}: featured content requires 'why_start_here'"
    end
  end
end
