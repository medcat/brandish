# encoding: utf-8
# frozen_string_literal: true

require "brandish/version"
require "brandish/errors"
require "brandish/configure"
require "brandish/location"
require "brandish/scanner"
require "brandish/parser"
require "brandish/processor"
require "brandish/processors"

# A library to format text.
module Brandish
  def self.configure
    if block_given?
      @configure ||= Configure.new
      Configure::DSL.call(@configure, &::Proc.new)
    else
      @configure
    end
  end
end
