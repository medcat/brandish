# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    class Node
      # A "string."  Because of how loose the language is, this is similar to
      # a {Text} node, but has no restriction on the allowed values for the
      # node.
      class String < Node
        # The value of the string node.  This is the contents of the string.
        #
        # @return [::String]
        attr_reader :value

        # Initialize the string.
        #
        # @overload initialize(children:, location: nil)
        #   Initialize with the given children, converting that automatically
        #   to a location and a value.  If a location is given, it is used;
        #   otherwise, the location is assumed from the children.
        #
        #   @param children [<Scanner::Token>] The tokens constituting this
        #     string.
        #   @param location [Location, nil] The location for the string.  If
        #     none is given, it is assumed from the children.
        # @overload initialize(value:, location:)
        #   Initialize with the given value and location.
        #
        #   @param value [::String] The value of the string.
        #   @param location [Location] The location of the string.
        def initialize(children: nil, value: nil, location: nil)
          @value = value || children.map(&:value).join.freeze
          @location = location || children.map(&:location).inject(:union)
        end

        # Determines if this object and the other object are equivalent.  If
        # the other object is this object, it returns true; otherwise, if the
        # other object is a {String}, and the other object's properties equal
        # this object's properties, it returns true; otherwise, it returns
        # false.
        #
        # @param [::Object]
        # @return [Boolean]
        # def ==(other)
        #   equal?(other) || other.is_a?(String) && @value == other.value &&
        #     @location == other.location
        # end
      end
    end
  end
end
