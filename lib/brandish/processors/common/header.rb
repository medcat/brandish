# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module Common
      # A processor that defines the `header` command.  This creates a list
      # internally of all of the headers in the document, to later be used to
      # possibly create a table of contents, if needed.
      #
      # @abstract
      class Header < Processor::Command
        self.name = :header

        # (see Processor::Command#initialize)
        def initialize(context, options)
          super
          @context[:headers] = []
        end

        # Handles the header.  This stores the {#header_data} in the context
        # `:headers` key, and then calls {#header_render}.
        #
        # @param _node [Parser::Node::Command] The node.  Unused.
        # @return [Parser::Node::Text] The resulting header text.
        def perform(_node)
          @context[:headers] << header_data
          header_render
        end

        # Renders the header for the format.  This should be implemented by the
        # implementing format.
        #
        # @abstract
        # @return [Parser::Node::Text] The resulting header text.
        def header_render
          fail NotImplementedError.new("Please implement #{self.class}#header_render")
        end

        # The header data used for the internal `:headers` structure.
        #
        # @return [{::Symbol => ::Object}]
        def header_data
          { level: header_level, value: header_value, id: header_id }
        end

        # The header level.  This is an integer between 1 and 6.
        #
        # @return [Numeric]
        def header_level
          @options.fetch("level", "1").to_i
        end

        # The "value" of the header.  This is the contents or the name of the
        # header.  This is required.
        #
        # @return [::String]
        def header_value
          @options.fetch("value")
        end

        # The "id" of the header.  This should be a unique value between all
        # headers that specifies this exact header.
        #
        # @return [::String]
        def header_id
          @options.fetch("id") { header_value.downcase.gsub(/[^\w]|\_/, "-") }
        end
      end
    end
  end
end
