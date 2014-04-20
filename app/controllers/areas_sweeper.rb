class AreasSweeper < ActionController::Caching::Sweeper
  
  observe Area

  def after_create(area)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(area)
    end
  end

  def after_update(area)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(area)
    end
  end

  def after_destroy(area)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(area)
    end
  end
end