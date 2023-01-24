# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

module Integration
  class ComponentGeneratorTest < ::GeneratorTestCase
    context 'rails without importmap and js bundling' do
      setup do
        setup_git_repo RAILS_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'generate a new component' do
        assert rails "g #{INSTALL_GENERATOR}"
        git.add
        assert_equal 5, git.diff.entries.size
        %w[some some_component Some SomeComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 9, git.diff.entries.size

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
            +<div class="some_component">
            +  <h1>
            +    Hello from <b>SomeComponent</b>, initialized at: <%= @time %>
            +  </h1>
            +
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
        end
      end

      should 'generate a new namespaced component' do
        assert rails "g #{INSTALL_GENERATOR}"
        git.add
        assert_equal 5, git.diff.entries.size
        %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 9, git.diff.entries.size

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
            +<div class="some_awesome_wonderful_component">
            +  <h1>
            +    Hello from <b>Some::Awesome::WonderfulComponent</b>, initialized at: <%= @time %>
            +  </h1>
            +
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
        end
      end
    end

    context 'rails with importmap' do
      setup do
        setup_git_repo RAILS_IMPORTMAP_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'generate a new component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 8, git.diff.entries.size
        %w[some some_component Some SomeComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 13, git.diff.entries.size

          diff = file_diff component_path('some_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

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
            +<div class="some_component" data-controller="some-component">
            +  <h1>
            +    Hello from <b>SomeComponent</b>, initialized at: <%= @time %>
            +  </h1>
            +
            +  <button data-action="click->some-component#greet">Greet me</button>
            +  
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
        end
      end

      should 'generate a new namespaced component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 8, git.diff.entries.size
        %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 13, git.diff.entries.size

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some--awesome--wonderful-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

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
            +<div class="some_awesome_wonderful_component" data-controller="some--awesome--wonderful-component">
            +  <h1>
            +    Hello from <b>Some::Awesome::WonderfulComponent</b>, initialized at: <%= @time %>
            +  </h1>
            +
            +  <button data-action="click->some--awesome--wonderful-component#greet">Greet me</button>
            +  
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
        end
      end
    end

    context 'rails with jsbundling and haml' do
      setup do
        setup_git_repo RAILS_JSBUNDLING_WEBPACK_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'generate a new component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 7, git.diff.entries.size
        %w[some some_component Some SomeComponent].each do |passed_name|
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 12, git.diff.entries.size

          diff = file_diff component_path('some_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

          diff = file_diff 'app/javascript/controllers/components.js'
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import SomeComponent from "../../components/some_component/controller"
            +application.register("some-component", SomeComponent)
          PATCH

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

          diff = file_diff component_path('some_component', 'view.haml')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +.some_component{ data: { controller: "some-component" } }
            +  %h1
            +    Hello from
            +    %b
            +      SomeComponent
            +    , initialized at:
            +    = @time
            +
            +  %button{ data: { action: "click->some-component#greet" }
            +    Greet me
            +  
            +  %p
            +    = description
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
        end
      end

      should 'generate a new namespaced component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 7, git.diff.entries.size
        %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 12, git.diff.entries.size

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some--awesome--wonderful-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

          diff = file_diff 'app/javascript/controllers/components.js'
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import SomeAwesomeWonderfulComponent from "../../components/some/awesome/wonderful_component/controller"
            +application.register("some--awesome--wonderful-component", SomeAwesomeWonderfulComponent)
          PATCH

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

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'view.haml')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +.some_awesome_wonderful_component{ data: { controller: "some--awesome--wonderful-component" } }
            +  %h1
            +    Hello from
            +    %b
            +      Some::Awesome::WonderfulComponent
            +    , initialized at:
            +    = @time
            +
            +  %button{ data: { action: "click->some--awesome--wonderful-component#greet" }
            +    Greet me
            +  
            +  %p
            +    = description
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
        end
      end
    end

    context 'rails with webpacker sass and slim' do
      setup do
        setup_git_repo RAILS_WEBPACKER_PROJECT_PATH
      end

      teardown do
        reset_git_repo
      end

      should 'generate a new component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 14, git.diff.entries.size
        %w[some some_component Some SomeComponent].each do |passed_name|
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 19, git.diff.entries.size

          diff = file_diff component_path('some_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

          diff = file_diff 'app/javascript/controllers/components.js'
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import SomeComponent from "../../components/some_component/controller"
            +application.register("some-component", SomeComponent)
          PATCH

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

          diff = file_diff component_path('some_component', 'view.slim')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +div.some_component data-controller="some-component"
            +  h1
            +    | Hello from
            +    b SomeComponent
            +    | , initialized at: \#{@time}
            +
            +    button data-action="click->some-component#greet"
            +      | Greet me
            +    
            +  p = description
          PATCH

          diff = file_diff component_path('some_component', 'style.scss')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +.some_component {
            +  h1 {
            +    color: blue;
            +  }
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
        end
      end

      should 'generate a new namespaced component with stimulus' do
        assert rails "g #{INSTALL_GENERATOR} --stimulus"
        git.add
        assert_equal 14, git.diff.entries.size
        %w[some/awesome/wonderful some/awesome/wonderful_component Some::Awesome::Wonderful Some::Awesome::WonderfulComponent].each do |passed_name|
          # with snake_cased name
          assert rails "g #{COMPONENT_GENERATOR} #{passed_name}"
          git.add
          assert_equal 19, git.diff.entries.size

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'controller.js')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import { Controller } from "@hotwired/stimulus"
            +
            +// Read more about Stimulus here https://stimulus.hotwired.dev/
            +export default class extends Controller {
            +  connect() {
            +    console.log("Stimulus controller 'some--awesome--wonderful-component' is connected!")
            +  }
            +
            +  greet() {
            +    alert("Hi there!")
            +  }
            +}
          PATCH

          diff = file_diff 'app/javascript/controllers/components.js'
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +import SomeAwesomeWonderfulComponent from "../../components/some/awesome/wonderful_component/controller"
            +application.register("some--awesome--wonderful-component", SomeAwesomeWonderfulComponent)
          PATCH

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

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'view.slim')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +div.some_awesome_wonderful_component data-controller="some--awesome--wonderful-component"
            +  h1
            +    | Hello from
            +    b Some::Awesome::WonderfulComponent
            +    | , initialized at: \#{@time}
            +
            +    button data-action="click->some--awesome--wonderful-component#greet"
            +      | Greet me
            +    
            +  p = description
          PATCH

          diff = file_diff component_path('some', 'awesome', 'wonderful_component', 'style.scss')
          assert_equal 'new', diff.type
          assert diff.patch.end_with?(<<~PATCH.chomp)
            +.some_awesome_wonderful_component {
            +  h1 {
            +    color: blue;
            +  }
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
        end
      end
    end

  end
end
