# frozen_string_literal: true

require 'ostruct'

class MethodStyledComponent < AmberComponent::Base
  style :scss do
    <<~SCSS
      p {
        font-size: bold;
      }
    SCSS
  end
end
