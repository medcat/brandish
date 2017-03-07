# encoding: utf-8
# frozen_string_literal: true

module Brandish
  # An error that originates from the library for a library-specific reason.
  # All libraries errors inherit from this class.
  class Error < ::StandardError; end

  # An error that is created when there is a problem with scanning the
  # document.
  class ScanError < Error; end

  # An error that occurs with setting up a processor.  This has no location
  # information because this error occurs independant of a document.
  class ProcessorError < Error; end

  # This should never be used directly.  This is an error that is tied to
  # a location; as such, it provides an initalizer for providing a location.
  #
  # @api private
  class LocationError < Error
    # The location of the error in a file.
    #
    # @return [Location]
    attr_reader :location

    # Initialize the error with the given location and message.
    def initialize(message, location = Location.default)
      @location = location
      super(message)
    end
  end

  # An error that occurs when parsing.  This is for unexpected tokens.
  class ParseError < LocationError; end

  # An error that is created when there is an issue interacting with a parser
  # node.
  class NodeError < ParseError; end

  # An error occured during a build.
  class BuildError < LocationError; end
end
