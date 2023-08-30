Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  namespace :api do
    namespace :v1 do
      resources :internal_users ,only:[:create,:index,:update,:destroy,:show]
      resources :subscriptions,only:[:index,:update]
      resources :donors,only:[:create,:index,:update] do
        member do
          put :subscription
          put :deactivate
          put :promote_rep
        end
        collection do 
          get :find
        end
        resources :members,only:[:create,:index,:destroy] do
          member do
            put :promote_head
            put :promote_donor
          end
      end
    end
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