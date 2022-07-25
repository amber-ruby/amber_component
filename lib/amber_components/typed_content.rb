# frozen_string_literal: true

module ::AmberComponent
  # Contains the content and type of an asset.
  class TypedContent
    class << self
      # @param val [Hash, self]
      # @return [self]
      def wrap(val)
        return val if val.is_a?(self)

        new(type: val[:type], content: val[:content])
      end

      alias [] wrap
    end

    # @param type [Symbol]
    # @param content [String, Proc]
    def initialize(type:, content:)
      @type = type
      @content = content
      freeze
    end

    # @return [Symbol]
    attr_reader :type
    # @return [String, Proc]
    attr_reader :content

    # Stringified content.
    #
    # @return [String]
    def to_s
      return @content.call.to_s if @content.is_a?(::Proc)

      @content.to_s
    end

    alias string_content to_s
  end
end
