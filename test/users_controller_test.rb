require 'test_helper'

class TestTargetController < UserAuthKuma::UsersController
end


class TestTargetControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      root :to => "test_target#index"

      match ':controller(/:action(/:id(.:format)))'
    end
  end

  def test_change_password
    get :change_password

    assert_response :success
    assert_template :change_password
  end

  def test_update_password_for_wrong_old_password
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

    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_response :success
    assert_template :change_password
    assert_equal(User         , current_user.class               , "Class of @current_user")
    assert_equal(:old_password, current_user.errors.column_name  , "column_name of @current_user.erros")
    assert_equal(String       , current_user.errors.message.class, "Class of message of @current_user.erros")
  end
end

