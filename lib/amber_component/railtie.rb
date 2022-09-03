# frozen_string_literal: true

module ::AmberComponent
  # Class which hooks into Rails
  # and configures the application.
  class Railtie < ::Rails::Railtie
    initializer 'amber_component.initialization' do |app|
      app.config.assets.paths << (app.root / 'app' / 'components')

      next if ::Rails.env.production?

      components_root = app.root / 'app' / 'components'
      component_paths = ::Dir[components_root / '**' / '*.rb']
      app.config.eager_load_paths += component_paths

      ::ActiveSupport::Reloader.to_prepare do
        component_paths.each { |file| require_dependency(components_root / file) }
      end
    end
  end
end
