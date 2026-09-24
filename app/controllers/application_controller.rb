class ApplicationController < ActionController::API
  private
  def team_params
    params.require(:team).permit(:code, :password)
  end

  def create_team_params
    params.require(:team).permit(:name, :password)
  end

  def update_team_params
    params.require(:team).permit(:name)
  end

  def user_params
    params.require(:user).permit(:email, :username, :password)
  end

  def create_page_params
    params.fetch(:page, {}).permit(:title)
  end

  def update_page_params
    params.require(:page).permit(:title, :content, :folder_id)
  end

  def create_diagram_params
    params.fetch(:diagram, {}).permit(:title)
  end

  def update_diagram_params
    params.require(:diagram).permit(:title, :content, :folder_id)
  end

  def create_folder_params
    params.require(:folder).permit(:title, :item_type, :parent_id)
  end

  def update_folder_params
    params.require(:folder).permit(:parent_id)
  end

  def authenticate_user!
    render json: { statusMessage: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  def membership_for(team)
    team.memberships.find_by(user: current_user)
  end

  def require_team_role!(team, *roles)
    membership = membership_for(team)
    unless membership && roles.map(&:to_s).include?(membership.role)
      render json: { statusMessage: 'Forbidden' }, status: :forbidden
      return nil
    end
    membership
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

