require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  include UserAuthKuma::UsersHelper

  def test_attribute_value
    expected = UserAuthKuma::UsersHelper::YES_DISPLAY
    user_mock = make_user_mock_to_test_attribute_value(:name, true)
    actual = attribute_value(user_mock, :name)
    assert_equal(expected, actual, "attribute_value() for value of true")

    expected = UserAuthKuma::UsersHelper::NO_DISPLAY
    user_mock = make_user_mock_to_test_attribute_value(:name, false)
    actual = attribute_value(user_mock, :name)
    assert_equal(expected, actual, "attribute_value() for value of false")

    expected = :value
    user_mock = make_user_mock_to_test_attribute_value(:name, expected)
    actual = attribute_value(user_mock, :name)
    assert_equal(expected, actual, "attribute_value() for value of false")
  end

    def make_user_mock_to_test_attribute_value(attr_name, attr_value)
      user_mock = Object.new
      user_mock.instance_variable_set(:@name , attr_name )
      user_mock.instance_variable_set(:@value, attr_value)
      def user_mock.attributes
        {@name.to_s => @value}
      end

      return user_mock
    end
end

