class FrontController < ApplicationController

  hobo_controller 
  
  # Require the user to be logged in for every other action on this controller
  # except :index. 
  skip_before_filter :my_login_required, :only => [:test_fail, :index, :pitch, :sendreminders, :updateindicators, :expirecaches, :resetcounters, :healthupdate, :colorize, :reprocess_photos]
  
  def index
    if !current_user.nil? && !current_user.guest? && current_user.user_companies.empty?
      redirect_to "/first"
    elsif !current_user.nil? && !current_user.guest? && current_user.respond_to?('tutorial_complete?') && !current_user.tutorial_complete? && current_user.hoshins.empty? && current_user.companies.size == 1
      redirect_to current_user.companies.first
    elsif !current_user.nil? && !current_user.guest? && current_user.respond_to?('tutorial_complete?') && !current_user.tutorial_complete? && current_user.hoshins.size == 1
      redirect_to current_user.hoshins.first
    elsif !current_user.nil? && !current_user.guest?
       redirect_to current_user
    end
  end
  
  def test_fail
    fail "Test fail!"
  end
 
  def first
    
  end
  
  def cms
    
  end
  
  def pitch
  end
  
  def pricing
    @freq = params[:freq]
    @freq ||= :MONTH
  end
  
  def invitation_accepted
    flash[:notice] = nil
  end
  
  def sso_login
    if params["email"].nil?
      flash[:error] = t("errors.invalid_credentials")
      render "index"
    else
      user, domain = params["email"].split("@")
      prov = AuthProvider.where(:email_domain => domain).first
      if prov.nil?
        flash[:error] = t("no_oid_url", :default => "No corporate login for the given email")
        render "index"
      else
        if prov.type == 'OpenidProvider' 
          oi = prov.openid_url
          url = oi.gsub('{user}', user)
          redirect_to "/auth/openid?openid_url=" + url
        elsif prov.type == 'SamlProvider'
          redirect_to "/auth/saml_" + prov.email_domain
        else
          flash[:error] = "Unknown provider: " + prov.type.to_s
          render "index"
        end
      end
    end
  end
  
  def sendreminders   
    require File.expand_path('config/jobs/base_job.rb')
    Dir['config/jobs/*.rb'].each {|file| require File.expand_path(file)}

    @text = Jobs::SendReminders.perform(params[:hour])
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def reprocess_photos
    User.unscoped.where("image_updated_at < now()- interval '2 hour'").each do |user|
      user.image.reprocess!
    end
  end
  
  def set_colors
    @text = Jobs::SetColors.perform
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def updateindicators
    require File.expand_path('config/jobs/base_job.rb')
    Dir['config/jobs/*.rb'].each {|file| require File.expand_path(file)}
    
    @text = Jobs::UpdateIndicators.perform
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def expirecaches
    require File.expand_path('config/jobs/base_job.rb')
    Dir['config/jobs/*.rb'].each {|file| require File.expand_path(file)}
    
    @text = Jobs::ExpireCaches.new.perform
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def exec_sqls(sqls)
    lines = sqls.lines
    lines.reject! {|line|
      line.strip!
      line.empty?
    }
    n = lines.count
    ret = ll "Executing #{n} sqls..."
    lines.each.with_index do |sql, i|
      ret += ll "(#{i}/#{n}) Executing: #{sql}"
      res = ActiveRecord::Base.connection.execute(sql)
      ret += ll "====  Done! #{res.cmd_tuples} rows affected"
    end
    ret
  end
  
  def updatepeoplemixpanel
    User.all.each {|user|
      Mp.people_set(user, '')
    }
  end
  
  def healthupdate
    require File.expand_path('config/jobs/base_job.rb')
    Dir['config/jobs/*.rb'].each {|file| require File.expand_path(file)}
    
    @text = Jobs::HealthUpdate.new.perform
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def resetcounters
    @text = exec_sqls("
      update hoshins set goals_count = (select count(*) from goals where hoshin_id = hoshins.id) where goals_count != (select count(*) from goals where hoshin_id = hoshins.id);

      update hoshins set areas_count = (select count(*) from areas where hoshin_id = hoshins.id) where areas_count != (select count(*) from areas where hoshin_id = hoshins.id);

      update objectives set hoshin_id = (select hoshin_id from areas where areas.id = area_id) where hoshin_id != (select hoshin_id from areas where areas.id = area_id);
      update hoshins set objectives_count = (select count(*) from objectives where hoshin_id = hoshins.id) where objectives_count != (select count(*) from objectives where hoshin_id = hoshins.id);

      update indicators set hoshin_id = (select hoshin_id from objectives where objectives.id = objective_id) where hoshin_id != (select hoshin_id from objectives where objectives.id = objective_id);
      update hoshins set indicators_count = (select count(*) from indicators where hoshin_id = hoshins.id) where indicators_count != (select count(*) from indicators where hoshin_id = hoshins.id);

      update tasks set hoshin_id = (select hoshin_id from objectives where objectives.id = objective_id) where hoshin_id != (select hoshin_id from objectives where objectives.id = objective_id);
      update hoshins set tasks_count = (select count(*) from tasks where hoshin_id = hoshins.id and status = 'active') where tasks_count != (select count(*) from tasks where hoshin_id = hoshins.id and status = 'active');

      update areas set objectives_count = (select count(*) from objectives where area_id = areas.id) where objectives_count != (select count(*) from objectives where area_id = areas.id);

      update indicators set area_id = (select area_id from objectives where objectives.id = objective_id) where area_id != (select area_id from objectives where objectives.id = objective_id);
      update areas set indicators_count = (select count(*) from indicators where area_id = areas.id) where indicators_count != (select count(*) from indicators where area_id = areas.id);

      update tasks set area_id = (select area_id from objectives where objectives.id = objective_id) where area_id != (select area_id from objectives where objectives.id = objective_id) ;
      update areas set tasks_count = (select count(*) from tasks where area_id = areas.id and status = 'active') where tasks_count != (select count(*) from tasks where area_id = areas.id and status = 'active');
    ");
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def colorize
    @text = ll "Initiating colorize job!"
    @text = ""
    Area.unscoped.where(:color => nil).each{ |area|
      col = area.color
      @text += ll "Area #{area.id}: #{col}"
    }
    
    User.unscoped.where(:color => nil).each{ |user|
      col = user.color
      @text += ll "User #{user.id}: #{col}"
    }
    @text += ll "End colorize job!"
    render :text => @text, :content_type => Mime::TEXT
  end

  def summary
    if !current_user.administrator?
      redirect_to user_login_path
    end
  end

  def search
    if params[:query]
      site_search(params[:query])
    end
  end
  
  def failure
    msg = t("errors." + params[:message].to_s, :default => t("errors.unknown") + params[:message].to_s) 
    unless params[:error_reason].blank? 
      msg += " " + t("errors.provider_said", :default => "The message from your authentication provider was: ") + " " + params[:error_reason]
    end
    flash[:error] = msg
    
    render 'index'
  end
  
  def health_check
    if !current_user.nil? 
      redirect_to "/first"
    end
  end

end
