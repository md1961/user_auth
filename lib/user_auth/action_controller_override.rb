
class ActionController::Base
  protected

    # ログイン手続きを経ない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインしていれば true、していなければ false（同時にログイン画面にリダイレクトする）
    def authenticate
      return logged_in? ? true : access_denied
    end

    # ログイン手続きを経ない、かつ書き込み権限を持たない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインして、かつ書き込み権限を持てば true、なければ false（同時にログイン画面にリダイレクトする）
    def authenticate_as_writer
      return logged_in? && current_user.writer? ? true : access_denied
    end

    # ログイン手続きを経ない、かつ管理者権限を持たない不正なアクセスを遮断するためのフィルタ・メソッド。
    # アクセスを遮断したいコントローラの before_filter に設定する
    # 返り値 :: ログインして、かつ管理者権限を持てば true、なければ false（同時にログイン画面にリダイレクトする）
    def authenticate_as_administrator
      return logged_in? && current_user.administrator? ? true : access_denied
    end

    # 現在のログインユーザを返す
    # 返り値 :: 現在のログインユーザ。ログインしていなければ nil
    def current_user
      user_id = session[:user_id]
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
      redirect_to login_path and return false
    end
end

