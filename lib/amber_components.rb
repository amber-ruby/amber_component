# frozen_string_literal: true

require 'rails'
require 'active_support'
require 'active_support/core_ext'

module ::AmberComponent
  class Error < ::StandardError; end
  class ViewFileNotFound < Error; end

  class StyleTypeNotFound < Error; end
  class UnknownStyleType < Error; end
  class EmptyStyle < Error; end
end

require_relative 'amber_components/version'
require_relative 'amber_components/base'
