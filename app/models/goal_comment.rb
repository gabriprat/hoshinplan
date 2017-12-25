class GoalComment < GenericComment
  belongs_to :goal, :inverse_of => :goal_comments
  index [:goal_id, :created_at]
end