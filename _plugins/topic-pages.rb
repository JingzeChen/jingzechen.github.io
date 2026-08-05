# frozen_string_literal: true

module Garden
  class TopicPagesGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      topics = site.data["topics"] || {}
      hidden_topics = site.config.dig("garden", "hidden_topics") || []
      posts_by_uid = site.posts.docs.to_h { |post| [post.data["uid"], post] }
      errors = []

      site.posts.docs.each do |post|
        Array(post.data["topics"]).each do |topic|
          next if hidden_topics.include?(topic) || topics.key?(topic)

          errors << "#{post.relative_path}: topic '#{topic}' has no _data/topics.yml entry"
        end
      end

      topics.each do |slug, metadata|
        validate_topic(slug, metadata, topics, posts_by_uid, errors)
        site.pages << build_page(site, slug, metadata)
      end

      return if errors.empty?

      raise Jekyll::Errors::FatalException,
            "Garden topic validation failed:\n- #{errors.join("\n- ")}"
    end

    private

    def validate_topic(slug, metadata, topics, posts_by_uid, errors)
      errors << "topic '#{slug}' requires a title" if blank?(metadata["title"])
      errors << "topic '#{slug}' requires a description" if blank?(metadata["description"])

      Array(metadata["related"]).each do |related|
        errors << "topic '#{slug}' references unknown related topic '#{related}'" unless topics.key?(related)
        errors << "topic '#{slug}' cannot relate to itself" if related == slug
      end

      Array(metadata["start_here"]).each do |uid|
        post = posts_by_uid[uid]
        if post.nil?
          errors << "topic '#{slug}' references unknown start_here uid '#{uid}'"
        elsif !Array(post.data["topics"]).include?(slug)
          errors << "topic '#{slug}' start_here uid '#{uid}' does not belong to the topic"
        end
      end
    end

    def build_page(site, slug, metadata)
      page = Jekyll::PageWithoutAFile.new(site, site.source, File.join("topics", slug), "index.html")
      page.data = {
        "layout" => "topic",
        "title" => metadata["title"],
        "description" => metadata["description"],
        "topic_slug" => slug,
        "permalink" => "/topics/#{slug}/"
      }
      page
    end

    def blank?(value)
      value.nil? || value.respond_to?(:empty?) && value.empty?
    end
  end
end