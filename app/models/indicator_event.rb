class IndicatorEvent < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  include ModelBase

  fields do
    day   :date, null: false
    name  :string, name: true, null: false
    timestamps
  end
  index [:indicator_id, :day]
  
  attr_accessible :name, :indicator_id, :day, :creator_id
  
  belongs_to :creator, :class_name => "User", :creator => true
  
  belongs_to :company, :null => false

  belongs_to :indicator, :inverse_of => :indicator_histories, :counter_cache => false, :null => false    
  
  before_create do |ie|
    ie.company = ie.indicator.company
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || same_company_editor
  end

  def update_permitted?
    acting_user.administrator? || same_company_editor
  end

  def destroy_permitted?
    acting_user.administrator? || same_company_admin || same_creator || hoshin_creator
  end

  def view_permitted?(field=nil)
    acting_user.administrator? || same_company
  end

end
