class UserCompanyMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  
  default :from => "hello@hoshinplan.com"
  
  def render_email(name, params)
    user = params[:user]
    pars = {:unsubscribe_url => unsubscribe_user_url(user, :host => get_host_port(user))}
    pars = pars.merge(params)
    #fail Dryml::Taglib.get({:src => 'email_template',  :template_dir=>"app/views/user_company_mailer", :template_path=>"app/views/user_company_mailer/email_template", :source_template=>"user_company_mailer/reminder"}).to_s
  Dryml.render(File.read("app/views/user_company_mailer/" + name + ".dryml"), 
    pars,
    "app/views/taglibs/new-tags/" + name,
    [{:src => 'hobo_rapid', :gem => 'hobo_rapid'}, {:src => 'email_template'}],
    nil,
    [ActionView::Helpers::UrlHelper, ActionView::Helpers::ControllerHelper, HoboRouteHelper, HoboPermissionsHelper, ActionView::Helpers::ActiveModelHelper]
    )
  end

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
  
  def get_host_port(user) 
    language = user.language || "es"
    uri = Addressable::URI.parse(root_url(:subdomain => language))
    ret = uri.host 
    ret = ret + (':' + uri.port.to_s) if uri.port != 80
    ret
  end
  
  def reminder(user)
    @user = user
    if @user.state == "active" 
      mail( :subject => I18n.translate("emails.reminder.subject"),
            :to      => @user.email_address,
            :from    => "alerts@hoshinplan.com") do |format|
              format.html {    
                render_email("reminder", 
                  {:user => @user, :app_name => @app_name, :url => pending_user_url(@user, :host => get_host_port(user))})          
              }
      end
    end
  end
  
  def welcome(user)
    mail( :subject => I18n.translate("emails.welcome.subject", :name => user.name.empty? ? user.email_address : user.name),
          :to      => user.email_address) do |format|
            format.html {
              render_email("welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
  end
  
  def invited_welcome(user, subject)
    @user, @message = user
    mail( :subject => subject,
          :to      => @user.email_address)
  end
  
end
