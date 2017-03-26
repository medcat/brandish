# encoding: utf-8
# frozen_string_literal: true

require "forwardable"

module Brandish
  # A set of paths that can be searched for a certain file.  This is used for
  # looking for certain files, like sources or templates.  This can allow
  # Brandish to provide "default" files.
  #
  # Despite its name, the order in which the paths are added to the pathset
  # are important.
  class PathSet
    extend Forwardable
    include Enumerable

    # @!method clear
    # Removes all of the paths from this pathset.
    #
    # @return [void]
    def_delegator :@paths, :clear

    # @!method each(&block)
    #   @overload each
    #     Returns an enumerable over all of the paths in the pathset.
    #
    #     @return [::Enumerable<::Pathname>]
    #   @overload each(&block)
    #     Iterates over all of the paths in this pathset.
    #
    #     @yield path For each path in the pathset.
    #     @yieldparam path [::Pathname] The path.
    #     @return [void]
    def_delegator :@paths, :each

    # Initialize the pathset.
    def initialize
      @paths = []
    end

    # Adds a path to this pathset.
    #
    # @param path [::String, ::Pathname]
    # @return [self]
    def <<(path)
      @paths << ::Pathname.new(path)
    end

    # Calls {#clear}, and then uses {#<<} to append the given path to the
    # pathset, effectively replacing all of the paths in the pathset with the
    # one given.
    #
    # @param path [::String, ::Pathname]
    # @return [self]
    def replace(path)
      clear
      self << path
    end

    # The default options for {#find} and {#find_all}.
    #
    # @return [{::Symbol => ::Object}]
    DEFAULT_FIND_OPTIONS = { file: true, allow_absolute: false }.freeze

    # "Resolves" a path.  This is resolved the exact same way that {#find}
    # and {#find_all} are (with some slight variations), and so can be used
    # as a sort of "name" for a certain path.
    #
    # @param path [::String, ::Pathname] The path to the file.
    # @param options [{::Symbol => ::Object}] The options for resolution.
    # @return [::Pathname] The resolved path.
    def resolve(path, options = {})
      options = DEFAULT_FIND_OPTIONS.merge(options)
      path = ::Pathname.new(path)
      if options[:allow_absolute]
        path.cleanpath
      else
        ::Pathname.new(path.expand_path("/").to_s.gsub(%r{\A(/|\\)}, ""))
      end
    end

    # Finds a file in the pathset.  If the file is returned, it is guarenteed
    # to exist.  Relative paths, that do not expand out of the relative path,
    # are handled like you would expect - the path is appended to one of the
    # paths in the set, and checked for existance.  However, for a file that
    # expands out of the relative path (e.g. `../a` or `a/../../b`), the
    # behavior for expansion depends on the `allow_absolute` option.  If
    # `allow_absolute` is false (default), the path is expanded against `/`
    # before it is joind with the paths in the set (e.g. `../a`, against
    # `/path/to`, with `allow_absolute=false`, expands to `/path/to/a`).
    # If `allow_absolute` is true, it directly expanding against the path
    # (e.g. `../a`, against `/path/to`, with `allow_absolute=true`, expands
    # to `/path/a`).  `allow_absolute` should only be used if the given path
    # is trusted.  Absolute paths are handled in a similar manner; if
    # `allow_absolute=false`, for `/a` against `/path/to`, it expands to
    # `/path/to/a`; with `allow_absolute=true`, for `/a` against `/path/to`,
    # it expands to `/a`.
    #
    # @example
    #   pathset
    #   # => #<PathSet ...>
    #   pathset.find("some/file")
    #   # => #<Pathname /path/to/some/file>
    #   pathset.find("not/real")
    #   # !> NoFileError
    #   pathset.find("/path/to/some/file")
    #   # !> NoFileError
    #   pathset.find("/path/to/some/file", allow_absolute: true)
    #   # => #<Pathname /path/to/some/file>
    #   pathset.find("../to/some/file")
    #   # !> NoFileError
    #   pathset.find("../to/some/file", allow_absolute: true)
    #   # => #<Pathname /path/to/some/file>
    # @raise [NoFileError] If no file could be found.
    # @param short [::String, ::Pathname] The "short" path to resolve.
    # @param options [{::Symbol => ::Object}] The options for finding.
    # @option (see #find_all)
    # @return [::Pathname] The full absolute path to the file.
    def find(short, options = {})
      find_all(short, options).next
    rescue ::StopIteration
      fail NoFileError, "Could not find `#{short}' in any of the given paths " \
        "(paths: #{@paths.map(&:to_s).join(', ')})"
    end

    # Finds all versions of the short path name in the paths in the path
    # sets.  If no block is given, it returns an enumerable; otherwise, if
    # a block is given, it yields the joined path if it exists.
    #
    # @raise NoFileError If no file could be found.
    # @param short [::String, ::Pathname] The "short" path to resolve.
    # @param options [{::Symbol => ::Object}] The options for finding.
    # @option options [Boolean] :allow_absolute (false)
    # @option options [Boolean] :file (true) Whether or not the full path
    #   must be a file for it to be considered existant.  This should be set
    #   to true, because in most cases, it's the desired behavior.
    # @yield [path] For every file that exists.
    # @yieldparam path [::Pathname] The path to the file.  This is guarenteed
    #   to exist.
    # @return [void]
    def find_all(short, options = {})
      return to_enum(:find_all, short, options) unless block_given?
      short = ::Pathname.new(short)
      options = DEFAULT_FIND_OPTIONS.merge(options)

      @paths.reverse.each do |path|
        joined = path_join(path, short, options)
        yield joined if (options[:file] && joined.file?) || joined.exist?
      end

      nil
    end

  private

    def path_join(path, short, options)
      if options[:allow_absolute]
        short.expand_path(path)
      else
        ::Pathname.new(::File.join(path, short.expand_path("/")))
      end
    end
  end
end
