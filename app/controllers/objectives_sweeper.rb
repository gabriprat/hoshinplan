class ObjectivesSweeper < ActionController::Caching::Sweeper
  
  observe Objective

  def after_create(objective)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(objective.area)
    end
  end

  def after_update(objective)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(objective)
      expire_swept_caches_for(objective.area)
    end
  end

  def after_destroy(objective)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(objective)
      expire_swept_caches_for(objective.area)
    end
  end
end