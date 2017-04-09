# encoding: utf-8
# frozen_string_literal: true

require "brandish/version"
require "brandish/errors"
require "brandish/execute"
require "brandish/path_set"
require "brandish/configure"
require "brandish/scanner"
require "brandish/parser"
require "brandish/markup"
require "brandish/processor"
require "brandish/processors"

# A library to format text.
module Brandish
  # @overload self.configuration(&block)
  #   Sets the configuration object to a new {Configure} object, and builds it
  #   using {Configure::DSL.call}.  The configuration object is then returned.
  #
  #   @yield
  #   @return [Configure]
  # @overload self.configuration
  #   Returns the current configuration object.
  #
  #   @return [Configure]
  def self.configuration(root = ::Dir.pwd)
    if block_given?
      @configuration ||= Configure.new(::File.expand_path(root))
      Configure::DSL.call(@configuration, &::Proc.new)
    else
      @configuration
    end
  end

  # Sets the configuration object to a new {Configure} object, and builds it
  # using {Configure::DSL.call}.  The configuration object is then returned.
  #
  # @yield
  # @return [Configure]
  def self.configure(&b)
    configuration(&b)
  end

  # Resets the configuration object, so that it can be redefined.  This is
  # used to clear out the previous configuration.
  #
  # @return [void]
  def self.reset_configuration
    @configuration = nil
  end
end
