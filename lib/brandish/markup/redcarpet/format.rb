# encoding: utf-8
# frozen_string_literal: true

module Brnadish
  module Markup
    module Redcarpet
      class Format
        MARKDOWN_OPTIONS = %i[
          no_intra_emphasis tables fenced_code_blocks autolink
          disable_indented_code_blocks strikethrough lax_spacing
          space_after_headers superscript underline highlight
          quote footnotes
        ].freeze
        
        MARKDOWN_DEFAULTS = {}.freeze
        
        FORMAT_OPTIONS = %i[
          filter_html no_images no_links no_styles escape_html safe_links_only
          with_toc_data hard_wrap xhtml prettify link_attributes
          highlighter
        ].freeze
        
        FORMAT_DEFAULTS = {}.freeze
        
        HIGHLIGHTERS = {
          rouge: "rouge", coderay: "coderay", pygments: "pygments",
          none: nil
        }.freeze
        
        FORMATTERS = { html: :HTML }.freeze

        def initialize(options)
          @context = options.fetch(:context)
          @format = options.fetch(:format)
          @highlighter = options.fetch(:highlighter)
          @markdown_options = MARKDOWN_DEFAULTS
            .merge(extract_options(MARKDOWN_OPTIONS, options))
          @formatter_options = FORMAT_DEFAULTS
            .merge(extract_options(FORMAT_OPTIONS, options))
            .merge(highlighter: @highlighter, context: @context)
          load_highlighter
          load_engine
        end
        
        def render(string)
          @engine.render(string)
        end

      private

        def load_highlighter
          file = HIGHLIGHTERS.fetch(@highlighter)
          require file
        rescue ::KeyError
          fail ProcessorError.new("Unknown highlighter `#{@highlighter}`")
        end

        def load_engine
          formatter = FORMATTERS.fetch(@format)
          renderer_class = Brandish::Markup::Redcarpet.const_get(formatter)
          renderer = renderer_class.new(@formatter_options)
          @engine = Redcarpet::Markdown.new(renderer, @markdown_options)
        rescue ::KeyError
          fail ProcessorError.new("Unsupported format `#{@format}`")
        end

        def extract_options(keys, options)
          keys.zip(options.values_at(keys)).select!(&:last).to_h
        end
      end
    end
  end
end