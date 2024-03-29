[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Gem Version](https://img.shields.io/gem/v/amber_component.svg?style=flat)](https://rubygems.org/gems/amber_component)
[![Maintainability](https://api.codeclimate.com/v1/badges/ad84af499e9791933a87/maintainability)](https://codeclimate.com/github/amber-ruby/amber_component/maintainability)
[![CI badge](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml/badge.svg)](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml)
[![Coverage Badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Verseth/6a095c79278b074d79feaa4f8ceeb2a8/raw/amber_component__heads_main.json)](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml)
<!-- [![Downloads](https://ruby-gem-downloads-badge.herokuapp.com/amber_component)]((https://rubygems.org/gems/amber_component)) -->

<img src="banner.png" width="500px" style="margin-bottom: 2rem;"/>

# AmberComponent

AmberComponent is a simple component library which seamlessly hooks into your Rails project and allows you to create simple backend components which consist of a Ruby controller, view, stylesheet and even a JavaScript controller (using [Stimulus](https://stimulus.hotwired.dev/)).

Created by [Garbus Beach](https://github.com/garbusbeach) and [Mateusz Drewniak](https://github.com/Verseth).

## Getting started

You can read a lot more about AmberComponent in its [official docs](https://ambercomponent.com).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add amber_component

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install amber_component

If you're using a Rails application there's an installation generator that you should run:

```sh
$ bin/rails generate amber_component:install
```

Amber component supports [Stimulus](https://stimulus.hotwired.dev/) to make your components
reactive using JavaScript.

If you want to use stimulus you should install this gem with the `--stimulus` flag

```sh
$ bin/rails generate amber_component:install --stimulus
```

## Usage

### Components

Components are located under `app/components`. And their tests under `test/components`.

Every component consists of:
- a Ruby file which defines its properties, encapsulates logic and may implement helper methods (like a controller)
- a view/template file (html.erb, haml, slim etc.)
- a style file (css, scss, sass etc.)
- [optional] a JavaScript file with a Stimulus controller (if you installed the gem with `--stimulus`)

`amber_component` automatically detects what kind of view and stylesheet formats your app is configured to use.

So if you've got `haml-rails`, components will be generated with `haml`. When your app uses `slim-rails`, components will be generated with `slim`. When your `Gemfile` contains `sassc-rails`, components will use `scss` etc.

All of these formats can be overridden in
an initializer or by adding arguments to the component generator.

```
app/components/
├─ [name]_component.rb
└─ [name]_component/
   ├─ style.css     # may be .sass or .scss
   ├─ view.html.erb
   └─ controller.js # if stimulus is configured
test/components/
└─ [name]_component_test.rb
```

An individual component which implements a button may look like this.

```ruby
# app/components/button_component.rb

class ButtonComponent < AmberComponent::Base
  prop :label, required: true
end
```

```html
<!-- app/components/button_component/view.html.erb -->

<div class="button_component"
     data-controller="button-component"
     data-action="click->button-component#greet">
    <%= label %>
</div>
```

```scss
// app/components/button_component/style.scss

.button_component {
    background-color: indigo;
    border-radius: 1rem;
    transition-duration: 500ms;

    &:hover {
        background-color: blue;
    }
}
```

If you used the `--stimulus` option when installing the gem, a JS controller will be generated as well.
```js
// app/components/button_component/controller.js

import { Controller } from "@hotwired/stimulus"

// Read more about Stimulus here https://stimulus.hotwired.dev/
export default class extends Controller {
  connect() {
    console.log("Stimulus controller 'button-component' is connected!")
  }

  greet() {
    alert("Hi there!")
  }
}

```

You can render this component in other components or in a Rails view.

```html
<!-- app/controller/foo/index.html.erb -->

<h1>We're inside FooController</h1>

<!-- using a helper method -->
<%= button_component label: 'Click me!' %>
<!-- calling a method on the component class -->
<%= ButtonComponent.call label: 'Click me!' %>
```

Or even directly in Ruby

```ruby
# Calling a method on the component class. Outputs an HTML string.
ButtonComponent.call label: 'Click me!'
#=> '<div class="button_component">Click me!</div>'
```

### Components with namespaces

Components may be defined inside multiple modules/namespaces.

```ruby
# app/components/sign_up/button_component.rb

class SignUp::ButtonComponent < AmberComponent::Base
  prop :label, required: true
end
```

```html
<!-- app/components/sign_up/button_component/view.html.erb -->

<div class="sign_up_button_component">
    <%= label %>
</div>
```

```scss
// app/components/sign_up/button_component/style.scss

.sign_up_button_component {
    background-color: indigo;
    border-radius: 1rem;
    transition-duration: 500ms;

    &:hover {
        background-color: blue;
    }
}
```

You can render such a component by calling the `::call` method
on its class, or by using the helper method defined on its parent module.

```ruby
SignUp::ButtonComponent.call label: 'Sign up!'
SignUp.button_component label: 'Sign up!'
```

### Generating Components

You can generate new components by running

```sh
$ bin/rails generate component [name]
```

Name of the component may be PascalCased like `FooBar` or snake_cased `foo_bar`

This will generate a new component in `app/components/[name]_component.rb` along with a view, stylesheet, test file and a stimulus controller (if configured).

```
app/components/
├─ [name]_component.rb
└─ [name]_component/
   ├─ style.css     # may be `.scss` or `.sass`
   ├─ view.html.erb # may be `.haml` or `.slim`
   └─ controller.js # if stimulus is configured
test/components/
└─ [name]_component_test.rb
```

View and stylesheet formats can be overridden by providing options.

```
-v, [--view=VIEW]          # Indicate what type of view should be generated eg. [:erb, :haml, :slim]
--styles, -c, [--css=CSS]  # Indicate what type of styles should be generated eg. [:css, :scss, :sass]
```

### Component properties

There is a neat prop DSL.

```ruby
# app/components/comment_component.rb

class CommentComponent < ApplicationComponent
    # will raise an error when not present
    prop :body, required: true
    # will raise an error when an object of a different
    # class is received (uses `is_a?`)
    prop :author, type: User, allow_nil: true
    # the default value
    prop :date, default: -> { DateTime.now }
end
```

Props can be passed as keyword arguments
to the `::call` method of the component class
or the helper method.

```ruby
CommentComponent.call body: 'Foo bar', author: User.first
# only in views and other components
comment_component body: 'Foo bar', author: User.first
```

### Helper methods

Defining helper methods which are available
in the template is extremely easy.

Just define a method on the component class.

```ruby
# app/components/comment_component.rb

class CommentComponent < ApplicationComponent
    # you can also include helper modules
    include SomeHelper

    prop :body, required: true
    prop :author, type: Author, allow_nil: true
    prop :date, default: -> { DateTime.now }

    private

    def humanized_date
        date.strftime '%Y-%m-%d %H:%M'
    end

    def author_name
        author&.name || 'Unknown'
    end

    def author_avatar
        author&.avatar_url || User.placeholder_avatar_url
    end
end
```

```html
<!-- app/components/comment_component/view.html.erb -->

<div class="comment_component">
    <div class="comment_header">
        <img src="<%= author_avatar %>" alt="<%= author_name %> avatar">

        <div><%= author_name %></div>
        <div class="comment_date"><%= humanized_date %></div>
    </div>

    <div class="comment_content">
        <%= body %>
    </div>
</div>
```

### Overriding prop getters and setters

Getters and setters for properties are
defined in a module which means that you can override them and call them with `super`.

```ruby
# app/components/priority_icon_component.rb

class PriorityIconComponent < ApplicationComponent
    PriorityStruct = Struct.new :icon, :color

    PRIORITY_MAP = {
        low: PriorityStruct.new('fa-solid fa-chevrons-down', 'green'),
        medium: PriorityStruct.new('fa-solid fa-chevron-up', 'yellow'),
        high: PriorityStruct.new('fa-solid fa-chevrons-up', 'red')
    }

    prop :severity, default: -> { :low }

    def severity=(val)
      # super will call the original
      # implementation of the setter
      super(PRIORITY_MAP[val])
    end
end
```

```html
<!-- app/components/priority_icon_component/view.html.erb -->

<i style="color: <%= severity&.color %>;" class="<%= severity&.icon %>"></i>
```

### Nested components

It's possible to nest components or provide
custom HTML to a component.

This works similarly to React's `props.children`.

To render the passed nested content call `children(&block)` somewhere inside the ERB template/view.
If you're using another template language like Haml,
you may need to use `children{yield}` instead. This difference
is due to how these templates are compiled.

```ruby
# app/components/modal_component.rb

class ModalComponent < ApplicationComponent
    prop :id, required: true
    prop :title, required: true
end
```

```html
<!-- app/components/modal/view.html.erb -->

<div id="<%= id %>" class="modal_component">
    <div class="model_header">
        <%= title %>
    </div>

    <div class="modal_body">
        <!-- nested content will be rendered here -->
        <%= children(&block) %>
    </div>

    <div class="modal_footer">
        <div class="modal_close_button"></div>
    </div>
<div>
```

You can pass a body to this modal by passing
a block.

```erb
<!-- app/controller/tasks/show.html.erb -->

<%= ModalComponent.call id: 'update-task-modal' title: 'Update the task' do %>
    <!-- You can provide HTML and render other components -->
    <h2>This is your task!</h2>
    <%= form_with model: @task do |f| %>
        <%= f.text_field :name %>
        <%= f.text_area :description %>
        <%= f.submit %>
    <% end %>
    <%= OtherComponent.call some: 'prop' %>
<% end %>
```

Note that this will raise an error when no block/nested content is provided.

In order to render nested content
only when it is present (will work without nested content)
you can use `children(&block) if block_given?` in ERB templates (or `children{yield} if block_given?` for Haml and others)

In general `block_given?` will return `true` when a block/nested content is present, otherwise `false`.
You can use it to render content conditionally based on
whether nested content is present.

### Rails helpers inside component templates

Component views/template files can make use
of all ActionView helpers and Rails route helpers.

This makes component views very flexible and convenient.

```erb
<!-- app/components/login_form_component/view.html.erb -->

<%= form_with url: sign_up_path, class: "login_form_component" do |f| %>
  <%= f.label :first_name %>
  <%= f.text_field :first_name %>

  <%= f.label :last_name %>
  <%= f.text_field :last_name %>

  <%= f.label :email, "Email Address" %>
  <%= f.text_field :email %>

  <%= f.label :password %>
  <%= f.password_field :password %>

  <%= f.label :password_confirmation, "Confirm Password" %>
  <%= f.password_field :password_confirmation %>

  <%= f.submit "Create account" %>
<% end %>
```

### Configuration

This gem can be configured in an initializer.
If you used the installer generator it should already be present.

```ruby
# config/initializers/amber_component.rb

::AmberComponent.configure do |c|
    c.stimulus = nil # [nil, :importmap, :webpacker, :jsbundling, :webpack, :esbuild, :rollup]
    c.stylesheet_format = :css # [:css, :scss, :sass]
    c.view_format = :erb # [:erb, :haml, :slim]
end
```

### Testing Components

### Rails

After setting up this gem with the rails generator
`rails generate amber_component:install` a new abstract
test class will be available called `ApplicationComponentTestCase`.

It provides a handful of helper methods to make it
easier to inspect the rendered HTML.

A simple test file may look like this:

```ruby
# test/components/foo_component_test.rb

require 'test_helper'

class FooComponentTest < ApplicationComponentTestCase
    test 'render correct HTML' do
        # Specify what the assertions are supposed to
        # check against.
        #
        # There can be multiple renders in one test
        # but they override the previous one.
        # So there is only one rendered component
        # at any given time.
        render do
            FooComponent.call some: 'prop'
        end

        # Assertions on the rendered HTML

        # Use a CSS selector
        assert_selector ".foo_component span.my_class", text: 'Some Text'
        # Check text
        assert_text 'Amber Component is awesome!'
    end
end
```

A full list of available assertions can be found [here](https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers).

### Non Rails

There is a test case class for minitest. You can
access it by requiring `'amber_component/minitest_test_case'`.

It has the same assertion methods as the Rails test case class.
It requires [capybara](https://github.com/teamcapybara/capybara) to be installed and present in the Gemfile.

A full list of available assertions can be found [here](https://rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers).

```ruby
require 'amber_component/minitest_test_case'

class FooComponentTest < AmberComponent::MinitestTestCase
    def test_render_correct_html
        # Specify what the assertions are supposed to
        # check against.
        #
        # There can be multiple renders in one test
        # but they override the previous one.
        # So there is only one rendered component
        # at any given time.
        render do
            FooComponent.call some: 'prop'
        end

        # Assertions on the rendered HTML

        # Use a CSS selector
        assert_selector ".foo_component span.my_class", text: 'Some Text'
        # Check text
        assert_text 'Amber Component is awesome!'
    end
end
```

There is also a helper module which provides all of these assertions
under `'amber_component/test_helper'`.

```ruby
require 'amber_component/test_helper'

class MyAbstractTestCase < ::Minitest::Test
    include ::AmberComponent::TestHelper
end
```

Note that this module has only been tested with minitest and rails test suites,
so it may require overriding or implementing a few methods to work with other test suites.

## Contribute

Do you want to contribute to AmberComponent? Open the issues page and check for the help wanted label! But before you start coding, please read our [Contributing Guide](https://github.com/amber-ruby/amber_component/blob/main/CONTRIBUTING.md).

Bug reports and pull requests are welcome on GitHub at https://github.com/amber-ruby/amber_component.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
