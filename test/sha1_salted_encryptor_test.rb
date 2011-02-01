# vi: set fileencoding=utf-8 :

require 'test_helper'

class Sha1SaltedEncryptorTest < ActiveSupport::TestCase
  include Sha1SaltedEncryptor

  def test_encrypt_for_exceptional
    [nil, ""].each do |str|
      msg = "encrypt(#{str.inspect})"
      assert_equal(str, encrypt(str), msg)
    end

    salt = 'a' * SALT_LENGTH
    [nil, ""].each do |str|
      msg = "encrypt(#{str.inspect}, #{salt.inspect})"
      assert_equal(str, encrypt(str, salt), msg)
    end

    str = 'anything'
    msg = "ArgumentError should have been raised"
    [-1, 1].each do |offset|
      salt = 'a' * (SALT_LENGTH + offset)
      msg = "encrypt(#{str.inspect}, #{salt.inspect}) should raise ArgumentError"
      assert_raise(ArgumentError, msg) do
        encrypt(str, salt, msg)
      end
    end
  end

  def test_encrypt_for_no_repeatability
    str = 'anything'
    result0 = encrypt(str)
    result1 = encrypt(str)
    msg = "2nd result should have been different with 1st"
    assert_not_equal(result1, result0, msg)
  end

  STR_SALT_AND_ENCRYPTED = %w(target aaaaaaaa $2$aaaaaaaa$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff)

  def test_encrypt
    # Specify salt
    str, salt, expected = STR_SALT_AND_ENCRYPTED
    assert_equal(expected, encrypt(str, salt))

    # Inside salt generation
    expected = encrypt(str)
    lid_length = Sha1SaltedEncryptorTest::LID.length
    salt = expected[lid_length, SALT_LENGTH]
    assert_equal(expected, encrypt(str, salt))
  end

  def test_encrypted_equal_q
    str, dump, encrypted = STR_SALT_AND_ENCRYPTED
    assert(encrypted_equal?(str, encrypted))

    assert(! encrypted_equal?('targes', encrypted))
  end

  NON_ENCRYPTED = %w(
    $1$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    2$$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $$2hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $$$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$/JV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmS/$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmSo:4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmSo$gdf9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2fg
  )

  def test_appears_encrypted_q
    # Expecting true
    encrypted = STR_SALT_AND_ENCRYPTED[2]
    assert(appears_encrypted?(encrypted))

    # Expecting false
    NON_ENCRYPTED.each do |non_encrypted|
      msg = "appears_encrypted?(#{non_encrypted.inspect})"
      assert(! appears_encrypted?(non_encrypted), msg)
    end
  end

  def test_make_salt_for_non_repeatability
    salt0 = make_salt
    salt1 = make_salt
    msg = "2nd result should have been different with 1st"
    assert_not_equal(salt1, salt0, msg)
  end

  def test_make_salt
    salt = make_salt
    assert_equal(SALT_LENGTH, salt.length, "Length of make_salt()")
    assert(salt.split(//).all? { |c| ALPHA_NUMERAL.include?(c)}, "Should consist of ALPHA_NUMERAL")
  end

  DETORTED = %w(
    $1$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    2$$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $$2hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $$$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmSo:4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4$mSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff
    $2$hJV4OmSo$4df9ae9e188df$fa39d9a66512a8b0287c8ec2ff
  )

  def test_extract_salt_and_body_for_exceptional
    DETORTED.each do |detorted|
      msg = "extract_salt_and_body(#{detorted.inspect}) should raise ArgumentError"
      assert_raise(ArgumentError, msg) do
        extract_salt_and_body(detorted)
      end
    end
  end

  ENCRYPTED = "$2$hJV4OmSo$4df9ae9e188df7fa39d9a66512a8b0287c8ec2ff"

  def test_extract_salt_and_body
    expected = ENCRYPTED.from(LID.length).split(DELIMITER)
    assert_equal(expected, extract_salt_and_body(ENCRYPTED))
  end
end
