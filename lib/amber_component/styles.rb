# frozen_string_literal: true

module ::AmberComponent
  # Provides methods concerning style registering and rendering.
  module Styles
    # @return [Set<Symbol>]
    ALLOWED_STYLE_TYPES = ::Set[:sass, :scss, :less].freeze
    # @return [Regexp]
    STYLE_FILE_REGEXP = /^style\./.freeze

    # Class methods for styles.
    module ClassMethods
      # Register an inline style by returning a String from the passed block.
      #
      # Usage:
      #
      #   style do
      #     '.my-class { color: red; }'
      #   end
      #
      # or:
      #
      #    style :sass do
      #     <<~SASS
      #       .my-class
      #         color: red
      #     SASS
      #    end
      #
      # @param type [Symbol]
      # @return [void]
      def style(type = :css, &block)
        @method_style = TypedContent.new(type: type, content: block)
      end

      # CSS/SCSS/Sass styles registered through the `style` method.
      #
      # @return [TypedContent]
      attr_reader :method_style

      # @return [String]
      def style_path
        asset_path style_file_name
      end

      # @return [String, nil]
      def style_file_name
        files = asset_file_names(STYLE_FILE_REGEXP)
        raise MultipleStyles, "More than one style file for `#{name}` found!" if files.length > 1

        files.first
      end

      # @return [Symbol]
      def style_type
        (style_file_name.split('.')[1..].reject { _1.match?(/erb/) }.last || 'erb')&.to_sym
      end
    end

    # Instance methods for styles.
    module InstanceMethods
      protected

      # @return [String]
      def inject_styles
        style_content = render_style_from_file + render_class_method_style + render_style_from_inline
        return if style_content.empty?

        StyleInjector.inject(style_content)
      end

      # Helper method to render style from css string or with other provided type.
      #
      # Usage:
      #
      #   render_style_from_content('.my-class { color: red; }')
      #
      # or:
      #
      #   render_style_from_content content: '.my-class { color: red; }', type: :sass
      #
      # @param content [TypedContent, Hash{Symbol => Symbol, String, Proc}, String]
      # @return [String, nil]
      def render_style_from_content(content)
        return '' unless content
        return content if content.is_a?(::String)

        content = TypedContent.wrap(content)
        type = content.type
        content = content.to_s

        if content.empty?
          raise EmptyStyle, <<~ERR.squish
            Custom style for `#{self.class}` from style method cannot be empty!
          ERR
        end

        unless ALLOWED_STYLE_TYPES.include? type
          raise UnknownStyleType, <<~ERR.squish
            Unknown style type for `#{self.class}` from style method!
            Check return value of param type in `style :[type] do`
          ERR
        end

        # first render the content with ERB
        content = render_string(content, :erb)

        render_string(content, type)
      end

      # Method returning style from file (style.(css|sass|scss|less)) if exists.
      #
      # @return [String]
      def render_style_from_file
        style_path = self.class.style_path
        return '' unless style_path

        content = ::File.read(style_path)
        type = self.class.style_type

        return content if type == :css

        content = render_string(content, :erb)
        render_string(content, type)
      end

      # Method returning style from method in class file.
      # Usage:
      #
      #   style do
      #     '.my-class { color: red; }'
      #   end
      #
      # or:
      #
      #    style :sass do
      #     <<~SASS
      #       .my-class
      #         color: red
      #     SASS
      #    end
      #
      # @return [String]
      def render_class_method_style
        render_style_from_content(self.class.method_style)
      end

      # Method returning style from params in view.
      # Usage:
      #
      #   <%= ExampleComponent data: data, style: '.my-class { color: red; }' %>
      #
      # or:
      #
      #   <%= ExampleComponent data: data, style: { content: '.my-class { color: red; }', type: :sass } %>
      #
      # @return [String]
      def render_style_from_inline
        render_style_from_content(@style)
      end
    end
  end
end
