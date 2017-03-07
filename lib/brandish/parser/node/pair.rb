# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A key-value pair used for a command.  This is used to represent an
      # argument for the command node.
      class Pair < Node
        # The key of the pair.  This will *always* be a `:TEXT`
        # {Scanner::Token}.
        #
        # @return [Scanner::Token] The key.
        attr_reader :key

        # The value of the pair.
        #
        # @return [Parser::Node::Text, Parser::Node::String] The value.
        attr_reader :value

        # Initialize the pair node with the given key, value and location.
        #
        # @param key [Scanner::Token] The key.
        # @param value [Parser::Node::Text, Parser::Node::String] The value.
        # @param location [Location] The location of the key-value pair.
        def initialize(key:, value:, location: nil)
          @key = key
          @value = value
          @location = location || key.location.union(value.location)
          freeze
        end

        # Pretty inspect.
        #
        # @return [::String]
        def inspect
          "#<#{self.class} key=#{@key.inspect} value=#{@value.inspect} " \
            "location=#{@location.inspect}>"
        end
      end
    end
  end
end
