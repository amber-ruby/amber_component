![CI badge](https://github.com/amber-ruby/amber_component/actions/workflows/ci_ruby.yml/badge.svg)

# AmberComponent

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/amber_component`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add amber_component

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install amber_component

If you're using a Rails application there's an installation generator that you should run:

```sh
$ rails generate amber_component:install
```

## Usage

TODO: Write usage instructions here

### Generators

#### Component

There's a generator for quickly generating new components.

This generator will create all necessary files for a functional
component.

```sh
$ rails generate amber_component:component SomeComponent
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amber-ruby/amber_component.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development

### Setup

To setup this gem for development you should use the setup script.

```sh
$ bin/setup
```

### Console

You can access an IRB with this entire gem preloaded like this

```sh
$ bin/console
```

### Tests

You can run all tests with:

```sh
$ rake test
```

All unit tests:

```sh
$ rake test:unit
```

All integration tests:

```sh
$ rake test:integration
```

### Release

To release a new version, update the version number in `version.rb`, and then run

```sh
$ bundle exec rake release
```

This will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Local installation

To install this gem onto your local machine, run

```sh
$ bundle exec rake install
```

### Problems with bundling

> An error occurred while installing ffi (1.15.5), and Bundler cannot continue.
>
> In Gemfile:
>  sassc was resolved to 2.4.0, which depends on
>    ffi

```sh
$ gem install ffi -- --with-cflags="-fdeclspec"
```

**puma**

> Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
>
>    current directory: /Users/mateuszdrewniak/.rvm/gems/ruby-3.1.0@dupa/gems/puma-5.6.2/ext/puma_http11
>
> /Users/mateuszdrewniak/.rvm/rubies/ruby-3.1.0/bin/ruby -I /Users/mateuszdrewniak/.rvm/rubies/ruby-3.1.0/lib/ruby/3.1.0 -r ./siteconf20220219-40641-4uxhq6.rb extconf.rb --with-cflags\=-Wno-error\=implicit-function-declaration
>
> checking for BIO_read() in -lcrypto... *** extconf.rb failed ***
>
> Could not create Makefile due to some reason, probably lack of necessary
> libraries and/or headers.  Check the mkmf.log file for more details.  You may
> need configuration options.

```sh
$ gem install puma -- --with-cflags="-fdeclspec"
```
