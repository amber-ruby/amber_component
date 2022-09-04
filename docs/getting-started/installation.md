---
layout: default
title: Installation
parent: Getting started
nav_order: 1
---

# Installation
In your `Gemfile` just add:

```ruby
gem 'amber_component'
```

and run `bundle install`.
Next, to setup your `ApplicationComponent` run:

```sh
rails generate amber_component:install
```

This will create a `app/components/application_component.rb` file with the `ApplicationComponent` class. This class is the base for all your components - similar to `ApplicationController` for controllers.
