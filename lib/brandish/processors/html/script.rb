# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/html/script/babel"
require "brandish/processors/html/script/coffee"
require "brandish/processors/html/script/vanilla"

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        register %i(html script) => self
        self.names = %i(script scripting)

        include Script::Babel
        include Script::Coffee
        include Script::Vanilla

        # (see Common::Asset::Paths#asset_kind_path)
        def asset_kind_path
          "assets/scripts"
        end

        # (see Common::Asset::Paths#asset_kind_extension)
        def asset_kind_extension
          ".js"
        end
      end
    end
  end
end
