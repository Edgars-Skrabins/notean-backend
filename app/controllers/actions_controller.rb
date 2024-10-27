class ActionsController < ApplicationController

  def join_workspace
    @workspace = Workspace.find_by(name: workspace_params[:name])

    if @workspace.nil?
      render json: { statusMessage: 'Workspace not found' }, status: :not_found
      return
    end

    if @workspace.authenticate(workspace_params[:password])
      render json: {
        workspace: @workspace.as_json(except: :password),
        statusMessage: 'Workspace joined successfully' },
             status: :ok
    else
      render json: { statusMessage: 'Wrong password' }, status: :unauthorized
    end
  end
end
