class TaskComment < GenericComment
  belongs_to :task, :inverse_of => :task_comments
  index [:task_id, :created_at]
end
