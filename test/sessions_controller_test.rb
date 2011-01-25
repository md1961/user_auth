require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      resource :session

      # Temporary definition for tests
      root :to => "session#show"
    end
  end

  USER_ID = 345

  def test_create_for_authenticated
    user_mock = Object.new
    def user_mock.id
      USER_ID
    end

    User.override_authenticate(user_mock)
    get :create
    User.restore_authenticate
    assert_equal(USER_ID, session[:user_id], "session[:user_id]")
    assert_redirected_to '/'
  end
end


class User
  def self.override_authenticate(result)
    @@__kuma_result__ = result
    User.instance_eval do
      alias :authenticate_orig :authenticate
      alias :authenticate      :authenticate_overriden
    end
  end
  def self.restore_authenticate
    User.instance_eval do
      alias :authenticate :authenticate_orig
    end
  end

  def self.authenticate_overriden(name, password)
    return @@__kuma_result__
  end
end

