# frozen_string_literal: true

require 'action_view'

module ::AmberComponent
  module Helpers
    # Adds a few utility methods for working with CSS
    # inside components.
    module CssHelper
      # Helper method which creates a name for a css class or id
      # which is scoped to the current component class.
      #
      #   self.class #=> Navigation::DropdownMenuComponent
      #   css_id(:list_item) #=> "navigation-dropdown_menu_component--list_item"
      #
      # @param name [String, Symbol]
      # @return [String]
      def css_identifier(name)
        "#{self.class.name.underscore.gsub('/', '-')}--#{name.to_s.underscore}"
      end

      alias css_id css_identifier
    end
  end
end
