# frozen_string_literal: true

module ::AmberComponent
  # Object which stores configuration options
  # for this gem.
  class Configuration
    # @return [Set<Symbol>]
    STIMULUS_INTEGRATIONS = ::Set[nil, :importmap, :webpacker, :jsbundling, :webpack, :esbuild, :rollup]
    # @return [Set<Symbol>]
    ALLOWED_STYLES = ::Set.new(%i[css scss sass])
    # @return [Set<Symbol>]
    ALLOWED_VIEWS = ::Set.new(%i[erb haml slim])

    # How Stimulus.js is bundled in this app.
    # Possible values: `[nil, :importmap, :webpacker, :jsbundling, :webpack, :esbuild, :rollup]`
    # `nil` indicates that stimulus should not be used (default behaviour).
    #
    # @return [Symbol, nil]
    attr_reader :stimulus

    # The default format that the generators will use
    # for the view/template file of a component.
    # Possible values: `[nil, :erb, :haml, :slim]`
    #
    # @return [Symbol, nil]
    attr_reader :view_format

    # The default format that the generators will use
    # for the stylesheets of a component.
    # Possible values: `[nil, :css, :scss, :sass]`
    #
    # @return [Symbol, nil]
    attr_reader :stylesheet_format

    # How Stimulus.js is bundled in this app.
    # Possible values: `[nil, :importmap, :webpacker, :jsbundling, :webpack, :esbuild, :rollup]`
    # `nil` indicates that stimulus should not be used (default behaviour).
    #
    # @param val [Symbol, String, nil]
    def stimulus=(val)
      val = val&.to_sym
      unless val.nil? || STIMULUS_INTEGRATIONS.include?(val)
        raise(::ArgumentError,
              "Invalid value for `#{__method__}` bundling. " \
              "Received #{val.inspect}, expected one of #{STIMULUS_INTEGRATIONS.inspect}")
      end

      @stimulus = val
    end

    # @param val [Symbol, String, nil]
    def stylesheet_format=(val)
      val = val&.to_sym
      unless val.nil? || ALLOWED_STYLES.include?(val)
        raise(::ArgumentError,
              "Invalid value for `#{__method__}`. " \
              "Received #{val.inspect}, expected one of #{ALLOWED_STYLES.inspect}")
      end

      @stylesheet_format = val
    end

    # @param val [Symbol, String, nil]
    def view_format=(val)
      val = val&.to_sym
      unless val.nil? || ALLOWED_VIEWS.include?(val)
        raise(::ArgumentError,
              "Invalid value for `#{__method__}`. " \
              "Received #{val.inspect}, expected one of #{ALLOWED_VIEWS.inspect}")
      end

      @view_format = val
    end

    # @return [Boolean]
    def stimulus?
      !@stimulus.nil?
    end

    # @return [Boolean]
    def stimulus_importmap?
      @stimulus == :importmap
    end
  end
end
