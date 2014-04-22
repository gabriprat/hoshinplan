class Task < ActiveRecord::Base

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name              :string
    description       HoboFields::Types::TextileString
    deadline          :date
    original_deadline :date
    show_on_parent    :boolean
    reminder          :boolean, :default => true
    timestamps
  end
  attr_accessible :name, :objective, :objective_id, :description, :responsible, :responsible_id, :reminder,
    :deadline, :original_deadline, :area, :area_id, :show_on_parent, :company, :company_id, :creator_id, :hoshin, :hoshin_id

  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :company
  
  
  belongs_to :objective, :inverse_of => :tasks, :counter_cache => false
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false
  belongs_to :hoshin, :inverse_of => :indicators, :counter_cache => false
  belongs_to :responsible, :class_name => "User", :inverse_of => :tasks
  
  acts_as_list :scope => :area, :column => "tsk_pos"
  
  set_default_order [:status, :tsk_pos]
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id)) }
  
  scope :due, lambda { |*interval|
    joins(:responsible)
    .where("reminder = true 
      and deadline between #{User::TODAY_SQL} - interval ?
      and #{User::TODAY_SQL} and status = ?", interval, :active)
  }
  
  scope :overdue, lambda {
    includes(:responsible)
    .where("deadline < #{User::TODAY_SQL} and status = ?", :active)
  }
  
  scope :due_today, -> { due('0 hour') }
 
  before_create do |task|
    task.company = task.objective.company
    task.hoshin = task.objective.hoshin
  end
  
  after_save "hoshin.health_update!"
  after_destroy "hoshin.health_update!"

  after_save :update_counter_cache
  after_destroy :update_counter_cache

  def update_counter_cache
    self.objective.tasks_count = Task.where(:status => :active, :objective_id => self.objective_id).count(:id)
    self.objective.save!
    self.area.tasks_count = Task.where(:status => :active, :area_id => self.area_id).count(:id)
    self.area.save!
    self.hoshin.tasks_count = Task.where(:status => :active, :hoshin_id => self.hoshin_id).count(:id)
    self.hoshin.save!
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :task
    user.save!
  end

  lifecycle :state_field => :status do
    state :active, :default => true
    state :completed, :discarded, :deleted
    
    transition :activate, {nil => :active}, :available_to => "User" 
    
    transition :complete, {:active => :completed}, :available_to => "User" 
    
    transition :discard, {:active => :discarded}, :available_to => "User" 
    
    transition :reactivate, {:completed => :active}, :available_to => "User" 
    transition :reactivate, {:discarded => :active}, :available_to => "User" 
    
    transition :delete, {:completed => :deleted}, :available_to => "User" 
    transition :delete, {:discarded => :deleted}, :available_to => "User" 
      
  end
  
  before_save do |task|
    if task.original_deadline.nil? && !task.deadline.nil?
      task.original_deadline = task.deadline
    end
  end
  
  def position
    tsk_pos
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
  
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    acting_user.administrator? || same_company
  end

  def update_permitted?
    acting_user.administrator? || same_company
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end

class ChildTask < Task
end
