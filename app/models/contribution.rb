# == Schema Information
#
# Table name: contributions
#
#  id          :integer          not null, primary key
#  campaign_id :integer          not null
#  amount      :decimal(, )      not null
#  email       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ip_address  :string(15)       not null
#  user_agent  :string           not null
#  state       :string           default("pledged"), not null
#

class Contribution < ActiveRecord::Base
  include AASM

  belongs_to :campaign
  belongs_to :reward
  has_many :payments
  has_many :transactions, through: :payments
  has_one :fulfillment

  validates_presence_of :campaign_id, :amount, :ip_address, :user_agent
  validates_numericality_of :amount, greater_than: 0
  validates_format_of :email, with: /\A^\w[\w_\.-]+@\w[\w_\.-]+\.[a-z]{2,}\z/i, if: :email
  validates_format_of :ip_address, with: /\A\d{1,3}(\.\d{1,3}){3}\z/
  validate :reward_is_from_same_campaign

  aasm(:state, whiny_transitions: false) do
    state :incipient, initial: true
    state :pledged
    state :collected
    state :cancelled

    event :pledge do
      transitions from: :incipient, to: :pledged, if: :email_present?
    end

    event :collect do
      transitions from: :pledged, to: :collected, if: :create_payment
    end

    event :cancel do
      transitions from: [:pledged, :collected], to: :cancelled, if: :refund_payment
    end
  end

  def create_payment
    raise 'not implemented'
  end

  def refund_payment
    payment = first_approved_payment
    refund = PAYMENT_PROVIDER.refund(payment.sale_id, amount)
    if refund
      tx = payment.transactions.create!(intent: PaymentTransaction.REFUND,
                                        state: refund.state,
                                        response: refund.to_json)
      refund.state == 'completed'
    else
      false
    end
  rescue => e
    Rails.logger.error "Unable to refund the payment. id=#{payment.try(:id)}, external_id=#{payment.try(:external_id)}, #{e.class.name}: #{e.message} at\n  #{e.backtrace.join("\n  ")}\n  refund=#{refund.try(:to_json)}"
    false
  end

  private

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
end
