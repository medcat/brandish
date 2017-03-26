# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # An inline-defined processor.  This allows processors to be defined easily
    # within a block.  This is mostly used for configuration.
    #
    # @example
    #   class RFC < Brandish::Processor::Inline
    #     command! :rfc
    #     pairs :number
    #
    #     perform do
    #       number = @pairs.fetch("number")
    #       "<a href='https://www.ietf.org/rfc/rfc#{number}.txt'>RFC #{number}</a>"
    #     end
    #   end
    class Inline < Base
      # Sets this processor as a command processor.  This includes
      # {Command}, and passes the given names to 
      # {NameFilter::ClassMethods#name}.
      #
      # @return [void]
      def self.command!(*names)
        include Command
        name(*names)
      end

      # Sets this processor as a block processor.  This include {Block}, and
      # passes the given names to {NameFilter::ClassMethods#name}.
      #
      # @return [void]
      def self.block!(*names)
        include Block
        name(*names)
      end

      # Defines the `#perform` method with the given block.  This is only
      # effective if one of {Command} or {Block} is included.  This takes the
      # block passed to it and uses that to define the `#perform` method.
      #
      # @return [void]
      def self.perform(&block)
        define_method(:perform, &block)
      end
    end
  end
end