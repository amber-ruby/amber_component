# frozen_string_literal: true

require 'ostruct'

class ScssMethodStyledComponent < AmberComponent::Base
  def style
    {
      content: '.card { p {font-size: bold; &:hover {color: red;}} }',
      type: 'scss'
    }
  end
end
