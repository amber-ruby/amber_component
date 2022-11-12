# frozen_string_literal: true

require 'fileutils'

# A Rails generator which creates a new Amber component.
class AmberComponentGenerator < ::Rails::Generators::NamedBase
  desc 'Generate a new component'
  source_root ::File.expand_path('templates', __dir__)

  # @return [Array<Symbol>]
  VIEW_FORMATS = %i[html erb haml slim].freeze
  # @return [Array<Symbol>]
  STYLE_FORMATS = %i[css scss sass].freeze

  class_option :view,
               aliases: ['-v'],
               desc: "Indicate what type of view should be generated eg. #{VIEW_FORMATS}"

  class_option :css,
               aliases: ['--style', '-c'],
               desc: "Indicate what type of styles should be generated eg. #{STYLE_FORMATS}"

  def generate_component
    @view_format = (options[:view] || :html).to_sym
    @view_format = :html if @view_format == :erb

    @style_format = options[:css]&.to_sym

    unless VIEW_FORMATS.include? @view_format
      puts "No such view format as `#{@view_format}`"
      return
    end

    if !@style_format.nil? && STYLE_FORMATS.include?(@style_format)
      puts "No such css/style format as `#{@style_format}`"
      return
    end

    template 'component.rb.erb', "app/components/#{file_path}.rb"
    template 'component_test.rb.erb', "test/components/#{file_path}_test.rb"
    create_stylesheet
    create_view
    create_stimulus_controller
  end

  # @return [String]
  def file_name
    name = super
    return name if name.end_with? '_component'

    "#{name}_component"
  end

  private

  # @return [Boolean]
  def stimulus?
    ::AmberComponent.configuration.stimulus?
  end

  # @return [void]
  def create_stimulus_controller
    return unless stimulus?

    template 'controller.js.erb', "app/components/#{file_path}/controller.js"
  end

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
    if (@style_format.nil? && defined?(::SassC)) || @style_format == :scss
      template 'style.scss.erb', "app/components/#{file_path}/style.scss"
    elsif @style_format == :sass
      template 'style.sass.erb', "app/components/#{file_path}/style.sass"
    else
      template 'style.css.erb', "app/components/#{file_path}/style.css"
    end
  end

  # @return [String]
  def stimulus_controller_id
    file_path.gsub('_', '-').gsub('/', '--')
  end
end
