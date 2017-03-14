# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Execute
    def initialize(context)
      context.each { |k, v| instance_variable_set(:"@#{k}", v) }
    end

    def exec(code)
      bind.exec(code)
    end

    def bind
      binding
    end
  end
end
