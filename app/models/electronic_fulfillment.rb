# == Schema Information
#
# Table name: fulfillments
#
#  id           :integer          not null, primary key
#  type         :string(50)       not null
#  donation_id  :integer          not null
#  reward_id    :integer          not null
#  email        :string(200)
#  address1     :string(100)
#  address2     :string(100)
#  city         :string(100)
#  state        :string(2)
#  postal_code  :string(15)
#  country_code :string(2)
#  delivered    :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  first_name   :string(100)      not null
#  last_name    :string(100)      not null
#

class ElectronicFulfillment < Fulfillment
  validates_presence_of :email
  validates_format_of :email, with: /\A[a-z0-9\+\._-]+@[a-z0-9_\.-]+\.[a-z]{2,4}\z/i
  validates_length_of :email, maximum: 200
end
