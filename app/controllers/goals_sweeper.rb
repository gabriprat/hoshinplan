class GoalsSweeper < ActionController::Caching::Sweeper
  
  include Hobo::Controller::Cache
  
  observe Goal

  def after_create(goal)
    if Rails.configuration.action_controller.perform_caching
      #expire_swept_caches_for(goal.hoshin)
    end
  end

  def after_update(goal)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(goal)
    end
  end

  def after_destroy(goal)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(goal)
      #expire_swept_caches_for(goal.hoshin)
    end
  end
end