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

    # The options.  These can be anything; predefined options are `:root`,
    # `:source`, `:output`, and `:templates`; for more information on those,
    # see {#root}, {#sources}, {#output}, and {#templates} for more information.
    # These options should not be accessed directly, but rather through their
    # accessors.  Other options must be accessed through this.
    #
    # @return [{::Symbol => ::Object}]
    attr_reader :options

    # The forms that are defined on this configuration instance.
    #
    # @return [Set<Configure::Form>]
    attr_reader :forms

    # @!method [](key)
    #   Sets a key on the options.  This gets an option that is used for all
    #   processors on the options.
    #
    #   @param key [::Symbol, ::String] The key.
    #   @return [::Object]
    # @!method []=(key, value)
    #   Sets a key on the options.  This sets an option that is used for all
    #   processors on the options.
    #
    #   @param key [::Symbol, ::String] The key.
    #   @param value [::Object] The value.
    #   @return [::Object]
    # @!method fetch(key, default = CANARY, &block)
    #   Fetches a value at the given key, or provides a default if the key
    #   doesn't exist.  If both a block and a default argument are given,
    #   the block form takes precedence.
    #
    #   @overload fetch(key)
    #     Attempts to retrieve a value at the given key.  If there is no
    #     key-value pair at the given key, it raises an error.
    #
    #     @raise [KeyError] if the key isn't on the options.
    #     @param key [::Symbol, ::String] The key.
    #     @return [::Object] The value.
    #
    #  @overload fetch(key, default)
    #    Attempts to retrieve a value at the given key.  If there is no
    #    key-value pair at the given key, it returns the value given by
    #    `default`.
    #
    #    @param key [::Symbol, ::String] The key.
    #    @param default [::Object] The default value.
    #    @return [::Object] The value, or the default value if there isn't
    #      one.
    #
    #   @overload fetch(key, &block)
    #     attempts to retrieve a value at the given key.  If there is no
    #     key-value pair at the given key, it yields.
    #
    #     @yield if there is no corresponding key-value pair.
    #     @param key [::Symbol, ::String] The key.
    #     @return [::Object] The value, or the result of the block if there
    #       isn't one.
    delegate [:[], :fetch] => :options

    # Initializes the configure instance.
    #
    # @param root [::String, ::Pathname] The root for the project.  This is
    #   used to determine the correct paths for the output directory, the
    #   sources directory, and the templates directory.
    def initialize(root = Dir.pwd)
      root = ::Pathname.new(root)
      @options = { root: root, sources: PathSet.new, templates: PathSet.new }
      @forms = ::Set.new
      default_paths
    end

    # Retrieves the root path.  This is where all of the other directories
    # should be located, and where the configuration file should be
    # located.
    #
    # @return [::Pathname]
    def root
      fetch(:root)
    end

    # Retrieves the output path.  This is where the outputs for all of the forms
    # should be located.
    #
    # @return [::Pathname]
    def output
      fetch(:output) { root / "output" }
    end

    # Retrieves the source path.  This is where the sources for all of the
    # documents in the Brandish project are located.
    #
    # @return [PathSet]
    def sources
      fetch(:sources)
    end

    # Retrieves the templates path.  This is where all of the templates for
    # all of the forms should be located.
    #
    # @return [PathSet]
    def templates
      fetch(:templates)
    end

    # Given a set of forms to build, it yields blocks that can be called to
    # build a form.
    #
    # @param which [::Symbol, <::Symbol>] If this is `:all`, all of the forms
    #   available are built; otherwise, it only builds the forms whose names
    #   are listed.
    # @yield [build] Yields for each form that can be built.
    # @yieldparam build [::Proc<void>] A block that can be called to build
    #   a form.
    # @return [void]
    def build(which = :all)
      return to_enum(:build, which) unless block_given?
      select_forms(which).each { |f| yield proc { f.build(self) } }
    end

    # Given a set of forms to build, it yields blocks that can be called to
    # build a form.
    #
    # This first clears the cache for file nodes.
    #
    # @param which [::Symbol, <::Symbol>] If this is `:all`, all of the forms
    #   available are built; otherwise, it only builds the forms whose names
    #   are listed.
    # @yield [build] Yields for each form that can be built.
    # @yieldparam build [::Proc<void>] A block that can be called to build
    #   a form.
    # @return [void]
    def build!(which = :all)
      return to_enum(:build!, which) unless block_given?
      @_roots = nil
      select_forms(which).each { |f| yield proc { f.build(self) } }
    end

    # A cache for all of the root nodes.  This is a regular hash; however, upon
    # attempt to access an item that isn't already in the hash, it first
    # parses the file at that item, and stores the result in the hash, returning
    # the root node in the file.  This is to cache files so that they do not
    # get reparsed multiple times.
    #
    # @return [{::Pathname => Parser::Root}]
    def roots
      @_roots ||= ::Hash.new do |h, k|
        h[k] = nil
        h[k] = parse_from(k)
      end
    end

    # Parses a file.  This bypasses the cache.
    #
    # @param path [::Pathname] The path to the actual file.  This should
    #   respond to `#read`.  If this isn't a pathname, the short should be
    #   provided.
    # @param short [::String] The short name of the file.  This is used for
    #   location information.
    # @return [Parser::Root]
    def parse_from(path, short = path.relative_path_from(root))
      Parser.new(Scanner.new(path.read, short, options).call).call
    end

  private

    def default_paths
      sources <<
        File.expand_path("../../../defaults/source", __FILE__) <<
        (root / "source")
      templates <<
        File.expand_path("../../../defaults/templates", __FILE__) <<
        (root / "templates")
    end

    def select_forms(which)
      which = @forms.map(&:name) if which == :all || !which.is_a?(::Array) ||
                                    which.empty?
      which = which.to_set
      @forms.select { |f| which.include?(f.name) }
    end
  end
end
