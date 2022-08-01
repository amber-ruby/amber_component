# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

module ::AmberComponent
  class Error < ::StandardError; end
  class ViewFileNotFound < Error; end
  class InvalidType < Error; end

  class EmptyView < Error; end
  class UnknownViewType < Error; end
  class MultipleViews < Error; end

  class EmptyStyle < Error; end
  class UnknownStyleType < Error; end
  class MultipleStyles < Error; end
end

require_relative 'amber_component/version'
require_relative 'amber_component/helpers'
require_relative 'amber_component/typed_content'
require_relative 'amber_component/template_handler'
# require_relative 'amber_component/styles'
require_relative 'amber_component/views'
require_relative 'amber_component/assets'
require_relative 'amber_component/rendering'
require_relative 'amber_component/base'
