# frozen_string_literal: true

require 'erb'
require 'byebug'

class ::AmberComponents::BaseComponent
  class << self
    # @return [String]
    def run(*args)
      comp = new(*args)

      comp.before_render
      comp.render
    end

    alias call run
  end

  def initialize(*args)
    before_create
    bind_variables(*args)
    after_create
  end

  # @return [String]
  def render
    view_path = asset_path('view.erb')
    ::ERB.new(::File.read(view_path)).result(local_binding)
  end

  # Returns a binding in the scope of this instance.
  #
  # @return [Binding]
  def local_binding
    binding
  end

  # @param file_name [String]
  # @return [String]
  def asset_path(file_name)
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

  def after_create(*args); end
  def before_create(*args); end
  def before_render(*args); end

  private

  def bind_variables(*args)
    args.each do |arg|
      key   = arg.keys.first
      name  = key.to_s
      value = arg[key]
      instance_variable_set("@#{name}", value)
    end
  end
end
