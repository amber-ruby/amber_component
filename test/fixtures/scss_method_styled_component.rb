# frozen_string_literal: true

require 'ostruct'

class ScssMethodStyledComponent < AmberComponent::Base
  style :scss do
    <<~SCSS
      .card {
        p {
          font-size: bold;
          &:hover {
            color: red;
          }
        }
      }
    SCSS
  end
end
