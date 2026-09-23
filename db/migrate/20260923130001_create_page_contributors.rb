class CreatePageContributors < ActiveRecord::Migration[7.2]
  def change
    create_table :page_contributors do |t|
      t.references :page, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :page_contributors, [:page_id, :user_id], unique: true
  end
end
