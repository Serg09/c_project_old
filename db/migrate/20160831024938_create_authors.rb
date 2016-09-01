class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :first_name, null: false, limit: 100
      t.string :last_name, null: false, limit: 100

      t.timestamps null: false
      t.index [:last_name, :first_name], unique: true
    end
  end
end
