# encoding: utf-8
# frozen_string_literal: true

require "mustache"
require "brandish/processors/html/output/document"

module Brandish
  module Processors
    module HTML
      class Output < Common::Output
        register %i(html output) => self

        def setup
          super

          @document = @context[:document] = Document.new
          @document.title = @context.configure.root.basename.to_s
        end

      private

        def find_path
          @options.fetch(:path) do
            directory = @options.fetch(:directory, @context.configure.output)
            file = @options.fetch(:file) do
              ::Pathname.new(@context.form.entry).sub_ext(".html")
            end

            directory / file
          end
        end

        def template_data
          @document.data.merge("content" => @root.flatten)
        end
      end
    end
  end
end
