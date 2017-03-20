# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A command node.  This takes the form of `{.a b=c}`, and executes a
      # given command with the given options.
      class Command < Node
        # The name of the command node.  This is the name of the command that
        # is executed.
        #
        # @return [::String]
        attr_reader :name

        # The "pairs" of arguments to be passed to the command.
        #
        # @return [{::String => ::String}]
        attr_reader :pairs

        # Initialize the command node.
        #
        # @overload initialize(name:, arguments:, location: nil)
        #   Creates a command node with the given name.  The arguments are
        #   processed to turn into a hash that is a key-value store of the
        #   arguments; if there are duplicate key-values pairs, the earlier
        #   ones are overwritten.  If no location is provided, it is assumed
        #   from the name and arguments.
        #
        #   @param name [::String, Scanner::Token] The name of the command.  If
        #     no location is provided, this *must* respond to `#location`.
        #   @param arguments [<Node::Pair>] The pairs of arguments as an array
        #     of nodes.
        # @overload initialize(name:, pairs:, location:)
        #   Creates a command node with the given name and argument pairs.
        #   Since no location can be derived from either, the location is
        #   required.
        #
        #   @param name [::String, Scanner::Token] The name of the command.
        #   @param pairs [{::String => ::String, ::Numeric}] The argument pairs
        #     for the command.
        #   @param location [Location] The location of the node.
        def initialize(name:, arguments: nil, pairs: nil, location: nil)
          if !location && !arguments
            fail ArgumentError, "Expected either a location or " \
              "arguments, got neither"
          end

          @name = name.is_a?(Yoga::Token) ? name.value : name.freeze
          @location = location || arguments.map(&:location)
                                           .inject(name.location, :union)
          @pairs = pairs.freeze || derive_pairs(arguments).freeze
        end

        # Determines if this object and the given object are equal.  If the
        # other object is this object, it returns true; otherwise, if the other
        # object is a {Command}, and all of the properties of that object equal
        # this one, then it returns true; otherwise, it returns false.
        #
        # @param other [::Object] The object to equal.
        # @return [Boolean]
        def ==(other)
          equal?(other) || (other.is_a?(Command) && @name == other.name &&
            @location == other.location && @pairs == other.pairs)
        end

        # Pretty inspect.
        #
        # @return [::String]
        def inspect
          "#<#{self.class} name=#{@name.inspect} pairs=#{@pairs.inspect} " \
            "location=#{@location.inspect}>"
        end

      private

        def update_name(name)
          Command.new(name: name, pairs: @pairs, location: @location)
        end

        def update_pairs(pairs)
          Command.new(name: @name, pairs: pairs, location: @location)
        end

        def update_arguments(arguments)
          update_pairs(derive_pairs(arguments))
        end

        def update_location(location)
          Command.new(name: @name, pairs: @pairs, location: location)
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
