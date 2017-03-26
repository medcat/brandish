# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        # "Vanilla" scripting engines.  This just performs copying, and
        # does not modify the contents of the script at all.
        #
        # Engines:
        #
        # - `"file"` - A command.  Takes a file, and copies it over to the
        #   destination, based on the values given in `#load_file_paths`.
        # - `"remote"`, `"remote-file"` - A command.  Takes a URI (supports
        #   `http`, `https`, and `ftp`), and outputs the directory into the
        #   `"output"` pair (or a uri path assumed from the URI).
        # - `"inline"` - A block.  This performs {Parser::Node::Root#flatten}
        #   on the body, and pushes the result as an inline script.
        # - `"remote-inline"` - A command.  Similar to `"remote"`; however,
        #   this takes the remote scripts as an inline script.
        # - `"link"` - A command.  Similar to `"remote"`; however, it does not
        #   copy down the remote script.
        module Vanilla
          Script.engine "file", :command, :script_file
          Script.engine "remote", :command, :script_file_remote
          Script.engine "inline", :block, :script_inline
          Script.engine "remote-inline", :command, :script_inline_remote
          Script.engine "link", :command, :script_link

        private

          def script_inline_remote
            uri = URI(load_asset_file)
            file = open(uri)
            content = file.read
            file.close

            @context[:document].add_inline_script(content)
          end

          def script_file_remote
            uri = URI(load_asset_file)
            file = open(uri)
            asset_path = @pairs.fetch("output") { uri_path(uri) }
            output_path = output_assets_path / asset_path
            output_path.dirname.mkpath
            link_path = output_path.relative_path_from(@context.configure.output)
            output = output_path.open("wb")
            ::IO.copy_stream(file, output)
            [file, output].each(&:close)

            @context[:document].add_linked_script(link_path)
          end

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

          def script_link
            @context[:document].add_linked_script(load_asset_file)
          end
        end
      end
    end
  end
end
