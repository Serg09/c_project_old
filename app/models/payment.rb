# == Schema Information
#
# Table name: payments
#
#  id          :integer          not null, primary key
#  contribution_id :integer          not null
#  external_id :string           not null
#  state       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Payment < ActiveRecord::Base
  include AASM

  has_many :transactions, class_name: 'PaymentTransaction'
  belongs_to :contribution

  CREDIT_CARD_TYPES = [
    ['VISA', 'visa'],
    ['Mastercard', 'mastercard'],
    ['Discover', 'discover'],
    ['American Express', 'amex']
  ]

  attr_accessor :credit_card_number,
                :credit_card_type,
                :cvv,
                :expiration_month,
                :expiration_year,
                :billing_address_1,
                :billing_address_2,
                :billing_city, 
                :billing_state,
                :billing_postal_code,
                :billing_country_code,
                :payment_provider_error

  validates_presence_of :contribution_id, :state
  validates_presence_of :credit_card_number,
    :credit_card_type,
    :cvv,
    :billing_address_1,
    :billing_city,
    :billing_state,
    :billing_postal_code,
    :billing_country_code,
    on: :create
  validates_uniqueness_of :external_id

  aasm(:state, whiny_transitions: false) do
    state :pending, initial: true
    state :approved
    state :completed
    state :failed
    state :refunded

    event :execute do
      transitions from: :pending, to: :approved, if: :_execute
      transitions from: :pending, to: :failed, unless: :payment_provider_error
    end

    event :refund do
      transitions from: :completed, to: :refunded, if: :_refund
    end
  end

  def sale_id
    transactions.lazy.
      map{|t| extract_sale_id(t.response)}.
      select{|id| id}.
      first
  end

  private

  def _execute
    response = PAYMENT_PROVIDER.execute_payment(self)
    create_transaction(response, :sale)
    
    response[:state] == 'approved'
  rescue => e
    self.payment_provider_error = e
    Rails.logger.error "Error executing payment #{self.inspect}, #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    false
  end

  def _refund
    response = PAYMENT_PROVIDER.refund_payment(self, contribution.amount * 0.97)
    create_transaction(response, :refund)

    %w(pending completed).include?(response[:state])
  rescue => e
    self.payment_provider_error = e
    Rails.logger.error "Error refunding payment #{self.inspect}, #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    false
  end

  def create_transaction(response, intent)
    transaction = transactions.create(intent: intent,
                                      state: response[:state],
                                      response: response.to_json)
    unless transaction.save
      Rails.logger.warn "Unable to create payment transaction #{transaction.inspect} for response #{response.inspect}"
    end
  end

  def extract_sale_id(content)
    data = JSON.parse(content, symbolize_names: true)
    transaction = data[:transactions].first
    related_resource = transaction[:related_resources].first
    sale = related_resource[:sale]
    sale[:id]
  end
end
