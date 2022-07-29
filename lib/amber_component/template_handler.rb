# frozen_string_literal: true

module ::AmberComponent
  module TemplateHandler
    class << self
      # @param context [AmberComponent::Base]
      # @param content [String]
      # @param type [Symbol, String]
      # @param block [Proc, nil]
      # @return [String]
      def render_from_string(context, content, type, block = nil)
        options = if type.to_sym == :erb
                    { engine_class: ERB }
                  else
                    {}
                  end

        ::Tilt[type].new(options) { content }.render(context, &block)
      end
    end
  end
end

require_relative 'template_handler/erb'
