class PublishingCostEstimator
  BASE_PRICE = 4.5
  ADDITIVE = 5.5
  MULTIPLIER = 1.3

  MARKUP_FACTOR = 1.25

  TITLE_SETUP = 95.0
  PROOF = 45.0
  FILE_REVISIONS = 50.0
  ANNUAL_MARKET_DISTRIBUTION = 15.0

  def estimate(book_count)
    additive = ADDITIVE / (MULTIPLIER ** book_count)
    price = (BASE_PRICE + additive) * MARKUP_FACTOR
    book_count * price +
      TITLE_SETUP +
      PROOF +
      FILE_REVISIONS +
      ANNUAL_MARKET_DISTRIBUTION
  end
end
