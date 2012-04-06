class UserAuthMailer < ActionMailer::Base
  default from: 'skelton_admin@skelton.japex.co.jp'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_auth_mailer.password_reset.subject
  #
  def notify_password_reset(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail :to => user.email
  end
end

