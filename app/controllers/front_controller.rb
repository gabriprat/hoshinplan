class FrontController < ApplicationController

  hobo_controller 
  
  # Require the user to be logged in for every other action on this controller
  # except :index. 
  skip_before_filter :my_login_required, :only => [:index, :sendreminders, :updateindicators, :expirecaches, :resetcounters, :healthupdate]
  
  def index
    if !current_user.nil? && !current_user.guest? && current_user.user_companies.empty?
      redirect_to "/first"
    elsif !current_user.nil? && !current_user.guest?
       redirect_to current_user
    end
  end
 
  def first
    
  end
  
  def cms
    
  end
  
  def invitation_accepted
    flash[:notice] = nil
  end
  
  def oid_login
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
  
  def ll(text)
    "#{DateTime.now.to_s} #{text}\n"
  end
  
  def sendreminders
    @text = ll "Initiating send reminders job!"
    kpis = User.at_hour(7).joins(:indicators).merge(Indicator.unscoped.due('5 day'))
    tasks = User.at_hour(7).joins(:tasks).merge(Task.unscoped.due('5 day'))
    (kpis | tasks).each { |user|
      @text +=  ll " User: #{user.email_address}" 
      UserCompanyMailer.reminder(user, "You have KPIs or tasks to update!", 
      "You can access all the KPIs and tasks you have to update at your dashboard:").deliver
    }
    @text += ll "End send reminders job!"
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def updateindicators
    @text = ll " Initiating updateindicators job!"
    ihs = IndicatorHistory.joins(:indicator => :responsible)
      .where("day = #{User::TODAY_SQL} 
        and (
          indicator_histories.goal != indicators.goal
          or indicators.goal is null and indicator_histories.goal is not null 
          or indicator_histories.value != indicators.value
          or indicators.value is null and indicator_histories.value is not null 
          or last_update != day
          or last_update is null
          )")
    ihs.each { |ih| 
      ind = ih.indicator
      line += ind.name + ": "
      if (ind.goal.nil? || ind.goal != ih.goal)
        line += "goal #{ind.goal} => #{ih.goal}"
        ind.goal = ih.goal
      end
      if (ind.value.nil? || ind.value != ih.value)
        line += " value #{ind.value} => #{ih.value} last_update #{ind.last_update} => #{ih.day}"
        ind.value = ih.value
      end
      if (ind.last_update.nil? || ind.last_update < ih.day) 
        line += " last_update #{ind.last_update} => #{ih.day}"
        ind.last_update = ih.day
      end
      @text += ll line
      ind.save!
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
        expire_swept_caches_for(indicator)
        expire_swept_caches_for(indicator.area)
      }
      tasks = Task.unscoped.due_today.merge(User.at_hour(0))
      tasks.each { |task| 
        @text +=  ll "Task: #{task.name}"
        expire_swept_caches_for(task)
        expire_swept_caches_for(indicator.area)
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
      ret += ll "====  Done! #{res.ntuples} rows affected"
    end
    ret
  end
  
  def healthupdate
    @text = ll "Initiating healthupdate job!"
    Hoshin.all.each{|hoshin|
      @text = ll "Updating hoshin #{hoshin.id} -- #{hoshin.name}"
      hoshin.health_update!
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

end
