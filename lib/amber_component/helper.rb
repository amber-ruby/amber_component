# frozen_string_literal: true

require 'action_view'

module ::AmberComponent
  # Contains methods for quickly rendering
  # components defined under the root namespace `Object`.
  module Helper
  end
end

class ::ActionView::Base
  # Add those convenience methods to all
  # controllers and views.
  include ::AmberComponent::Helper
end
