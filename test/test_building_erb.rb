# frozen_string_literals: true

require 'test_helper'
require 'nokogiri'
require 'haml'
require 'byebug'
require_relative './fixtures/example_component'
require_relative './fixtures/ruby_version_component'

class ::TestBuildingErb < ::Minitest::Test
  def test_that_is_be_able_to_build_erb_files
    view = ExampleComponent.call name: 'John Doe' do
      RubyVersionComponent.call
    end

    assert_equal view, <<-HTML.chomp
<div>
  <h1>Hello, John Doe, john_doe@example.com!</h1>
  <p>Welcome to the world of Amber Components!</p>
  <div>
<h1>Ruby version</h1>
<div>
3.1.0
</div>
</div>

</div>
HTML
    doc = Nokogiri::HTML(view)

    header = doc.css('h1').first
    paragraph = doc.css('p').first

    assert_equal header.text, 'Hello, John Doe, john_doe@example.com!'
    assert_equal paragraph.text, 'Welcome to the world of Amber Components!'
  end
end
