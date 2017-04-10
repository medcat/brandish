# encoding: utf-8
# frozen_string_literal: true

require "webrick"
require "pathname"
require "commander"
require "listen"
require "brandish/application/bench_command"
require "brandish/application/build_command"
require "brandish/application/initialize_command"
require "brandish/application/serve_command"

module Brandish
  # The command line interface for Brandish.
  #
  # @api private
  class Application
    include Commander::Methods

    # The name of the configure file.  This should be `"brandish.config.rb"`,
    # but may change in the future (maybe `Brandishfile`?).
    #
    # @return [::String]
    attr_reader :config_file

    # The executing directory for the application.  This is provided with the
    # global option `-d`.  Using this should be the same as using `cd` and
    # executing the command.
    #
    # @return [::String]
    attr_reader :directory

    # Defines and runs the command line interface.
    #
    # @see #call
    # @return [void]
    def self.call
      new.call
    end

    # Defines and runs the command line interface.
    #
    # @see #program_information
    # @see #configure_global_option
    # @see #directory_global_option
    # @see InitializeCommand.define
    # @see BenchCommand.define
    # @see BuildCommand.define
    # @see ServeCommand.define
    # @return [void]
    def call
      program_information
      configure_global_option
      directory_global_option
      command(:initialize) { |c| InitializeCommand.define(self, c) }
      command(:bench) { |c| BenchCommand.define(self, c) }
      command(:build) { |c| BuildCommand.define(self, c) }
      command(:serve) { |c| ServeCommand.define(self, c) }
      alias_command(:init, :initialize)
      default_command(:build)
      run!
    end

    # The program information.  This is for use with Commander.
    #
    # @return [void]
    def program_information
      program :name, "Brandish"
      program :version, Brandish::VERSION
      program :help_formatter, :compact
      program :help_paging, false
      program :description, "A multi-format document generator."
      program :help, "Author", "Jeremy Rodi <jeremy.rodi@medcat.me>"
      program :help, "License", "MIT License Copyright (c) 2017 Jeremy Rodi"
    end

    # Defines the config global option.  This sets {#config_file} to its
    # default file, and defines an option that can set it.
    #
    # @return [void]
    def configure_global_option
      @config_file = "brandish.config.rb"
      global_option("--config FILE") { |f| @config_file = f }
    end

    # Defines the directory global option.  This sets {#directory} to its
    # default value, and defines an option that can set it.
    #
    # @return [void]
    def directory_global_option
      @directory = Pathname.new(Dir.pwd)
      global_option("--directory PATH") do |path|
        @directory = Pathname.new(path).expand_path(Dir.pwd)
      end
    end

    # Options that are passed to the `progress` method provided by Commander.
    # This makes it look "nice."
    #
    # @return [{::Symbol => ::String}]
    PROGRESS_OPTIONS = {
      title: "   Building...", progress_str: "#", incomplete_str: " ",
      format: ":title <:progress_bar> :percent_complete%",
      complete_message: "   Build complete!"
    }.freeze

    # The width of all of the set text items in the progress bar.  This is
    # used to dynamically determine the with of the progress bar later on.
    #
    # @return [::Numeric]
    PROGRESS_WIDTH = "   Building... <  > 000%  ".length

    # Creates a progress bar on the terminal based off of the given array.
    # This mostly passes everything on to the `progress` method provided by
    # Commander, but with a few options added.
    #
    # @param array [::Array] The array of items that are being processed.
    # @yield [item] Once for every item in the array.  Once the block ends,
    #   the progress bar increments.
    # @yieldparam item [::Object] One of the items in the array.
    # @return [void]
    def progress(array, &block)
      # rubocop:disable Style/GlobalVars
      width = $terminal.terminal_size[0] - PROGRESS_WIDTH
      # rubocop:enable Style/GlobalVars
      options = PROGRESS_OPTIONS.merge(width: width)
      super(array, options, &block)
    end

    # If the configuration isn't already loaded, load it; otherwise, just
    # return the already loaded version of the configuration file.
    #
    # @return [Configure]
    def load_configuration_file
      Brandish.configuration || load_configuration_file!
    end

    # Forces the configuration file to be loaded, even if it already was;
    # this first resets the configuration using {Brandish.reset_configuration},
    # then it loads the {#config_file_path}.  If no configuration was provided,
    # it fails;  if it didn't load properly, it fails.
    #
    # @raise [RuntimeError] If no configuration was provided, or if it didn't
    #   load properly.
    # @return [Configure]
    def load_configuration_file!
      Brandish.reset_configuration
      load load_paths.find(@config_file).to_s
      fail "No configuration provided" unless Brandish.configuration
      Brandish.configuration
    end

  private

    def load_paths
      @_load_paths ||= Brandish::PathSet.new << @directory
    end
  end
end
