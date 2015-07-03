Rails.application.routes.draw do
  resources :scans, only: [:index, :create, :show] do
    collection do
      get :stats
    end
  end

  resources :projects do
    member do
      post :regenerate_keys
      post :update_plan
    end
  end
end
