# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Common::Asset
        # A Style engine for highlighting libraries.  This supports
        # Rouge and Pygments.
        #
        # Engines:
        #
        # - `"highlight-rouge"`, `"highlight-rouge-file"` - A command.
        #   Retrieves the given theme from the Rouge library, and outputs it
        #   to the `"output"` pair (or `"highlight/rouge/<theme>.css"` by
        #   default).
        # - `"highlight-pygments", `"highlight-pygments-file"` - A command.
        #   Retrieves the given theme from the Pygments library, and outputs
        #   it to the `"output"` pair (or `"highlight/pygments/<theme>.css"`
        #   by default).
        # - `"highlight-rouge-inline"` - A command.  Retrieves the given theme
        #   from the Rouge library, and uses it like an inline style.
        # - `"highlight-pygments-inline"` - A command.  Retrieves the given
        #   theme from the pygments library, and uses it like an inline
        #   style.
        #
        # @note
        #   The libraries that these engines depend on are not required in
        #   by default; if any of these engines are used, the requisite 
        #   libraries would have to be required by the `brandish.config.rb`
        #   file.
        module Highlight
          Style.engine "highlight-rouge", :command, :style_highlight_rouge
          Style.engine "highlight-pygments", :command, :style_highlight_pygments
          Style.engine "highlight-rouge-file", :command, :style_highlight_rouge
          Style.engine "highlight-pygments-file", :command, :style_highlight_pygments
          Style.engine "highlight-rouge-inline", :command, :style_highlight_rouge_inline
          Style.engine "highlight-pygments-inline", :command, :style_highlight_pygments_inline
          Style.pair :theme, :scope, :output

        private

          def highlight_theme
            @pairs.fetch("theme")
          end

          def highlight_rouge_value
            scope = @pairs.fetch("scope", ".highlight")
            options = { scope: scope }
            ::Rouge::Theme.find(highlight_theme).render(options)
          end

          def highlight_pygments_value
            scope = @pairs.fetch("scope", ".highlight")
            ::Pygments.css(scope, style: highlight_theme)
          end

          def style_highlight_rouge
            file = @pairs.fetch("output", "highlight/rouge/#{highlight_theme}.css")
            output_path = output_assets_path / file
            output_path.dirname.mkpath
            link_path = output_path.relative_path_from(@context.configure.output)
            output_path.write(highlight_rouge_value)

            @context[:document].add_linked_style(link_path)
          end

          def style_highlight_pygments
            file = @pairs.fetch("output", "highlight/pygments/#{highlight_theme}.css")
            output_path = output_assets_path / file
            output_path.dirname.mkpath
            link_path = output_path.relative_path_from(@context.configure.output)
            output_path.write(highlight_pygments_value)

            @context[:document].add_linked_style(link_path)
          end

          def style_highlight_rouge_inline
            @context[:document].add_inline_style(highlight_rouge_value)
          end

          def style_highlight_pygments_inline
            @context[:document].add_inline_style(highlight_pygments_value)
          end
        end
      end
    end
  end
end
