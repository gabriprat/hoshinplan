class UserCompanyMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  include SendGrid
  
  default :from => "Hoshinplan Team <hello@hoshinplan.com>",
          'X-SMTPAPI' => '{"filters": { "subscriptiontrack": { "settings": {"replace": "#unsubscribe_url#", "enable": 1} } } }'       
  
  @@renderer = {}
  
  def get_renderer(key, locals)
    unless @@renderer.has_key?(key)
      Rails.logger.debug "================= COMPILING EMAIL TEMPLATE #{key} =================="
      template_path = "app/views/user_company_mailer/" + key + ".dryml"
      template_src = File.read(template_path)
      included_taglibs = [{:src => 'hobo_rapid', :gem => 'hobo_rapid'}, {:src => 'email_template'}]
      imports = [ActionView::Helpers::UrlHelper, ActionView::Helpers::ControllerHelper, HoboRouteHelper, HoboPermissionsHelper, ActionView::Helpers::ActiveModelHelper]
      @@renderer[key] = Dryml.send(:make_renderer_class, template_src, template_path, locals.keys, included_taglibs, imports)
    end
    @@renderer[key]
  end
  
  def render_email(key, locals)
    view = ActionView::Base.new(ActionController::Base.view_paths, {})
    this = locals.delete(:this) || nil
    ret = get_renderer(key, locals).new(view).render_page(this, locals)
    Rails.logger.debug "================= FINISHED RENDERING EMAIL #{key} =================="
    ret
  end

  def invite(user_company, company, key, invitor, language)
    sendgrid_category "invite"
    I18n.locale = language.blank? ? I18n.default_locale : language
    mail( :subject => I18n.translate("emails.invite.subject", :name => invitor.name.blank? ? invitor.email_address : invitor.name, :company => company), 
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
    sendgrid_category "new_invite"
    I18n.locale = language.blank? ? I18n.default_locale : language
    mail( :subject => I18n.translate("emails.new_invite.subject", :name => invitor.name.blank? ? invitor.email_address : invitor.name), 
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
    sendgrid_category "transition"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
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
    sendgrid_category "reminder"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user = user
    html_body = render_email("reminder", 
                {:user => @user, :app_name => @app_name, 
                  :url => pending_user_url(@user, :host => get_host_port(user)),
                  :kpis => kpis, :tasks => tasks})
    Rails.logger.info "========= Mail rendered, starting sending to (#{@user.email_address}) ============"
    mail( :subject => I18n.translate("emails.reminder.subject"),
          :to      => @user.email_address,
          :from    => "Hoshinplan Notifications <alerts@hoshinplan.com>") do |format|
            format.html {    
              html_body          
            }
          end
  end
  
  def welcome(user)
    sendgrid_category "welcome"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    name = user.name.blank? ? user.email_address : user.name
    vars = {}
    vars[:name] ||= user.name.blank? ? user.email_address : user.name
    template = EmailTemplate.welcome
    mail( :subject => template.render_subject(vars),
          :to      => user.email_address,
          :from    => t("emails.from.gabriel") + " <gabri@hoshinplan.com>") do |format|
      format.html {
        template.render_content(vars)
      }
    end
  end
  
  def invited_welcome(user)
    sendgrid_category "invited_welcome"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user, @message = user
    mail( :subject => I18n.translate("emails.invited_welcome.subject", :name => user.name.blank? ? user.email_address : user.name),
          :to      => @user.email_address) do |format|
            format.html {
              render_email("invited_welcome", 
                {:user => user, :app_name => @app_name}          
              )
            }
    end
  end
  
  def forgot_password(user, key)
    sendgrid_category "forgot_password"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user, @message = user, @key = key
    mail( :subject => I18n.translate("emails.forgot_password.subject", :name => user.name.blank? ? user.email_address : user.name),
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
    sendgrid_category "activation"
    I18n.locale = user.language.to_s.blank? ? (I18n.locale || I18n.default_locale) : user.language.to_s
    mail_from_template(EmailTemplate.activation, user, {
      url: activate_from_email_url(:id => user, :key => key)}
    )
  end
  
  def mention(mentioning_user, user, object, message)
    sendgrid_category "mention"
    I18n.locale = user.language.to_s.blank? ? I18n.default_locale : user.language.to_s
    @user = user
    hoshin = Hoshin.unscoped.find(object.hoshin_id)
    mail( :subject => I18n.translate("emails.mention.subject", name: hoshin.name),
          :to      => @user.email_address,
          :from    => "Hoshinplan Notifications <alerts@hoshinplan.com>") do |format|
            format.html {    
              render_email("mention", {
                 mentioning_user: mentioning_user, user: @user, app_name: @app_name, 
                 model: object.class.model_name.human, name: object.name, url: url_for(object),
                 hoshin_name: hoshin.name, hoshin_url: url_for(hoshin), message: message
              })
            }
          end
  end

  def admin_payment_error(subscription, e)
    sendgrid_category "payment_error"
    mail( :subject => "Payment error for subscription #{subscription.id}!",
          :to      => User.administrator.pluck(:email_address),
          :from    => "Hoshinplan Jobs <no-reply@hoshinplan.com>" )  do |format|
      format.text {
        render text: "Payment error for subscription #{subscription.id}!"
          + e.message + "\n"
          + e.backtrace.join("\n")
      }
    end
  end
  
  private
  
  def mail_from_template(template, user, vars={})
    vars[:name] ||= user.name.blank? ? user.email_address : user.name
    mail( :subject => template.render_subject(vars),
          :to      => user.email_address) do |format|
      format.html {
        template.render_content(vars)
      }
    end
  end  
end
