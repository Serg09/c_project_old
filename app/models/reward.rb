# == Schema Information
#
# Table name: rewards
#
#  id                        :integer          not null, primary key
#  campaign_id               :integer          not null
#  description               :string(100)      not null
#  long_description          :text
#  physical_address_required :boolean          default(FALSE), not null
#  house_reward_id           :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Reward < ActiveRecord::Base
  belongs_to :house_reward
  belongs_to :campaign

  validates_presence_of :campaign_id, :description, :minimum_donation
  validates_length_of :description, maximum: 100
  validates_uniqueness_of :description, scope: :campaign_id
  validates_numericality_of :minimum_donation, greater_than: 0

  def initialize(attributes = {})
    super
    apply_house_reward_attributes
  end

  def working_description
    house_reward ? house_reward.description : description
  end

  def working_physical_address_required
    house_reward ? house_reward.physical_address_required : physical_address_required
  end

  private

  def apply_house_reward_attributes
    return unless house_reward
    self.description = house_reward.description
    self.physical_address_required = house_reward.physical_address_required
  end
end
