class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :campaign_id, null: false
      t.string :description, null: false, limit: 100
      t.text :long_description
      t.decimal :minimum_donation, null: false
      t.boolean :physical_address_required, null: false, default: false
      t.integer :house_reward_id

      t.timestamps null: false

      t.index :house_reward_id
      t.index [:campaign_id, :description], unique: true
    end
  end
end
