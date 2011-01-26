require 'test_helper'
require 'user_auth/action_controller_override'


class TestsController < ActionController::Base
  def get_authenticate                 ; authenticate                 ; end
  def get_authenticate_as_writer       ; authenticate_as_writer       ; end
  def get_authenticate_as_administrator; authenticate_as_administrator; end
  def get_access_denied                ; access_denied                ; end
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

  def test_authenticate
    override_logged_in_q(true)
    assert(@controller.send(:authenticate), "authenticate() should return true")
    restore_logged_in_q

    override_logged_in_q(false)
    get :get_authenticate
    assert_redirected_to '/login'
    restore_logged_in_q
  end

  def test_authenticate_as_writer
    override_current_user(create_user_mock(:writer?, true))
    override_logged_in_q(true)
    assert(@controller.send(:authenticate_as_writer), "authenticate_as_writer() should return true")
    restore_logged_in_q
    restore_current_user

=begin
    override_logged_in_q(false)
    get :get_authenticate_as_writer
    assert_redirected_to '/login'
    restore_logged_in_q
=end
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

    def create_user_mock(method, retval)
      user_mock = Object.new
      user_mock.class_eval do
        define_method(method.to_sym) do
          retval
        end
      end
      return user_mock
    end

    def override_logged_in_q(retval)
      @controller.instance_variable_set(:@__logged_in_q_retval, retval)
      def @controller.logged_in_q_override
        @__logged_in_q_retval
      end

      @controller.instance_eval do
        alias :logged_in_q_orig :logged_in?
        alias :logged_in?       :logged_in_q_override
      end
    end

    def restore_logged_in_q
      @controller.instance_eval do
        alias :logged_in? :logged_in_q_orig
      end
    end
end

