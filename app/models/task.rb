class Task < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name              :string
    description       :text
    responsible       :string
    deadline          :date
    original_deadline :date
    show_on_parent    :boolean
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :description, :responsible, 
    :deadline, :original_deadline, :area, :area_id, :show_on_parent

  belongs_to :objective, :inverse_of => :tasks, :counter_cache => true
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  
  acts_as_list :scope => :area
  
  set_default_order :position

  lifecycle :state_field => :status do
    state :active, :default => true
    state :completed, :discarded
    
    transition :activate, {nil => :active}, :available_to => "User" 
    
    transition :complete, {:active => :completed}, :available_to => "User" 
    
    transition :discard, {:active => :discarded}, :available_to => "User" 
    
    transition :reactivate, {:completed => :active}, :available_to => "User" 
    transition :reactivate, {:discarded => :active}, :available_to => "User" 
      
  end
  
  def status 
    if deadline?
      deadline < Date.today ? :overdue : :current
    end
  end
  
  # --- Permissions --- #

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
    true
  end

end
