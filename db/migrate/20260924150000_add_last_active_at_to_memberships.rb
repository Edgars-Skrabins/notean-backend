class AddLastActiveAtToMemberships < ActiveRecord::Migration[7.2]
  def up
    add_column :memberships, :last_active_at, :datetime
    execute "UPDATE memberships SET last_active_at = created_at WHERE last_active_at IS NULL"
    change_column_null :memberships, :last_active_at, false
  end

  def down
    remove_column :memberships, :last_active_at
  end
end
