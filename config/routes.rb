Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :workspaces , param: :name
  post "actions/joinworkspace" => "actions#join_workspace"

  post "auth/register" => "users#create"
  post "auth/login" => "sessions#create"
end
