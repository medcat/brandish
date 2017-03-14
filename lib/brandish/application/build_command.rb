# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Application
    # The build command.  This just builds the project in the set directory.
    class BuildCommand
      include Commander::Methods

      # The description for the build command.
      #
      # @return [::String]
      COMMAND_DESCRIPTION =
        "Builds an existing Brandish project.  If no directory is specified " \
        " using --directory or -d, it defaults to the current directory."

      # Defines the command on the given application.  This sets the important
      # data information for the command, for use for the help output.
      #
      # @param application [Application]
      # @param command [Commander::Command]
      # @return [void]
      def self.define(application, command)
        command.syntax = "brandish build"
        command.description = COMMAND_DESCRIPTION
        command.option "-o", "--only NAMES", [::String],
          "Which forms to build.  If this is omitted, it defaults to all."

        command.action { |_, o| call(application, o.__hash__) }
      end

      # The default options for the build command.
      #
      # @return [{::Symbol => ::Object}]
      DEFAULTS = { only: :all }.freeze

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
        configure = @application.load_configuration_file
        @application.progress(configure.build(@options[:only]).to_a, &:call)
      rescue => e
        say_error "\n=> Error while building!"
        say_error "-> Received exception: #{e.class}: #{e.message}"
        e.backtrace.each { |l| say_warning "\t-> in #{l}" } if @options[:trace]
      end
    end
  end
end
