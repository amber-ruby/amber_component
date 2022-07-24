# frozen_string_literal: true

require 'ostruct'

class MethodStyledComponent < AmberComponent::Base
  def style
    "p {font-size: bold;}"
  end
end
