class GoalLog < Log
  belongs_to :goal, :inverse_of => :log
end