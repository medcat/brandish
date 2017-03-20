# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/common/group"
require "brandish/processors/common/header"
require "brandish/processors/common/markup"
require "brandish/processors/common/output"
require "brandish/processors/common/style"

module Brandish
  module Processors
    # Common processors.  These are processors that are required to be
    # implemented for all formats, but are processors that can be implemented
    # as an {All} processor.
    #
    # @abstract
    module Common
    end
  end
end
