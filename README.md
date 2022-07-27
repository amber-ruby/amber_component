# AmberComponents

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/amber_components`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add amber_components

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install amber_components

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/amber_components.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Problems

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
