class ApplicationController < ActionController::API
  private
  def team_params
    params.require(:team).permit(:code, :password)
  end

  def user_params
    params.require(:user).permit(:email, :username, :password)
  end

  def authenticate_user!
    render json: { statusMessage: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  def current_user
    return @current_user if defined?(@current_user)

    header = request.headers['Authorization']
    token = header.split(' ').last if header

    @current_user = token && User.find_by(id: JsonWebToken.decode(token)[:user_id])
  rescue JWT::DecodeError
    @current_user = nil
  end
end

