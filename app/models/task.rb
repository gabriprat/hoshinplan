class Task < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    description       :text
    deadline          :date
    original_deadline :date
    show_on_parent    :boolean
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :description, :responsible, :responsible_id, 
    :deadline, :original_deadline, :area, :area_id, :show_on_parent, :company, :company_id

  belongs_to :company, :inverse_of => :areas

  belongs_to :objective, :inverse_of => :tasks, :counter_cache => true
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :tasks
  
  acts_as_list :scope => :area
  
  set_default_order :position
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
  
  before_create do |task|
    task.company = task.objective.company
  end

  lifecycle :state_field => :status do
    state :active, :default => true
    state :completed, :discarded
    
    transition :activate, {nil => :active}, :available_to => "User" 
    
    transition :complete, {:active => :completed}, :available_to => "User" 
    
    transition :discard, {:active => :discarded}, :available_to => "User" 
    
    transition :reactivate, {:completed => :active}, :available_to => "User" 
    transition :reactivate, {:discarded => :active}, :available_to => "User" 
      
  end
  
  before_save do |task|
    if task.original_deadline.nil? && !task.deadline.nil?
      task.original_deadline = task.deadline
    end
  end
  
  def deadline_status 
    if deadline?
      deadline < Date.today ? :overdue : :current
    end
  end
  
  def deviation
    if !deadline.nil? && !original_deadline.nil?
      (deadline - original_deadline).to_i
    else
      0
    end
  end
  
  # --- Permissions --- #
  
  def same_company
    acting_user.user_companies.where(:company_id => self.company_id)
  end
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    true
  end

  def update_permitted?
    same_company
  end

  def destroy_permitted?
    same_company
  end

  def view_permitted?(field)
    true
  end

end

class ChildTask < Task
end
