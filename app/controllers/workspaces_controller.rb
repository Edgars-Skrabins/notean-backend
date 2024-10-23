class WorkspacesController < ApplicationController
  def index
    @workspaces = Workspace.all
    render json: @workspaces
  end

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end
end
