Rails.application.routes.draw do
  namespace :api do
    post 'auth/login', to: 'auth#login'
    post 'auth/register', to: 'auth#register'
    post 'auth/admin-setup', to: 'auth#admin_setup'
    post 'auth/agency-setup', to: 'auth#agency_setup'
    
    resources :submissions, only: [:index, :create]
    
    # Reference data endpoints
    get 'districts', to: 'reference#districts'
    get 'chiefdoms', to: 'reference#chiefdoms'
    get 'fertilizers', to: 'reference#fertilizers'
    get 'dealers', to: 'reference#dealers'

    namespace :admin do
      resources :users, only: [:create, :index, :show, :update]
      resources :agencies, only: [:create, :index, :show, :update]
      
      # Reference data CRUD
      resources :districts
      resources :chiefdoms
      resources :fertilizers
      resources :dealers
      
      get 'analytics/bags-by-district'
      get 'analytics/bags-by-agency'
      get 'analytics/bags-by-fertilizer'
      get 'analytics/agency-district-distribution'
    end
  end
end