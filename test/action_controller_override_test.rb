require 'test_helper'
require 'user_auth/action_controller_override'


class TestsController < ActionController::Base
  def get_access_denied
    access_denied
  end
end


class TestsControllerTest < ActionController::TestCase

  ALL_METHODS = [
    :authenticate,
    :authenticate_as_writer,
    :authenticate_as_administrator,
    :current_user,
    :logged_in?,
    :access_denied,
  ]

  def setup
    Rails.application.routes.draw do
      match '/login' => "tests#index", :as => :login
      match ':controller(/:action(/:id(.:format)))'
    end
  end

  def test_methods_are_protected
    assert_raise(NoMethodError, "Method authenticate() should be protected") do
      @controller.authenticate
    end
    assert_raise(NoMethodError, "Method authenticate_as_writer() should be protected") do
      @controller.authenticate_as_writer
    end
    assert_raise(NoMethodError, "Method authenticate_as_administrator() should be protected") do
      @controller.authenticate_as_administrator
    end
    assert_raise(NoMethodError, "Method current_user() should be protected") do
      @controller.current_user
    end
    assert_raise(NoMethodError, "Method logged_in?() should be protected") do
      @controller.logged_in?
    end
    assert_raise(NoMethodError, "Method access_denied() should be protected") do
      @controller.access_denied
    end
  end

  def test_cuo
    override_current_user('cuo')
    assert_equal('cuo', @controller.current_user)
    restore_current_user
  end

  def test_access_denied
    get :get_access_denied
    assert_redirected_to '/login'
    #TODO: How can we test "return false"?
  end

  private

    def override_current_user(retval)
      @controller.instance_variable_set(:@__current_user_retval, retval)
      def @controller.current_user_override
        @__current_user_retval
      end

      @controller.instance_eval do
        alias :current_user_orig :current_user
        alias :current_user      :current_user_override
      end
    end

    def restore_current_user
      @controller.instance_eval do
        alias :current_user :current_user_orig
      end
    end
end

