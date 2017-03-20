# encoding: utf-8
# frozen_string_literal: true

module Brandish
  # Markup modules for use with the {Processors::Common::Markup} processor.
  # This is only to provide certain integrations with Brandish.
  module Markup
    autoload :Redcarpet, "brandish/markup/redcarpet"
  end
end
