class UserCompanyMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  
  default :from => "Hoshinplan Team <hello@hoshinplan.com>"
  
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

  def invite(user_company, company, key, invitor)
    mail( :subject => I18n.translate("emails.invite.subject", :name => invitor.name.blank? ? invitor.email_address : invitor.name, :company => company), 
          :to      => user_company.user.email_address,
          :from    => invitor.name + " at hoshinplan.com <no-reply@hoshinplan.com>" )  do |format|
              format.html {    
                render_email("invite", 
                  {:user => user_company.user, :app_name => @app_name, :company => user_company.company.name,
                    :accept_url => accept_from_email_url(:id => user_company, :key => key), :invitor => invitor})          
              }
      end
  end
 
  def transition(user, user2, company, email_key)
    mail( :subject => I18n.translate("emails." + email_key + ".subject", :company => company, :user => user.name.blank? ? user.email_address : user.name),
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
    @user = user
    if @user.state == "active" 
      mail( :subject => I18n.translate("emails.reminder.subject"),
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
  end
  
  def welcome(user)
    mail( :subject => I18n.translate("emails.welcome.subject", :name => user.name.blank? ? user.email_address : user.name), 
          :to      => user.email_address) do |format|
            format.html {
              render_email("welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
  end
  
  def invited_welcome(user)
    @user, @message = user
    mail( :subject => I18n.translate("emails.invited_welcome.subject"),
          :to      => @user.email_address) do |format|
            format.html {
              render_email("invited_welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
  end
  
end
