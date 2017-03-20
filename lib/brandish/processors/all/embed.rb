# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # Provides a block that allows Ruby code to be executed within it.
      #
      # Options:
      #
      # - `:really` - Optional.  If this isn't the exact value `true`, this
      #   processor is never added to the context, preventing embed blocks from
      #   being used.
      #
      # @note
      #   This is **very dangerous** - ONLY USE IF YOU TRUST THE SOURCE.  This
      #   processor provides no sandboxing by default.
      class Embed < Processor::Base
        include Processor::Block
        self.names = %i(embed ruby)
        register %i(all embed) => self

        # (see Processor::Base#initlaize)
        def initialize(context, options = {})
          super if true.equal?(options[:really])
        end

        # Creates a {Brandish::Execute} instance and executes the code.  This
        # returns the return value of the code executed; therefore, if the
        # code returns a string value, it is added to the output; otherwise,
        # if it returns a nil value, it is ignored.  Those are the only two
        # values that should be returned; others will be rejected.
        #
        # @return [::String, nil]
        def perform
          Execute.new(execute_context).exec(@body.flatten)
        end

        # The context that is passed to {Brandish::Execute#initialize}.  This
        # provides the context, the "pairs" that were passed to the block, the
        # options that were passed to the processor, the format that it is
        # being executed in, and the form name.
        #
        # @return [{::Symbol => ::Object}]
        def execute_context
          { context: @context, pairs: @pairs, options: @options,
            format: @context.form.format, form: @context.form.name }
        end
      end
    end
  end
end
