class Area < ApplicationRecord

  acts_as_paranoid

  include ModelBase

  hobo_model # Don't put anything above this
  
  include ColorHelper
  
  fields do
    name        :string, :null => false
    description HoboFields::Types::TextilePlusString
    color       Color
    timestamps
    deleted_at    :datetime
  end
  index [:deleted_at]
  
  amoeba do
    enable
    include_association :objectives
  end
    
  validates_presence_of :name

  attr_accessible :name, :description, :hoshin, :hoshin_id, :company, :company_id, :creator, :creator_id, :color
  never_show :position
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  has_many :objectives,  -> { order :obj_pos }, :dependent => :destroy, :inverse_of => :area
  has_many :indicators, -> { order :ind_pos }, :inverse_of => :area, :accessible => true
  has_many :child_indicators, -> { order :hoshin_id, :area_id, :ind_pos }, :inverse_of => :parent_area, :accessible => true, :class_name => 'Indicator', :foreign_key => :parent_area_id
  
  has_many :tasks, -> { 
      visible
        .except(:order)
        .reorder('CASE WHEN (status in (\'backlog\', \'active\')) THEN 0 ELSE 1 END, tsk_pos')},
       :inverse_of => :area, 
       :accessible => true
  has_many :child_tasks, -> { 
      visible
        .except(:order)
        .reorder('CASE WHEN (status in (\'backlog\', \'active\')) THEN 0 ELSE 1 END, tsk_pos')},
      :inverse_of => :parent_area, :accessible => true, :class_name => 'Task', :foreign_key => :parent_area_id
  
  has_many :log, :class_name => "AreaLog", :inverse_of => :area
  has_many :area_comments, :inverse_of => :area

  belongs_to :hoshin, :inverse_of => :areas, :counter_cache => true, :null => false, :touch => true
  belongs_to :company, :inverse_of => :areas, :null => false
  
  acts_as_list :scope => :hoshin
  
  validate :validate_company
  
  default_scope lambda { 
    where(:company_id => UserCompany.select(:company_id)
      .where('user_id=?',  
        User.current_id) ) }
        
  before_create do |area|
    area.company = area.hoshin.company
  end
  
  before_save do |area|
    area.color = area.defaultColor if area.color.blank?
  end
  
  after_create do |obj|
    user = User.current_user
    user.tutorial_step << :area
    #FIXME: Trying to avoid health not to appear on complete hoshinplans without goals 
    user.tutorial_step << :goal
    user.save!
  end
  
  after_update do |area|
    if area.hoshin_id_changed?
      Objective.where(:area_id => id).update_all({:hoshin_id => hoshin_id})
      Indicator.where(:area_id => id).update_all({:hoshin_id => hoshin_id})
      Task.where(:area_id => id).update_all({:hoshin_id => hoshin_id})
    end
  end
  
  def defaultColor
    str = "area+" + (name.nil? ? rand(1000000000).to_s(16) : name)
    res = hexFromString(str, 0.95 - (position.nil? ? 1 : position)/30.0)  
    return res
  end
  
  def parent_hoshin
    ret = hoshin.parent_id
    ret.nil? ? 0 : ret
  end

  def parent_objectives
    result = Objective.includes(:area).where(hoshin_id: parent_hoshin)
  end
  
  # --- Permissions --- #
  def validate_company
    errors.add(:company, "You don't have permissions on this company") unless same_company
  end
  
  def create_permitted?
    acting_user.administrator? || same_company_editor
  end

  def update_permitted?
    acting_user.administrator? || same_company_editor
  end

  def destroy_permitted?
    acting_user.administrator? || same_creator || hoshin_creator || same_company_admin
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end
