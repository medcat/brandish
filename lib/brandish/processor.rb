# encoding: utf-8
# frozen_string_literal: true

require "brandish/processor/base"
require "brandish/processor/context"
require "brandish/processor/name_filter"
require "brandish/processor/block"
require "brandish/processor/command"
require "brandish/processor/descend"

module Brandish
  # Processors for Brandish.  These just handle reshaping nodes so that they
  # output nicely.  This can be used for things like including, bold tags,
  # etc.
  module Processor
    # A structure containing all of the processors available.  This is a key
    # value store, with the key being the format and the name, and the value
    # being the actual processor.
    #
    # @return [{(::Symbol, ::Symbol) => Processor::Base}]
    def self.all
      @_processors ||= ::Hash.new
    end

    # Registers processors with the global registry.  This interns the format
    # and name of the processor.  If the format and name pair already exists,
    # it raises a {ProcessorError}.
    #
    # @example
    #   Processor.register [:html, :stripper] => self
    # @example
    #   Processor.register [:all, :descend] => self
    # @raise [ProcessorError] If one of the format and name pairs already
    #   exists.
    # @param map [{(::Symbol, ::Symbol) => Processor::Base}] The processors to
    #   register.
    # @return [void]
    def self.register(map)
      map.each do |(format, name), processor|
        format, name = format.intern, name.intern
        fail ProcessorError, "#{format}:#{name} already exists" \
          if all.key?([format, name])
        all[[format, name]] = processor
      end
    end
  end
end
