# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Verify < Processor::Base
        register %i(all verify) => self

        # Processes a block.  This always fails by design.
        #
        # @param node [Parser::Node::Block]
        def process_block(node)
          fail BuildError.new(error_message(node), node.location)
        end

        # Processes a command.  This always fails by design.
        #
        # @param node [Parser::Node::Command]
        def process_command(node)
          fail BuildError.new(error_message(node), node.location)
        end

      private

        def error_message(node)
          "Unexpected command or block element `#{node.name}` at " \
            "#{node.location}.  All command and block elements should be " \
            "processed; try adding #{suggested_processor(node)} to your " \
            "`brandish.config.rb` file"
        end

        def suggested_processor(node)
          "`form.use #{node.name.intern.inspect}` or " \
            "`form.use \"all:#{node.name}\"`"
        end
      end
    end
  end
end
