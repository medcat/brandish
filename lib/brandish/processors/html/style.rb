# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Style < Processor::Base
        include Processor::Command
        include Processor::Block
        register %i(html style) => self

        def perform
          case @pairs.fetch("type")
          when "inline"      then perform_inline_styling
          when "inline-sass" then perform_inline_sass_styling(:sass)
          when "inline-scss" then perform_inline_scss_styling(:scss)
          when "file"        then perform_file_styling
          when "file-sass"   then perform_file_sass_styling
          when "highlight"   then perform_highlight_styling
          else
            fail ArgumentError, "Unknown style type `#{@pairs['type']}"
          end

          nil
        end

        def perform_inline_styling
          @context[:html_styles] << { inline: extract_body }
        end

        def perform_inline_sass_styling(syntax)
          require "sass"
          value = extract_body
          sass_options = { syntax: syntax, load_paths: sass_load_paths }
          engine = ::Sass::Engine.new(value, sass_options)
          @context[:html_styles] << { inline: engine.render }
        end

        def perform_file_styling
          paths = load_file_paths
          paths[:out].dirname.mkpath
          src, dest = paths[:file].open("rb"), paths[:out].open("wb")
          IO.copy_stream(src, dest)
          [src, dest].each(&:close)

          @context[:html_styles] << { src: paths[:src] }
        end

        def perform_file_sass_styling
          paths = load_file_paths
          paths[:out].dirname.mkpath
          dest = paths[:out].open("wb")
          sass_options = { load_paths: sass_load_paths }
          engine = ::Sass::Engine.for_file(paths[:file].to_s, sass_options)
          output = engine.render
          dest.write(output)
          dest.close

          @context[:html_styles] << { src: paths[:src] }
        end

        def perform_highlight_styling
          case @pairs.fetch("which")
          when "rouge"    then perform_rouge_highlight_styling
          when "pygments" then perform_pygments_highlight_styling
          else
            fail ArgumentError, "Unknown library name given"
          end
        end

        def perform_rouge_highlight_styling
          require "rouge"
          theme = @pairs.fetch("theme")
          options = { scope: ".highlight" }
          value = Rouge::Theme.find(theme).render(options)
          @context[:html_styles] << { inline: value }
        end

        def perform_pygments_highlight_styling
          require "pygments"
          theme = @pairs.fetch("theme")
          value = Pygments.css(".highlight", style: theme)
          @context[:html_styles] << { inline: value }
        end

      private

        def source_styles_path
          @context.configure.source / "assets" / "styles"
        end

        def output_styles_path
          @context.configure.output / "assets" / "styles"
        end

        def sass_load_paths
          @_sass_load_paths ||= [
            source_styles_path, @context.configure.source,
            *@context.configure.options.fetch(:sass_load_paths, [])
]
        end

        def load_file_paths
          fail ArgumentError, "Requires command syntax for file styling" \
            if @body
          # The file provided to us by the user.
          file = @pairs.fetch("file")
          # The directory the file is in.  This is checked against the
          # sass_load_paths.
          (directory = sass_load_paths.find { |d| (d / file).exist? }) ||
            (fail NameError, "Could not find css file `#{file}`")
          # The full path to the file itself.
          path = directory / file
          output_path = @context.configure.output
          # The relative path from the source asset directory.
          asset_path = path.relative_path_from(source_styles_path)
          # The "raw" output path.
          raw_output_path = @pairs.fetch("output", asset_path.sub_ext(".css"))
          # The actual output path of the file.
          file_output_path = output_styles_path / raw_output_path
          src_output_path = file_output_path.relative_path_from(output_path)

          { file: path, out: file_output_path, src: src_output_path }
        end

        def extract_body
          fail ArgumentError, "Requires block syntax for inline styling" \
            unless @body
          @body.flatten
        end
      end
    end
  end
end
