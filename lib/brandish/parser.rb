# encoding: utf-8
# frozen_string_literal: true

require "brandish/parser/helpers"
require "brandish/parser/main"
require "brandish/parser/node"

module Brandish
  # Parses the document into a tree of nodes.  This is strictly an LL(0)
  # recursive descent parser - even though the term `peek` is used, this is
  # technically a shifted token that is acted upon.
  #
  # This constructs a tree that can then be walked or modified to construct
  # an end product.
  class Parser
    include Parser::Helpers
    include Parser::Main

    # Initialize the parser with the enumerator of tokens.  These tokens should
    # be terminated with an EOF token (See {Scanner::Token.eof}), and should be
    # an actual Enumerator.  For more information on Enumerators, please refer
    # to the Ruby documentation; if you have an array of tokens, calling
    # `#each` on it (without a block) will return an enumerator.
    #
    # @param tokens [::Enumerator<Scanner::Token>] An enumerator over the
    #   tokens from the original file.
    def initialize(tokens)
      @tokens = tokens
    end

    # Parses the document.  See {Main#parse_document}.
    #
    # @return [Parser::Node]
    def call
      @_root ||= parse_document
    end
  end
end
