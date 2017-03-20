# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      # Takes the contents of the block, and outputs it, without any
      # processing.  This is used to bypass any text processing processors
      # that are being used.  This does nothing for command or block elements
      # in the literal block, and the existance of such elements will cause
      # errors.
      #
      # Because of the way the parser works, the original source text
      # information is discarded for command and block elements, since they
      # are unneeded for building the nodes.  This means that it is not
      # possible to reconstruct, from only the AST, the original text without
      # slight variances (which we don't want).  (The other option would be
      # to use the location information to grab it from the file itself, but
      # as of right now, location information is unreliable.)  This is why
      # the literal tag cannot contain other command or block elements.
      #
      # This processor takes no options, nor any pairs.
      #
      # @example
      #   <l>**Test**</l> this.
      #   # => "**Test** this."
      class Literal < Processor::Base
        include Processor::Block
        self.names = %i(literal raw l)
        register %i(all literal) => self

        # Preforms the literalizing of the body.  Right now, this just uses
        # {Parser::Node::Root#flatten}.
        #
        # @return [::String]
        def perform
          @body.flatten
        end
      end
    end
  end
end
