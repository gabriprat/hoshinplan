# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Hoshinplan::Application.routes.draw do


  # Resource routes for controller areas
  resources :areas, :only => [:index, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end


  # Resource routes for controller client_applications
  resources :client_applications do
    member do
      get 'sign'
    end
  end


  # Resource routes for controller companies
  resources :companies do
    collection do
      get 'complete_users'
    end
    member do
      get 'collaborators'
    end
  end


  # Resource routes for controller goals
  resources :goals, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
  end

  # Owner routes for controller goals
  resources :hoshins, :as => :hoshin, :only => [] do
    resources :goals, :only => [] do
      get 'new', :on => :new, :action => 'new_for_hoshin'
      collection do
        post 'create', :action => 'create_for_hoshin'
      end
    end
  end


  # Resource routes for controller hoshins
  resources :hoshins, :only => [:new, :edit, :show, :create, :update, :destroy] do
    member do
      get 'health'
      get 'kanban'
      post 'kanban_update'
    end
  end

  # Owner routes for controller hoshins
  resources :companies, :as => :company, :only => [] do
    resources :hoshins, :only => [] do
      get 'new', :on => :new, :action => 'new_for_company'
      collection do
        post 'create', :action => 'create_for_company'
      end
    end
  end


  # Resource routes for controller indicator_histories
  resources :indicator_histories, :only => [:new, :edit, :show, :create, :update, :destroy]


  # Resource routes for controller indicators
  resources :indicators, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      get 'history'
      post 'form'
      post 'value_form'
      post 'delete_history'
    end
  end

  # Owner routes for controller indicators
  resources :objectives, :as => :objective, :only => [] do
    resources :indicators, :only => [] do
      get 'new', :on => :new, :action => 'new_for_objective'
      collection do
        get 'index', :action => 'index_for_objective'
        post 'create', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller milestones
  resources :milestones, :only => [:new, :edit, :show, :create, :update, :destroy]


  # Resource routes for controller objectives
  resources :objectives, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      post 'form'
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


  # Resource routes for controller tasks
  resources :tasks, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      post 'form'
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'complete', :action => 'do_complete'
      get 'complete'
      put 'discard', :action => 'do_discard'
      get 'discard'
      put 'start', :action => 'do_start'
      get 'start'
      put 'reactivate', :action => 'do_reactivate'
      get 'reactivate'
      put 'reactivate', :action => 'do_reactivate'
      get 'reactivate'
      put 'delete', :action => 'do_delete'
      get 'delete'
      put 'delete', :action => 'do_delete'
      get 'delete'
      put 'delete', :action => 'do_delete'
      get 'delete'
      put 'to_backlog', :action => 'do_to_backlog'
      get 'to_backlog'
      put 'to_active', :action => 'do_to_active'
      get 'to_active'
      put 'to_completed', :action => 'do_to_completed'
      get 'to_completed'
      put 'to_discarded', :action => 'do_to_discarded'
      get 'to_discarded'
      put 'to_deleted', :action => 'do_to_deleted'
      get 'to_deleted'
    end
  end

  # Owner routes for controller tasks
  resources :objectives, :as => :objective, :only => [] do
    resources :tasks, :only => [] do
      get 'new', :on => :new, :action => 'new_for_objective'
      collection do
        get 'index', :action => 'index_for_objective'
        post 'create', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller user_companies
  resources :user_companies, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'invite', :action => 'do_invite'
      get 'invite'
      post 'activate_ij', :action => 'do_activate_ij'
      get 'activate_ij'
    end
    member do
      put 'revoke_admin', :action => 'do_revoke_admin'
      get 'revoke_admin'
      put 'resend_invite', :action => 'do_resend_invite'
      get 'resend_invite'
      put 'accept', :action => 'do_accept'
      get 'accept'
      put 'cancel_invitation', :action => 'do_cancel_invitation'
      get 'cancel_invitation'
      put 'make_admin', :action => 'do_make_admin'
      get 'make_admin'
      put 'revoke_admin', :action => 'do_revoke_admin'
      get 'revoke_admin'
      put 'remove', :action => 'do_remove'
      get 'remove'
    end
  end


  # Resource routes for controller users
  resources :users, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      post 'signup', :action => 'do_signup'
      get 'signup'
    end
    member do
      get 'dashboard'
      get 'tutorial'
      get 'pending'
      get 'unsubscribe'
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

  namespace :admin do


    # Resource routes for controller admin/openid_providers
    resources :openid_providers


    # Resource routes for controller admin/users
    resources :users, :only => [:index, :edit, :show, :update, :destroy] do
      collection do
        get 'suplist'
      end
      member do
        post 'supplant'
      end
    end

  end

end
