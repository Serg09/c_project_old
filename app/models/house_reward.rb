# == Schema Information
#
# Table name: house_rewards
#
#  id                        :integer          not null, primary key
#  description               :string(255)      not null
#  physical_address_required :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  estimator_class           :string(200)
#

class HouseReward < ActiveRecord::Base
  has_many :rewards

  validates :description, presence: true, length: { maximum: 255 }

  def estimator
    return nil unless @estimator || estimator_class.present?
    @estimator ||= estimator_class.constantize.new
  rescue NameError
    raise InvalidClassNameError.new "estimator_class \"#{estimator_class}\" is not a valid class."
  end

  def estimator=(estimator)
    if estimator.present? && !estimator.respond_to?(:estimate)
      raise ArgumentError.new("'estimator' must implement 'estimate'")
    end
    @estimator = estimator
  end

  def estimate_cost(count)
    return nil unless estimator
    estimator.estimate(count)
  end
end

class InvalidClassNameError < StandardError; end
