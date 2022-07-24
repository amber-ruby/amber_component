# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  add_group 'Amber Components', 'lib/'
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'amber_components'

require 'minitest/autorun'
require 'shoulda-context'
require 'byebug'


require 'haml'
require 'nokogiri'



# Load all files in the test/fixtures directory
Dir['./test/fixtures/*_component.rb'].each do |file|
  require file
end

class ::TestCase < ::Minitest::Test; end
