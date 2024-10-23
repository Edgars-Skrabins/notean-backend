class WorkspacesController < ApplicationController
  def index
    @workspaces = Workspace.all
    render json: @workspaces
  end

  def show
    @workspace = Workspace.find(params[:id])
    render json: @workspace
  end

  def create
    @workspace = Workspace.new(workspace_params)
    if Workspace.exists?(name: workspace_params[:name])
      render json: { statusMessage: 'Workspace with this name already exists' }, status: :conflict
      return
    end

    if @workspace.save
      render json: { workspace: @workspace, statusMessage: 'Workspace created successfully' }, status: :created
    else
      render json: { statusMessage: 'Failed to create workspace'}, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end

  private
  def workspace_params
    params.require(:workspace).permit(:name, :password)
  end
end
