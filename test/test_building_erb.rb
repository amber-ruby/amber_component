# frozen_string_literals: true

require 'test_helper'
require_relative './fixtures/example_component'

class ::TestBuildingErb < ::Minitest::Test
  def test_that_is_be_able_to_build_erb_files
    view = ::ExampleComponent.(name: 'John Doe')
    assert view.include? 'John Doe'
    assert view.include? 'john_doe@example.com'
    assert view.include? 'john_doe@example.com'
    assert view.include? '<h1>Hello, John Doe, john_doe@example.com!</h1>'
  end
end
