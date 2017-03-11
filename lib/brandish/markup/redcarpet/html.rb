# encoding: utf-8
# frozen_string_literal: true

module Brandish
	module Markup
		module Redcarpet
			class HTML < ::Redcarpet::Renderer::SmartyHTML
				include Hanami::Helpers::HtmlHelper

				TAGS = %i[h1 h2 h3 h4 h5 h6].freeze

				def initialize(context, options)
					@context = context
					@highlighter = options.fetch(:highlighter)
					super(options)
				end

				def header(text, level)
					id = (match = text =~ /#(.+)\z/) ? match[1] : text.downcase.gsub(/[\W]/, "-")
					html.tag(TAGS.fetch(level), text, id: id)
				end

				def block_code(code, language)
					case @highlighter
					when :rouge then rouge_highlight_code(code, language)
					when :coderay then coderay_highlight_code(code, language)
					when :pygments then pygments_highlight_code(code, language)
					when :none
						html.pre { html.code(code, class: "language-#{language}") }
					end
				rescue
					html.pre { html.code(code, class: "langauge-#{language} failed") }
				end

			private

				def rouge_highlight_code(code, language)
					Rouge.highlight(code, language, "html")
				end

				def coderay_highlight_code(code, langauge)
					CodeRay.scan(code, langauge.intern).div
				end

				def pygments_highlight_code(code, language)
					Pygments.highlight(code, lexer: language.intern)
				end
			end
		end
	end
end