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
    if @workspace.save
      render json: @workspace, status: :created
    else
      render json: @workspace.errors, status: :unprocessable_entity
    end
  end

  def update
  end

  def destroy
  end
end
