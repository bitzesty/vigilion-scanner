Rails.application.routes.draw do
  resources :plans, only: :index
  resources :accounts, only: [:show, :create, :update, :destroy]

  resources :projects do
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
    end
  end

  get :healthcheck, to: 'healthcheck#perform'
end
