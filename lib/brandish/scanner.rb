# encoding: utf-8
# frozen_string_literal: true

require "strscan"
require "yoga"

module Brandish
  # Scans the file for tokens.  This is by default done incrementally, as it's
  # requested by the parser or whatever consumer wants to use it.  This is done
  # to make sure that work that doesn't need to be done isn't.
  class Scanner
    include Yoga::Scanner

    # The default options for the scanner.
    #
    # @return [{::Symbol => ::Object}]
    DEFAULT_OPTIONS = { tags: %i(< >).freeze }.freeze

    # Initialize the scanner with the given source and file.  If no file
    # is given, it defaults to `<anon>`.
    #
    # @param source [::String] The source to read from.
    # @param file [::String] The name of the file that this originates from.
    def initialize(*args, **options)
      super(*args)
      @options = DEFAULT_OPTIONS.merge(options)
    end

  private

    def scan
      scan_escape ||
        scan_operators ||
        scan_numerics ||
        scan_whitespace ||
        scan_normal ||
        fail(ScanError) # unreachable
    end

    def scan_escape
      match(/\\./, :ESCAPE)
    end

    def scan_operators
      operators.find { |(o, n)| (t = match(o, n)) && (return t) }
    end

    def scan_numerics
      match(/0[xX][0-9a-fA-F]/, :NUMERIC) || match(/[-+]?\d+(\.\d+)?/, :NUMERIC)
    end

    def scan_whitespace
      match_line(:LINE) || match(/[ \v\t\f]+/, :SPACE)
    end

    def scan_normal
      match(/[^\d\s\\#{Regexp.escape(operators.keys.join)}]+/, :TEXT)
    end

    OPERATORS = { "=" => :"=", '"' => :'"', "/" => :"/" }.freeze

    def operators
      @_operators ||=
        OPERATORS.merge(@options.fetch(:tags).map(&:to_s).zip([:<, :>]).to_h)
    end
  end
end
