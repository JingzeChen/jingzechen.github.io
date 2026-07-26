# frozen_string_literal: true

module Garden
  class ContentSchemaGenerator < Jekyll::Generator
    safe true
    priority :highest

    REQUIRED_FIELDS = %w[uid type status topics description].freeze

    def generate(site)
      content_types = site.config.dig("garden", "content_types") || []
      statuses = site.config.dig("garden", "statuses") || []
      seen_uids = {}
      errors = []

      site.posts.docs.each do |post|
        REQUIRED_FIELDS.each do |field|
          errors << "#{post.relative_path}: missing '#{field}'" if blank?(post.data[field])
        end

        validate_value(post, "type", content_types, errors)
        validate_value(post, "status", statuses, errors)
        validate_topics(post, errors)

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

    def validate_topics(post, errors)
      topics = post.data["topics"]
      return if blank?(topics) || topics.is_a?(Array)

      errors << "#{post.relative_path}: 'topics' must be a YAML array"
    end
  end
end
