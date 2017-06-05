module ModelBase
  extend ActiveSupport::Concern

  included do
    after_destroy do
      log_operation(true)
    end
    after_save :log_operation
    after_save :notify_mentions
    after_save :notify_responsible
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

  def taglist
    Hoshin.current_hoshin ? Hoshin.current_hoshin.all_tags_hashes[self.typed_id] : nil
  end

  def has_tags
    Hoshin.current_hoshin ? Hoshin.current_hoshin.all_tags_hashes[self.typed_id] : nil
  end

  def notify_mentions
    return unless self.respond_to?(:deleted_at) && self.respond_to?(:name) && self.respond_to?(:description)
    mentions = Differ.diff(description || '', description_was || '').new_mentions
    mentions.each do |user, message|
      UserCompanyMailer.mention(User.current_user, user, self, message).deliver_later
    end
  end

  def notify_responsible
    user = acting_user ? acting_user : User.current_user
    if self.respond_to?(:responsible) &&
        self.responsible_id != self.responsible_id_was &&
        user &&
        user.respond_to?(:notify_on_assign) &&
        user.notify_on_assign
      UserCompanyMailer.assign_responsible(user, self).deliver_later
    end
  end

  def rs_key(prefix, cid)
    user = acting_user ? acting_user : User.current_user
    prefix.to_s + user._?.id.to_s + "-" + cid.to_s
  end

  def same_company_editor(cid=nil)
    same_company(cid, :editor)
  end

  def same_company_reader(cid=nil)
    same_company(cid, :reader)
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
    same_company(cid, :admin)
  end

  def same_company(cid=nil, *roles)
    user = acting_user ? acting_user : User.current_user
    return false if user.guest?

    return true if user._?.administrator?

    if user == self
      return true
    end

    if self.instance_of?(Company)
      cid = self.id if cid.nil?
    else
      cid = self.company_id if cid.nil? && self.respond_to?(:company_id)
    end

    ret = RequestStore.store[rs_key :sc, cid]
    if ret.nil?
      ret = _user_companies_company(user, cid)
      RequestStore.store[rs_key :sc, cid] = ret
    end

    if respond_to?("creator_id") && user._?.id == creator_id && ret._?.include?(:editor)
      return true
    end

    if roles.empty?
      ret
    else
      ret._?.any? {|uc| roles.all? {|role| uc.roles.include? role}}
    end
  end

  def _user_companies_company(user, cid=nil)
    ret = user.all_active_user_companies_and_hoshins._?.select {|uc| uc.company.id == cid}
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

end