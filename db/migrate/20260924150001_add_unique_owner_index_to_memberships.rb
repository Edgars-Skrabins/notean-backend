class AddUniqueOwnerIndexToMemberships < ActiveRecord::Migration[7.2]
  def change
    add_index :memberships, :team_id, unique: true, where: "role = 'owner'", name: "index_memberships_on_team_id_unique_owner"
  end
end
