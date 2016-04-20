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

class PhysicalFulfillment < Fulfillment
  validates_presence_of :address1, :city, :state, :postal_code, :country_code
  validates_length_of :address1, maximum: 100
  validates_length_of :address2, maximum: 100
  validates_length_of :city, maximum: 100
  validates_length_of :state, is: 2
  validates_length_of :postal_code, minimum: 5, maximum: 15
  validates_length_of :country_code, is: 2
end
