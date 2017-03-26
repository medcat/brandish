# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A "string."  Because of how loose the language is, this is similar to
      # a {Text} node, but has no restriction on the allowed values for the
      # node.
      class String < Text
        # A set of tokens kinds that are allowed to be in a string node.
        #
        # @return [::Set<::Symbol>]
        TOKENS = (Node::Text::TOKENS - ::Set[:'"']) + ::Set[:<, :>]

      private

        def assert_valid_tokens(tokens)
          valid = tokens.all? { |t| TOKENS.include?(t.kind) }
          return valid if valid
          fail ::ArgumentError, "Expected tokens to all be one of " \
            "#{TOKENS.map(&:inspect).join(', ')}"
        end
      end
    end
  end
end
