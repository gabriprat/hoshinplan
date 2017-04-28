class GoalTag < Tag
  belongs_to :objective, :inverse_of => :goal_tags

  after_initialize :add_defaults

  def add_defaults
    self.hoshin_id = self.goal.hoshin_id if self.goal
  end
end
