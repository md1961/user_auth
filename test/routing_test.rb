require 'test_helper'

class RoutingTest < Test::Unit::TestCase
 
  def setup
  end
 
  def test_session_route
    assert_recognition :post  , "/session", :controller => "sessions", :action => "create"
    assert_recognition :delete, "/session", :controller => "sessions", :action => "destroy"
  end
 
  private
 
    def assert_recognition(method, path, options)
      result = Rails.application.routes.recognize_path(path, :method => method)
      assert_equal options, result
    end
end

