# frozen_string_literal: true

# Abstract class which should serve as a superclass
# for all your custom components in this app.
#
# @abstract Subclass to create a new component.
class ::ApplicationComponent < ::AmberComponent::Base
  # Include your global application helper.
  include ::ApplicationHelper
  # Include the helper methods for your application's
  # routes.
  include ::Rails.application.routes.url_helpers
end
