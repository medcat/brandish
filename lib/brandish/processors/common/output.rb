# encoding: utf-8
# frozen_string_literal: true

require "liquid"

module Brandish
  module Processors
    module Common
      # Outputs the result of processing the document.  Without this processor,
      # the document is not output, and most other processors have no effect.
      class Output < Processor::Base
        # Sets up the path and template for the output processor.  It first
        # attempts to find the output path, creating the directory to that
        # path if needed.  Then, it builds up the template that will later then
        # be used to render the data.
        #
        # @see Processor::Base#setup
        # @return [void]
        def setup
          super

          @path = find_path.tap { |p| p.dirname.mkpath }
          template_option = @options.fetch(:template, @context.form.format.to_s)
          template_path = ::Pathname.new(template_option).sub_ext(".liquid")
          template_full = @context.configure.templates.find(template_path)
          @template = ::Liquid::Template.parse(template_full.read)
        end

        # Postprocess the result of processing.  The given root should only
        # have text children, and should respond successfully to `#flatten`.
        # This will render the template, and write it out to the value given
        # in `@path`.
        #
        # @see Processor::Base#postprocess
        # @param root [Parser::Node::Root]
        # @return [void]
        def postprocess(root)
          @root = root
          value = @template.render!(template_data, strict_variables: true)
          @path.open("wb") { |f| f.write(value) }
        end

        # Finds the output path.
        #
        # @abstract
        # @return [::Pathname]
        def find_path
          fail ProcessorNotImplementedError,
            "Please implement #{self.class}#find_path"
        end

        # A hash of data to pass to the template for rendering.  The keys
        # should always be strings.
        #
        # @abstract
        # @return [{::String => ::Object}]
        def template_data
          fail ProcessorNotImplementedError,
            "Please implement #{self.class}#template_data"
        end
      end
    end
  end
end
