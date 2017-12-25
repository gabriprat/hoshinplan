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
