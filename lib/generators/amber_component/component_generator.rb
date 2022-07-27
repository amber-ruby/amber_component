# frozen_string_literal: true

require 'fileutils'
require 'byebug'

module ::AmberComponent
  module Generators
    class ComponentGenerator < ::Rails::Generators::NamedBase
      desc 'Generate a new component'
      source_root ::File.expand_path('templates', __dir__)

      # copy rake tasks
      def copy_tasks
        template 'component.rb.erb', "app/components/#{file_path}.rb"
        template 'component_test.rb.erb', "test/components/#{file_path}_test.rb"
        template 'view.html.erb', "app/components/#{file_path}/view.html.erb"
        template 'style.css.erb', "app/components/#{file_path}/style.css"
      end

      def file_name
        name = super
        return name if name.end_with? '_component'

        "#{name}_component"
      end
    end
  end
end
