# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module Latex
      # Markup support for the Latex format.  For more information, and
      # available options, see the {Processors::Common::Markup} processor.
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
      # - `:redcloth` - A Textile formatter.  More information on this
      #   markup format can be found at <https://github.com/jgarber/redcloth>.
      #   Available options are: `:filter_html`, `:sanitize_html`,
      #   `:filter_styles`, `:filter_classes`, `:filter_ids`,
      #   `:hard_breaks` (deprecated, default), `:lite_mode`,
      #   and `:no_span_caps`.
      # - `:escape` - Escapes the content to prevent conflict with the
      #   resulting format.
      # @note
      #   This class provides the `latex:markup` processor.
      class Markup < Processors::Common::Markup
        register %i(latex markup) => self

        engine(:kramdown, {}, :initialize_kramdown, :markup_kramdown)
        engine(:redcloth, [], :initialize_redcloth, :markup_redcloth)
        engine(:escape, nil, nil, :markup_escape)
      end
    end
  end
end
