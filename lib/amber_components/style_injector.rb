# frozen_string_literal: true

require 'nokogiri'

# Helper class for injecting styles into DOM.
class ::AmberComponent::StyleInjector
  class << self

    # Injects styles into the DOM, or returns string if
    # DOM stucture is not available.
    #
    # @param style [String]
    # @return [String, nil]
    def inject(style)
      injector = new(style)
      injector.run
    end
  end

  # @param style [String]
  def initialize(style)
    @style = style
  end

  # @return [void]
  def run
    return dom_tag unless dom_available?

    insert_style_in_head
    nil
  end

  private

  # @return [Boolean]
  def dom_available?
    false
    # check for header in DOM rendrer
  end

  # @return [void]
  def insert_style_in_head
    false
  end

  # @return [String]
  def dom_tag
    "<style type='text/css'>#{@style}</style>"
  end
end
