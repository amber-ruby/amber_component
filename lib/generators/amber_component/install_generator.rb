# frozen_string_literal: true

require 'fileutils'

module ::AmberComponent
  module Generators
    # A Rails generator which installs the `amber_component`
    # library in a Rails project.
    class InstallGenerator < ::Rails::Generators::Base
      desc 'Install the AmberComponent gem'
      source_root ::File.expand_path('templates', __dir__)

      class_option :stimulus,
                   desc: "Configure the app to use Stimulus.js wih components to make them interactive " \
                         "[options: importmap (default), webpacker (legacy), jsbundling, webpack, esbuild, rollup]"

      class_option :styles,
                   desc: "Configure the app to generate components with a particular stylesheet format " \
                         "[options: css (default), scss, sass]"

      class_option :views,
                   desc: "Configure the app to generate components with a particular view format " \
                         "[options: erb (default), haml, slim]"

      def setup
        detect_stimulus
        detect_styles
        detect_views
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
        create_initializer
      end

      private

      def detect_styles
        styles_option = options[:styles]&.to_sym
        if !styles_option.nil? && !Configuration::ALLOWED_STYLES.include?(styles_option)
          raise ::ArgumentError, "no such `stylesheet_format` as #{styles_option.inspect}"
        end

        @styles =
          if styles_option
            styles_option
          elsif defined?(::SassC)
            :scss
          else
            :css
          end
      end

      def detect_views
        views_option = options[:views]&.to_sym
        if !views_option.nil? && !Configuration::ALLOWED_VIEWS.include?(views_option)
          raise ::ArgumentError, "no such `view_format` as #{views_option.inspect}"
        end

        @views =
          if views_option
            views_option
          elsif defined?(::Haml)
            :haml
          elsif defined?(::Slim)
            :slim
          else
            :erb
          end
      end

      def detect_stimulus
        stimulus_option = options[:stimulus]&.to_sym
        return unless stimulus_option

        case stimulus_option
        when :stimulus
          if defined?(::Jsbundling)
            stimulus_jsbundling!
          elsif defined?(::Webpacker)
            stimulus_webpacker!
          else
            stimulus_importmap!
          end
        when :importmap
          stimulus_importmap!
        when :jsbundling, :webpack, :esbuild, :rollup
          stimulus_jsbundling!
        when :webpacker
          stimulus_webpacker!
        else
          raise ::ArgumentError,
                "no such stimulus integration as `#{options[:stimulus].inspect}`"
        end
      end

      def assert_styles
        return if options[:styles].nil?
        return if options[:styles].nil?
      end

      def configure_stimulus
        case @stimulus
        when :importmap  then configure_stimulus_importmap
        when :jsbundling then configure_stimulus_jsbundling
        when :webpacker  then configure_stimulus_webpacker
        end
      end

      def create_initializer
        create_file 'config/initializers/amber_component.rb', <<~RUBY
          # frozen_string_literal: true

          ::AmberComponent.configure do |c|
            c.stimulus = #{@stimulus.inspect} # #{Configuration::STIMULUS_INTEGRATIONS.to_a}
            c.stylesheet_format = #{@styles.inspect} # #{Configuration::ALLOWED_STYLES.to_a}
            c.view_format = #{@views.inspect} # #{Configuration::ALLOWED_VIEWS.to_a}
          end
        RUBY
      end

      def stimulus_jsbundling!
        @stimulus = :jsbundling
      end

      def stimulus_importmap!
        @stimulus = :importmap
      end

      def stimulus_webpacker!
        @stimulus = :webpacker
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
