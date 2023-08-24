Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  namespace :api do
    namespace :v1 do
      resources :internal_users ,only:[:create,:index,:update,:destroy]
      resources :donors
      resources :projects
      resources :payments
      resources :representatives
      resources :password ,only: [] do
        collection do
          post :forgot
        end
        member do
          post :reset
        end
      end
    end
  end
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
