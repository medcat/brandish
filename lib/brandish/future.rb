# encoding: utf-8
# frozen_string_literal: true

require "forwardable"

module Brandish
  class Future
    extend Forwardable
    delegate [:to_s] => :__value__

    def initialize(&block)
      @block = block
    end

    def __value__
      @value ||= @block.call
    end

    def method_missing(name, *args, &block)
      return super unless respond_to_missing?(name)
      __value__.public_send(name, *args, &block)
    end

    def respond_to_missing?(name, *args)
      __value__.respond_to?(name, *args)
    end
  end
end
