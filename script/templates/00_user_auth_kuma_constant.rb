module UserAuthKuma
  module Constant
    SESSION_TIMEOUT_IN_MIN =  5

    MIN_LENGTH_OF_NAME     =  5
    MAX_LENGTH_OF_NAME     = 50
    MIN_LENGTH_OF_PASSWORD =  4
    MAX_LENGTH_OF_PASSWORD = 20

    module TemporaryPassword
      LENGTH     = 12
      NUM_DIGITS =  2
      NUM_SIGNS  =  1
      NUM_UPPERS =  2
      NUM_LOWERS = LENGTH - NUM_DIGITS - NUM_SIGNS - NUM_UPPERS

      SIGNS = %w(! # $ % & + - * / = @ ?)
    end

    # Give expression in string to be evaluated by Kernel#eval() such as "users_path"
    # when you want to override default link 'Cancel' destination to root_path
    # in VIEW 'users#index', 'users#change_password', respectively
    CANCEL_PATH_FROM_USERS_INDEX     = nil
    CANCEL_PATH_FROM_CHANGE_PASSWORD = nil
  end
end
