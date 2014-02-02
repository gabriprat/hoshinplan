class UserCompanyMailer < ActionMailer::Base
  default :from => "hello@hoshinplan.com"

  def invite(user_company, subject, lead, message, callout, key, invitor)
    @key, @user, @user_company, @lead, @message, @callout = 
    key, user_company.user, user_company, lead, message, callout
    mail( :subject => subject,
          :to      => @user.email_address,
          :from    => invitor.name + " at hoshinplan.com <no-reply@hoshinplan.com>" )
  end
 
  def transition(user, subject, message)
    @user, @message = user.email_address, message
    mail( :subject => subject,
          :to      => @user)
  end
  
  def reminder(user, subject, message)
    @user, @message = user, message
    mail( :subject => subject,
          :to      => @user.email_address,
          :from    => "alerts@hoshinplan.com")
  end
  
  def welcome(user, subject)
    @user, @message = user
    mail( :subject => subject,
          :to      => @user.email_address)
  end
  
  def invited_welcome(user, subject)
    @user, @message = user
    mail( :subject => subject,
          :to      => @user.email_address)
  end
  
end
