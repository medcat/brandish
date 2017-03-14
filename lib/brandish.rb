# encoding: utf-8
# frozen_string_literal: true

require "brandish/version"
require "brandish/errors"
require "brandish/configure"
require "brandish/scanner"
require "brandish/parser"
require "brandish/markup"
require "brandish/processor"
require "brandish/processors"

# A library to format text.
module Brandish
  def self.configuration
    if block_given?
      @configuration ||= Configure.new
      Configure::DSL.call(@configuration, &::Proc.new)
    else
      @configuration
    end
  end

  def self.configure(&b)
    configuration(&b)
  end

  def self.reset_configuration
    @configuration = nil
  end
end
