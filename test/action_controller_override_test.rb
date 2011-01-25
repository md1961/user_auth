require 'test_helper'
require 'user_auth/action_controller_override'


class TestsController < ActionController::Base
  def access_denied
    super
  end
end


class TestsControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      match '/login' => "tests#index", :as => :login
      match ':controller(/:action(/:id(.:format)))'
    end
  end

  def test_access_denied
    get :access_denied
    assert_redirected_to '/login'
  end
end

