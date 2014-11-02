class IndicatorHistoriesSweeper < ActionController::Caching::Sweeper
  
  include Hobo::Controller::Cache
  
  observe IndicatorHistory

  def after_create(ih)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(ih.indicator.area)
    end
  end

  def after_update(ih)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(ih.indicator.area)
      expire_swept_caches_for(ih.indicator)
      expire_swept_caches_for(ih.indicator.objective.parent.area) if ih.indicator && ih.indicator.objective && ih.indicator.objective.parent  
      
    end
  end

  def after_destroy(ih)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(ih.indicator)
      expire_swept_caches_for(ih.indicator.area)
      expire_swept_caches_for(ih.indicator.objective.parent.area) if ih.indicator && ih.indicator.objective && ih.indicator.objective.parent  
    end
  end
end