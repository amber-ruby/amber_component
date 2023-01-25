# frozen_string_literal: true

module ::AmberComponent
  # Provides code which handles rendering different
  # template languages outside of Rails.
  module TemplateHandler
    class << self
      # @param context [AmberComponent::Base]
      # @param content [String]
      # @param type [Symbol, String]
      # @param block [Proc, nil]
      # @return [String]
      def render_from_string(context, content, type, block = nil)
        tilt_handler = ::Tilt[type]
        raise UnknownViewTypeError, <<~ERR.squish unless tilt_handler
          Unknown view type for `#{context.class}`!
          Check return value of param type in `view type: :[type]`
          or the view file extension.
        ERR

        tilt_handler.new { content }.render(context, &block).html_safe
      end
    end
  end
end
