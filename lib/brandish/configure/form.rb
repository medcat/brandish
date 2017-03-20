# encoding: utf-8
# frozen_string_literal: true

require "pry"
require "pry-rescue"

module Brandish
  class Configure
    # A form used for building.
    Form = Struct.new(:name, :format, :entry, :processors) do
      # Builds the form.  This takes a configure object, and builds the
      # form based on that.
      #
      # @see Configure#roots
      # @see Processor::Context
      # @see Processor
      # @param configure [Configure] The configuration object for this build.
      # @return [void]
      def build(configure)
        context = Processor::Context.new(configure, self)
        root = configure.roots[configure.sources.find(entry)]

        processors.each do |(processor, options)|
          klass = processor.is_a?(::Array) ? Processor.all.fetch(processor) : processor
          klass.new(context, options)
        end

        context.process(root)
      end
    end
  end
end
