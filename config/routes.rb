require 'resque/server'

class RedirectWww
  def matches?(request)
    request.subdomain.blank? && !request.path_info.start_with?('/health_check')
  end
end

Hoshinplan::Application.routes.draw do
  
  apipie
  #adding www. to the beginning of any URL that doesn't already have it
  constraints RedirectWww.new do
    get ':any', to: redirect(subdomain: 'www', path: '/%{any}'), any: /.*/
    root to: redirect(subdomain: 'www'), :as => 'root_redirect'
  end
  
  get "errors/file_not_found"
  get "errors/unprocessable"
  get "errors/internal_server_error"
  get "errors/service_unavailable"
  get "errors/maintenance"

  get ENV['RAILS_RELATIVE_URL_ROOT'] => 'front#index' if ENV['RAILS_RELATIVE_URL_ROOT']
  
  root :to => 'front#index'
  
  get 'users/:id/reset_password_from_email/:key' => 'users#reset_password', :as => 'reset_password_from_email'

  get 'users/:id/accept_invitation_from_email/:key' => 'users#accept_invitation', :as => 'accept_invitation_from_email'

  get 'users/:id/activate_from_email/:key' => 'users#activate', :as => 'activate_from_email'
  
  get 'user_companies/:id/accept_from_email/:key' => 'user_companies#accept', :as => 'accept_from_email'

  get 'search' => 'front#search', :as => 'site_search'
  
  get 'first' => 'front#first', :as => 'front_first'

  get 'confirm-email' => 'front#confirm_email', :as => 'confirm_email'
  get ':partner/confirm-email' => 'front#confirm_email', :as => 'confirm_email_partner'

  get 'health_check' => 'front#health_check', :as => 'health_check'

  get 'about' => 'cms#page', :as => 'cms_about', :key => :about

  get 'features' => 'cms#page', :as => 'cms_features', :key => :features

  get 'invitation-accepted' => 'front#invitation_accepted', :as => 'front_invitation_accepted'

  get 'reprocessphotos' => 'front#reprocess_photos', :as => 'reprocess_photos'
  
  get 'setcolors' => 'front#set_colors', :as => 'set_colors'
  
  get 'sendreminders' => 'front#sendreminders', :as => 'send_reminders'
  
  get 'updateindicators' => 'front#updateindicators', :as => 'update_indicators'
  
  get 'expirecaches' => 'front#expirecaches', :as => 'expire_caches'

  get 'resetcounters' => 'front#resetcounters', :as => 'reset_counters'

  get 'subscriptionbilling' => 'front#subscriptionbilling', :as => 'subscriptionbilling'

  get 'healthupdate' => 'front#healthupdate', :as => 'healthupdate'

  get 'sageonesync' => 'front#sageonesync', :as => 'sageonesync'

  get 'sendtrial' => 'front#sendtrial', :as => 'sendtrial'

  get 'sendinvoice' => 'front#sendinvoice', :as => 'sendinvoice'

  get 'updatepeoplemixpanel' => 'front#updatepeoplemixpanel', :as => 'update_people_mixpanel'

  get 'colorize' => 'front#colorize', :as => 'colorize'

  get 'mail_preview' => 'mail_preview#index'
  
  get 'mail_preview(/:action(/:id(.:format)))' => 'mail_preview#:action'
  
  get  'admin' => 'admin/admin_site#index'
  
  get  'cms/:key/expire' => 'cms#expire', :constraints => {:key => /.*/}
  
  get  'cms/:key' => 'cms#show', :constraints => {:key => /.*/}

  get  'c/:key' => 'cms#page', :constraints => {:key => /.*/}

  get  'legal', :to => redirect('/legal/terms-of-use')

  get  'privacy', :to => redirect('/legal/privacy')
  
  get  '/legal/privacy' => 'legal#show', :defaults => {:id => 'privacy'}
  
  get  'terms-of-use', :to => redirect('/legal/terms-of-use')
  
  get  '/legal/terms-of-use' => 'legal#show', :defaults => {:id => 'terms-of-use'}

  get  'cookies', :to => redirect('/legal/cookies')

  get  '/legal/cookies' => 'legal#show', :defaults => {:id => 'cookies'}

  get  'dpa', :to => redirect('/legal/dpa')

  get  '/legal/dpa' => 'legal#show', :defaults => {:id => 'dpa'}

  get  'users/logout_and_return' => 'users#logout_and_return', :as => 'logout_and_return'
  
  get  'sso_login' => 'front#sso_login', :as => 'sso_login'
  
  get "/auth/failure" => "front#failure"
  
  post "/tasks/form" => "tasks#form", :as => 'task_form'
  
  post "/tasks/reorder_lane/:key/:task_id" => "tasks#reorder_lane"

  post "/indicators/form" => "indicators#form", :as => 'indicators_form'

  post "/objectives/form" => "objectives#form", :as => 'objectives_form'

  post "/areas/form" => "areas#form", :as => 'areas_form'

  post "/goals/form" => "goals#form", :as => 'goals_form'

  get "/pitch" => "front#pitch"
  
  match '/fail', to: 'front#test_fail', via: :all

  match '/auth/:identity_provider_id/callback',
        constraints: { identity_provider_id: /[^\/]+/ },
        via: [:get, :post],
        to: 'users#omniauth_callback',
        as: 'user_omniauth_callback'

  match '/auth/:identity_provider_id',
        constraints: { identity_provider_id: /[^\/]+/ },
        via: [:get, :post],
        to: 'omniauth_callbacks#passthru',
        as: 'user_omniauth_authorize'

  match '/auth/:provider/metadata',
        constraints: { provider: /[^\/]+/ },
        via: [:get, :post],
        to: 'users#omniauth_callback',
        as: 'user_omniauth_metadata'

  get 'pricing' => 'billing_plans#pricing'
  
  get "/payments/test-paypal-ipn" => "payment_notifications#index"
  
  post "/payments/paypal-ipn" => "payment_notifications#paypal_ipn"
  
  get "/payments/cancel" => "subscriptions#cancel"
  get "/payments/correct" => "subscriptions#correct"
  
  post "/stripe_subscription_checkout" => "subscriptions#stripe_subscription_checkout"
  
  get "/admin/billing_plans/create_stripe_plans" => "admin/billing_plans#create_stripe_plans"
  
  get "/log/:type/:id" => "log#index", :as => 'log_index'
  
  get "/tutorial" => "users#tutorial"
  
  get "/countries/complete_name" => "countries#complete_name"

  post "/vat_validator/validate_vat" => "vat_validator#validate_vat"

  post "/faye/auth" => "faye_auth#faye_auth", :as => 'faye_auth'

  get "/hoshins/:id/charts/:area" => "hoshins#charts"

  SamlDynamicRouter.load

  PartnersDynamicRouter.load

  constraints HasBasicAuth do
    post "/chargebee/webhook" => "sage_one#cb_webhook"
  end

  constraints IsAdministrator do
    mount Flipper::UI.app($flipper) => '/admin/flipper'
    mount Resque::Server.new, :at => "/admin/resque"

    get "/sage_one/auth" => "sage_one#auth"
    get "/sage_one/callback" => "sage_one#callback"
    get "/sage_one/sales_invoices" => "sage_one#sales_invoices"
    get "/sage_one/sales_invoices/:id" => "sage_one#sales_invoice"
    get "/sage_one/contacts" => "sage_one#contacts"
    get "/sage_one/contacts/:id" => "sage_one#contact"
    get "/sage_one/create_contact" => "sage_one#create_contact"
    get "/sage_one/create_invoices" => "sage_one#create_invoices"
    get "/sage_one/ledger_accounts" => "sage_one#ledger_accounts"
    get "/sage_one/tax_rates" => "sage_one#tax_rates"
    get "/sage_one/renew_token" => "sage_one#renew_token"
    get "/sage_one/send_invoice/:id" => "sage_one#send_invoice"
  end
  
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

end
