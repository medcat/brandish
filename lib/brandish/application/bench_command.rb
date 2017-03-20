# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Application
    # The bench command.  This builds the project in the set directory,
    # and benchmarks.  This is for debugging.
    class BenchCommand
      include Commander::Methods

      # Defines the command on the given application.  This sets the important
      # data information for the command, for use for the help output.
      #
      # @param application [Application]
      # @param command [Commander::Command]
      # @return [void]
      def self.define(application, command)
        command.syntax = "brandish build"
        command.option "-o", "--only NAMES", [::String]
        command.option "-p", "--path PATH", ::String
        command.option "-n", "--name NAME", ::String

        command.action { |_, o| call(application, o.__hash__) }
      end

      # The default options for the build command.
      #
      # @return [{::Symbol => ::Object}]
      DEFAULTS = { only: :all, path: "profile", name: "default" }.freeze

      # Performs the build command.  This initializes the command, and
      # calls {#call}.
      #
      # @param application [Application] The application.
      # @param options [{::Symbol => ::Object}] The options for the command.
      #
      # @return [void]
      def self.call(application, options)
        new(application, options).call
      end

      # Initialize the build command.
      #
      # @params (see {.call})
      def initialize(application, options)
        @application = application
        @options = DEFAULTS.merge(options)
      end

      # Performs the build.  First, it loads the configuration file for the
      # build.  Then, it performs the build, calling {Configure#build} with
      # the `:only` filter provided by the options.  This uses a Commander
      # native called `progress` to make it look nice on the output.
      #
      # @return [void]
      def call
        require "ruby-prof"
        require "benchmark"

        @configure = @application.load_configuration_file
        @path = ::Pathname.new(@options[:path]).expand_path(Dir.pwd)
        @path.mkpath
        say "=> Beginning build..."

        result = nil
        time = Benchmark.measure { result = RubyProf.profile { perform_build } }
        say "-> Build ended, time: #{time}"
        say "=> Outputting profile..."

        result.eliminate_methods!(method_eleminations)
        output_profile(result)
      end

    private

      def output_profile(result)
        printer = RubyProf::MultiPrinter.new(result)
        printer.print(path: @path, profile: @options[:name])
        say "-> Profile output to `#{@options[:path]}'!"
      end

      def perform_build
        @configure.build(@options[:only]).each(&:call)
      rescue => e
        say_error "!> Error while building!"
        say_error "-> Received exception: #{e.class}: #{e.message}"
        e.backtrace.each { |l| say_warning "\t-> in #{l}" } if @options[:trace]
        exit!
      end

      def method_eleminations
        [/\A(Set|Class|Array|Enumerable)#/]
      end
    end
  end
end
