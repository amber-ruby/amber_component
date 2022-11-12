# frozen_string_literal: true

module ::AmberComponent
  # Object which stores configuration options
  # for this gem.
  class Configuration
    # @return [Array<Symbol>]
    STIMULUS_INTEGRATIONS = %i[importmap js_bundler webpack esbuild rollup].freeze

    # How Stimulus.js is bundled in this app.
    # Possible values: `[nil, :importmap, :js_bundler, :webpack, :esbuild, :rollup]`
    # `nil` indicates that stimulus should not be used (default behaviour).
    #
    # @return [Symbol, nil]
    attr_reader :stimulus

    # How Stimulus.js is bundled in this app.
    # Possible values: `[nil, :importmap, :js_bundler, :webpack, :esbuild, :rollup]`
    # `nil` indicates that stimulus should not be used (default behaviour).
    #
    # @param val [Symbol, String, nil]
    def stimulus=(val)
      val = val&.to_sym
      unless val.nil? || STIMULUS_INTEGRATIONS.include?(val)
        raise(::ArgumentError,
              "Invalid value for `stimulus` bundling. " \
              "Received #{val.inspect}, expected one of #{STIMULUS_INTEGRATIONS.inspect}")
      end

      @stimulus = val
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
