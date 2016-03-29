require 'rails_helper'

RSpec.describe Reward, type: :model do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:other_campaign) { FactoryGirl.create(:campaign) }
  let (:attributes) do
    {
      campaign_id: campaign.id,
      description: 'Pat on the back',
      long_description: 'blah blah blah',
      minimum_donation: 50,
      physical_address_required: true
    }
  end

  it 'can be created from valid attributes' do
    reward = Reward.new attributes
    expect(reward).to be_valid
  end

  describe '#campaign_id' do
    it 'is required' do
      reward = Reward.new attributes.except(:campaign_id)
      expect(reward).to have_at_least(1).error_on :campaign_id
    end
  end

  describe '#campaign' do
    it 'is a reference to the campaign to which the reward belongs' do
      reward = Reward.new attributes
      expect(reward.campaign.id).to eq campaign.id
    end
  end

  describe '#description' do
    it 'is required' do
      reward = Reward.new attributes.except(:description)
      expect(reward).to have_at_least(1).error_on :description
    end

    it 'cannot be more than 100 characters' do
      reward = Reward.new attributes.merge(description: "x" * 101)
      expect(reward).to have_at_least(1).error_on :description
    end

    it 'must be unique within a campaign' do
      r1 = Reward.create! attributes
      r2 = Reward.new attributes
      expect(r2).to have_at_least(1).error_on :description
    end

    it 'can be repeated between campaigns' do
      r1 = Reward.create! attributes
      r2 = Reward.new attributes.merge(campaign_id: other_campaign.id)
      expect(r2).to be_valid
    end
  end

  describe '#minimum_donation' do
    it 'is required' do
      reward = Reward.new attributes.except(:minimum_donation)
      expect(reward).to have_at_least(1).error_on :minimum_donation
    end

    it 'must be greater than zero' do
      reward = Reward.new attributes.merge(minimum_donation: 0)
      expect(reward).to have_at_least(1).error_on :minimum_donation
    end
  end

  describe '#physical_address_required' do
    it 'defaults to false if no value is specified' do
      reward = Reward.create attributes.except(:physical_address_required)
      expect(reward.physical_address_required).to be false
    end
  end

  context 'when #house_reward_id is present' do
    let (:house_reward) { FactoryGirl.create(:house_reward, physical_address_required: false) }

    describe '#working_description' do
      it 'is the description of the house reward' do
        reward = Reward.new attributes.
          except(:description, :physical_address_required).
          merge(house_reward_id: house_reward.id)
        expect(reward).to be_valid
        expect(reward.working_description).to eq house_reward.description
      end
    end

    describe '#working_physical_address_required' do
      it 'is the value from the house reward' do
        reward = Reward.new attributes.
          except(:description, :physical_address_required).
          merge(house_reward_id: house_reward.id)
        expect(reward).to be_valid
        expect(reward.working_physical_address_required).to be false
      end
    end
  end

  context 'when #house_reward_id is absent' do
    describe '#working_description' do
      it 'is the description from the local record' do
        reward = Reward.new attributes
        expect(reward.working_description).to eq 'Pat on the back'
      end
    end

    describe '#working_physical_address_required' do
      it 'is the value from the local record' do
        reward = Reward.new attributes
        expect(reward.working_physical_address_required).to eq true
      end
    end
  end

  describe '::by_minimum_donation' do
    let!(:r1) { FactoryGirl.create(:reward, campaign: campaign, minimum_donation: 10) }
    let!(:r2) { FactoryGirl.create(:reward, campaign: campaign, minimum_donation: 5) }

    it 'returns the rewards sorted by minimum donation' do
      expect(campaign.rewards.by_minimum_donation.map(&:id)).to eq [r2.id, r1.id]
    end
  end
end
