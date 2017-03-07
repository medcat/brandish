# encoding: utf-8
# frozen_string_literal: true

require "thor"
require "rubygems"

module Brandish
  class Application
    class InitializeGenerator
      include Thor::Base
      include Thor::Actions

      def self.source_root
        File.expand_path("../../../../templates/initialize", __FILE__)
      end

      def call
        template "brandish.config.rb"
        template "index.br"
        template "Gemfile"
        inside(".") { run "bundle install" }
      end

      def approx
        @approx ||=
          Gem::Version.new(Brandish::VERSION).approximate_recommendation
      end
    end
  end
end
