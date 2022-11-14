# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'pathname'
require 'set'

require_relative 'amber_component/configuration'

# Root module of the `amber_component` gem.
module ::AmberComponent
  class Error < ::StandardError; end
  class MissingPropsError < Error; end
  class IncorrectPropTypeError < Error; end
  class ViewFileNotFoundError < Error; end
  class InvalidTypeError < Error; end

  class EmptyViewError < Error; end
  class UnknownViewTypeError < Error; end
  class MultipleViewsError < Error; end

  # @return [Pathname]
  ROOT_GEM_PATH = ::Pathname.new ::File.expand_path('..', __dir__)

  class << self
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # @yieldparam [Configuration]
    # @return [void]
    def configure
      yield configuration
    end
  end
end

require_relative 'amber_component/version'
require_relative 'amber_component/helpers'
require_relative 'amber_component/typed_content'
require_relative 'amber_component/template_handler'
require_relative 'amber_component/views'
require_relative 'amber_component/assets'
require_relative 'amber_component/rendering'
require_relative 'amber_component/props'
require_relative 'amber_component/base'
require_relative 'amber_component/railtie' if defined?(::Rails::Railtie)
