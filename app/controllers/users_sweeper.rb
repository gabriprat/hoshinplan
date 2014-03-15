class UsersSweeper < ActionController::Caching::Sweeper
  
  observe User

  def after_create(user)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(user)
    end
  end

  def after_update(user)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(user)
    end
  end

  def after_destroy(user)
    if Rails.configuration.action_controller.perform_caching
      expire_swept_caches_for(user)
    end
  end
end