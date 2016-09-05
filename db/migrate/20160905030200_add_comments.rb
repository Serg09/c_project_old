class AddComments < ActiveRecord::Migration
  def change
    add_column :bios, :comments, :text
    add_column :book_versions, :comments, :text
  end
end
