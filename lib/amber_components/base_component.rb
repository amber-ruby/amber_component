# frozen_string_literal: true

require 'erb'
require 'byebug'

class ::AmberComponents::BaseComponent
  def self.run(*args)
    comp = new(*args)

    comp.before_render
    comp.render
  end

  def initialize(*args)
    before_create
    bind_variables(*args)
    after_create
  end

  def render
    view_path = File.join(
      File.dirname(__FILE__),
      self.class.name.underscore,
      'view.erb'
    )
    byebug
    ERB.new(File.read(view_path)).run(self)
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
