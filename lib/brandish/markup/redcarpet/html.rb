# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Markup
    module Redcarpet
      class HTML < ::Redcarpet::Render::SmartyHTML
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper

        TAGS = %i(h1 h2 h3 h4 h5 h6).freeze

        def initialize(context, options)
          @context = context
          @highlighter = options.fetch(:highlight)
          super(options)
        end

        def header(text, level)
          id = (match = text =~ /#(.+)\z/) ? match[1] : text.downcase.gsub(/[\W]/, "-")
          html.tag(TAGS.fetch(level), text, id: id).to_s
        end

        def block_code(code, language)
          case @highlighter
          when :rouge then rouge_highlight_code(code, language)
          when :coderay then coderay_highlight_code(code, language)
          when :pygments then pygments_highlight_code(code, language)
          when :none
            html.pre { html.code(code, class: "language-#{language}") }.to_s
          end
        rescue => e
          $stderr.puts "!> Received error: #{e.class}: #{e.message}"
          html.pre { html.code(code, class: "langauge-#{language} failed") }.to_s
        end

      private

        def rouge_highlight_code(code, language)
          lexer = Rouge::Lexer.find_fancy(language, code) || Lexers::PlainText
          attributes = { class: "highlight language-#{lexer.tag}" }
          html.pre do
            code(raw(::Rouge.highlight(code, lexer, "html")), attributes)
          end.to_s
        end

        def coderay_highlight_code(code, langauge)
          CodeRay.scan(code, langauge.intern, css: :style).div
        end

        def pygments_highlight_code(code, language)
          Pygments.highlight(code, lexer: language.intern)
        end
      end
    end
  end
end
