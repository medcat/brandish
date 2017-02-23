
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
        expect(:":")
        expect(:"}")

        fail NotImplementedError
      end

      def parse_document_text
        fail NotImplementedError
      end
    end
  end
end
