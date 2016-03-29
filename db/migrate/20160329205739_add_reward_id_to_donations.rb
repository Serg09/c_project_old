class AddRewardIdToDonations < ActiveRecord::Migration
  def change
    change_table :donations do |t|
      t.integer :reward_id
      t.index :reward_id
    end
  end
end
