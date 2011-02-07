require 'test_helper'

class TestTargetController < UserAuthKuma::UsersController
end


class TestTargetControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      root :to => 'test_target#change_password'

      match ':controller(/:action(/:id(.:format)))'
    end
  end

  def test_change_password
    get :change_password

    assert_response :success
    assert_template :change_password
  end

  def test_update_password_for_wrong_old_password
    user_mock = make_user_mock_not_to_be_authenticated
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_response :success
    assert_template :change_password
    assert_equal(User         , current_user.class               , "Class of @current_user")
    assert_equal(:old_password, current_user.errors.column_name  , "column_name of @current_user.erros")
    assert_equal(String       , current_user.errors.message.class, "Class of message of @current_user.erros")
  end

    def make_user_mock_not_to_be_authenticated
      errors_mock = Object.new
      def errors_mock.add(column_name, message)
        @column_name = column_name
        @message     = message
      end
      def errors_mock.column_name
        @column_name
      end
      def errors_mock.message
        @message
      end

      user_mock = User.new
      user_mock.instance_variable_set(:@errors, errors_mock)
      def user_mock.authenticated?(old_password)
        false
      end
      def user_mock.errors
        @errors
      end

      return user_mock
    end
    private :make_user_mock_not_to_be_authenticated

  def test_update_password_for_successful_update
    user_mock = make_user_mock_to_be_updated_successfully
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_redirected_to root_path
    assert_equal(User  , current_user.class  , "Class of @current_user")
    assert_equal(String, flash[:notice].class, "Class of flash[:notice]")
  end

    def make_user_mock_to_be_updated_successfully
      user_mock = User.new
      def user_mock.authenticated?(old_password)
        true
      end
      def user_mock.update_attributes(params)
        true
      end

      return user_mock
    end
    private :make_user_mock_to_be_updated_successfully

  def test_update_password_for_failed_update
    user_mock = make_user_mock_to_be_updated_unsuccessfully
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_response :success
    assert_template :change_password
    assert_equal(User, current_user.class, "Class of @current_user")
  end

    def make_user_mock_to_be_updated_unsuccessfully
      user_mock = User.new
      def user_mock.authenticated?(old_password)
        true
      end
      def user_mock.update_attributes(params)
        false
      end

      return user_mock
    end
    private :make_user_mock_to_be_updated_unsuccessfully
end

