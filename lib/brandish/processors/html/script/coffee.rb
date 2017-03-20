# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        module Coffee
          Script.engine "coffee-inline", :block, :script_coffee_inline
          Script.engine "coffee-file", :command, :script_coffee_file

        private

          def script_coffee_inline
            parsed = ::CoffeeScript.compile(@body.flatten)
            @context[:document].add_inline_script(parsed)
          end

          def script_coffee_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            paths[:out].write(::CoffeeScript.compile(paths[:file].read))

            @context[:document].add_linked_script(paths[:src])
          end
        end
      end
    end
  end
end
