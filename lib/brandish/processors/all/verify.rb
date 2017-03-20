# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # This does nothing to the tree.  This just "verifies" that there are
      # no remaining blocks or commands in the node tree, as they shouldn't be.
      # This is highly recommended, as most Output processors are unable to
      # handle the remaining blocks or commands.
      #
      # This processor takes no options.
      class Verify < Processor::Base
        register %i(all verify) => self

        # Processes a block.  This always fails by design.
        #
        # @param node [Parser::Node::Block]
        # @raise BuildError
        def process_block(node)
          fail VerificationBuildError.new(error_message(node), node.location)
        end

        # Processes a command.  This always fails by design.
        #
        # @param node [Parser::Node::Command]
        # @raise BuildError
        def process_command(node)
          fail VerificationBuildError.new(error_message(node), node.location)
        end

      private

        def error_message(node)
          "Unexpected command or block element `#{node.name}' at " \
            "#{node.location}; try adding #{suggested_processor(node)} to " \
            "your `brandish.config.rb' file"
        end

        def suggested_processor(node)
          "`form.use #{node.name.intern.inspect}' or " \
            "`form.use #{"all:#{node.name}".inspect}'"
        end
      end
    end
  end
end
