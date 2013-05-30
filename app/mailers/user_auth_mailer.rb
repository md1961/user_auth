class UserAuthMailer < ActionMailer::Base
  default :from => UserAuthKuma::Constant::Mailer::DEFAULT_FROM

  SYSTEM_NAME = UserAuthKuma::Constant::Mailer::SYSTEM_NAME

  def notify_password_reset(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail :to => user.email, \
         :subject => t("user_auth_mailer.notify_password_reset.subject") % {system_name: SYSTEM_NAME}
  end

  def notify_user_creation(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @url_for_system = UserAuthKuma::Constant::Mailer::URL_FOR_SYSTEM

    mail :to => user.email, \
         :subject => t("user_auth_mailer.notify_user_creation.subject") % {system_name: SYSTEM_NAME}
  end

  def notify_email_change(user)
    @user = user

    mail :to => user.email, \
         :subject => t("user_auth_mailer.notify_email_change.subject") % {system_name: SYSTEM_NAME}
  end
end

