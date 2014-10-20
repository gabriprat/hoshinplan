class IndicatorHistoriesSweeper < ActionController::Caching::Sweeper
  
  observe IndicatorHistory

  def after_create(ih)
    if Rails.configuration.action_controller.perform_caching
      #expire_swept_caches_for(ih.indicator.area)
    end
  end

  def after_update(ih)
    if Rails.configuration.action_controller.perform_caching
      #expire_swept_caches_for(ih.indicator.area)
      #expire_swept_caches_for(ih.indicator)
    end
  end

  def after_destroy(ih)
    if Rails.configuration.action_controller.perform_caching
      #expire_swept_caches_for(ih.indicator)
      #expire_swept_caches_for(ih.indicator.area)
    end
  end
end