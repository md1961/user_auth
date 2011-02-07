require 'test_helper'

class TestTargetController < UserAuthKuma::UsersController
  def change_password; super; redirect_to root_path; end
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

    assert_redirected_to root_path
  end
end

