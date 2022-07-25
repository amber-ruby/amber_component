# frozen_string_literal: true

module ::AmberComponent
  # Contains the content and type of an asset.
  class TypedContent
    class << self
      # @param val [Hash, self]
      # @return [self]
      def wrap(val)
        return val if val.is_a?(self)

        unless val.respond_to?(:[])
          raise InvalidType, "`TypedContent` should be a `Hash` or `#{self}` but was `#{val.class}` (#{val.inspect})"
        end

        new(type: val[:type], content: val[:content])
      end

      alias [] wrap
    end

    # @param type [Symbol, String, nil]
    # @param content [String, Proc, nil]
    def initialize(type:, content:)
      @type = type&.to_sym
      @content = content
      freeze
    end

    # @return [Symbol, nil]
    attr_reader :type
    # @return [String, Proc, nil]
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
