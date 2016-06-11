module ModelBase
  extend ActiveSupport::Concern
  
  included do
      after_destroy do log_operation(true) end
      after_save :log_operation
      after_save :notify
  end
    
  def log_operation(destroyed=false)
    return unless self.respond_to?(:deleted_at) && self.respond_to?(:name)
    changed = self.changes & self.class.accessible_attributes
    return unless self.id_changed? || changed.present? || destroyed
    operation = :create if self.id_changed?
    operation ||= :delete if destroyed
    operation ||= :update
    title = self.name
    body = changed.to_json unless self.id_changed? || destroyed
    l = Object::const_get(self.class.name + 'Log').new(title: title, body: body)
    l.operation = operation
    l.company_id = self.try.company_id
    l.hoshin_id ||= self.try.hoshin_id
    self.log << l
    l.save!
  end
  
  def notify
    return unless self.respond_to?(:deleted_at) && self.respond_to?(:name) && self.respond_to?(:description)
    mentions = Differ.diff(description || '', description_was || '').new_mentions
    mentions.each do |user, message|
      UserCompanyMailer.mention(User.current_user, user, self, message).deliver_later
    end
  end
  
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
  
  def rs_key(prefix, cid)
    user = acting_user ? acting_user : User.current_user
    prefix.to_s + user._?.id.to_s + "-" + cid.to_s
  end
  
  def same_company(cid=nil)
    user = acting_user ? acting_user : User.current_user
    return false if user.guest?
    ret = RequestStore.store[rs_key :sc, cid]
    if ret.nil?
      ret = _same_company(cid)
      RequestStore.store[rs_key :sc, cid] = ret
    end
    ret
  end
  
  def _same_company(cid=nil)
    user = acting_user ? acting_user : User.current_user
    return true if user._?.administrator?
     
    if respond_to?("creator_id") && (user._?.id == creator_id)
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
    ret = self.all_user_companies._?.include? cid
    ret
  end

  def subscription_active
    cc = Company.current_company
    cu = User.current_user
    cc.unlimited || cc.subscriptions_count > 0 || Date.today < cu.trial_ends_at
  end
  
  def hoshin_creator
    user = acting_user ? acting_user : User.find(User.current_id)
    return false if user.id == 557 && !user.administrator?
    return self.respond_to?("hoshin") && self.hoshin && self.hoshin.creator_id == user.id
  end
  
  def same_creator
    user = acting_user ? acting_user : User.find(User.current_id)
    return false if user.id == 557 && !user.administrator?
    return self.respond_to?("creator") && self.creator_id == user.id
  end
  
  
  def same_company_admin(cid=nil)
    user = acting_user ? acting_user : User.current_user
    return false if user.id == 557 && !user.administrator?
    return true if user.administrator?
    if respond_to?("creator_id") && (user.id == creator_id)
      return true
    end
    if self.is_a?(Company)
      cid ||= self.id
    else
      cid ||= self.company_id.present? ? self.company_id : Company.current_id if self.respond_to?(:company_id)
    end
    if (self.admin_user_companies.nil? && !user.nil?)
      self.admin_user_companies = user.user_companies.unscoped.where(:state => :admin, :user_id => user.id).*.company_id
    end
    self.admin_user_companies.include? cid
  end
end