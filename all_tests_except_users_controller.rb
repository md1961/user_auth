require 'test_helper'

[
  'action_controller_override_test',
  'constant_test',
  'sessions_controller_test',
  'sessions_helper_test',
  'sha1_salted_encryptor_test',
  'user_auth_test',
  #'users_controller_test',
  'users_helper_test',
  'user_test',
].each do |basename|
  require File.join(File.dirname(__FILE__), 'test', basename)
end

