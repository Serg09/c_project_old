class AddAuthorFields < ActiveRecord::Migration
  def change
    change_table :authors do |t|
      t.string 'username', null: false
      t.string 'first_name', null: false
      t.string 'last_name', null: false
      t.string 'phone_number', null: true
      t.boolean 'contactable', null: false, default: false
      t.integer 'package_id', null: true
    end

    add_index :authors, :username, unique: true
  end
end
