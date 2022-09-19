# frozen_string_literal: true

require 'test_helper'

module ::AmberComponent
  class PropTest < ::TestCase

    should 'have appropriate default options' do
      prop = Prop.new(name: :something)
      assert_equal :something, prop.name
      assert_nil prop.type
      assert_equal false, prop.required
      assert_nil prop.default
    end

    should 'evaluate default! when it is a Proc' do
      prop = Prop.new(name: :something, default: -> { [] })
      assert_equal :something, prop.name
      assert prop.default.is_a?(::Proc)
      assert_equal [], prop.default!
      assert !prop.default!.equal?(prop.default!)
    end

    should 'not evaluate default! when it is not a Proc' do
      prop = Prop.new(name: :something, default: [])
      assert_equal :something, prop.name
      assert !prop.default.is_a?(::Proc)
      assert_equal [], prop.default
      assert_equal [], prop.default!
      assert prop.default!.equal?(prop.default!)
      assert prop.default!.equal?(prop.default)
    end

    should 'save all args' do
      prop = Prop.new(name: :nam, type: ::String, required: true, default: :def)
      assert_equal :nam, prop.name
      assert_equal ::String, prop.type
      assert prop.required
      assert_equal :def, prop.default
    end
  end
end
