class Log < ApplicationRecord
  require 'differ'
  include ModelBase

  hobo_model # Don't put anything above this
  
  fields do
    title :string
    body  :text
    operation   HoboFields::Types::EnumString.for(:create, :update, :delete), :null => false
    timestamps
  end
  attr_accessible :title, :body, :creator_id
  
  set_default_order "created_at DESC"
  
  after_initialize :add_defaults
  
  belongs_to :company, :null => false
  belongs_to :creator, :class_name => "User", :creator => true
  
  def add_defaults		
    self.company_id ||= Company.current_id if self.new_record?
    self.creator_id ||= User.current_id if self.new_record?
  end
  
  def model
    self.type.to_s[/\A(\w+)Log\Z/,1].constantize
  end
  
  def model_id
    self.send model.name.underscore + '_id'
  end
  
  def changes
    if operation == :update
      JSON.parse(body).map {|attr,change|
        ret = {attribute: attr, old: (change[0] || '').to_s, new: (change[1].to_s || '').to_s}
        ret[:diff] = Differ.diff_by_word(ret[:new], ret[:old]).format_as(:html).html_safe
        ret
      }
    end
  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || same_company
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.administrator? || same_company
  end

end