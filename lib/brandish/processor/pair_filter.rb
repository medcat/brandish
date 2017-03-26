# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processor
    # A filter for defining which pairs are accepted by the given command or
    # block processor.  By default, all pairs are restricted; however, certain
    # pairs can be whitelisted, or all pairs can be allowed.  The former helps
    # with debugging.
    module PairFilter
      # A placehodler object to denote that all pairs are allowed in the pair
      # set.  This is only inserted into the allowed pair set when
      # {ClassMethods#unrestricted_pairs!} is called.
      ALL = Object.new.freeze

      # The class methods that are implemented on the including module.  This
      # is extended onto the class.
      module ClassMethods
        # A set of allowed pairs that can be used with the command or block
        # element.
        #
        # @return [::Set<::String>]
        def allowed_pairs
          @allowed_pairs ||= Set.new
        end

        # A list of all of the ancestors' pairs.  This includes the current
        # classes' pairs.  This allows allowed pair inheritance.
        #
        # @return [::Set<::String>]
        def ancestor_allowed_pairs
          ancestors
            .select { |a| a.respond_to?(:allowed_pairs) }
            .map(&:allowed_pairs)
            .inject(Set.new, :merge)
        end

        # Retrives or sets the pairs for the class.
        #
        # @overload pairs
        #   Retrieves the current pairs.  This is the same as calling
        #   {#allowed_pairs}.
        #
        #   @return [::Set<::String>]
        # @overload pairs(*pairs)
        #   Adds pairs to the current {#allowed_pairs}.
        #
        #   @param pairs [::String, ::Symbol, #to_s]
        #   @return [void]
        def pairs(*pairs)
          return allowed_pairs if pairs.none?
          allowed_pairs.merge(Array(pairs).flatten.map(&:to_s))
        end
        alias_method :pair, :pairs

        # Adds {PairFilter::ALL} to the pair list, allowing all pairs to be
        # used with the command or block.
        #
        # @return [void]
        def unrestricted_pairs!
          pairs PairFilter::ALL
        end
        alias_method :unrestricted_pairs, :unrestricted_pairs!
      end

      # The instance methods on the including class.
      module InstanceMethods
        # (see ClassMethods#ancestor_allowed_pairs)
        def allowed_pairs
          self.class.ancestor_allowed_pairs
        end

        # Asserts that the pairs given are all allowed.  This uses the
        # `@pairs` and `@node` instance variables.
        #
        # @raise [PairError] If an invalid pair was given.
        # @return [void]
        def assert_valid_pairs
          return if allowed_pairs.include?(PairFilter::ALL)
          excessive = @pairs.keys - allowed_pairs
          return unless excessive.any?
          fail PairError.new("Unexpected pairs found " \
            "(#{excessive.map(&:inspect).join(', ')})", @node.location)
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