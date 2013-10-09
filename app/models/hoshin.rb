class Hoshin < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    areas_count :integer, :default => 0, :null => false
    timestamps
  end
  attr_accessible :name, :id, :parent, :parent_id, :company, :company_id
  attr_accessible :areas, :children, :children_ids

  belongs_to :company, :inverse_of => :hoshins, :counter_cache => true
  belongs_to :parent, :class_name => "Hoshin"
  has_many :children, :class_name => "Hoshin", :foreign_key => "parent_id", :dependent => :destroy
  
  has_many :areas, :dependent => :destroy, :inverse_of => :hoshin, :order => :position
  has_many :objectives, :through => :areas, :accessible => true
  
  children :areas
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }

  # --- Permissions --- #
  
  def same_company
    user = User.find(User.current_id)
    user.user_companies.where(:company_id => company_id)
  end
  
  def parent_same_company
    parent_id.nil? || Hoshin.find(parent_id).company_id == company_id
  end
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
    errors.add(:parent, "Parent hoshin must be from the same company") unless parent_same_company
  end

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    same_company
  end

end
