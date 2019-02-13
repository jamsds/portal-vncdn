Rails.application.routes.draw do
  # Front-End
  root "default#index"

  get '/api', to: "default#api"
end
