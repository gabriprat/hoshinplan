class TasksSweeper < ActionController::Caching::Sweeper
  
  include Hobo::Controller::Cache
  
  observe Task

  def after_create(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task.area)
    end
  end

  def after_update(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task)
      expire_swept_caches_for(task.area)
      expire_swept_caches_for(task.objective.parent.area) if task.objective.parent  
    end
  end

  def after_destroy(task)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(task)
      expire_swept_caches_for(task.area)
      expire_swept_caches_for(task.hoshin.parent.areas) if task.hoshin.parent
    end
  end
end