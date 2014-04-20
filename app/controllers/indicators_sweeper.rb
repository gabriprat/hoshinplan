class IndicatorsSweeper < ActionController::Caching::Sweeper
  
  observe Indicator

  def after_create(indicator)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(indicator.area)
    end
  end

  def after_update(indicator)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(indicator)
      expire_swept_caches_for(indicator.area)
    end
  end

  def after_destroy(indicator)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(indicator)
      expire_swept_caches_for(indicator.area)
    end
  end
end