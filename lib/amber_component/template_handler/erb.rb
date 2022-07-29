# frozen_string_literal: true

require 'action_view'
require 'ostruct'

module ::AmberComponent
  module TemplateHandler
    # Handles rendering ERB with Rails-like syntax
    class ERB < ::ActionView::Template::Handlers::ERB::Erubi
      def initialize(input, properties = {})
        properties[:bufvar]     ||= "@output_buffer"
        properties[:preamble] = "#{properties[:bufvar]}=#{::ActionView::OutputBuffer}.new;"
        super
      end
    end
  end
end
