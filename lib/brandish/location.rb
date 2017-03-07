# encoding: utf-8
# frozen_string_literal: true

module Brandish
  # A location in a file.  This can be used for debugging purposes.
  class Location
    # The file the location is positioned in.  This should just be a string
    # that uniquely identifies the file from all possible values of the
    # location.
    #
    # @return [::String]
    attr_reader :file

    # The line the location is on.  This can be a range of lines, or a single
    # line.
    #
    # @return [::Range]
    attr_reader :line

    # The column the location on.  This can be a range of columns, or a single
    # column.
    #
    # @return [::Range]
    attr_reader :column

    # A "hash" of the location.  This is a number that is meant to roughly
    # represent the value of this location.  Used primarily for the Hash
    # class.
    #
    # @api private
    # @return [::Numeric]
    attr_reader :hash

    # Creates a "default" location.  This is a location that can
    # be given if the location is unknown.
    #
    # @param file [::String] The file.  See {#file}.
    # @return [Location]
    def self.default(file = "<unknown>")
      new(file, 0..0, 0..0)
    end

    # Initialize the location with the given information.
    #
    # @param file [::String] The file.  See {#file}.
    # @param line [::Range, ::Numeric] The line.  See {#line}.
    # @param column [::Range, ::Numeric] The column.  See {#column}.
    def initialize(file, line, column)
      @file = file.freeze
      @line = ensure_range(line).freeze
      @column = ensure_range(column).freeze
      @hash = [@file, @line, @column].hash
      freeze
    end

    # Creates a string representing this location in a file.
    #
    # @return [::String]
    def to_s
      "#{file}:#{range(line)}.#{range(column)}"
    end

    # Pretty inspect.
    #
    # @return [::String]
    def inspect
      "#<#{self.class} #{self}>"
    end

    # Determines if the other object is equal to the current instance.  This
    # checks `equal?` first to determine if they are strict equals; otherwise,
    # it checks if the other is a {Location}.  If it is, it checks that the
    # properties are equal.
    #
    # @example
    #   a # => #<Location file="a" line=1..1 column=5..20>
    #   a == a # => true
    # @example
    #   a # => #<Location file="a" line=1..1 column=5..20>
    #   b # => #<Location file="a" line=1..1 column=5..20>
    #   a == b # => true
    # @example
    #   a # => #<Location file="a" line=1..1 column=5..20>
    #   b # => #<Location file="b" line=1..1 column=6..20>
    #   a == b # => false
    #
    # @param other [Object]
    # @return [Boolean]
    def ==(other)
      equal?(other) || other.is_a?(Location) && @file == other.file &&
        @line == other.line && @column == other.column
    end

    # Unions this location with another location.  This creates a new location,
    # with the two locations combined.  A conflict in the file name causes an
    # error to be raised.
    #
    # @example
    #   a = Location.new("a", 1..1, 5..10)
    #   a.union(a) # => #<Location file="a" line=1..1 column=5..10>
    #   a.union(a) == a # => true
    #   a.union(a).equal?(a) # => false
    # @example
    #   a = Location.new("a", 1..1, 5..10)
    #   b = Location.new("a", 1..1, 6..20)
    #   a.union(b) # => #<Location file="a" line=1..1 column=5..20>
    # @example
    #   a = Location.new("a", 1..5, 3..10)
    #   b = Location.new("b", 1..3, 2..20)
    #   a.union(b) # => #<Location file="a" line=1..5 column=2..20>
    # @example
    #   a # => #<Location ...>
    #   b # => #<Location ...>
    #   a.union(b) == b.union(a)
    #
    # @raise [::ArgumentError] if other isn't a {Location}.
    # @raise [::ArgumentError] if other's file isn't the receiver's file.
    # @param others [Location]
    # @return [Location]
    def union(*others)
      others.each do |other|
        fail ArgumentError.new("Expected #{self.class}, got #{other.class}") \
          unless other.is_a?(Location)
        fail ArgumentError.new("Expected other to have the same file") unless
          file == other.file
      end

      line = construct_range([@line, *others.map(&:line)])
      column = construct_range([@column, *others.map(&:column)])

      Location.new(@file, line, column)
    end

    alias_method :|, :union

  private

    def construct_range(from)
      first = from.map(&:first).min
      last = from.map(&:last).max

      first..last
    end

    def ensure_range(value)
      case value
      when ::Numeric
        value..value
      when ::Range
        value
      else
        fail ArgumentError.new("Unexpected #{value.class}, expected Range")
      end
    end

    def range(value)
      return value.first unless value.size != 1
      "#{value.first}-#{value.last}"
    end
  end
end
