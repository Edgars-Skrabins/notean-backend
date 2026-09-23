class AddNameToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :name, :string, null: false
    add_index :teams, :code, unique: true
  end
end
