class AddUniqueConstraintToBookVersionsGenres < ActiveRecord::Migration
  def change
    add_index :book_versions_genres, [:book_version_id, :genre_id], unique: true
  end
end
