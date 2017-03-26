# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Processors
    module HTML
      # A "group."  This is used for grouping together elements for styling,
      # like the "div" element in HTML.  This uses `div` as one of the
      # element names, but that doesn't mean that it includes all of the same
      # attributes.  This accepts the `"class"`, `"id"`, and `"name"` headers.
      #
      # @see Common::Group
      class Group < Common::Group
        include Processor::Block
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper
        register %i(html group) => self
        self.names = %i(group g div)

        # Creates a div element with the proper class and id values.  This
        # currently ignores the name value.
        #
        # @return [::String]
        def perform
          html.div(raw(accepted_body), class: class_value, id: id_value).to_s
        end
      end
    end
  end
end
