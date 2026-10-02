class CreateColumns < ActiveRecord::Migration[7.2]
  def change
    create_table :columns do |t|
      t.references :board, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
