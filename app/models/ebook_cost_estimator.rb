class EbookCostEstimator
  ANNUAL_DISTRIBUTION = 38.0
  AVERAGE_CONVERSION = 130.0

  def estimate(book_count)
    ANNUAL_DISTRIBUTION + AVERAGE_CONVERSION
  end
end
