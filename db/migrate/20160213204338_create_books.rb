class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.integer :author_id, null: false
      t.string :title, null: false, limit: 255
      t.string :short_description, null: false, limit: 1000
      t.text :long_description
      t.integer :cover_image_id
      t.string :status, null: false, default: 'pending'

      t.timestamps null: false
    end

    add_index :books, :author_id
  end
end
