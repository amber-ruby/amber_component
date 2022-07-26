# frozen_string_literal: true

require_relative "lib/amber_component/version"

::Gem::Specification.new do |spec|
  spec.name = "amber_component"
  spec.version = ::AmberComponent::VERSION
  spec.authors = ['Ruby-Amber', 'Mateusz Drewniak', 'Garbus Beach']
  spec.email = ['matmg24@gmail.com', 'piotr.garbus.garbicz@gmail.com']

  spec.summary = "A simple component library which seamlessly hooks into your Rails project."
  spec.description = <<~DESC
    A simple component library which seamlessly hooks into your Rails project
    and allows you to create simple backend components.

    They work like mini controllers which are bound with their view.
  DESC
  spec.homepage = 'https://github.com/amber-ruby/amber_component'
  spec.license = 'MIT'
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = ::Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| ::File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "actionview", ">= 6"
  spec.add_dependency "activemodel", ">= 6"
  spec.add_dependency "activesupport", ">= 6"
  spec.add_dependency "memery", ">= 1.4.1"
  spec.add_dependency "tilt", ">= 2.0.10"
end
