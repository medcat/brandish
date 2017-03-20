# encoding: utf-8
# frozen_string_literal: true

require "open-uri"

module Brandish
  module Processors
    module All
      # "Imports" another file into this current file.  This takes the file,
      # parses it, and inserts it directly into the position that the import
      # was placed.  By default, this forces the file to be in the source
      # directory, doing some awkward joining to make it work.  This takes
      # one pair - `"name"`, `"link"`, or `"file"` - which contains the name of
      # the file to import.  It takes two options:  `:absolute_allowed`, which
      # allows imports to be outside of the source directory; and
      # `:remote_allowed`, which allows remote files to be imported, using any
      # of the protocols supported by open-uri.
      #
      # For local file imports, if no extensions were provided, an extension
      # of `.br` is automatically added.  For remote files, extensions are
      # always required.
      #
      # Imports are handled as if the entire imported file was copy and pasted
      # into the source document.
      #
      # Options:
      #
      # - `:absolute_allowed` - Optional.  Despite its name, if this value is
      #   `true`, imports can be used with any file that is outside of the
      #   source directory.  Otherwise, the files will be forced to be inside
      #   the source directory, as if the source directory is the root of the
      #   file system.
      # - `:remote_allowed` - Optional.  Whether remote imports should be
      #   allowed.
      #
      # @example local file
      #   <import file="some-file" />
      # @example remote file
      #   <import link="http://example.org/some-file.br" />
      # @example absolute local file
      #   <import file="/opt/brandish/sources/html" />
      # @note
      #   Be careful when using `:remote_allowed` - this can cause possible
      #   security issues if the remote is not trusted.
      class Import < Processor::Base
        include Processor::Command
        register %i(all import) => self

        # Accepts the root node of the parsed file, processing the result as
        # if it were an extension of the original source tree.
        #
        # @return [Parser::Node]
        def perform
          accept(parse_file)
        end

      private

        def load_file
          file = @pairs["src"] || @pairs["file"] || @pairs["name"] ||
                 @pairs["link"]
          return file if file
          fail PairError.new("Expected one of src, file, name, or link, " \
            "got nothing", @node.location)
        end

        def parse_file
          load_file =~ /\A(https?|ftp):/ ? parse_remote_file : parse_local_file
        end

        def parse_remote_file
          fail_remote_file unless @options[:remote_allowed]
          open(load_file) { |io| @context.configure.parse_from(io, file) }
        end

        def fail_remote_file
          fail PairError.new("Remote file given, but not supported", @node.location)
        end

        def parse_local_file
          file = ::Pathname.new(load_file)
          file = file.sub_ext(".br") unless load_file =~ /\.(.+?)\z/
          path = @context.configure.sources.find(file)
          @context.configure.roots[path]
        end
      end
    end
  end
end
