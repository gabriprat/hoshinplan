class TaskLog < Log
  belongs_to :task, :inverse_of => :log
end
