# frozen_string_literal: true

module ::AmberComponent
  # Provides methods for locating and manipulating component assets.
  module Assets
    # Class methods for assets.
    module ClassMethods
      # @return [String]
      def asset_dir_path
        component_file_path, = source_location
        component_file_path.delete_suffix('.rb')
      end

      # @param file_name [String, nil]
      # @return [String, nil]
      def asset_path(file_name)
        return unless file_name

        ::File.join(asset_dir_path, file_name)
      end

      # Returns the name of the file inside the asset directory
      # of this component that matches the provided `Regexp`
      #
      # @param type_regexp [Regexp]
      # @return [Array<String>]
      def asset_file_names(type_regexp)
        return [] unless ::File.directory?(asset_dir_path)

        ::Dir.entries(asset_dir_path).select do |file|
          next unless ::File.file?(::File.join(asset_dir_path, file))

          file.match? type_regexp
        end
      end
    end

    # Instance methods for assets.
    module InstanceMethods
    end
  end
end
