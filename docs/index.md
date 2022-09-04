---
layout: default
title: Home
nav_order: 1
permalink: /
---

# AmberComponent (v{{ site.data.amber_component.version }})

A simple server-side component library which seamlessly hooks into your Rails project and allows you to create simple backend components. They work like mini controllers which are bound with their view.

Created by [Garbus Beach]({{ site.data.amber_component.garbus_beach_url }}){:target="_blank"}
and
[Mateusz Drewniak]({{ site.data.amber_component.mateusz_drewniak_url }}){:target="_blank"}.

## Example usage:

### Component (`app/components/user_component.rb`)

```ruby
class UserComponent < AmberComponent::Base
  before_render do
    @user = User.new(
      name: @name,
      email: @email,
      balance: @balance
    )
  end
end
```

### Template (`app/components/user_component/view.erb`)

```erb
<div class="card">
  Name: <%= @user.name %>
  Email: <%= @user.email %>
  Balance: <%= @user.balance %>
</div>
```

### Usage: (anywhere in your app)

```erb
<%= UserComponent.call name: 'John', email: 'john.doe@example.com', balance: 12.00 %>
```
*psst! - Haml, Markdown and Slim are also supported!*

[Get started now](/installation/getting_started/){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View it on GitHub](https://github.com/amber-ruby/amber_component){: .btn .fs-5 .mb-4 .mb-md-0 target="_blank"}