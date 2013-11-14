Tawseela::Application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config
  
  scope "(:locale)", :locale => /#{SUPPORTED_LOCALES.join("|")}/ do
    resources :pages, :only => [:show]
    resources :flags, :rates, :notifications
    resources :gasoline_types, :cars_makes, :notifications, :users_requests, :cities, :only => [:index]
    resources :messages, :only => [:index, :show]
    resources :feedbacks, :groups_users, :only => [:new, :create]
    resources :payments do
      member do
        get :confirm
      end
      collection do
        post :cashu_approved
        post :cashu_sorry
      end
    end
    resources :events
    resources :users do 
      resources :transports do
        collection do
          get :transports_requests
        end
      end
      resources :messages do 
        collection do
          get :sent
        end
      end
      resources :notifications, :users_requests, :only => [:index]
      resources :blocks do
        member do
          get :delete
        end
      end
      member do
        get :merge_accounts
        get :update_default_account
        get :dashboard
        put :invite_friends
      end
      collection do
        get :get_token
      end
    end
    resources :searches do
      member do
        get :delete
      end
      collection do
        get :my_searches
        post :results
        get :get_token
      end 
    end
    resources :transports do
      collection do 
        get :upcoming
        get :get_token
      end
      member do
        get :share
      end
      resources :flags, :rates do
        member do
          get :delete
          get :share
        end
      end
      resources :transports_requests do
        resources :flags, :rates do
          member do
            get :delete
          end
        end
        member do
          get :transports_response
          get :reject_request
          put :accept_request
          get :cancel_request
          get :delete
        end
      end
      member do
        get :delete
        put :repeat
      end
    end
    
    match '/login_header' => 'sessions#login_header'
    match '/auth/failure' => 'sessions#failure'
    match '/auth/:provider/callback' => 'sessions#create'
    match '/login/(:provider)' => 'sessions#login', :as => :login
    match '/mobile_login/:provider' => 'sessions#mobile_login', :as => :mobile_login
    match '/logout' => 'sessions#destroy', :as => :logout
    match '/get_current_user' => 'users#get_current_user', :as => :get_current_user
    match '/check_current_user' => 'users#check_current_user', :as => :check_current_user        
    
    root :to => 'pages#show', :id => :home
  
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
  # match ':controller(/:action(/:id(.:format)))'
end
