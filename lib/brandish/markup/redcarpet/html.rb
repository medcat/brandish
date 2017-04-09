# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Markup
    module Redcarpet
      # An HTML renderer for redcarpet.  This provides integrations with
      # Brandish, as well as code highlighting.
      class HTML < ::Redcarpet::Render::SmartyHTML
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper

        # Initialize the renderer with the given context and options.
        #
        # @param context [Processor::Context]
        # @param options [{::Symbol => ::Object}]
        # @option options [::Symbol] :highlight (:none) Which highlighter to
        #   use.  Possible values are `:rouge`, `:coderay`, `:pygments`, and
        #   `:none`.
        def initialize(context, options)
          @context = context
          @highlighter = options.fetch(:highlight)
          super(options)
        end

        # Creates a header with the given text and level.  If the text ends in
        # `/#([\w-]+)/`, that is removed, and used as the ID for the header;
        # otherwise, it is automagically assumed from the text.
        #
        # @param text [::String]
        # @param level [::Numeric]
        # @return [::String]
        def header(text, level)
          text, id = split_text(text)

          @context[:headers] << { id: id, level: level.to_i, value: text }.freeze
          html.tag(Processors::HTML::Header::TAGS.fetch(level), raw(text),
            id: id).to_s
        end

        # Highlights a block of code.
        #
        # @param code [::String] The code to highlight
        # @param language [::String, nil] The language that the code was in,
        #   or nil if it was not or could not be provided.
        # @return [::String]
        def block_code(code, language)
          basic_language = language || "unknown"
          case @highlighter
          when :rouge then rouge_highlight_code(code, language)
          when :coderay then coderay_highlight_code(code, language)
          when :pygments then pygments_highlight_code(code, language)
          when :none
            html.pre { html.code(code, class: "language-#{basic_language}") }
          end.to_s
        end

      private

        def split_text(text)
          # So we don't match entity tags by accident (`&#00;`).
          if (match = text.match(/\A(.*)(?<!&)#([\w-]+)\s*\z/))
            [match[1], match[2]]
          else
            # Remove entity tags, they're not needed.
            [text, text.downcase.gsub(/&(.+?);/, "").gsub(/\W+/, "-")]
          end
        end

        def rouge_highlight_code(code, language)
          lexer = (language && Rouge::Lexer.find_fancy(language, code)) ||
                  Rouge::Lexers::PlainText
          attributes = { class: "highlight language-#{lexer.tag}" }
          html.pre do
            code(raw(::Rouge.highlight(code, lexer, "html")), attributes)
          end
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
