# encoding: utf-8
# frozen_string_literal: true

require "webrick"
require "pathname"
require "commander"
require "listen"
require "brandish/application/build_command"
require "brandish/application/initialize_command"
require "brandish/application/serve_command"

module Brandish
  class Application
    include Commander::Methods

    attr_reader :config_file
    attr_reader :directory

    def self.call
      new.call
    end

    def call
      program_information
      global_options
      command(:initialize) { |c| InitializeCommand.define(self, c) }
      command(:build) { |c| BuildCommand.define(self, c) }
      command(:serve) { |c| ServeCommand.define(self, c) }
      alias_command(:init, :initialize)
      default_command(:build)
      run!
    end

    def program_information
      program :name, "Brandish"
      program :version, Brandish::VERSION
      program :help_formatter, :compact
      program :help_paging, false
      program :description, "A multi-format document generator."
      program :help, "Author", "Jeremy Rodi <jeremy.rodi@medcat.me>"
      program :help, "License", "MIT License Copyright (c) 2017 Jeremy Rodi"
    end

    def global_options
      configure_global_option
      directory_global_option
    end

    def configure_global_option
      @config_file = "brandish.config.rb"
      global_option("--config FILE") { |f| @config_file = f }
    end

    def directory_global_option
      @directory = Pathname.new(Dir.pwd)
      global_option("--directory PATH") do |path|
        @directory = Pathname.new(path).expand_path(Dir.pwd)
      end
    end

    PROGRESS_OPTIONS = {
      title: "   Building...", progress_str: "#", incomplete_str: " ",
      format: ":title <:progress_bar> :percent_complete%",
      complete_message: "   Build complete!"
    }.freeze

    PROGRESS_WIDTH = "   Building... <  > 000%  ".length

    def progress(array, &block)
      # rubocop:disable Style/GlobalVars
      width = $terminal.terminal_size[0] - PROGRESS_WIDTH
      # rubocop:enable Style/GlobalVars
      options = PROGRESS_OPTIONS.merge(width: width)
      super(array, options, &block)
    end

    def config_file_path
      @directory / @config_file
    end

    def load_configuration_file
      @configuration || load_configuration_file!
    end

    def load_configuration_file!
      @configuration = nil
      Brandish.reset_configuration
      load config_file_path.to_s
      fail "No configuration provided." unless Brandish.configuration
      @configuration = Brandish.configuration
    rescue LoadError
      fail "No configuration provided"
    end
  end
end
