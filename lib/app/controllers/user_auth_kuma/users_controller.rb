module UserAuthKuma

# モデル User の処理を行うコントローラ
class UsersController < ApplicationController

  ATTRIBUTE_NAMES_TO_LIST          = %w(id name).freeze
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
    if @user.save
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
    if @user.update_attributes(params[:user])
      redirect_to users_path, :notice => t("helpers.notice.user.updated")
    else
      render :edit
    end
  end

  # インスタンスを削除する<br />
  # <em>params[:id]</em> : 削除する User の id
  def destroy
    user = User.find(params[:id])
    if user.id == @current_user.id
      raise ArgumentError, "Cannot destroy currently logged-in user"
    end
    user.destroy

    redirect_to users_path
  end

  # パスワード変更画面を表示する
  def change_password
    # just render
  end

  # パスワードを更新する<br />
  # <em>params[:user][:old_password]</em> : ユーザ確認のための現在のパスワード<br />
  # <em>params[:user]</em> : パスワード（２度入力）を保持する Hash
  def update_password
    if ! @current_user.authenticated?(params[:user][:old_password])
      @current_user.errors.add(:old_password, t("helpers.alert.user.old_password_not_match"))
      render :change_password
    elsif params[:user][:password].blank?
      @current_user.errors.add(:password, t("helpers.alert.user.password_should_be_entered"))
      render :change_password
    elsif @current_user.update_attributes(params[:user])
      redirect_to root_path, :notice => t("helpers.notice.user.updated")
    else
      render :change_password
    end
  end
end

end

