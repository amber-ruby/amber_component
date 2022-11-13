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

      should 'install with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 15, git.diff.entries.size

        diff = file_diff 'app/javascript/controllers/index.js'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +// Import and register all your controllers from the importmap under controllers/*
          +
          +import { application } from "controllers/application"
          +
          +// Eager load all controllers defined in the import map under controllers/**/*_controller
          +import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
          +eagerLoadControllersFrom("controllers", application)
          +
          +// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
          +// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
          +// lazyLoadControllersFrom("controllers", application)
          +import { eagerLoadAmberComponentControllers } from "@amber_component/stimulus_loading"
          +eagerLoadAmberComponentControllers(application)
        PATCH

        diff = file_diff 'app/assets/config/manifest.js'
        assert_equal 'modified', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +//= link_tree ../../javascript .js
          +//= link_tree ../../../vendor/javascript .js
          +//= link_tree ../../components .js
        PATCH

        diff = file_diff 'config/importmap.rb'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +pin "application", preload: true
          +pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
          +pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
          +pin_all_from "app/javascript/controllers", under: "controllers"
          +pin "@amber_component/stimulus_loading", to: "amber_component/stimulus_loading.js", preload: true
          +pin_all_from "app/components"
        PATCH

        diff = file_diff 'config/initializers/amber_component.rb'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +::AmberComponent.configure do |c|
          +  c.stimulus = :importmap
          +end
        PATCH

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
      end

    end

    context 'rails with importmap' do
      setup do
        setup_git_repo RAILS_IMPORTMAP_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'install with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 8, git.diff.entries.size

        diff = file_diff 'app/javascript/controllers/index.js'
        assert_equal 'modified', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +import { eagerLoadAmberComponentControllers } from "@amber_component/stimulus_loading"
          +eagerLoadAmberComponentControllers(application)
        PATCH

        diff = file_diff 'app/assets/config/manifest.js'
        assert_equal 'modified', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +//= link_tree ../../components .js
        PATCH

        diff = file_diff 'config/importmap.rb'
        assert_equal 'modified', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +pin "@amber_component/stimulus_loading", to: "amber_component/stimulus_loading.js", preload: true
          +pin_all_from "app/components"
        PATCH

        diff = file_diff 'config/initializers/amber_component.rb'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +::AmberComponent.configure do |c|
          +  c.stimulus = :importmap
          +end
        PATCH

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
      end

    end

    context 'rails with jsbundling' do
      setup do
        setup_git_repo RAILS_WEBPACK_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'install with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 7, git.diff.entries.size

        diff = file_diff 'app/javascript/application.js'
        assert_equal 'modified', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +import "./controllers/components"
        PATCH

        diff = file_diff 'app/javascript/controllers/components.js'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +// This file has been created by `amber_component` and will
          +// register all stimulus controllers from your components
          +import { application } from "./application"
        PATCH

        diff = file_diff 'config/initializers/amber_component.rb'
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +::AmberComponent.configure do |c|
          +  c.stimulus = :jsbundling
          +end
        PATCH

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
      end

    end
  end
end
