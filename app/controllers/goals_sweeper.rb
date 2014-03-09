class GoalsSweeper < ActionController::Caching::Sweeper
  
  observe Goal

  def after_create(goal)
    expire_swept_caches_for(goal.hoshin)
  end

  def after_update(goal)
    expire_swept_caches_for(goal)
  end

  def after_destroy(goal)
    expire_swept_caches_for(goal)
    expire_swept_caches_for(goal.hoshin)
  end
end