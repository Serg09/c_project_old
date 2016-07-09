class PublishingCostEstimator
  BASE_PRICE = 4.5
  ADDITIVE = 5.5
  MULTIPLIER = 1.3

  def estimate(book_count)
    additive = ADDITIVE / (MULTIPLIER ** book_count)
    price = BASE_PRICE + additive
    book_count * price
  end
end
