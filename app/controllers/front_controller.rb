class FrontController < ApplicationController

  hobo_controller 
  
  # Require the user to be logged in for every other action on this controller
  # except :index. 
  skip_before_filter :my_login_required, :only => [:index, :sendreminders]
  
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
    puts "Initiating send remainders job!"
    kpis = Indicator.unscoped.due('5 day').joins(:responsible).merge(User.at_hour(7))
    tasks = Task.unscoped.due('5 day').joins(:responsible).merge(User.at_hour(7))
    (kpis | tasks).each { |user|
      UserCompanyMailer.reminder(user, "You have KPIs or tasks to update!", 
      "You can access all the KPIs and tasks you have to update at your dashboard:").deliver
    }
    render "empty"
  end
  
  def updateindicators
    puts "Initiating updateindicators job!"
    ihs = IndicatorHistory.joins(:indicator => :responsible)
      .where("day = #{User::TODAY_SQL} and last_update < day")
    ihs.each { |ih| 
      ind = ih.indicator
      ind.goal = ih.goal
      if (ind.value != ih.value)
        ind.value = ih.value
        ind.last_update
      end
      ind.save!
    }
    render "empty"
  end
  
  def expirecaches
    puts "Initiating expirecaches job!"
    if Rails.configuration.action_controller.perform_caching
      kpis = Indicator.unscoped.due('0 day').merge(User.at_hour(0))
      kpis.each { |indicator| 
        expire_swept_caches_for(indicator)
        #expire_swept_caches_for(indicator.area.hoshin)
      }
      tasks = Task.unscoped.due_today.merge(User.at_hour(0))
      tasks.each { |task| 
        expire_swept_caches_for(task)
        #expire_swept_caches_for(indicator.area.hoshin)
      }
    end
    render "empty"
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
