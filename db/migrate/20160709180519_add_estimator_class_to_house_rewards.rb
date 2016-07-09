class AddEstimatorClassToHouseRewards < ActiveRecord::Migration
  def change
    add_column :house_rewards, :estimator_class, :string, limit: 200
  end
end
