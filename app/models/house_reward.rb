# == Schema Information
#
# Table name: house_rewards
#
#  id                        :integer          not null, primary key
#  description               :string(255)      not null
#  physical_address_required :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class HouseReward < ActiveRecord::Base
  has_many :rewards

  validates :description, presence: true, length: { maximum: 255 }
end
