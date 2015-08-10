class Task < ActiveRecord::Base

  acts_as_paranoid

  include ModelBase
  
  hobo_model # Don't put anything above this

  fields do
    name              :string, :null => false
    description       HoboFields::Types::TextileString
    deadline          :date
    original_deadline :date
    show_on_parent    :boolean
    reminder          :boolean, :default => true
    lane_pos          :integer, :default => 0, :null => false
    feeling           EnumFeeling, :default => :smile, :null => false
    confidence        :percentage
    impact            :percentage
    effort            :percentage
    timestamps
    deleted_at    :datetime
  end
  index [:deleted_at]
  index [:deadline, :status]
  index [:area_id, :status]
  index [:hoshin_id, :status]
    
  validates_presence_of :objective, :name
  
  
  attr_accessible :name, :objective, :objective_id, :description, :responsible, :responsible_id, :reminder, :status,
    :deadline, :original_deadline, :area, :area_id, :show_on_parent, :company, :company_id, :creator_id, :hoshin, 
    :hoshin_id, :feeling, :confidence, :impact, :effort

  has_many :log, :class_name => "TaskLog", :inverse_of => :task
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :company, :null => false
  
  
  belongs_to :objective, :inverse_of => :tasks, :counter_cache => false, :null => false
  belongs_to :area, :inverse_of => :tasks, :counter_cache => false, :null => false
  belongs_to :hoshin, :inverse_of => :indicators, :counter_cache => false, :null => false, :touch => true
  belongs_to :responsible, :class_name => "User", :inverse_of => :tasks
  
  belongs_to :parent_area, :inverse_of => :child_tasks, :class_name => 'Area'
  belongs_to :parent_objective, :inverse_of => :child_tasks, :class_name => 'Objective'
  
  
  acts_as_list :scope => :area, :column => "tsk_pos"
  
  set_default_order 'CASE WHEN (status in (\'backlog\', \'active\')) THEN 0 ELSE 1 END, tsk_pos'
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id)).reorder('') unless User.current_user == -1 }
  
  scope :lane, lambda {|*status|
    visible.where(:status => status).order(:status)
  }
  
  scope :due, lambda { |*interval|
    joins(:responsible)
    .where("reminder = true 
      and deadline between #{User::TODAY_SQL} - interval ?
      and #{User::TODAY_SQL} and status in (?)", interval, [:active, :backlog])
  }
  
  scope :active_backlog, lambda {
    where(:status => [:active, :backlog]).reorder(:deadline)
  }
  
  scope :order_hoshin, lambda {
    order('CASE WHEN (status in (\'backlog\', \'active\')) THEN 0 ELSE 1 END, tsk_pos')
  }
  
  scope :overdue, lambda {
    includes([:area, :responsible])
    .where("deadline < #{User::TODAY_SQL}").merge(Task.active_backlog).references(:responsible)
  }
  
  scope :due_today, -> { due('0 hour') }
  
  scope :pending, lambda {
    where("deadline < #{User::TODAY_SQL}").merge(Task.active_backlog)
    .reorder('tasks.deadline').references(:responsible)
  }
  
  scope :visible, -> {
    where("status != 'deleted' and (status = 'active' or status = 'backlog' or coalesce(deadline, tasks.created_at)>current_date-110)")
  }
 
  before_create do |task|
    task.area = task.objective.area
    task.company = task.objective.company
    task.hoshin = task.objective.hoshin
  end

  after_destroy 'hoshin.touch'

  after_save :update_counter_cache
  after_destroy :update_counter_cache
  
  #after_update :update_lane_positions
  #after_destroy :decrement_lane_positions_on_lower_items
  before_create :add_to_lane_list_bottom
  
  def decrement_lane_positions_on_lower_items(position=nil)
    acts_as_list_class.unscoped.where(
      "status='#{status}' AND hoshin_id = #{hoshin_id} AND lane_pos > #{lane_pos}"
    ).update_all(
      "lane_pos = (lane_pos - 1)"
    )
  end
  
  def bottom_lane_item
    Task.unscoped.in_list.where("status='#{status}' AND hoshin_id = #{hoshin_id}").order("tasks.lane_pos DESC").first
  end
  
  def add_to_lane_list_bottom
    self.lane_pos = bottom_lane_item
    self.lane_pos ||= 0
  end
  
  def reorder_lanes
    ordering = params["#{model.name.underscore}_ordering"]
    if ordering
      ordering.each_with_index do |id, position|
        object = model.find(id)
        object.user_update_attributes!(current_user, object.position_column => position+1)
      end
      hobo_ajax_response || render(:nothing => true)
    else
      render :nothing => true
    end
  end
  
  def update_lane_positions
      old_position = lane_pos_was
      new_position = lane_pos

      return unless Task.unscoped.where("status = '#{status}' AND hoshin_id = #{hoshin_id} AND lane_pos = #{new_position}").count > 1
      shuffle_lane_positions_on_intermediate_items old_position, new_position, id
  end
  
  def shuffle_lane_positions_on_intermediate_items(old_position, new_position, avoid_id = nil)
    return if old_position == new_position
    avoid_id_condition = avoid_id ? " AND #{self.class.primary_key} != #{self.class.quote_value(avoid_id)}" : ''

    if old_position < new_position
      # Decrement position of intermediate items
      #
      # e.g., if moving an item from 2 to 5,
      # move [3, 4, 5] to [2, 3, 4]
      Task.unscoped.where(
        "status = '#{status}' AND hoshin_id = #{hoshin_id} AND lane_pos > #{old_position} AND lane_pos <= #{new_position}#{avoid_id_condition}"
      ).update_all(
        "lane_pos = (lane_pos - 1)"
      )
    else
      # Increment position of intermediate items
      #
      # e.g., if moving an item from 5 to 2,
      # move [2, 3, 4] to [3, 4, 5]
      Task.unscoped.where(
        "status = '#{status}' AND hoshin_id = #{hoshin_id} AND lane_pos >= #{new_position} AND lane_pos < #{old_position}#{avoid_id_condition}"
      ).update_all(
        "lane_pos = (lane_pos + 1)"
      )
    end
  end
  
  def update_counter_cache
    self.hoshin.tasks_count = Task.where(:status => [:active, :backlog], :hoshin_id => self.hoshin_id).count(:id)
    self.hoshin.save!
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :task
    user.save!
  end

  lifecycle :state_field => :status do
    state :backlog, :default => true
    state :active, :completed, :discarded, :deleted
    
    create :backlog,
      :params => [:company_id, :objective_id, :area_id],
      :become => :backlog    
      
    transition :activate, {nil => :active}, :available_to => "User" 
    
    transition :complete, {:active => :completed}, :available_to => "User" 
    
    transition :discard, {:active => :discarded}, :available_to => "User" 
    
    transition :start, {:backlog => :active}, :available_to => "User" 
    transition :reactivate, {:completed => :active}, :available_to => "User" 
    transition :reactivate, {:discarded => :active}, :available_to => "User" 
    
    transition :delete, {:backlog => :backlog}, :available_to => "User" do self.destroy! end
    transition :delete, {:completed => :completed}, :available_to => "User" do self.destroy! end
    transition :delete, {:discarded => :discarded}, :available_to => "User" do self.destroy! end
    
    transition :to_backlog, {Task::Lifecycle.states.keys => :backlog}, :available_to => "User" 
    transition :to_active, {Task::Lifecycle.states.keys => :active}, :available_to => "User" 
    transition :to_completed, {Task::Lifecycle.states.keys => :completed}, :available_to => "User" 
    transition :to_discarded, {Task::Lifecycle.states.keys => :discarded}, :available_to => "User" 
    transition :to_deleted, {Task::Lifecycle.states.keys => :deleted}, :available_to => "User" 
    
      
  end
  
  before_save do |task|    
    if task.original_deadline.nil? && !task.deadline.nil?
      task.original_deadline = task.deadline
    end
    if task.show_on_parent && task.objective.parent_id
      task.parent_area_id = task.objective.parent.area_id
      task.parent_objective_id = task.objective.parent_id
    else
      task.parent_area_id = nil
      task.parent_objective_id = nil
    end
  end
  
  def position
    tsk_pos
  end
  
  def deadline_status 
    ret = ""
    if self.deadline
      ret = (self.deadline < Date.today) && ['active', 'backlog'].include?(self.status) ? :overdue : :current
    end
    ret
  end
  
  def deviation
    if !deadline.nil? && !original_deadline.nil?
      (deadline - original_deadline).to_i
    else
      0
    end
  end
  
  def effort_or_rand
    effort || (id * 37 + 17) % 100
  end
  
  def confidence_or_rand
    confidence || (id * 29 + 19) % 100
  end
  
  def impact_or_rand
    impact || (id * 43 + 13) % 100
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
    acting_user.administrator? || same_creator || hoshin_creator || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end

class ChildTask < Task
end
