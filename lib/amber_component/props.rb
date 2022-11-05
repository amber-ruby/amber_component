# frozen_string_literal: true

require_relative 'prop_definition'

module ::AmberComponent
  # Provides a DSL for defining component
  # properties.
  module Props
    # Class methods for component properties.
    module ClassMethods
      # @return [Hash{Symbol => AmberComponent::Prop}]
      attr_reader :prop_definitions

      # @param names [Array<Symbol>]
      # @param type [Class, nil]
      # @param required [Boolean]
      # @param default [Object, Proc, nil]
      # @param allow_nil [Boolean]
      def prop(*names, type: nil, required: false, default: nil, allow_nil: false)
        @prop_definitions ||= {}
        include(@prop_methods_module = ::Module.new) if @prop_methods_module.nil?

        names.each do |name|
          @prop_definitions[name] = prop_def = PropDefinition.new(
            name: name,
            type: type,
            required: required,
            default: default,
            allow_nil: allow_nil
          )
          raise IncorrectPropTypeError, <<~MSG unless type.nil? || type.is_a?(::Class)
            `type` should be a class but received `#{type.inspect}` (`#{type.class}`)
          MSG

          @prop_methods_module.attr_reader name
          next @prop_methods_module.attr_writer(name) unless prop_def.type?

          @prop_methods_module.class_eval( # rubocop:disable Style/DocumentDynamicEvalDefinition
            # def phone=(val)
            #   raise IncorrectPropTypeError, <<~MSG unless val.nil? || val.is_a?(String)
            #     #{self.class} received `#{val.class}` instead of `String` for `phone` prop
            #   MSG
            #
            #   @phone = val
            # end
            <<~RUB, __FILE__, __LINE__ + 1
              def #{name}=(val)
                raise IncorrectPropTypeError, <<~MSG unless #{allow_nil ? 'val.nil? ||' : nil} val.is_a?(#{prop_def.type})
                  \#{self.class} received `\#{val.class}` instead of `#{prop_def.type}` for `#{name}` prop
                MSG

                @#{name} = val
              end
            RUB
          ) # rubocop:disable Layout/HeredocArgumentClosingParenthesis
        end
      end

      # @return [Array<Symbol>, nil]
      def prop_names
        @prop_definitions.keys
      end

      # @return [Array<Symbol>, nil]
      def required_prop_names
        @prop_definitions&.filter_map do |name, prop_def|
          next unless prop_def.required

          name
        end
      end
    end

    # Instance methods for component properties.
    module InstanceMethods
      private

      # @param props [Hash{Symbol => Object}]
      def initialize(**kwargs)
        bind_props(kwargs)
      end

      # @param props [Hash{Symbol => Object}]
      # @return [Boolean] `false` when there are no props defined on the class
      #   and `true` otherwise
      # @raise [AmberComponent::MissingPropsError] when required props are missing
      # @raise [AmberComponent::IncorrectPropTypeError]
      def bind_props(props)
        return false if self.class.prop_definitions.nil?

        self.class.prop_definitions.each do |name, prop_def|
          setter_name = :"#{name}="
          public_send(setter_name, prop_def.default!) if prop_def.default?

          prop_present = props.include? name

          raise MissingPropsError, <<~MSG if prop_def.required? && !prop_present
            `#{self.class}` has a missing required prop: `#{name.inspect}`
          MSG

          next unless prop_present

          value = props[name]
          public_send(setter_name, value)
        end

        true
      end
    end
  end
end
