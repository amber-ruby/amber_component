# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'amber_components'

require 'minitest/autorun'
require 'shoulda-context'
require 'byebug'
require 'simplecov'

require 'haml'
require 'nokogiri'

SimpleCov.start do
  add_filter '/test/'
  add_group 'Amber Components', '/lib/'
end

# Load all files in the test/fixtures directory
Dir['./test/fixtures/*_component.rb'].each do |file|
  require file
end

class ::TestCase < ::Minitest::Test; end
