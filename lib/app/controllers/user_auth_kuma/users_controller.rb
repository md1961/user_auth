module UserAuthKuma

# モデル User の処理を行うコントローラ
class UsersController < ApplicationController

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
    elsif @current_user.update_attributes(params[:user])
      redirect_to projects_path, :notice => t("helpers.notice.user.updated")
    else
      render :change_password
    end
  end
end

end

