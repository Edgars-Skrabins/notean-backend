Rails.application.routes.draw do
  get "users/index"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :workspaces , param: :name
  resources :users , param: :email
  post "actions/joinworkspace" => "actions#join_workspace"
end
