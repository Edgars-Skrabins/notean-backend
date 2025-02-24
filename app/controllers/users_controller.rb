class UsersController < ApplicationController
  def index
  end

  def create
    @user = User.new(user_params)
    if User.exists?(email: user_params[:email])
      render json: { statusMessage: 'User with this email already exists' }, status: :conflict
      return
    end

    if @user.save
      render json: { user: @user.as_json(except: :password), statusMessage: 'User created successfully' }, status: :created
    else
      render json: { statusMessage: 'Failed to create user'}, status: :unprocessable_entity
    end
  end
end