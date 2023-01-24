# frozen_string_literal: true

require 'test_helper'

module ::AmberComponent
  class Base
    class PropsTest < ::TestCase
      context 'no defined props' do
        class ComponentWithoutProps < Base; end

        should 'set all kwargs as instance variables' do
          obj = ComponentWithoutProps.new foo: 3, bar: :thing
          assert !obj.respond_to?(:foo)
          assert !obj.respond_to?(:bar)
          assert_equal 3, obj.instance_variable_get(:@foo)
          assert_equal :thing, obj.instance_variable_get(:@bar)
        end
      end

      context 'defined props' do
        class ComponentWithProps < Base
          prop :amount, type: ::Numeric, required: true
          prop :currencies, default: -> { ['PLN'] }
          prop :address, :phone
        end

        should 'ignore nonexistent props' do
          obj = ComponentWithProps.new amount: 1, foo: 3, bar: :thing
          assert obj.respond_to?(:amount)
          assert_equal 1, obj.amount

          assert !obj.respond_to?(:foo)
          assert !obj.respond_to?(:bar)
          assert !obj.instance_variables.include?(:@foo)
          assert !obj.instance_variables.include?(:@bar)
        end
      end
    end
  end
end
