# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        # A set of scripting engines that use the Coffee transpiler.
        #
        # Engines:
        #
        # - `"coffee"`, `"coffee-file"` - A command.  This takes the contents
        #   of the resolved file, transpiles it, and outputs it into
        #   the output path, given by `#load_file_paths`.
        # - `"coffee-inline"` - A block.  Similar to `"coffee"`; however, it
        #   takes the block, uses {Parser::Node::Root#flatten} on it,
        #   transpiles the result, and adds that as an inline script.
        #
        # @note
        #   The libraries that these engines depend on are not required in
        #   by default; if any of these engines are used, the requisite 
        #   libraries would have to be required by the `brandish.config.rb`
        #   file.
        module Coffee
          Script.engine "coffee", :command, :script_coffee_file
          Script.engine "coffee-file", :command, :script_coffee_file
          Script.engine "coffee-inline", :block, :script_coffee_inline

        private

          def script_coffee_inline
            parsed = ::CoffeeScript.compile(@body.flatten)
            @context[:document].add_inline_script(parsed)
          end

          def script_coffee_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            paths[:out].write(::CoffeeScript.compile(paths[:file].read))

            @context[:document].add_linked_script(paths[:src])
          end
        end
      end
    end
  end
end
