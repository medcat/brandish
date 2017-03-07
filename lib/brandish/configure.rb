# encoding: utf-8
# frozen_string_literal: true

require "rubygems" # for Gem::Requirement
require "securerandom"

require "brandish/configure/dsl"
require "brandish/configure/form"

module Brandish
  # This provides a central location for all configuration options.  For the
  # DSL, see {DSL}.
  class Configure
    attr_reader :options
    attr_reader :forms

    def self.random_name
      SecureRandom.hex
    end

    def initialize
      @options = { root: Pathname.new(Dir.pwd) }
      @forms = ::Set.new
    end

    def build(which = :all)
      which = @forms.map(&:name) if which == :all ||
        (which.is_a?(::Array) && which.empty?)
      forms = @forms.select { |f| which.include?(f.name) }
      forms.each { |f| f.build(root_nodes, @options) }
    end

  private

    def root_nodes
      @_root_nodes||=
        ::Hash.new do |hash, key|
          short = key.relative_path_from(@options[:root])
          scanner = Scanner.new(key.read, short, options)
          parser = Parser.new(scanner.call)
          hash[key] = parser.call
        end
    end
  end
end
