Rails.application.routes.draw do
  # Front-End
  root "default#index"

  # Account Management
  get '/account', to: "account#index"
  get '/account/detail', to: "account#detail"
  get '/account/billing', to: "account#billing"
  get '/account/password', to: "account#password"
  get '/account/notification', to: "account#notification"

  get '/account/transaction', to: "account#transaction"

  get '/account/subscription', to: "account#subscription"
  post '/account/subscription/add', to: "account#subscriptionAdd"

  patch '/account/detail/update', to: "account#detailUpdate"
  post  '/account/password/update', to: "account#passwordUpdate"
  patch '/account/notification/update', to: "account#notificationsUpdate"

  get '/account/billing/deposit', to: "account#deposit"
  post '/account/billing/depositCharge', to: "account#depositCharge"
  
  get '/account/payment', to: "account#payment"
  get '/account/payment/charge', to: "account#paymentCharge"

  post '/account/payment/verify', to: "account#paymentVerify"
  post '/account/payment/remove', to: "account#paymentRemove"

  # Reseller Management
  get '/reseller', to: "reseller#index"
  get '/reseller/customer', to: "reseller#customer"
  get '/reseller/customer/create', to: "reseller#customerCreate"
  post '/reseller/customer/add', to: "reseller#customerAdd"
  get '/reseller/customer/:username', to: "reseller#customerDetail"
  get '/reseller/customer/:username/billing', to: "reseller#customerBilling"
  get '/reseller/customer/:username/transaction', to: "reseller#customerTransactions"
  get '/reseller/customer/:username/edit', to: "reseller#customerEdit"
  patch '/reseller/customer/update', to: "reseller#customerUpdate"
  delete '/reseller/customer/:username', to: "reseller#customerDelete"

  get '/reseller/package', to: "reseller#package"
  get '/reseller/package/create', to: "reseller#packageCreate"
  post '/reseller/package/add', to: "reseller#packageAdd"

  get '/reseller/subscription', to: "reseller#subscription"

  # Content Delivery Network(CDN)
  get '/cdn', to: "delivery#delivery"
  get '/cdn/:propertyId/:type', to: "delivery#deliveryDetail"
  get '/cdn/:propertyId/:type/reports', to: "delivery#deliveryReport"
  get '/cdn/:propertyId/:type/logs', to: "delivery#deliveryLog"
  get '/cdn/:propertyId/:type/policies', to: "delivery#deliveryPolicy"

  get '/cdn/create', to: "delivery#deliveryCreate"
  post '/cdn/add', to: "delivery#deliveryAdd"

  get '/cdn/:propertyId/:type/edit', to: "delivery#deliveryEdit"

  put '/cdn/update', to: "delivery#deliveryUpdate"

  post '/cdn/:propertyId/:type/stop', to: "delivery#deliveryStop"
  post '/cdn/:propertyId/:type/start', to: "delivery#deliveryStart"
  post '/cdn/:propertyId/:type/delete', to: "delivery#deliveryDelete"

  # API
  namespace :api do
    scope 'v1.1', as: :v1 do
      get '/', to: "v1#index"

      # Web Acceleration Service
      get '/listDelivery', to: "v1#listDelivery"

      # File Download Acceleration
      get '/listDownload', to: "v1#listDownload"

      # Runtime Background
      get '/customerDelivery', to: "v1#customerDelivery"
      get '/customerDownload', to: "v1#customerDownload"

      post '/customerVolume', to: "v1#customerVolume"
      post '/customerStorage', to: "v1#customerStorage"
    end
  end

  # Authenticator
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords", confirmations: 'users/confirmations' }

  # Runtime Background
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'

  mount Sidekiq::Web, at: '/sidekiq'

  # existing paths
  match '/errors', to: "default#bugs", via: :all
  match '*path' => 'default#errors', via: :all
end
