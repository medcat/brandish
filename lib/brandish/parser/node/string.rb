# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A "string."  Because of how loose the language is, this is similar to
      # a {Text} node, but has no restriction on the allowed values for the
      # node.
      class String < Text
      end
    end
  end
end
