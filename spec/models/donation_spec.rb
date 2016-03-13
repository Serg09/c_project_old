require 'rails_helper'

RSpec.describe Donation, type: :model do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:attributes) do
    {
      email: 'john@doe.com',
      amount: 100.00,
      campaign_id: campaign.id
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
end
