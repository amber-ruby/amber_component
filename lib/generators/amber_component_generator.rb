# frozen_string_literal: true

require 'fileutils'

# A Rails generator which creates a new Amber component.
class AmberComponentGenerator < ::Rails::Generators::NamedBase
  desc 'Generate a new component'
  source_root ::File.expand_path('templates', __dir__)

  # copy rake tasks
  def copy_tasks
    template 'component.rb.erb', "app/components/#{file_path}.rb"
    template 'component_test.rb.erb', "test/components/#{file_path}_test.rb"
    template 'view.html.erb.erb', "app/components/#{file_path}/view.html.erb"
    if defined?(::SassC)
      template 'style.scss.erb', "app/components/#{file_path}/style.scss"
    else
      template 'style.css.erb', "app/components/#{file_path}/style.css"
    end
  end

  def file_name
    name = super
    return name if name.end_with? '_component'

    "#{name}_component"
  end
end
