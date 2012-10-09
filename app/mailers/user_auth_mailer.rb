class UserAuthMailer < ActionMailer::Base
  default :from => UserAuthKuma::Constant::Mailer::DEFAULT_FROM

  SYSTEM_NAME = UserAuthKuma::Constant::Mailer::SYSTEM_NAME

  def notify_password_reset(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail :to => user.email
  end

  def notify_user_creation(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @url_for_system = UserAuthKuma::Constant::Mailer::URL_FOR_SYSTEM

    mail :to => user.email
  end

  def notify_email_change(user)
    @user = user

    mail :to => user.email
  end
end

