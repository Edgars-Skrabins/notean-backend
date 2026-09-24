class CreateDiagramContributors < ActiveRecord::Migration[7.2]
  def change
    create_table :diagram_contributors do |t|
      t.references :diagram, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :diagram_contributors, [:diagram_id, :user_id], unique: true
  end
end
