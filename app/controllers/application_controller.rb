class ApplicationController < ActionController::API
  private
  def workspace_params
    params.require(:workspace).permit(:name, :password)
  end
end

