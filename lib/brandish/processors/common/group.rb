# encoding: utf-8
# frozen_string_literal: true

require "securerandom"

module Brandish
  module Processors
    module Common
      # A "group."  This is for grouping together elements for styling
      # or logical purposes.  By default, this creates a block element.
      class Group < Processor::Base
        include Processor::Block

        # The class value of the group.  This can have a 1-to-1 correspondence
        # to the destination source.  This works similarly to HTML's class
        # attribute.
        #
        # @return [::String]
        def class_value
          @pairs.fetch("class", "")
        end

        # The ID value of the group.  This can have a 1-to-1 correspondence
        # to the destination source.  This works similarly to HTML's id
        # attribute; especially the concept that it should be unique.
        #
        # @return [::String, nil]
        def id_value
          @pairs["id"]
        end

        # The name value of the group.  This doesn't have a 1-to-1
        # correspondence to the destination source.  This is used to provide
        # an internal styling or grouping process.
        #
        # @return [::String, nil]
        def name_value
          @pairs["name"]
        end

        # The body, accepted and flattened.  This essentially converts the
        # contents into a string that can be used as the value for the group.
        #
        # @see #accept
        # @see Parser::Node::Root#flatten
        # @return [::String]
        def accepted_body
          accept(@body).flatten
        end
      end
    end
  end
end
