require 'rails_helper'

describe EbookCostEstimator do
  describe '#estimate' do
    context 'for a book count of zero' do
      it 'returns 0' do
        expect(EbookCostEstimator.new.estimate(0)).to eq 0
      end
    end
    context 'for a non-zero book count' do
      it 'returns 168' do
        expect(EbookCostEstimator.new.estimate(10)).to eq 168
      end
    end
  end
end
