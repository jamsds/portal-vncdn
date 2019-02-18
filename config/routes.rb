Rails.application.routes.draw do
  # Front-End
  root "default#index"

  # Account Management
  get '/account', to: "account#index"
  get '/account/detail', to: "account#detail"
  get '/account/password', to: "account#password"

  post '/account/detail/update', to: "account#detailUpdate"
  post '/account/password/update', to: "account#passwordUpdate"

  # Reseller Management
  get '/reseller', to: "reseller#index"

  # Content Delivery Network(CDN)
  get '/cdn', to: "default#delivery"
  get '/cdn/:propertyId/:type', to: "default#deliveryDetail"
  get '/cdn/:propertyId/:type/reports', to: "default#deliveryReport"
  get '/cdn/:propertyId/:type/logs', to: "default#deliveryLog"

  get '/cdn/create', to: "default#deliveryCreate"
  post '/cdn/add', to: "default#deliveryAdd"

  get '/cdn/:propertyId/:type/edit', to: "default#deliveryEdit"

  put '/cdn/update', to: "default#deliveryUpdate"

  post '/cdn/:propertyId/:type/stop', to: "default#deliveryStop"
  post '/cdn/:propertyId/:type/start', to: "default#deliveryStart"
  post '/cdn/:propertyId/:type/delete', to: "default#deliveryDelete"

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
