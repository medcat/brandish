
module Brandish
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def call
      @_root ||= parse_document
    end
  end
end
