class UserMailer < ActionMailer::Base
  default :from => "hello@hoshinplan.com"
  
  def forgot_password(user, key)
    @user, @key = user, key
    mail( :subject => "#{app_name} -- forgotten password",
          :to      => user.email_address )
  end


  def activation(user, key)
    @user, @key = user, key
    mail( :subject => "#{app_name} -- activate",
          :to      => user.email_address )
  end
  
  def reminder(user, kpis, key)
    @user, @kpis, @key = user, kpis, key
    mail( :subject => "#{app_name} -- reminder",
          :to      => user.email_address )
  end

end
