# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Import < Processor::Base
        include Processor::Command
        register %i(all import) => self

        def perform
          file = @pairs.fetch("file")
          path = (@context.configure.source / file).realpath
          accept(@context.configure.roots[path])
        end
      end
    end
  end
end
