# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class If < Processor::Base
        include Processor::Block

        self.names = [:if, :unless]
        register %i(all if) => self

        def perform
          accept(@body) if meets_conditions?
        end

        def meets_conditions?
          @name == "if" ? match_conditions : !match_conditions
        end

      private

        def match_conditions
          @options[:embed] ? exec_condition : pair_condition
        end

        def exec_condition
          context = Brandish::Execute.new(execute_context)
          context.exec(@pairs.fetch("condition"))
        end

        def execute_context
          { context: @context, pairs: @pairs, options: @options,
            format: @context.form.format, form: @context.form.name }
        end

        def pair_condition
          @pairs.all? { |k, v| match_pair.fetch(k.to_s).to_s == v.to_s }
        end

        def match_pair
          @_match_pair ||= {
            "format" => @context.form.format, "form" => @context.form.name
          }.freeze
        end
      end
    end
  end
end
