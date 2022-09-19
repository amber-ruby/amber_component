# frozen_string_literal: true

require_relative 'prop'

module ::AmberComponent
  # Provides a DSL for defining component
  # properties.
  module Props
    # Class methods for component properties.
    module ClassMethods
      # @return [Hash{Symbol => AmberComponent::Prop}]
      attr_reader :props
      # @return [Set<Symbol>]
      attr_reader :prop_names
      # @return [Set<Symbol>]
      attr_reader :required_prop_names

      # @param names [Array<Symbol>]
      # @param type [Class]
      # @param required [Boolean]
      # @param default [Object, Proc, nil]
      def prop(*names, type: nil, required: false, default: nil)
        @props ||= {}
        @required_prop_names ||= ::Set.new

        names.each do |name|
          attr_accessor name

          @props[name] = Prop.new(
            name: name,
            type: type,
            required: required,
            default: default
          )
          next unless required

          @required_prop_names << name
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
        return false if self.class.props.nil?

        self.class.props.each do |name, prop_def|
          setter_name = :"#{name}="
          public_send(setter_name, prop_def.default!) if prop_def.default

          prop_present = props.include? name

          raise MissingPropsError, <<~MSG if prop_def.required && !prop_present
            `#{self.class}` has a missing required prop: `#{name.inspect}`
          MSG

          next unless prop_present

          value = props[name]
          raise IncorrectPropTypeError, <<~MSG if prop_def.type && !value.is_a?(prop_def.type)
            #{self.class} received `#{value.class}` instead of `#{prop_def.type}` for `#{name}` prop
          MSG

          public_send(setter_name, value)
        end

        true
      end
    end
  end
end
