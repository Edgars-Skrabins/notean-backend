class RenameWorkspacesToTeams < ActiveRecord::Migration[7.2]
  def change
    rename_table :workspaces, :teams
    rename_column :teams, :name, :code
  end
end
