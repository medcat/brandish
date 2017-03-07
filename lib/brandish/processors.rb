# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/common"
require "brandish/processors/all"
require "brandish/processors/html"
require "brandish/processors/latex"

module Brandish
  # All of the available processors provided by Brandish by default are defined
  # under this module.  Under this module, there are a set of modules, all
  # pertaining to either a format, `All`, or `Common`.  `All` processors are
  # provided for all documents, regardless of format; `Common` processors are
  # always abstract, and define a set of processors that are required to be
  # implemented for all formats.  If a format does not provide a `Common`
  # processor, it is considered a bug.
  module Processors
    # All of the format modules under the {Processors} module.  This is
    # essentially all modules that aren't named `All` or `Common`.
    #
    # @return [<Module>]
    def self.format_modules
      (constants - [:All, :Common]).map { |c| Processors.const_get(c) }
    end

    # Checks if the given module provides the {Common} processors.
    # Essentially, it just checks if the module's constants are a subset
    # of the {Common}'s constants.
    #
    # @param mod [Module]
    # @return [Boolean]
    def self.module_provides_common?(mod)
      mod.constants <= Common.constants
    end

    # Checks if all of the {.format_modules} provide the {Common} processors,
    # using {.module_provides_common?}.  This should **always** return `true`.
    #
    # @return [Boolean]
    def self.formats_provide_common?
      format_modules.all? { |m| module_provides_common?(m) }
    end
  end
end
