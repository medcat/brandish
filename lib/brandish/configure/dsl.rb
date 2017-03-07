# encoding: utf-8
# frozen_string_literal: true

require "rubygems" # for Gem::Requirement
require "pathname"

module Brandish
  class Configure
    class DSL
      attr_reader :configure

      def self.call(configure = Configure.new)
        DSL.new(configure).tap { |t| yield t }
      end

      def initialize(configure = Configure.new)
        @configure = configure
      end

      def version(*requirements)
        requirement = Gem::Requirement.new(*requirements)
        return if requirement =~ Gem::Version.new(Brandish::VERSION)
        fail Error.new("Running version of Brandish doesn't meet requirements")
      end

      def set(name, value)
        @configure.options[name.intern] = value
      end

      def root(value)
        @configure.options[:root] = Pathname.new(value).expand_path(Dir.pwd)
      end

      def form(*arguments)
        instance = Configure::Form.new(*arguments)
        yield instance
        @configure.forms << instance
        instance
      end
    end
  end
end
