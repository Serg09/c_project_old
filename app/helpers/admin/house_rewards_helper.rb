module Admin::HouseRewardsHelper
  def estimator_class_options_for_select(selected)
    options = [
      ['None', ''],
      ['Publishing', 'PublishingCostEstimator'],
      ['e-Book', 'EbookCostEstimator'],
    ]
    options_for_select(options, selected)
  end
end
