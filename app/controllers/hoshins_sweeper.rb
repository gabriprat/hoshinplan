class HoshinsSweeper < ActionController::Caching::Sweeper
  
  observe Hoshin

  def after_create(hoshin)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(hoshin)
    end
  end

  def after_update(hoshin)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(hoshin)
    end
  end

  def after_destroy(hoshin)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(hoshin)
    end
  end
end