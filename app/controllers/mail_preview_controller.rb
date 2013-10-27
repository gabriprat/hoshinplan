class MailPreviewController < ApplicationController
  
  skip_before_filter :my_login_required
  skip_around_filter :scope_current_user


  def index() 
    @previews = ["welcome", "invite"]
  end
  
  def preview() 
    @id = params[:id]
  end
  
  def preview_welcome()
    @user = User.find(1)
    render :file => 'user_company_mailer/welcome'
  end
  
  def send_welcome()
    @user = User.find(1)
    @subject = "#{@user.name} welcome to Hoshinplan!"
    UserCompanyMailer.welcome(@user, 
    @subject).deliver
    render :json => { subject: @subject, to: @user.email_address }
  end
  
  def preview_invite()
    user = User.find(1)
    acting_user = user
    user_company = user.user_companies.first
    company = user_company.company
    @key, @user, @user_company, @lead, @message, @callout, @accept_url = 
      "key", user, user_company, "Invitation to the Hoshin Plan of #{company.name}", 
      "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
      "Accept",
      "http://fakeurl.com"
    render :file => 'user_company_mailer/invite'
  end
  
  def send_invite()
    user = User.find(1)
    @user = user
    acting_user = user
    user_company = user.user_companies.first
    company = user_company.company
    @subject = "Invitation to the Hoshin Plan of #{company.name}"
    UserCompanyMailer.invite(user_company, @subject, 
      "#{acting_user.name} wants to invite you to collaborate to their Hoshin Plan.",
      "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
      "Accept",
      "fakekey").deliver
    render :json => { subject: @subject, to: @user.email_address }
  end

end