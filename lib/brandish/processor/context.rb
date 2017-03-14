# encoding: utf-8
# frozen_string_literal: true

require "forwardable"

module Brandish
  module Processor
    # The state associated with all of the processors.  Since all processors
    # are independant class instances, instance variables that are used in
    # one processor does not affect another; however, shared state can be
    # used through the context.
    #
    # The context also keeps track of the processors being used for the
    # processor, and distributes the processing management throughout all of
    # the processors.
    class Context
      extend Forwardable
      # @!method <<(*processors)
      #   Adds processors to the processor list.  This delegates to
      #   {#processors}.
      #
      #   @return [<#call>]
      # @!method push(*processors)
      #   Adds processors to the processor list.  This delegates to
      #   {#processors}.
      #
      #   @return [<#call>]
      # @!method unshift(*processors)
      #   Adds a processor to the start of the processor list.  This delegates
      #   to {#processors}.
      #
      #   @return [<#call>]
      delegate [:<<, :push, :unshift] => :@processors

      # @!method [](key)
      #   Sets a key on the context.  This gets an option that is used for all
      #   processors on this context.
      #
      #   @param key [::Symbol, ::String] The key.
      #   @return [::Object]
      # @!method []=(key, value)
      #   Sets a key on the context.  This sets an option that is used for all
      #   processors on this context.
      #
      #   @param key [::Symbol, ::String] The key.
      #   @param value [::Object] The value.
      #   @return [::Object]
      # @!method fetch(key, default = CANARY, &block)
      #   Fetches a value at the given key, or provides a default if the key
      #   doesn't exist.  If both a block and a default argument are given,
      #   the block form takes precedence.
      #
      #   @overload fetch(key)
      #     Attempts to retrieve a value at the given key.  If there is no
      #     key-value pair at the given key, it raises an error.
      #
      #     @raise [KeyError] if the key isn't on the context.
      #     @param key [::Symbol, ::String] The key.
      #     @return [::Object] The value.
      #
      #  @overload fetch(key, default)
      #    Attempts to retrieve a value at the given key.  If there is no
      #    key-value pair at the given key, it returns the value given by
      #    `default`.
      #
      #    @param key [::Symbol, ::String] The key.
      #    @param default [::Object] The default value.
      #    @return [::Object] The value, or the default value if there isn't
      #      one.
      #
      #   @overload fetch(key, &block)
      #     attempts to retrieve a value at the given key.  If there is no
      #     key-value pair at the given key, it yields.
      #
      #     @yields if there is no corresponding key-value pair.
      #     @param key [::Symbol, ::String] The key.
      #     @return [::Object] The value, or the result of the block if there
      #       isn't one.
      delegate [:[], :[]=, :fetch] => :@options

      # @!method merge(options)
      #   Merges the given options into this context.
      #
      #   @param options [{::Symbol, ::String => ::Object}]
      #   @return [void]
      def_delegator :@options, :merge!, :merge

      # The processors that are going to be run on an accept.  This can be
      # a {Processor::Base} subclass, or any object that responds to `#call`.
      #
      # @return [<#call>]
      attr_reader :processors

      # The configuration for the build.  This is used for output directories
      # and the like.
      #
      # @return [Configure]
      attr_reader :configure

      # The form that is being processed.
      #
      # @return [Configure::Form]
      attr_reader :form

      # Initialize the context, to set up the internal state.
      def initialize(configure, form)
        @processors = []
        @configure = configure
        @form = form
        @descent = Processor::Descend.new(self)
        @visited = ::Set.new
        @buffer = []
        @options = {}
      end

      # Performs the processing of the given root node.  This should be a
      # {Parser::Node::Root}.
      #
      # @param root [Parser::Node::Root]
      # @return [::Object]
      def process(root)
        accept(root)
        effective_processors.each(&:postprocess)
      end

      # Accepts a node.  This passes the node through all of the processors,
      # as well as an instance of the {Processor::Descend} processor.
      #
      # @param node [Parser::Node] The node to process.
      # @return [::Object]
      def accept(node)
        # FIXME: Temporary check to ensure that we never visit the same node
        # twice.  This should only happen by default - if it is required by any
        # custom processors, it should be allowed.  Therefore, this is only
        # here for the core processors.
        fail if @visited.include?(node)
        @visited << node
        # Injects the node over all effective processors.  Every iteration will
        # use the value returned by the last `process` method call, unless it
        # is `nil`.
        effective_processors.inject(node) { |n, p| p.call(n) if n }
      end

    private

      def effective_processors
        [@descent] + @processors
      end
    end
  end
end
