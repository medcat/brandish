
module Brandish
  class Parser
    module Helpers
      # Peeks to the next token.  If peeking would cause a `StopIteration`
      # error, it instead returns the last value that was peeked.
      #
      # @return [Scanner::Token]
      def peek
        if next?
          @_last = @enum.peek
        else
          @_last
        end
      end

      # Checks if the next token exists.  It does this by checking for a
      # `StopIteration` error.  This is actually really slow, but there's
      # not much else I can do.
      #
      # @return [::Boolean]
      def next?
        @enum.peek
        true
      rescue StopIteration
        false
      end

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

      # Checks to see if any of the given types includes the next token.
      #
      # @param tokens [<::Symbol>] The possible types.
      # @return [::Boolean]
      def peek?(*tokens)
        tokens.include?(peek.type)
      end

      # Shifts to the next token, and returns the old token.
      #
      # @return [Scanner::Token]
      def shift
        @enum.next
      end

      # Sets up an expectation for a given token.  If the next token is
      # an expected token, it shifts, returning the token; otherwise,
      # it {#error}s with the token information.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [Scanner::Token]
      def expect(*tokens)
        return shift if peek?(*tokens)
        error(tokens)
      end

      # Errors, noting the expected tokens, the given token, the location
      # of given tokens.  It does this by emitting a diagnostic.  The
      # diagnostic is only allowed to be a {Metanostic::Mode::PANIC}
      # diagnostic, so this is garenteed to error.
      #
      # @param tokens [<::Symbol>] The expected tokens.
      # @return [void]
      def error(tokens)
        fail "Unexpected #{peek.type.inspect}, expected one of" \
          " #{tokens.map(&:inspect).join(', ')}"
      end
    end
  end
end
