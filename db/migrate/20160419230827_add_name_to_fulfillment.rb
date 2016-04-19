class AddNameToFulfillment < ActiveRecord::Migration
  def up
    change_table :fulfillments do |t|
      t.string :first_name, null: false, limit: 100, default: 'unknown'
      t.string :last_name, null: false, limit: 100, default: 'unknown'
    end
    change_column :fulfillments, :first_name, :string, limit: 100, default: nil
    change_column :fulfillments, :last_name, :string, limit: 100, default: nil
  end

  def down
    remove_column :fulfillments, :first_name
    remove_column :fulfillments, :last_name
  end
end
