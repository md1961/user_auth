require 'test_helper'

class UserAuthTest < ActiveSupport::TestCase

  def test_autoload_paths
    autoload_paths = ActiveSupport::Dependencies.autoload_paths

    DIRECTORIES_TO_LOAD_FROM.each do |dir|
      dir_fullpath = File.expand_path("#{File.dirname(__FILE__)}/../lib/app/#{dir}")
      assert(autoload_paths.include?(dir_fullpath), "'{dir_fullpath}' should be in autoload_paths")
    end
  end
end

