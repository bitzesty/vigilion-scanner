Rails.application.routes.draw do
  resources :scans do
    collection do
      get :total
      get :infected
    end
  end

  resources :accounts do
    member do
      post 'regenerate_keys'
    end
  end
end
