class RemoveStatusFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :status
  end

  def down
    add_column :users, :status, :string
    User.connection.execute("update users set status = 'approved'")
    change_column :users, :status, :string, null: false, limit: 10, default: "pending"
  end
end
