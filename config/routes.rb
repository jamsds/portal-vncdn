Rails.application.routes.draw do
  # Front-End
  root "default#index"

  get '/api', to: "default#api"

  # Account Management
  get '/account', to: "account#index"

  # Authenticator
  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", passwords: "users/passwords", confirmations: 'users/confirmations' }
end
