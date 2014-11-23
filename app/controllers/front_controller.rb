class FrontController < ApplicationController

  hobo_controller 
  
  # Require the user to be logged in for every other action on this controller
  # except :index. 
  skip_before_filter :my_login_required, :only => [:index, :pitch, :sendreminders, :updateindicators, :expirecaches, :resetcounters, :healthupdate, :colorize, :reprocess_photos]
  
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
 
  def first
    
  end
  
  def cms
    
  end
  
  def pitch
  end
  
  def invitation_accepted
    flash[:notice] = nil
  end
  
  def oid_login
    if params["email"].nil?
      flash[:error] = t("errors.invalid_credentials")
      render "index"
    else
      user, domain = params["email"].split("@")
      oiprov = OpenidProvider.where(:email_domain => domain).first
      if oiprov.nil?
        flash[:error] = t("no_oid_url", :default => "No corporate login for the given email")
        render "index"
      else
        oi = oiprov.openid_url
        url = oi.gsub('{user}', user)
        redirect_to "/auth/openid?openid_url=" + url
      end
    end
  end
  
  def ll(text)
    "#{DateTime.now.to_s} #{text}\n"
  end
  
  def sendreminders   
    hour = params[:hour] || 7 
    @text = ll "Initiating send reminders job!"
    User.current_user = -1
    kpis = User.at_hour(hour).includes(:indicators, {:indicators => :hoshin}, {:indicators => :company}).joins(:indicators).merge(Indicator.unscoped.due('5 day')).order("indicators.company_id, indicators.hoshin_id")
    tasks = User.at_hour(hour).includes(:tasks, {:tasks => :hoshin}, {:tasks => :company}).joins(:tasks).merge(Task.unscoped.due('5 day')).order("tasks.company_id, tasks.hoshin_id")
    comb = {}
    kpis.each {|user|
      com = comb[user.id] || {:user => user}
      com[:kpis] = user.indicators
      comb[user.id] = com
    }
    tasks.each {|user|
      com = comb[user.id] || {:user => user}
      com[:tasks] = user.tasks
      comb[user.id] = com
    }
    comb.values.each { |com|
      user = com[:user]
      @text +=  ll " ==== User: #{user.email_address}" 
      UserCompanyMailer.reminder(user, com[:kpis], com[:tasks]).deliver
    }
    @text += ll "End send reminders job!"
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def reprocess_photos
    User.unscoped.where("image_updated_at < now()- interval '2 hour'").each do |user|
      user.image.reprocess!
    end
  end
  
  def updateindicators
    self.current_user = User.administrator.first
    User.current_user = self.current_user
    @text = ll " Initiating updateindicators job!"
    ihs = IndicatorHistory.joins(:indicator).includes({:indicator => :responsible}, {:indicator => :hoshin})
      .where("day = #{User::TODAY_SQL}  and (
          indicator_histories.goal != indicators.goal
          or indicators.goal is null and indicator_histories.goal is not null 
          or indicator_histories.value != indicators.value
          or indicators.value is null and indicator_histories.value is not null 
          or last_update != day
          or last_update is null
          )").references(:indicator)
    ihs.each { |ih| 
      ind = ih.indicator
      line = ind.id.to_s + " " + (ind.name.nil? ? 'N/A' : ind.name)   + ": "
      if (!ih.goal.nil? && (ind.goal.nil? || ind.goal != ih.goal))
        line += "goal #{ind.goal} => #{ih.goal}"
        ind.goal = ih.goal
      end
      updated = false
      if (!ih.value.nil? && (ind.value.nil? || ind.value != ih.value))
        line += " value #{ind.value} => #{ih.value} last_update #{ind.last_update} => #{ih.day}"
        ind.value = ih.value
        updated = true
      end
      if (updated && (ind.last_update.nil? || ind.last_update < ih.day))
        line += " last_update #{ind.last_update} => #{ih.day}"
        ind.last_update = ih.day
      end
      @text += ll line
      ind.save!({:validate => false})
    }
    @text += ll "End update indicators job!"
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def expirecaches
    @text = ll "Initiating expirecaches job!"
    if Rails.configuration.action_controller.perform_caching
      kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(0))
      kpis.each { |indicator| 
        @text +=  ll " KPI: #{indicator.name}"
        #expire_swept_caches_for(indicator)
        #expire_swept_caches_for(indicator.area)
      }
      tasks = Task.unscoped.due_today.merge(User.at_hour(0))
      tasks.each { |task| 
        @text +=  ll "Task: #{task.name}"
        #expire_swept_caches_for(task)
        #expire_swept_caches_for(task.area)
      }
    end
    @text += ll "End expirecaches job!"
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
  
  def healthupdate
    @text = ll "Initiating healthupdate job!"    
    Hoshin.unscoped.all.each{|hoshin|
      hoshin.all_user_companies = nil
      uc_ids = UserCompany.unscoped.select(:user_id).where(:company_id => hoshin.company_id)
      users = User.unscoped.where(:id => uc_ids)
      if (users.length > 0)
        User.current_user = User.unscoped.where(:id => uc_ids).first
        User.current_id = User.current_user.id
        acting_user = User.current_user
      else
        User.current_user = nil
        User.current_id = nil
        acting_user = nil
        @text += ll "Hoshin with no users! #{hoshin.id} -- #{hoshin.name}"
        next
      end
      @text += ll "Updating hoshin #{hoshin.id} -- #{hoshin.name}"
      begin
        hoshin.health_update!
      rescue => e 
        @text += ll "Error!"  + e.inspect + e.backtrace.to_yaml + acting_user.to_yaml
      end
    }
    @text += ll "End healthupdate job!"
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
    msg = t("errors." + params[:message], :default => t("errors.unknown")) 
    unless params[:error_reason].blank? 
      msg += " " + t("errors.provider_said", :default => "The message from your authentication provider was: ") + " " + params[:error_reason]
    end
    flash[:error] = msg
    
    render 'index'
  end

end
