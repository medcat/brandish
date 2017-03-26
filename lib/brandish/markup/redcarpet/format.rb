# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Markup
    module Redcarpet
      # Formats text with Redcarpet.  This is extracted into a seperate object
      # in order to provide highlighting properties.  This is
      # format-independant.
      #
      # This class can take the following options:
      #
      # - All Markdown extension options that are listed on
      #   <https://github.com/vmg/redcarpet>, e.g. `:no_intra_emphasis`,
      #   `:tables`, etc.
      # - All HTML formatter options that are listed on
      #   <https://github.com/vmg/redcarpet>, e.g. `:filter_html`,
      #   `:no_images`, etc.
      # - `:highlight` - Optional.  The highlighting engine to use.  Can be
      #   one of `:rouge`, `:coderay`, `:pygments`, and `:none`.  Remember to
      #   include the requisite highlighting engine in your Gemfile.  They
      #   will automatically be required as needed.  Defaults to `:none`.
      class Format
        # The options that are passed over to the markdown engine.  These
        # are extracted from the options that are passed to the markup engine.
        #
        # @return [<::Symbol>]
        MARKDOWN_OPTIONS = %i(
          no_intra_emphasis tables fenced_code_blocks autolink
          disable_indented_code_blocks strikethrough lax_spacing
          space_after_headers superscript underline quote footnotes
        ).freeze

        # The default options for the markdown engine as passed by this markup
        # engine.
        #
        # @return [{::Symbol => ::Object}]
        MARKDOWN_DEFAULTS = {
          fenced_code_blocks: true, tables: true, autolink: true,
          strikethrough: true, superscript: true, underline: true,
          footnotes: true, space_after_headers: true
        }.freeze

        # The options that are passed over to the formatting engine.  These are
        # Extracted from the options that are passed to the markup engine.
        #
        # @return [<::Symbol>]
        FORMAT_OPTIONS = %i(
          filter_html no_images no_links no_styles escape_html safe_links_only
          with_toc_data hard_wrap xhtml prettify link_attributes highlight
        ).freeze

        # The default options for the formatting engine as passed by this
        # markup engine.
        #
        # @return [{::Symbol => ::Object}]
        FORMAT_DEFAULTS = { highlight: :none }.freeze

        # The highlighting engines that are supported by this markup engine.
        # The key is the value passed by the `:highlight` option, and the value
        # is the require file name.  If the value is `nil`, no requirement
        # is performed.
        #
        # @return [{::Symbol => ::Object, nil}]
        HIGHLIGHTERS = {
          rouge: "rouge", coderay: "coderay", pygments: "pygments",
          none: nil
        }.freeze

        # The formating engines that can be used by this markup engine.
        #
        # @return [{::Symbol => ::Class}]
        FORMATTERS = { html: HTML }.freeze

        # Initialize the markup engine for Redcarpet.  For the available
        # options, see {Format}.
        #
        # @param options [::Hash]
        def initialize(options)
          @context = options.fetch(:context)
          @format = options.fetch(:format)
          @markdown_options = MARKDOWN_DEFAULTS
                              .merge(extract_options(MARKDOWN_OPTIONS, options))
          @formatter_options = FORMAT_DEFAULTS
                               .merge(extract_options(FORMAT_OPTIONS, options))
          @highlight = @formatter_options[:highlight]
          load_highlighter
          load_engine
        end

        # Renders the given text using the engine.
        #
        # @param string [::String] The value to render.
        # @return [::String] The rendered value.
        def render(string)
          @engine.render(string)
        end

      private

        def load_highlighter
          file = HIGHLIGHTERS.fetch(@highlight)
          require file if file
        rescue ::KeyError
          fail ProcessorError, "Unknown highlighter `#{@highlight}`"
        end

        def load_engine
          begin
            formatter = FORMATTERS.fetch(@format)
          rescue ::KeyError
            fail ProcessorError, "Unsupported format `#{@format}`"
          end

          renderer = formatter.new(@context, @formatter_options)
          @engine = ::Redcarpet::Markdown.new(renderer, @markdown_options)
        end

        def extract_options(keys, options)
          keys.zip(options.values_at(*keys)).select!(&:last).to_h
        end
      end
    end
  end
end
