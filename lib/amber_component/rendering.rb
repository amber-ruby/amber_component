# frozen_string_literal: true

module ::AmberComponent
  # Provides universal methods for rendering components.
  module Rendering
    # Class methods for rendering.
    module ClassMethods
      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def render(**kwargs, &block)
        comp = new(**kwargs)

        comp.render(&block)
      end

      alias call render
    end

    # Instance methods for rendering.
    module InstanceMethods
      # @return [String]
      def render(&block)
        run_callbacks :render do
          element  = render_view(&block)
          styles   = inject_styles
          element += styles unless styles.nil?
          element.html_safe
        end
      end

      # Method used internally by Rails to render an object
      # passed to the `render` method.
      #
      #   render MyComponent.new(some: :attribute)
      #
      # @param _context [ActionView::Base]
      # @return [String]
      def render_in(_context)
        render
      end

      protected

      # @param content [String]
      # @param type [Symbol]
      # @param block [Proc, nil]
      # @return [String]
      def render_string(content, type, block = nil)
        TemplateHandler.render_from_string(self, content, type, block)
      end
    end
  end
end
