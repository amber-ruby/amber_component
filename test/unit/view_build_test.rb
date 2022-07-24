require 'test_helper'

class ::ViewBuildTest < ::TestCase
  context 'view from file' do
    should 'be able to build view from file' do
      view = ::ExampleComponent.call name: 'John Doe'
      assert_equal view, <<-HTML.chomp
<div>
  <h1>Hello, John Doe, john_doe@example.com!</h1>
  <p>Welcome to the world of Amber Components!</p>
  
</div>
HTML
      doc = Nokogiri::HTML(view)

      header = doc.css('h1').first
      paragraph = doc.css('p').first

      assert_equal header.text, 'Hello, John Doe, john_doe@example.com!'
      assert_equal paragraph.text, 'Welcome to the world of Amber Components!'
    end

    should 'build embedded components' do
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
    end

    should 'build haml components' do
      view = RubyVersionComponent.call

      assert_equal view, <<-HTML
<div>
<h1>Ruby version</h1>
<div>
3.1.0
</div>
</div>
HTML
    end

    should 'raise error when no view given' do
      assert_raises(::AmberComponent::ViewFileNotFound) do
        NoViewComponent.call
      end
    end

    should 'raise error when multiple views given' do
      assert_raises(::AmberComponent::MultipleViews) do
        MultipleViewsComponent.call
      end
    end
  end
end
