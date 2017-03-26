# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/common/asset/paths"

module Brandish
  module Processors
    module Common
      # Allows assets to be included in the documents.  This is similar to the
      # markup processor in that it uses a concept of _engines_ in order to
      # power different kinds of assets.
      #
      # Options:
      #
      # - `:asset_load_paths` - Optional.  The load paths for the asset
      #   processor.  These are used to resolve the asset file names, and are
      #   passed directly to the {PathSet} created.
      #
      # Pairs:
      #
      # - `"src"`, `"file"`, `"name"`, or `"link"` - Required.  At least one
      #   of these options are required.  They all perform the same function.
      #   This defines the name or path of the asset to add or process.
      # - `"type"` - Required.  The type of the asset to process.  This defines
      #   how the asset is handled.
      #
      # @abstract
      #   Implement engines using {.engine} and register the processor using
      #   {.register}.
      class Asset < Processor::Base
        include Processor::Command
        include Processor::Block
        include Asset::Paths
        pairs :src, :file, :name, :link, :type

        # The engines defined for the subclass.  This should not be used on the
        # parent class ({Common::Asset}).  This returns a key-value pair for
        # the engines.  The key is the "name" of the format; this is used for
        # the `"type" pair.  The value is a tuple containing two values:
        # the syntax of the block/command options, and a proc that takes no
        # arguments to include the asset.
        #
        # @api private
        # @return [{::String => (::Symbol, ::Proc<void>)}]
        def self.engines
          @_engines ||= {}
        end

        # Defines an engine for use on the subclass.  This should not be used
        # on the parent class ({Common::Asset}).  This takes the name of the
        # engine, the syntax for the engine, and the processor to
        # perform the asset processor.
        #
        # If both a third argument and a block are provided, then the block
        # takes precedence.
        #
        # @api private
        # @param name [::String] The name of the engine.  This is used for the
        #   value of the `"type"` pair.
        # @param syntax [::Symbol] The syntax type for the engine.  If it's
        #   `:command`, the element should be a command node.  If it's
        #   `:block`, the element should be a block node.  If it's `:all` or
        #   `:_`, it can be either.
        # @param symbol [::Symbol, nil] The method to call to add the
        #   asset.
        # @return [void]
        def self.engine(name, syntax, symbol = nil, &block)
          block ||= proc { send(symbol) }
          engines[name.to_s] = [syntax, block]
        end

        # Adds the asset.  If the engine cannot be found, it returns
        # `nil`, effectively ignoring the node.  This helps enable cross-format
        # support without the use of `if` nodes.  This always returns `nil`,
        # because outputting the asset is up to the {Common::Output}
        # processor for the inclusion of the asset.
        #
        # @return [nil]
        def perform
          return unless (engine = find_engine)
          syntax, block = engine
          fail_syntax_error(syntax) if syntax == :block && !@body ||
                                       syntax == :command && @body
          instance_exec(&block)
          nil
        end

        # Finds the value for the asset file.  This tries four different
        # pairs before giving up: `"src"`, `"file"`, `"name"`, and `"link"`.
        # If none of these could be found, it fails.
        #
        # @return [::String]
        def load_asset_file
          file = @pairs["src"] || @pairs["file"] || @pairs["name"] ||
                 @pairs["link"]
          return file if file
          fail PairError.new("Expected one of src, file, name, or link, " \
            "got nothing", @node.location)
        end

      private

        def fail_syntax_error(syntax)
          fail ElementSyntaxError.new("Incorrect syntax used for " \
            "#{@pairs['type']} (a #{syntax} type)", @node.location)
        end

        def find_engine
          type = @pairs.fetch("type")
            .gsub(/(?<=[\w])([A-Z])/) { |m| "-#{m}" }
            .downcase
          return [] unless self.class.engines.key?(type)
          self.class.engines.fetch(type)
        end
      end
    end
  end
end
