# frozen_string_literal: true

require 'simplecov'
require 'simplecov-cobertura'

::SimpleCov.start do
  add_filter '/test/'
  add_group 'Amber Component', 'lib/'
end

::SimpleCov.formatter = ::SimpleCov::Formatter::MultiFormatter.new([
  ::SimpleCov::Formatter::HTMLFormatter,
  ::SimpleCov::Formatter::CoberturaFormatter
])

$LOAD_PATH.unshift ::File.expand_path("../lib", __dir__)
require 'amber_component'

require 'byebug'
require 'minitest/autorun'
require 'rails/railtie'
require 'shoulda-context'

require 'haml'
require 'sassc'
require 'nokogiri'
require 'git'

# Load all files in the test/fixtures directory
::Dir['./test/fixtures/*_component.rb'].each do |file|
  require file
end

class ::TestCase < ::Minitest::Test; end
