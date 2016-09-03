class MakeBooksAuthorPolymorphic < ActiveRecord::Migration
  def up
    add_column :books, :author_type, :string
    sql = "update books set author_type = 'User'"
    ActiveRecord::Base.connection.execute(sql)
    change_column :books, :author_type, :string, null: false, limit: 100
  end

  def down
    remove_column :books, :author_type
  end
end
