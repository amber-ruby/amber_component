# frozen_string_literal: true

require 'set'
require 'erb'
require 'tilt'
require 'active_model/callbacks'
require 'memery'

require_relative './style_injector'

# Abstract class which serves as a base
# for all Amber Components.
#
# There are a few life cycle callbacks that can be defined.
# The same way as in `ActiveRecord` models and `ActionController` controllers.
#
# - before_render
# - around_render
# - after_render
# - before_initialize
# - around_initialize
# - after_initialize
#
#    class ButtonComponent < ::AmberComponent::Base
#      # You can provide a Symbol of the method that should be called
#      before_render :before_render_method
#      # Or provide a block that will be executed
#      after_initialize do
#        # Your code here
#      end
#
#      def before_render_method
#        # Your code here
#      end
#    end
#
#
# @abstract Create a subclass to define a new component.
module ::AmberComponent
  class Base # :nodoc:
    extend ::ActiveModel::Callbacks

    include Helper

    # @return [Regexp]
    VIEW_FILE_REGEXP  = /^view\./.freeze
    # @return [Regexp]
    STYLE_FILE_REGEXP = /^style\./.freeze
    # @return [Set<String>]
    ALLOWED_VIEW_TYPES = ::Set[:erb, :haml, :html, :md, :markdown].freeze

    class << self
      include ::Memery

      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def run(**kwargs, &block)
        comp = new(**kwargs)

        comp.render(&block)
      end

      alias call run


      # @return [String]
      memoize def asset_dir_path
        class_const_name = name.split('::').last
        component_file_path, = module_parent.const_source_location(class_const_name)

        component_file_path.delete_suffix('.rb')
      end

      # @return [String]
      def view_path
        files = asset_file_name(VIEW_FILE_REGEXP)
        raise MultipleViews, "More than one view file for `#{name}` found!" if files.length > 1

        asset_path files.first
      end

      # @return [String]
      def style_path
        files = asset_file_name(STYLE_FILE_REGEXP)
        raise MultipleStyles, "More than one style file for `#{name}` found!" if files.length > 1

        asset_path files.first
      end

      # Memoize these methods in production
      if defined?(::Rails) && ::Rails.env.production?
        memoize :view_path
        memoize :style_path
      end

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

      private

      # @param subclass [Class]
      # @return [void]
      def inherited(subclass)
        # @type [Module]
        parent_module = subclass.module_parent
        method_body = proc do |**kwargs, &block|
          subclass.run(**kwargs, &block)
        end

        Helper.define_method(subclass.name, &method_body) && return if parent_module.equal? ::Object

        parent_module.define_singleton_method(subclass.name.split('::').last, &method_body)
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
      def asset_file_name(type_regexp)
        return [] unless ::File.directory?(asset_dir_path)

        ::Dir.entries(asset_dir_path).select do |file|
          next unless ::File.file?(::File.join(asset_dir_path, file))

          file.match? type_regexp
        end
      end
    end

    define_model_callbacks :initialize, :render

    # @param kwargs [Hash{Symbol => Object}]
    def initialize(**kwargs)
      run_callbacks :initialize do
        bind_variables(kwargs)
      end
    end

    # @return [String]
    def render(&block)
      run_callbacks :render do
        element  = inject_views(&block)
        styles   = inject_styles
        element += styles unless styles.nil?
        element
      end
    end

    private

    # @param kwargs [Hash{Symbol => Object}]
    # @return [void]
    def bind_variables(kwargs)
      kwargs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Helper method to render view from string or with other provided type.
    #
    # Usage:
    #
    #   render_custom_view('<h1>Hello World</h1>')
    #
    # or:
    #
    #   render_custom_view content: '**Hello World**', type: 'md'
    #
    # @param style [TypedContent, Hash{Symbol => String, Symbol, Proc}, String]
    # @return [String, nil]
    def render_custom_view(view, &block)
      return '' unless view
      return view if view.is_a?(::String)

      view = TypedContent.wrap(view)
      type = view.type
      content = view.to_s

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

      ::Tilt[type].new { content }.render(self, &block)
    end

    # @return [String]
    def render_view_from_file(&block)
      view_path = self.class.view_path
      return '' if view_path.nil? || !::File.file?(view_path)

      ::Tilt.new(view_path).render(self, &block)
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
      render_custom_view(self.class.method_view, &block)
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
        if @view.is_a? String
          TypedContent.new(
            type: :erb,
            content: @view
          )
        else
          @view
        end

      render_custom_view(data, &block)
    end

    # @return [String]
    def inject_views(&block)
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

    # Helper method to render style from css string or with other provided type.
    #
    # Usage:
    #
    #   render_custom_style('.my-class { color: red; }')
    #
    # or:
    #
    #   render_custom_style style: '.my-class { color: red; }', type: 'sass'
    #
    # @param style [TypedContent, Hash{Symbol => Symbol, String, Proc}, String]
    # @return [String, nil]
    def render_custom_style(style)
      return '' unless style
      return style if style.is_a?(::String)

      style = TypedContent.wrap(style)
      type = style.type
      content = style.to_s

      if content.empty?
        raise EmptyStyle, <<~ERR.squish
          Custom style for `#{self.class}` from style method cannot be empty!
        ERR
      end
      unless %w[sass scss less].include? type
        raise UnknownStyleType, <<~ERR.squish
          Unknown style type for `#{self.class}` from style method!
          Check return value of param type in `style :[type] do`
        ERR
      end

      ::Tilt[type].new { content }.render(self)
    end

    # Method returning style from file (style.(css|sass|scss|less)) if exists.
    #
    # @return [String]
    def render_style_from_file
      style_path = self.class.style_path
      return '' unless style_path
      return ::File.read(style_path) if style_path.split('.').last == 'css'

      ::Tilt.new(style_path).render(self)
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
      render_custom_style(self.class.method_style)
    end

    # Method returning style from params in view.
    # Usage:
    #
    #   <%= ExampleComponent data: data, style: '.my-class { color: red; }' %>
    #
    # or:
    #
    #   <%= ExampleComponent data: data, style: {style: '.my-class { color: red; }', type: 'sass'} %>
    #
    # @return [String]
    def render_style_from_inline
      render_custom_style(@style)
    end

    # @return [String]
    def inject_styles
      style_content = render_style_from_file + render_class_method_style + render_style_from_inline
      return if style_content.empty?

      ::AmberComponent::StyleInjector.inject(style_content)
    end
  end
end
