class AddUnsubscribeTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :unsubscribed, :boolean, null: false, default: false
    add_column :users, :unsubscribe_token, :string
    User.all.each do |user|
      sql = "update users set unsubscribe_token='#{SecureRandom.uuid}' where id=#{user.id}"
      User.connection.execute sql
    end
    change_column :users, :unsubscribe_token, :string, null:false, limit: 36
    add_index :users, :unsubscribe_token, unique: true
  end

  def down
    remove_index :users, :unsubscribe_token
    remove_columns :users, :unsubscribed, :unsubscribe_token
  end
end
