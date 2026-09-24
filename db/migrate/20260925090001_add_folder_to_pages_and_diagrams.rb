class AddFolderToPagesAndDiagrams < ActiveRecord::Migration[7.2]
  def change
    add_reference :pages, :folder, null: true, foreign_key: true
    add_reference :diagrams, :folder, null: true, foreign_key: true
  end
end
