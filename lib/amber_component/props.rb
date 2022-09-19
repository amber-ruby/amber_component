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
      # @param type [Class]
      # @param required [Boolean]
      # @param default [Object, Proc, nil]
      def prop(*names, type: nil, required: false, default: nil)
        @prop_definitions ||= {}

        names.each do |name|
          attr_accessor name

          @prop_definitions[name] = PropDefinition.new(
            name: name,
            type: type,
            required: required,
            default: default
          )
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
          raise IncorrectPropTypeError, <<~MSG if prop_def.type? && !value.is_a?(prop_def.type)
            #{self.class} received `#{value.class}` instead of `#{prop_def.type}` for `#{name}` prop
          MSG

          public_send(setter_name, value)
        end

        true
      end
    end
  end
end
