# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        # "Vanilla" scripting engines.  This just performs copying, and
        # does not modify the contents of the styles at all.
        #
        # Engines:
        #
        # - `"file"` - A command.  Takes a file, and copies it over to the
        #   destination, based on the values given in `#load_file_paths`.
        # - `"remote"`, `"remote-file"` - A command.  Takes a URI (supports 
        #   `http`, `https`, and `ftp`), and outputs the directory into the
        #   `"output"` pair (or a uri path assumed from the URI).
        # - `"inline"` - A block.  This performs {Parser::Node::Root#flatten}
        #   on the body, and pushes the result as an inline style.
        # - `"remote-inline"` - A command.  Similar to `"remote"`; however,
        #   this takes the remote styles as an inline style.
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
