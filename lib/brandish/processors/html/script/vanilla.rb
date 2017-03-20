# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Style
        module Vanilla
          Script.engine "inline", :block, :script_inline
          Script.engine "file", :command, :script_file

        private

          def script_inline
            @context[:document].add_inline_script(@body.flatten)
          end

          def script_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            src, dest = paths[:file].open("rb"), paths[:out].open("wb")
            ::IO.copy_stream(src, dest)
            [src, dest].each(&:close)

            @context[:document].add_linked_script(paths[:src])
          end
        end
      end
    end
  end
end
