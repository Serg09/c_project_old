require 'rails_helper'

RSpec.describe Reward, type: :model do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:other_campaign) { FactoryGirl.create(:campaign) }
  let (:attributes) do
    {
      campaign_id: campaign.id,
      description: 'Pat on the back',
      long_description: 'blah blah blah',
      minimum_contribution: 50,
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

  describe '#working_long_description' do
    context 'for a house-fulfilled reward' do
      let (:house_reward) { FactoryGirl.create(:house_reward) }

      context 'when #long_description present' do
        let (:reward) do
          FactoryGirl.create(:reward, house_reward: house_reward,
                                      long_description: 'this is the long desc.') 
        end

        it 'is equal to #long_description' do
          expect(reward.working_long_description).to eq(reward.long_description)
        end
      end

      context 'when #long_description is blank' do
        let (:reward) do
          FactoryGirl.create(:reward, house_reward: house_reward,
                                      long_description: nil)
        end

        it 'is equal to #long_description on the house reward' do
          expect(reward.working_long_description).to eq(house_reward.long_description)
        end
      end
    end
  end

  describe '#minimum_contribution' do
    it 'is required' do
      reward = Reward.new attributes.except(:minimum_contribution)
      expect(reward).to have_at_least(1).error_on :minimum_contribution
    end

    it 'must be greater than zero' do
      reward = Reward.new attributes.merge(minimum_contribution: 0)
      expect(reward).to have_at_least(1).error_on :minimum_contribution
    end
  end

  describe '#physical_address_required' do
    it 'defaults to false if no value is specified' do
      reward = Reward.create attributes.except(:physical_address_required)
      expect(reward.physical_address_required).to be false
    end
  end

  context 'when #house_reward_id is present' do
    let!(:house_reward) { FactoryGirl.create(:house_reward, physical_address_required: false) }
    let (:reward) do
      Reward.new attributes.
        except(:description, :physical_address_required).
        merge(house_reward: house_reward)
    end

    describe '#working_description' do
      it 'is the description of the house reward' do
        expect(reward).to be_valid
        expect(reward.working_description).to eq house_reward.description
      end
    end

    describe '#working_physical_address_required' do
      it 'is the value from the house reward' do
        expect(reward).to be_valid
        expect(reward.working_physical_address_required).to be false
      end
    end

    describe '#estimate_cost' do
      it 'delegates to HouseReward#estimate_cost' do
        expect(house_reward).to receive(:estimate_cost).and_return(3.14)
        expect(reward.estimate_cost).to eq 3.14
      end
    end
  end

  context 'when #house_reward_id is absent' do
    let (:reward) { Reward.new attributes }

    describe '#working_description' do
      it 'is the description from the local record' do
        expect(reward.working_description).to eq 'Pat on the back'
      end
    end

    describe '#working_physical_address_required' do
      it 'is the value from the local record' do
        expect(reward.working_physical_address_required).to eq true
      end
    end

    describe '#estimate_cost' do
      it 'delegates to HouseReward#estimate_cost' do
        expect(reward.estimate_cost).to be_nil
      end
    end
  end

  describe '::by_minimum_contribution' do
    let!(:r1) { FactoryGirl.create(:reward, campaign: campaign, minimum_contribution: 10) }
    let!(:r2) { FactoryGirl.create(:reward, campaign: campaign, minimum_contribution: 5) }

    it 'returns the rewards sorted by minimum contribution' do
      expect(campaign.rewards.by_minimum_contribution.map(&:id)).to eq [r2.id, r1.id]
    end
  end

  shared_context :fulfillments do
    let (:reward) { FactoryGirl.create(:reward, campaign: campaign, physical_address_required: false) }
    let (:d1) { FactoryGirl.create(:contribution, campaign: campaign) }
    let!(:f1) { FactoryGirl.create(:electronic_fulfillment, contribution: d1, reward: reward) }
    let (:d2) { FactoryGirl.create(:contribution, campaign: campaign) }
    let!(:f2) { FactoryGirl.create(:electronic_fulfillment, contribution: d2, reward: reward) }
  end

  describe '#contributions' do
    include_context :fulfillments

    it 'is a list of contributions which selected the reward' do
      expect(reward).to have(2).contributions
    end
  end

  describe '#fulfillments' do
    include_context :fulfillments

    it 'is a list of fulfillments for the reward' do
      expect(reward).to have(2).fulfillments
    end
  end
end
