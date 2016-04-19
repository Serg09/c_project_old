require 'rails_helper'

RSpec.describe ElectronicFulfillment, type: :model do
  let (:reward) { FactoryGirl.create(:reward, physical_address_required: false) }
  let (:donation) { FactoryGirl.create(:donation, campaign: reward.campaign, reward: reward) }
  let (:attributes) do
    {
      donation_id: donation.id, 
      reward_id: reward.id,
      email: 'john@doe.com'
    }
  end

  it 'can be created from valid attributes' do
    fulfillment = ElectronicFulfillment.new attributes
    expect(fulfillment).to be_valid
  end

  describe '#donation_id' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:donation_id)
      expect(fulfillment).to have_at_least(1).error_on :donation_id
    end
  end

  describe '#donation' do
    it 'is a reference to the donation that earned the reward' do
      fulfillment = ElectronicFulfillment.new attributes
      expect(fulfillment.donation).to eq donation
    end
  end

  describe '#reward_id' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:reward_id)
      expect(fulfillment).to have_at_least(1).error_on :reward_id
    end
  end

  describe '#reward' do
    it 'is a reference to the reward the donor earned with the donation' do
      fulfillment = ElectronicFulfillment.new attributes
      expect(fulfillment.reward).to eq reward
    end
  end

  describe '#email' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:email)
      expect(fulfillment).to have_at_least(1).error_on :email
    end

    it 'must be a valid email' do
      fulfillment = ElectronicFulfillment.new attributes.merge(email: 'notvalid')
      expect(fulfillment).to have_at_least(1).error_on :email
    end

    it 'cannot be more than 200 characters' do
      email = ('a' * 191) + '@gmail.com'
      fulfillment = ElectronicFulfillment.new attributes.merge(email: email)
      expect(fulfillment).to have_at_least(1).error_on :email
    end
  end
end
