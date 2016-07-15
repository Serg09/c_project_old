require 'rails_helper'

describe PublishingCostEstimator do

  # From Pricing Model spreadsheet
  #
  # Title Setup                         95.00
  # Physical Book Proof Hardback        45.00
  # Revision to Cover & Interior Files  50.00
  # Yearly Print Market Distribution    15.00
  #------------------------------------------
  #                                    205.00

  describe '#estimate' do
    tests = [
      { book_count: 1,   expected: 215.91 },
      { book_count: 2,   expected: 224.39 },
      { book_count: 3,   expected: 231.26 },
      { book_count: 4,   expected: 237.13 },
      { book_count: 5,   expected: 242.38 },
      { book_count: 6,   expected: 247.30 },
      { book_count: 7,   expected: 252.04 },
      { book_count: 8,   expected: 256.74 },
      { book_count: 9,   expected: 261.46 },
      { book_count: 10,  expected: 266.24 },
      { book_count: 15,  expected: 291.39 },
      { book_count: 20,  expected: 318.22 },
      { book_count: 25,  expected: 345.87 },
      { book_count: 50,  expected: 486.25 },
      { book_count: 75,  expected: 626.88 },
      { book_count: 100, expected: 767.50 }
    ]
    tests.each do |test|
      it "returns a value close to #{test[:expected]} when given #{test[:book_count]}" do
        estimator = PublishingCostEstimator.new
        expect(estimator.estimate(test[:book_count])).to be_close_to test[:expected], 0.05
      end
    end
  end
end
