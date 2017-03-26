# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Common::Asset
        # "Vanilla" stylesheet engines.  This just performs copying, and
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
          Style.engine "file", :command, :style_file
          Style.engine "remote", :command, :style_file_remote
          Style.engine "inline", :block, :style_inline
          Style.engine "remote-file", :command, :style_file_remote
          Style.engine "remote-inline", :command, :style_inline_remote

        private

          def style_inline_remote
            uri = URI(load_asset_file)
            file = open(uri)
            content = file.read
            file.close

            @context[:document].add_inline_style(content)
          end

          def style_file_remote
            uri = URI(load_asset_file)
            file = open(uri)
            asset_path = @pairs.fetch("output") { uri_path(uri) }
            output_path = output_assets_path / asset_path
            output_path.dirname.mkpath
            link_path = output_path.relative_path_from(@context.configure.output)
            output = output_path.open("wb")
            ::IO.copy_stream(file, output)
            [file, output].each(&:close)

            @context[:document].add_linked_style(link_path)
          end

          def style_inline
            @context[:document].add_inline_style(@body.flatten)
          end

          def style_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            src, dest = paths[:file].open("rb"), paths[:out].open("wb")
            ::IO.copy_stream(src, dest)
            [src, dest].each(&:close)

            @context[:document].add_linked_style(paths[:src])
          end
        end
      end
    end
  end
end
