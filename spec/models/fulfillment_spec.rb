require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  let (:house_reward) { FactoryGirl.create(:house_reward) }
  let (:hr) { FactoryGirl.create(:reward, house_reward: house_reward) }
  let (:ar) { FactoryGirl.create(:reward) }

  let!(:f1) { FactoryGirl.create(:physical_fulfillment, delivered: false, reward: hr) }
  let!(:f2) { FactoryGirl.create(:physical_fulfillment, delivered: false, reward: ar) }
  let!(:f3) { FactoryGirl.create(:electronic_fulfillment, delivered: false, reward: hr) }
  let!(:f4) { FactoryGirl.create(:electronic_fulfillment, delivered: false, reward: ar) }
  let!(:f5) { FactoryGirl.create(:physical_fulfillment, delivered: true, reward: hr) }
  let!(:f6) { FactoryGirl.create(:physical_fulfillment, delivered: true, reward: ar) }
  let!(:f7) { FactoryGirl.create(:electronic_fulfillment, delivered: true, reward: hr) }
  let!(:f8) { FactoryGirl.create(:electronic_fulfillment, delivered: true, reward: ar) }

  describe '::undelivered' do
    it 'returns a list of fulfillments that have not been delivered' do
      expect(Fulfillment.undelivered.map(&:id)).to eq [f1, f2, f3, f4].map(&:id)
    end
  end

  describe '::delivered' do
    it 'returns a list of fulfillments that have been delivered' do
      expect(Fulfillment.delivered.map(&:id)).to eq [f5, f6, f7, f8].map(&:id)
    end
  end

  describe '::house' do
    it 'returns a list of fulfillments that are to be fulfilled by the company' do
      expect(Fulfillment.house.map(&:id)).to eq [f1, f3, f5, f7].map(&:id)
    end
  end

  describe '::author' do
    it 'returns a list of fulfillments that are to be fulfilled by the author' do
      expect(Fulfillment.author.map(&:id)).to eq [f2, f4, f6, f8].map(&:id)
    end
  end
end
