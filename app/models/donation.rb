# == Schema Information
#
# Table name: donations
#
#  id          :integer          not null, primary key
#  campaign_id :integer          not null
#  amount      :decimal(, )      not null
#  email       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ip_address  :string(15)       not null
#  user_agent  :string           not null
#  reward_id   :integer
#  state       :string           default("pledged"), not null
#

class Donation < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :reward
  has_many :payments

  validates_presence_of :campaign_id, :email, :amount, :ip_address, :user_agent
  validates_numericality_of :amount, greater_than: 0
  validates_format_of :email, with: /\A^\w[\w_\.-]+@\w[\w_\.-]+\.[a-z]{2,}\z/i
  validates_format_of :ip_address, with: /\A\d{1,3}(\.\d{1,3}){3}\z/
  validate :reward_is_from_same_campaign

  scope :pledged, ->{where(state: 'pledged')}
  scope :collected, ->{where(state: 'collected')}
  scope :cancelled, ->{where(state: 'cancelled')}

  state_machine :initial => :pledged do
    before_transition :pledged => :collected, do: :create_payment
    before_transition :collected => :cancelled, do: :refund_payment
    event :collect do
      transition :pledged => :collected
    end
    event :cancel do
      transition [:pledged, :collected] => :cancelled
    end
    state :pledged, :collected, :cancelled
  end

  def create_payment
  end

  def refund_payment
    payment = first_approved_payment
    result = PAYMENT_PROVIDER.refund(payment.sale_id)
    tx = payment.transactions.create!(intent: PaymentTransaction.REFUND,
                                      state: result.state,
                                      response: result.to_json)
    payment.state = result.state
    payment.state == 'completed'
  rescue => e
    Rails.logger.error "Unable to refund the payment. id=#{payment.try(:id)}, external_id=#{payment.try(:external_id)}, #{e.message} at #{e.backtrace.join("\n  ")}"
    false
  end

  private

  def first_approved_payment
    payment = payments.approved.first
    raise Exceptions::PaymentNotFoundError.new("No approved payment found for donation #{id}") unless payment
    payment
  end

  def reward_is_from_same_campaign
    return unless reward
    unless reward.campaign_id == campaign_id
      errors.add :reward_id, 'must belong to the campaign to which a donation is being made'
    end
  end
end
