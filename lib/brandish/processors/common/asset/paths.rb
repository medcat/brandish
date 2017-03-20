# encoding: utf-8
# frozen_string_literal: true

module Brandish
  module Processors
    module Common
      class Asset < Processor::Base
        # Common path operations used for asset processors.  This assumes
        # a css-like dependency structure similar to HTML's.  These are not
        # required to be used.
        module Paths
          # The asset path for this kind of asset.
          #
          # @abstract
          # @return [::String]
          def asset_kind_path
            nil
          end

          # The extension for this kind of asset.  This defaults to no
          # extension.
          #
          # @abstract
          # @return [::String]
          def asset_kind_extension
            ""
          end

          # The load paths for this asset type.  This defaults to a pathset
          # containing all of the sources, all of the sources' appended with
          # {#asset_kind_path}, and all of the paths given by the 
          # `:asset_load_paths` option value.
          def asset_load_paths
            return @asset_load_paths if @asset_load_paths

            paths = PathSet.new
            @context.configure.sources
                    .each { |p| paths << p }
                    .each { |p| paths << p / asset_kind_path }
            @options.fetch(:asset_load_paths, []).each { |p| paths << p }
            @asset_load_paths = paths
          end

          # The default output assets path.
          #
          # @return [::String]
          def output_assets_path
            @context.configure.output / asset_kind_path
          end

          # Converts the given uri into a pathname, using the host, the path,
          # the query, and the fragment all as directories.  This turns the
          # uri `https://example.com/some-path?waffles#test` into the path
          # `example.com/some-path/waffles/test.<asset_kind_extension>`.
          #
          # @param uri [::URI] The uri to convert into a path.
          # @return [::Pathname]
          def uri_path(uri)
            base = [uri.host,
              (uri.path unless uri.path.empty?),
              (uri.query if uri.query),
              (uri.fragment if uri.fragment)].compact
            ::Pathname.new(::File.join(*base)).sub_ext(asset_kind_extension)
          end

          # The file paths.  This returns a hash with three elements:
          # `:file`, which is the given file name from the element;
          # `:out`, which is the full output directory for outputting the
          # asset file; and `:src`, which is similar to what the HTML src
          # or href value would be for the asset.
          #
          # @return [{::Symbol => ::Pathname}]
          def load_file_paths
            file = load_asset_file
            # The full path to the file itself.
            path = asset_load_paths.find(file, @options)
            output_path = @context.configure.output
            # The relative path from the source asset directory.
            asset_path = asset_load_paths.resolve(file)
            # The "raw" output path.
            raw_output_path =
              @pairs.fetch("output") { asset_path.sub_ext(asset_kind_extension) }
            # The actual output path of the file.
            file_output_path = output_assets_path / raw_output_path
            src_output_path = file_output_path.relative_path_from(output_path)

            { file: path, out: file_output_path, src: src_output_path }
          end
        end
      end
    end
  end
end
