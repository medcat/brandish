# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A command processor.  This is designed to act over a base to modify
    # one specific command.  The command name itself is specified on the
    # class, and the class provides logic to only modify command nodes with
    # the same name.
    module Command
      # Ruby hook.
      #
      # @api private
      # @return [void]
      def self.included(base)
        base.include Processor::NameFilter
      end

      # Processes the command.  If the node's name doesn't match the name for
      # this class, it passes it on up to {Base#process_command}; otherwise,
      # it passes it over to {#perform}.
      #
      # @param node [Parser::Node::Command]
      # @return [::Object]
      def process_command(node)
        return super unless allowed_names.include?(node.name)
        @node = node
        @name = node.name
        @pairs = node.pairs
        @body = nil
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
