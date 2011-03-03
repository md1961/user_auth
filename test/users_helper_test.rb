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
    private :make_user_mock_to_test_attribute_value

  def test_attribute_align
    [
      %w(id    right),
      %w(name  left),
      %w(other center),
    ].each do |attr_name, expected|
      assert_equal(expected, attribute_align(attr_name), "attribute_align(#{attr_name.inspect})")
    end
  end

  USERS_PATH = "/users"
  USER_PATH  = "/user"

  def test_args_for_form_for
    [
      [true , USERS_PATH, :post],
      [false, USER_PATH , :put ],
    ].each do |is_new, url, method|
      user_mock = Object.new
      user_mock.instance_variable_set(:@is_new, is_new)
      def user_mock.new_record?
        @is_new
      end

      expected = {:as => :user, :url => url, :html => {:method => method}}
      actual   = args_for_form_for(user_mock)
      msg      = "args_for_form_for() for user with new_record? of #{is_new}"
      assert_equal(expected, actual, msg)
    end
  end

    def users_path
      return USERS_PATH
    end
    def user_path
      return USER_PATH
    end
    private :users_path, :user_path

  def test_eval_or_nil
    [
      [nil  , nil],
      [false, nil],
      [0    , nil],
      ['abracadabra', nil],
      ['users_path' , USERS_PATH],
      ['user_path'  , USER_PATH ],
    ].each do |arg, expected|
      assert_equal(expected, eval_or_nil(arg), "eval_or_nil(#{arg.inspect})")
    end
  end

  def test_object_boolean_q
    assert(true .boolean?, "true.boolean? should be true")
    assert(false.boolean?, "false.boolean? should be true")
    assert(! Object.new.boolean?, "Object.new.boolean? should be false")
    assert(! "string"  .boolean?, "'string'.boolean? should be false")
  end
end

