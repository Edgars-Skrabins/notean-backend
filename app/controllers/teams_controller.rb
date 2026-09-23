class TeamsController < ApplicationController
  before_action :authenticate_user!

  def show
    @team = Team.find_by(code: params[:code])

    if @team
      render json: { team: @team.as_json(except: [:password, :password_digest]), statusMessage: 'Team found' }
    else
      render json: { statusMessage: 'Team not found' }, status: :not_found
    end
  end

  def create
    if Team.exists?(code: team_params[:code])
      render json: { statusMessage: 'Team with this code already exists' }, status: :conflict
      return
    end

    @team = Team.new(team_params)

    if @team.save
      @team.memberships.create!(user: current_user, role: 'owner')
      render json: { team: @team.as_json(except: [:password, :password_digest]), statusMessage: 'Team created successfully' }, status: :created
    else
      render json: { statusMessage: 'Failed to create team' }, status: :unprocessable_entity
    end
  end
end
