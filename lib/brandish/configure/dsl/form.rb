# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Configure
    class DSL
      # Constructs a form for use with the configure instance.  A form is
      # basically a format and name pair; different forms can have different
      # entries, formats, and processors.
      class Form
        # The name of the form.  This defaults to a random value.  Do not
        # rely on the name unless it is set.
        #
        # @return [::String]
        attr_writer :name

        # The entry for the form.  This is the file that begins the parsing
        # for the form.
        #
        # @return [::String]
        attr_writer :entry

        # Initialize the form DSL.  This sets up the initial format and name,
        # and intializes the instance variables.
        #
        # @param format [::Symbol] The format.
        # @param name [::String, nil] The name of the form.
        def initialize(format, name = nil)
          @name = name || _generate_form_name
          @format = format
          @entry = "index.br"
          @processors = []
        end

        # Adds a processor for use for the form.  The order that this is called
        # is important.
        #
        # @param name [::String, ::Symbol, <::Symbol>] The name of the
        #   processor.  If the processor is a symbol, it is assumed to be the
        #   name of the processor; the format is guessed to be either
        #   the format of the form, or `:all`.  If the processor is a string,
        #   and it contains a colon, it is assumed to be the name of the
        #   processor in the form `<format>:<name>`; if it doesn't contain
        #   the colon, it is treated as a symbol.  If it is an array, it is
        #   assumed to be a pair containing the name of the process.
        # @param options [{::Object => ::Object}] The options for the
        #   processor.  The allowed values for the options are dependant on
        #   the processor.
        # @return [void]
        def use(name, options = {})
          format, processor = _guess_processor_name(name)
          @processors << [format, processor, options]
        end
        alias_method :process, :use
        alias_method :processor, :use

        # The data from this form.  This is used to create the actual form that
        # is used in the configuration.
        #
        # @return [(::String, ::Symbol, ::String, <(::String, ::String, ::Hash)>]
        def data
          [@name, @format, @entry, @processors]
        end

      private

        def _generate_form_name
          processor_names = @processors.map { |p| p[0..1].join(":") }.join(".")
          "#{@format}.#{processor_names}"
        end

        def _guess_processor_name(name)
          case name
          when ::String then _guess_processor_name_string(name)
          when ::Symbol then _guess_processor_name_symbol(name)
          when ::Array  then _guess_processor_name_array(name)
          else
            fail ::ArgumentError, "Unknown type given for name `#{name}`"
          end
        end

        def _guess_processor_name_string(name)
          parts = name.split(":")

          case parts
          when 1 then _guess_processor_name_symbol(name)
          when 2 then _guess_processor_name_array(parts)
          else
            _guess_processor_name_array([parts[0], parts[1..-1].join(":")])
          end
        end

        def _guess_processor_name_symbol(name)
          default = [@format, name]
          allowed = [default, [:all, name]]
          which = allowed.find { |a| Processor.all.key?(a) } || default
          _guess_processor_name_array(which)
        end

        def _guess_processor_name_array(name)
          name.map(&:intern)
        end
      end
    end
  end
end
