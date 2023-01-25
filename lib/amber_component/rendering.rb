# frozen_string_literal: true

module ::AmberComponent
  # Provides universal methods for rendering components.
  module Rendering

    # @return [Symbol]
    RENDER_TEMPLATE_METHOD_NAME = :__render

    # Class methods for rendering.
    module ClassMethods
      # @param kwargs [Hash{Symbol => Object}]
      # @return [String]
      def render(**kwargs, &block)
        new(**kwargs).render(&block)
      end

      alias call render

      # @return [Boolean]
      def compiled?
        return false if defined?(::Rails.env) && ::Rails.env.development?

        method_defined?(RENDER_TEMPLATE_METHOD_NAME)
      end

      # @param force [Boolean] force recompilation
      # @return [void]
      def compile(force: false)
        return if compiled? && !force
        return if template_handler.nil?

        render_template_method_redefinition_lock.synchronize do
          silence_redefinition_of_method(RENDER_TEMPLATE_METHOD_NAME)
          # rubocop:disable Style/EvalWithLocation
          class_eval <<~CODE, view_path.to_s, 0 # rubocop:disable Style/DocumentDynamicEvalDefinition
            def #{RENDER_TEMPLATE_METHOD_NAME}(local_assigns, output_buffer, &block)
              #{compiled_template_source}
            end
          CODE
          # rubocop:enable Style/EvalWithLocation
        end
      end

      # @return [Class, nil]
      def template_handler
        @template_handler ||= ::ActionView::Template.registered_template_handler(view_type)
      end

      private

      # @return [Mutex]
      def render_template_method_redefinition_lock
        @render_template_method_redefinition_lock ||= ::Mutex.new
      end

      # @return [String]
      def compiled_template_source
        handler = template_handler
        unless handler
          raise UnknownViewTypeError,
                "view type `#{view_type.inspect}` is not known in #{self}, " \
                "available types: #{::ActionView::Template.template_handler_extensions.inspect}"
        end

        if handler.method(:call).parameters.length > 1
          handler.call(self, view_template_source)
        else
          handler.call(
            source: view_template_source,
            identifier: identifier,
            type: type
          )
        end
      end

    end

    # Instance methods for rendering.
    module InstanceMethods
      # @return [String]
      def render(&block)
        run_callbacks :render do
          compile_and_render(&block)
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

      # @param args [Array<Object>]
      # @return [String]
      def nested_content(*args, &block)
        block_self = block.binding.receiver
        return block_self.safe_capture(*args, &block) if block_self.respond_to?(:safe_capture)

        safe_capture(*args, &block)
      end
      alias children nested_content

      def safe_capture(*args)
        value = nil
        buffer = with_output_buffer { value = yield(*args) }
        buffer.presence || value.html_safe
      end

      private

      # @return [String]
      def compile_and_render(&block)
        self.class.compile
        if self.class.compiled?
          return _run(
            RENDER_TEMPLATE_METHOD_NAME,
            self.class.template_handler,
            [],
            ::ActionView::OutputBuffer.new,
            &block
          )
        end

        render_non_rails_string(
          self.class.view_template_source,
          self.class.view_type,
          block
        )
      end

      # @param content [String]
      # @param type [Symbol]
      # @param block [Proc, nil]
      # @return [String]
      def render_non_rails_string(content, type, block = nil)
        TemplateHandler.render_from_string(self, content, type, block)
      end
    end
  end
end
