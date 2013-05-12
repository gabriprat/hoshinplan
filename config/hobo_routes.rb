# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Hoshinplan::Application.routes.draw do


  # Resource routes for controller tasks
  resources :tasks, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'complete', :action => 'do_complete'
      get 'complete'
      put 'discard', :action => 'do_discard'
      get 'discard'
      put 'reactivate', :action => 'do_reactivate'
      get 'reactivate'
      put 'reactivate', :action => 'do_reactivate'
      get 'reactivate'
    end
  end

  # Owner routes for controller tasks
  resources :objectives, :as => :objective, :only => [] do
    resources :tasks, :only => [] do
      get 'new', :on => :new, :action => 'new_for_objective'
      collection do
        post 'create', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller hoshins
  resources :hoshins

  # Owner routes for controller hoshins
  resources :companies, :as => :company, :only => [] do
    resources :hoshins, :only => [] do
      get 'new', :on => :new, :action => 'new_for_company'
      collection do
        post 'create', :action => 'create_for_company'
      end
    end
  end


  # Resource routes for controller indicators
  resources :indicators, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end


  # Resource routes for controller companies
  resources :companies


  # Resource routes for controller users
  resources :users, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      post 'signup', :action => 'do_signup'
      get 'signup'
    end
    member do
      get 'account'
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'reset_password', :action => 'do_reset_password'
      get 'reset_password'
    end
  end

  # User routes for controller users
  match 'login(.:format)' => 'users#login', :as => 'user_login'
  get 'logout(.:format)' => 'users#logout', :as => 'user_logout'
  match 'forgot_password(.:format)' => 'users#forgot_password', :as => 'user_forgot_password'


  # Resource routes for controller objectives
  resources :objectives, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller objectives
  resources :areas, :as => :area, :only => [] do
    resources :objectives, :only => [] do
      get 'new', :on => :new, :action => 'new_for_area'
      collection do
        post 'create', :action => 'create_for_area'
      end
    end
  end


  # Resource routes for controller areas
  resources :areas, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end


  # Resource routes for controller indicator_histories
  resources :indicator_histories, :only => [:new, :edit, :show, :create, :update, :destroy]

end
