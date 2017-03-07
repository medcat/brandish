# encoding: utf-8
# frozen_string_literal: true

require "strscan"
require "brandish/scanner/main"
require "brandish/scanner/token"

module Brandish
  # Scans the file for tokens.  This is by default done incrementally, as it's
  # requested by the parser or whatever consumer wants to use it.  This is done
  # to make sure that work that doesn't need to be done isn't.  Most of the
  # logic for scanning is located in {Scanner::Main} - this class mostly
  # contains the helpers for the scanner.
  class Scanner
    include Scanner::Main

    DEFAULT_OPTIONS = { tags: %i(< >).freeze }.freeze

    # Initialize the scanner with the given source and file.  If no file
    # is given, it defaults to `<anon>`.
    #
    # @param source [::String] The source to read from.
    # @param file [::String] The name of the file that this originates from.
    #   See {Location#file}.
    def initialize(source, file = "<anon>", **options)
      @scanner = StringScanner.new(source)
      @file = file
      @options = DEFAULT_OPTIONS.merge(options)
      reset!
    end

    # @overload call(&block)
    #   For every token that is scanned, the block is yielded to.
    #
    #   @yieldparam token [Scanner::Token]
    #   @return [self]
    # @overload call
    #   Returns an enumerable over the tokens in the scanner.
    #
    #   @return [::Enumerable<Scanner::Token>]
    def call
      return to_enum(:call) unless block_given?

      until @scanner.eos?
        value = scan
        yield value if value.is_a?(Token)
      end

      yield Token.eof(location)
      reset!
      self
    end

  private

    def reset!
      @scanner.reset
      @line = 1
      @last_line_at = 0
    end

    def location(size = 0)
      start = @scanner.charpos - @last_line_at
      column = (start - size)..start
      Location.new(@file, @line, column)
    end

    def emit(name, source = @scanner[0])
      Token.new(name, source, location(source.length))
    end

    def match(string, name = :"#{string}")
      string = ::Regexp.new(::Regexp.escape(string)) if string.is_a?(::Symbol)
      emit(name) if @scanner.scan(string)
    end
  end
end
