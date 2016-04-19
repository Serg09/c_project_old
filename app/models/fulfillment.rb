# == Schema Information
#
# Table name: fulfillments
#
#  id           :integer          not null, primary key
#  type         :string(50)       not null
#  donation_id  :integer          not null
#  reward_id    :integer          not null
#  email        :string
#  address1     :string(100)
#  address2     :string(100)
#  city         :string(100)
#  state        :string(2)
#  postal_code  :string(15)
#  country_code :string(2)
#  delivered    :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Fulfillment < ActiveRecord::Base
  belongs_to :donation
  belongs_to :reward
  validates_presence_of :donation_id, :reward_id

  scope :delivered, ->{where(delivered: true)}
  scope :undelivered, ->{where(delivered: false)}
end
