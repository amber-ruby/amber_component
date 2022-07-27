# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'debug'

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
    COMPONENT_GENERATOR = 'amber_component:component'

    def setup
      @original_pwd = ::Dir.pwd
      # change the working directory to the Rails project root
      ::Dir.chdir RAILS_PROJECT_PATH
      # initialize a new Git repo in the root of the Rails project
      @git = ::Git.init(::Dir.pwd)
      @git.add
      # commit the entires project
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
      assert system "rails g #{INSTALL_GENERATOR}"
      @git.add
      assert_equal 1, @git.diff.entries.size
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

      assert system "rails d #{INSTALL_GENERATOR}"
      @git.add
      assert_equal 0, @git.diff.entries.size
    end

    should 'generate and destroy a new component' do
      %w[some some_component Some SomeComponent].each do |passed_name|
        # with snake_cased name
        assert system "rails g #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 4, @git.diff.entries.size

        diff = file_diff component_path('some_component.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +class SomeComponent < ::ApplicationComponent
          +  # Your code goes here
          +
          +  after_initialize do
          +    @time = ::Time.now
          +  end
          +end
        PATCH

        diff = file_diff component_path('some_component', 'view.html.erb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +<h2 class='some_component'>
          +  Hello from <b>SomeComponent</b>, initialized at: <%= @time %>
          +</h2>
        PATCH

        diff = file_diff component_path('some_component', 'style.css')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +.some_component {
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
          +class SomeComponentTest < ::ActiveSupport::TestCase
          +  # test 'the truth' do
          +  #   assert true
          +  # end
          +end
        PATCH

        assert system "rails d #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 0, @git.diff.entries.size
      end
    end

    should 'generate and destroy a new namespaced component' do
      %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
        # with snake_cased name
        assert system "rails g #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 4, @git.diff.entries.size

        diff = file_diff component_path('some', 'awesome', 'wonderful_component.rb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +# frozen_string_literal: true
          +
          +class Some::Awesome::WonderfulComponent < ::ApplicationComponent
          +  # Your code goes here
          +
          +  after_initialize do
          +    @time = ::Time.now
          +  end
          +end
        PATCH

        diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'view.html.erb')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +<h2 class='some_awesome_wonderful_component'>
          +  Hello from <b>Some::Awesome::WonderfulComponent</b>, initialized at: <%= @time %>
          +</h2>
        PATCH

        diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'style.css')
        assert_equal 'new', diff.type
        assert diff.patch.end_with?(<<~PATCH.chomp)
          +.some_awesome_wonderful_component {
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
          +class Some::Awesome::WonderfulComponentTest < ::ActiveSupport::TestCase
          +  # test 'the truth' do
          +  #   assert true
          +  # end
          +end
        PATCH

        assert system "rails d #{COMPONENT_GENERATOR} #{passed_name}"
        @git.add
        assert_equal 0, @git.diff.entries.size
      end
    end

    private

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
