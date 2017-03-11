# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/escape_helper"

module Brandish
  module Processors
    module HTML
      # Markup support for the HTML format.  For more information, and available
      # options, see the {Processors::Common::Markup} processor.
      #
      # This markup processor provides the following engines:
      #
      # - `:kramdown` - A Markdown formatter.  More information on this
      #   markup format can be found at <https://github.com/gettalong/kramdown>.
      #   Available options are: `:template`, `:auto_ids` (not recommended),
      #   `:auto_id_stripping` (not recommended), `:auto_id_prefix` (not
      #   recommended), `:parse_block_html`, `:parse_span_html`,
      #   `:html_to_native`, `:link_defs`, `:footnote_nr`, `:enable_coderay`,
      #   `:coderay_wrap`, `:coderay_line_numbers`,
      #   `:coderay_line_number_start`, `:coderay_tab_width`,
      #   `:coderay_bold_every`, `:coderay_css`, `:coderay_default_lang`,
      #   `:entity_output`, `:toc_levels` (not recommended), `:line_width`,
      #   `:latex_headers` (does nothing), `:smart_quotes`,
      #   `:remove_block_html_tags`, `:remove_span_html_tags`,
      #   `:header_offset`, `:hard_wrap`, `:syntax_highlighter`,
      #   `:syntax_highlighter_opts`, `:math_engine`, `:math_engine_opts`,
      #   `:footnote_backlink`, and `:gfm_quirks`.  Requires the kramdown
      #   gem.
      # - `:rdiscount` - A Markdown formatter.  More information on this
      #   markup format can be found at <https://github.com/davidfstr/rdiscount>.
      #   The options for this engine are specified in an array, not a
      #   hash.  Available options are: `:smart`, `:filter_styles`,
      #   `:filter_html`, `:fold_lines`, `:footnotes`, `:generate_toc` (not
      #   recommended), `:no_image`, `:no_links`, `:no_tables`, `:strict`,
      #   `:autolink`, `:safelink`, `:no_pseudo_protocals`, `:no_superscript`,
      #   and `:no_strikethrough`.  Requires the rdiscount gem.
      # - `:minidown` - A Markdown formatter.  More information on this
      #   markup format can be found at <https://github.com/jjyr/minidown>.
      #   Available options are: `:code_block_handler`.
      # - `:redcloth` - A Textile formatter.  More information on this
      #   markup format can be found at <https://github.com/jgarber/redcloth>.
      #   Available options are: `:filter_html`, `:sanitize_html`,
      #   `:filter_styles`, `:filter_classes`, `:filter_ids`,
      #   `:hard_breaks` (deprecated, default), `:lite_mode`,
      #   and `:no_span_caps`.
      # - `:creole` - A creole formatter.  More information on this markup
      #   format can be found at <https://github.com/larsch/creole>.
      #   Available options are: `:allowed_schemes`, `:extensions`,
      #   and `:no_escape`.
      # - `:sanitize` - A sanitizer, to remove non-whitelisted elements.
      #   More information on this can be found at <https://github.com/rgrove/sanitize>.
      #   The option can be a symbol or a hash; the hash is passed directly
      #   to sanitize.  The symbol is mapped to one of the corresponding
      #   default configs.  Symbol values are: `:restricted`, `:basic`,
      #   `:relaxed`, and `:basic`.
      # - `:escape` - Escapes the content to prevent conflict with the
      #   resulting format.
      # @note
      #   This class provides the `html:markup` processor.
      class Markup < Processors::Common::Markup
        include Hanami::Helpers::EscapeHelper
        register %i(html markup) => self

        engine(:kramdown, {}, :initialize_kramdown, :markup_kramdown)
        engine(:rdiscount, [:smart], :initialize_rdiscount, :markup_rdiscount)
        engine(:minidown, {}, :initialize_minidown, :markup_minidown)
        engine(:redcloth, [], :initialize_redcloth, :markup_redcloth)
        engine(:redcarpet, {}, :initialize_redcarpet, :markup_redcarpet)
        engine(:creole, { extensions: true }, :initialize_creole, :markup_creole)
        engine(:sanitize, :relaxed, :initialize_sanitize, :markup_sanitize)
        engine(:escape, nil, nil, :markup_escape)

      private

        def initialize_kramdown
          require "kramdown"
        end

        def markup_kramdown(value, options)
          Kramdown::Document.new(value, options).to_html
        end

        def initialize_rdiscount
          require "rdiscount"
        end

        def markup_rdiscount(value, options)
          RDiscount.new(value, *options).to_html
        end

        def initialize_minidown
          require "minidown"
          @parser = Minidown::Parser.new(engine_options)
        end

        def markup_minidown(value, _)
          @parser.render(value)
        end

        def initialize_redcloth
          require "redcloth"
        end

        def markup_redcloth(value, options)
          RedCloth.new(value, options).to_html
        end

        def initialize_redcarpet
          require "redcarpet"
          @format = Markup::Redcarpet::Format.new(@context, engine_options)
        end

        def markup_redcarpet(value, _options)
          @format.render(value)
        end

        def initialize_creole
          require "creole"
        end

        def markup_creole(value, options)
          Creole::Parser.new(value, options).to_html
        end

        def initialize_sanitize
          require "sanitize"
          @options = Sanitize::Config.const_get(engine_options.to_s.upcase) if
            engine_options.is_a?(::Symbol)
        end

        def markup_sanitize(value, options)
          Sanitize.fragment(value, options)
        end

        def markup_escape(value, _options)
          h(value)
        end
      end
    end
  end
end
