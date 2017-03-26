# encoding: utf-8
# frozen_string_literal: true

require "liquid"
require "brandish/processors/html/output/document"

module Brandish
  module Processors
    module HTML
      # Outputs the result of processing the document.  Without this processor,
      # the document is not output, and most other processors have no effect.
      #
      # Options:
      #
      # - `:template` - Optional.  The name of the template to use.  This
      #   defaults to the format used.
      # - `:path` - Optional.  The full path, including the file name,
      #   to output the file.  This overwrites `:directory` and `:file`.
      #   Defaults to `:directory`/`:file`.
      # - `:directory` - Optional.  The directory to the file to output
      #   the file.  Overwritten by `:path`.  Defaults to the output path
      #   of the project.
      # - `:file` - Optional.  The name of the file to output to.  Overwritten
      #   by `:path`.  Defaults to the name of the entry file, with the
      #   extension substituted by `".html"`.
      #
      # @see Common::Output
      class Output < Common::Output
        register %i(html output) => self

        # Sets up the output processor.  This creates a {Document} and puts
        # it on the `:document` context option.
        #
        # @see Common::Output#setup
        # @return [void]
        def setup
          super

          @document = @context[:document] = Document.new
          @document.title = @context.configure.root.basename.to_s
        end

      private

        def find_path
          @options.fetch(:path) do
            directory = ::Pathname.new(@options.fetch(:directory, "."))
            file = @options.fetch(:file) do
              ::Pathname.new(@context.form.entry).sub_ext(".html")
            end

            directory.expand_path(@context.configure.output) / file
          end
        end

        def template_data
          @document.data.merge("content" => @root.flatten)
        end
      end
    end
  end
end
