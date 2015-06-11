Rails.application.routes.draw do
  resources :scans
  resources :accounts do
    member do
      post 'regenerate_keys'
    end
  end
end
