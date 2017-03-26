# encoding: utf-8
# frozen_string_literal: true

require "set"

module Brandish
  module Processor
    # A "name filter" for command and block nodes.  This provides helpers to
    # filter out nodes that don't have the given name.  The class will keep
    # an internal list of names that are allowed to be used for the node,
    # and if the node matches, then it processes it.
    #
    # @api private
    module NameFilter
      # The class methods that are implemented on the including module.  This
      # is extended onto the class.
      module ClassMethods
        # The name that is assumed from the class name.
        #
        # @return [::String]
        def assumed_class_name
          name
            .gsub(/\A(?:.+::)?(.*?)\z/, "\\1")
            .gsub(/(?<!\A)[A-Z]/) { |m| "-#{m}" }
            .downcase
        end

        # A list of allowed names for the class.
        #
        # @return [::Set<::String>]
        def allowed_names
          @names ||= name ? Set[assumed_class_name] : Set.new
        end

        # If no names are given, it retrieves them using {#allowed_names};
        # otherwise, it merges the names into the allowed names set.
        #
        # @param names [#to_s, <#to_s>] The names.
        # @return [::Set<::String>] The allowed names.
        def names(*names)
          return allowed_names if names.none?
          allowed_names.merge(Array(names).flatten.map(&:to_s))
        end

        alias_method :names=, :names
      end

      # The instance methods on the including class.
      module InstanceMethods
        # (see ClassMethods#allowed_names)
        def allowed_names
          self.class.allowed_names
        end
      end

      # Used as a hook for Ruby.
      #
      # @api private
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
