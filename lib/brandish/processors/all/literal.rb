# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Literal < Processor::Block
        name :literal, :raw
        register %i(all literal) => self

        def perform(_)
          @body.prevent_update
        end
      end
    end
  end
end
