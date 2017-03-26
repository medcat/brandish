# encoding: utf-8
# frozen_string_literal: true

require "brandish/processors/html/style/highlight"
require "brandish/processors/html/style/sass"
require "brandish/processors/html/style/vanilla"

module Brandish
  module Processors
    module HTML
      # A Style asset.  This is a CSS asset.
      #
      # Engines:
      #
      # - `"highlight-rouge"`, `"highlight-rouge-file"` - A command.
      #   Retrieves the given theme from the Rouge library, and outputs it
      #   to the `"output"` pair (or `"highlight/rouge/<theme>.css"` by
      #   default).
      # - `"highlight-pygments", `"highlight-pygments-file"` - A command.
      #   Retrieves the given theme from the Pygments library, and outputs
      #   it to the `"output"` pair (or `"highlight/pygments/<theme>.css"`
      #   by default).
      # - `"highlight-rouge-inline"` - A command.  Retrieves the given theme
      #   from the Rouge library, and uses it like an inline style.
      # - `"highlight-pygments-inline"` - A command.  Retrieves the given
      #   theme from the pygments library, and uses it like an inline
      #   style.
      # - `"sass"`, `"sass-file"`, `"scss"`, `"scss-file"` - A command.
      #   These take a file and processes it, and outputs it to the output
      #   path given by `#load_file_paths`.  There is no difference
      #   between any of these engine types - the engine assumes the actual
      #   syntax of the file from the file extension.
      # - `"sass-inline"` - A block.  This takes the block's contents,
      #   performs {Parser::Node::Root#flatten} on it, and processes the
      #   content as Sass.  This is then included as an inline stylesheet.
      # - `"scss-inline" - A block.  Similar to `"sass-inline"`, except it
      #   processes the content as SCSS.
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
      # - `"theme"` - Required (for `highlight-*` engines only).  The theme
      #   to find for styling.
      # - `"scope"` - Required (for `highlight-*` engines only).  The CSS
      #   scope for styling.
      # - `"output"` - Optional (for `highlight-*` engines or for
      #   `"remote"`/`"remote-file"` that output to a file only).  The output
      #   path for the CSS file.
      class Style < Common::Asset
        register %i(html style) => self
        self.names = %i(style styling)

        include Style::Highlight
        include Style::Sass
        include Style::Vanilla

        # (see Common::Asset::Paths#asset_kind_path)
        def asset_kind_path
          "assets/styles"
        end

        # (see Common::Asset::Paths#asset_kind_extension)
        def asset_kind_extension
          ".css"
        end
      end
    end
  end
end
