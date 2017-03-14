# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Embed < Processor::Base
        include Processor::Block
        self.names = [:embed, :ruby]
        register %i(all embed) => self

        def perform
          @context = Brandish::Execute.new(execute_context)
          @context.exec(@body.flatten)
        end

        def execute_context
          { context: @context, pairs: @pairs, options: @options,
            format: @context.form.format, form: @context.form.name }
        end
      end
    end
  end
end
