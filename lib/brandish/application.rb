# encoding: utf-8
# frozen_string_literal: true

require "pathname"
require "commander"
require "brandish/application/initialize_generator"

module Brandish
  class Application
    include Commander::Methods

    def self.call
      new.call
    end

    def call
      program_information
      global_options
      command(:init) { |c| define_initialize_command(c) }
      command(:build) { |c| define_build_command(c) }
      alias_command(:initialize, :init)
      run!
    end

    def program_information
      program :name, "Brandish"
      program :version, Brandish::VERSION
      program :description, "A multi-format document generator."
      program :help, "Author", "Jeremy Rodi <jeremy.rodi@medcat.me>"
      program :help, "License", "MIT License Copyright (c) 2016 Jeremy Rodi"
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
      global_option("-d", "--directory PATH") do |path|
        @directory = Pathname.new(path).expand_path(Dir.pwd)
      end
    end

    def define_initialize_command(command)
      command.syntax = "brandish init NAME"
      command.description = "Creates a new brandish project."
      command.option "-n", "--name NAME", ::String, "The name of the project"

      command.action { |_, o| perform_initialize_command(a, o) }
    end

    def define_build_command(command)
      command.syntax = "brandish build"
      command.description = "Builds an existing brandish project."
      command.option "-o", "--only NAMES", [::String], "The forms to build"

      command.action { |_, o| perform_build_command(o) }
    end

    def perform_initialize_command(options)
      options.default(name: @directory.basename.to_s)
      InitializeGenerator.new([], { name: options.name },
        destination_root: @directory).call
    end

    def perform_build_command(options)
      options.default(only: :all)
      load_configuration_file
      Brandish.configure.build(options.only)
    end

  private

    def load_configuration_file
      path = @directory / @config_file
      load path.to_s
      fail "No configuration provided." unless Brandish.configure
    end
  end
end
