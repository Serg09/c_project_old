require 'rails_helper'

RSpec.describe ElectronicFulfillment, type: :model do
  let (:reward) { FactoryGirl.create(:reward, physical_address_required: false) }
  let (:contribution) { FactoryGirl.create(:contribution, campaign: reward.campaign) }
  let (:attributes) do
    {
      contribution_id: contribution.id, 
      reward_id: reward.id,
      email: 'john@doe.com',
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  it 'can be created from valid attributes' do
    fulfillment = ElectronicFulfillment.new attributes
    expect(fulfillment).to be_valid
  end

  describe '#contribution_id' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:contribution_id)
      expect(fulfillment).to have_at_least(1).error_on :contribution_id
    end
  end

  describe '#contribution' do
    it 'is a reference to the contribution that earned the reward' do
      fulfillment = ElectronicFulfillment.new attributes
      expect(fulfillment.contribution).to eq contribution
    end
  end

  describe '#reward_id' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:reward_id)
      expect(fulfillment).to have_at_least(1).error_on :reward_id
    end
  end

  describe '#reward' do
    it 'is a reference to the reward the donor earned with the contribution' do
      fulfillment = ElectronicFulfillment.new attributes
      expect(fulfillment.reward).to eq reward
    end
  end

  describe '#first_name' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:first_name)
      expect(fulfillment).to have_at_least(1).error_on :first_name
    end

    it 'cannot be more than 100 characters' do
      fulfillment = ElectronicFulfillment.new attributes.merge(first_name: 'a' * 101)
      expect(fulfillment).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      fulfillment = ElectronicFulfillment.new attributes.except(:last_name)
      expect(fulfillment).to have_at_least(1).error_on :last_name
    end

    it 'cannot be more than 100 characters' do
      fulfillment = ElectronicFulfillment.new attributes.merge(last_name: 'a' * 101)
      expect(fulfillment).to have_at_least(1).error_on :last_name
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
