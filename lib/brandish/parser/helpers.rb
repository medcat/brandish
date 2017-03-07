# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Parser
    # Helpers for the parser class.  This is used to help with the parsing
    # process.  None of these should be used publicly.
    module Helpers
      # Peeks to the next token.
      #
      # @return [Scanner::Token]
      def peek
        @tokens.peek
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity

      # "Collects" a set of nodes until a terminating token.  It yields
      # until the peek is the token.
      #
      # @param ending [::Symbol] The terminating token.
      # @param join [::Symbol, nil] The token that joins each of the
      #   children.  This is the comma between arguments.
      # @return [::Array] The collected nodes from the yielding process.
      def collect(ending, join = nil)
        children = []
        join = Array(join).flatten if join
        ending = Array(ending).flatten if ending
        return [] if (ending && peek?(ending)) || (!ending && !join)

        children << yield
        until (ending && peek?(ending)) || (!ending && !peek?(join))
          expect(join) if join
          children << yield
        end

        children
      end

      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity

      # Checks to see if any of the given kinds includes the next token.
      #
      # @param tokens [<::Symbol>] The possible kinds.
      # @return [::Boolean]
      def peek?(tokens)
        tokens.include?(peek.kind)
      end

      # Shifts to the next token, and returns the old token.
      #
      # @return [Scanner::Token]
      def shift
        @tokens.next
      end

      # Sets up an expectation for a given token.  If the next token is
      # an expected token, it shifts, returning the token; otherwise,
      # it {#error}s with the token information.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [Scanner::Token]
      def expect(tokens)
        return shift if peek?(tokens)
        error(tokens)
      end

      # Errors, noting the expected tokens, the given token, the location
      # of given tokens.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [void]
      def error(tokens)
        fail ParseError.new("Unexpected #{peek.kind.inspect}, expected one of" \
          " #{tokens.map(&:inspect).join(', ')} at #{peek.location}",
          peek.location)
      end
    end
  end
end
