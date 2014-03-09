class TasksSweeper < ActionController::Caching::Sweeper
  
  observe Task

  def after_create(task)
    Rails.logger.debug "============== CACHE SWEEP" + task.area.hoshin_id.to_s
    expire_swept_caches_for(task.area.hoshin)
  end

  def after_update(task)
    expire_swept_caches_for(task)
  end

  def after_destroy(task)
    expire_swept_caches_for(task)
    expire_swept_caches_for(task.area.hoshin)
  end
end