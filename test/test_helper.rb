# frozen_string_literal: true

require 'simplecov'

::SimpleCov.start do
  add_filter '/test/'
  add_group 'Amber Component', 'lib/'
end

$LOAD_PATH.unshift ::File.expand_path("../lib", __dir__)
require 'amber_component'

require 'minitest/autorun'
require 'rails/railtie'
require 'shoulda-context'
require 'byebug'

require 'haml'
require 'sassc'
require 'nokogiri'
require 'git'

# Load all files in the test/fixtures directory
::Dir['./test/fixtures/*_component.rb'].each do |file|
  require file
end

class ::TestCase < ::Minitest::Test; end
