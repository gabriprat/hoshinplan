class TaskTag < Tag
  belongs_to :task, :inverse_of => :task_tags

  before_save :add_defaults

  def add_defaults
    self.hoshin_id = self.task.hoshin_id if self.task
  end
end
