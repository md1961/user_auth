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
  end
end
