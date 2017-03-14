# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Literal < Processor::Base
        include Processor::Block
        self.names = [:literal, :raw]
        register %i(all literal) => self

        def perform
          @body.flatten
        end
      end
    end
  end
end
