class AddPasswordDigestToWorkspaces < ActiveRecord::Migration[7.2]
  def change
    add_column :workspaces, :password_digest, :string
  end
end
