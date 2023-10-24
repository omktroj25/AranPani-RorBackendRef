Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end
  namespace :api do
    namespace :v1 do
      resources :internal_users ,only:[:create,:index,:update,:destroy,:show]
      resources :subscriptions,only:[:index,:update]
      resources :donors,only:[:create,:index,:update,:show] do
        member do
          put :subscription
          put :deactivate
          put :demote_rep
          get :payments,to: 'payments#get_payments'
          post :payments,to: 'payments#add_payment'
        end
        put "payments/:id",to: 'payments#settle_payment'
        put "projects/:id",to: 'donors#subscribe_project'
        collection do 
          get :find,to: 'meta/donors#find'
        end
        resources :members,only:[:create,:index,:destroy,:update]
    end

      resources :projects,only:[:index,:create,:show,:update] do
        member do
          post :project_documents
          post :project_activity
          post :project_images
        end
      end
      resources :payments,only:[:index,:create,:show]
      resources :representatives,only:[:index,:show,:update]
      resources :password ,only: [] do
        collection do
          post :forgot
        end
        member do
          post :reset
        end
      end
      get 'dashboard_stats',to: 'dashboards#dashboard_stats'
      get 'donor_stats',to: 'dashboards#donor_stats'
      get 'donation_stats',to: 'dashboards#donation_stats'
    end
  end
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end