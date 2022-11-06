# frozen_string_literal: true

require 'fileutils'

# A Rails generator which creates a new Amber component.
class AmberComponentGenerator < ::Rails::Generators::NamedBase
  desc 'Generate a new component'
  source_root ::File.expand_path('templates', __dir__)

  # @return [Array<Symbol>]
  VIEW_FORMATS = %i[html erb haml slim]

  class_option view: :string
  # copy rake tasks
  def copy_tasks
    @view_format = (options[:view] || :html).to_sym
    @view_format = :html if @view_format == :erb

    unless VIEW_FORMATS.include? @view_format
      puts "No such view format as `#{@view_format}`"
      error!
    end

    template 'component.rb.erb', "app/components/#{file_path}.rb"
    template 'component_test.rb.erb', "test/components/#{file_path}_test.rb"
    create_stylesheet
    create_view
  end

  def file_name
    name = super
    return name if name.end_with? '_component'

    "#{name}_component"
  end

  private

  # @return [void]
  def create_view
    case @view_format
    when :slim
      template 'view.slim.erb', "app/components/#{file_path}/view.slim"
    when :haml
      template 'view.haml.erb', "app/components/#{file_path}/view.haml"
    else
      template 'view.html.erb.erb', "app/components/#{file_path}/view.html.erb"
    end
  end

  # @return [void]
  def create_stylesheet
    if defined?(::SassC)
      template 'style.scss.erb', "app/components/#{file_path}/style.scss"
    else
      template 'style.css.erb', "app/components/#{file_path}/style.css"
    end
  end
end
