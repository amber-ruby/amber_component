# frozen_string_literal: true

require 'test_helper'

module ::AmberComponent
  class PropsTest < ::TestCase
    class TestClass
      extend Props::ClassMethods
      include Props::InstanceMethods

      prop :amount, type: ::Numeric, required: true
      prop :currencies, default: -> { ['PLN'] }
      prop :address, :phone
    end

    should 'generate accessors for props' do
      %i[amount currencies address phone].each do |prop|
        assert TestClass.instance_methods.include?(prop), "missing: #{prop.inspect}"
        assert TestClass.instance_methods.include?(:"#{prop}="), "missing: #{prop.inspect}="
      end
    end

    should "return information about its props" do
      assert_equal %i[amount currencies address phone], TestClass.prop_names
      assert_equal %i[amount], TestClass.required_prop_names
    end

    context 'initializer' do
      should 'raise an error when a required prop is not present' do
        assert_raises MissingPropsError do
          TestClass.new
        end
      end

      should 'raise an error when a typed prop has an incorrect class' do
        assert_raises IncorrectPropTypeError do
          TestClass.new amount: '12'
        end
      end

      should 'not raise an error when a typed prop is given a subclass' do
        TestClass.new amount: 12
        TestClass.new amount: 12.0
      end

      should 'apply default values when props are not given' do
        obj = TestClass.new amount: 12
        assert_equal 12, obj.amount
        assert_equal ['PLN'], obj.currencies
        assert_nil obj.address
        assert_nil obj.phone
      end

      should 'override default values when props are given' do
        obj = TestClass.new amount: 12, currencies: ['GBP']
        assert_equal 12, obj.amount
        assert_equal ['GBP'], obj.currencies
        assert_nil obj.address
        assert_nil obj.phone
      end

      should 'mass assign' do
        obj = TestClass.new(
          amount: 12,
          currencies: 'GBP',
          address: 'My Street 11C',
          phone: '162874563'
        )
        assert_equal 12, obj.amount
        assert_equal 'GBP', obj.currencies
        assert_equal 'My Street 11C', obj.address
        assert_equal '162874563', obj.phone
      end

      should 'evaluate the default option when it is a Proc' do
        obj = TestClass.new(amount: 45)
        assert obj.currencies.equal?(obj.currencies)

        obj2 = TestClass.new(amount: 45)
        assert obj2.currencies.equal?(obj2.currencies)
        assert !obj2.currencies.equal?(obj.currencies)
      end
    end
  end
end
