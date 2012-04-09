class UserAuthMailer < ActionMailer::Base
  default :from => 'skelton_admin@skelton.japex.co.jp'

  def notify_password_reset(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail :to => user.email, :subject => I18n.t("mail.reset_password.subject")
  end

  def notify_user_creation(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @url_for_system = 'http://mimas:4300'

    mail :to => user.email, :subject => I18n.t("mail.user_creation.subject")
  end
end

