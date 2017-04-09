# encoding: utf-8
# frozen_string_literal: true

module Support
  module ParserHelper
    def n(type, a)
      Brandish::Parser::Node.const_get(type).new(a)
    end

    def l(column, line = 1..1)
      Yoga::Location.new("<anon>", line, column)
    end

    def t(type, column, value = type.to_s, line = 1..1)
      Yoga::Token.new(type, value, l(column, line))
    end
  end
end

RSpec.configure do |config|
  config.include Support::ParserHelper
end
