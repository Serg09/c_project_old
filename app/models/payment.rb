# == Schema Information
#
# Table name: payments
#
#  id          :integer          not null, primary key
#  donation_id :integer          not null
#  external_id :string           not null
#  state       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Payment < ActiveRecord::Base

  has_many :transactions, class_name: 'PaymentTransaction'

  CREDIT_CARD_TYPES = [
    ['VISA', 'visa'],
    ['Mastercard', 'mastercard'],
    ['Discover', 'discover'],
    ['American Express', 'amex']
  ]

  belongs_to :donation

  validates_presence_of :donation_id, :external_id, :state
  validates_uniqueness_of :external_id

  scope :approved, ->{where(state: 'approved')}
  scope :failed, ->{where(state: 'failed')}

  def authorization_id
    transactions.
      approved.
      lazy.
      map(&:response).
      map{|r| extract_authorization_id(r)}.
      select{|id| id}.
      first
  end

  private

  def extract_authorization_id(raw_response)
    data = JSON.parse(raw_response, symbolize_names: true)
    transactions = data[:transactions]
    transaction = transactions.first
    related_resources = transaction[:related_resources]
    related_resource = related_resources.first
    authorization = related_resource[:authorization]
    authorization[:id]
  end
end
