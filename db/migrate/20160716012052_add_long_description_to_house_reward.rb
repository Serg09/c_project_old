class AddLongDescriptionToHouseReward < ActiveRecord::Migration
  def change
    add_column :house_rewards, :long_description, :text
  end
end
