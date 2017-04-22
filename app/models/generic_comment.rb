class GenericComment < ApplicationRecord
  include ModelBase

  hobo_model # Don't put anything above this

  fields do
    body  HoboFields::Types::TextilePlusString
    timestamps
  end
  attr_accessible :body, :creator_id

  default_scope { order('created_at DESC') }

  after_initialize :add_defaults
  after_save :notify
  after_create do |c|
    ::FayeCommentControllerHelper.new.run(c)
  end


  belongs_to :company, :null => false, :inverse_of => :company_comments
  belongs_to :creator, :class_name => "User", :creator => true

  def add_defaults
    self.company_id ||= Company.current_id if self.new_record?
    self.creator_id ||= User.current_id if self.new_record?
  end

  def notify
    mentions = Differ.diff(body || '', body_was || '').new_mentions
    mentions.each do |user, message|
      UserCompanyMailer.mention(User.current_user, user, self.owner, message).deliver_later
    end
  end

  def model
    self.type.to_s[/\A(\w+)Comment\Z/,1].constantize
  end

  def owner
    self.send model.name.underscore
  end

  def model_id
    self.send model.name.underscore + '_id'
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

class CompanyComment < GenericComment
  index [:company_id, :created_at]
end

class AreaComment < GenericComment
  belongs_to :area, :inverse_of => :area_comments
  index [:area_id, :created_at]
end

class HoshinComment < GenericComment
  belongs_to :hoshin, :inverse_of => :hoshin_comments
  index [:hoshin_id, :created_at]
end

class GoalComment < GenericComment
  belongs_to :goal, :inverse_of => :goal_comments
  index [:goal_id, :created_at]
end

class IndicatorComment < GenericComment
  belongs_to :indicator, :inverse_of => :indicator_comments
  index [:indicator_id, :created_at]
end

class TaskComment < GenericComment
  belongs_to :task, :inverse_of => :task_comments
  index [:task_id, :created_at]
end
