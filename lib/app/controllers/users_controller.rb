# モデル User の処理を行うコントローラ
class UsersController < ApplicationController
  before_filter :authenticate, :only => [:change_password, :update_password]
  before_filter :authenticate_as_administrator,
                             :except => [:change_password, :update_password]

  ATTRIBUTE_NAMES_TO_LIST          = %w(id name real_name email time_limit).freeze
  OPTIONAL_ATTRIBUTE_NAMES_TO_LIST = %w(is_writer is_administrator).freeze

  # ユーザの一覧を出力する
  def index
    @users = User.find(:all)

    @attribute_names = ATTRIBUTE_NAMES_TO_LIST.dup
    OPTIONAL_ATTRIBUTE_NAMES_TO_LIST.each do |attr_name|
      @attribute_names << attr_name if User.new.respond_to?(attr_name.to_sym)
    end
  end

  # 新規作成画面を表示する
  def new
    @user = User.new
  end

  # インスタンスを生成する<br />
  # <em>params[:user]</em> : インスタンスを生成するための属性を保持する Hash
  def create
    @user = User.new(params[:user])
    temporary_password = @user.reset_password
    if @user.save
      UserAuthMailer.notify_user_creation(@user, temporary_password).deliver
      redirect_to users_path, :notice => t("helpers.notice.user.created")
    else
      render :new
    end
  end

  # 編集画面を表示する<br />
  # <em>params[:id]</em> : 編集する User の id
  def edit
    @user = User.find(params[:id])
  end

  # インスタンスの属性を更新する<br />
  # <em>params[:id]</em> : 更新する User の id<br />
  # <em>params[:user]</em> : 更新後の属性を保持する Hash
  def update
    @user = User.find(params[:id])
    old_email = @user.email
    if @user.update_attributes(params[:user])
      if @user.email != old_email
        UserAuthMailer.notify_email_change(@user).deliver
      end
      redirect_to users_path, :notice => t("helpers.notice.user.updated")
    else
      render :edit
    end
  end

  # インスタンスを削除する<br />
  # <em>params[:id]</em> : 削除する User の id
  def destroy
    user = User.find(params[:id])
    if user.id == current_user.id
      raise ArgumentError, "Cannot destroy currently logged-in user"
    end
    user.destroy

    redirect_to users_path
  end

  # パスワード変更画面を表示する
  def change_password
    @user = current_user
  end

  # パスワードを更新する<br />
  # <em>params[:user][:old_password]</em> : ユーザ確認のための現在のパスワード<br />
  # <em>params[:user]</em> : パスワード（２度入力）を保持する Hash
  def update_password
    @user = current_user

    old_password = params[:user][:old_password]
    password     = params[:user][:password]

    if ! @user.authenticated?(old_password)
      @user.errors.add(:old_password, t("helpers.alert.user.not_match"))
    elsif password.blank?
      @user.errors.add(:password, t("helpers.alert.user.should_be_entered"))
    elsif password == old_password
      @user.errors.add(:password, t("helpers.alert.user.should_be_different_from_old"))
    elsif @user.update_attributes(params[:user])
      redirect_to root_path, :notice => t("helpers.notice.user.updated")
      return
    end

    render :change_password
  end

  # パスワードをリセットする。<br />
  # 具体的には、現在のパスワードを上書きして一時的なパスワードを設定する<br />
  # <em>params[:id]</em> : パスワードをリセットする User の id
  def reset_password
    @user = User.find(params[:id])
    @new_password = @user.reset_password
    if @user.save
      render
    else
      render :reset_password_failed
    end
  end
end

