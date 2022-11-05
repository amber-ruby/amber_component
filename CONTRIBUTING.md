<img src="banner.png" width="500px" style="margin-bottom: 2rem;"/>

# Contributing

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
>    current directory: ~/.rvm/gems/ruby-3.1.0@dupa/gems/puma-5.6.2/ext/puma_http11
>
> ~/.rvm/rubies/ruby-3.1.0/bin/ruby -I ~/.rvm/rubies/ruby-3.1.0/lib/ruby/3.1.0 -r ./siteconf20220219-40641-4uxhq6.rb extconf.rb --with-cflags\=-Wno-error\=implicit-function-declaration
>
> checking for BIO_read() in -lcrypto... *** extconf.rb failed ***
>
> Could not create Makefile due to some reason, probably lack of necessary
> libraries and/or headers.  Check the mkmf.log file for more details.  You may
> need configuration options.

```sh
$ gem install puma -- --with-cflags="-fdeclspec"
```
