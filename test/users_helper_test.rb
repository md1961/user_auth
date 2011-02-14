require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  include UserAuthKuma::UsersHelper

  def test_attribute_value
    user_mock = make_user_mock_to_test_attribute_value(:name, true)

    expected = UserAuthKuma::UsersHelper::YES_DISPLAY
    actual   = attribute_value(user_mock, :name)
    assert_equal(expected, actual, "for value of true")
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

