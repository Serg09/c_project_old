module RewardsHelper
  def house_reward_options_for_select(selected)
    options_from_collection_for_select HouseReward.all, :id, :description, selected
  end
end
