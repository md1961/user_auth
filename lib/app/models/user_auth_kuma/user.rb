module UserAuthKuma

# ログインユーザを表す永続化クラス
class User < ActiveRecord::Base
  include Sha1SaltedEncryptor

  attr_accessor :password, :old_password

  MIN_LENGTH_OF_NAME     = UserAuthKuma::Constant::MIN_LENGTH_OF_NAME
  MAX_LENGTH_OF_NAME     = UserAuthKuma::Constant::MAX_LENGTH_OF_NAME
  MIN_LENGTH_OF_PASSWORD = UserAuthKuma::Constant::MIN_LENGTH_OF_PASSWORD
  MAX_LENGTH_OF_PASSWORD = UserAuthKuma::Constant::MAX_LENGTH_OF_PASSWORD

  validates :name    , :presence     => true,
                       :uniqueness   => true,
                       :length       => {:within => MIN_LENGTH_OF_NAME .. MAX_LENGTH_OF_NAME}
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => {:within => MIN_LENGTH_OF_PASSWORD .. MAX_LENGTH_OF_PASSWORD},
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
    return respond_to?(:is_writer) && is_writer
  end

  # 管理者権限があるか評価する
  # 返り値 :: 管理者権限があれば true、なければ false
  def administrator?
    return respond_to?(:is_administrator) && is_administrator
  end

  # パスワードをリセットする。具体的には、現在のパスワードを上書きして
  # 一時的なパスワードを設定する
  # 返り値 :: 設定した一時的なパスワード
  def reset_password
    tmp_passwd = temporary_password
    self.password = tmp_passwd
    save!
    return tmp_passwd
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

    # 一時的なパスワードを生成する
    # 返り値 :: 一時的なパスワード
    def temporary_password
      chars = Array.new
      UserAuthKuma::Constant::TemporaryPassword::NUM_DIGITS.times { chars << pick_digit }
      UserAuthKuma::Constant::TemporaryPassword::NUM_SIGNS .times { chars << pick_sign  }
      UserAuthKuma::Constant::TemporaryPassword::NUM_UPPERS.times { chars << pick_upper }
      UserAuthKuma::Constant::TemporaryPassword::NUM_LOWERS.times { chars << pick_lower }
      return chars.shuffle.join
    end

    def pick_digit
      return (0 .. 9).to_a.sample
    end

    def pick_sign
      return UserAuthKuma::Constant::TemporaryPassword::SIGNS.sample
    end

    def pick_upper
      return (?A .. ?Z).to_a.sample
    end

    def pick_lower
      return (?a .. ?z).to_a.sample
    end
end

end

