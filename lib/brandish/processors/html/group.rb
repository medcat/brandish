# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Processors
    module HTML
      class Group < Common::Group
        include Processor::Block
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper
        register %i(html group) => self
        self.names = %i(group g)

        def perform
          html.div(raw(accepted_body), class: class_value, id: id_value).to_s
        end
      end
    end
  end
end
