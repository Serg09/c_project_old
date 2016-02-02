class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :author_id, null: false
      t.integer :image_binary_id, null: false
      t.string :hash_id, limit: 40, null: false
      t.string :mime_type, limit: 20, null: false

      t.timestamps null: false
    end

    add_index :images, :author_id
    add_index :images, :hash_id, unique: true
  end
end
