# frozen_string_literal: true

require 'pathname'

module ::AmberComponent
  # Provides methods concerning view registering and rendering.
  module Views
    # @return [Regexp]
    VIEW_FILE_REGEXP  = /^view\./.freeze

    # Class methods for views.
    module ClassMethods
      # Register an inline view by returning a String from the passed block.
      #
      # Usage:
      #
      #   view <<~ERB
      #     <h1>
      #       Hello <%= @name %>
      #     </h1>
      #   ERB
      #
      # or:
      #
      #   view <<~HAML, type: :haml
      #     %h1
      #       Hello
      #       = @name
      #   HAML
      #
      # @param content [String, Proc]
      # @param type [Symbol]
      # @return [void]
      def view(content, type: :erb)
        @method_view = TypedContent.new(type: type, content: content)
      end

      # ERB/Haml/Slim view registered through the `view` method.
      #
      # @return [TypedContent]
      attr_reader :method_view

      # @return [String]
      def view_template_source
        return @method_view.to_s if @method_view

        ::File.read(view_path)
      end

      # @return [String, nil]
      def view_path
        asset_path view_file_name
      end

      # @return [String, nil]
      def view_file_name
        files = asset_file_names(VIEW_FILE_REGEXP)
        raise MultipleViewsError, "More than one view file for `#{name}` found!" if files.length > 1

        files.first
      end

      # @return [Symbol]
      def view_type
        return @method_view.type if @method_view
        raise ViewFileNotFoundError, "No view file for #{self}" unless view_file_name

        view_file_path = ::Pathname.new view_file_name
        view_file_path.extname.delete_prefix('.').to_sym
      end
    end
  end
end
