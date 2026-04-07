Rails.application.routes.draw do
  namespace :api do
    post 'auth/login', to: 'auth#login'
    post 'auth/register', to: 'auth#register'
    post 'auth/admin-setup', to: 'auth#admin_setup'
    post 'auth/agency-setup', to: 'auth#agency_setup'
    
    resources :submissions, only: [:index, :create]
    resources :drafts, only: [:index, :show, :create, :update, :destroy] do
      member do
        post :submit
      end
    end
    
    # Reference data endpoints
    get 'districts', to: 'reference#districts'
    post 'districts', to: 'reference#create_district'
    get 'chiefdoms', to: 'reference#chiefdoms'
    post 'chiefdoms', to: 'reference#create_chiefdom'
    get 'fertilizers', to: 'reference#fertilizers'
    post 'fertilizers', to: 'reference#create_fertilizer'
    get 'dealers', to: 'reference#dealers'
    post 'dealers', to: 'reference#create_dealer'
    get 'regions', to: 'reference#regions'
    post 'regions', to: 'reference#create_region'
    get 'townships', to: 'reference#townships'
    post 'townships', to: 'reference#create_township'

    namespace :admin do
      resources :users, only: [:create, :index, :show, :update]
      resources :agencies, only: [:create, :index, :show, :update]
      
      # Reference data CRUD
      resources :regions
      resources :districts
      resources :chiefdoms
      resources :townships
      resources :fertilizers
      resources :dealers
      
      get 'analytics/bags-by-district'
      get 'analytics/bags-by-agency'
      get 'analytics/bags-by-fertilizer'
      get 'analytics/agency-district-distribution'
      get 'analytics/dealers-by-region'
      get 'analytics/dealers-by-district'
      get 'analytics/dealers-by-category'
      get 'analytics/license-status-summary'
      get 'analytics/dealer-operational-coverage'
    end
  end
end