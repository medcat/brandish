# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/html/style/highlight"
require "brandish/processors/html/style/sass"
require "brandish/processors/html/style/vanilla"

module Brandish
  module Processors
    module HTML
      class Style < Common::Asset
        register %i(html style) => self
        self.names = %i(style styling)

        include Style::Highlight
        include Style::Sass
        include Style::Vanilla
        
        # (see Common::Asset::Paths#asset_kind_path)
        def asset_kind_path
          "assets/styles"
        end

        # (see Common::Asset::Paths#asset_kind_extension)
        def asset_kind_extension
          ".css"
        end
      end
    end
  end
end
