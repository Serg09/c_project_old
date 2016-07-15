require 'rails_helper'

describe EbookCostEstimator do
  describe '#estimate' do
    it 'returns 168' do
      expect(EbookCostEstimator.new.estimate(10)).to eq 168
    end
  end
end
