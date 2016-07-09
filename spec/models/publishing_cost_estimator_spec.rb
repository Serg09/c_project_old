require 'rails_helper'

describe PublishingCostEstimator do
  describe '#estimate' do
    tests = [
      { book_count: 1,   expected: 9.61 },
      { book_count: 2,   expected: 14.32 },
      { book_count: 3,   expected: 19.03 },
      { book_count: 4,   expected: 23.74 },
      { book_count: 5,   expected: 28.45 },
      { book_count: 6,   expected: 33.16 },
      { book_count: 7,   expected: 37.87 },
      { book_count: 8,   expected: 42.58 },
      { book_count: 9,   expected: 47.29 },
      { book_count: 10,  expected: 52.00 },
      { book_count: 15,  expected: 75.55 },
      { book_count: 20,  expected: 97.87 },
      { book_count: 25,  expected: 119.95 },
      { book_count: 50,  expected: 238.27 },
      { book_count: 75,  expected: 356.57 },
      { book_count: 100, expected: 451.87 }
    ]
    tests.each do |test|
      it "returns a value close to #{test[:expected]} when given #{test[:book_count]}" do
        estimator = PublishingCostEstimator.new
        expect(estimator.estimate(test[:book_count])).to be_close_to test[:expected], 0.15
      end
    end
  end
end
