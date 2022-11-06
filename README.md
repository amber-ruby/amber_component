[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![Gem Version](https://img.shields.io/gem/v/amber_component.svg?style=flat)](https://rubygems.org/gems/amber_component)
[![Maintainability](https://api.codeclimate.com/v1/badges/ad84af499e9791933a87/maintainability)](https://codeclimate.com/github/amber-ruby/amber_component/maintainability)
[![CI badge](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml/badge.svg)](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml)
[![Coverage Badge](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/Verseth/6a095c79278b074d79feaa4f8ceeb2a8/raw/amber_component__heads_main.json)](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml)
[![Downloads](https://ruby-gem-downloads-badge.herokuapp.com/amber_component)]((https://rubygems.org/gems/amber_component))

<img src="banner.png" width="500px" style="margin-bottom: 2rem;"/>

# AmberComponent

AmberComponent is a simple component library which seamlessly hooks into your Rails project and allows you to create simple backend components. They work like mini controllers which are bound with their view and stylesheet.

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

## Usage

## Components

Components are located under `app/components`.

Every component consists of:
- a Ruby file which defines its properties, encapsulates logic and may implement helper methods (like a controller)
- a view/template file (html.erb, haml, slim etc.)
- a style file (css, scss, sass etc.)

An individual component which implements a button may look like this.

```ruby
# app/components/button_component.rb

class ButtonComponent < AmberComponent::Base
  prop :label, required: true
end
```

```html
<!-- app/components/button_component/view.html.erb -->

<div class="button_component">
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

### Nested components

It's possible to nest components or provide
custom HTML to a component.

To render the passed nested content call `yield.html_safe` somewhere inside the template/view.

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
        <%= yield.html_safe %>
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
    <h2>This is your task!</h2>
    <%= form_with model: @task do |f| %>
        <%= f.text_field :name %>
        <%= f.text_area :description %>
        <%= f.submit %>
    <% end %>
<% end %>
```

Note that this will raise an error when no block/nested content is provided.

In order to render nested content
only when it is present (will work without nested content)
you can use `yield.html_safe if block_given?`

In general `block_given?` will return `true` when a block/nested content is present, otherwise `false`.

### Components with namespaces

Components may be defined inside modules/namespaces.

```ruby
# app/components/sign_up/button_component.rb

class SignUp::ButtonComponent < AmberComponent::Base
  prop :label, required: true
end
```

```html
<!-- app/components/sign_up/button_component/view.html.erb -->

<div class="sign_up-button_component">
    <%= label %>
</div>
```

```scss
// app/components/sign_up/button_component/style.scss

.sign_up-button_component {
    background-color: indigo;
    border-radius: 1rem;
    transition-duration: 500ms;

    &:hover {
        background-color: blue;
    }
}
```

### Generating Components

You an generate new components by running

```sh
$ bin/rails generate component foo_bar
```

or

```sh
$ bin/rails generate component FooBar
```

This will generate a new component in `app/components/foo_bar_component.rb` along with a view, stylesheet and test file.

## Contribute

Do you want to contribute to AmberComponent? Open the issues page and check for the help wanted label! But before you start coding, please read our [Contributing Guide](https://github.com/amber-ruby/amber_component/blob/main/CONTRIBUTING.md).

Bug reports and pull requests are welcome on GitHub at https://github.com/amber-ruby/amber_component.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
