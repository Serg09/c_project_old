require 'rails_helper'

RSpec.describe Donation, type: :model do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:reward) { FactoryGirl.create(:reward, campaign: campaign) }
  let (:attributes) do
    {
      email: 'john@doe.com',
      amount: 100.00,
      campaign_id: campaign.id,
      ip_address: '123.456.789.012',
      user_agent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'
    }
  end

  it 'can be created from valid attributes' do
    donation = Donation.new attributes
    expect(donation).to be_valid
  end

  describe '#campaign_id' do
    it 'is required' do
      donation = Donation.new attributes.except(:campaign_id)
      expect(donation).to have_at_least(1).error_on :campaign_id
    end
  end

  describe '#campaign' do
    it 'is a reference to the campaign to which the donation belongs' do
      donation = Donation.new attributes
      expect(donation.campaign).not_to be_nil
    end
  end

  describe '#email' do
    it 'is required' do
      donation = Donation.new attributes.except(:email)
      expect(donation).to have_at_least(1).error_on :email
    end

    it 'must be a valid email' do
      donation = Donation.new attributes.merge(email: 'notavalidemail')
      expect(donation).to have_at_least(1).error_on :email
    end
  end

  describe '#amount' do
    it 'is required' do
      donation = Donation.new attributes.except(:amount)
      expect(donation).to have_at_least(1).error_on :amount
    end

    it 'must be greater than zero' do
      donation = Donation.new attributes.merge(amount: 0)
      expect(donation).to have_at_least(1).error_on :amount
    end
  end

  describe '#ip_address' do
    it 'is required' do
      donation = Donation.new attributes.except(:ip_address)
      expect(donation).to have_at_least(1).error_on :ip_address
    end

    it 'must be a valid IP address' do
      donation = Donation.new attributes.merge(ip_address: 'notavalidipaddress')
      expect(donation).to have_at_least(1).error_on :ip_address
    end
  end

  describe '#user_agent' do
    it 'is required' do
      donation = Donation.new attributes.except(:user_agent)
      expect(donation).to have_at_least(1).error_on :user_agent
    end
  end

  describe '#reward' do
    let (:other_reward) { FactoryGirl.create(:reward) }

    it 'is a reference to the reward selected for the donation' do
      donation = Donation.new attributes.merge(reward_id: reward.id)
      expect(donation.reward.id).to eq reward.id
    end

    it 'must reference the same campaign as the donation' do
      donation = Donation.new attributes.merge(reward_id: other_reward.id)
      expect(donation).to have_at_least(1).error_on :reward_id
    end
  end
end
