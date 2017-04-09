# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Processors
    module HTML
      class ContentsTable < Processor::Base
        include Processor::Command
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper
        register %i(html contents_table) => self
        self.names = %i(contents_table contents-table table-of-contents toc)

        def perform
          _context = @context

          html.ul(class: "contents") do
            _context[:headers].map do |header|
              li(a(raw(header[:value]), href: "##{header[:id]}"),
                class: "contents-item contents-item-#{header[:level]}")
            end
          end.to_s
        end
      end
    end
  end
end
