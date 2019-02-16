Rails.application.routes.draw do
  # Front-End
  root "default#index"

  # Account Management
  get '/account', to: "account#index"

  # Reseller Management
  get '/reseller', to: "reseller#index"

  # Content Delivery Network(CDN)
  get '/delivery', to: "default#delivery"
  get '/delivery/:propertyId/:type', to: "default#deliveryDetail"
  get '/delivery/:propertyId/:type/reports', to: "default#deliveryReport"
  get '/delivery/:propertyId/:type/logs', to: "default#deliveryLog"

  get '/delivery/create', to: "default#deliveryCreate"
  post '/delivery/add', to: "default#deliveryAdd"

  get '/delivery/:propertyId/:type/edit', to: "default#deliveryEdit"
  put '/delivery/update', to: "default#deliveryUpdate"

  # API
  namespace :api do
    scope 'v1.1', as: :v1 do
      get '/', to: "v1#index"

      # Customer
      post '/createCustomer', to: "v1#createCustomer"

      # Web Acceleration Service
      get '/listDelivery', to: "v1#listDelivery"

      # File Download Acceleration
      get '/listDownload', to: "v1#listDownload"
    end
  end

  # Authenticator
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords", confirmations: 'users/confirmations' }
end
