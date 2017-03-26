# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Common::Asset
        # A set of styling engines that provide access to Sass/SCSS.
        #
        # Engines:
        #
        # - `"sass"`, `"sass-file"`, `"scss"`, `"scss-file"` - A command.
        #   These take a file and processes it, and outputs it to the output
        #   path given by `#load_file_paths`.  There is no difference
        #   between any of these engine types - the engine assumes the actual
        #   syntax of the file from the file extension.
        # - `"sass-inline"` - A block.  This takes the block's contents,
        #   performs {Parser::Node::Root#flatten} on it, and processes the
        #   content as Sass.  This is then included as an inline stylesheet.
        # - `"scss-inline" - A block.  Similar to `"sass-inline"`, except it
        #   processes the content as SCSS.
        #
        # @note
        #   The libraries that these engines depend on are not required in
        #   by default; if any of these engines are used, the requisite
        #   libraries would have to be required by the `brandish.config.rb`
        #   file.
        module Sass
          Style.engine "sass", :command, :style_file_sass
          Style.engine "scss", :command, :style_file_sass
          Style.engine "sass-file", :command, :style_file_sass
          Style.engine "scss-file", :command, :style_file_sass
          Style.engine "sass-inline", :block, :style_inline_sass
          Style.engine "scss-inline", :block, :style_inline_scss

        private

          def style_file_sass
            paths = load_file_paths
            paths[:out].dirname.mkpath
            dest = paths[:out].open("wb")
            sass_options = { load_paths: asset_load_paths.to_a }
            engine = ::Sass::Engine.for_file(paths[:file].to_s, sass_options)
            output = engine.render
            dest.write(output)
            dest.close

            @context[:document].add_linked_style(paths[:src])
          end

          def style_inline_scss
            style_inline_sass(:scss)
          end

          def style_inline_sass(syntax = :sass)
            sass_options = { syntax: syntax, load_paths: asset_load_paths.to_a }
            engine = ::Sass::Engine.new(@body.flatten, sass_options)
            @context[:document].add_inline_style(engine.render)
          end
        end
      end
    end
  end
end
