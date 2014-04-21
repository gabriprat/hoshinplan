class FrontController < ApplicationController

  hobo_controller 
  
  # Require the user to be logged in for every other action on this controller
  # except :index. 
  skip_before_filter :my_login_required, :only => [:index, :sendreminders, :updateindicators, :expirecaches]
  
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
  
  def sendreminders
    @text = DateTime.now.to_s + " Initiating send reminders job!\n"
    kpis = User.at_hour(7).joins(:indicators).merge(Indicator.unscoped.due('5 day'))
    tasks = User.at_hour(7).joins(:tasks).merge(Task.unscoped.due('5 day'))
    (kpis | tasks).each { |user|
      @text +=  DateTime.now.to_s + " User: " + user.email_address + "\n"
      UserCompanyMailer.reminder(user, "You have KPIs or tasks to update!", 
      "You can access all the KPIs and tasks you have to update at your dashboard:").deliver
    }
    @text += DateTime.now.to_s + " End send reminders job!"
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def updateindicators
    @text = DateTime.now.to_s + " Initiating updateindicators job!\n"
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
      @text += DateTime.now.to_s + " " + ind.name + ": "
      if (ind.goal.nil? || ind.goal != ih.goal)
        @text += "goal #{ind.goal} => #{ih.goal}"
        ind.goal = ih.goal
      end
      if (ind.value.nil? || ind.value != ih.value)
        @text += " value #{ind.value} => #{ih.value} last_update #{ind.last_update} => #{ih.day}"
        ind.value = ih.value
      end
      if (ind.last_update.nil? || ind.last_update < ih.day) 
        @text += " last_update #{ind.last_update} => #{ih.day}"
        ind.last_update = ih.day
      end
      @text += "\n"
      ind.save!
    }
    @text += DateTime.now.to_s + " End update indicators job!"
    render :text => @text, :content_type => Mime::TEXT
  end
  
  def expirecaches
    @text = DateTime.now.to_s + " Initiating expirecaches job!\n"
    if Rails.configuration.action_controller.perform_caching
      kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(0))
      kpis.each { |indicator| 
        @text +=  DateTime.now.to_s + " KPI: " + indicator.name + "\n"
        expire_swept_caches_for(indicator)
        expire_swept_caches_for(indicator.area)
      }
      tasks = Task.unscoped.due_today.merge(User.at_hour(0))
      tasks.each { |task| 
        @text +=  DateTime.now.to_s + " Task: " + task.name + "\n"
        expire_swept_caches_for(task)
        expire_swept_caches_for(indicator.area)
      }
    end
    @text += DateTime.now.to_s + " End expirecaches job!"
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
