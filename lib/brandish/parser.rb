# encoding: utf-8
# frozen_string_literal: true

require "yoga"
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
    include Yoga::Parser
    include Parser::Main
  end
end
