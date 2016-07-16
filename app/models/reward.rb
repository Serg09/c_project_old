# == Schema Information
#
# Table name: rewards
#
#  id                        :integer          not null, primary key
#  campaign_id               :integer          not null
#  description               :string(100)      not null
#  long_description          :text
#  minimum_contribution      :decimal(, )      not null
#  physical_address_required :boolean          default(FALSE), not null
#  house_reward_id           :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Reward < ActiveRecord::Base
  belongs_to :house_reward
  belongs_to :campaign
  has_many :fulfillments, dependent: :restrict_with_error
  has_many :contributions, through: :fulfillments

  before_save :process_photo_file

  validates_presence_of :campaign_id, :description, :minimum_contribution
  validates_length_of :description, maximum: 100
  validates_uniqueness_of :description, scope: :campaign_id
  validates_numericality_of :minimum_contribution, greater_than: 0

  attr_accessor :photo_file

  scope :by_minimum_contribution, ->{order(:minimum_contribution)}
  scope :for_amount, ->(amount){where('minimum_contribution <= ?', amount)}

  def initialize(attributes = {})
    super
    apply_house_reward_attributes
  end

  def estimate_cost
    return unless house_reward.present?
    house_reward.estimate_cost(fulfillments.count)
  end

  def working_description
    house_reward ? house_reward.description : description
  end

  def working_physical_address_required
    house_reward ? house_reward.physical_address_required : physical_address_required
  end

  def working_long_description
    return long_description if long_description.present?
    return house_reward.long_description if house_reward.present?
  end

  def visible_to_owner?
    true
  end

  def visible_to_public?
    campaign.active?
  end

  private

  def apply_house_reward_attributes
    return unless house_reward
    self.description = house_reward.description
    self.physical_address_required = house_reward.physical_address_required
  end

  def process_photo_file
    return unless photo_file

    image = Image.find_or_create_from_file(photo_file, campaign.book.author)
    self.photo_id = image.id if image
  end
end
