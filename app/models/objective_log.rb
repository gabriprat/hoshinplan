class ObjectiveLog < Log
  belongs_to :objective, :inverse_of => :log
end
