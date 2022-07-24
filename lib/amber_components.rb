# frozen_string_literal: true

require 'rails'
require 'active_support'
require 'active_support/core_ext'

module ::AmberComponents
  class Error < ::StandardError; end
  class ViewFileNotFound < Error; end
end

require_relative 'amber_components/version'
require_relative 'amber_components/base'
