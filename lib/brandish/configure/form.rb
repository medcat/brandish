# encoding: utf-8
# frozen_string_literal: true

module Brandish
  class Configure
    class Form
      attr_reader :processors
      attr_reader :format
      attr_accessor :name
      attr_writer :entry

      def initialize(format, name = Configure.random_name)
        @name = name.to_s
        @format = format
        @processors = []
      end

      def entry
        @entry || "index.br"
      end

      def use(name, options = {})
        format, processor =
          case name
          when ::String
            name.split(":")
          when ::Symbol
            [@format, name]
          when ::Array
            name
          else
            fail ::ArgumentError.new("Unexpected `#{name.inspect}")
          end.map(&:intern)

        @processors << [format, processor, options]
      end

      def build(trees, options)
        context = Processor::Context.new
        root = trees[options[:root] / entry]

        @processors.each do |processor|
          klass = Processor.all.fetch([processor[0],processor[1]])
          klass.new(context, processor[2])
        end

        p context.accept(root)
      end
    end
  end
end
