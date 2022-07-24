# frozen_string_literal: true

require 'rails'
require 'active_support'
require 'active_support/core_ext'
require 'active_model/callbacks'

module ::AmberComponents
  class Error < ::StandardError; end
end

require_relative 'amber_components/version'
require_relative 'amber_components/base_component'
