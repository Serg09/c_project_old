class ChangeAuthorsToUsers < ActiveRecord::Migration
  def up
    rename_table :authors, :users
    rename_column :images, :author_id, :user_id
  end

  def down
    rename_column :images, :user_id, :author_id
    rename_table :users, :authors
  end
end
