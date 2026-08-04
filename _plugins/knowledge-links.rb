# frozen_string_literal: true

module Garden
  class KnowledgeLinksGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      posts = site.posts.docs
      posts_by_uid = posts.to_h { |post| [post.data["uid"], post] }
      backlink_sources = Hash.new { |hash, key| hash[key] = [] }
      errors = []

      posts.each do |post|
        related_uids = post.data["related"] || []
        unless related_uids.is_a?(Array)
          errors << "#{post.relative_path}: 'related' must be a YAML array"
          next
        end

        seen_related_uids = {}
        post.data["garden_related"] = related_uids.filter_map do |uid|
          unless uid.is_a?(String)
            errors << "#{post.relative_path}: related values must be UID strings"
            next
          end

          if uid == post.data["uid"]
            errors << "#{post.relative_path}: cannot relate to its own uid '#{uid}'"
            next
          end

          if seen_related_uids.key?(uid)
            errors << "#{post.relative_path}: duplicate related uid '#{uid}'"
            next
          end
          seen_related_uids[uid] = true

          target = posts_by_uid[uid]
          if target.nil?
            errors << "#{post.relative_path}: related uid '#{uid}' does not exist"
            next
          end

          backlink_sources[uid] << post
          reference_for(target)
        end

        validate_references(post, errors)
      end

      posts.each do |post|
        post.data["garden_backlinks"] = backlink_sources[post.data["uid"]].map do |source|
          reference_for(source)
        end
      end

      build_series_navigation(posts, errors)

      return if errors.empty?

      raise Jekyll::Errors::FatalException,
            "Garden knowledge link validation failed:\n- #{errors.join("\n- ")}"
    end

    private

    def build_series_navigation(posts, errors)
      posts.group_by { |post| post.data["series"] }.each do |series, series_posts|
        next if series.nil?

        explicit_orders = series_posts.filter_map { |post| post.data["series_order"] }
        duplicate_orders = explicit_orders.tally.select { |_, count| count > 1 }.keys
        duplicate_orders.each do |order|
          errors << "series '#{series}' uses duplicate series_order #{order}"
        end

        ordered_posts = if explicit_orders.size == series_posts.size
                          series_posts.sort_by { |post| post.data["series_order"] }
                        else
                          series_posts.sort_by(&:date)
                        end

        ordered_posts.each_with_index do |post, index|
          post.data["garden_series_position"] = index + 1
          post.data["garden_series_size"] = ordered_posts.size
          post.data["garden_series_previous"] = reference_for(ordered_posts[index - 1]) if index.positive?
          next_post = ordered_posts[index + 1]
          post.data["garden_series_next"] = reference_for(next_post) unless next_post.nil?
        end
      end
    end

    def reference_for(post)
      {
        "uid" => post.data["uid"],
        "title" => post.data["title"],
        "url" => post.url,
        "type" => post.data["type"],
        "status" => post.data["status"],
        "description" => post.data["description"]
      }
    end

    def validate_references(post, errors)
      references = post.data["references"]
      return if references.nil?

      unless references.is_a?(Array)
        errors << "#{post.relative_path}: 'references' must be a YAML array"
        return
      end

      references.each_with_index do |reference, index|
        unless reference.is_a?(Hash) && present?(reference["title"]) && present?(reference["url"])
          errors << "#{post.relative_path}: reference #{index + 1} requires 'title' and 'url'"
        end
      end
    end

    def present?(value)
      !value.nil? && (!value.respond_to?(:empty?) || !value.empty?)
    end
  end
end
