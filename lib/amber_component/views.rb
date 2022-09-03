# frozen_string_literal: true

module ::AmberComponent
  # Provides methods concerning view registering and rendering.
  module Views
    # View types with built-in embedded Ruby
    #
    # @return [Set<Symbol>]
    VIEW_TYPES_WITH_RUBY = ::Set[:erb, :haml, :slim].freeze
    # @return [Set<Symbol>]
    ALLOWED_VIEW_TYPES = ::Set[:erb, :haml, :slim, :html, :md, :markdown].freeze
    # @return [Regexp]
    VIEW_FILE_REGEXP  = /^view\./.freeze

    # Class methods for views.
    module ClassMethods
      # Register an inline view by returning a String from the passed block.
      #
      # Usage:
      #
      #   view do
      #     <<~ERB
      #       <h1>
      #         Hello <%= @name %>
      #       </h1>
      #     ERB
      #   end
      #
      # or:
      #
      #   view :haml do
      #     <<~HAML
      #       %h1
      #         Hello
      #         = @name
      #     HAML
      #   end
      #
      # @param type [Symbol]
      # @return [void]
      def view(type = :erb, &block)
        @method_view = TypedContent.new(type: type, content: block)
      end

      # ERB/Haml/Slim view registered through the `view` method.
      #
      # @return [TypedContent]
      attr_reader :method_view

      # @return [String]
      def view_path
        asset_path view_file_name
      end

      # @return [String, nil]
      def view_file_name
        files = asset_file_names(VIEW_FILE_REGEXP)
        raise MultipleViews, "More than one view file for `#{name}` found!" if files.length > 1

        files.first
      end

      # @return [Symbol]
      def view_type
        (view_file_name.split('.')[1..].grep_v(/erb/).last || 'erb')&.to_sym
      end
    end

    # Instance methods for views.
    module InstanceMethods
      protected

      # @return [String]
      def render_view(&block)
        view_from_file   = render_view_from_file(&block)
        view_from_method = render_class_method_view(&block)
        view_from_inline = render_view_from_inline(&block)

        view_content = view_from_file unless view_from_file.empty?
        view_content = view_from_method unless view_from_method.empty?
        view_content = view_from_inline unless view_from_inline.empty?

        if view_content.nil? || view_content.empty?
          raise ViewFileNotFound, "View for `#{self.class}` could not be found!"
        end

        view_content
      end

      # Helper method to render view from string or with other provided type.
      #
      # Usage:
      #
      #   render_view_from_content('<h1>Hello World</h1>')
      #
      # or:
      #
      #   render_view_from_content content: '**Hello World**', type: 'md'
      #
      # @param content [TypedContent, Hash{Symbol => String, Symbol, Proc}, String]
      # @return [String, nil]
      def render_view_from_content(content, &block)
        return '' unless content
        return content if content.is_a?(::String)

        content = TypedContent.wrap(content)
        type = content.type
        content = content.to_s

        if content.empty?
          raise EmptyView, <<~ERR.squish
            Custom view for `#{self.class}` from view method cannot be empty!
          ERR
        end

        unless ALLOWED_VIEW_TYPES.include? type
          raise UnknownViewType, <<~ERR.squish
            Unknown view type for `#{self.class}` from view method!
            Check return value of param type in `view :[type] do`
          ERR
        end

        unless VIEW_TYPES_WITH_RUBY.include? type
          # first render the content with ERB if the
          # type does not support embedding Ruby by default
          content = render_string(content, :erb, block)
        end

        render_string(content, type, block)
      end

      # @return [String]
      def render_view_from_file(&block)
        view_path = self.class.view_path
        return '' if view_path.nil? || !::File.file?(view_path)

        content = ::File.read(view_path)
        type = self.class.view_type

        unless VIEW_TYPES_WITH_RUBY.include? type
          content = render_string(content, :erb, block)
        end

        render_string(content, type, block)
      end

      # Method returning view from method in class file.
      # Usage:
      #
      #   view do
      #     <<~HTML
      #       <h1>
      #         Hello <%= @name %>
      #       </h1>
      #     HTML
      #   end
      #
      # or:
      #
      #   view :haml do
      #     <<~HAML
      #       %h1
      #         Hello
      #         = @name
      #     HAML
      #   end
      #
      # @return [String]
      def render_class_method_view(&block)
        render_view_from_content(self.class.method_view, &block)
      end

      # Method returning view from params in view.
      # Usage:
      #
      #   <%= ExampleComponent data: data, view: "<h1>Hello #{@name}</h1>" %>
      #
      # or:
      #
      #   <%= ExampleComponent data: data, view: { content: "<h1>Hello #{@name}</h1>", type: 'erb' } %>
      #
      # @return [String]
      def render_view_from_inline(&block)
        data = \
          if @view.is_a? ::String
            TypedContent.new(
              type: :erb,
              content: @view
            )
          else
            @view
          end

        render_view_from_content(data, &block)
      end
    end
  end
end
