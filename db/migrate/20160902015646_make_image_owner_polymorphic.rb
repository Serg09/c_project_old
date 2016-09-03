class MakeImageOwnerPolymorphic < ActiveRecord::Migration
  def up
    rename_column :images, :user_id, :owner_id
    add_column :images, :owner_type, :string

    sql = "update images set owner_type  = 'User';"
    ActiveRecord::Base.connection.execute(sql)

    change_column :images, :owner_type, :string, null: false, limit: 100
  end

  def down
    remove_column :images, :owner_type
    rename_column :images, :owner_id, :user_id
  end
end
