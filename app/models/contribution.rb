# == Schema Information
#
# Table name: contributions
#
#  id          :integer          not null, primary key
#  campaign_id :integer          not null
#  amount      :decimal(, )      not null
#  email       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ip_address  :string(15)       not null
#  user_agent  :string           not null
#  state       :string           default("incipient"), not null
#  public_key  :string(36)       not null
#

class Contribution < ActiveRecord::Base
  include AASM

  belongs_to :campaign
  belongs_to :reward
  has_and_belongs_to_many :payments
  has_many :transactions, through: :payments
  has_one :fulfillment

  validates_presence_of :campaign_id, :amount, :ip_address, :user_agent, :email
  validates_numericality_of :amount, greater_than: 0
  validates_format_of :email, with: /\A^\w[\w_\.-]+@\w[\w_\.-]+\.[a-z]{2,}\z/i, if: :email
  validates_format_of :ip_address, with: /\A\d{1,3}(\.\d{1,3}){3}\z/
  validate :reward_is_from_same_campaign

  before_create :ensure_public_key

  aasm(:state, whiny_transitions: false) do
    state :incipient, initial: true
    state :pledged
    state :collected
    state :cancelled

    event :pledge do
      transitions from: :incipient, to: :pledged, if: :email_present?
    end

    event :collect do
      transitions from: [:incipient, :pledged], to: :collected, if: :_collect
    end

    event :cancel do
      transitions from: [:pledged, :collected], to: :cancelled, if: :_cancel
    end
  end

  private

  def _collect
    return true if payments.any?{|p| p.approved? || p.completed?}
    payment = payments.detect{|p| p.pending?}
    payment.execute!
  end

  def _cancel
    payment = first_approved_payment
    payment.refund!
  end

  def email_present?
    email.present?
  end

  def first_approved_payment
    payment = payments.approved.first
    raise Exceptions::PaymentNotFoundError.new("No approved payment found for contribution #{id}") unless payment
    payment
  end

  def reward_is_from_same_campaign
    return unless reward
    unless reward.campaign_id == campaign_id
      errors.add :reward_id, 'must belong to the campaign to which a contribution is being made'
    end
  end

  def ensure_public_key
    self.public_key ||= SecureRandom.uuid
  end
end
