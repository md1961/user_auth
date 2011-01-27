module UserAuthKuma

# ログインユーザを表す永続化クラス
class User < ActiveRecord::Base
  include Sha1SaltedEncryptor

  attr_accessor :password, :old_password

  MIN_LENGTH_OF_NAME     =  5
  MAX_LENGTH_OF_NAME     = 50
  MIN_LENGTH_OF_PASSWORD =  4
  MAX_LENGTH_OF_PASSWORD = 20

  validates :name    , :presence   => true,
                       :uniqueness => true,
                       :length     => {:within => MIN_LENGTH_OF_NAME .. MAX_LENGTH_OF_NAME}
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length => {:within => MIN_LENGTH_OF_PASSWORD .. MAX_LENGTH_OF_PASSWORD},
                       :if => :password_required?

  before_save :encrypt_new_password

  # 与えられたユーザ名とパスワードで認証を行い、認証されれば User のインスタンスを返す
  # <em>name</em> :: ユーザ名
  # <em>password</em> :: パスワード（平文）
  # 返り値 :: 認証された User のインスタンス。認証されなければ nil
  def self.authenticate(name, password)
    user = find_by_name(name)
    return user if user && user.authenticated?(password)
    return nil
  end

  # パスワードが正しいか評価する
  # <em>password</em> :: パスワード（平文）
  # 返り値 :: 正しければ true, 正しくなければ false
  def authenticated?(password)
    return encrypted_equal?(password, self.hashed_password)
  end

  # 書き込み権限があるか評価する
  # 返り値 :: 書き込み権限があれば true、なければ false
  def writer?
    return is_writer
  end

  # 管理者権限があるか評価する
  # 返り値 :: 管理者権限があれば true、なければ false
  def administrator?
    return is_administrator
  end

  protected

    # 入力されたパスワードを暗号化して、属性 hashed_password に設定する。
    # パスワードが nil か空文字であれば何もしない
    def encrypt_new_password
      return if password.blank?
      self.hashed_password = encrypt(password)
    end

    # パスワードの設定を必要としているか評価する。
    # 具体的には、hashed_password が nil か空文字であるか、もしくは password が入力されているか評価する
    # 返り値 :: パスワードの設定を必要としていれば true
    def password_required?
      return hashed_password.blank? || password.present?
    end
end

end

