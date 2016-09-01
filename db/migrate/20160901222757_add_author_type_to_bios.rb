class AddAuthorTypeToBios < ActiveRecord::Migration
  def up
    add_column :bios, :author_type, :string
    sql = "update bios set author_type = 'User'"
    ActiveRecord::Base.connection.execute(sql)
    change_column :bios, :author_type, :string, null: false, limit: 100
  end

  def down
    remove_column :bios, :author_type
  end
end
