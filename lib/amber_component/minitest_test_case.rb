# frozen_string_literal: true

require_relative 'test_helper'

module AmberComponent
  # A base class for component tests with Minitest
  class MinitestTestCase < ::Minitest::Test
    include TestHelper
  end
end
