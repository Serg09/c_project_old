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
end
