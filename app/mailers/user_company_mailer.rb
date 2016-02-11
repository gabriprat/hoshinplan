class UserCompanyMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  
  default :from => "Hoshinplan Team <hello@hoshinplan.com>",
          'X-SMTPAPI' => '{"filters": { "subscriptiontrack": { "settings": {"replace": "#unsubscribe_url#", "enable": 1} } } }'
          
  def render_email(name, params)
    user = params[:user]
    #fail Dryml::Taglib.get({:src => 'email_template',  :template_dir=>"app/views/user_company_mailer", :template_path=>"app/views/user_company_mailer/email_template", :source_template=>"user_company_mailer/reminder"}).to_s
  Dryml.render(File.read("app/views/user_company_mailer/" + name + ".dryml"), 
    params,
    "app/views/user_company_mailer/" + name + ".dryml",
    [{:src => 'hobo_rapid', :gem => 'hobo_rapid'}, {:src => 'email_template'}],
    nil,
    [ActionView::Helpers::UrlHelper, ActionView::Helpers::ControllerHelper, HoboRouteHelper, HoboPermissionsHelper, ActionView::Helpers::ActiveModelHelper]
    )
  end

  def invite(user_company, company, key, invitor, language)
    I18n.locale = language.blank? ? I18n.default_locale : language
    ret = mail( :subject => I18n.translate("emails.invite.subject", :name => invitor.name.blank? ? invitor.email_address : invitor.name, :company => company), 
          :to      => user_company.user.email_address,
          :from    => invitor.name + " at hoshinplan.com <no-reply@hoshinplan.com>" )  do |format|
              format.html {    
                render_email("invite", 
                  {:user => user_company.user, :app_name => @app_name, :company => company.name,
                    :accept_url => accept_from_email_url(:id => user_company, :key => key), :invitor => invitor})          
              }
    end
    
  end
  
  def new_invite(key, invitor, invitee, language)
    I18n.locale = language.blank? ? I18n.default_locale : language
    ret = mail( :subject => I18n.translate("emails.new_invite.subject", :name => invitor.name.blank? ? invitor.email_address : invitor.name), 
          :to      => invitee.email_address,
          :from    => invitor.name + " at hoshinplan.com <no-reply@hoshinplan.com>" )  do |format|
              format.html {    
                render_email("new_invite", 
                  {:user => invitee, :app_name => @app_name,
                    :accept_url => accept_invitation_from_email_url(:id => invitee, :key => key), :invitor => invitor})          
              }
    end
    
  end
 
  def transition(user, user2, company, email_key)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    ret = mail( :subject => I18n.translate("emails." + email_key + ".subject", :company => company, :user => user.name.blank? ? user.email_address : user.name),
          :to      => user.email_address) do |format|
              format.html {    
                render_email("transition", 
                  {:user => user, :app_name => @app_name, 
                    :message => I18n.translate("emails." + email_key + ".message", :user => user.name.blank? ? user.email_address : user.name, :user2 => user2.name.blank? ? user2.email_address : user2.name, :company => company.name).html_safe})          
              }
    end
    
  end

  def get_host_port(user) 
    language = user.language || "es"
    uri = Addressable::URI.parse(root_url(:subdomain => language))
    ret = uri.host 
    ret = ret + (':' + uri.port.to_s) if uri.port != 80
    ret.chomp!(':')
    ret
  end
  
  def reminder(user, kpis, tasks)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user = user
    ret = mail( :subject => I18n.translate("emails.reminder.subject"),
          :to      => @user.email_address,
          :from    => "Hoshinplan Notifications <alerts@hoshinplan.com>") do |format|
            format.html {    
              render_email("reminder", 
                {:user => @user, :app_name => @app_name, 
                  :url => pending_user_url(@user, :host => get_host_port(user)),
                  :kpis => kpis, :tasks => tasks})          
            }
    end
  end
  
  def welcome(user)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    ret = mail( :subject => I18n.translate("emails.welcome.subject", :name => user.name.blank? ? user.email_address : user.name), 
          :to      => user.email_address) do |format|
            format.html {
              render_email("welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
    
  end
  
  def invited_welcome(user)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user, @message = user
    ret = mail( :subject => I18n.translate("emails.invited_welcome.subject", :name => user.name.blank? ? user.email_address : user.name),
          :to      => @user.email_address) do |format|
            format.html {
              render_email("invited_welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
    
  end
  
  def forgot_password(user, key)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user, @message = user, @key = key
    ret = mail( :subject => I18n.translate("emails.forgot_password.subject", :name => user.name.blank? ? user.email_address : user.name),
          :to      => @user.email_address) do |format|
            format.html {
              render_email("forgot_password", {
                  :user => user, :app_name => @app_name,
                  :url => reset_password_from_email_url(:id => @user, :key => @key)
                }          
              )
            }
    end
    
  end


  def activation(user, key)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user, @message = user, @key = key
    ret = mail( :subject => I18n.translate("emails.activation.subject", :name => user.name.blank? ? user.email_address : user.name),
          :to      => @user.email_address) do |format|
            format.html {
              render_email("activation", {
                :user => user, :app_name => @app_name,
                :url =>  activate_from_email_url(:id => @user, :key => @key)
                }          
              )
            }
    end
    
  end
  
  def mention(mentioning_user, user, object, message)
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user = user
    ret = mail( :subject => I18n.translate("emails.mention.subject", name: object.hoshin.name),
          :to      => @user.email_address,
          :from    => "Hoshinplan Notifications <alerts@hoshinplan.com>") do |format|
            format.html {    
              render_email("mention", {
                 mentioning_user: mentioning_user, user: @user, app_name: @app_name, 
                 model: object.class.model_name.human, name: object.name, url: url_for(object),
                 hoshin_name: object.hoshin.name, hoshin_url: url_for(object.hoshin), message: message
              })
            }
    end
  end
  
end
