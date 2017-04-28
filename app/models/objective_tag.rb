class ObjectiveTag < Tag
  belongs_to :objective, :inverse_of => :objective_tags

  after_initialize :add_defaults

  def add_defaults
    self.hoshin_id = self.objective.hoshin_id if self.objective
  end
end
