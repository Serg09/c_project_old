class CreateBios < ActiveRecord::Migration
  def change
    create_table :bios do |t|
      t.integer :author_id, null: false
      t.text :text, null: false
      t.integer :photo_id

      t.timestamps null: false
    end
  end
end
