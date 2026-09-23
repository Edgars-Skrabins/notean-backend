Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :teams, only: [:create, :show], param: :code do
    resources :pages, only: [:index, :create, :show, :update, :destroy]
  end

  post "actions/jointeam" => "actions#join_team"

  post "auth/register" => "users#create"
  post "auth/login" => "sessions#create"

  mount ActionCable.server => "/cable"
end
