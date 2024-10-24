class WorkspacesController < ApplicationController
  def index
    @workspaces = Workspace.all
    render json: @workspaces.as_json(except: :password)
  end

  def show
    @workspace = Workspace.find_by(id: params[:id]) || Workspace.find_by(name: params[:name])

    if @workspace
      render json: @workspace.as_json(except: :password)
    else
      render json: { statusMessage: 'Workspace not found' }, status: :not_found
    end
  end

  def create
    @workspace = Workspace.new(workspace_params)
    if Workspace.exists?(name: workspace_params[:name])
      render json: { statusMessage: 'Workspace with this name already exists' }, status: :conflict
      return
    end

    if @workspace.save
      render json: { workspace: @workspace.as_json(except: :password), statusMessage: 'Workspace created successfully' }, status: :created
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
