# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Common::Style
        module Vanilla
          Style.engine "inline", :block, :style_inline
          Style.engine "file", :command, :style_file
          Style.engine "remote", :command, :style_file_remote
          Style.engine "remote-file", :command, :style_file_remote
          Style.engine "remote-inline", :command, :style_inline_remote

        private

          def style_inline_remote
            uri = URI(load_style_file)
            file = open(uri)
            content = file.read
            file.close

            @context[:document].add_inline_style(content)
          end

          def style_file_remote
            uri = URI(load_style_file)
            file = open(uri)
            asset_path = @pairs.fetch("output") { uri_path(uri) }
            output_path = output_styles_path / asset_path
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
