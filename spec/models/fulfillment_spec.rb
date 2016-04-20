require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  let (:house_reward) { FactoryGirl.create(:house_reward) }
  let (:collected_campaign) { FactoryGirl.create(:collected_campaign) }
  let (:active_campaign) { FactoryGirl.create(:active_campaign) }
  let (:hr) { FactoryGirl.create(:reward, house_reward: house_reward, campaign: collected_campaign) }
  let (:ar1) { FactoryGirl.create(:reward, campaign: collected_campaign) }
  let (:ar2) { FactoryGirl.create(:reward, campaign: active_campaign) }

  let (:d1) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d2) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d3) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d4) { FactoryGirl.create(:collected_donation, campaign: active_campaign) }
  let (:d5) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d6) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d7) { FactoryGirl.create(:collected_donation, campaign: collected_campaign) }
  let (:d8) { FactoryGirl.create(:collected_donation, campaign: active_campaign) }

  let!(:f1) { FactoryGirl.create(:physical_fulfillment, delivered: false, reward: hr, donation: d1) }
  let!(:f2) { FactoryGirl.create(:physical_fulfillment, delivered: false, reward: ar1) }
  let!(:f3) { FactoryGirl.create(:electronic_fulfillment, delivered: false, reward: hr) }
  let!(:f4) { FactoryGirl.create(:electronic_fulfillment, delivered: false, reward: ar2) }
  let!(:f5) { FactoryGirl.create(:physical_fulfillment, delivered: true, reward: hr) }
  let!(:f6) { FactoryGirl.create(:physical_fulfillment, delivered: true, reward: ar1) }
  let!(:f7) { FactoryGirl.create(:electronic_fulfillment, delivered: true, reward: hr) }
  let!(:f8) { FactoryGirl.create(:electronic_fulfillment, delivered: true, reward: ar2) }

  describe '::undelivered' do
    it 'returns a list of fulfillments that have not been delivered' do
      expect(Fulfillment.undelivered.map(&:id)).to contain_exactly *[f1, f2, f3, f4].map(&:id)
    end
  end

  describe '::delivered' do
    it 'returns a list of fulfillments that have been delivered' do
      expect(Fulfillment.delivered.map(&:id)).to contain_exactly *[f5, f6, f7, f8].map(&:id)
    end
  end

  describe '::house' do
    it 'returns a list of fulfillments that are to be fulfilled by the company' do
      expect(Fulfillment.house.map(&:id)).to contain_exactly *[f1, f3, f5, f7].map(&:id)
    end
  end

  describe '::author' do
    it 'returns a list of fulfillments that are to be fulfilled by the author' do
      expect(Fulfillment.author.map(&:id)).to contain_exactly *[f2, f4, f6, f8].map(&:id)
    end
  end

  describe '::ready' do
    it 'returns a list of fulfillments that are ready to be fulfilled (i.e., the campaign has been closed and the payment collected)' do
      expect(Fulfillment.ready.map(&:id)).to contain_exactly *[f1, f2, f3, f5, f6, f7].map(&:id)
    end
  end
end
