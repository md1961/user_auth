require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      resource :session

      # Temporary definition for tests
      root :to => "session#show"
    end
  end

  def test_new
    get :new
    assert_response :success
  end
end

