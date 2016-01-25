class IndicatorHistoriesSweeper < ActionController::Caching::Sweeper
  
  include Hobo::Controller::Cache
  
  observe IndicatorHistory

  def after_create(ih)
    if Rails.configuration.action_controller.perform_caching
      ind = Indicator.unscoped.find(ih.indicator_id)
      expire_swept_caches_for(ind.area) if ind && ind.area
    end
  end

  def after_update(ih)
    if Rails.configuration.action_controller.perform_caching
      ind = Indicator.unscoped.find(ih.indicator_id)
      expire_swept_caches_for(ind.area) if ind && ind.area
      expire_swept_caches_for(ind) if ind 
      expire_swept_caches_for(ind.objective.parent.area) if ind && ind.objective && ind.objective.parent  
    end
  end

  def after_destroy(ih)
    if Rails.configuration.action_controller.perform_caching
      ind = Indicator.unscoped.find(ih.indicator_id)
      expire_swept_caches_for(ind) if ind
      expire_swept_caches_for(ind.area) if ind && ind.area
      expire_swept_caches_for(ind.objective.parent.area) if ind && ind.objective && ind.objective.parent  
    end
  end
end