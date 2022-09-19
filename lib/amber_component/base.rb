# frozen_string_literal: true

require 'set'
require 'erb'
require 'tilt'
require 'memery'
require 'active_model/callbacks'
require 'action_view'

module ::AmberComponent
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
  class Base < ::ActionView::Base
    # for defining callback such as `after_initialize`
    extend ::ActiveModel::Callbacks
    extend Helpers::ClassHelper

    include Helpers::CssHelper
    include Views::InstanceMethods
    extend  Views::ClassMethods
    include Assets::InstanceMethods
    extend  Assets::ClassMethods
    include Rendering::InstanceMethods
    extend  Rendering::ClassMethods

    class << self
      include ::Memery

      memoize :asset_dir_path

      # Memoize these methods in production
      if ::ENV['RAILS_ENV'] == 'production'
        memoize :view_path
        memoize :view_file_name
        memoize :view_type
      end

      private

      # @param subclass [Class]
      # @return [void]
      def inherited(subclass)
        super
        method_body = lambda do |**kwargs, &block|
          subclass.render(**kwargs, &block)
        end
        parent_module = subclass.module_parent

        if parent_module.equal?(::Object)
          method_name = subclass.name
          define_helper_method(subclass, Helpers::ComponentHelper, method_name.underscore, method_body)
          return
        end

        method_name = subclass.const_name
        define_helper_method(subclass, parent_module.singleton_class, method_name.underscore, method_body)
      end

      # Gets or defines an anonymous module that
      # will store all dynamically generated helper methods
      # for the received module/class.
      #
      # @param mod [Module, Class]
      # @return [Module]
      def helper_module(mod)
        ivar_name = :@__amber_component_helper_module
        mod.instance_variable_get(ivar_name)&.then { return _1 }

        helper_mod = mod.instance_variable_set(ivar_name, ::Module.new)
        mod.include helper_mod
        helper_mod
      end

      # Defines an instance method on the given `mod` Module/Class.
      #
      # @param component [Class]
      # @param target_mod [Module, Class]
      # @param method_name [String, Symbol]
      # @param body [Proc]
      def define_helper_method(component, target_mod, method_name, body)
        helper_module(target_mod).define_method(method_name, &body)

        return if ::ENV['RAILS_ENV'] == 'production'

        ::Warning.warn <<~WARN if target_mod.instance_methods.include?(method_name)
          #{caller(0, 1).first}: warning:
              `#{component}` shadows the name of an already existing `#{target_mod}` method `#{method_name}`.
              Consider renaming this component, because the original method will be overridden.
        WARN
      end
    end

    define_model_callbacks :initialize, :render

    # @param kwargs [Hash{Symbol => Object}]
    def initialize(**kwargs)
      run_callbacks :initialize do
        bind_variables(kwargs)
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
  end
end
