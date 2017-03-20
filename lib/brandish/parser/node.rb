# encoding: utf-8
# frozen_string_literal: true

require "brandish/parser/node/block"
require "brandish/parser/node/command"
require "brandish/parser/node/pair"
require "brandish/parser/node/root"
require "brandish/parser/node/text"
require "brandish/parser/node/string"

module Brandish
  class Parser
    # A parser node.  This is the base for all parser nodes.b  All parser
    # nodes are frozen, and so cannot be mutated; all mutations need to be
    # set up as a new node, that is then returned.
    class Node
      # The location of the node.
      #
      # @return [Location]
      attr_reader :location

      # Initialize the node with the given location.  This should be
      # overwritten by a decending node, but all decending nodes should
      # include a location.
      #
      # @param location [Location] The location.  See
      #   {#location}.
      def initialize(location:)
        @location = location
      end

      # Pretty inspect.
      #
      # @return [::String]
      def inspect
        "#<#{self.class} location=#{@location}>"
      end

      # "Updates" the node with the given attributes.  All of the key-value
      # pairs in the attributes are updated on the node by sending an update
      # to the node.
      #
      # @example
      #   node.update(some: true, value: true)
      #   # this sends `update_some` and `update_value`, each with `true` as
      #   # the argument.  These functions return a node similar to the
      #   # original, but with the requested change.  This is functionally
      #   # similar to this (with some minor differences):
      #   node.update_some(true).update_value(true)
      # @raise [NodeError] if an attribute key is passed that isn't updatable
      #   for the node.
      # @param attributes [{::Symbol, ::String => ::Object}] The attributes to
      #   update, and the new values for them.
      # @return [Node] The updated node, or `self` if no attributes are given.
      def update(attributes)
        attributes.inject(self) { |a, (n, v)| a.update_attribute(n, v) }
      end

      # Prevents all calls to {#update}.  This is used on nodes that should
      # never be updated.  This is a stop-gap measure for incorrectly
      # configured projects.  This, in line with all other methods, creates
      # a duplicate node.
      #
      # @return [Node]
      def prevent_update
        node = dup
        node.singleton_class.send(:undef_method, :update)
        node
      end

      def update_prevented?
        !respond_to?(:update)
      end

    protected

      # Updates an attribute on the node.  This is used for {#update}.
      #
      # @param name [::Symbol, ::String] The name of the attribute.
      # @param value [::Object] The value of the attribute.
      def update_attribute(name, value)
        return send(:"update_#{name}", value) if respond_to?(:"update_#{name}", true)

        fail NodeError.new("Unable to update attribute #{name} on #{self}",
          @location)
      end
    end
  end
end
