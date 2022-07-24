# frozen_string_literal: true

require 'erb'
require 'tilt'
require 'active_model/callbacks'

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

    # @return [Regexp]
    VIEW_FILE_REGEXP  = /^view\./.freeze
    # @return [Regexp]
    STYLE_FILE_REGEXP = /^style\./.freeze

    class << self
      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def run(**kwargs, &block)
        comp = new(**kwargs)

        comp.render(&block)
      end

      # @return [String]
      def asset_dir_path
        @asset_dir_path ||= begin
          class_const_name = name.split('::').last
          component_file_path, = module_parent.const_source_location(class_const_name)

          component_file_path.delete_suffix('.rb')
        end
      end

      alias call run
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
        element  = inject_views(block)
        styles   = inject_styles
        element += styles unless styles.nil?
        element
      end
    end

    # @param file_name [String, nil]
    # @return [String, nil]
    def asset_path(file_name)
      return unless file_name

      ::File.join(self.class.asset_dir_path, file_name)
    end

    protected

    # Can be overridden to provide styling in class file.
    # Should return string of CSS. When other type is provided,
    # should return hash:
    #
    #   {style: String, type: String ('sass | scss | less')}.
    #
    # @return [String, Hash{content => String, type => String}, nil]
    def style; end

    # Can be overridden to provide small views in class file.
    # Should return string of ERB. When other type is provided,
    # should return hash {content: String, type: String ('erb | haml | html | md (markdown)')}.
    #
    # @return [String, Hash{content => String, type => String}, nil]
    def view; end

    private

    # @param kwargs [Hash{Symbol => Object}]
    # @return [void]
    def bind_variables(kwargs)
      kwargs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Returns the name of the file inside the asset directory
    # of this component that matches the provided `Regexp`
    #
    # @param type_regexp [Regexp]
    # @return [String, nil]
    def asset_file_name(type_regexp)
      asset_dir = self.class.asset_dir_path
      ::Dir.entries(asset_dir).find do |file|
        next unless ::File.file?(::File.join(asset_dir, file))

        file.match? type_regexp
      end
    end

    # Helper method to render view from string or with other provided type.
    # Usage:
    #
    #   render_custom_view('<h1>Hello World</h1>')
    #
    # or:
    #
    #   render_custom_view({content: '**Hello World**', type: 'md'})
    #
    # @param style [String, Hash{content => String, type => String}]
    # @return [String, nil]
    def render_custom_view(view)
      return '' unless view
      return view if view.is_a? String

      type = view[:type].to_s.downcase
      content = view[:content].to_s

      if content.empty?
        raise EmptyView, <<~ERR.chomp
          Custom view for #{self.class} from view method cannot be empty!
          Check return value of view[:content]
        ERR
      end

      if type.empty?
        raise ViewTypeNotFound, <<~ERR.chomp
          Custom view type for #{self.class} from view method cannot be empty!
          Check return value of view[:type]
        ERR
      end

      unless %w[erb haml html md markdown].include? type
        raise UnknownViewType, <<~ERR.chomp
          Unknown view type for #{self.class} from view method!
          Check return value of view[:type]
        ERR
      end

      ::Tilt[type].new { content }.render(self)
    end

    # @return [String]
    def render_view_from_file
      view_path = asset_path(find_asset_file_path(VIEW_FILE_REGEXP))
      return '' unless File.exist?(view_path)

      ::Tilt.new(view_path).render(self, &block)
    end

    # Method returning view from method in class file.
    # Usage:
    #
    #   def view
    #     '<h1>Hello World</h1>'
    #   end
    #
    # or:
    #
    #  def view
    #   {
    #     content: "<h1>Hello #{@name}</h1>",
    #     type: 'erb'
    #   }
    # end
    #
    # @return [String]
    def render_view_from_method
      render_custom_view(view)
    end

    # Method returning view from params in view.
    # Usage:
    #
    #   <%= ExampleComponent data: data, view: "<h1>Hello #{@name}</h1>" %>
    #
    # or:
    #
    #   <%= ExampleComponent data: data, view: {content: "<h1>Hello #{@name}</h1>", type: 'erb'} %>
    #
    # @return [String]
    def render_view_from_inline
      render_custom_view(@view)
    end

    # @return [String]
    def inject_views(&_block)
      view_from_file   = render_view_from_file
      view_from_method = render_view_from_method
      view_from_inline = render_view_from_inline

      view_content = view_from_file unless view_from_file.empty?
      view_content = view_from_method unless view_from_method.empty?
      view_content = view_from_inline unless view_from_inline.empty?

      raise ViewFileNotFound, "View for `#{self.class}` could not be found!" if view_content.empty?

      view_content
    end

    # Helper method to render style from css string or with other provided type.
    # Usage:
    #
    #   render_custom_style('.my-class { color: red; }')
    #
    # or:
    #
    #   render_custom_style({style: '.my-class { color: red; }', type: 'sass'})
    #
    # @param style [String, Hash{content => String, type => String}]
    # @return [String, nil]
    def render_custom_style(style)
      return '' unless style
      return style if style.is_a? String

      type = style[:type].to_s.downcase
      content = style[:content].to_s

      if content.empty?
        raise EmptyStyle, <<~ERR.chomp
          Custom style for #{self.class} from style method cannot be empty!
          Check return value of style[:style]
        ERR
      end
      if type.empty?
        raise StyleTypeNotFound, <<~ERR.chomp
          Custom style type for #{self.class} from style method cannot be empty!
          Check return value of style[:type]
        ERR
      end
      unless %w[sass scss less].include? type
        raise UnknownStyleType, <<~ERR.chomp
          Unknown style type for #{self.class} from style method!
          Check return value of style[:type]
        ERR
      end

      ::Tilt[type].new { content }.render(self)
    end

    # Method returning style from file (style.(css|sass|scss|less)) if exists.
    #
    # @return [String]
    def render_style_from_file
      style_path = asset_path(asset_file_name(STYLE_FILE_REGEXP))
      return '' unless style_path
      return ::File.read(style_path) if style_path.split('.').last == 'css'

      ::Tilt.new(style_path).render(self)
    end

    # Method returning style from method in class file.
    # Usage:
    #
    #   def style
    #     '.my-class { color: red; }'
    #   end
    #
    # or:
    #
    #    def style
    #     {
    #       style: '.my-class { color: red; }',
    #       type: 'sass'
    #     }
    #   end
    #
    # @return [String]
    def render_style_from_method
      render_custom_style(style)
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
      style_content = render_style_from_file + render_style_from_method + render_style_from_inline
      return if style_content.empty?

      ::AmberComponent::StyleInjector.inject(style_content)
    end
  end
end
