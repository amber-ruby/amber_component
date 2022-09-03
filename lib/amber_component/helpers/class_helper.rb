# frozen_string_literal: true

require 'action_view'

module ::AmberComponent
  module Helpers
    # Adds class-specific utilities.
    module ClassHelper
      # Name of the constant this class/module is saved in (in the parent module).
      #
      # @return [String]
      def const_name
        name.split('::').last
      end

      # Get the exact place where this class/module has been defined.
      #
      # @return [Array(String, Integer), Array(Boolean, Integer)] File path followed by line number.
      def source_location
        module_parent.const_source_location const_name
      end
    end
  end
end
