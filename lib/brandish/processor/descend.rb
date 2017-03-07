# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A descent processor.  This allows the context to descend into the
    # children of the node as needed.  This does *not* descend into block
    # nodes by default, due to a design decision - that has to be handled by
    # another processor.
    #
    # @api private
    class Descend < Base
      # Initializes the processor with the given context.  This *does not* adds
      # the processor to the context, and sets the context for use on the
      # processor.
      #
      # @param context [Context]
      def initialize(context)
        @context = context
      end

      # Processes the root node.  This updates the root node with an updated
      # list of children that have been accepted.
      #
      # @param node [Parser::Node::Root]
      # @return [Parser::Node::Root]
      def process_root(node)
        node.update(children: node.children.map { |c| accept(c) }.compact)
      end
    end
  end
end
