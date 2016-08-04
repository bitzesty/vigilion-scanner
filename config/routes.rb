Rails.application.routes.draw do
  resources :plans, only: [:index, :show]
  resources :accounts, only: [:show, :create, :update, :destroy]

  resources :projects, only: [:index, :show, :create, :update, :destroy] do
    member do
      post :regenerate_keys
      post :update_plan
    end
    collection do
      get :validate
    end
  end

  resources :scans, only: [:index, :create, :show] do
    collection do
      get :stats
      get :admin_stats
    end
  end

  get :healthcheck, to: 'healthcheck#perform'
  get :status, to: 'healthcheck#perform'

  # Redirect the root api request back to vigilion
  root to: redirect('https://www.vigilion.com/')
end
