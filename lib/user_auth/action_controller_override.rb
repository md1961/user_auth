
class ActionController::Base

  KEY_FOR_USER_ID                  = :user_id
  KEY_FOR_DATETIME_TIMEOUT_CHECKED = :datetime_timeout_checked

  protected

    # ログイン手続きを経ない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインしていれば true、していなければ false（同時にログイン画面にリダイレクトする）
    def authenticate(also_must_be_true=true)
      check_timeout
      return logged_in? && also_must_be_true ? true : access_denied
    end

    # ログイン手続きを経ない、かつ書き込み権限を持たない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインして、かつ書き込み権限を持てば true、なければ false（同時にログイン画面にリダイレクトする）
    def authenticate_as_writer
      return authenticate(current_user.respond_to?(:writer?) && current_user.writer?)
    end

    # ログイン手続きを経ない、かつ管理者権限を持たない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインして、かつ管理者権限を持てば true、なければ false（同時にログイン画面にリダイレクトする）
    def authenticate_as_administrator
      return authenticate(current_user.respond_to?(:administrator?) && current_user.administrator?)
    end

    # 現在のログインユーザを返す
    # 返り値 :: 現在のログインユーザ。ログインしていなければ nil
    def current_user
      user_id = session[KEY_FOR_USER_ID]
      return nil unless user_id
      return @current_user ||= User.find(user_id)
    end

    helper_method :current_user

    # ログインしているか評価する
    # 返り値 :: ログインしていれば true、していなければ false
    def logged_in?
      return current_user.is_a?(User)
    end

    helper_method :logged_in?

    # ログイン画面にリダイレクトして false を返す
    # 返り値 :: 常に false
    def access_denied
      reset_session
      redirect_to login_path and return false
    end

    # セッションタイムアウトを起こしていないかチェックする
    def check_timeout
      timeout = UserAuthKuma::Constant::SESSION_TIMEOUT_IN_MIN
      datetime_checked = session[KEY_FOR_DATETIME_TIMEOUT_CHECKED]
      if datetime_checked && datetime_checked < timeout.minutes.ago 
        reset_session

        flash[:notice] = t("helpers.notice.session.timeout") % {timeout: timeout}
        logger.debug "ActionController::Base#check_timeout(): Session had been timed out"
      else
        session[KEY_FOR_DATETIME_TIMEOUT_CHECKED] = Time.now
      end
    end
end

