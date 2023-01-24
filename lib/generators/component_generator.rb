# frozen_string_literal: true

require 'fileutils'
require_relative 'amber_component_generator'

# A Rails generator which creates a new Amber component.
class ComponentGenerator < AmberComponentGenerator
  source_root ::File.expand_path('templates', __dir__)
end
