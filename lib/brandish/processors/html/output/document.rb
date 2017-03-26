# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Output < Common::Output
        # A "document."  This contains meta information for the document,
        # such as the title, author, description, styles, and scripts that
        # are used to set up the HTML document.
        #
        # @api private
        class Document
          # The title of the document.  This is used for the `<title>` tag.
          #
          # @return [::String, nil]
          attr_accessor :title

          # The author for the document.  This is used for a `<meta>` tag.
          #
          # @return [::String, nil]
          attr_accessor :author

          # The description of the document.  This is used for a `<meta>` tag.
          #
          # @return [::String, nil]
          attr_accessor :description

          # Initialize the document.
          def initialize
            @title = ""
            @author = ""
            @description = ""
            @styles = []
            @scripts = []
          end

          # Adds a given style with the given type.  The type is the kind of
          # style it is; this should be either one of `:inline` or `:linked`.
          #
          # @param type [::Symbol] The style type.
          # @param content [::String] The contents of the style.  For an
          #   inline style, this is the stylesheet itself; for a linked
          #   style, this is the link to the stylesheet.
          # @return [self]
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

          # Adds a given script with the given type.  The type of the kind of
          # script it is; this should be either one of `:inline` or `:linked`.
          #
          # @param type [::Symbol] The style type.
          # @param content [::String] The contents of the script.  For an
          #   inline style, this is the script it self; for a linked script,
          #   this is the link to the script.
          # @return [self]
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

          # Adds an inline style.
          #
          # @see #add_style
          # @param content [::String] The stylesheet itself.
          # @return (see #add_style)
          def add_inline_style(content)
            add_style(:inline, content)
          end

          # Adds an linked style.
          #
          # @see #add_style
          # @param content [::String] The link to the stylesheet.
          # @return (see #add_style)
          def add_linked_style(content)
            add_style(:linked, URI.escape(content.to_s))
          end

          # Adds an inline script.
          #
          # @see #add_script
          # @param content [::String] The script itself.
          # @return (see #add_script)
          def add_inline_script(content)
            add_script(:inline, content)
          end

          # Adds an linked script.
          #
          # @see #add_script
          # @param content [::String] The link to the script.
          # @return (see #add_script)
          def add_linked_script(content)
            add_script(:linked, URI.escape(content.to_s))
          end

          # The data from this document.  This is used to pass all of the
          # proper information to the templating library.
          #
          # @return [::Object]
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
