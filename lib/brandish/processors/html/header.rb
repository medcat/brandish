# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"

module Brandish
  module Processors
    module HTML
      # A processor that defines the `header` command.  This creates a list
      # internally of all of the headers in the document, to later be used to
      # possibly create a table of contents, if needed.
      #
      # This takes no options.
      #
      # Pairs:
      #
      # - `"level"` - Optional.  Defaults to `1`.  The "level" of the header.
      #   This should be a value between 1 and 6.
      # - `"value"` - Required.  The name of the header.
      # - `"id"` - Optional.  The ID of the header.  This is a unique value
      #   to reference to this header.  If no value is given, it defaults
      #   to a modified `"value"`.
      # - `"class"` - Optional.  The class name of the header.
      class Header < Processors::Common::Header
        include Hanami::Helpers::HtmlHelper
        register %i(html header) => self
        pair :class

        # The tags to use for each header level.  This is just `h1` through
        # `h6`.
        #
        # @return [{::Numeric => ::Symbol}]
        TAGS = { 1 => :h1, 2 => :h2, 3 => :h3, 4 => :h4, 5 => :h5,
          6 => :h6 }.freeze

        # Renders the proper HTML tag for the header, including the proper
        # id, and an optional class value from the pairs.
        #
        # @return [::String]
        def header_render
          html.tag(TAGS.fetch(header_level), header_value, id: header_id,
            class: @pairs.fetch("class", "")).to_s
        end
      end
    end
  end
end
