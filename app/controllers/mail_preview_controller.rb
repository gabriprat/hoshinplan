class MailPreviewController < ApplicationController
  
  hobo_controller

  
  def index() 
    @previews = ["welcome", "invited_welcome", "invite", "reminder"]
  end
  
  def preview() 
    @id = params[:id]
  end
  
  def preview_welcome()
    @user = current_user
    render :text => UserCompanyMailer.welcome(current_user).body   
  end
  
  def send_welcome()
    @user = current_user
    UserCompanyMailer.welcome(@user).deliver
    render :json => {to: @user.email_address }
  end
  
  def preview_invited_welcome()
    @user = current_user
    render :file => 'user_company_mailer/invited_welcome'
  end
  
  def send_invited_welcome()
    @user = current_user
    @subject = "#{@user.name} welcome to Hoshinplan!"
    UserCompanyMailer.invited_welcome(@user, 
    @subject).deliver
    render :json => { subject: @subject, to: @user.email_address }
  end
  
  def preview_invite()
    user = current_user
    user_company = user.user_companies.first
    company = user_company.company
    @key, @user, @user_company, @lead, @message, @callout, @accept_url = 
      "key", user, user_company, "Invitation to the Hoshin Plan of #{company.name}", 
      "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
      "Accept",
      "http://fakeurl.com"
    render :file => 'user_company_mailer/invite'
  end
  
  def send_invited()
    user = current_user
    @user = user
    user_company = user.user_companies.first
    company = user_company.company
    @subject = "Invitation to the Hoshin Plan of #{company.name}"
    UserCompanyMailer.invite(user_company, @subject, 
      "#{current_user.name} wants to invite you to collaborate to their Hoshin Plan.",
      "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
      "Accept",
      "fakekey").deliver
    render :json => { subject: @subject, to: @user.email_address }
  end

  def preview_reminder
    render :text => UserCompanyMailer.reminder(current_user).body   
  end
  
  def send_reminder
    @user = current_user
    UserCompanyMailer.reminder(@user).deliver
    render :json => {to: @user.email_address }
  end

end