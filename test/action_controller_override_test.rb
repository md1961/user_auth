require 'test_helper'
require 'user_auth/action_controller_override'


class TestsController < ActionController::Base
  def get_authenticate                 ; authenticate                 ; end
  def get_authenticate_as_writer       ; authenticate_as_writer       ; end
  def get_authenticate_as_administrator; authenticate_as_administrator; end
  def get_current_user                 ; current_user                 ; end
  def get_access_denied                ; access_denied                ; end
end


class TestsControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      match '/login' => "tests#index", :as => :login
      match ':controller(/:action(/:id(.:format)))'
    end

    @request.session = ActionController::TestSession.new
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

  def test_authenticate_as_writer_without_user_writer_q_defined
    msg = "authenticate_as_writer() should return false if User#writer?() not defined"
    override_current_user(create_user_mock)
    override_logged_in_q(true)
    get :get_authenticate_as_writer
    assert_redirected_to '/login'
    restore_logged_in_q
    restore_current_user
  end

  def test_authenticate_as_writer
    is_writer    = true
    is_logged_in = true
    override_current_user(create_user_mock(:writer?, is_writer))
    override_logged_in_q(is_logged_in)
    assert(@controller.send(:authenticate_as_writer), "authenticate_as_writer() should return true")
    restore_logged_in_q
    restore_current_user

    [
      [true , false],
      [false, true ],
      [false, false],
    ].each do |is_writer, is_logged_in|
      override_current_user(create_user_mock(:writer?, is_writer))
      override_logged_in_q(is_logged_in)
      get :get_authenticate_as_writer
      assert_redirected_to '/login'
      restore_logged_in_q
      restore_current_user
    end
  end

  def test_authenticate_as_administrator
    is_administrator    = true
    is_logged_in = true
    override_current_user(create_user_mock(:administrator?, is_administrator))
    override_logged_in_q(is_logged_in)
    assert(@controller.send(:authenticate_as_administrator), "authenticate_as_administrator() should return true")
    restore_logged_in_q
    restore_current_user

    [
      [true , false],
      [false, true ],
      [false, false],
    ].each do |is_administrator, is_logged_in|
      override_current_user(create_user_mock(:administrator?, is_administrator))
      override_logged_in_q(is_logged_in)
      get :get_authenticate_as_administrator
      assert_redirected_to '/login'
      restore_logged_in_q
      restore_current_user
    end
  end

  USER_MOCK = :user_mock

  def test_current_user
    msg = "current_user() should return nil without setting nothing"
    assert_nil(@controller.send(:current_user), msg)

    msg = "current_user() should return nil with session[:user_id] of nil"
    @request.session[:user_id] = nil
    assert_nil(@controller.send(:current_user), msg)

    msg = "current_user() should return User.find() with session[:user_id] of non-nil and @current_user of nil"
    assert_nil(@controller.instance_variable_get(:@current_user), "@current_user before calling current_user() should be nil")
    @request.session[:user_id] = :whatever_non_nil
    User.override_find(USER_MOCK)
    assert_equal(USER_MOCK, @controller.send(:current_user), msg)
    User.restore_find
    assert_equal(USER_MOCK, @controller.instance_variable_get(:@current_user), "@current_user after calling current_user()")
    @controller.instance_variable_set(:@current_user, nil)

    msg = "current_user() should return @current_user with both session[:user_id] and @current_user of non-nil"
    assert_nil(@controller.instance_variable_get(:@current_user), "@current_user before calling current_user() should be nil")
    @request.session[:user_id] = :whatever_non_nil
    @controller.instance_variable_set(:@current_user, USER_MOCK)
    User.override_find(:something_else)
    assert_equal(USER_MOCK, @controller.send(:current_user), msg)
    User.restore_find
    assert_equal(USER_MOCK, @controller.instance_variable_get(:@current_user), "@current_user after calling current_user()")
    @controller.instance_variable_set(:@current_user, nil)  # just in case
  end

  def test_logged_in_q
    msg = "logged_in?() should return false when current_user() returns nil"
    override_current_user(nil)
    assert(! @controller.send(:logged_in?), msg)
    restore_current_user

    msg = "logged_in?() should return false when current_user() returns a non-User"
    override_current_user(Object.new)
    assert(! @controller.send(:logged_in?), msg)
    restore_current_user

    msg = "logged_in?() should return false when current_user() returns a User"
    override_current_user(User.new)
    assert(@controller.send(:logged_in?), msg)
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

    def create_user_mock(method=nil, retval=nil)
      user_mock = Object.new
      if method.is_a?(Symbol)
        user_mock.class_eval do
          define_method(method.to_sym) do
            retval
          end
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


class User
  def self.override_find(user_mock)
    @@user_mock = user_mock
    User.instance_eval do
      alias :find_original :find
      alias :find          :find_override
    end
  end

  def self.restore_find
    User.instance_eval do
      alias :find :find_original
    end
  end

  def self.find_override(id)
    @@user_mock
  end
end

