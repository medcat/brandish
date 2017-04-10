# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # Adds a `<capture>` tag.  This takes a block, and stores it.  This
      # does not output directly to the document; instead, it allows the
      # output to be deferred.  If the capture group is not outputted, then
      # this is similar to a comment, except the body is processed beforehand.
      #
      # Pairs:
      #
      # - `"name"` - Optional.  The name of the capture group.  This is used
      #   to pull the contents of the capture block later.
      class Capture < Common::Group
        self.names = %i(capture)
        register %i(all capture) => self

        def setup
          @context[:captures] = {}
        end

        # Accepts the body, and if no name is provided, discards it; otherwise,
        # stores it for later accessing.
        #
        # @return [nil]
        def perform
          contents = accepted_body
          return nil unless name_value
          @context[:captures][name_value] = contents

          nil
        end
      end
    end
  end
end
