class MailPreviewController < ApplicationController

  def preview_welcome()
    @user = User.first
    render :file => 'user_company_mailer/welcome'
  end
  
  def send_welcome()
    @user = User.first
    UserCompanyMailer.welcome(@user, 
    "#{@user.name} welcome to Hoshinplan!").deliver
    redirect_to action: "preview_welcome"
  end
  
  def preview_invite()
    user = User.first
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
    user = User.first
    @user = user
    acting_user = user
    user_company = user.user_companies.first
    company = user_company.company
    UserCompanyMailer.invite(user_company, "Invitation to the Hoshin Plan of #{company.name}", 
      "#{acting_user.name} wants to invite you to collaborate to their Hoshin Plan.",
      "By accepting this invitation you will be able to participate in the Hoshin plan of their company: #{company.name}.",
      "Accept",
      "fakekey").deliver
    redirect_to action: "preview_invite"
  end

end