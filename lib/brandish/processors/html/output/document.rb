# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Output < Common::Output
        class Document
          attr_accessor :title
          attr_accessor :author
          attr_accessor :description

          def initialize
            @title = ""
            @author = ""
            @description = ""
            @styles = []
            @scripts = []
          end

          def add_style(type, content)
            inline = type == :inline
            linked = type == :linked

            @styles << {
              "inline?" => inline,
              "linked?" => linked,
              "content" => content.to_s
            }
            self
          end

          def add_script(type, content)
            inline = type == :inline
            linked = type == :linked

            @scripts << {
              "inline?" => inline,
              "linked?" => linked,
              "content" => content.to_s
            }
            self
          end

          def add_inline_style(content)
            add_style(:inline, content)
          end

          def add_linked_style(content)
            add_style(:linked, URI.escape(content.to_s))
          end

          def add_inline_script(content)
            add_script(:inline, content)
          end

          def add_linked_script(content)
            add_script(:linked, URI.escape(content.to_s))
          end

          def data
            { "title" => @title, "author" => @author,
              "description" => @description,
              "styles" => @styles, "scripts" => @scripts }.freeze
          end
        end
      end
    end
  end
end
