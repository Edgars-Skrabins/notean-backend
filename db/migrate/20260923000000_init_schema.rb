class InitSchema < ActiveRecord::Migration[7.2]
  def change
    create_table :teams do |t|
      t.string :code
      t.string :password
      t.string :password_digest
      t.string :name, null: false

      t.timestamps
    end
    add_index :teams, :code, unique: true

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :username, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end
    add_index :memberships, [:user_id, :team_id], unique: true
  end
end
