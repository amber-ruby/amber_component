# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

module Integration
  class InstallGeneratorTest < ::GeneratorTestCase
    context 'rails without importmap and js bundling' do
      setup do
        setup_git_repo RAILS_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'install and uninstall the gem' do
        assert rails "g #{INSTALL_GENERATOR}"
        git.add
        assert_equal 4, git.diff.entries.size

        diff = file_diff component_path('application_component.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +# Abstract class which should serve as a superclass
          +# for all your custom components in this app.
          +#
          +# @abstract Subclass to create a new component.
          +class ::ApplicationComponent < ::AmberComponent::Base
          +  # Include your global application helper.
          +  include ::ApplicationHelper
          +  # Include the helper methods for your application's
          +  # routes.
          +  include ::Rails.application.routes.url_helpers
          +end
        PATCH

        diff = file_diff 'app/assets/stylesheets/application.css'
        assert_equal 'modified', diff.type
        assert diff.patch.include?(<<~PATCH.chomp)
          + *= require_tree ./../../components
        PATCH

        diff = file_diff 'test/application_component_test_case.rb'
        assert_equal 'new', diff.type
        assert diff.patch.include?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +require 'amber_component/test_helper'
          +
          +class ApplicationComponentTestCase < ::ActiveSupport::TestCase
          +  include ::AmberComponent::TestHelper
          +end
        PATCH

        diff = file_diff 'test/test_helper.rb'
        assert_equal 'modified', diff.type
        assert diff.patch.include?(<<~PATCH.chomp)
          +require_relative 'application_component_test_case'
        PATCH

        assert rails "d #{INSTALL_GENERATOR}"
        git.add
        assert_equal 0, git.diff.entries.size
      end

    end
  end
end
