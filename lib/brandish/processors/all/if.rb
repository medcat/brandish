# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # Provides both an `if` and an `unless` block into the output.  The
      # processor takes one option: `:embed`.  If embed _is_ `true` (using
      # strict equalivalence `equal?`), then the if statement takes a single
      # pair, named `"condition"`.  This condition is executed using
      # {Brandish::Execute}, and if it is true, and if it is an `if` block,
      # the contents are included; otherwise, if it is false, and if it is
      # an `unless` block, the contents are included; otherwise, they are
      # ignored.  If embed is `false`, the block can take multiple pairs, and
      # each pair is matched to a name.  If the pair's value equals the matched
      # name's value, then the condition is true.  If the condition is true,
      # and the block is an `if` block, the contents are included; otherwise,
      # if it is false, and if it is an `unless` block, the contents are
      # included; otherwise, they are not.  The pair conditions that are
      # matched by default are `"format"` and `"form"`.  If pairs are included
      # that are not provided, it errors.
      #
      # Options:
      #
      # - `:embed` - Optional.  Whether or not the condition should be
      #   treaded like an embedded condition.  This must be set to the exact
      #   value of `true` for it to be accepted.
      # - `:conditions` - Optional.  A hash of extra conditions that can be
      #   checked for non-embed if blocks.
      #
      # Pairs:
      #
      # - `"condition"` - Optional.  The embedded condition for the `if` or
      #   `unless` block.  Only applies if the `:embed` option is set.
      # - `"format"` - Optional.  If this is provided, and the `:embed` option
      #   is not set, it is added as a condition.
      # - `"form"` - Optional.  If this is provided, and the `:embed` option
      #   is not set, it is added as a condition.
      #
      # @example non-embed
      #   <if format="html">
      #     <import file="html-style" />
      #   </if>
      # @example embed
      #   <if condition="@format == :html">
      #     <import file="html-style" />
      #   </if>
      # @note
      #   Using the `:embed` option is **very dangerous** - ONLY USE IF YOU
      #   TRUST THE SOURCE.  `:embed` provides no sandboxing by default.  This
      #   is why its value _must_ be set to be `true` exactly, and not
      #   any other value.
      class If < Processor::Base
        include Processor::Block
        self.names = [:if, :unless]
        register %i(all if) => self
        unrestricted_pairs!

        # If {#meets_conditions?} is true, this accepts the body of the block
        # for processing; otherwise, it returns `nil`, effectively causing
        # the body to be ignored.
        #
        # @return [Parser::Node, nil]
        def perform
          accept(@body) if meets_conditions?
        end

        # If the name of this block is `"if"`, and all of the conditions are
        # matched as outlined in the class direction, then this returns
        # `true`; otherwise, if the name of this block is `"if"`, and any of
        # the conditions are not matched as outlined in the class description,
        # then this returns `false`; otherwise, if the name of this block is
        # anything else (i.e. `"unless"`), and all of the conditions are
        # matched as outlined in the class description, then this returns
        # `false`; otherwise, if any of the conditions are not matched as
        # outlined in the class description, then this returns `true`.
        #
        # @return [::Boolean]
        def meets_conditions?
          @name == "if" ? match_conditions : !match_conditions
        end

      private

        def match_conditions
          true.equal?(@options[:embed]) ? exec_condition : pair_condition
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
          }.merge!(custom_match_pair).freeze
        end

        def custom_match_pair
          @options
            .fetch(:conditions, {})
            .map { |k, v| [k, v].map(&:to_s) }
            .to_h.freeze
        end
      end
    end
  end
end
