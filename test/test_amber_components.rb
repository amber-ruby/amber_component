# frozen_string_literal: true

require 'test_helper'

class ::TestAmberComponents < ::TestCase
  should 'have a version number' do
    refute_nil ::AmberComponents::VERSION
  end
end
