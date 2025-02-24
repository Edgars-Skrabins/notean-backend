class ApplicationController < ActionController::API
  private
  def workspace_params
    params.require(:workspace).permit(:name, :password)
  end
  def user_params
    params.require(:user).permit(:email, :password)
  end
end

