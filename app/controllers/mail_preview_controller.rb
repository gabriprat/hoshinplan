require 'hobo_fields/types/enum_string'

class MailPreviewController < ApplicationController
  
  hobo_controller

  
  def index() 
    @previews = ["welcome", "invited_welcome", "invite", "reminder", "accept", "admin", "no_admin", "removed"]
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
    UserCompanyMailer.delay.welcome(@user)
    render :json => {to: @user.email_address }
  end
  
  def preview_invited_welcome()
    render :text => UserCompanyMailer.invited_welcome(current_user).body   
  end
  
  def send_invited_welcome()
   UserCompanyMailer.delay.invited_welcome(current_user)  
  end
  
  def preview_invite()
    user = current_user
    user_company = user.user_companies.first
    company = user_company.company
    render :text => UserCompanyMailer.invite(user_company, company.name, 'fake_key', user).body
  end
  
  def send_invite()
    user = current_user
    user_company = user.user_companies.first
    company = user_company.company
    UserCompanyMailer.delay.invite(user_company, company.name, 'fake_key', user)
    render :json => { to: user_company.user.email_address }
  end

  def preview_reminder
    render :text => UserCompanyMailer.reminder(current_user).body   
  end
  
  def send_reminder
    @user = current_user
    UserCompanyMailer.delay.reminder(@user)
    render :json => {to: @user.email_address }
  end
  
  def preview_accept
    render :text => UserCompanyMailer.transition(current_user, current_user, current_user.companies.first,'accept').body   
  end
  
  def send_accept
    @user = current_user
    UserCompanyMailer.delay.transition(current_user, current_user, current_user.companies.first,'accept')
    render :json => {to: current_user.email_address }
  end
  
  def preview_admin
    render :text => UserCompanyMailer.transition(current_user, current_user, current_user.companies.first,'admin').body   
  end
  
  def send_admin
    @user = current_user
    UserCompanyMailer.delay.transition(current_user,current_user, current_user.companies.first, 'admin')
    render :json => {to: current_user.email_address }
  end
  
  def preview_no_admin
    render :text => UserCompanyMailer.transition(current_user, current_user, current_user.companies.first,'no_admin').body   
  end
  
  def send_no_admin
    @user = current_user
    UserCompanyMailer.delay.transition(current_user, current_user, current_user.companies.first,'no_admin')
    render :json => {to: current_user.email_address }
  end
  
  def preview_removed
    render :text => UserCompanyMailer.transition(current_user, current_user, current_user.companies.first,'removed').body   
  end
  
  def send_removed
    @user = current_user
    UserCompanyMailer.delay.transition(current_user, current_user, current_user.companies.first,'removed')
    render :json => {to: current_user.email_address }
  end

end