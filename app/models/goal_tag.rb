class GoalTag < Tag
  belongs_to :goal, :inverse_of => :goal_tags

  before_save :add_defaults

  def add_defaults
    self.hoshin_id = self.goal.hoshin_id if self.goal
  end
end
