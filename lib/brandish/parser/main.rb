# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    # The main parser for the document.  This constructs a tree
    # of nodes that can be used to represent the original
    # document.
    module Main
      # Parses the overall document.  This parses a sequence of
      # elements until it reaches the `EOF` token.
      #
      # @return [Parser::Node]
      def parse_document
        body = collect(EOF_SYMBOL) { parse_document_element }
        expect(EOF_SYMBOL)
        Node::Root.new(children: body)
      end

      alias_method :parse_root, :parse_document

      # Parses a single element in the docuemnt.  If the next token is a
      # less-than sign, it calls {#parse_document_meta}; otherwise, it calls
      # {#parse_document_text}.
      #
      # @return [Node] The node for the element.
      def parse_document_element
        peek?(LESS_THAN_SYMBOL) ? parse_document_meta : parse_document_text
      end

      # parses a "meta" element from the document.  In this sense, it is
      # anything that doesn't correspond 1-to-1 to the destination document.
      # If the next token after the less-than sign is an at-sign, it calls
      # {#parse_document_command}; otherwise, it calls {#parse_document_block}.
      #
      # @return [Node]
      def parse_document_meta(start = expect(LESS_THAN_SYMBOL))
        name = expect(TEXT_SYMBOL)
        parse_skip_space
        arguments = collect(SLASH_OR_GREATER_THAN_SYMBOL) { parse_document_command_argument }
        if peek?(SLASH_SYMBOL)
          parse_document_command(start, name, arguments)
        else
          parse_document_block(start, name, arguments)
        end
      end

      # Parses a document command.  This is essentially a message to the
      # compiler about the document, to alter how the document is processed.
      #
      #     command ::= '<' TEXT *command-argument '/' '>'
      #
      # @param start [Scanner::Token] The starting element for the command.
      # @param name [Scanner::Token] The name of the command.
      # @param arguments [<Node::Pair>] The arguments to the command.
      # @return [Node::Command] The command node.
      def parse_document_command(start, name, arguments)
        expect(SLASH_SYMBOL)
        stop = expect(GREATER_THAN_SYMBOL)

        Node::Command.new(name: name, arguments: arguments,
          location: start.location.union(stop.location))
      end

      # Parses a document command argument.  This is an argument to a command.
      # All arguments are key-value pairs.
      #
      #     command-argument ::= *space command-argument-key *space '=' *space command-argument-value *space
      #
      # @return [Node::Pair] The command argument.
      def parse_document_command_argument
        parse_skip_space
        key = parse_document_command_argument_key
        parse_skip_space
        expect(EQUAL_SYMBOL)
        parse_skip_space
        value = parse_document_command_argument_value
        parse_skip_space

        Node::Pair.new(key: key, value: value)
      end

      # The key for the command argument.
      #
      #     command-argument-key ::= TEXT
      #
      # @return [Scanner::Token]
      def parse_document_command_argument_key
        expect(TEXT_SYMBOL)
      end

      # The value for the command argument.  This can be either a string, or
      # a {Node::Text} with a single token.  If it's a string, it's parsed with
      # {#parse_document_string}; otherwise, it grabs one token that's valid
      # for a {Node::Text} node.
      #
      #     command-argument-value ::= string / TEXT
      #
      # @return [Node]
      def parse_document_command_argument_value
        if peek?(QUOTE_SYMBOL)
          parse_document_string
        else
          Node::Text.new(tokens: [expect(Node::Text::TOKENS)])
        end
      end

      # Parses a "block."  This is similar to a HTML tag in the sense that it
      # has a name and a body; however, blocks do not have any sort of
      # arguments to them.
      #
      #     block ::= '<' TEXT *command-argument '>' *element '</' TEXT '>'
      #
      # @param start [Scanner::Token] The starting element for the block.
      # @param name [Scanner::Token] The name of the block.
      # @param arguments [<Node::Pair>] The arguments to the block.
      # @return [Node::Block]
      def parse_document_block(start, name, arguments)
        expect(GREATER_THAN_SYMBOL)
        body = parse_document_block_body
        expect(SLASH_SYMBOL)
        match = expect(TEXT_SYMBOL)
        stop = expect(GREATER_THAN_SYMBOL)

        unless name.value == match.value
          fail ParseError.new("Unexpected #{match.value.inspect}, expected" \
            " #{name.value.inspect}", match.location)
        end

        Node::Block.new(name: name, body: body, arguments: arguments,
          location: start.location.union(body.location, match.location,
            stop.location, *arguments.map(&:location)))
      end

      # Parses the body of a block tag.  This keeps attempting to parse text
      # and meta tags until it encounters the phrase `</`, at which point it
      # will stop parsing and return to the parent.
      #
      # @return [Node::Root]
      def parse_document_block_body
        children = []
        loop do
          if peek?(LESS_THAN_SYMBOL)
            start = expect(LESS_THAN_SYMBOL)
            break if peek?(SLASH_SYMBOL)
            children << parse_document_meta(start)
          else
            children << parse_document_text
          end
        end

        Node::Root.new(children: children)
      end

      # Parses a "string."  This is a series of text encapulated by quotes.
      # Strings can contain more characters than just regular text, but right
      # now, strings are only used for command argument values.
      #
      #     string ::= '"' *(TEXT / SPACE / LINE / NUMERIC / ESCAPE / '<' / '>' / '=') '"'
      #
      # @return [Node::String]
      def parse_document_string
        start = expect(QUOTE_SYMBOL)
        children = collect(QUOTE_SYMBOL) { expect(Node::String::TOKENS) }
        stop = expect(QUOTE_SYMBOL)
        location = start.location.union(stop.location)

        Node::String.new(tokens: children, location: location)
      end

      # Parses a document for text.  This is just regular text tokens.  For a
      # list of tokens that are allowed, see {Node::Text::TOKENS}.
      #
      #     text ::= *(TEXT / SPACE / LINE / NUMERIC / ESCAPE / '/' / '"' / '=')
      #
      # @return [Node::Text]
      def parse_document_text
        children = [expect(Node::Text::TOKENS)]
        children << expect(Node::Text::TOKENS) while peek?(Node::Text::TOKENS)
        Node::Text.new(tokens: children)
      end

      # Skips over nodes as long as they're space nodes.
      #
      # @return [void]
      def parse_skip_space
        expect(SPACE_SYMBOLS) while peek?(SPACE_SYMBOLS)
      end

      # A set containing the kind symbol for a quote.
      #
      # @return [::Set<::Symbol>]
      QUOTE_SYMBOL = ::Set[:'"']

      # A set containing the kind symbol for an equal sign.
      #
      # @return [::Set<::Symbol>]
      EQUAL_SYMBOL = ::Set[:'=']

      # A set containing the kind symbol for a less than symbol.
      #
      # @return [::Set<::Symbol>]
      LESS_THAN_SYMBOL = ::Set[:<]

      # A set containing the kind symbol for a greater than symbol.
      #
      # @return [::Set<::Symbol>]
      GREATER_THAN_SYMBOL = ::Set[:>]

      # A set containing the kind symbol for a forward slash symbol.
      #
      # @return [::Set<::Symbol>]
      SLASH_SYMBOL = ::Set[:/]

      # A set containing the kind symbols for a forward slash or a greater than
      # symbol.
      #
      # @return [::Set<::Symbol>]
      SLASH_OR_GREATER_THAN_SYMBOL = SLASH_SYMBOL | GREATER_THAN_SYMBOL

      # A set containing the kind symbols for a text symbol.
      #
      # @return [::Set<::Symbol>]
      TEXT_SYMBOL = ::Set[:TEXT]

      # A set containing the kind symbols for a space symbol.
      #
      # @return [::Set<::Symbol>]
      SPACE_SYMBOLS = ::Set[:SPACE, :LINE]

      # A set containing the kind symbols for a eof symbol.
      #
      # @return [::Set<::Symbol>]
      EOF_SYMBOL = ::Set[:EOF]
    end
  end
end
