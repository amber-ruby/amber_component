# frozen_string_literal: true

require 'fileutils'

module ::AmberComponent
  module Generators
    # A Rails generator which installs the `amber_component`
    # library in a Rails project.
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Install the AmberComponent gem'
      source_root ::File.expand_path('templates', __dir__)

      # @return [Array<Symbol>]
      STIMULUS_INTEGRATIONS = %i[stimulus importmap webpacker jsbundling webpack esbuild rollup].freeze

      class_option :stimulus,
                   desc: "Configure the app to use Stimulus.js wih components to make them interactive " \
                         "[options: importmap (default), webpacker (legacy), jsbundling, webpack, esbuild, rollup]"

      def setup
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
        configure_stimulus
      end

      private

      def configure_stimulus
        stimulus = options[:stimulus]&.to_sym
        return unless stimulus

        case stimulus
        when :stimulus
          if defined?(::Jsbundling)
            stimulus_integration = :jsbundling
            configure_stimulus_jsbundling
          elsif defined?(::Webpacker)
            stimulus_integration = :webpacker
            configure_stimulus_webpacker
          else
            stimulus_integration = :importmap
            configure_stimulus_importmap
          end
        when :importmap
          stimulus_integration = :importmap
          configure_stimulus_importmap
        when :jsbundling, :webpack, :esbuild, :rollup
          stimulus_integration = :jsbundling
          configure_stimulus_jsbundling
        when :webpacker
          stimulus_integration = :webpacker
          configure_stimulus_webpacker
        end

        create_file 'config/initializers/amber_component.rb', <<~RUBY
          # frozen_string_literal: true

          ::AmberComponent.configure do |c|
            c.stimulus = :#{stimulus_integration}
          end
        RUBY
      end

      def configure_stimulus_importmap
        install_importmap
        install_stimulus
        append_file 'config/importmap.rb', <<~RUBY
          pin "@amber_component/stimulus_loading", to: "amber_component/stimulus_loading.js", preload: true
          pin_all_from "app/components"
        RUBY
        append_file 'app/javascript/controllers/index.js', <<~JS
          import { eagerLoadAmberComponentControllers } from "@amber_component/stimulus_loading"
          eagerLoadAmberComponentControllers(application)
        JS
        append_file 'app/assets/config/manifest.js', %(//= link_tree ../../components .js\n)
      end

      def configure_stimulus_jsbundling
        install_stimulus
        append_file 'app/javascript/application.js', %(import "./controllers/components"\n)
        create_file 'app/javascript/controllers/components.js', <<~JS
          // This file has been created by `amber_component` and will
          // register all stimulus controllers from your components
          import { application } from "./application"
        JS
      end

      def configure_stimulus_webpacker
        install_stimulus
        append_file 'app/javascript/packs/application.js', %(import "controllers"\n)
        append_file 'app/javascript/controllers/index.js', %(import "./components"\n)
        create_file 'app/javascript/controllers/components.js', <<~JS
          // This file has been created by `amber_component` and will
          // register all stimulus controllers from your components
          import { application } from "./application"
        JS
      end

      # @return [void]
      def install_importmap
        return if ::File.exist?('config/importmap.rb') && defined?(::Importmap)

        unless defined?(::Importmap)
          system 'gem install importmap-rails'
          gem 'importmap-rails'
          system 'bundle install'
        end
        rake 'importmap:install'
      end

      # @return [void]
      def install_stimulus
        return if defined?(::Stimulus)

        system 'gem install stimulus-rails'
        gem 'stimulus-rails'
        system 'bundle install'
        rake 'stimulus:install'
      end

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
