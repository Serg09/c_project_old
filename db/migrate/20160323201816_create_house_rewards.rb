class CreateHouseRewards < ActiveRecord::Migration
  def change
    create_table :house_rewards do |t|
      t.string :description, null: false, limit: 255
      t.boolean :physical_address_required, null: false, default: false

      t.timestamps null: false
    end
  end
end
