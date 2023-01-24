# frozen_string_literal: true

module ::AmberComponent
  # Class which hooks into Rails
  # and configures the application.
  class Railtie < ::Rails::Railtie
    initializer 'amber_component.assets' do |app|
      app.config.assets.paths << (app.root / 'app' / 'components')
      app.config.assets.paths << (ROOT_GEM_PATH / 'assets' / 'javascripts')
      app.config.assets.precompile += %w[amber_component/stimulus_loading.js]

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
