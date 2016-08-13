class RelaxFulfillmentConstraints < ActiveRecord::Migration
  def up
    change_column :fulfillments, :first_name, :string, limit: 100, null: true
    change_column :fulfillments, :last_name, :string, limit: 100, null: true
  end

  def down
    change_column :fulfillments, :first_name, :string, limit: 100, null: false
    change_column :fulfillments, :last_name, :string, limit: 100, null: false
  end
end
