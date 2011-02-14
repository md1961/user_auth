require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  include UserAuthKuma::UsersHelper

  def test_attribute_value
    user_mock = Object.new
    value = true
    user_mock.instance_variable_set(:@name, value)
    def user_mock.attributes
      return {'name' => @name}
    end

    expected = UserAuthKuma::UsersHelper::YES_DISPLAY
    actual   = attribute_value(user_mock, :name)
    assert_equal(expected, actual, "for value of true")
  end
end

