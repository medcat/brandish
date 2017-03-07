# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A command processor.  This is designed to act over a base to modify
    # one specific command.  The command name itself is specified on the
    # class, and the class provides logic to only modify command nodes with
    # the same name.
    #
    # @abstract
    #   This class is not designed to be used and instantiated directly; this
    #   just provides common behavior for a processor.  This class should be
    #   subclassed and proper behavior defined on a subclass.
    class Command < Base
      include Processor::NameFilter

      # Processes the command.  If the node's name doesn't match the name for
      # this class, it passes it on up to {Base#process_command}; otherwise,
      # it passes it over to {#perform}.
      #
      # @param node [Parser::Node::Command]
      # @return [::Object]
      def process_command(node)
        return super unless allowed_names.include?(node.name)
        @options = node.pairs
        perform(node)
      end

      # Performs the command adjustment.  This must be subclassed and
      # overwritten.
      #
      # @abstract
      # @param _node [Parser::Node::Command]
      # @return [::Object]
      def perform(_node)
        fail NotImplementedError.new("Please implement #{self.class}#perform")
      end
    end
  end
end
