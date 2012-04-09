class UserAuthMailer < ActionMailer::Base
  default :from => 'skelton_admin@skelton.japex.co.jp'

  def notify_password_reset(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail :to => user.email
  end

  def notify_user_creation(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @url_for_system = 'http://mimas:4300'

    mail :to => user.email
  end

  def notify_email_change(user)
    @user = user

    mail :to => user.email
  end
end

