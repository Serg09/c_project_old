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
      { book_count: 1,   expected: 214.61 },
      { book_count: 2,   expected: 219.32 },
      { book_count: 3,   expected: 224.03 },
      { book_count: 4,   expected: 228.74 },
      { book_count: 5,   expected: 233.45 },
      { book_count: 6,   expected: 238.16 },
      { book_count: 7,   expected: 242.87 },
      { book_count: 8,   expected: 247.58 },
      { book_count: 9,   expected: 252.29 },
      { book_count: 10,  expected: 257.00 },
      { book_count: 15,  expected: 280.55 },
      { book_count: 20,  expected: 302.87 },
      { book_count: 25,  expected: 324.95 },
      { book_count: 50,  expected: 443.27 },
      { book_count: 75,  expected: 561.57 },
      { book_count: 100, expected: 656.87 }
    ]
    tests.each do |test|
      it "returns a value close to #{test[:expected]} when given #{test[:book_count]}" do
        estimator = PublishingCostEstimator.new
        expect(estimator.estimate(test[:book_count])).to be_close_to test[:expected], 0.15
      end
    end
  end
end
