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
  
  def same_company_admin(cid=nil)
    user = acting_user ? acting_user : User.find(User.current_id)
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