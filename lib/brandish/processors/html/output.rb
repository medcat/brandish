# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Output < Processor::Base
        register %i(html output) => self
      end
    end
  end
end