# frozen_string_literal: true

require 'fileutils'

# A Rails generator which creates a new Amber component.
class AmberComponentGenerator < ::Rails::Generators::NamedBase
  desc 'Generate a new component'
  source_root ::File.expand_path('templates', __dir__)

  class_option :view,
               aliases: ['-v'],
               desc: "Indicate what type of view should be generated " \
                     "eg. #{::AmberComponent::Configuration::ALLOWED_VIEWS}"

  class_option :css,
               aliases: ['--styles', '-c'],
               desc: "Indicate what type of styles should be generated " \
                     "eg. #{::AmberComponent::Configuration::ALLOWED_STYLES}"

  def generate_component
    set_view_format
    set_stylesheet_format

    unless ::AmberComponent::Configuration::ALLOWED_VIEWS.include? @view_format
      raise ::ArgumentError, "No such view format as `#{@view_format}`"
    end

    unless ::AmberComponent::Configuration::ALLOWED_STYLES.include?(@stylesheet_format)
      raise ::ArgumentError, "No such css/style format as `#{@stylesheet_format}`"
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

  def set_view_format
    @view_format = options[:view]&.to_sym || ::AmberComponent.configuration.view_format || :erb
  end

  def set_stylesheet_format
    @stylesheet_format = options[:style]&.to_sym || ::AmberComponent.configuration.stylesheet_format || :css
  end

  # @return [Boolean]
  def stimulus?
    ::AmberComponent.configuration.stimulus?
  end

  # @return [Boolean]
  def stimulus_importmap?
    ::AmberComponent.configuration.stimulus_importmap?
  end

  # @return [void]
  def create_stimulus_controller
    return unless stimulus?

    template 'controller.js.erb', "app/components/#{file_path}/controller.js"
    return if stimulus_importmap?

    append_file 'app/javascript/controllers/components.js', <<~JS
      import #{stimulus_controller_class_name} from "../../components/#{file_path}/controller"
      application.register("#{stimulus_controller_id}", #{stimulus_controller_class_name})
    JS
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
    case @stylesheet_format
    when :scss
      template 'style.scss.erb', "app/components/#{file_path}/style.scss"
    when :sass
      template 'style.sass.erb', "app/components/#{file_path}/style.sass"
    else
      template 'style.css.erb', "app/components/#{file_path}/style.css"
    end
  end

  # @return [String]
  def stimulus_controller_id
    file_path.gsub('_', '-').gsub('/', '--')
  end

  # @return [String]
  def stimulus_controller_class_name
    file_path.gsub('/', '_').camelize
  end
end
