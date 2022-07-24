# frozen_string_literal: true

require 'tilt'
require 'active_model/callbacks'
require 'byebug'

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
  class Base
    extend ::ActiveModel::Callbacks

    # @return [Regexp]
    VIEW_FILE_REGEXP  = /^view\./.freeze
    STYLE_FILE_REGEXP = /^style\./.freeze

    class << self
      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def run(**kwargs)
        comp = new(**kwargs)

        comp.render
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
    def render
      run_callbacks :render do
        element = render_view
        styles = inject_styles
        element += styles unless styles.nil?

        element
      end
    end

    # Returns a binding in the scope of this instance.
    #
    # @return [Binding]
    def local_binding
      binding
    end

    # @param file_name [String, nil]
    # @return [String, nil]
    def asset_path(file_name)
      return unless file_name

      ::File.join(component_asset_dir_path, file_name)
    end

    # @return [String]
    def component_asset_dir_path
      class_const_name = self.class.name.split('::').last
      parent_module = self.class.module_parent
      component_file_path, = parent_module.const_source_location(class_const_name)

      component_file_path.delete_suffix('.rb')
    end

    protected

    # Can be overridden to provide styling in class file.
    # Should return string of CSS. When other type is provided,
    # should return hash {style: String, type: String ('sass | scss | less')}.
    #
    # @return [String, Hash{style => String, type => String}, nil]
    def style; end

    private

    # @param kwargs [Hash{Symbol => Object}]
    # @return [void]
    def bind_variables(kwargs)
      kwargs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # @param type_regexp [Regexp]
    # @return [String, nil]
    def find_asset_file_path(type_regexp)
      asset_dir = component_asset_dir_path
      ::Dir.entries(asset_dir).find do |file|
        next unless ::File.file?(::File.join(asset_dir, file))

        file.match? type_regexp
      end
    end

    # @return [String]
    def render_view
      view_path = asset_path(find_asset_file_path(VIEW_FILE_REGEXP))
      raise ViewFileNotFound, "View file for `#{self.class}` could not be found!" unless view_path

      ::Tilt.new(view_path).render(self)
    end

    # Helper method to render style from css string or with other provided type.
    # Usage: render_custom_style('.my-class { color: red; }')
    # or: render_custom_style({style: '.my-class { color: red; }', type: 'sass'})
    #
    # @param style [String, Hash{style => String, type => String}]
    # @return [String, nil]
    def render_custom_style(style)
      return '' unless style
      return style if style.is_a? String

      type = style[:type].to_s.downcase
      content = style[:content].to_s

      if content.empty?
        raise EmptyStyle, `
          Custom style for #{self.class} from style method cannot be empty!
          Check return value of style[:style]`.squeeze(' ')
      end
      if type.empty?
        raise StyleTypeNotFound, `
          Custom style type for #{self.class} from style method cannot be empty!
          Check return value of style[:type]`.squeeze(' ')
      end
      unless %w[sass scss less].include? type
        raise UnknownStyleType, `
          Unknown style type for #{self.class} from style method!
          Check return value of style[:type]`.squeeze(' ')
      end

      ::Tilt[type].new { content }.render
    end

    # Method returning style from file (style.(css|sass|scss|less)) if exists.
    #
    # @return [String]
    def render_style_from_file
      style_path = asset_path(find_asset_file_path(STYLE_FILE_REGEXP))
      return '' unless style_path
      return File.read(style_path) if style_path.split('.').last == 'css'

      ::Tilt.new(style_path).render(self)
    end

    # Method returning style from method in class file.
    # Usage:
    #   def style
    #     '.my-class { color: red; }'
    #   end
    #
    # or:
    #  def style
    #   {
    #     style: '.my-class { color: red; }',
    #     type: 'sass'
    #   }
    # end
    #
    # @return [String]
    def render_style_from_method
      render_custom_style(style)
    end

    # Method returning style from params in view.
    # Usage:
    #   <%= ExampleComponent data: data, style: '.my-class { color: red; }' %>
    # or:
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
