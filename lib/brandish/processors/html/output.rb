# encoding: utf-8
# frozen_string_literal: true

require "hanami/helpers/html_helper"
require "hanami/helpers/escape_helper"

module Brandish
  module Processors
    module HTML
      class Output < Processor::Base
        register %i(html output) => self
        include Hanami::Helpers::HtmlHelper
        include Hanami::Helpers::EscapeHelper
        attr_reader :context

        def self.template_path
          Pathname.new("../../../../../templates/html/skeleton.html")
                  .expand_path(__FILE__)
        end

        def initialize(*)
          super
          @file = @options.fetch(:path) do
            @options.fetch(:directory) { @context.configure.output } /
              @options.fetch(:file, "index.html")
          end

          @template = @options.fetch(:template, :auto)

          @context[:html_styles] = []
          @context[:html_scripts] = []
          @context[:html_title] = @context.configure.root.basename.to_s
          @context[:html_container] = "container"
          @file.dirname.mkpath
          @io = []
        end

        def process_text(node)
          @io << if @context.configure.options[:output_debug]
                   "[{#{node.location}}#{node.value}]"
                 else
                   node.value
                 end

          nil
        end

        def postprocess
          @file.open("w") { |f| f.write(document(@io)) }
        end

        def document(io)
          "<!DOCTYPE html>\n" + html.tag(:html) do
            head do
              title context[:html_title]
              context[:html_styles].each do |data|
                if data.key?(:inline)
                  style(raw(data[:inline]))
                elsif data.key?(:src)
                  link href: data[:src], rel: "stylesheet"
                else
                  fail KeyError, "Could not find either key `:inline` or `:src`"
                end
              end
            end

            body { div(raw(io.join), class: context[:html_container]) }
            context[:html_scripts].each do |s|
              script src: s[:src]
            end
          end.to_s
        end
      end
    end
  end
end
