module TaskDotHelper 
  
	def size(task)
		task.impact_or_rand/2+10
	end
	def top(task)
		'calc(' + ((100-task.effort_or_rand) * 0.5).to_s + '% - ' + (size(task)/2).to_s + 'px + 30px)'
	end
	def left(task)
		'calc(' + (task.confidence_or_rand * 0.75).to_s + '% - ' + (size(task)/2).to_s + 'px + 30px)'
	end
  
end
