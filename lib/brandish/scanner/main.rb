# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Scanner
    # The logic for the scanner.
    module Main
    private

      def scan
        scan_escape ||
          scan_operators ||
          scan_numerics ||
          scan_whitespace ||
          scan_normal ||
          fail(ScanError) # unreachable
      end

      OPERATORS = {
        "=": :"=",
        '"': :'"',
        "/": :"/"
      }.freeze

      def scan_escape
        match(/\\./, :ESCAPE)
      end

      def scan_operators
        operators.find { |(o, n)| (t = match(o, n)) && (return t) }
      end

      def scan_numerics
        match(/0[xX][0-9a-fA-F]/, :NUMERIC) ||
          match(/[-+]?\d+(\.\d+)?/, :NUMERIC)
      end

      def scan_whitespace
        if @scanner.scan(/\r\n|\r|\n/)
          @line += 1
          @last_line_at = @scanner.charpos - 1
          emit(:LINE)
        elsif @scanner.scan(/[ \v\t\f]+/)
          emit(:SPACE)
        end
      end

      def scan_normal
        match(/[^\d\r\n\v\t\f #{Regexp.escape(operators.keys.join)}\\]+/, :TEXT)
      end

      def operators
        @_operators ||=
          OPERATORS.merge(@options.fetch(:tags).zip([:<, :>]).to_h)
      end
    end
  end
end
