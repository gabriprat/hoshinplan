class UserMailer < ActionMailer::Base
  default :from => "no-reply@gabriel.prat.name"
  
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
  
  def remainder(user, kpis, key)
    @user, @kpis, @key = user, kpis, key
    mail( :subject => "#{app_name} -- remainder",
          :to      => user.email_address )
  end

end
