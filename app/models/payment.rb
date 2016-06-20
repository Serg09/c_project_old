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

  has_many :transactions, class_name: 'PaymentTransaction'

  CREDIT_CARD_TYPES = [
    ['VISA', 'visa'],
    ['Mastercard', 'mastercard'],
    ['Discover', 'discover'],
    ['American Express', 'amex']
  ]

  belongs_to :contribution

  validates_presence_of :contribution_id, :external_id, :state
  validates_uniqueness_of :external_id

  PaymentTransaction::STATES.each do |state|
    scope state.to_sym, ->{where(state: state)}
  end

  def sale_id
    transactions.lazy.
      map{|t| extract_sale_id(t.response)}.
      select{|id| id}.
      first
  end

  private

  def extract_sale_id(content)
    data = JSON.parse(content, symbolize_names: true)
    transaction = data[:transactions].first
    related_resource = transaction[:related_resources].first
    sale = related_resource[:sale]
    sale[:id]
  end
end
