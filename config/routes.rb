Rails.application.routes.draw do
  # Front-End
  root "default#index"

  # Account Management
  get '/account', to: "account#index"

  # Reseller Management
  get '/reseller', to: "reseller#index"

  # Content Delivery Network(CDN)
  get '/delivery', to: "default#delivery"

  # API
  namespace :api do
    scope 'v1.1', as: :v1 do
      get '/', to: "v1#index"

      # Customer
      post '/createCustomer', to: "v1#createCustomer"

      # Web Acceleration Service
      get '/listDomain', to: "v1#listDomain"
    end
  end

  # Authenticator
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords", confirmations: 'users/confirmations' }
end
