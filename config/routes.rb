Hoshinplan::Application.routes.draw do
  match ENV['RAILS_RELATIVE_URL_ROOT'] => 'front#index' if ENV['RAILS_RELATIVE_URL_ROOT']

  root :to => 'front#index'

  match 'users/:id/reset_password_from_email/:key' => 'users#reset_password', :as => 'reset_password_from_email'

  match 'users/:id/accept_invitation_from_email/:key' => 'users#accept_invitation', :as => 'accept_invitation_from_email'

  match 'users/:id/activate_from_email/:key' => 'users#activate', :as => 'activate_from_email'
  
  match 'user_companies/:id/accept_from_email/:key' => 'user_companies#accept', :as => 'accept_from_email'

  match 'search' => 'front#search', :as => 'site_search'
  
  match 'first' => 'front#first', :as => 'front_first'

  match 'invitation-accepted' => 'front#invitation_accepted', :as => 'front_invitation_accepted'

  match 'sendreminders' => 'front#sendreminders', :as => 'send_reminders'

  match 'mail_preview' => 'mail_preview#index'
  
  match 'mail_preview(/:action(/:id(.:format)))' => 'mail_preview#:action'
  
  match  'admin' => 'admin/admin_site#index'
  
  match  'cms/:key/expire' => 'cms#expire', :constraints => {:key => /.*/}
  
  match  'cms/:key' => 'cms#show', :constraints => {:key => /.*/}
  
  match  '/login' => 'front#login'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  match '/404' => 'errors#not_found'
  match '/422' => 'errors#server_error'
  match '/500' => 'errors#server_error'
end
