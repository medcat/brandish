# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/html/script/babel"
require "brandish/processors/html/script/coffee"
require "brandish/processors/html/script/vanilla"

module Brandish
  module Processors
    module HTML
      # A script asset.  This is a JavaScript asset.
      #
      # Engines:
      #
      # - `"babel"`, `"babel-file"` - A command.  This takes the contents
      #   of the resolved file, transpiles it, and outputs it into
      #   the output path, given by `#load_file_paths`.
      # - `"babel-inline"` - A block.  Similar to `"babel"`; however, it
      #   takes the block, uses {Parser::Node::Root#flatten} on it,
      #   transpiles the result, and adds that as an inline script.
      # - `"coffee"`, `"coffee-file"` - A command.  This takes the contents
      #   of the resolved file, transpiles it, and outputs it into
      #   the output path, given by `#load_file_paths`.
      # - `"coffee-inline"` - A block.  Similar to `"coffee"`; however, it
      #   takes the block, uses {Parser::Node::Root#flatten} on it,
      #   transpiles the result, and adds that as an inline script.
      # - `"file"` - A command.  Takes a file, and copies it over to the
      #   destination, based on the values given in `#load_file_paths`.
      # - `"remote"`, `"remote-file"` - A command.  Takes a URI (supports 
      #   `http`, `https`, and `ftp`), and outputs the directory into the
      #   `"output"` pair (or a uri path assumed from the URI).
      # - `"inline"` - A block.  This performs {Parser::Node::Root#flatten}
      #   on the body, and pushes the result as an inline style.
      # - `"remote-inline"` - A command.  Similar to `"remote"`; however,
      #   this takes the remote styles as an inline style.
      #
      # Pairs:
      #
      # - `"src"`, `"file"`, `"name"`, or `"link"` - Required.  At least one
      #   of these options are required.  They all perform the same function.
      #   This defines the name or path of the asset to add or process.
      # - `"type"` - Required.  The type of the asset to process.  This defines
      #   how the asset is handled.
      class Script < Common::Asset
        register %i(html script) => self
        self.names = %i(script scripting)

        include Script::Babel
        include Script::Coffee
        include Script::Vanilla

        # (see Common::Asset::Paths#asset_kind_path)
        def asset_kind_path
          "assets/scripts"
        end

        # (see Common::Asset::Paths#asset_kind_extension)
        def asset_kind_extension
          ".js"
        end
      end
    end
  end
end
