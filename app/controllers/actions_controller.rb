class ActionsController < ApplicationController
  before_action :authenticate_user!

  def join_team
    @team = Team.find_by(code: team_params[:code])

    if @team.nil?
      render json: { statusMessage: 'Team not found' }, status: :not_found
      return
    end

    if @team.authenticate(team_params[:password])
      membership = @team.memberships.find_or_create_by!(user: current_user) { |m| m.role = 'user' }
      membership.update!(last_active_at: Time.current)
      render json: {
        team: @team.as_json(except: [:password, :password_digest]),
        role: membership.role,
        statusMessage: 'Team joined successfully' },
             status: :ok
    else
      render json: { statusMessage: 'Wrong password' }, status: :unauthorized
    end
  end
end
