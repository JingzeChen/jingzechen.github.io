# frozen_string_literal: true

require "kramdown"

module Garden
  class SearchContentGenerator < Jekyll::Generator
    safe true
    priority :low

    EXCLUDED_TYPES = %i[codeblock codespan table html_element xml_comment img].freeze
    MAX_EXCERPT_LENGTH = 220
    MAX_SEARCH_TEXT_LENGTH = 12_000

    def generate(site)
      site.posts.docs.each do |post|
        root = Kramdown::Document.new(post.content, input: "GFM").root
        body_text = normalize(extract_text(root))
        excerpt_source = if post.data["garden_description_valid"]
                           post.data["description"]
                         else
                           first_paragraph(root) || body_text
                         end

        post.data["garden_search_excerpt"] = truncate(normalize(excerpt_source), MAX_EXCERPT_LENGTH)
        post.data["garden_search_text"] = truncate(body_text, MAX_SEARCH_TEXT_LENGTH)
      end
    end

    private

    def extract_text(element)
      return "" if EXCLUDED_TYPES.include?(element.type)
      return element.value.to_s if element.type == :text

      element.children.map { |child| extract_text(child) }.join(" ")
    end

    def first_paragraph(element)
      if element.type == :p
        paragraph = normalize(extract_text(element))
        return paragraph unless paragraph.empty?
      end

      element.children.each do |child|
        paragraph = first_paragraph(child)
        return paragraph unless paragraph.nil?
      end

      nil
    end

    def normalize(value)
      value.to_s.gsub(/\s+/, " ").strip
    end

    def truncate(value, length)
      return value if value.length <= length

      "#{value[0, length - 1].rstrip}…"
    end
  end
end