# encoding: utf-8
# frozen_string_literal: true

require "thor"
require "rubygems"

module Brandish
  class Application
    # The initialize command for the application.  This creates a new project
    # at a given directory.  The Brandish project is placed at
    # `directory`/`name`.
    class InitializeCommand
      include Thor::Base
      include Thor::Actions

      # The description for the initialize command.
      #
      # @return [::String]
      COMMAND_DESCRIPTION =
        "Creates a new Brandish project.  The name given should not contain " \
        "any path seperators - if a brandish project needs to be placed in " \
        "a seperate directory, use the --directory (or -d) option."

      # The source root for the templates used by Thor for initialization.
      #
      # @return [::String]
      def self.source_root
        File.expand_path("../../../../templates/initialize", __FILE__)
      end

      # Defines the command on the given application.  This sets the important
      # data information for the command, for use for the help output.
      #
      # @param application [Application]
      # @param command [Commander::Command]
      # @return [void]
      def self.define(application, command)
        command.syntax = "brandish initialize NAME"
        command.description = COMMAND_DESCRIPTION

        command.action { |a, o| call(application, a, o.__hash__) }
      end

      # Performs the initialize command.  Since this class uses Thor, this
      # performs some setup to interface with the Thor class.
      #
      # @param application [Application]
      # @param arguments [<::String>] The arguments passed to the initialize
      #   command.  This should contain one value - the name.
      # @param _options [Hash] The options for the command.  Since this command
      #   takes no specific options, this is ignored.
      # @return [void]
      def self.call(application, arguments, _options)
        name = arguments[0]
        directory = application.directory / name
        new([], { name: name }, destination_root: directory).call
      end

      # Performs the initialize command, setting up the project.
      #
      # @return [void]
      def call
        template "brandish.config.rb"
        %w(source source/assets source/assets/styles source/assets/scripts
          templates output).each { |d| empty_directory(d) }
        template "index.br", "source/index.br"
        template "Gemfile"
        inside(".") { run "bundle install" }
      end

    protected

      # The approximate recommendation for the current running version of
      # Brandish.  This is used to set up a requirement for Brandish in both
      # the Gemfile and the `brandish.config.rb` file.
      #
      # @return [::String]
      def approx
        @approx ||=
          Gem::Version.new(Brandish::VERSION).approximate_recommendation
      end
    end
  end
end
