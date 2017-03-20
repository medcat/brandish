# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Application
    # The serve command.  This builds, and then serves, an existing Brandish
    # project.  This watches the source.  If it detects a change, it rebuilds.
    class ServeCommand
      include Commander::Methods

      # The description for the serve command.
      #
      # @return [::String]
      COMMAND_DESCRIPTION = "Builds, and serves, an existing Brandish project."

      # Defines the command on the given application.  This sets the important
      # data information for the command, for use for the help output.
      #
      # @param application [Application]
      # @param command [Commander::Command]
      # @return [void]
      def self.define(application, command)
        command.syntax = "branish serve"
        command.description = COMMAND_DESCRIPTION
        command.option "-p", "--port PORT", ::Integer, "The port to listen on"
        command.option "-o", "--only NAMES", [::String], "The forms to build"
        command.option "--verbose", "Whether or not to be verbose in the output"

        command.action { |_, o| call(application, o.__hash__) }
      end

      # Performs the serve command.  This initializes the command, and
      # calls {#call}.
      #
      # @param application [Application] The application.
      # @param options [{::Symbol => ::Object}] The options for the command.
      #
      # @return [void]
      def self.call(application, options)
        puts "Running with options #{options.inspect}..."
        new(application, options).call
      end

      # The default options for the serve command.
      #
      # @return [{::Symbol => ::Object}]
      DEFAULTS = { only: :all, show_build: false }.freeze

      # Initialize the serve command.
      #
      # @params (see {.call})
      def initialize(application, options)
        @application = application
        @options = DEFAULTS.merge(options)
        @port = @options.fetch(:port, (ENV["PORT"] || "3000").to_i)
      end

      # Performs the serve command.  It first loads the configuration file,
      # then calls {#start_webserver}, followed by {#start_buildserver}.  Once
      # both servers are setup, it calls {#wait_on_servers}.
      #
      # @return [void]
      def call
        @configuration = @application.load_configuration_file
        say "=> Beginning serve..."
        start_webserver
        start_buildserver
        color "\r=> Ready and waiting! ", :erase_line, :green
        wait_on_servers
      rescue StandardError, ScriptError => e
        # Whenever we receive a general error, which only occurs while setup,
        # we complain, and pass up the exception.
        say_error "\n!> Received exception: #{e.class}: #{e.message}"
        e.backtrace.each { |l| say_warning "\t-> in #{l}" } if @options[:trace]
        fail
      rescue SignalException, NoMemoryError, SystemExit, SystemStackError => e
        # Whenever we receive a signal, or an unrecoverable error, we kill
        # the servers and complain.  These exceptions occur on the main thread,
        # and so we handle them here.
        say_warning "\n!> Received exception: #{e.class}: #{e.message}"
        say_ok "\n-> Received termination, shutting down..."
        kill_webserver
        kill_buildserver
      end

    private

      def start_webserver
        say "-> Setting up web server on port #{@port}..."
        log_file = @options[:verbose] ? $stdout : StringIO.new
        log = WEBrick::Log.new(log_file)
        access_log = [[log_file, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
        data = { Port: @port, DocumentRoot: @configuration.output.to_s,
                 Logger: log, AccessLog: access_log }

        @webserver = Thread.start { WEBrick::HTTPServer.new(data).start }
      end

      def print(a, *)
        fail if a.is_a?(::IO)
        super
      end

      def start_buildserver
        perform_build
        say "\n"
        say "-> Setting up listen server..."
        source_build_server = Listen.to(*listen_paths) { perform_build }
        config_build_server = Listen.to(@application.directory.to_s) do
          say "-> Configuration file changed, updating..."
          @configuration = @application.load_configuration_file!
          perform_build
        end
        config_build_server.only(/#{Regexp.escape(@application.config_file.to_s)}\z/)

        @buildservers = [source_build_server, config_build_server].each(&:start)
      end

      def perform_build
        builds = @configuration.build!(@options[:only])
        color "\r~> Building... ", :erase_line, :clear
        builds.each(&:call)
        color "\r=> Build completed at #{Time.now.strftime('%T.%L')}! ", :erase_line, :green

      rescue => e
        say_error "\n!> Error while building!"
        say_error "!> #{e.location}" if e.respond_to?(:location)
        say_error "-> Received exception: #{e.class}: #{e.message}"
        e.backtrace.each { |l| say_warning "\t-> in #{l}" } if @options[:trace]
      end

      def kill_webserver
        @webserver&.kill
      end

      def kill_buildserver
        @buildservers&.each { |b| b&.stop }
      end

      def wait_on_servers
        @webserver.join
      end

      def listen_paths
        (@configuration.sources.to_a + @configuration.templates.to_a)
          .select(&:directory?).map(&:to_s)
      end
    end
  end
end
