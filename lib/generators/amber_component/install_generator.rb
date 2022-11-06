# frozen_string_literal: true

require 'fileutils'

module ::AmberComponent
  module Generators
    # A Rails generator which installs the `amber_component`
    # library in a Rails project.
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Install the AmberComponent gem'
      source_root ::File.expand_path('templates', __dir__)

      # copy rake tasks
      def copy_tasks
        copy_file 'application_component.rb', 'app/components/application_component.rb'
        copy_file 'application_component_test_case.rb', 'test/application_component_test_case.rb'
        append_file 'test/test_helper.rb', "require_relative 'application_component_test_case'"

        require_components_css_in 'app/assets/stylesheets/application.css'
        require_components_css_in 'app/assets/stylesheets/application.scss'
        require_components_css_in 'app/assets/stylesheets/application.sass'
        require_components_css_in 'app/assets/stylesheets/application.css.scss'
        require_components_css_in 'app/assets/stylesheets/application.css.sass'
        require_components_css_in 'app/assets/stylesheets/application.scss.sass'
        require_components_css_in 'app/assets/stylesheets/application.sass.scss'
      end

      private

      # @param file_name [String]
      # @return [void]
      def require_components_css_in(file_name)
        return unless ::File.exist? file_name

        inject_into_file file_name, after: "*= require_tree .\n" do
          " *= require_tree ./../../components\n"
        end
      end

    end
  end
end
