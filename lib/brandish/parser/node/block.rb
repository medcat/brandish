# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A "block" node.  Basically, this is a node that encapsulates a block of
      # text.  This typically has a 1-to-1 relationship with the body of text,
      # while a command may not.
      class Block < Node
        # The name of the block.
        #
        # @return [::String]
        attr_reader :name

        # The body of the block.
        #
        # @return [Node::Root]
        attr_reader :body

        # The "pairs" of arguments to be passed to the command.
        #
        # @return [{::String => ::String}]
        attr_reader :pairs

        # Creates a block with the given name, body, and location.  If no
        # location is given, it is assumed from the name and body.
        #
        # @param name [Scanner::Token] The name of the block.
        # @param body [Node::Root] The body of the block.

        # @param location [Location] The location of the block.
        def initialize(name:, body:, arguments: nil, pairs: nil, location: nil)
          if !location && !arguments
            fail ArgumentError, "Expected either a location or " \
              "arguments, got neither"
          end

          @name = name.is_a?(Yoga::Token) ? name.value : name
          @body = body
          @location = location || arguments.map(&:location)
                                           .inject(name.location.union(body.location),
                                             :union)
          @pairs = pairs.freeze || derive_pairs(arguments).freeze
        end

        # Pretty inspect.
        #
        # @return [::String]
        def inspect
          "#<#{self.class} name=#{@name.inspect} pairs=#{@pairs.inspect} " \
            "body=#{@body.inspect} location=#{@location.inspect}>"
        end

        # Equates this object with another object.  If the other object is
        # this object, it returns true; otherwise, if it is a block, whose
        # properties all equal this one, it returns true; otherwise, it
        # returns false.
        #
        # @param other [::Object]
        # @return [Boolean]
        def ==(other)
          equal?(other) || other.is_a?(Block) && @name == other.name &&
            @body == other.body && @location == other.location
        end

      private

        def update_name(name)
          Block.new(name: name, body: @body, pairs: @pairs, location: @location)
        end

        def update_body(body)
          Block.new(name: @name, body: body, pairs: @pairs, location: @location)
        end

        def update_pairs(pairs)
          Block.new(name: @name, body: @body, pairs: pairs, location: @location)
        end

        def update_arguments(arguments)
          update_pairs(derive_pairs(arguments))
        end

        def update_location(location)
          Block.new(name: @name, body: @body, pairs: @pairs, location: location)
        end

        def derive_pairs(arguments)
          arguments.inject({}) do |a, pair|
            k, v = pair.key, pair.value
            a.merge!(k.value => v.value)
          end.freeze
        end
      end
    end
  end
end
