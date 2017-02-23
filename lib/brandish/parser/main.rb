
module Brandish
  class Parser
    module Main
      def parse_document
        body = collect(:EOF) { parse_document_element }
        Parser::Node.new(:root, body)
      end

      def parse_document_element
        case peek.kind
        when :"{"
          parse_document_command
        else
          parse_document_text
        end
      end

      def parse_document_command
        expect(:"{")
        case peek.kind
        when :":"
          parse_document_command_definition
        when :"."
          parse_document_command_block
        else
          error([:":", :"."])
        end
      end

      def parse_document_command_definition
        expect(:":")
        arguments = collect(:"}") { parse_document_element }
        expect(:"}")

        Parser::Node.new(:definition, arguments)
      end

      def parse_document_command_block
        expect(:".")
        arguments = collect(:"}") { parse_document_command_block_argument }
        expect(:"}")

        Parser::Node.new(:block, arguments)
      end

      def parse_document_command_block_argument
        expect([:SPACE, :LINE]) while peek?([:SPACE, :LINE])
        key = parser_document_text
        expect([:SPACE, :LINE]) while peek?([:SPACE, :LINE])
        expect(:=)
        expect([:SPACE, :LINE]) while peek?([:SPACE, :LINE])
        value = parser_document_text

        Parser::Node.new(:block_argument, [key, value])
      end

      def parse_document_text
        Parser::Node.new(:text, expect([:TEXT, :SPACE, :LINE, :ESCAPE]))
      end
    end
  end
end
