class ObjectivesSweeper < ActionController::Caching::Sweeper
  
  observe Objective

  def after_create(objective)
    expire_swept_caches_for(objective.area.hoshin)
  end

  def after_update(objective)
    expire_swept_caches_for(objective)
  end

  def after_destroy(objective)
    expire_swept_caches_for(objective)
    expire_swept_caches_for(objective.area.hoshin)
  end
end