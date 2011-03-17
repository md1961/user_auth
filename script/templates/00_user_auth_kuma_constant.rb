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

# module Constant の定数を保持する YAMLファイルのファイル名
CONSTANT_YAML_FILENAME = "#{Rails.root}/lib/constant.yml"


module Constant

  module_function

  # 特定の定数名を持つ定数が存在するかを評価する
  # _key_ :: 定数名。Symbol、または文字列
  # 返り値 :: 定数が存在すれば true
  def has_key?(key)
    return read_yaml.has_key?(key.to_s)
  end

  # 定数を取得する
  # _key_ :: 定数名。Symbol、または文字列
  # 返り値 :: 定数
  def get(key)
    yaml = read_yaml
    raise KeyError, "No entry for key #{key.inspect}" unless yaml.has_key?(key.to_s)

    return yaml[key.to_s]
  end

  private

    def self.read_yaml
      return YAML.load_file(CONSTANT_YAML_FILENAME)
    end
end

