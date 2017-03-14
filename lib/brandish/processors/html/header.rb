# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"

module Brandish
  module Processors
    module HTML
      class Header < Processors::Common::Header
        include Hanami::Helpers::HtmlHelper
        register %i(html header) => self

        TAGS = %i(h1 h2 h3 h4 h5 h6).freeze

        def header_render
          html.tag(TAGS.fetch(header_level), header_value, id: header_id,
            class: @pairs.fetch("class", ""))
        end
      end
    end
  end
end
