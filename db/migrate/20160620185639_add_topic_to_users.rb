class AddTopicToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :package_id, :integer
    add_column :users, :topic, :text
  end
end
