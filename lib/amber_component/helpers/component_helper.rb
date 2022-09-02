# frozen_string_literal: true

require 'action_view'

module ::AmberComponent
  module Helpers
    # Contains methods for quickly rendering
    # components defined under the root namespace `Object`.
    module ComponentHelper
    end
  end
end

class ::ActionView::Base
  # Add those convenience methods to all
  # controllers and views.
  include ::AmberComponent::Helpers::ComponentHelper
end
