require 'rails_helper'

RSpec.describe HouseReward, type: :model do
  let (:attributes) do
    {
      description: 'Sense of accomplishment',
      physical_address_required: true
    }
  end

  it 'can be created from valid attributes' do
    reward = HouseReward.new attributes
    expect(reward).to be_valid
  end

  describe '#description' do
    it 'is required' do
      reward = HouseReward.new attributes.except(:description)
      expect(reward).to have_at_least(1).error_on :description
    end

    it 'cannot be more than 255 characters' do
      reward = HouseReward.new attributes.merge(description: 'X' * 256)
      expect(reward).to have_at_least(1).error_on :description
    end
  end

  describe '#physical_address_required' do
    it 'defaults to false if no value is specified' do
      reward = HouseReward.new attributes.except(:physical_address_required)
      expect(reward.physical_address_required?).to be false
    end
  end

  describe '#rewards' do
    it 'is a list of campaign rewards that reference this house reward' do
      reward = HouseReward.new attributes
      expect(reward).to have(0).rewards
    end
  end

  describe '#estimator' do
    context 'when #estimator_class is a valid class name' do
      let (:reward) { FactoryGirl.create(:house_reward, estimator_class: 'PublishingCostEstimator') }

      it 'is an instance of the specified estimator_class' do
        expect(reward.estimator).to be_a PublishingCostEstimator
      end
    end

    context 'when #estimator_class is nil' do
      let (:reward) { FactoryGirl.create(:house_reward, estimator_class: nil) }

      it 'is nil' do
        expect(reward.estimator).to be_nil
      end
    end

    context 'when #estimator_class is an invalid class name' do
      let (:reward) { FactoryGirl.create(:house_reward, estimator_class: 'not_a_class') }

      it 'raises an error' do
        expect{reward.estimator}.to \
          raise_error(InvalidClassNameError, "estimator_class \"not_a_class\" is not a valid class.")
      end
    end
  end

  describe '#estimated_cost' do
    context 'when a cost estimator is specified' do
      let (:estimator) { double('estimator') }
      let (:reward) { FactoryGirl.create(:house_reward, estimator: estimator) }

      it 'returns the value generate by an instance of the estimator' do
        expect(estimator).to receive(:estimate).with(2).and_return(6.28)
        expect(reward.estimate_cost(2)).to eq 6.28
      end
    end

    context 'when a cost estimate is absent' do
      let (:reward) { FactoryGirl.create(:house_reward, estimator: nil) }

      it 'returns nil' do
        expect(reward.estimate_cost(2)).to be_nil
      end
    end
  end
end
