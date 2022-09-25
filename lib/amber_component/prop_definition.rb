# frozen_string_literal: true

module ::AmberComponent
  # Internal class which represents a property
  # on a component class.
  class PropDefinition
    # @return [Symbol]
    attr_reader :name
    # @return [Class, nil]
    attr_reader :type
    # @return [Boolean]
    attr_reader :required
    # @return [Object, Proc, nil]
    attr_reader :default
    # @return [Boolean]
    attr_reader :allow_nil

    # @param name [Symbol]
    # @param type [Class, nil]
    # @param required [Boolean]
    # @param default [Object, Proc, nil]
    # @param allow_nil [Boolean]
    def initialize(name:, type: nil, required: false, default: nil, allow_nil: false)
      @name = name
      @type = type
      @required = required
      @default = default
      @allow_nil = allow_nil
    end

    alias required? required
    alias allow_nil? allow_nil

    # @return [Boolean]
    def type?
      !@type.nil?
    end

    # @return [Boolean]
    def default?
      !@default.nil?
    end

    # Evaluate the default value if it's a `Proc`
    # and return the result.
    #
    # @return [Object]
    def default!
      return @default.call if @default.is_a?(::Proc)

      @default
    end
  end
end
