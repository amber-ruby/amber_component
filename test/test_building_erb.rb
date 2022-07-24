# frozen_string_literals: true

require 'test_helper'
require 'nokogiri'
require_relative './fixtures/example_component'

class ::TestBuildingErb < ::Minitest::Test
  def test_that_is_be_able_to_build_erb_files
    view = ExampleComponent.(name: 'John Doe')
    assert_equal view, "<div>\n  <h1>Hello, John Doe, john_doe@example.com!</h1>\n  <p>Welcome to the world of Amber Components!</p>\n</div>"
    doc = Nokogiri::HTML(view)

    header = doc.css('h1').first
    paragraph = doc.css('p').first

    assert_equal header.text, 'Hello, John Doe, john_doe@example.com!'
    assert_equal paragraph.text, 'Welcome to the world of Amber Components!'
  end
end
