# モデル Session の処理を行うコントローラ
class SessionsController < ApplicationController

  DEFAULT_LOGIN_ALLOWANCE = {
    :login_enabled  => true ,
    :login_disabled => false,
  }

  # ログイン画面を表示する
  # Constant.get(:login_enabled) が false を返すか、Constant.get(:login_disabled) が
  # true を返す場合は、ログインができない旨を表示する。
  def new
    login_allowance = Hash.new { |hash, key| DEFAULT_LOGIN_ALLOWANCE[key] }
    [:login_enabled, :login_disabled].each do |key|
      login_allowance[key] = Constant.get(key) if Constant.has_key?(key)
    end
    is_login_disallowed = ! login_allowance[:login_enabled] || login_allowance[:login_disabled]

    render is_login_disallowed ? :login_disabled : :new
  end

  # ログイン認証を行い、成功すれば Session にユーザIDを設定する。失敗した場合はログイン画面に戻る<br />
  # <em>params[:name]</em> : ユーザ名<br />
  # <em>params[:password]</em> : パスワード
  def create
    if user = User.authenticate(params[:name], params[:password])
      session[KEY_FOR_USER_ID] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = t("helpers.notice.session.invalid_login")
      render :new
    end
  end

  # Session のデータをクリアし、ログイン画面に戻る
  def destroy
    reset_session
    redirect_to root_path, :notice => t("helpers.notice.session.logged_out")
  end
end
