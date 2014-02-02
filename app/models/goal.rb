class Goal < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end
  attr_accessible :name, :hoshin, :hoshin_id
  
  belongs_to :hoshin, :inverse_of => :objectives
  belongs_to :company
  
  acts_as_list :scope => :hoshin
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
  
  before_create do |goal|
    h = Hoshin.unscoped.find(goal.hoshin_id)
    goal.company = h.company
  end
  

  # --- Permissions --- #
  
  def same_company
    user = User.find(User.current_id)
    user.user_companies.where(:company_id => company_id)
  end
  
  def same_company_admin
    user = User.find(User.current_id)
    user.user_companies.where(:company_id => company_id, :state => :admin)
  end
  

  def create_permitted?
    same_company
  end

  def update_permitted?
    same_company
  end

  def destroy_permitted?
    same_company_admin
  end

  def view_permitted?(field)
    same_company
  end

end
