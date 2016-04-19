class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.string :type, limit: 50, null: false
      t.integer :donation_id, null: false
      t.integer :reward_id, null: false
      t.string :email, limit: 200
      t.string :address1, limit: 100
      t.string :address2, limit: 100
      t.string :city, limit: 100
      t.string :state, limit: 2
      t.string :postal_code, limit: 15
      t.string :country_code, limit: 2
      t.boolean :delivered, null: false, default: false

      t.timestamps null: false
      t.index :donation_id
      t.index :reward_id
    end
  end
end
