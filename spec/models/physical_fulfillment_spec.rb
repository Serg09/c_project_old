require 'rails_helper'

RSpec.describe PhysicalFulfillment, type: :model do
  let (:reward) { FactoryGirl.create(:reward, physical_address_required: true) }
  let (:contribution) { FactoryGirl.create(:contribution, campaign: reward.campaign) }
  let (:attributes) do
    {
      contribution_id: contribution.id,
      reward_id: reward.id,
      first_name: 'John',
      last_name: 'Doe',
      address1: '1234 Main St',
      address2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200',
      country_code: 'US'
    }
  end

  it 'can be created from valid attributes' do
    fulfillment = PhysicalFulfillment.new attributes
    expect(fulfillment).to be_valid
  end

  describe '#contribution_id' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:contribution_id)
      expect(fulfillment).to have_at_least(1).error_on :contribution_id
    end
  end

  describe '#contribution' do
    it 'is a reference to the contribution that earned the reward' do
      fulfillment = PhysicalFulfillment.new attributes
      expect(fulfillment.contribution).to eq contribution
    end
  end

  describe '#reward_id' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:reward_id)
      expect(fulfillment).to have_at_least(1).error_on :reward_id
    end
  end

  describe '#reward' do
    it 'is a reference to the reward the donor earned with the contribution' do
      fulfillment = PhysicalFulfillment.new attributes
      expect(fulfillment.reward).to eq reward
    end
  end

  describe '#first_name' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:first_name)
      expect(fulfillment).to have_at_least(1).error_on :first_name
    end

    it 'cannot be more than 100 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(first_name: 'a' * 101)
      expect(fulfillment).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:last_name)
      expect(fulfillment).to have_at_least(1).error_on :last_name
    end

    it 'cannot be more than 100 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(last_name: 'a' * 101)
      expect(fulfillment).to have_at_least(1).error_on :last_name
    end
  end

  describe '#address1' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:address1)
      expect(fulfillment).to have_at_least(1).error_on :address1
    end

    it 'cannot be longer than 100 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(address1: 'x' * 101)
      expect(fulfillment).to have_at_least(1).error_on :address1
    end
  end

  describe '#address2' do
    it 'cannot be longer than 100 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(address2: 'x' * 101)
      expect(fulfillment).to have_at_least(1).error_on :address2
    end
  end

  describe '#city' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:city)
      expect(fulfillment).to have_at_least(1).error_on :city
    end

    it 'cannot be longer than 100 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(city: 'x' * 101)
      expect(fulfillment).to have_at_least(1).error_on :city
    end
  end

  describe '#state' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:state)
      expect(fulfillment).to have_at_least(1).error_on :state
    end

    it 'cannot be more than 2 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(state: 'TEX')
      expect(fulfillment).to have_at_least(1).error_on :state
    end

    it 'cannot be less than 2 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(state: 'T')
      expect(fulfillment).to have_at_least(1).error_on :state
    end
  end

  describe '#postal_code' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:postal_code)
      expect(fulfillment).to have_at_least(1).error_on :postal_code
    end

    it 'cannot be less than 5 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(postal_code: '1234')
      expect(fulfillment).to have_at_least(1).error_on :postal_code
    end

    it 'cannot be longer than 15 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(postal_code: '1' * 16)
      expect(fulfillment).to have_at_least(1).error_on :postal_code
    end
  end

  describe '#country_code' do
    it 'is required' do
      fulfillment = PhysicalFulfillment.new attributes.except(:country_code)
      expect(fulfillment).to have_at_least(1).error_on :country_code
    end

    it 'must be 2 characters' do
      fulfillment = PhysicalFulfillment.new attributes.merge(country_code: 'USA')
      expect(fulfillment).to have_at_least(1).error_on :country_code
    end
  end
end
