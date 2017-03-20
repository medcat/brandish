# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A processor.  This responds to a set of methods that return updated
    # versions of the nodes that are passed to them.  Processors are all
    # initialized at the same time, with a context.  The processor is expected
    # to add an object that responds to #call with arity matching `1` to the
    # context using {Context#<<}.  The processor is allowed to add any number
    # of objects to the context using this, if need be; by default, the
    # processor just adds itself.
    #
    # @abstract
    #   This class is not designed to be used and instantiated directly; this
    #   just provides common behavior for a processor.  This class should be
    #   subclassed and proper behavior defined on a subclass.
    class Base
      # (see Processor.register)
      def self.register(map)
        Processor.register(map)
      end

      # The context associated with this processor.
      #
      # @return [Context]
      attr_reader :context

      # Initializes the processor with the given context.  This adds the
      # processor to the context, and sets the context for use on the
      # processor.
      #
      # @param context [Context]
      # @param options [::Object] The options for this processor.
      def initialize(context, options = {})
        @context = context
        @context << self
        @options = options
        setup
      end

      # This is called by {#initialize}.  This allows subclasses to perform
      # any nessicary setups without having to override {#initialize}.  This
      # does nothing by default.
      #
      # @return [void]
      def setup; end

      # Processes the given node.  By default, it checks the classes of the
      # inbound node, and maps them to `process_*` blocks.  If it doesn't
      # match, an `ArgumentError` is thrown.
      #
      # If this function returns a `nil` value, the node should be ignored.
      # {Context#accept} acknowledges this, and skips over the remaining
      # processors once a processor returns a `nil` value for a node.
      #
      # @raise [::ArgumentError] if the node given isn't one of
      #   {Parser::Node::Block}, {Parser::Node::Command}, {Parser::Node::Root},
      #   or {Parser::Node::Text}.
      # @param node [Parser::Node] A parser node to handle.
      # @return [Parser::Node, nil] The result of processing.
      def call(node)
        _fix_result(_switch_node(node), node)
      rescue LocationError then fail
      rescue => e
        fail BuildError.new("#{e.class}: #{e.message}", node.location,
          e.backtrace)
      end

      # (see Context#accept)
      def accept(node)
        context.accept(node)
      end

      # Processes a block.  By default, this performs no modifications on the
      # node, and returns the node itself.
      #
      # @param node [Parser::Node::Block]
      # @return [::Object]
      def process_block(node)
        node
      end

      # Processes a command.  By default, this performs no modifications on the
      # node, and returns the node itself.
      #
      # @param node [Parser::Node::Command]
      # @return [::Object]
      def process_command(node)
        node
      end

      # Processes a root node.  By default, this performs no modifications on
      # the node, and returns the node itself.
      #
      # @param node [Parser::Node::Root]
      # @return [::Object]
      def process_root(node)
        node
      end

      # Processes a text node.  By default, this performs no modifications on
      # the node, and returns the node itself.
      #
      # @param node [Parser::Node::Text]
      # @return [::Object]
      def process_text(node)
        node
      end

      # An optional post-process.
      #
      # @param root [Parser::Node::Root]
      # @return [void]
      def postprocess(root); end

    private

      def _switch_node(node)
        case node
        when Parser::Node::Block   then process_block(node)
        when Parser::Node::Command then process_command(node)
        when Parser::Node::Root    then process_root(node)
        when Parser::Node::Text    then process_text(node)
        else
          fail ArgumentError, "Expected node, got `#{node.class}'"
        end
      end

      def _fix_result(result, node)
        case result
        when Parser::Node, nil
          result
        when ::String
          Parser::Node::Text.new(value: result, location: node.location)
                            .prevent_update
        else
          fail ArgumentError, "Unknown result type `#{result.class}' " \
            "(given from #{self.class})"
        end
      end
    end
  end
end
