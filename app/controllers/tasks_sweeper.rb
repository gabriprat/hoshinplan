class TasksSweeper < ActionController::Caching::Sweeper
  
  observe Task

  def after_create(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task.area.hoshin)
    end
  end

  def after_update(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task)
    end
  end

  def after_destroy(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task)
      expire_swept_caches_for(task.area.hoshin)
    end
  end
end