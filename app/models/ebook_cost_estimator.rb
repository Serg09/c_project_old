class EbookCostEstimator
  ANNUAL_DISTRIBUTION = 38.0
  AVERAGE_CONVERSION = 130.0

  def estimate(book_count)
    return 0 unless book_count > 0
    ANNUAL_DISTRIBUTION + AVERAGE_CONVERSION
  end
end
