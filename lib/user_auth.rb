
DIRECTORIES_TO_LOAD_FROM = %w(models controllers helpers)

DIRECTORIES_TO_LOAD_FROM.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end

require 'user_auth/action_controller_override'

