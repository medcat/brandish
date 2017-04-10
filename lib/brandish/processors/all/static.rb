# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module All
      class Static < Common::Asset
        register %i(all static) => self
        self.names = %i(static file)

        engine "file", :command, :static_file
        engine "remote", :command, :static_file_remote
        engine "remote-file", :command, :static_file_remote

        # (see Common::Asset::Paths#asset_kind_path)
        def asset_kind_path
          "assets/static"
        end

      private

        def static_file
          paths = load_file_paths
          paths[:out].dirname.mkpath
          src, dest = paths[:file].open("rb"), paths[:out].open("wb")
          ::IO.copy_stream(src, dest)
          [src, dest].each(&:close)
        end

        def static_file_remote
          uri = URI(load_asset_file)
          file = open(uri)
          asset_path = @pairs.fetch("output") { uri_path(uri) }
          output_path = output_assets_path / asset_path
          output_path.dirname.mkpath
          link_path = output_path.relative_path_from(@context.configure.output)
          output = output_path.open("wb")
          ::IO.copy_stream(file, output)
          [file, output].each(&:close)
        end
      end
    end
  end
end