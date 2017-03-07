# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/all/literal"
require "brandish/processors/all/verify"

module Brandish
  module Processors
    # Processors designed for use with all formats.  This module does not
    # implement the {Common} processors, since the common processors can be
    # format-dependant.  All processors in this module are defined on the
    # `:all` special format.
    module All
    end
  end
end
