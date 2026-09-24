class CreateDiagrams < ActiveRecord::Migration[7.2]
  def change
    create_table :diagrams do |t|
      t.references :team, null: false, foreign_key: true
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :content, null: false, default: ''

      t.timestamps
    end
  end
end
