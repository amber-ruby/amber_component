require 'test_helper'

class ::ViewBuildTest < ::TestCase
  module ::Some
    module Namespaced
      class Component < ::AmberComponent::Base
        view do
          <<~HTML
            <h2>Some::Namespaced::Component</h2>
            <div class="namespaced">
              <%= yield if block_given? %>
            </div>
          HTML
        end
      end
    end
  end

  class ::InnerComponent < ::AmberComponent::Base
    view do
      <<~HTML
        <div class="inner">
          <h1>I'm the inner component!</h1>
          <div class="content">
            <%= @content %>
          </div>
          <%=
            Some::Namespaced.Component name: "My name" do
              "<b>nested inside Namespaced component</b>"
            end
          %>
        </div>
      HTML
    end
  end

  class ::OuterComponent < ::AmberComponent::Base
    view do
      <<~HTML
        <div class="outer">
          <%= InnerComponent content: 'Siemka!' %>
        </div>
      HTML
    end
  end

  context 'helper methods' do
    should 'correctly render components' do
      view = OuterComponent.call
      assert_equal <<~HTML, view
        <div class="outer">
          <div class="inner">
          <h1>I'm the inner component!</h1>
          <div class="content">
            Siemka!
          </div>
          <h2>Some::Namespaced::Component</h2>
        <div class="namespaced">
          <b>nested inside Namespaced component</b>
        </div>

        </div>

        </div>
      HTML
    end
  end

  context 'view from file' do
    should 'be able to build view from file' do
      view = ::ExampleComponent.call name: 'John Doe'
      assert_equal <<~HTML.chomp, view
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

      assert_equal <<~HTML.chomp, view
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

    should 'build markdown component with Ruby' do
      view = MarkdownComponent.call

      assert_equal <<~HTML, view
        <h1 id="hello-john-doe">Hello John Doe!</h1>

        <p>Your data:</p>

        <ul>
          <li>Email: john_doe@example.com</li>
          <li>Last login: 2022-07-25 11:01:41</li>
          <li>Balance: 200</li>
        </ul>

        <p>Ruby:</p>

        <div>
        <h1>Ruby version</h1>
        <div>
        3.1.0
        </div>
        </div>

      HTML
    end

    should 'build haml components' do
      view = RubyVersionComponent.call

      assert_equal <<~HTML, view
        <div>
        <h1>Ruby version</h1>
        <div>
        3.1.0
        </div>
        </div>
      HTML
    end

    should 'raise error when no view given' do
      error = assert_raises ::AmberComponent::ViewFileNotFound  do
        NoViewComponent.call
      end

      assert_equal error.message, "View for `NoViewComponent` could not be found!"
    end

    should 'raise error when multiple views given' do
      error = assert_raises ::AmberComponent::MultipleViews do
        MultipleViewsComponent.call
      end
      assert_equal error.message, "More than one view file for `MultipleViewsComponent` found!"
    end
  end

  context 'view from class method' do
    should 'prefer class method over file' do
      view = ::MethodAndFileViewComponent.call name: 'John Doe'
      assert_equal view, "Hello John Doe!"
      assert view != "This shouldn't be rendered."
    end

    should 'render view with method only' do
      class OnlyMethodViewComponent < ::AmberComponent::Base
        view do
          "It Works! Hello <%= @name %>!"
        end
      end

      view = OnlyMethodViewComponent.call name: 'John Doe'
      assert !view.nil?
      assert_equal view, "It Works! Hello John Doe!"
    end

    should 'render correct view type from class method' do
      class OnlyMethodHamlViewComponent < ::AmberComponent::Base
        view :haml do
          <<~HAML
            %h1 It Works!
            .card
              .card-title= @name
              .card-content
                ="Hello, " + @name + "!"
          HAML
        end
      end

      view = OnlyMethodHamlViewComponent.call name: 'John Doe'
      assert_equal view, <<~HTML
        <h1>It Works!</h1>
        <div class='card'>
        <div class='card-title'>John Doe</div>
        <div class='card-content'>
        Hello, John Doe!
        </div>
        </div>
      HTML
    end

    should 'be able to render markdown' do
      class OnlyMethodMdViewComponent < ::AmberComponent::Base
        before_render do
          @text = "instance variable text!"
        end

        view :md do
          <<~MARKDOWN
            # It Works!
            <%= @text %>

            **Hello!**
          MARKDOWN
        end
      end

      view = OnlyMethodMdViewComponent.call name: 'John Doe'
      assert_equal view, <<~HTML
        <h1 id="it-works">It Works!</h1>
        <p>instance variable text!</p>

        <p><strong>Hello!</strong></p>
      HTML
    end

    should 'raise EmptyView error whem empty view given' do
      class EmptyMethodViewComponent < ::AmberComponent::Base
        view do
          nil
        end
      end

      error = assert_raises ::AmberComponent::EmptyView do
        EmptyMethodViewComponent.call
      end

      assert_equal error.message, <<~TEXT.squish
        Custom view for `ViewBuildTest::EmptyMethodViewComponent`
        from view method cannot be empty!
      TEXT
    end

    should 'raise UnknownViewType error when unsuported type passed' do
      class UnknownTypeMethodViewComponent < ::AmberComponent::Base
        view :some_future_template_type do
          "!@#$%^&*()(*&^%$#"
        end
      end

      error = assert_raises ::AmberComponent::UnknownViewType do
        UnknownTypeMethodViewComponent.call
      end

      assert_equal error.message, <<~TEXT.squish
        Unknown view type for `ViewBuildTest::UnknownTypeMethodViewComponent` from view method!
        Check return value of param type in `view :[type] do`
      TEXT
    end

    should 'be able to render block when passed from class method' do
      class BlockInViewMethodComponent < ::AmberComponent::Base
        view :haml do
          <<~HAML
            .card
              .card-title= @title
              .card-content
                = yield if block_given?
          HAML
        end
      end

      class NestedComponent < ::AmberComponent::Base
        view :erb do
          "I'm your message passed by block!"
        end
      end

      view = BlockInViewMethodComponent.call title: 'Hello World!' do
        NestedComponent.call
      end

      assert_equal view, <<~HTML
        <div class='card'>
        <div class='card-title'>Hello World!</div>
        <div class='card-content'>
        I'm your message passed by block!
        </div>
        </div>
      HTML
    end
  end

  context 'view from params' do
    should 'prefer params over class method and file' do
      view = ::MethodAndFileViewComponent.call(
        name: 'John Doe',
        view: "Hello from params <%= @name %>!"
      )
      assert_equal view, "Hello from params John Doe!"
      assert view != "This shouldn't be rendered."
      assert view != "Hello John Doe!"
    end

    should 'render view with params only' do
      class OnlyParamsViewComponent < ::AmberComponent::Base; end

      view = OnlyParamsViewComponent.call(
        name: 'John Doe',
        view: "It works from params! Hello <%= @name %>!"
      )
      assert !view.nil?
      assert_equal view, "It works from params! Hello John Doe!"
    end

    should 'render correct view type from class method' do
      class OnlyParamsViewComponent < ::AmberComponent::Base; end

      view = OnlyParamsViewComponent.call(
        name: 'John Doe',
        view: {
          type: :haml,
          content: '="Hello " + @name + " from params!"'
        }
      )
      assert_equal view, "Hello John Doe from params!\n"
    end

    should 'raise EmptyView error whem empty view given' do
      class EmptyParamViewComponent < ::AmberComponent::Base; end

      error = assert_raises ::AmberComponent::EmptyView do
        EmptyParamViewComponent.call(view: {})
      end

      assert_equal error.message, <<~TEXT.squish
        Custom view for `ViewBuildTest::EmptyParamViewComponent`
        from view method cannot be empty!
      TEXT
    end

    should 'raise UnknownViewType error when unsuported type passed' do
      class UnknownTypeParamViewComponent < ::AmberComponent::Base; end

      error = assert_raises ::AmberComponent::UnknownViewType do
        UnknownTypeParamViewComponent.call(
          view: {
            type: :some_future_template_type,
            content: "!@#$%^&*()(*&^%$#"
          }
        )
      end

      assert_equal error.message, <<~TEXT.squish
        Unknown view type for `ViewBuildTest::UnknownTypeParamViewComponent` from view method!
        Check return value of param type in `view :[type] do`
      TEXT
    end

    should 'be able to render block when passed from param' do
      class BlockInViewParamComponent < ::AmberComponent::Base; end

      class NestedComponent < ::AmberComponent::Base
        view :erb do
          "I'm your message passed by block!"
        end
      end

      view = BlockInViewParamComponent.call(
        title: 'Hello World',
        view: "<%= @title %>! <%= yield if block_given? %>"
      ) do
        NestedComponent.call
      end

      assert_equal view, "Hello World! I'm your message passed by block!"
    end
  end
end
