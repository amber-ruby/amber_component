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

        inject_into_file 'app/assets/stylesheets/application.css', after: "*= require_tree .\n" do
          " *= require_tree ./../../components\n"
        end
      end
    end
  end
end
