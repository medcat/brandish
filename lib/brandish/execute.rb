# encoding: utf-8
# frozen_string_literal: true

module Brandish
  # Executes a string of code in the instance of the class.
  #
  # @api private
  class Execute
    # Initialize the execution context.
    #
    # @param context [{::Symbol, ::String => ::Object}] The context.  The keys
    #   are set as instance variables on the class, with the values being the
    #   instance variable's respective value.
    def initialize(context)
      context.each { |k, v| instance_variable_set(:"@#{k}", v) }
    end

    # Executes the given code in the context of the class.
    #
    # @param code [::String] The code to execute.
    # @return [::Object]
    def exec(code)
      instance_exec(code)
    end
  end
end
