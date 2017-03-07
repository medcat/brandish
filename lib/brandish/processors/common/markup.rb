# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module Common
      # Processes the text in the document with the given markup.  Markup
      # support varies from format to format, from a lot, to none.  All
      # supported markups are not included as a dependency on the Brandish
      # gem; they must be used as a dependency for the using library or
      # application.
      #
      # *All* formats *must* provide an `:escape` engine, that escapes the
      # source for the target format.
      #
      # Options:
      #
      # - `:engine` - Required.  This is the markup engine to use.  The allowed
      #   values for this option is dependant on the format.
      # - `:options` - Optional.  This is the
      #   options for the markup engine.  The actual type is dependant on the
      #   markup engine.  The default values are dependant on the markup engine.
      #
      # @abstract
      class Markup < Processor::Base
        # The engines defined for the subclass.  This should not be used on the
        # parent class ({Common::Markup}).  This returns a key-value pair for
        # the engines.  The key is the "name" of the format; this is used for
        # the `:engine` option.  The value is a tuple containing two values:
        # the default options, and a proc that takes two arguments to markup
        # the text.
        #
        # @api private
        # @return [{::Symbol => (::Object, ::Proc<::String, ::Object, ::String>)}]
        def self.engines
          @_engines ||= {}
        end

        # Defines an engine for use on the subclass.  This should not be used
        # on the parent class ({Common::Markup}).  This takes the name of the
        # engine, the default options for the engine, and the processor to
        # perform the markup processor.
        #
        # If both a third argument and a block are provided, then the block
        # takes precedence.
        #
        # @api private
        # @param name [::Symbol] The name of the engine.  This isn't the actual
        #   name of the markup; this is the name of the engine that processes
        #   the markup.
        # @param default [::Object] The default options for the engine.
        # @param initializer [::Symbol, ::Proc, nil] The initializer for the
        #   engine.  If this is `nil`, no initializer is called.  If this is
        #   a Symbol, the method is called for initialization.  If this is a
        #   Proc, it is called for initialization.
        # @param processor [::Symbol, ::Proc] The processor for the
        #   engine.  If this is a Symbol, the method is called for
        #   processing.  If this is a Proc, it is called for processing.
        # @return [void]
        def self.engine(name, default, initializer, processor)
          engines[name] = [default.freeze, initializer, processor]
        end

        # (see Processor::Base#initialize)
        def initialize(context, options)
          super
          initialize_engine
        end

        # (see Processor::Base#process_text)
        def process_text(node)
          node.update(value: markup(node.value))
        end

      private

        def initialize_engine
          @engine = find_engine

          case @engine[1]
          when ::Symbol then send(@engine[1])
          when ::Proc   then @engine[1].call
          when nil      then return
          else
            fail ProcessorError.new("Unknown initializer `#{@engine[1].inspect}`")
          end
        end

        def find_engine
          engine = @options.fetch(:engine)

          case engine
          when ::Symbol
            self.class.engines.fetch(engine)
          when ::Proc
            [{}, nil, engine]
          else
            fail ProcessorError.new("Unknown engine `#{engine.inspect}`")
          end
        end

        def engine_options
          @options ||= @options.fetch(:options) { @engine[0].dup }.freeze
        end

        def markup(value)
          case @engine[2]
          when ::Symbol then send(@engine[2], value, engine_options)
          when ::Proc   then @engine[2].call(value, engine_options)
          else
            fail ProcessorError.new("Unknown processor `#{@engine[2].inspect}`")
          end
        end
      end
    end
  end
end
