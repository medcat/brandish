# encoding: utf-8
# frozen_string_literal: true

require "pathname"
require "brandish/configure/dsl/form"

module Brandish
  class Configure
    # The DSL for configuration files for Brandish.  This is used to construct
    # a configure object.
    class DSL
      # Creates a new DSL object with the given configuration object, and
      # yields it.
      #
      # @param configure [Configure] The configuration instance.
      # @return [DSL]
      def self.call(configure = Configure.new)
        DSL.new(configure).tap { |t| yield t }
      end

      # Creates a DSL object with the given configuration object.
      #
      # @param configure [Configure]
      def initialize(configure = Configure.new)
        @configure = configure
      end

      # Sets a given option key to a value.  The name is interned, making it
      # a symbol.
      #
      # @param name [::Symbol, #intern] The name of the option key.
      # @param value [::Object] The option value.
      # @return [void]
      def set(name, value)
        @configure.options[name.intern] = value
      end
      alias_method :[]=, :set

      # Retrives a given option key.  The name is interned, making it a symbol.
      #
      # @param name [::Symbol, #intern] The name of the option key.
      # @return [::Object] The option value.
      def get(name)
        @configure.options.fetch(name)
      end
      alias_method :[], :get

      # Sets the root path of the Brandish project.  This is where all of the
      # important files are located.  Very rarely should this be set to
      # anything other than `"."`.
      #
      # @param root [::String, ::Pathname] The new root.
      # @return [void]
      def root=(root)
        path = _expand_path(root, Dir.pwd)
        self[:root] = path
      end

      # Retrieves the root path of the Brandish project.  This is where all of
      # the important files are located.  Very rarely should this be set to
      # anything other than `"."`.
      #
      # @return [::Pathname] The full path to the root.
      def root
        self[:root]
      end

      alias_method :root_path=, :root=
      alias_method :root_path, :root

      # Sets the output directory of the Brandish project.  This is where all
      # of the outputs are placed.  This is normally `"./output"`.
      #
      # @param output [::String, ::Pathname] The path to the output directory.
      # @return [void]
      def output=(output)
        path = _expand_path(output, root)
        self[:output] = path
      end

      # Retrieves the output directory of the Brandish project.  This is where all
      # of the outputs are placed.  This is normally `"./output"`.
      #
      # @return [::Pathname] The full path to the output.
      def output
        self[:output]
      end

      alias_method :output_path=, :output=
      alias_method :output_path, :output

      # Retrives the source directories of the Brandish project.  This is where
      # all of the sources are located.  This is normally `"./source"`.
      #
      # @return [::Pathname] The full path to the sources.
      def sources
        self[:sources]
      end

      alias_method :source_paths, :sources

      # Retrieves the template directory of the Brandish project.  This is
      # where all of the templates are placed.  This is normally `"./template"`.
      #
      # @return [::Pathname] The full path to the template.
      def templates
        self[:templates]
      end

      alias_method :template_paths, :templates

      # Creates a new form for the configuration object.  This takes arguments
      # and a block.  The block is yielded the form instance.
      #
      # @see DSL::Form
      # @see Configure::Form
      # @param (see DSL::Form#instance)
      # @yield [form]
      # @return [void]
      def form(*arguments)
        instance = DSL::Form.new(*arguments)
        yield instance
        form = Configure::Form.new(*instance.data)
        @configure.forms << form
        form
      end

    private

      def _expand_path(path, directory)
        ::Pathname.new(path).expand_path(::Pathname.new(directory))
      end
    end
  end
end
