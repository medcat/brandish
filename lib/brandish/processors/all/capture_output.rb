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
      # - `"name"` - Required.  The name of the capture group.  This is used
      #   to pull the contents of the capture block later.
      class CaptureOutput < Processor::Base
        include Processor::Command
        self.names = %i(capture_output capture-output capout)
        register %i(all capture_output) => self
        pair :name

        def perform
          @context[:captures].fetch(@pairs.fetch("name"))
        end
      end
    end
  end
end
