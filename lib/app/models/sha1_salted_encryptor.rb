# vi: set fileencoding=utf-8 :

require 'digest/sha1'

# Sha-1 と salt により暗号化した文字列を返すメソッド encrypt を
# 定義するモジュール
module Sha1SaltedEncryptor

  # Salt 付きのときの暗号化パスワードの先頭文字群
  LID = '$2$'
  # 暗号化パスワード中の salt と暗号本文との区切り文字
  DELIMITER = '$'
  # Salt の文字列長
  SALT_LENGTH = 8

  # Sha-1 により文字列を暗号化して返す
  # 文字列が nil または空文字列の場合はそのまま返す
  # _str_ :: 暗号化する文字列
  # _salt_ :: salt。指定のない場合はランダムに生成する
  # 返り値 :: 暗号化された文字列
  def encrypt(str, salt=nil)
    return str if str.blank?
    if salt && salt.length != SALT_LENGTH
      raise ArgumentError.new("salt の文字列長は #{SALT_LENGTH} です (#{salt.length} given)")
    end
    salt = make_salt if salt.nil?
    return LID + salt + DELIMITER + Digest::SHA1.hexdigest(str + salt)
  end

  # 平文のパスワードと暗号化されたパスワードが一致するか評価する
  # <em>plain_password</em> :: 平文のパスワード
  # <em>encrypted_password</em> :: 暗号化されたパスワード
  # 返り値 :: パスワードが一致すれば true
  def encrypted_equal?(plain_password, encrypted_password)
    salt = extract_salt_and_body(encrypted_password)[0]
    return encrypt(plain_password, salt) == encrypted_password
  end
  
  # ダイジェスト文字列に含まれる16進数文字からなる文字列
  HEXADECIMAL = ['0'..'9', 'a'..'f'].map { |range| range.to_a.join }.join

  # メソッド encrypt により暗号化された文字列とみなせるか評価する
  # <em>str</em> :: 対象の文字列
  # 返り値 :: メソッド encrypt により暗号化された文字列とみなせると判断されれば true
  def appears_encrypted?(str)
    pos_delim = LID.length + SALT_LENGTH
    salt   = str[LID.length, SALT_LENGTH] || ""
    digest = str[LID.length + SALT_LENGTH + DELIMITER.length, str.length] || ""

    is_lid_right    = str[0, LID.length] == LID
    is_delim_right  = str[pos_delim, DELIMITER.length] == DELIMITER
    is_length_right = str.length == encrypt('a_string').length
    is_salt_right   = salt  .split(//).all? { |ch| ALPHA_NUMERAL.include?(ch) }
    is_digest_right = digest.split(//).all? { |ch| HEXADECIMAL  .include?(ch) }

    return is_lid_right && is_delim_right && is_length_right && is_salt_right && is_digest_right
  end

  private

    # 英大小文字・数字、それぞれ一文字ずつからなる文字列
    ALPHA_NUMERAL = ['a'..'z', 'A'..'Z', '0'..'9'].map { |range| range.to_a.join }.join

    def make_salt
      s = Array.new
      SALT_LENGTH.times do
        s << ALPHA_NUMERAL.split(//).sample
      end
      return s.join
    end

    # 暗号化されたパスワードから salt と暗号本文を抽出する
    def extract_salt_and_body(str)
      raise ArgumentError.new("Argument str does not start with '#{LID}'") unless str[0, LID.length] == LID

      salt_and_body = str[LID.length, str.length].split(DELIMITER)
      raise ArgumentError.new("Argument str does not have delimiter '#{DELIMITER}'")                 if salt_and_body.size <= 1
      raise ArgumentError.new("Argument str has #{salt_and_body.size - 1} delimiter '#{DELIMITER}'") if salt_and_body.size >  2

      return salt_and_body
    end
end

