# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

module Integration
  class GeneratorTest < ::TestCase
    # @return [String]
    RAILS_PROJECT_PATH = 'test/dummy/rails_7'
    # @return [String]
    COMPONENTS_ROOT_PATH = 'app/components'
    # @return [String]
    COMPONENTS_TEST_ROOT_PATH = 'test/components'
    # @return [String]
    INSTALL_GENERATOR = 'amber_component:install'
    # @return [String]
    COMPONENT_GENERATOR = 'amber_component'

    def setup
      @original_pwd = ::Dir.pwd
      # change the working directory to the Rails project root
      ::Dir.chdir RAILS_PROJECT_PATH
      # initialize a new Git repo in the root of the Rails project
      @git = ::Git.init(::Dir.pwd)
      @git.add
      # commit the entire project
      @git.commit('.')
      assert @git.diff.none?
    end

    def teardown
      # reset all the changes to the Rails project
      @git.clean(force: true)
      @git.reset_hard
      @git = nil
      # remove the Git repo
      ::FileUtils.rm_rf('.git')
      # restore the original working directory
      ::Dir.chdir @original_pwd
    end

    should 'install and uninstall the gem' do
      assert rails "g #{INSTALL_GENERATOR}"
      @git.add
      assert_equal 4, @git.diff.entries.size

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
      @git.add
      assert_equal 0, @git.diff.entries.size
    end

    should 'generate and destroy a new component' do
      assert rails "g #{INSTALL_GENERATOR}"
      @git.add
      assert_equal 4, @git.diff.entries.size
      %w[some some_component Some SomeComponent].each do |passed_name|
        # with snake_cased name
        assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 8, @git.diff.entries.size

        diff = file_diff component_path('some_component.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +class SomeComponent < ::ApplicationComponent
          +  # Props that your component accepts
          +  prop :description, default: -> { 'Default Description' }
          +
          +  after_initialize do
          +    # some initialization
          +    @time = ::Time.now
          +  end
          +end
        PATCH

        diff = file_diff component_path('some_component', 'view.html.erb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +<div class='some_component'>
          +  <h1>
          +    Hello from <b>SomeComponent</b>, initialized at: <%= @time %>
          +  </h1>
          +  <p>
          +    <%= description %>
          +  </p>
          +</div>
        PATCH

        diff = file_diff component_path('some_component', 'style.css')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +.some_component h1 {
          +  color: blue;
          +}
        PATCH

        diff = file_diff component_test_path('some_component_test.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +require 'test_helper'
          +
          +class SomeComponentTest < ::ApplicationComponentTestCase
          +  # For a full list of available assertions see
          +  # https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers
          +
          +  # test 'returns correct html' do
          +  #   render do
          +  #     SomeComponent.call
          +  #   end
          +
          +  #   assert_text 'Hello from SomeComponent'
          +  #   assert_selector "div.some_component p", text: 'Default Description'
          +  # end
          +end
        PATCH

        assert rails "d #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 4, @git.diff.entries.size
      end
      assert rails "d #{INSTALL_GENERATOR}"
    end

    should 'generate and destroy a new namespaced component' do
      assert rails "g #{INSTALL_GENERATOR}"
      @git.add
      assert_equal 4, @git.diff.entries.size
      %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
        # with snake_cased name
        assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 8, @git.diff.entries.size

        diff = file_diff component_path('some', 'awesome', 'wonderful_component.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +class Some::Awesome::WonderfulComponent < ::ApplicationComponent
          +  # Props that your component accepts
          +  prop :description, default: -> { 'Default Description' }
          +
          +  after_initialize do
          +    # some initialization
          +    @time = ::Time.now
          +  end
          +end
        PATCH

        diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'view.html.erb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +<div class='some_awesome_wonderful_component'>
          +  <h1>
          +    Hello from <b>Some::Awesome::WonderfulComponent</b>, initialized at: <%= @time %>
          +  </h1>
          +  <p>
          +    <%= description %>
          +  </p>
          +</div>
        PATCH

        diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'style.css')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +.some_awesome_wonderful_component h1 {
          +  color: blue;
          +}
        PATCH

        diff = file_diff component_test_path('some', 'awesome', 'wonderful_component_test.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +require 'test_helper'
          +
          +class Some::Awesome::WonderfulComponentTest < ::ApplicationComponentTestCase
          +  # For a full list of available assertions see
          +  # https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers
          +
          +  # test 'returns correct html' do
          +  #   render do
          +  #     Some::Awesome::WonderfulComponent.call
          +  #   end
          +
          +  #   assert_text 'Hello from Some::Awesome::WonderfulComponent'
          +  #   assert_selector "div.some_awesome_wonderful_component p", text: 'Default Description'
          +  # end
          +end
        PATCH

        assert rails "d #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 4, @git.diff.entries.size
      end
      assert rails "d #{INSTALL_GENERATOR}"
    end

    private

    # @param command [String]
    # @return [Boolean]
    def rails(command)
      gemfile_path = ::File.expand_path 'Gemfile'
      system "BUNDLE_GEMFILE=#{gemfile_path} bundle exec rails #{command}"
    end

    # @param file_name [String]
    # @return [Git::Diff::DiffFile, nil]
    def file_diff(file_name)
      @git.diff.entries.find { _1.path == file_name }
    end

    # @param args [Array<Symbol, String>]
    # @return [String]
    def component_test_path(*args)
      args.map! &:to_s

      ::File.join(COMPONENTS_TEST_ROOT_PATH, *args)
    end

    # @param args [Array<Symbol, String>]
    # @return [String]
    def component_path(*args)
      args.map! &:to_s

      ::File.join(COMPONENTS_ROOT_PATH, *args)
    end
  end
end
