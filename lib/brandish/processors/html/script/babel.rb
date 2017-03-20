# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        module Babel
          Script.engine "babel-inline", :block, :script_babel_inline
          Script.engine "babel-file", :command, :script_babel_file

        private

          def script_babel_inline
            parsed = ::Babel::Transpiler.transform(@body.flatten)
            @context[:document].add_inline_script(parsed["code"])
          end

          def script_babel_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            parsed = ::Babel::Transpiler.transform(paths[:file].read)
            paths[:out].write(parsed["code"])

            @context[:document].add_linked_script(paths[:src])
          end
        end
      end
    end
  end
end
