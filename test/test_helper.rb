# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'amber_components'
require 'minitest/autorun'
require 'shoulda-context'

class ::TestCase < ::Minitest::Test
end
