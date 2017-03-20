# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Common::Style
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
            sass_options = { load_paths: style_load_paths.to_a }
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
            sass_options = { syntax: syntax, load_paths: style_load_paths.to_a }
            engine = ::Sass::Engine.new(@body.flatten, sass_options)
            @context[:document].add_inline_style(engine.render)
          end
        end
      end
    end
  end
end
