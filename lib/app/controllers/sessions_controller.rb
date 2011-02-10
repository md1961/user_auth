# モデル Session の処理を行うコントローラ
class SessionsController < ApplicationController

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
