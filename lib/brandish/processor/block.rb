# encoding: utf-8
# frozen_string_literal: true

require "forwardable"

module Brandish
  module Processor
    # A block processor.  This is designed to act over a base to modify
    # one specific block.  The block name itself is specified on the
    # class, and the class provides logic to only modify block nodes with
    # the same name.
    #
    # @abstract
    #   This class is not designed to be used and instantiated directly; this
    #   just provides common behavior for a processor.  This class should be
    #   subclassed and proper behavior defined on a subclass.
    class Block < Base
      include Processor::NameFilter

      # Processes the block.  If the node's name doesn't match the name for
      # this class, it passes it on up to {Base#process_block}; otherwise,
      # it passes it over to {#perform}.
      #
      # @param node [Parser::Node::Block]
      # @return [::Object]
      def process_block(node)
        return super unless allowed_names.include?(node.name)
        @options = node.pairs
        @body = node.body
        perform(node)
      end

      # Performs the block adjustment.  This must be subclassed and
      # overwritten.
      #
      # @abstract
      # @param _node [Parser::Node::Block]
      # @return [::Object]
      def perform(_node)
        fail NotImplementedError.new("Please implement #{self.class}#perform")
      end
    end
  end
end
