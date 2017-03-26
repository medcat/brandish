# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A block processor.  This is designed to act over a base to modify
    # one specific block.  The block name itself is specified on the
    # class, and the class provides logic to only modify block nodes with
    # the same name.
    module Block
      # Ruby hook.
      #
      # @api private
      # @return [void]
      def self.included(base)
        base.include Processor::NameFilter
        base.include Processor::PairFilter
      end

      # Processes the block.  If the node's name doesn't match the name for
      # this class, it passes it on up to {Base#process_block}; otherwise,
      # it passes it over to {#perform}.
      #
      # @param node [Parser::Node::Block]
      # @return [::Object]
      def process_block(node)
        return super unless allowed_names.include?(node.name)
        @node = node
        @name = node.name
        @pairs = node.pairs
        @body = node.body

        assert_valid_pairs
        perform
      end

      # Performs the command adjustment.  This must be subclassed and
      # overwritten.
      #
      # @abstract
      # @return [::Object]
      def perform
        fail NotImplementedError, "Please implement #{self.class}#perform"
      end
    end
  end
end
