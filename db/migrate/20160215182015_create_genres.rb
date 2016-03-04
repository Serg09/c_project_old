class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :name, null: false, limit: 50

      t.timestamps null: false
      t.index :name, unique: true
    end

    create_join_table :books, :genres do |t|
      t.index :book_id
      t.index :genre_id
    end
  end
end
