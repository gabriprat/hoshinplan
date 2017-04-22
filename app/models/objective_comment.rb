class ObjectiveComment < GenericComment
  attr_accessible :body, :creator_id, :objective_id
  belongs_to :objective, :inverse_of => :objective_comments
  index [:objective_id, :created_at]
end