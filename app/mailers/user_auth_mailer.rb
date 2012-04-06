class UserAuthMailer < ActionMailer::Base
  default from: 'skelton_admin@skelton.japex.co.jp'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_auth_mailer.password_reset.subject
  #
  def password_reset(user_to)
    @greeting = "Hello"

    mail :to => user_to.email
  end
end
