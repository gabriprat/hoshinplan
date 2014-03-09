class IndicatorsSweeper < ActionController::Caching::Sweeper
  
  observe Indicator

  def after_create(indicator)
    expire_swept_caches_for(indicator.area.hoshin)
  end

  def after_update(indicator)
    expire_swept_caches_for(indicator)
  end

  def after_destroy(indicator)
    expire_swept_caches_for(indicator)
    expire_swept_caches_for(indicator.area.hoshin)
  end
end