# モデル Session の処理を行うコントローラ
class SessionsController < ApplicationController
  skip_filter :authenticate

  # lib/constant.rb にログイン許可／不許可を指定するときの名称と、そのデフォルト値
  DEFAULT_LOGIN_ALLOWANCE = {
    :login_enabled  => true ,
    :login_disabled => false,
  }

  # ログイン／ログアウト時のログ出力の出力フォーマット・テンプレート
  TEMPLATE_FORMAT_LOG_LOGIN_LOGOUT = "[LOG%s@%%s] User '%%s' logged %s from %%s"
  # ログイン時のログ出力の出力フォーマット
  FORMAT_LOG_LOGIN  = TEMPLATE_FORMAT_LOG_LOGIN_LOGOUT % ['IN ', 'in ']
  # ログアウト時のログ出力の出力フォーマット
  FORMAT_LOG_LOGOUT = TEMPLATE_FORMAT_LOG_LOGIN_LOGOUT % ['OUT', 'out']
  # ログ出力時のタイムスタンプのフォーマット
  FORMAT_TIMESTAMP  = "%Y/%m/%d %H:%M:%S %Z"

  # ログイン画面を表示する
  # Constant.get(:login_enabled) が false を返すか、Constant.get(:login_disabled) が
  # true を返す場合は、ログインができない旨を表示する。
  def new
    login_allowance = Hash.new { |hash, key| DEFAULT_LOGIN_ALLOWANCE[key] }
    DEFAULT_LOGIN_ALLOWANCE.keys.each do |key|
      login_allowance[key] = Constant.get(key) if Constant.has_key?(key)
    end
    is_login_disallowed = ! login_allowance[:login_enabled] || login_allowance[:login_disabled]

    render is_login_disallowed ? :login_disabled : :new
  end

  # ログイン認証を行い、成功すれば Session にユーザIDを設定する。失敗した場合はログイン画面に戻る<br />
  # <em>params[:name]</em> : ユーザ名<br />
  # <em>params[:password]</em> : パスワード
  def create
    if params[:reset_password]
      user = User.find_by_name(params[:name])
      unless user
        flash.now[:alert] = t("helpers.notice.session.username_required")
      else
        temporary_password = user.reset_password
        if user.save
          UserAuthMailer.notify_password_reset(user, temporary_password).deliver

          flash.now[:alert] = t("helpers.notice.session.password_reset_and_mail_sent")
        else
          flash.now[:alert] = t("helpers.notice.session.password_reset_failed")
        end
      end
      render :new
    elsif user = User.authenticate(params[:name], params[:password])
      session[KEY_FOR_USER_ID] = user.id

      logger.warn(FORMAT_LOG_LOGIN % [timestamp, user.name, request.env['REMOTE_ADDR']])

      redirect_to root_path
    else
      flash.now[:alert] = t("helpers.notice.session.invalid_login")

      render :new
    end
  end

  # Session のデータをクリアし、ログイン画面に戻る
  def destroy
    logger.warn(FORMAT_LOG_LOGOUT % [timestamp, current_user.name, request.env['REMOTE_ADDR']]) if logged_in?

    reset_session_safely

    redirect_to root_path, :notice => t("helpers.notice.session.logged_out")
  end

  private

    def timestamp(timestamp=nil)
      timestamp = Time.now unless timestamp
      return timestamp.strftime(FORMAT_TIMESTAMP)
    end
end

