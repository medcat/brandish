# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # The root node.  This is the parent of the full document.
      class Root < Node
        # The children of the root node.  This should be a series of nodes
        # that are in the body.
        #
        # @return [<Node>]
        attr_reader :children

        # Initialize the root node with the given children and location.
        #
        # @param children [<Node>] The children of the root node.  See
        #   {#children}.
        # @param location [Location] The location of the node.  If no location
        #   is provided, it assumed from the children.
        def initialize(children:, location: nil)
          @children = children.freeze
          @location = location || (@assumed = true) &&
                                  (@children.map(&:location).inject(:union) ||
                                  Yoga::Location.default)
          freeze
        end

        # Pretty inspect.
        #
        # @return [::String]
        def inspect
          "#<#{self.class} children=#{@children.inspect} " \
            "location=#{@location.inspect}>"
        end

        # Checks for equivalence between this and another object.  If the other
        # object is this object, it returns true; otherwise, if the other
        # object is a root, and its properties are equal to this one, it returns
        # true; otherwise, it returns false.
        #
        # @param other [::Object]
        # @return [Boolean]
        def ==(other)
          equal?(other) || other.is_a?(Root) && @children == other.children &&
            @location == other.location
        end

        # This flattens out the root node into a single string value.  This is
        # used for outputing the contents.
        #
        # @raise [NodeError] if the node contains a non-root or non-text node.
        # @return [::String]
        def flatten
          children.map do |child|
            case child
            when Node::Root then child.flatten
            when Node::Text then child.value
            else
              fail NodeError.new("Unexpected node `#{child.class}",
                node.location)
            end
          end.join
        end

      private

        def update_children(children)
          location = if @assumed
                       children.map(&:location).inject(:union) ||
                         Yoga::Location.default
                     else
                       @location
                     end
          Root.new(children: children, location: location)
        end

        def update_location(location)
          Root.new(children: @children, location: location)
        end
      end
    end
  end
end
