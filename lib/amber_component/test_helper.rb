# frozen_string_literal: true

module AmberComponent
  # Provides assertions for the rendered
  # HTML of components.
  module TestHelper
    begin
      require 'capybara/minitest'
      include ::Capybara::Minitest::Assertions

      def page
        @page ||= ::Capybara::Node::Simple.new(@rendered_content)
      end
    rescue ::LoadError
      nil
    end

    # @return [Nokogiri::HTML]
    def document
      ::Nokogiri::HTML.fragment(@rendered_content)
    end
    alias doc document
    alias html document

    # @param content [String]
    # @return [Nokogiri::HTML]
    def render(content = nil)
      @page = nil
      @rendered_content = content || yield
      document
    end
    alias render_inline render
  end
end
