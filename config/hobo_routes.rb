# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Hoshinplan::Application.routes.draw do


  # Resource routes for controller areas
  resources :areas, :only => [:edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      get 'charts'
      post 'form'
    end
  end

  # Owner routes for controller areas
  resources :hoshins, :as => :hoshin, :only => [] do
    resources :areas, :only => [] do
      get '/', :on => :new, :action => 'new_for_hoshin'
      collection do
        post '/', :action => 'create_for_hoshin'
      end
    end
  end


  # Resource routes for controller billing_details
  resources :billing_details, :only => [:edit, :show, :create, :update, :destroy]

  # Owner routes for controller billing_details
  resources :companies, :as => :company, :only => [] do
    resources :billing_details, :only => [] do
      get '/', :on => :new, :action => 'new_for_company'
      collection do
        post '/', :action => 'create_for_company'
      end
    end
  end


  # Resource routes for controller billing_plans
  resources :billing_plans, :only => [:index] do
    collection do
      get 'pricing'
    end
  end


  # Resource routes for controller client_applications
  resources :client_applications do
    member do
      post 'sign'
    end
  end


  # Resource routes for controller companies
  resources :companies do
    collection do
      get 'complete_users'
      get 'complete_users2'
    end
    member do
      get 'collaborators'
      get 'upgrade'
      post 'checkout'
      post 'invite'
    end
  end


  # Resource routes for controller generic_comments
  resources :generic_comments, :only => [:index, :new, :create]


  # Resource routes for controller company_comments
  resources :company_comments, :only => []

  # Owner routes for controller company_comments
  resources :companies, :as => :company, :only => [] do
    resources :company_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_company'
      collection do
        post '/', :action => 'create_for_company'
      end
    end
  end


  # Resource routes for controller hoshin_comments
  resources :hoshin_comments, :only => []

  # Owner routes for controller hoshin_comments
  resources :hoshins, :as => :hoshin, :only => [] do
    resources :hoshin_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_hoshin'
      collection do
        post '/', :action => 'create_for_hoshin'
      end
    end
  end


  # Resource routes for controller goal_comments
  resources :goal_comments, :only => []

  # Owner routes for controller goal_comments
  resources :goals, :as => :goal, :only => [] do
    resources :goal_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_goal'
      collection do
        post '/', :action => 'create_for_goal'
      end
    end
  end


  # Resource routes for controller area_comments
  resources :area_comments, :only => []

  # Owner routes for controller area_comments
  resources :areas, :as => :area, :only => [] do
    resources :area_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_area'
      collection do
        post '/', :action => 'create_for_area'
      end
    end
  end


  # Resource routes for controller objective_comments
  resources :objective_comments, :only => []

  # Owner routes for controller objective_comments
  resources :objectives, :as => :objective, :only => [] do
    resources :objective_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_objective'
      collection do
        post '/', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller indicator_comments
  resources :indicator_comments, :only => []

  # Owner routes for controller indicator_comments
  resources :indicators, :as => :indicator, :only => [] do
    resources :indicator_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_indicator'
      collection do
        post '/', :action => 'create_for_indicator'
      end
    end
  end


  # Resource routes for controller task_comments
  resources :task_comments, :only => []

  # Owner routes for controller task_comments
  resources :tasks, :as => :task, :only => [] do
    resources :task_comments, :only => [] do
      get '/', :on => :new, :action => 'new_for_task'
      collection do
        post '/', :action => 'create_for_task'
      end
    end
  end


  # Resource routes for controller goals
  resources :goals, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'reorder'
    end
    member do
      post 'form'
    end
  end

  # Owner routes for controller goals
  resources :hoshins, :as => :hoshin, :only => [] do
    resources :goals, :only => [] do
      get '/', :on => :new, :action => 'new_for_hoshin'
      collection do
        post '/', :action => 'create_for_hoshin'
      end
    end
  end


  # Resource routes for controller hoshins
  resources :hoshins, :only => [:new, :edit, :show, :create, :update, :destroy] do
    member do
      get 'health'
      get 'kanban'
      get 'charts'
      get 'map'
      post 'kanban_update'
      post 'sort_by_deadline'
      post 'request_access'
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'archive', :action => 'do_archive'
      get 'archive'
      put 'clone', :action => 'do_clone'
      get 'clone'
      put 'clone', :action => 'do_clone'
      get 'clone'
    end
  end

  # Owner routes for controller hoshins
  resources :companies, :as => :company, :only => [] do
    resources :hoshins, :only => [] do
      get '/', :on => :new, :action => 'new_for_company'
      collection do
        post '/', :action => 'create_for_company'
      end
    end
  end


  # Resource routes for controller indicator_events
  resources :indicator_events, :only => [:edit, :show, :create, :update, :destroy]

  # Owner routes for controller indicator_events
  resources :indicators, :as => :indicator, :only => [] do
    resources :indicator_events, :only => [] do
      get '/', :on => :new, :action => 'new_for_indicator'
      collection do
        post '/', :action => 'create_for_indicator'
      end
    end
  end


  # Resource routes for controller indicator_histories
  resources :indicator_histories, :only => [:new, :edit, :show, :create, :update, :destroy]

  # Owner routes for controller indicator_histories
  resources :indicators, :as => :indicator, :only => [] do
    resources :indicator_histories, :only => [] do
      collection do
        post '/', :action => 'create_for_indicator'
      end
    end
  end


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
      post 'data_update'
    end
  end

  # Owner routes for controller indicators
  resources :objectives, :as => :objective, :only => [] do
    resources :indicators, :only => [] do
      get '/', :on => :new, :action => 'new_for_objective'
      collection do
        get '/', :action => 'index_for_objective'
        post '/', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller invoices
  resources :invoices, :only => [:show]

  # Owner routes for controller invoices
  resources :subscriptions, :as => :subscription, :only => [] do
    resources :invoices, :only => [] do
      collection do
        get '/', :action => 'index_for_subscription'
      end
    end
  end


  # Resource routes for controller log
  resources :log, :only => [:index]


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
      get '/', :on => :new, :action => 'new_for_area'
      collection do
        post '/', :action => 'create_for_area'
      end
    end
  end


  # Resource routes for controller payment_notifications
  resources :payment_notifications, :only => []


  # Resource routes for controller subscriptions
  resources :subscriptions, :only => [:new, :create, :destroy]

  # Owner routes for controller subscriptions
  resources :users, :as => :user, :only => [] do
    resources :subscriptions, :only => [] do
      collection do
        get '/', :action => 'index_for_user'
      end
    end
  end


  # Resource routes for controller subscription_paypals
  resources :subscription_paypals, :only => [:new, :destroy]


  # Resource routes for controller subscription_stripes
  resources :subscription_stripes, :only => [:new, :destroy]


  # Resource routes for controller task_tags
  resources :task_tags, :only => [] do
    collection do
      get 'complete_label'
    end
  end

  # Owner routes for controller task_tags
  resources :tasks, :as => :task, :only => [] do
    resources :task_tags, :only => [] do
      get '/', :on => :new, :action => 'new_for_task'
      collection do
        post '/', :action => 'create_for_task'
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
      get '/', :on => :new, :action => 'new_for_objective'
      collection do
        get '/', :action => 'index_for_objective'
        post '/', :action => 'create_for_objective'
      end
    end
  end


  # Resource routes for controller uri_dir_reports
  resources :uri_dir_reports


  # Resource routes for controller user_companies
  resources :user_companies, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      post 'invite', :action => 'do_invite'
      get 'invite'
      post 'invite_without_email', :action => 'do_invite_without_email'
      get 'invite_without_email'
      post 'activate_ij', :action => 'do_activate_ij'
      get 'activate_ij'
    end
    member do
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'resend_invite', :action => 'do_resend_invite'
      get 'resend_invite'
      put 'accept', :action => 'do_accept'
      get 'accept'
      put 'cancel_invitation', :action => 'do_cancel_invitation'
      get 'cancel_invitation'
      put 'remove', :action => 'do_remove'
      get 'remove'
    end
  end


  # Resource routes for controller users
  resources :users, :only => [:new, :edit, :show, :create, :update, :destroy] do
    collection do
      get 'check_corporate_login'
      post 'signup', :action => 'do_signup'
      get 'signup'
    end
    member do
      get 'account'
      get 'dashboard'
      get 'tutorial'
      get 'pending'
      get 'unsubscribe'
      get 'kanban'
      put 'resend_activation', :action => 'do_resend_activation'
      get 'resend_activation'
      put 'resend_activation', :action => 'do_resend_activation'
      get 'resend_activation'
      put 'accept_invitation', :action => 'do_accept_invitation'
      get 'accept_invitation'
      put 'activate', :action => 'do_activate'
      get 'activate'
      put 'reset_password', :action => 'do_reset_password'
      get 'reset_password'
      put 'reset_password', :action => 'do_reset_password'
      get 'reset_password'
    end
  end

  # User routes for controller users
  post 'login(.:format)' => 'users#login', :as => 'user_login_post'
  get 'login(.:format)' => 'users#login', :as => 'user_login'
  get 'logout(.:format)' => 'users#logout', :as => 'user_logout'
  get 'forgot_password(.:format)' => 'users#forgot_password', :as => 'user_forgot_password'
  post 'forgot_password(.:format)' => 'users#forgot_password', :as => 'user_forgot_password_post'

  namespace :admin do


    # Resource routes for controller admin/billing_plans
    resources :billing_plans do
      collection do
        get 'from_stripe'
        get 'from_paypal'
        post 'reorder'
      end
      member do
        post 'update_from_paypal'
        post 'sync_paypal'
      end
    end


    # Resource routes for controller admin/clockwork_events
    resources :clockwork_events


    # Resource routes for controller admin/openid_providers
    resources :openid_providers


    # Resource routes for controller admin/paypal_buttons
    resources :paypal_buttons


    # Resource routes for controller admin/saml_providers
    resources :saml_providers


    # Resource routes for controller admin/users
    resources :users do
      collection do
        get 'suplist'
      end
      member do
        post 'supplant'
      end
    end

  end

end
