module ModelBase 
  def same_company
    user = acting_user ? acting_user : User.find(User.current_id)
    cid = company_id ? company_id : Company.current_id
    ret = user.all_companies.where(:id => cid).exists?
    ret
  end
  
  def same_company_admin
    user = acting_user ? acting_user : User.find(User.current_id)
    user.user_companies.where(:company_id => company_id, :state => :admin).exists?
  end
end