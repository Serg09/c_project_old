require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  let!(:undelivered1) { FactoryGirl.create(:physical_fulfillment, delivered: false) }
  let!(:delivered1) { FactoryGirl.create(:physical_fulfillment, delivered: true) }
  let!(:undelivered2) { FactoryGirl.create(:electronic_fulfillment, delivered: false) }
  let!(:delivered2) { FactoryGirl.create(:electronic_fulfillment, delivered: true) }

  describe '::undelivered' do
    it 'returns a list of fulfillments that have not been delivered' do
      expect(Fulfillment.undelivered.map(&:id)).to eq [undelivered1.id,
                                                       undelivered2.id]
    end
  end

  describe '::delivered' do
    it 'returns a list of fulfillments that have been delivered' do
      expect(Fulfillment.delivered.map(&:id)).to eq [delivered1.id,
                                                     delivered2.id]
    end
  end
end
