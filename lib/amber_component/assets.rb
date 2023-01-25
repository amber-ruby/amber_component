# frozen_string_literal: true

module ::AmberComponent
  # Provides methods for locating and manipulating component assets.
  module Assets
    # Class methods for assets.
    module ClassMethods
      # @return [Pathname]
      def asset_dir_path
        component_file_path = source_location.first
        return asset_dir_from_name unless component_file_path

        ::Pathname.new component_file_path.delete_suffix('.rb')
      end

      # @return [Pathname, nil]
      def asset_dir_from_name
        return unless defined?(::Rails)

        ::Rails.root / 'app' / 'components' / name.underscore
      end

      # Get an array of all folders containing component assets.
      # This method should only be used on the parent class `AmberComponent::Base` or `ApplicationComponent`.
      #
      # @return [Array<Pathname>]
      def all_asset_dir_paths
        subclasses.map(&:asset_dir_path)
      end

      # @param file_name [String, Pathname, nil]
      # @return [Pathname, nil]
      def asset_path(file_name)
        return unless file_name

        asset_dir_path / file_name
      end

      # Returns the name of the file inside the asset directory
      # of this component that matches the provided `Regexp`
      #
      # @param type_regexp [Regexp]
      # @return [Array<String>]
      def asset_file_names(type_regexp)
        return [] unless ::File.directory?(asset_dir_path)

        ::Dir.entries(asset_dir_path).select do |file|
          next unless ::File.file?(asset_dir_path / file)

          file.match? type_regexp
        end
      end
    end

  end
end
