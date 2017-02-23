
require "brandish/parser/helpers"
require "brandish/parser/main"
require "brandish/parser/node"

module Brandish
  # Parses the document into a tree of nodes.
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def call
      @_root ||= parse_document
    end
  end
end
