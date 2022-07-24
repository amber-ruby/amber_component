# frozen_string_literal: true

require 'erb'
require 'tilt'
require 'active_model/callbacks'

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
#    class ButtonComponent < ::AmberComponents::Base
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
module ::AmberComponents
  class Base
    extend ::ActiveModel::Callbacks

    # @return [Regexp]
    VIEW_FILE_REGEXP = /^view\./.freeze

    class << self
      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def run(**kwargs, &block)
        comp = new(**kwargs)

        comp.render(&block)
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
        view_path = asset_path(view_file_name)
        raise ViewFileNotFound, "View file for `#{self.class}` could not be found!" unless view_path

        ::Tilt.new(view_path).render(self, &block)
      end
    end

    # @return [String, nil]
    def view_file_name
      asset_dir = component_asset_dir_path
      ::Dir.entries(asset_dir).find do |file|
        next unless ::File.file?(::File.join(asset_dir, file))

        file.match? VIEW_FILE_REGEXP
      end
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

    private

    # @param kwargs [Hash{Symbol => Object}]
    # @return [void]
    def bind_variables(kwargs)
      kwargs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
