module Admin::HouseRewardsHelper
  def estimator_class_options_for_select(selected)
    options_for_select([['None', ''], ['Publishing', 'PublishingCostEstimator']], selected)
  end
end
