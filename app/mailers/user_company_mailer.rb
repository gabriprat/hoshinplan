class UserCompanyMailer < ActionMailer::Base
  default :from => "no-reply@gabriel.prat.name"

  def invite(user_company, subject, message, key)
    @key, @user, @user_company, @message = key, user_company.user, user_company, message
    mail( :subject => "#{app_name} -- " + subject,
          :to      => @user.email_address )
  end
 
  def transition(user, subject, message)
    @user, @message = user, message
    mail( :subject => "#{app_name} -- " + subject,
          :to      => @user.email_address )
  end
  
end
