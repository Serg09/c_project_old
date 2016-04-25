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

class Fulfillment < ActiveRecord::Base
  belongs_to :donation
  belongs_to :reward
  validates_presence_of :donation_id, :reward_id, :first_name, :last_name
  validates_length_of :first_name, maximum: 100
  validates_length_of :last_name, maximum: 100

  scope :delivered, ->{where(delivered: true)}
  scope :undelivered, ->{where(delivered: false)}
  scope :house, ->{joins(reward: :house_reward)}
  scope :ready, ->{joins(donation: :campaign).where(campaigns: {state: 'collected'}, donations: {state: 'collected'})}

  def self.author(author_or_id)
    id = author_or_id.respond_to?(:id) ?
      author_or_id.id :
      author_or_id
    joins(:reward, donation: [campaign: :book]).
      where('house_reward_id is null and books.author_id = ?', id)
  end
end
