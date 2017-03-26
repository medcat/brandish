# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module HTML
      class Script < Common::Asset
        # A set of scripting engines that use the Babel transpiler.
        #
        # Engines:
        #
        # - `"babel"`, `"babel-file"` - A command.  This takes the contents
        #   of the resolved file, transpiles it, and outputs it into
        #   the output path, given by `#load_file_paths`.
        # - `"babel-inline"` - A block.  Similar to `"babel"`; however, it
        #   takes the block, uses {Parser::Node::Root#flatten} on it,
        #   transpiles the result, and adds that as an inline script.
        #
        # @note
        #   The libraries that these engines depend on are not required in
        #   by default; if any of these engines are used, the requisite
        #   libraries would have to be required by the `brandish.config.rb`
        #   file.
        module Babel
          Script.engine "babel", :command, :script_babel_file
          Script.engine "babel-file", :command, :script_babel_file
          Script.engine "babel-inline", :block, :script_babel_inline

        private

          def script_babel_inline
            parsed = ::Babel::Transpiler.transform(@body.flatten)
            @context[:document].add_inline_script(parsed["code"])
          end

          def script_babel_file
            paths = load_file_paths
            paths[:out].dirname.mkpath
            parsed = ::Babel::Transpiler.transform(paths[:file].read)
            paths[:out].write(parsed["code"])

            @context[:document].add_linked_script(paths[:src])
          end
        end
      end
    end
  end
end
