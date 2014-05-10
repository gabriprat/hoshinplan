module ModelBase   
  
  def all_user_companies=(companies)
    RequestStore.store[:all_user_companies] = companies
  end

  def all_user_companies
    RequestStore.store[:all_user_companies]
  end  
  
  def admin_user_companies=(companies)
    RequestStore.store[:admin_user_companies] = companies
  end

  def admin_user_companies
    RequestStore.store[:admin_user_companies]
  end  
  
  def same_company(cid=nil)
    user = acting_user ? acting_user : User.current_user
    return true if user.administrator?
    if respond_to?("creator_id") && (user.id == creator_id)
      return true
    end
    if (self.all_user_companies.nil? && !user.nil?)
      self.all_user_companies = user.all_companies.*.id
    end
    if self.is_a?(Company)
      cid = self.id
    else
      cid = company_id ? company_id : Company.current_id if cid.nil?
    end
    ret = self.all_user_companies.include? cid
    ret
  end
  
  def hoshin_creator
    user = acting_user ? acting_user : User.find(User.current_id)
    return self.respond_to?("hoshin") && self.hoshin.creator_id == user.id
  end
  
  def same_creator
    user = acting_user ? acting_user : User.find(User.current_id)
    return self.respond_to?("creator") && self.creator_id == user.id
  end
  
  def same_company_admin(cid=nil)
    user = acting_user ? acting_user : User.find(User.current_id)
    return true if user.administrator?
    if respond_to?("creator_id") && (user.id == creator_id)
      return true
    end
    if self.is_a?(Company)
      cid = self.id
    else
      cid = company_id ? company_id : Company.current_id if cid.nil?
    end
    if (self.admin_user_companies.nil? && !user.nil?)
      self.admin_user_companies = user.user_companies.unscoped.where(:state => :admin, :user_id => user.id).*.company_id
    end
    self.admin_user_companies.include? cid
  end
end