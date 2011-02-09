require 'test_helper'

class TestTargetController < UserAuthKuma::UsersController
end


class TestTargetControllerTest < ActionController::TestCase

  def setup
    Rails.application.routes.draw do
      resources :users
      root :to => 'test_target#change_password'

      match ':controller(/:action(/:id(.:format)))'
    end
  end

  def test_index
    get :index

    assert_response :success
    assert_template :index

    users = assigns(:users)
    assert_equal(Array, users.class, "Class of @users")
    users.each_with_index do |user, index|
      base_class_name = user.class.name.demodulize
      assert_equal('User', base_class_name, "Class of @users[#{index}]")
    end

    attribute_names = assigns(:attribute_names)
    assert_equal(Array, attribute_names.class, "Class of @attribute_names")
    attribute_names.each_with_index do |attr_name, index|
      assert_equal(String, attr_name.class, "Class of @attribute_names[#{index}]")
    end
  end

  def test_new
    get :new

    assert_response :success
    assert_template :new

    user = assigns(:user)
    base_class_name = user.class.name.demodulize
    assert_equal('User', base_class_name, "Class of @user")
    assert(user.new_record?, "@user should be a new record")
  end

  PARAMS_USER_MOCK = :params_user_mock

  def test_create_for_failed_save
    UserAuthKuma::User.override_new(false)
    get :create
    UserAuthKuma::User.restore_new

    assert_response :success
    assert_template :new
  end

  def test_create
    UserAuthKuma::User.override_new(true)
    get :create, :user => PARAMS_USER_MOCK
    UserAuthKuma::User.restore_new

    assert_redirected_to :controller => 'users', :action => 'index'
    assert_equal(PARAMS_USER_MOCK, assigns(:user).params_user, "@user.user")
  end

  ID = 635

  def test_edit
    UserAuthKuma::User.override_find(false)
    get :edit, {:id => ID, :user => PARAMS_USER_MOCK}
    UserAuthKuma::User.restore_find

    assert_response :success
    assert_template :edit

    assert_equal(ID, assigns(:user).id, "@user.id")
  end

  def test_update_for_failed_update_attributes
    UserAuthKuma::User.override_find(false)
    get :update, {:id => ID, :user => PARAMS_USER_MOCK}
    UserAuthKuma::User.restore_find

    assert_response :success
    assert_template :edit
  end

  def test_change_password
    get :change_password

    assert_response :success
    assert_template :change_password
  end

  def test_update_password_for_wrong_old_password
    user_mock = make_user_mock_not_to_be_authenticated
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_response :success
    assert_template :change_password
    assert_equal(User         , current_user.class               , "Class of @current_user")
    assert_equal(:old_password, current_user.errors.column_name  , "column_name of @current_user.erros")
    assert_equal(String       , current_user.errors.message.class, "Class of message of @current_user.erros")
  end

    def make_user_mock_not_to_be_authenticated
      errors_mock = Object.new
      def errors_mock.add(column_name, message)
        @column_name = column_name
        @message     = message
      end
      def errors_mock.column_name
        @column_name
      end
      def errors_mock.message
        @message
      end

      user_mock = User.new
      user_mock.instance_variable_set(:@errors, errors_mock)
      def user_mock.authenticated?(old_password)
        false
      end
      def user_mock.errors
        @errors
      end

      return user_mock
    end
    private :make_user_mock_not_to_be_authenticated

  def test_update_password_for_successful_update
    user_mock = make_user_mock_to_be_updated_successfully
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_redirected_to root_path
    assert_equal(User  , current_user.class  , "Class of @current_user")
    assert_equal(String, flash[:notice].class, "Class of flash[:notice]")
    assert(flash[:notice].present?, "flash[:notice] should be present?")
  end

    def make_user_mock_to_be_updated_successfully
      user_mock = User.new
      def user_mock.authenticated?(old_password)
        true
      end
      def user_mock.update_attributes(params)
        true
      end

      return user_mock
    end
    private :make_user_mock_to_be_updated_successfully

  def test_update_password_for_failed_update
    user_mock = make_user_mock_to_be_updated_unsuccessfully
    @controller.instance_variable_set(:@current_user, user_mock)

    get :update_password, :user => {}
    current_user = assigns(:current_user)

    assert_response :success
    assert_template :change_password
    assert_equal(User, current_user.class, "Class of @current_user")
  end

    def make_user_mock_to_be_updated_unsuccessfully
      user_mock = User.new
      def user_mock.authenticated?(old_password)
        true
      end
      def user_mock.update_attributes(params)
        false
      end

      return user_mock
    end
    private :make_user_mock_to_be_updated_unsuccessfully
end


module UserAuthKuma
class User
  def self.override_new(retval_of_save)
    @@retval_of_save = retval_of_save
    UserAuthKuma::User.instance_eval do
      alias :new_original :new
      alias :new          :new_overridden
    end
  end

  def self.restore_new
    UserAuthKuma::User.instance_eval do
      alias :new :new_original
    end
  end

  def self.new_overridden(params_user)
    user_mock = Object.new
    user_mock.instance_variable_set(:@params_user, params_user)
    user_mock.instance_variable_set(:@retval_of_save, @@retval_of_save)
    def user_mock.params_user
      @params_user
    end
    def user_mock.save
      @retval_of_save
    end

    return user_mock
  end

  def self.override_find(retval_of_update)
    @@retval_of_update = retval_of_update
    User.instance_eval do
      alias :find_original :find
      alias :find          :find_overridden
    end
  end

  def self.restore_find
    User.instance_eval do
      alias :find :find_original
    end
  end

  def self.find_overridden(id)
    user_mock = Object.new
    user_mock.instance_variable_set(:@id, id)
    user_mock.instance_variable_set(:@retval_of_update, @@retval_of_update)
    def user_mock.id
      @id
    end
    def user_mock.params_user
      @params_user
    end
    def user_mock.update_attributes(params_user)
      @params_user = params_user
      @retval_of_update
    end

    return user_mock
  end
end
end

