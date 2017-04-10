# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # Adds a `<comment>` tag.  This ignores all of the elements inside of
      # it, effectively  removing it from the output.
      #
      # This processor takes no options, nor any pairs.
      #
      # @example
      #   Congratulations!  You've won $1,000!
      #   <comment>Before taxes, anyway.</comment>
      class Comment < Processor::Base
        include Processor::Block
        self.names = %i(comment ignore)
        register %i(all comment) => self

        # Returns nil, removing the node and its children from the tree.
        #
        # @return [nil]
        def perform
          nil
        end
      end
    end
  end
end
