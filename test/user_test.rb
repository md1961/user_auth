require 'test_helper'

module UserAuthKuma

class UserTest < ActiveSupport::TestCase

  def test_create
    user = User.new
    user.name             = 'foobar'
    user.password         = 'foobar'
    user.is_writer        = false
    user.is_administrator = false

    assert_nothing_raised("Failed to save #{user.inspect}") do
      user.save!
    end
  end

  #TODO: Need to create fixture :normal, :writer and :admin

  def test_find
    id = users(:normal).id

    assert_nothing_raised("Cannot find a User with id = #{id}") do
      User.find(id)
    end
  end

  def test_update
    user = users(:normal)

    assert_nothing_raised("Failed to update #{user.inspect}") do
      user.update_attributes!(name: 'foobar', password: 'foobar', is_writer: true)
    end
  end

  def test_destroy
    user = users(:normal)
    user.destroy

    assert_raise(ActiveRecord::RecordNotFound) do
      User.find(user.id)
    end
  end

  def test_validation_for_presence_of_name
    user = User.new(password: 'foobar')

    assert(! user.valid?, "User should not be valid without a name")
    assert(user.errors[:name].any?, "User should have an error without a name")
    assert(! user.save, "User should not be saved without a name")
  end

  def test_validation_for_presence_of_password
    user = User.new(name: 'foobar')

    assert(! user.valid?, "User should not be valid without a password")
    assert(user.errors[:password].any?, "User should have an error without a password")
    assert(! user.save, "User should not be saved without a password")
  end

  def test_validation_for_uniqueness_of_name
    name = 'foobar'
    user = User.new(name: name, password: name)
    user.save!
    user = User.new(name: name, password: name)
    assert(! user.save, "Two users should not be able to have same name")
  end

  def test_validation_for_length_of_name
    min_length = User::MIN_LENGTH_OF_NAME
    max_length = User::MAX_LENGTH_OF_NAME

    [min_length, max_length].each do |length|
      name = 'a' * length
      user = User.new(name: name, password: 'foobar')
      assert_nothing_raised("User with name of length = #{length} should be saved") do
        user.save!
      end
    end

    [min_length - 1, max_length + 1].each do |length|
      name = 'a' * length
      user = User.new(name: name, password: 'foobar')
      assert(! user.save, "User with name of length = #{length} should not be saved")
    end
  end

  def test_validation_for_length_of_password
    min_length = User::MIN_LENGTH_OF_PASSWORD
    max_length = User::MAX_LENGTH_OF_PASSWORD

    [min_length, max_length].each do |length|
      password = 'a' * length
      user = User.new(name: 'foobar', password: password)
      assert_nothing_raised("User with password of length = #{length} should be saved") do
        user.save!
      end
      user.destroy
    end

    [min_length - 1, max_length + 1].each do |length|
      password = 'a' * length
      user = User.new(name: 'foobar', password: password)
      assert(! user.save, "User with password of length = #{length} should not be saved")
    end
  end

  def test_validation_for_confirmation_of_password
    name = 'foobar'
    user = User.new(name: name, password: name, password_confirmation: name)

    assert_nothing_raised("User should be saved if password confirmed") do
      user.save!
    end

    user = User.new(name: name, password: name, password_confirmation: name + 'x')

    assert(! user.save, "User should not be saved if password was not confirmed")
  end

  def test_self_authenticate_return_nil
    assert_nil(User.authenticate('nobody', 'unlikely password'), "Should not be authenticated")
  end

  USERNAMES = %w(normal writer admin)

  def test_self_authenticate
    USERNAMES.each do |name|
      user = User.authenticate(name, name)
      assert(user.is_a?(User), "user should be a class User instance")
      assert_equal(name, user.name, "user's name")
    end
  end

  def test_authenticated_q
    USERNAMES.each do |name|
      user = User.find_by_name(name)
      assert(user.authenticated?(name), "User '#{name}' should be authenticated with password of its name")
    end
  end

  def test_writer_q
    [true, false].each do |is_writer|
      user = User.new(is_writer: is_writer)
      assert_equal(is_writer, user.writer?, "User#writer?()")
    end
  end

  def test_administrator_q
    [true, false].each do |is_administrator|
      user = User.new(is_administrator: is_administrator)
      assert_equal(is_administrator, user.administrator?, "User#administrator?()")
    end
  end

  def test_reset_password
    user = User.new
    assert_nil(user.password, "user.password before")
    retval = user.reset_password
    assert_equal(retval, user.password, "return value & user.password after")
    assert_temporary_password(retval)
  end

  def test_encrypt_new_password
    user = User.new
    user.instance_eval do
      user.encrypt_new_password
    end
    assert_nil(user.hashed_password, "hashed_password should be nil")

    password = 'password'
    user.password = password
    is_encrypted_equal = false
    user.instance_eval do
      user.encrypt_new_password
      is_encrypted_equal = encrypted_equal?(password, hashed_password)
    end
    assert(is_encrypted_equal, "hashed_password should be 'encrypted_equal' to password")
  end

  def test_password_required_q
    [
      [nil, nil, true ],
      ["" , nil, true ],
      ["a", nil, false],
      [nil, "" , true ],
      ["" , "" , true ],
      ["a", "" , false],
      [nil, "a", true ],
      ["" , "a", true ],
      ["a", "a", true ],
    ].each do |hashed_password, password, expected|
      user = User.new(hashed_password: hashed_password, password: password)
      actual = nil
      user.instance_eval do
        actual = user.password_required?
      end
      msg = "hashed_password = #{hashed_password.inspect}, password = #{password.inspect}"
      assert_equal(expected, actual, msg)
    end
  end

  TIMES_TO_TEST_TEMPORARY_PASSWORD = 50

  def test_temporary_password
    user = User.new

    TIMES_TO_TEST_TEMPORARY_PASSWORD.times do
      actual = nil
      user.instance_eval { actual = temporary_password }
      assert_temporary_password(actual)
    end
  end

    LENGTH     = UserAuthKuma::Constant::TemporaryPassword::LENGTH
    NUM_DIGITS = UserAuthKuma::Constant::TemporaryPassword::NUM_DIGITS
    NUM_SIGNS  = UserAuthKuma::Constant::TemporaryPassword::NUM_SIGNS 
    NUM_UPPERS = UserAuthKuma::Constant::TemporaryPassword::NUM_UPPERS
    NUM_LOWERS = UserAuthKuma::Constant::TemporaryPassword::NUM_LOWERS
    SIGNS      = Regexp.escape(UserAuthKuma::Constant::TemporaryPassword::SIGNS.join)

    def assert_temporary_password(actual)
      assert_equal(LENGTH    , actual.length            , "length of #{actual.inspect}")
      assert_equal(NUM_LOWERS, count_char(actual, 'a-z'), "num lowers of #{actual.inspect}")
      assert_equal(NUM_UPPERS, count_char(actual, 'A-Z'), "num uppers of #{actual.inspect}")
      assert_equal(NUM_DIGITS, count_char(actual, '0-9'), "num digits of #{actual.inspect}")
      assert_equal(NUM_SIGNS , count_char(actual, SIGNS), "num signs of #{actual.inspect}")
    end

    def count_char(str, pattern)
      return str.gsub(/[^#{pattern}]/, '').length
    end
end

end

