# encoding: utf-8
# frozen_string_literal: true

require "rubygems" # for Gem::Requirement
require "securerandom"
require "forwardable"

require "brandish/configure/dsl"
require "brandish/configure/form"

module Brandish
  # This provides a central location for all configuration options.  For the
  # DSL, see {DSL}.
  class Configure
    extend Forwardable
    attr_reader :options
    attr_reader :forms

    delegate [:[]] => :options

    def initialize
      @options = {
        root: Pathname.new(Dir.pwd),
        source: Pathname.new("source").expand_path(Dir.pwd),
        output: Pathname.new("output").expand_path(Dir.pwd),
        templates: Pathname.new("templates").expand_path(Dir.pwd)
      }
      @forms = ::Set.new
    end

    def root
      @options.fetch(:root)
    end

    def source
      @options.fetch(:source)
    end

    def output
      @options.fetch(:output)
    end

    def templates
      @options.fetch(:templates)
    end

    def build(which = :all)
      return to_enum(:build, which) unless block_given?
      select_forms(which).each { |f| yield proc { f.build(self) } }
    end

    def refresh(which = :all)
      return to_enum(:refresh, which) unless block_given?
      @_root_nodes = nil
      select_forms(which).each { |f| yield proc { f.build(self) } }
    end

    def select_forms(which)
      which = @forms.map(&:name) if which == :all || !which.is_a?(::Array) ||
                                    which.empty?
      which = which.to_set
      @forms.select { |f| which.include?(f.name) }
    end

    def roots
      @_root_nodes ||=
        ::Hash.new do |hash, key|
          short = key.relative_path_from(root)
          scanner = Scanner.new(key.read, short, options)
          parser = Parser.new(scanner.call)
          hash[key] = parser.call
        end
    end
  end
end
