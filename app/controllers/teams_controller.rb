class TeamsController < ApplicationController
  before_action :authenticate_user!

  def mine
    membership = current_user.memberships.order(last_active_at: :desc).first
    render json: {
      team: membership&.team&.as_json(except: [:password, :password_digest]),
      role: membership&.role,
    }
  end

  def mine_all
    memberships = current_user.memberships.includes(:team).order(last_active_at: :desc)
    render json: {
      teams: memberships.map { |m| m.team.as_json(except: [:password, :password_digest]).merge(role: m.role) }
    }
  end

  def activate
    @team = Team.find_by(code: params[:code])
    return render json: { statusMessage: 'Team not found' }, status: :not_found unless @team

    membership = membership_for(@team)
    return render json: { statusMessage: 'Not a member of this team' }, status: :forbidden unless membership

    membership.update!(last_active_at: Time.current)
    render json: { team: @team.as_json(except: [:password, :password_digest]), role: membership.role }
  end

  def members
    @team = Team.find_by(code: params[:code])
    return render json: { statusMessage: 'Team not found' }, status: :not_found unless @team
    return unless require_team_role!(@team, :admin, :owner)

    render json: {
      members: @team.memberships.includes(:user).map { |m| { id: m.user.id, username: m.user.username, role: m.role } }
    }
  end

  def show
    @team = Team.find_by(code: params[:code])

    if @team
      render json: { team: @team.as_json(except: [:password, :password_digest]), statusMessage: 'Team found' }
    else
      render json: { statusMessage: 'Team not found' }, status: :not_found
    end
  end

  def create
    @team = Team.new(create_team_params)

    if @team.save
      @team.memberships.create!(user: current_user, role: 'owner', last_active_at: Time.current)
      render json: { team: @team.as_json(except: [:password, :password_digest]), role: 'owner', statusMessage: 'Team created successfully' }, status: :created
    else
      render json: { statusMessage: 'Failed to create team' }, status: :unprocessable_entity
    end
  end

  def update
    @team = Team.find_by(code: params[:code])
    return render json: { statusMessage: 'Team not found' }, status: :not_found unless @team
    return unless require_team_role!(@team, :admin, :owner)

    if @team.update(update_team_params)
      render json: { team: @team.as_json(except: [:password, :password_digest]), statusMessage: 'Team renamed successfully' }
    else
      render json: { statusMessage: 'Failed to rename team' }, status: :unprocessable_entity
    end
  end

  def destroy
    @team = Team.find_by(code: params[:code])
    return render json: { statusMessage: 'Team not found' }, status: :not_found unless @team
    return unless require_team_role!(@team, :owner)

    @team.destroy!
    render json: { statusMessage: 'Team deleted successfully' }, status: :ok
  end
end
