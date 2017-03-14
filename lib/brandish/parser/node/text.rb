# encoding: utf-8
# frozen_string_literal: true

require "set"

module Brandish
  class Parser
    class Node
      # A text node.  This contains only text, and has no  other node
      # decendants.  This node automatically merges the contents of the text
      # into a single value, and places it in the `value` attribute.
      class Text < Node
        # A set of tokens kinds that are allowed to be in a text node.
        #
        # @return [Set<::Symbol>]
        TOKENS =
          Set[:SPACE, :TEXT, :LINE, :NUMERIC, :ESCAPE, :'"', :"=", :"/"].freeze

        # The value of the text node.  This is the string value of the source
        # text that this node is based off of.
        #
        # @return [::String]
        attr_reader :value

        # Initialize the node.
        #
        # @overload initialize(tokens:, location: nil)
        #   Initialize the text node with the given series of tokens.  The
        #   location can be either provided, or assumed from the locations of
        #   the tokens.  The tokens are concatenated into a single string,
        #   and used to provide the text.
        #
        #   @param tokens [<Scanner::Token>] The tokens that make up
        #     this text node.
        #   @param location [Location] The location of the text node.  If none
        #     is provided, it is assumed from the tokens.
        # @overload initialize(value:, location:)
        #   Initialize the text node with the given value.  The location must
        #   be provided.
        #
        #   @param value [::String] The value of the text node.
        #   @param location [Location] The location of the text node.
        def initialize(tokens: nil, value: nil, location: nil)
          unless tokens || (value && location)
            fail ArgumentError, "Expected either a set of tokens or a " \
              "value and a location, got neither"
          end

          @value = value || derive_value(tokens)
          @location = location || derive_location(tokens)
          freeze
        end

        # Pretty inspect.
        #
        # @return [::String]
        def inspect
          "#<#{self.class} value=#{@value.inspect} " \
            "location=#{@location.inspect}>"
        end

        # Determines if this object equals another object.  If the other object
        # is this object, it returns true; otherwise, if the other object is a
        # {Text}, and all of the properties are equal, it returns true;
        # otherwise, it returns false.
        #
        # @param other [::Object]
        # @return [Boolean]
        def ==(other)
          equal?(other) || other.is_a?(self.class) && @value == other.value &&
            @location == other.location
        end

      private

        def update_value(value)
          Text.new(value: value, location: @location)
        end

        def update_tokens(tokens)
          update_value(derive_value(tokens))
        end

        def update_location(location)
          Text.new(value: @value, location: location)
        end

        def derive_location(tokens)
          unless tokens
            fail ArgumentError, "Expected either location or tokens, got" \
              " neither"
          end

          tokens.map(&:location).inject(:union)
        end

        def derive_value(tokens)
          assert_valid_tokens(tokens)
          tokens
            .map { |t| t.kind == :ESCAPE ? t.value[-1] : t.value }
            .join
            .freeze
        end

        def assert_valid_tokens(tokens)
          valid = tokens.all? { |t| TOKENS.include?(t.kind) }
          return valid if valid
          fail ArgumentError, "Expected tokens to all be one of " \
            "#{TOKENS.map(&:inspect).join(', ')}"
        end
      end
    end
  end
end
