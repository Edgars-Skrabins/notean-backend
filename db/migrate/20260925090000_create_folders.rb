class CreateFolders < ActiveRecord::Migration[7.2]
  def change
    create_table :folders do |t|
      t.references :team, null: false, foreign_key: true
      t.string :item_type, null: false
      t.references :parent, null: true, foreign_key: { to_table: :folders }
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false

      t.timestamps
    end
  end
end
